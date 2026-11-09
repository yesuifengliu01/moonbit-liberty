///|
test "SDC does not silently turn nonzero constraints into zero after SI conversion" {
  let original = @liberty.load_library(@testdata.library())
  let library = {
    ..original,
    units: Some({
      ..original.units.unwrap(),
      time_seconds: 1.0e-100,
      capacitance_farads: 1.0e-100,
    }),
  }
  let netlist : @sta.Netlist = {
    ports: [
      { name: "clk", net: "clk", direction: Input, },
      { name: "a", net: "a", direction: Input, },
      { name: "y", net: "y", direction: Output, },
    ],
    gates: [],
    nets: ["clk", "a", "y"].map(name => { name, wire_cap_farads: 0.0, }),
  }
  let prefix = "create_clock -name clk -period 1 [get_ports clk]\n"
  for
    command in [
      "set_input_delay -clock clk 1e-300 [get_ports a]", "set_output_delay -clock clk -1e-300 [get_ports y]",
      "set_input_transition 1e-300 [get_ports a]", "set_load 1e-300 [get_ports y]",
      "set_clock_transition 1e-300 [get_clocks clk]", "set_clock_latency -1e-300 [get_clocks clk]",
      "set_clock_uncertainty 1e-300 [get_clocks clk]",
    ] {
    try @sta.parse_sdc(prefix + command, library, netlist) catch {
      error =>
        assert_true("\{@debug.Debug::to_repr(error)}".contains("underflow"))
    } noraise {
      _ => fail("underflowed SDC value was accepted: " + command)
    }
  }
  for token in ["1e-400", "-1e-400"] {
    try
      @sta.parse_sdc(
        prefix + "set_input_delay -clock clk " + token + " [get_ports a]",
        library,
        netlist,
      )
    catch {
      error =>
        assert_true("\{@debug.Debug::to_repr(error)}".contains("underflow"))
    } noraise {
      _ => fail("underflowed SDC literal was accepted: " + token)
    }
  }
  for token in ["0", "0e-400", "-0.0"] {
    let zero = @sta.parse_sdc(
      prefix + "set_input_delay -clock clk " + token + " [get_ports a]",
      library,
      netlist,
    )
    assert_eq(zero.input_delays[0].rise, Some(0.0))
  }
  let finite = @sta.parse_sdc(
    prefix +
    "set_input_delay -clock clk 1e-200 [get_ports a]\n" +
    "set_load 1e-200 [get_ports y]",
    library,
    netlist,
  )
  assert_true(finite.input_delays[0].rise.unwrap() > 0.0)
  assert_true(finite.output_loads[0].fall.unwrap() > 0.0)
}
