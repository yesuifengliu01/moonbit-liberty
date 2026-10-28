///|
fn r06_net(cell : String) -> @sta.Netlist {
  let two = cell != "inv"
  let names = ["clk", "a"] + (if two { ["b"] } else { [] }) + ["y"]
  {
    ports: names.map(name => {
      name,
      net: name,
      direction: if name == "y" {
        Output
      } else {
        Input
      },
    }),
    gates: [
      instance(
        "gate",
        cell,
        [("A", "a")] +
        (if two { [("B", "b")] } else { [] }) +
        [(if cell == "and2" || cell == "or2" { "X" } else { "Y" }, "y")],
      ),
    ],
    nets: names.map(name => { name, wire_cap_farads: 0.0, }),
  }
}

///|
fn r06_constraints(
  lib : @liberty.Library,
  n : @sta.Netlist,
) -> @sta.TimingConstraints raise {
  @sta.parse_sdc(
    sdc() +
    "\nset_input_delay -rise -clock clk 0.05 [get_ports a]\nset_input_delay -fall -clock clk 0.8 [get_ports a]\nset_input_transition -rise 0.01 [get_ports a]\nset_input_transition -fall 0.5 [get_ports a]" +
    (if n.ports.any(p => p.name == "b") {
      "\nset_input_delay -rise -clock clk 0.2 [get_ports b]\nset_input_delay -fall -clock clk 0.7 [get_ports b]\nset_input_transition -rise 0.02 [get_ports b]\nset_input_transition -fall 0.3 [get_ports b]"
    } else {
      ""
    }),
    lib,
    n,
  )
}

///|
fn r06_same(a : @sta.STAResult, b : @sta.STAResult) -> Unit raise {
  for x in a.nodes {
    let y = node(b, x.pin, x.edge)
    match (x.arrival_seconds, y.arrival_seconds) {
      (Some(a), Some(b)) => near(a, b, tolerance=1.0e-24)
      (None, None) => ()
      _ => fail("arrival constraint changed at " + x.pin)
    }
    near(x.slew_seconds, y.slew_seconds, tolerance=1.0e-24)
  }
  for x in a.endpoints {
    let y = endpoint(b, x.pin, x.edge)
    for
      (a, b) in [
        (x.required_seconds, y.required_seconds),
        (x.slack_seconds, y.slack_seconds),
        (x.setup_seconds, y.setup_seconds),
      ] {
      match (a, b) {
        (Some(a), Some(b)) => near(a, b, tolerance=1.0e-24)
        (None, None) => ()
        _ => fail("endpoint constraint changed at " + x.pin)
      }
    }
  }
}

///|
fn r06_split(lib : @liberty.Library, kind : String) -> @liberty.Library {
  {
    ..lib,
    cells: lib.cells.map(cell => {
      ..cell,
      pins: cell.pins.map(pin => {
        let timings = []
        for arc in pin.timings {
          if arc.timing_type == Some(kind) {
            for
              keep in [
                ["cell_rise", "rise_transition", "rise_constraint"],
                ["cell_fall", "fall_transition", "fall_constraint"],
              ] {
              timings.push({
                ..arc,
                tables: arc.tables.filter(t => keep.contains(t.kind)),
              })
            }
          } else {
            timings.push(arc)
          }
        }
        { ..pin, timings, }
      }),
    }),
  }
}

///|
test "repair06 missing timing sense preserves Boolean unateness with asymmetric edges" {
  let lib = @liberty.load_library(@testdata.library())
  let omitted = {
    ..lib,
    cells: lib.cells.map(cell => {
      ..cell,
      pins: cell.pins.map(pin => {
        ..pin,
        timings: pin.timings.map(arc => { ..arc, timing_sense: None, }),
      }),
    }),
  }
  for cell in ["inv", "and2", "or2", "nand2"] {
    let n = r06_net(cell)
    let c = r06_constraints(lib, n)
    r06_same(run(n, c, lib~), run(n, c, lib=omitted))
  }
}

///|
test "repair06 explicit nonunate and absent function keep conservative dual edges" {
  let lib = @liberty.load_library(@testdata.library())
  let nonunate = {
    ..lib,
    cells: lib.cells.map(cell => {
      ..cell,
      pins: cell.pins.map(pin => {
        ..pin,
        timings: pin.timings.map(arc => {
          ..arc,
          timing_sense: Some("non_unate"),
        }),
      }),
    }),
  }
  let unknown = {
    ..lib,
    cells: lib.cells.map(cell => {
      ..cell,
      pins: cell.pins.map(pin => {
        ..pin,
        function: None,
        timings: pin.timings.map(arc => { ..arc, timing_sense: None, }),
      }),
    }),
  }
  let n = r06_net("inv")
  let c = r06_constraints(lib, n)
  let result = run(n, c, lib=nonunate)
  r06_same(result, run(n, c, lib=unknown))
  for edge in [@sta.Rise, @sta.Fall] {
    assert_true(endpoint(result, "y", edge).arrival_seconds.unwrap() > 0.8e-9)
  }
}

///|
test "repair06 separate rise and fall DFF groups preserve physical tCQ and setup" {
  let lib = @liberty.load_library(@testdata.library())
  let n = sequential()
  let c = r06_constraints(lib, n)
  let expected = run(n, c, lib~)
  for kind in ["rising_edge", "setup_rising"] {
    let split = r06_split(lib, kind)
    r06_same(expected, run(n, c, lib=split))
  }
  r06_same(
    expected,
    run(n, c, lib=r06_split(r06_split(lib, "rising_edge"), "setup_rising")),
  )
}

///|
test "repair06 separate combinational groups preserve both transitions" {
  let lib = @liberty.load_library(@testdata.library())
  let n = r06_net("inv")
  let c = r06_constraints(lib, n)
  r06_same(run(n, c, lib~), run(n, c, lib=r06_split(lib, "combinational")))
}

///|
test "repair06 zero slew retains a real contributor" {
  let lib = @liberty.load_library(@testdata.library())
  let zero = {
    ..lib,
    cells: lib.cells.map(cell => {
      ..cell,
      pins: cell.pins.map(pin => {
        ..pin,
        timings: pin.timings.map(arc => {
          ..arc,
          tables: arc.tables.map(table => {
            if ["rise_transition", "fall_transition"].contains(table.kind) {
              { ..table, values: table.values.map(_ => 0.0), }
            } else {
              table
            }
          }),
        }),
      }),
    }),
  }
  let n = r06_net("inv")
  let c = r06_constraints(lib, n)
  let r = run(n, c, lib=zero)
  for edge in [@sta.Rise, @sta.Fall] {
    let output = node(r, "gate/Y", edge)
    near(output.slew_seconds, 0.0, tolerance=0.0)
    assert_true(output.slew_contributor == "gate/A")
  }
}

///|
test "repair06 partial table support still rejects broken propagation and setup models" {
  let lib = @liberty.load_library(@testdata.library())
  let n = sequential()
  let c = r06_constraints(lib, n)
  // Missing all models or one member of a delay/slew pair remains an error.
  for
    remove in [
      ["cell_rise"],
      ["rise_transition"],
      ["rise_constraint", "fall_constraint"],
      ["cell_rise", "cell_fall", "rise_transition", "fall_transition"],
    ] {
    let broken = {
      ..lib,
      cells: lib.cells.map(cell => {
        ..cell,
        pins: cell.pins.map(pin => {
          ..pin,
          timings: pin.timings.map(arc => {
            ..arc,
            tables: arc.tables.filter(t => !remove.contains(t.kind)),
          }),
        }),
      }),
    }
    try run(n, c, lib=broken) catch {
      _ => ()
    } noraise {
      _ => fail("broken model accepted")
    }
  }
}
