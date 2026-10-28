///|
fn r13_net(
  clock : String,
  data : String,
  other : String,
  output : String,
) -> @sta.Netlist {
  {
    ports: [
      { name: clock, net: clock, direction: Input, },
      { name: data, net: data, direction: Input, },
      { name: other, net: other, direction: Input, },
      { name: output, net: data, direction: Output, },
    ],
    gates: [],
    nets: [clock, data, other].map(name => { name, wire_cap_farads: 0.0, }),
  }
}

///|
fn r13_sdc(
  clock : String,
  target : String,
  other : String,
  output : String,
) -> String {
  "create_clock -name main -period 2 [get_ports {\{clock}}]\n" +
  "set_clock_transition 0.1 [get_clocks main]\n" +
  "set_input_transition 0.1 [get_ports *]\n" +
  "set_input_delay -clock main 0.9 [get_ports {\{other}}]\n" +
  "set_input_delay -clock main 0.2 [get_ports {\{target}}]\n" +
  "set_output_delay -clock main 0.1 [get_ports {\{output}}]\n"
}

///|
test "repair13 braced scalar bit names remain literal on input clock and output selectors" {
  let lib = r07_lib()
  // Braced names are data even when their literal bracket is unmatched.
  for data in ["a[0]", "a[0", "a]0"] {
    let n = r13_net("clk[0]", data, "a", "y[3]")
    let c = @sta.parse_sdc(r13_sdc("clk[0]", data, "a", "y[3]"), lib, n)
    assert_true(c.clock.port == "clk[0]")
    let a = @sta.STAEngine::new(lib, n, c).run_period_analysis()
    near(
      node(a.timing, "a", Rise).arrival_seconds.unwrap(),
      0.9e-9,
      tolerance=1.0e-24,
    )
    for edge in [@sta.Rise, @sta.Fall] {
      let e = endpoint(a.timing, "y[3]", edge)
      assert_true(e.path[0].pin == data)
      near(e.arrival_seconds.unwrap(), 0.2e-9, tolerance=1.0e-24)
      near(e.slack_seconds.unwrap(), 1.7e-9, tolerance=1.0e-24)
    }
    assert_true(a.budget.status == Complete)
    near(a.budget.minimum_period_seconds.unwrap(), 0.3e-9, tolerance=1.0e-24)
  }
}

///|
test "repair13 braced bit name lists bind both exact ports while nested commands still fail" {
  let lib = r07_lib()
  let n = r13_net("clk", "a[0]", "a[1]", "y")
  let text = r13_sdc("clk", "a[0] a[1]", "a[1]", "y")
  let c = @sta.parse_sdc(text, lib, n)
  let r = run(n, c, lib~)
  for port in ["a[0]", "a[1]"] {
    near(
      node(r, port, Rise).arrival_seconds.unwrap(),
      0.2e-9,
      tolerance=1.0e-24,
    )
  }
  let bad = text + "set_input_delay -clock main 0.3 [get_ports [bad]]\n"
  try @sta.parse_sdc(bad, lib, n) catch {
    e => assert_true("\{@debug.Debug::to_repr(e)}".contains("bad SDC grouping"))
  } noraise {
    _ => fail("nested command accepted")
  }
}
