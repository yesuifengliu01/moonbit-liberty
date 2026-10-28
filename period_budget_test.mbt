///|
fn period_bound(
  budget : @sta.PeriodBudget,
  pin : String,
  edge : @sta.Edge,
) -> Double? {
  budget.endpoint_bounds
  .iter()
  .find_first(e => e.pin == pin && e.edge == edge)
  .unwrap().bound_seconds
}

///|
fn period_wire() -> @sta.Netlist {
  {
    ports: [
      { name: "clk", net: "clk", direction: Input, },
      { name: "a", net: "a", direction: Input, },
      { name: "y", net: "a", direction: Output, },
    ],
    gates: [],
    nets: ["clk", "a"].map(name => { name, wire_cap_farads: 0.0, }),
  }
}

///|
test "period budget scalar hand calculation and crossing the predicted boundary" {
  let lib = r07_lib()
  let n = r07_net()
  let c = r07_constraints(lib, n)
  let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
  let b = a.budget
  assert_true(b.status == Complete)
  near(b.minimum_period_seconds.unwrap(), 1.0e-9, tolerance=1.0e-24)
  near(b.maximum_frequency_hz.unwrap(), 1.0e9, tolerance=1.0e-6)
  near(period_bound(b, "y", Rise).unwrap(), 0.98e-9, tolerance=1.0e-24)
  near(period_bound(b, "y", Fall).unwrap(), 1.0e-9, tolerance=1.0e-24)
  assert_true(
    b.limiting_endpoints.length() == 1 && b.limiting_endpoints[0].edge == Fall,
  )
  r06_same(a.timing, run(n, c, lib~))
  for (period, sign) in [(0.999e-9, -1), (1.0e-9, 0), (1.001e-9, 1)] {
    let c = { ..c, clock: { ..c.clock, period_seconds: period, }, }
    let slack = run(n, c, lib~).worst_slack_seconds.unwrap()
    if sign == 0 {
      near(slack, 0.0, tolerance=1.0e-24)
    } else {
      assert_true(slack * sign.to_double() > 0.0)
    }
  }
}

///|
test "period budget remains accurate with a huge reference period" {
  let lib = r07_lib()
  let n = r07_net()
  let c = r07_constraints(lib, n)
  let c = { ..c, clock: { ..c.clock, period_seconds: 1.0e200, }, }
  let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
  // At this scale period - worst_slack rounds to zero; direct endpoint bounds do not.
  assert_true(
    c.clock.period_seconds - a.timing.worst_slack_seconds.unwrap() == 0.0,
  )
  near(a.budget.minimum_period_seconds.unwrap(), 1.0e-9, tolerance=1.0e-24)
}

///|
test "period budget keeps real negative setup uncertainty and signed latency semantics" {
  let lib = @liberty.load_library(@testdata.library())
  let n = sequential()
  let c = @sta.parse_sdc(
    sdc() +
    "\nset_clock_transition 0.5 [get_clocks clk]\nset_input_transition 0.01 [get_ports a]\nset_clock_latency -0.2 [get_clocks clk]",
    lib,
    n,
  )
  let b = @sta.STAEngine::new(lib, n, c).run_period_analysis().budget
  near(
    period_bound(b, "launch/D", Rise).unwrap(),
    0.0518665e-9,
    tolerance=1.0e-24,
  )
  near(
    period_bound(b, "launch/D", Fall).unwrap(),
    0.0591908e-9,
    tolerance=1.0e-24,
  )
  assert_true(b.status == Complete)
}

///|
test "period budget never reports a full frequency from partial or absent constraints" {
  let lib = r07_lib()
  let n = r07_net()
  let c = r07_constraints(lib, n)
  let c = {
    ..c,
    input_delays: [{ port: "a", rise: Some(0.05e-9), fall: None, }],
  }
  let b = @sta.STAEngine::new(lib, n, c).run_period_analysis().budget
  assert_true(b.status == Partial)
  assert_true(
    b.constrained_endpoint_edges == 1 && b.unconstrained_endpoint_edges == 1,
  )
  assert_true(
    b.minimum_period_seconds is None && b.maximum_frequency_hz is None,
  )
  assert_true(period_bound(b, "y", Rise) is None)
  near(period_bound(b, "y", Fall).unwrap(), 1.0e-9, tolerance=1.0e-24)
  let c = { ..c, input_delays: [], output_delays: [], }
  let b = @sta.STAEngine::new(lib, n, c).run_period_analysis().budget
  assert_true(b.status == Unconstrained && b.constrained_endpoint_edges == 0)
  assert_true(
    b.minimum_period_seconds is None && b.maximum_frequency_hz is None,
  )
  let empty : @sta.Netlist = {
    ports: [{ name: "clk", net: "clk", direction: Input, }],
    gates: [],
    nets: [{ name: "clk", wire_cap_farads: 0.0, }],
  }
  let c = r08_constraints(lib, empty)
  let b = @sta.STAEngine::new(lib, empty, c).run_period_analysis().budget
  assert_true(b.status == Unconstrained && b.endpoint_bounds.is_empty())
}

///|
test "period budget preserves escaped endpoint identities across constraint lookup" {
  let lib = @liberty.load_library(@testdata.library())
  let base = period_wire()
  let n = {
    ..base,
    ports: base.ports.map(p => {
      if p.direction == Output {
        { ..p, name: "y/~𝄞", }
      } else {
        p
      }
    }),
  }
  let b = @sta.STAEngine::new(lib, n, r08_constraints(lib, n)).run_period_analysis().budget
  assert_true(b.status == Complete)
  near(period_bound(b, "y~1~0𝄞", Fall).unwrap(), 0.18e-9, tolerance=1.0e-24)
  assert_true(b.limiting_endpoints[0].pin == "y~1~0𝄞")
}

///|
test "period budget represents no positive limit without inventing infinite frequency" {
  let lib = @liberty.load_library(@testdata.library())
  let n = period_wire()
  let c = r08_constraints(lib, n)
  let c = {
    ..c,
    clock: { ..c.clock, latency_seconds: 0.25e-9, },
    input_delays: [{ port: "a", rise: Some(-0.5e-9), fall: Some(-0.5e-9), }],
    output_delays: [{ port: "y", rise: Some(-0.1e-9), fall: Some(-0.1e-9), }],
  }
  let b = @sta.STAEngine::new(lib, n, c).run_period_analysis().budget
  assert_true(b.status == NoPositiveLimit)
  near(b.minimum_period_seconds.unwrap(), 0.0, tolerance=0.0)
  assert_true(b.maximum_frequency_hz is None && b.limiting_endpoints.is_empty())
  near(period_bound(b, "y", Rise).unwrap(), -0.6e-9, tolerance=1.0e-24)
}

///|
test "period budget retains a tiny representable bound when its reciprocal overflows" {
  let lib = @liberty.load_library(@testdata.library())
  let n = period_wire()
  let c = r08_constraints(lib, n)
  let c = {
    ..c,
    clock: { ..c.clock, period_seconds: 1.0, },
    input_delays: [{ port: "a", rise: Some(1.0e-320), fall: Some(1.0e-320), }],
    output_delays: [{ port: "y", rise: Some(0.0), fall: Some(0.0), }],
  }
  let b = @sta.STAEngine::new(lib, n, c).run_period_analysis().budget
  assert_true(b.status == FrequencyOverflow)
  assert_true(
    b.minimum_period_seconds.unwrap() == 1.0e-320 &&
    b.maximum_frequency_hz is None,
  )
  let text = ToJson::to_json(b).stringify()
  assert_true(!text.contains("Infinity") && !text.contains("NaN"))
}

///|
test "period budget rejects unrepresentable derived bounds while legacy timing stays valid" {
  let lib = @liberty.load_library(@testdata.library())
  let n = period_wire()
  let c = r08_constraints(lib, n)
  let c = {
    ..c,
    clock: { ..c.clock, period_seconds: 1.0e308, },
    input_delays: [{ port: "a", rise: Some(1.0e308), fall: Some(1.0e308), }],
    output_delays: [{ port: "y", rise: Some(1.0e308), fall: Some(1.0e308), }],
  }
  ignore(run(n, c, lib~))
  try @sta.STAEngine::new(lib, n, c).run_period_analysis() catch {
    e =>
      assert_true(
        "\{@debug.Debug::to_repr(e)}".contains("nonfinite derived period bound"),
      )
  } noraise {
    _ => fail("unrepresentable budget accepted")
  }
}

///|
test "period budget JSON is opt in and leaves the legacy timing envelope intact" {
  let lib = @testdata.library()
  let n = ToJson::to_json(sequential())
  let original : Json = { "netlist": n, "sdc": sdc() }
  let disabled : Json = { "netlist": n, "sdc": sdc(), "period_budget": false }
  let enabled : Json = { "netlist": n, "sdc": sdc(), "period_budget": true }
  let malformed : Json = { "netlist": n, "sdc": sdc(), "period_budget": "yes" }
  let baseline = @json.parse(@sta.analyze_json(lib, original.stringify()))
  guard baseline is { "ok": True, "result": expected, .. } else {
    fail("baseline failed: " + baseline.stringify())
  }
  for request in [original, disabled] {
    let value = @json.parse(@sta.analyze_json(lib, request.stringify()))
    if value is { "period_budget": _, .. } {
      fail("budget must be opt in")
    }
  }
  let value = @json.parse(@sta.analyze_json(lib, enabled.stringify()))
  guard value
    is {
      "ok": True,
      "result": actual,
      "period_budget": { "status": String("Complete"), .. },
      ..
    } else {
    fail("missing budget")
  }
  assert_true(expected.stringify() == actual.stringify())
  let value = @json.parse(@sta.analyze_json(lib, malformed.stringify()))
  guard value is { "ok": False, .. } else {
    fail("invalid budget flag accepted")
  }
}
