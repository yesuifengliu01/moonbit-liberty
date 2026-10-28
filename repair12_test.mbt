///|
fn r12_net(data : String) -> @sta.Netlist {
  {
    ports: [
      { name: "clk", net: "clk", direction: Input, },
      { name: "a", net: "a", direction: Input, },
      { name: data, net: data, direction: Input, },
      { name: "y", net: data, direction: Output, },
    ],
    gates: [],
    nets: ["clk", "a", data].map(name => { name, wire_cap_farads: 0.0, }),
  }
}

///|
fn r12_sdc(data : String, clock : String) -> String {
  "# full-line comment\n" +
  "create_clock -name \{clock} -period 2 [get_ports clk]\n" +
  "set_clock_transition 0.1 [get_clocks \{clock}]\n" +
  "set_input_transition 0.1 [get_ports *] # trailing profile comment\n" +
  "set_input_delay -clock \{clock} 0.9 [get_ports a]\n" +
  "set_input_delay -clock \{clock} 0.2 [get_ports {\{data}}]\n" +
  "set_output_delay -clock \{clock} 0.1 [get_ports y]\n"
}

///|
test "repair12 hash selector names do not bind a shorter input" {
  let lib = r07_lib()
  for data in ["a#b", "#data"] {
    let n = r12_net(data)
    let c = @sta.parse_sdc(r12_sdc(data, "clk"), lib, n)
    let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
    near(
      node(a.timing, "a", Rise).arrival_seconds.unwrap(),
      0.9e-9,
      tolerance=1.0e-24,
    )
    for edge in [@sta.Rise, @sta.Fall] {
      let e = endpoint(a.timing, "y", edge)
      near(e.arrival_seconds.unwrap(), 0.2e-9, tolerance=1.0e-24)
      near(e.slack_seconds.unwrap(), 1.7e-9, tolerance=1.0e-24)
    }
    assert_true(a.budget.status == Complete)
    near(a.budget.minimum_period_seconds.unwrap(), 0.3e-9, tolerance=1.0e-24)
  }
}

///|
test "repair12 hash clock names coexist with full and trailing profile comments" {
  let lib = r07_lib()
  let n = r12_net("data")
  for clock in ["core#clk", "clk"] {
    let c = @sta.parse_sdc(r12_sdc("data", clock), lib, n)
    assert_true(c.clock.name == clock)
    near(
      run(n, c, lib~).worst_slack_seconds.unwrap(),
      1.7e-9,
      tolerance=1.0e-24,
    )
  }
}

///|
test "repair12 unknown hash selector fails with its whole name" {
  let lib = r07_lib()
  let n = r12_net("data")
  let text = r12_sdc("data", "clk") +
    "set_input_delay -clock clk 0.3 [get_ports {a#missing}]\n"
  try @sta.parse_sdc(text, lib, n) catch {
    e =>
      assert_true(
        "\{@debug.Debug::to_repr(e)}".contains("unknown port a#missing"),
      )
  } noraise {
    _ => fail("unknown selector bound to a shorter name")
  }
}
