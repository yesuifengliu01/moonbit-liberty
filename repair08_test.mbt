///|
fn r08_net(input : String, output : String, gate : String) -> @sta.Netlist {
  {
    ports: [
      { name: "clk", net: "clk", direction: Input, },
      { name: input, net: "a", direction: Input, },
      { name: output, net: "y", direction: Output, },
    ],
    gates: [
      {
        name: gate,
        cell: "sky130_fd_sc_hd__inv_1",
        connections: [{ pin: "A", net: "a", }, { pin: "Y", net: "y", }],
      },
    ],
    nets: ["clk", "a", "y"].map(name => { name, wire_cap_farads: 0.0, }),
  }
}

///|
fn r08_constraints(
  lib : @liberty.Library,
  n : @sta.Netlist,
  clock? : String = "clk",
) -> @sta.TimingConstraints raise {
  let mut text = "create_clock -name clk -period 2 [get_ports \{clock}]\nset_clock_transition 0.1 [get_clocks clk]\n"
  for p in n.ports {
    if p.direction == Input && p.name != clock {
      text += "set_input_delay -rise -clock clk 0.05 [get_ports \{p.name}]\nset_input_delay -fall -clock clk 0.08 [get_ports \{p.name}]\nset_input_transition 0.1 [get_ports \{p.name}]\n"
    }
    if p.direction == Output {
      text += "set_output_delay -clock clk 0.1 [get_ports \{p.name}]\nset_load 0.01 [get_ports \{p.name}]\n"
    }
  }
  @sta.parse_sdc(text, lib, n)
}

///|
fn r08_unique(r : @sta.STAResult) -> Unit raise {
  for x in r.nodes {
    assert_true(
      r.nodes.filter(y => y.pin == x.pin && y.edge == x.edge).length() == 1,
      msg="ambiguous identity " + x.pin,
    )
  }
}

///|
test "repair08 port and qualified pin identities remain distinct with escape lookalikes" {
  let lib = @liberty.load_library(@testdata.library())
  let base = r08_net("u/Y", "y", "u")
  let n = {
    ..base,
    ports: base.ports + [{ name: "u~1Y", net: "b", direction: Input, }],
    nets: base.nets + [{ name: "b", wire_cap_farads: 0.0, }],
  }
  let r = run(n, r08_constraints(lib, n), lib~)
  r08_unique(r)
  near(
    node(r, "u~1Y", Rise).arrival_seconds.unwrap(),
    0.05e-9,
    tolerance=1.0e-24,
  )
  near(
    node(r, "u~01Y", Rise).arrival_seconds.unwrap(),
    0.05e-9,
    tolerance=1.0e-24,
  )
  assert_true(node(r, "u/Y", Rise).arrival_seconds.unwrap() > 0.05e-9)
  assert_true(endpoint(r, "y", Rise).path[0].pin == "u~1Y")
  assert_true(node(r, "u/Y", Rise).slew_contributor == "u/A")
}

///|
test "repair08 distinct instance and pin component splits cannot collapse" {
  let lib = @liberty.load_library(@testdata.library())
  let base = lib.cell("sky130_fd_sc_hd__inv_1").unwrap()
  let slash = {
    ..base,
    name: "slash_output",
    pins: base.pins.map(p => {
      if p.name == "Y" {
        { ..p, name: "x/Y", }
      } else {
        p
      }
    }),
  }
  let lib = { ..lib, cells: [base, slash], }
  let n : @sta.Netlist = {
    ports: [
      { name: "clk", net: "clk", direction: Input, },
      { name: "a", net: "a", direction: Input, },
      { name: "y", net: "y", direction: Output, },
      { name: "z", net: "z", direction: Output, },
    ],
    gates: [
      {
        name: "u",
        cell: "slash_output",
        connections: [{ pin: "A", net: "a", }, { pin: "x/Y", net: "y", }],
      },
      {
        name: "u/x",
        cell: base.name,
        connections: [{ pin: "A", net: "a", }, { pin: "Y", net: "z", }],
      },
    ],
    nets: ["clk", "a", "y", "z"].map(name => { name, wire_cap_farads: 0.0, }),
  }
  let r = run(n, r08_constraints(lib, n), lib~)
  r08_unique(r)
  near(
    node(r, "u/x~1Y", Rise).arrival_seconds.unwrap(),
    node(r, "u~1x/Y", Rise).arrival_seconds.unwrap(),
    tolerance=1.0e-24,
  )
  assert_true(node(r, "u/x~1Y", Rise).slew_contributor == "u/A")
  assert_true(node(r, "u~1x/Y", Rise).slew_contributor == "u~1x/A")
}

///|
test "repair08 Unicode supplementary and combining names survive component escaping exactly" {
  let lib = @liberty.load_library(@testdata.library())
  let base = r08_net("源😀/~x", "é/𝄞", "top/u")
  let n = {
    ..base,
    ports: base.ports + [{ name: "é/𝄞", net: "b", direction: Input, }],
    nets: base.nets + [{ name: "b", wire_cap_farads: 0.0, }],
  }
  let r = run(n, r08_constraints(lib, n), lib~)
  r08_unique(r)
  assert_true(node(r, "源😀~1~0x", Rise).pin == "源😀~1~0x")
  assert_true(node(r, "é~1𝄞", Fall).pin == "é~1𝄞")
  assert_true(endpoint(r, "é~1𝄞", Rise).path[0].pin == "源😀~1~0x")
  assert_true(node(r, "top~1u/Y", Rise).slew_contributor == "top~1u/A")
}

///|
test "repair08 DFF clock latency path setup endpoint and contributors use the same identities" {
  let lib = @liberty.load_library(@testdata.library())
  let base = sequential()
  let n = {
    ..base,
    ports: base.ports.map(p => {
      if p.name == "clk" {
        { ..p, name: "clock/😀", }
      } else {
        p
      }
    }),
    gates: base.gates.map(g => { ..g, name: "root/" + g.name + "~r", }),
  }
  let c = r08_constraints(lib, n, clock="clock/😀")
  let c = { ..c, clock: { ..c.clock, latency_seconds: 0.2e-9, }, }
  let r = run(n, c, lib~)
  r08_unique(r)
  let q = node(r, "root~1launch~0r/Q", Rise)
  assert_true(q.slew_contributor == "root~1launch~0r/CLK")
  assert_true(q.path[0].pin == "root~1launch~0r/CLK")
  near(q.path[0].delay_seconds, 0.2e-9, tolerance=1.0e-24)
  near(q.arrival_seconds.unwrap(), 0.517083388567e-9)
  assert_true(node(r, "clock~1😀", Rise).arrival_seconds is None)
  assert_true(endpoint(r, "root~1capture~0r/D", Rise).setup_seconds is Some(_))
}
