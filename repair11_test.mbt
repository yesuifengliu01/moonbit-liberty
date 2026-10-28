///|
test "repair11 opposing output constraints preserve small required slack and period bounds" {
  let lib = r07_lib()
  let n = period_wire()
  let base = r08_constraints(lib, n)
  for
    (period, offset, required, slack, bound) in [
      (2.0e-9, -1.0e12, 2.0e-9, 1.0e-9, 1.0e-9),
      (
        2.0e-4, -999999999999.9999, 7.792968750000001e-5, 7.792868750000001e-5, 0.0001220713125,
      ),
    ] {
    let c = {
      ..base,
      clock: {
        ..base.clock,
        period_seconds: period,
        uncertainty_seconds: 1.0e12,
      },
      input_delays: [{ port: "a", rise: Some(1.0e-9), fall: Some(1.0e-9), }],
      output_delays: [{ port: "y", rise: Some(offset), fall: Some(offset), }],
    }
    let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
    assert_true(
      a.budget.status == Complete &&
      a.budget.minimum_period_seconds == Some(bound),
    )
    for edge in [@sta.Rise, @sta.Fall] {
      let e = endpoint(a.timing, "y", edge)
      assert_true(
        e.required_seconds == Some(required) && e.slack_seconds == Some(slack),
      )
      assert_true(period_bound(a.budget, "y", edge) == Some(bound))
    }
    for (period, sign) in [(bound - 1.0e-12, -1), (bound + 1.0e-12, 1)] {
      let target = { ..c, clock: { ..c.clock, period_seconds: period, }, }
      assert_true(
        run(n, target, lib~).worst_slack_seconds.unwrap() * sign.to_double() >
        0.0,
      )
    }
  }
}

///|
test "repair11 finite final required and budget survive intermediate overflow" {
  let lib = r07_lib()
  let n = period_wire()
  let base = r08_constraints(lib, n)
  for
    (latency, offset, data, slack, bound) in [
      (0.0, -1.0e308, 1.0e308, 0.0, 1.0e308),
      (1.0e308, 0.0, -1.0e308, 1.0e308, 0.0),
    ] {
    let c = {
      ..base,
      clock: {
        ..base.clock,
        period_seconds: 1.0e308,
        latency_seconds: latency,
        uncertainty_seconds: 1.0e308,
      },
      input_delays: [{ port: "a", rise: Some(data), fall: Some(data), }],
      output_delays: [{ port: "y", rise: Some(offset), fall: Some(offset), }],
    }
    let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
    for edge in [@sta.Rise, @sta.Fall] {
      let e = endpoint(a.timing, "y", edge)
      assert_true(
        e.required_seconds == Some(1.0e308) && e.slack_seconds == Some(slack),
      )
      assert_true(period_bound(a.budget, "y", edge) == Some(bound))
    }
    assert_true(a.budget.minimum_period_seconds == Some(bound))
    assert_true(
      a.budget.status == (if bound > 0.0 { Complete } else { NoPositiveLimit }),
    )
  }
}

///|
test "repair11 negative DFF setup cancels uncertainty without dropping the data path" {
  let lib = @liberty.load_library(@testdata.library())
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
            ..t,
            template_name: "scalar",
            variable_1: None,
            variable_2: None,
            index_1: [],
            index_2: [],
            values: [
              if t.kind == "rise_constraint" || t.kind == "fall_constraint" {
                -1.0e12
              } else {
                0.2e-9
              },
            ],
          }),
        }),
      }),
    }),
  }
  let wire = period_wire()
  let n : @sta.Netlist = {
    ports: wire.ports.map(p => {
      if p.name == "y" {
        { ..p, net: "y", }
      } else {
        p
      }
    }),
    gates: [
      instance("capture", "dfxtp", [("CLK", "clk"), ("D", "a"), ("Q", "y")]),
    ],
    nets: wire.nets + [{ name: "y", wire_cap_farads: 0.0, }],
  }
  let base = r08_constraints(lib, n)
  let c = {
    ..base,
    clock: {
      ..base.clock,
      period_seconds: 2.0e-9,
      uncertainty_seconds: 1.0e12,
    },
    input_delays: [{ port: "a", rise: Some(1.0e-9), fall: Some(1.0e-9), }],
    output_delays: [{ port: "y", rise: Some(-1.0e12), fall: Some(-1.0e12), }],
  }
  let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
  for edge in [@sta.Rise, @sta.Fall] {
    let e = endpoint(a.timing, "capture/D", edge)
    assert_true(
      e.setup_seconds == Some(-1.0e12) && e.required_seconds == Some(2.0e-9),
    )
    assert_true(e.slack_seconds == Some(1.0e-9))
    assert_true(period_bound(a.budget, "capture/D", edge) == Some(1.0e-9))
  }
  assert_true(
    a.budget.status == Complete &&
    a.budget.minimum_period_seconds == Some(1.0e-9),
  )
}

///|
test "repair11 finite period bound recovers even when the relative arrival is out of range" {
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
  let wire = period_wire()
  let n : @sta.Netlist = {
    ports: wire.ports.map(p => {
      if p.name == "y" {
        { ..p, net: "y", }
      } else {
        p
      }
    }),
    gates: [
      {
        name: "invert",
        cell: "INV",
        connections: [{ pin: "A", net: "a", }, { pin: "Y", net: "y", }],
      },
    ],
    nets: wire.nets + [{ name: "y", wire_cap_farads: 0.0, }],
  }
  let base = r08_constraints(lib, n)
  let c = {
    ..base,
    clock: { ..base.clock, period_seconds: 1.0e308, latency_seconds: -1.0e308, },
    input_delays: [{ port: "a", rise: Some(1.0e308), fall: Some(1.0e308), }],
    output_delays: [{ port: "y", rise: Some(-1.0e308), fall: Some(-1.0e308), }],
  }
  let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
  assert_true(a.timing.worst_slack_seconds == Some(0.0))
  assert_true(
    a.budget.status == Complete &&
    a.budget.minimum_period_seconds == Some(1.0e308),
  )
}
