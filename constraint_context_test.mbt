///|
fn cc_netlist() -> @sta.Netlist {
  {
    ports: [
      { name: "clk", net: "ck", direction: Input, },
      { name: "a/~😀", net: "a", direction: Input, },
      { name: "out/~😀", net: "y", direction: Output, },
      { name: "alias/#", net: "a", direction: Output, },
    ],
    gates: [
      {
        name: "inv/~😀",
        cell: "INV",
        connections: [{ pin: "A", net: "a", }, { pin: "Y", net: "y", }],
      },
    ],
    nets: ["ck", "a", "y"].map(name => { name, wire_cap_farads: 0.0, }),
  }
}

///|
fn cc_sdc(complete? : Bool = false) -> String {
  "create_clock -name c -period 2 [get_ports clk]\n" +
  "set_clock_transition 0.1 [get_clocks c]\n" +
  "set_input_transition 0.1 [get_ports {a/~😀}]\n" +
  "set_input_delay " +
  (if complete { "" } else { "-rise " }) +
  "-clock c 0.6 [get_ports {a/~😀}]\n" +
  "set_output_delay -clock c 0.2 [get_ports {out/~😀}]\n" +
  "set_output_delay " +
  (if complete { "" } else { "-rise " }) +
  "-clock c 0.2 [get_ports {alias/#}]\n"
}

///|
test "constraint context traces missing Fall through inversion and a direct alias" {
  let library = @liberty.load_library(@testdata.constraint_context_library())
  let netlist = cc_netlist()
  let constraints = @sta.parse_sdc(cc_sdc(), library, netlist)
  let engine = @sta.STAEngine::new(library, netlist, constraints)
  let analysis = engine.run_setup_with_constraint_context()
  assert_eq(
    ToJson::to_json(analysis.timing),
    ToJson::to_json(engine.run_setup_analysis()),
  )
  assert_eq(analysis.timing.setup_summary().status, @sta.PartialCoverage)
  assert_eq(analysis.constraint_context.length(), 2)
  let inverted = analysis.constraint_context[0]
  assert_eq(inverted.pin, "out~1~0😀")
  assert_eq(inverted.edge, @sta.Rise)
  assert_true(inverted.missing_output_delay_port is None)
  let witness = inverted.launch_witness.unwrap()
  assert_eq(witness.kind, @sta.MissingInputDelay)
  assert_eq(witness.port, "a/~😀")
  assert_eq(witness.pin, "a~1~0😀")
  assert_eq(witness.edge, @sta.Fall)
  assert_eq(witness.path.map(s => s.pin), [
    "a~1~0😀", "inv~1~0😀/A", "inv~1~0😀/Y", "out~1~0😀",
  ])
  assert_eq(witness.path.map(s => s.edge), [
    @sta.Fall,
    @sta.Fall,
    @sta.Rise,
    @sta.Rise,
  ])
  assert_eq(witness.path.map(s => s.arc), ["source", "net", "A->Y", "net"])
  assert_true(witness.path[0].delay_seconds is None)
  near(witness.path[1].delay_seconds.unwrap(), 0.0, tolerance=0.0)
  near(witness.path[2].delay_seconds.unwrap(), 0.2e-9, tolerance=1.0e-22)
  near(witness.path[3].delay_seconds.unwrap(), 0.0, tolerance=0.0)
  let old_endpoint = endpoint(analysis.timing, "out~1~0😀", Rise)
  assert_true(
    old_endpoint.arrival_seconds is None && old_endpoint.path.is_empty(),
  )
  near(old_endpoint.required_seconds.unwrap(), 1.8e-9, tolerance=1.0e-22)
  let direct = analysis.constraint_context[1]
  assert_eq(direct.pin, "alias~1#")
  assert_eq(direct.edge, @sta.Fall)
  assert_eq(direct.missing_output_delay_port, Some("alias/#"))
  assert_eq(direct.launch_witness.unwrap().path.map(s => s.pin), [
    "a~1~0😀", "alias~1#",
  ])
}

///|
test "constraint context complete control retains independent SI timing and no gaps" {
  let library = @liberty.load_library(@testdata.constraint_context_library())
  let netlist = cc_netlist()
  let constraints = @sta.parse_sdc(cc_sdc(complete=true), library, netlist)
  let engine = @sta.STAEngine::new(library, netlist, constraints)
  let analysis = engine.run_setup_with_constraint_context()
  assert_eq(
    ToJson::to_json(analysis.timing),
    ToJson::to_json(engine.run_setup_analysis()),
  )
  assert_eq(analysis.constraint_context.length(), 0)
  assert_eq(analysis.timing.setup_summary().status, @sta.Met)
  for edge in [@sta.Rise, @sta.Fall] {
    let inverted = endpoint(analysis.timing, "out~1~0😀", edge)
    near(inverted.arrival_seconds.unwrap(), 0.8e-9, tolerance=1.0e-22)
    near(inverted.required_seconds.unwrap(), 1.8e-9, tolerance=1.0e-22)
    near(inverted.slack_seconds.unwrap(), 1.0e-9, tolerance=1.0e-22)
    let direct = endpoint(analysis.timing, "alias~1#", edge)
    near(direct.arrival_seconds.unwrap(), 0.6e-9, tolerance=1.0e-22)
    near(direct.slack_seconds.unwrap(), 1.2e-9, tolerance=1.0e-22)
  }
}

///|
test "constraint context output-delay omission does not invent a missing launch" {
  let library = @liberty.load_library(@testdata.constraint_context_library())
  let netlist = cc_netlist()
  let full = @sta.parse_sdc(cc_sdc(complete=true), library, netlist)
  let constraints = {
    ..full,
    output_delays: full.output_delays.map(value => {
      if value.port == "alias/#" {
        { ..value, fall: None, }
      } else {
        value
      }
    }),
  }
  let analysis = @sta.STAEngine::new(library, netlist, constraints).run_setup_with_constraint_context()
  assert_eq(analysis.constraint_context.length(), 1)
  let gap = analysis.constraint_context[0]
  assert_eq(gap.pin, "alias~1#")
  assert_eq(gap.edge, @sta.Fall)
  assert_eq(gap.missing_output_delay_port, Some("alias/#"))
  assert_true(gap.launch_witness is None)
  near(
    endpoint(analysis.timing, "alias~1#", Fall).arrival_seconds.unwrap(),
    0.6e-9,
    tolerance=1.0e-22,
  )
}

///|
test "constraint context retains known alternates and one actual first-arc witness" {
  let library = @liberty.load_library(@testdata.constraint_context_library())
  let netlist : @sta.Netlist = {
    ports: ["clk", "a", "b", "y"].map(name => {
      name,
      net: name,
      direction: if name == "y" {
        Output
      } else {
        Input
      },
    }),
    gates: [
      {
        name: "or",
        cell: "OR2",
        connections: ["A", "B", "Y"].mapi((i, pin) => {
          pin,
          net: ["a", "b", "y"][i],
        }),
      },
    ],
    nets: ["clk", "a", "b", "y"].map(name => { name, wire_cap_farads: 0.0, }),
  }
  let known = @sta.parse_sdc(
    "create_clock -name c -period 2 [get_ports clk]\n" +
    "set_input_transition 0.1 [get_ports *]\n" +
    "set_input_delay -rise -clock c 0.6 [get_ports a]\n" +
    "set_input_delay -clock c 0.6 [get_ports b]\n" +
    "set_output_delay -clock c 0.2 [get_ports y]\n",
    library,
    netlist,
  )
  let engine = @sta.STAEngine::new(library, netlist, known)
  let analysis = engine.run_setup_with_constraint_context()
  assert_eq(analysis.constraint_context.length(), 0)
  assert_eq(
    ToJson::to_json(analysis.timing),
    ToJson::to_json(engine.run_setup_analysis()),
  )
  near(
    endpoint(analysis.timing, "y", Fall).arrival_seconds.unwrap(),
    0.8e-9,
    tolerance=1.0e-22,
  )
  let both_missing = {
    ..known,
    input_delays: known.input_delays.map(value => { ..value, fall: None, }),
  }
  let gap = @sta.STAEngine::new(library, netlist, both_missing).run_setup_with_constraint_context()
  assert_eq(gap.constraint_context.length(), 1)
  assert_eq(gap.constraint_context[0].edge, @sta.Fall)
  let witness = gap.constraint_context[0].launch_witness.unwrap()
  assert_eq(witness.port, "a")
  assert_eq(witness.edge, @sta.Fall)
  assert_eq(witness.path.map(s => s.pin), ["a", "or/A", "or/Y", "y"])
}

///|
test "constraint context DFF clock launch cuts missing D provenance" {
  let library = @liberty.load_library(@testdata.library())
  let netlist = sequential()
  let full = @sta.parse_sdc(sdc(), library, netlist)
  let constraints = {
    ..full,
    input_delays: full.input_delays.map(value => { ..value, fall: None, }),
  }
  let engine = @sta.STAEngine::new(library, netlist, constraints)
  let analysis = engine.run_setup_with_constraint_context()
  assert_eq(
    ToJson::to_json(analysis.timing),
    ToJson::to_json(engine.run_setup_analysis()),
  )
  assert_eq(analysis.constraint_context.length(), 1)
  let gap = analysis.constraint_context[0]
  assert_eq(gap.pin, "launch/D")
  assert_eq(gap.edge, @sta.Fall)
  assert_true(gap.missing_output_delay_port is None)
  let witness = gap.launch_witness.unwrap()
  assert_eq(witness.port, "a")
  assert_eq(witness.kind, @sta.MissingInputDelay)
  assert_eq(witness.path.map(s => s.pin), ["a", "launch/D"])
  assert_true(
    endpoint(analysis.timing, "capture/D", Fall).arrival_seconds is Some(_),
  )
}

///|
test "constraint context clock-as-data is distinct from an unset input delay" {
  let library = @liberty.load_library(@testdata.constraint_context_library())
  let netlist : @sta.Netlist = {
    ports: [
      { name: "clk", net: "clk", direction: Input, },
      { name: "clock_data", net: "clk", direction: Output, },
    ],
    gates: [],
    nets: [{ name: "clk", wire_cap_farads: 0.0, }],
  }
  let constraints = @sta.parse_sdc(
    "create_clock -name c -period 2 [get_ports clk]\nset_output_delay -clock c 0.2 [get_ports clock_data]",
    library, netlist,
  )
  let analysis = @sta.STAEngine::new(library, netlist, constraints).run_setup_with_constraint_context()
  assert_eq(analysis.constraint_context.length(), 2)
  for gap in analysis.constraint_context {
    assert_true(gap.missing_output_delay_port is None)
    let witness = gap.launch_witness.unwrap()
    assert_eq(witness.kind, @sta.IdealClockNoDataArrival)
    assert_eq(witness.port, "clk")
    assert_eq(witness.edge, gap.edge)
    assert_eq(witness.path.map(s => s.pin), ["clk", "clock_data"])
  }
}

///|
test "constraint context retains typed analysis errors and a separate JSON boundary" {
  let library = @liberty.load_library(@testdata.constraint_context_library())
  let netlist = cc_netlist()
  let full = @sta.parse_sdc(cc_sdc(), library, netlist)
  let engine = @sta.STAEngine::new(library, netlist, {
    ..full,
    input_slews: [],
  })
  let expected = "InvalidInput(\"missing input transition for a/~😀\")"
  try engine.run_setup_analysis() catch {
    error => assert_eq("\{@debug.Debug::to_repr(error)}", expected)
  } noraise {
    _ => fail("expected old transition error")
  }
  try engine.run_setup_with_constraint_context() catch {
    error => assert_eq("\{@debug.Debug::to_repr(error)}", expected)
  } noraise {
    _ => fail("expected same typed transition error")
  }
  assert_eq(
    @json.parse(
      @sta.analyze_constraint_context_json(
        @testdata.constraint_context_library(),
        "{",
        "",
      ),
    ),
    {
      "ok": false,
      "schema": "moonbit.sta.constraint-context.v1",
      "error": "InvalidInput(\"invalid netlist JSON\")",
    },
  )
}
