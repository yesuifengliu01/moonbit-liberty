///|
test "SDC rejects delay values that overflow after SI conversion" {
  let original = @liberty.load_library(@testdata.library())
  let library = {
    ..original,
    units: Some({ ..original.units.unwrap(), time_seconds: 1.0e100, }),
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
  for
    command in [
      "set_input_delay -clock clk -max 1e300 [get_ports a]", "set_output_delay -clock clk -max 1e300 [get_ports y]",
    ] {
    try
      @sta.parse_sdc(
        "create_clock -name clk -period 1 [get_ports clk]\n" + command,
        library,
        netlist,
      )
    catch {
      e => assert_true("\{@debug.Debug::to_repr(e)}".contains("nonfinite"))
    } noraise {
      _ => fail("overflowed SDC delay was accepted: " + command)
    }
  }
  let finite = @sta.parse_sdc(
    "create_clock -name clk -period 1 [get_ports clk]\n" +
    "set_input_delay -clock clk -max 1e200 [get_ports a]\n" +
    "set_output_delay -clock clk -max 1e200 [get_ports y]",
    library,
    netlist,
  )
  assert_true(
    finite.input_delays[0].rise.unwrap() > 0.0 &&
    !finite.input_delays[0].rise.unwrap().is_inf(),
  )
  assert_true(
    finite.output_delays[0].fall.unwrap() > 0.0 &&
    !finite.output_delays[0].fall.unwrap().is_inf(),
  )
}
