///|
fn r10_nand() -> @liberty.Library raise {
  let lib = @liberty.load_library(@testdata.library())
  {
    ..lib,
    cells: lib.cells.map(cell => {
      if cell.name != "sky130_fd_sc_hd__nand2_1" {
        return cell
      }
      {
        ..cell,
        pins: cell.pins.map(pin => {
          ..pin,
          timings: pin.timings.map(arc => {
            ..arc,
            tables: arc.tables.map(t => {
              let value = match t.kind {
                "cell_rise" => 0.2
                "cell_fall" => 0.3
                "rise_transition" => 0.04
                "fall_transition" => 0.05
                _ => t.values[0]
              }
              {
                ..t,
                template_name: "scalar",
                variable_1: None,
                variable_2: None,
                index_1: [],
                index_2: [],
                values: [value],
              }
            }),
          }),
        }),
      }
    }),
  }
}

///|
test "repair10 common ideal latency does not change scalar slack budget or boundary" {
  let lib = r07_lib()
  let n = r07_net()
  let base = r07_constraints(lib, n)
  for latency in [1.0e12, -1.0e12, 0.2e-9] {
    let c = { ..base, clock: { ..base.clock, latency_seconds: latency, }, }
    let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
    near(a.budget.minimum_period_seconds.unwrap(), 1.0e-9, tolerance=1.0e-24)
    near(a.timing.worst_slack_seconds.unwrap(), 1.0e-9, tolerance=1.0e-24)
    assert_true(
      a.budget.limiting_endpoints.length() == 1 &&
      a.budget.limiting_endpoints[0].edge == Fall,
    )
    for (period, sign) in [(0.999e-9, -1), (1.001e-9, 1)] {
      let target = { ..c, clock: { ..c.clock, period_seconds: period, }, }
      assert_true(
        run(n, target, lib~).worst_slack_seconds.unwrap() * sign.to_double() >
        0.0,
      )
    }
  }
}

///|
test "repair10 predecessor selection survives common clock cancellation" {
  let lib = r10_nand()
  let n = r06_net("nand2")
  let base = r06_constraints(lib, n)
  let base = {
    ..base,
    clock: { ..base.clock, uncertainty_seconds: 0.0, },
    input_delays: [
      { port: "a", rise: Some(0.05e-9), fall: Some(0.05e-9), },
      { port: "b", rise: Some(0.8e-9), fall: Some(0.8e-9), },
    ],
  }
  for latency in [0.0, 1.0e12, -1.0e12] {
    let c = { ..base, clock: { ..base.clock, latency_seconds: latency, }, }
    let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
    near(a.budget.minimum_period_seconds.unwrap(), 1.2e-9, tolerance=1.0e-24)
    near(a.timing.worst_slack_seconds.unwrap(), 0.8e-9, tolerance=1.0e-24)
    for edge in [@sta.Rise, @sta.Fall] {
      assert_true(endpoint(a.timing, "y", edge).path[0].pin == "b")
    }
  }
}

///|
test "repair10 real DFF budgets and slacks are invariant under a common clock translation" {
  let lib = @liberty.load_library(@testdata.library())
  let n = sequential()
  let base = @sta.parse_sdc(sdc(), lib, n)
  let expected = @sta.STAEngine::new(lib, n, base).run_period_analysis()
  for latency in [1.0e12, -1.0e12] {
    let c = { ..base, clock: { ..base.clock, latency_seconds: latency, }, }
    let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
    near(
      a.budget.minimum_period_seconds.unwrap(),
      expected.budget.minimum_period_seconds.unwrap(),
      tolerance=1.0e-24,
    )
    for x in expected.timing.endpoints {
      near(
        endpoint(a.timing, x.pin, x.edge).slack_seconds.unwrap(),
        x.slack_seconds.unwrap(),
        tolerance=1.0e-24,
      )
      near(
        period_bound(a.budget, x.pin, x.edge).unwrap(),
        period_bound(expected.budget, x.pin, x.edge).unwrap(),
        tolerance=1.0e-24,
      )
    }
  }
}

///|
test "repair10 relative reference overflow must not reject finite legacy timing" {
  let lib = r07_lib()
  let lib = {
    ..lib,
    units: Some({ ..lib.units.unwrap(), time_seconds: 1.0, }),
    cells: lib.cells.map(cell => {
      ..cell,
      pins: cell.pins.map(pin => {
        ..pin,
        timings: pin.timings.map(arc => {
          ..arc,
          tables: arc.tables.map(t => {
            if ["cell_rise", "cell_fall"].contains(t.kind) {
              { ..t, values: [1.0e308], }
            } else {
              t
            }
          }),
        }),
      }),
    }),
  }
  let n : @sta.Netlist = {
    ports: [
      { name: "clk", net: "clk", direction: Input, },
      { name: "a", net: "a", direction: Input, },
      { name: "y", net: "y", direction: Output, },
    ],
    gates: [
      {
        name: "invert",
        cell: "INV",
        connections: [{ pin: "A", net: "a", }, { pin: "Y", net: "y", }],
      },
    ],
    nets: ["clk", "a", "y"].map(name => { name, wire_cap_farads: 0.0, }),
  }
  let c = r08_constraints(lib, n)
  let c = {
    ..c,
    clock: { ..c.clock, period_seconds: 1.0e308, latency_seconds: -1.0e308, },
    input_delays: [{ port: "a", rise: Some(1.0e308), fall: Some(1.0e308), }],
    output_delays: [{ port: "y", rise: Some(0.0), fall: Some(0.0), }],
  }
  let r = run(n, c, lib~)
  assert_true(endpoint(r, "y", Rise).arrival_seconds == Some(1.0e308))
  assert_true(endpoint(r, "y", Rise).slack_seconds == Some(-1.0e308))
  let n = period_wire()
  let c = {
    ..c,
    output_delays: [{ port: "y", rise: Some(-1.0e308), fall: Some(-1.0e308), }],
  }
  let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
  assert_true(a.timing.worst_slack_seconds == Some(1.0e308))
  assert_true(a.budget.status == NoPositiveLimit)
}

///|
test "repair10 all tied output aliases are located and an unknown edge still prevents full budgeting" {
  let lib = r07_lib()
  let base = r07_net()
  let n = {
    ..base,
    ports: base.ports + [{ name: "z", net: "y", direction: Output, }],
  }
  let c = r07_constraints(lib, n)
  let c = {
    ..c,
    output_delays: c.output_delays +
    [{ port: "z", rise: Some(0.1e-9), fall: Some(0.1e-9), }],
  }
  let b = @sta.STAEngine::new(lib, n, c).run_period_analysis().budget
  assert_true(b.status == Complete && b.limiting_endpoints.length() == 2)
  assert_true(b.limiting_endpoints.all(e => e.edge == Fall))
  for pin in ["y", "z"] {
    near(period_bound(b, pin, Fall).unwrap(), 1.0e-9, tolerance=1.0e-24)
  }
  let c = {
    ..c,
    output_delays: c.output_delays.map(v => {
      if v.port == "z" {
        { ..v, fall: None, }
      } else {
        v
      }
    }),
  }
  let b = @sta.STAEngine::new(lib, n, c).run_period_analysis().budget
  assert_true(b.status == Partial && b.unconstrained_endpoint_edges == 1)
  assert_true(
    b.minimum_period_seconds is None && b.maximum_frequency_hz is None,
  )
}
