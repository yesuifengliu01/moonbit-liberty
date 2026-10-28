///|
fn straight_net() -> @sta.Netlist {
  {
    ports: [
      { name: "clk", net: "clock_wire", direction: Input, },
      { name: "a", net: "data_wire", direction: Input, },
      { name: "y", net: "data_wire", direction: Output, },
    ],
    gates: [],
    nets: [
      { name: "clock_wire", wire_cap_farads: 0.0, },
      { name: "data_wire", wire_cap_farads: 0.0, },
    ],
  }
}

///|
test "deep repair finite inputs must not yield infinite arrival required or slack" {
  let lib = @liberty.load_library(@testdata.library())
  let n = straight_net()
  let base = @sta.parse_sdc(sdc(), lib, n)
  let cases = [
    {
      ..base,
      clock: { ..base.clock, latency_seconds: 1.0e308, },
      input_delays: [{ port: "a", rise: Some(1.0e308), fall: Some(1.0e308), }],
    },
    {
      ..base,
      clock: {
        ..base.clock,
        latency_seconds: 1.0e308,
        period_seconds: 1.0e308,
      },
      input_delays: [],
    },
    {
      ..base,
      clock: { ..base.clock, period_seconds: 1.0e308, },
      input_delays: [{ port: "a", rise: Some(-1.0e308), fall: Some(-1.0e308), }],
      output_delays: [{ port: "y", rise: Some(0.0), fall: Some(0.0), }],
    },
  ]
  let accepted = []
  for c in cases {
    try @sta.STAEngine::new(lib, n, c).run_setup_analysis() catch {
      e => assert_true("\{@debug.Debug::to_repr(e)}".contains("nonfinite"))
    } noraise {
      r => accepted.push("\{@debug.Debug::to_repr(r.endpoints[0])}")
    }
  }
  assert_true(
    accepted.is_empty(),
    msg="overflow accepted: \{@debug.Debug::to_repr(accepted)}",
  )
}

///|
test "deep repair large representable arithmetic remains supported" {
  let lib = @liberty.load_library(@testdata.library())
  let n = straight_net()
  let base = @sta.parse_sdc(sdc(), lib, n)
  let c = {
    ..base,
    clock: { ..base.clock, period_seconds: 1.0e301, latency_seconds: 1.0e300, },
    input_delays: [{ port: "a", rise: Some(1.0e300), fall: Some(1.0e300), }],
  }
  let r = @sta.STAEngine::new(lib, n, c).run_setup_analysis()
  let a = endpoint(r, "y", Rise).arrival_seconds.unwrap()
  assert_true(!a.is_inf() && !a.is_nan())
  assert_true((a / 1.0e300 - 2.0).abs() < 1.0e-14)
  assert_true(
    (endpoint(r, "y", Rise).slack_seconds.unwrap() / 1.0e300 - 9.0).abs() <
    1.0e-14,
  )
}

///|
test "deep repair DFF explanatory path includes nonzero ideal clock latency" {
  let lib = @liberty.load_library(@testdata.library())
  let n = sequential()
  let base = @sta.parse_sdc(sdc(), lib, n)
  let c = { ..base, clock: { ..base.clock, latency_seconds: 0.2e-9, }, }
  let r = @sta.STAEngine::new(lib, n, c).run_setup_analysis()
  for edge in [@sta.Rise, @sta.Fall] {
    let q = node(r, "launch/Q", edge)
    let mut explained = 0.0
    for step in q.path {
      explained += step.delay_seconds
    }
    near(explained, q.arrival_seconds.unwrap(), tolerance=1.0e-24)
    assert_true(q.path[0].pin == "launch/CLK")
    assert_true(q.path[0].edge == Rise)
    near(q.path[0].delay_seconds, 0.2e-9, tolerance=1.0e-25)
  }
}

///|
test "deep repair SDC accepts finite signed ideal latency consistently with structured API" {
  let lib = @liberty.load_library(@testdata.library())
  let n = sequential()
  let c = @sta.parse_sdc(
    sdc() + "\nset_clock_latency -0.2 [get_clocks clk]",
    lib,
    n,
  )
  near(c.clock.latency_seconds, -0.2e-9, tolerance=1.0e-25)
  let result = @sta.STAEngine::new(lib, n, c).run_setup_analysis()
  assert_true(result.worst_slack_seconds is Some(_))
}

///|
test "deep repair SDC rejects empty selectors and invalid clock ports at parse boundary" {
  let lib = @liberty.load_library(@testdata.library())
  let n = sequential()
  for
    text in [
      sdc() + "\nset_load 0.1 [get_ports {}]",
      "create_clock -name clk -period 2 [get_ports missing]",
      "create_clock -name clk -period 2 [get_ports y]",
      "create_clock -name {} -period 2 [get_ports clk]",
    ] {
    try @sta.parse_sdc(text, lib, n) catch {
      _ => ()
    } noraise {
      _ => fail("invalid SDC accepted: " + text)
    }
  }
}

///|
test "deep repair real negative setup and transposed variable order agree at known PDK knots" {
  let lib = @liberty.load_library(@testdata.library())
  let n = sequential()
  let c = @sta.parse_sdc(
    sdc() +
    "\nset_clock_transition 0.5 [get_clocks clk]\nset_input_transition 0.01 [get_ports a]\nset_clock_latency 0.15 [get_clocks clk]",
    lib,
    n,
  )
  let transposed = {
    ..lib,
    cells: lib.cells.map(cell => {
      ..cell,
      pins: cell.pins.map(pin => {
        ..pin,
        timings: pin.timings.map(arc => {
          ..arc,
          tables: arc.tables.map(table => {
            if table.variable_1 == Some("related_pin_transition") &&
              table.variable_2 == Some("constrained_pin_transition") {
              let rows = table.index_1.length()
              let columns = table.index_2.length()
              let values = Array::make(table.values.length(), 0.0)
              for i in 0..<rows {
                for j in 0..<columns {
                  values[j * rows + i] = table.values[i * columns + j]
                }
              }
              {
                ..table,
                variable_1: table.variable_2,
                variable_2: table.variable_1,
                index_1: table.index_2,
                index_2: table.index_1,
                values,
              }
            } else {
              table
            }
          }),
        }),
      }),
    }),
  }
  for library in [lib, transposed] {
    let r = @sta.STAEngine::new(library, n, c).run_setup_analysis()
    // Source PDK constraint knots, independently probed with OpenSTA as well.
    near(
      endpoint(r, "launch/D", Rise).setup_seconds.unwrap(),
      -0.0181335e-9,
      tolerance=1.0e-24,
    )
    near(
      endpoint(r, "launch/D", Fall).setup_seconds.unwrap(),
      -0.0108092e-9,
      tolerance=1.0e-24,
    )
    near(
      endpoint(r, "launch/D", Rise).required_seconds.unwrap(),
      2.1481335e-9,
      tolerance=1.0e-24,
    )
  }
}

///|
test "deep repair unconstraint follows the reversed edge without inventing slack" {
  let lib = @liberty.load_library(@testdata.library())
  let n : @sta.Netlist = {
    ports: [
      { name: "clk", net: "clk", direction: Input, },
      { name: "a", net: "a", direction: Input, },
      { name: "y", net: "y", direction: Output, },
    ],
    gates: [instance("invert", "inv", [("A", "a"), ("Y", "y")])],
    nets: ["clk", "a", "y"].map(name => { name, wire_cap_farads: 0.0, }),
  }
  let base = @sta.parse_sdc(sdc(), lib, n)
  let c = {
    ..base,
    input_delays: [{ port: "a", rise: None, fall: Some(0.05e-9), }],
  }
  let r = @sta.STAEngine::new(lib, n, c).run_setup_analysis()
  assert_true(endpoint(r, "y", Rise).slack_seconds is Some(_))
  assert_true(endpoint(r, "y", Fall).arrival_seconds is None)
  assert_true(endpoint(r, "y", Fall).slack_seconds is None)
  let c = {
    ..c,
    output_delays: [{ port: "y", rise: None, fall: Some(0.1e-9), }],
  }
  let r = @sta.STAEngine::new(lib, n, c).run_setup_analysis()
  assert_true(endpoint(r, "y", Rise).arrival_seconds is Some(_))
  assert_true(endpoint(r, "y", Rise).required_seconds is None)
  assert_true(endpoint(r, "y", Rise).slack_seconds is None)
}
