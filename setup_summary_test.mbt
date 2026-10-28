///|
fn summary_report(
  values : Array[(String, @sta.Edge, Double?)],
) -> @sta.STAResult {
  {
    nodes: [],
    endpoints: values.map(v => {
      pin: v.0,
      edge: v.1,
      arrival_seconds: None,
      required_seconds: None,
      slack_seconds: v.2,
      setup_seconds: None,
      path: [],
    }),
    worst_slack_seconds: None,
    diagnostics: [],
    topological_order: [],
  }
}

///|
test "setup summary counts failing endpoints once and separates WNS from positive slack" {
  let r = summary_report([
    ("y", Rise, Some(-0.1e-9)),
    ("y", Fall, Some(-0.2e-9)),
    ("z", Rise, Some(0.2e-9)),
    ("z", Fall, Some(0.2e-9)),
    ("w", Rise, Some(-0.1e-9)),
    ("w", Fall, Some(0.4e-9)),
  ])
  let s = r.setup_summary()
  assert_true(s.status == Violated && s.endpoint_count == 3)
  assert_true(
    s.constrained_endpoint_edges == 6 && s.unconstrained_endpoint_edges == 0,
  )
  assert_true(s.violating_endpoint_edges == 3 && s.violating_endpoints == 2)
  assert_true(
    s.worst_slack_seconds == Some(-0.2e-9) &&
    s.worst_negative_slack_seconds == Some(-0.2e-9),
  )
}

///|
test "setup summary distinguishes full success partial unknown and no endpoints" {
  for
    (rise, fall, status, constrained, unknown) in [
      (Some(0.0), Some(1.0), @sta.Met, 2, 0),
      (Some(1.0), None, @sta.PartialCoverage, 1, 1),
      (None, None, @sta.NoCoverage, 0, 2),
      (Some(-1.0), None, @sta.Violated, 1, 1),
    ] {
    let s = summary_report([("y", Rise, rise), ("y", Fall, fall)]).setup_summary()
    assert_true(
      s.status == status &&
      s.constrained_endpoint_edges == constrained &&
      s.unconstrained_endpoint_edges == unknown,
    )
    if status == @sta.Met || status == @sta.PartialCoverage {
      assert_true(s.worst_negative_slack_seconds == Some(0.0))
    }
    if status == @sta.NoCoverage {
      assert_true(
        s.worst_slack_seconds is None && s.worst_negative_slack_seconds is None,
      )
    }
  }
  let s = summary_report([]).setup_summary()
  assert_true(
    s.status == NoEndpoints &&
    s.endpoint_count == 0 &&
    s.constrained_endpoint_edges == 0 &&
    s.unconstrained_endpoint_edges == 0,
  )
  assert_true(
    s.worst_slack_seconds is None && s.worst_negative_slack_seconds is None,
  )
}

///|
test "setup summary keeps finite extremes and rejects nonfinite public slack objects" {
  let s = summary_report([
    ("u/Y", Rise, Some(-1.0e308)),
    ("u~1Y", Rise, Some(1.0e308)),
  ]).setup_summary()
  assert_true(
    s.endpoint_count == 2 &&
    s.violating_endpoints == 1 &&
    s.worst_negative_slack_seconds == Some(-1.0e308),
  )
  for bits in [0x7ff0000000000000UL, 0x7ff8000000000000UL] {
    try
      summary_report([("x", Rise, Some(bits.reinterpret_as_double()))]).setup_summary()
    catch {
      e =>
        assert_true(
          "\{@debug.Debug::to_repr(e)}".contains(
            "nonfinite derived summary slack",
          ),
        )
    } noraise {
      _ => fail("nonfinite summary slack accepted")
    }
  }
}

///|
test "setup summary applies to the real DFF report without a second analysis" {
  let lib = @liberty.load_library(@testdata.library())
  let n = sequential()
  let c = @sta.parse_sdc(sdc(), lib, n)
  let s = run(n, c, lib~).setup_summary()
  assert_true(
    s.status == Met &&
    s.endpoint_count == 3 &&
    s.constrained_endpoint_edges == 6 &&
    s.violating_endpoint_edges == 0 &&
    s.worst_negative_slack_seconds == Some(0.0),
  )
  let c = { ..c, clock: { ..c.clock, period_seconds: 1.0e-12, }, }
  let s = run(n, c, lib~).setup_summary()
  assert_true(
    s.status == Violated &&
    s.violating_endpoint_edges == 6 &&
    s.violating_endpoints == 3,
  )
}

///|
test "setup summary JSON is optional composes with period budget and validates its flag" {
  let lib = @testdata.library()
  let base : Json = { "netlist": ToJson::to_json(sequential()), "sdc": sdc() }
  let disabled : Json = {
    "netlist": ToJson::to_json(sequential()),
    "sdc": sdc(),
    "setup_summary": false,
  }
  let combined : Json = {
    "netlist": ToJson::to_json(sequential()),
    "sdc": sdc(),
    "setup_summary": true,
    "period_budget": true,
  }
  let bad : Json = {
    "netlist": ToJson::to_json(sequential()),
    "sdc": sdc(),
    "setup_summary": "yes",
  }
  let original = @json.parse(@sta.analyze_json(lib, base.stringify()))
  guard original is { "ok": True, "result": expected, .. } else {
    fail("baseline failed")
  }
  for request in [base, disabled] {
    let value = @json.parse(@sta.analyze_json(lib, request.stringify()))
    assert_true(value.stringify() == original.stringify())
  }
  let value = @json.parse(@sta.analyze_json(lib, combined.stringify()))
  guard value
    is {
      "ok": True,
      "result": actual,
      "setup_summary": { "status": String("Met"), .. },
      "period_budget": { "status": String("Complete"), .. },
      ..
    } else {
    fail("combined reports missing")
  }
  assert_true(actual.stringify() == expected.stringify())
  let value = @json.parse(@sta.analyze_json(lib, bad.stringify()))
  guard value is { "ok": False, "error": String(message), .. } else {
    fail("invalid flag accepted")
  }
  assert_true(message.contains("setup_summary must be boolean"))
}
