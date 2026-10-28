///|
// Self-authored scalar/1D NLDM fixture, also run through an independent OpenSTA process.
fn r07_lib(linear? : Bool = false) -> @liberty.Library raise {
  let text =
    #|library (dual_demo) {
    #|  delay_model : table_lookup;
    #|  time_unit : "1ns";
    #|  capacitive_load_unit (1.0, "pf");
    #|  voltage_unit : "1V";
    #|  current_unit : "1mA";
    #|  nom_process : 1;
    #|  nom_voltage : 1;
    #|  nom_temperature : 25;
    #|  input_threshold_pct_rise : 50;
    #|  input_threshold_pct_fall : 50;
    #|  output_threshold_pct_rise : 50;
    #|  output_threshold_pct_fall : 50;
    #|  slew_lower_threshold_pct_rise : 20;
    #|  slew_lower_threshold_pct_fall : 20;
    #|  slew_upper_threshold_pct_rise : 80;
    #|  slew_upper_threshold_pct_fall : 80;
    #|  slew_derate_from_library : 1;
    #|  lu_table_template (slew_axis) { variable_1 : input_net_transition; index_1 ("0, 1"); }
    #|  lu_table_template (load_axis) { variable_1 : total_output_net_capacitance; index_1 ("0, 0.1"); }
    #|  cell (DUAL) { area : 1;
    #|    pin (A) { direction : input; capacitance : 0.001; }
    #|    pin (B) { direction : input; capacitance : 0.002; }
    #|    pin (X) { direction : output; function : "A";
    #|      timing () { related_pin : "A"; timing_sense : positive_unate; timing_type : combinational;
    #|        cell_rise (slew_axis) { values ("0.20000000, 0.30000000"); }
    #|        cell_fall (slew_axis) { values ("0.30000000, 0.40000000"); }
    #|        rise_transition (load_axis) { values ("0.04000000, 0.14000000"); }
    #|        fall_transition (load_axis) { values ("0.05000000, 0.15000000"); }
    #|      }
    #|    }
    #|    pin (Y) { direction : output; function : "B";
    #|      timing () { related_pin : "B"; timing_sense : positive_unate; timing_type : combinational;
    #|        cell_rise (slew_axis) { values ("0.40000000, 0.50000000"); }
    #|        cell_fall (slew_axis) { values ("0.50000000, 0.60000000"); }
    #|        rise_transition (load_axis) { values ("0.06000000, 0.16000000"); }
    #|        fall_transition (load_axis) { values ("0.07000000, 0.17000000"); }
    #|      }
    #|    }
    #|  }
    #|  cell (INV) { area : 1;
    #|    pin (A) { direction : input; capacitance : 0.003; }
    #|    pin (Y) { direction : output; function : "!A";
    #|      timing () { related_pin : "A"; timing_sense : negative_unate; timing_type : combinational;
    #|        cell_rise (slew_axis) { values ("0.10000000, 0.20000000"); }
    #|        cell_fall (slew_axis) { values ("0.15000000, 0.25000000"); }
    #|        rise_transition (load_axis) { values ("0.02000000, 0.12000000"); }
    #|        fall_transition (load_axis) { values ("0.03000000, 0.13000000"); }
    #|      }
    #|    }
    #|  }
    #|}
  let lib = @liberty.load_library(text)
  if linear {
    return lib
  }
  {
    ..lib,
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
            values: [t.values[0]],
          }),
        }),
      }),
    }),
  }
}

///|
fn r07_net() -> @sta.Netlist {
  {
    ports: ["clk", "a", "y"].map(name => {
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
        name: "pair",
        cell: "DUAL",
        connections: [("A", "a"), ("B", "n"), ("X", "x"), ("Y", "y")].map(p => {
          pin: p.0,
          net: p.1,
        }),
      },
      {
        name: "invert",
        cell: "INV",
        connections: [("A", "x"), ("Y", "n")].map(p => { pin: p.0, net: p.1, }),
      },
    ],
    nets: ["clk", "a", "x", "n", "y"].map(name => {
      name,
      wire_cap_farads: 0.0,
    }),
  }
}

///|
fn r07_constraints(
  lib : @liberty.Library,
  n : @sta.Netlist,
) -> @sta.TimingConstraints raise {
  let text =
    #|create_clock -name clk -period 2 [get_ports clk]
    #|set_clock_transition 0.1 [get_clocks clk]
    #|set_input_delay -rise -clock clk 0.05 [get_ports a]
    #|set_input_delay -fall -clock clk 0.08 [get_ports a]
    #|set_input_transition 0.1 [get_ports a]
    #|set_output_delay -clock clk 0.1 [get_ports y]
    #|set_load 0.01 [get_ports y]
  @sta.parse_sdc(text, lib, n)
}

///|
test "repair07 acyclic pin dependencies inside a multioutput instance are not a loop" {
  let lib = r07_lib()
  let n = r07_net()
  let c = r07_constraints(lib, n)
  let r = run(n, c, lib~)
  near(
    endpoint(r, "y", Rise).arrival_seconds.unwrap(),
    0.88e-9,
    tolerance=1.0e-24,
  )
  near(
    endpoint(r, "y", Fall).arrival_seconds.unwrap(),
    0.9e-9,
    tolerance=1.0e-24,
  )
  assert_true(r.topological_order.join(">") == "pair>invert>pair")
  assert_true(
    endpoint(r, "y", Rise).path.map(s => s.pin).join(">") ==
    "a>pair/A>pair/X>invert/A>invert/Y>pair/B>pair/Y>y",
  )
  assert_true(endpoint(r, "y", Rise).path[0].edge == Fall)
  assert_true(r.nodes.length() == 18)
  for s in r.nodes {
    assert_true(
      r.nodes.filter(t => t.pin == s.pin && t.edge == s.edge).length() == 1,
    )
  }
}

///|
test "repair07 valid graph result is independent of pin and instance declaration order" {
  let lib = r07_lib()
  let reversed = {
    ..lib,
    cells: lib.cells.map(cell => {
      if cell.name == "DUAL" {
        {
          ..cell,
          pins: [
            cell.pin("Y").unwrap(),
            cell.pin("B").unwrap(),
            cell.pin("X").unwrap(),
            cell.pin("A").unwrap(),
          ],
        }
      } else {
        cell
      }
    }),
  }
  let n = r07_net()
  let c = r07_constraints(lib, n)
  let expected = run(n, c, lib~)
  r06_same(
    expected,
    run({ ..n, gates: [n.gates[1], n.gates[0]], }, c, lib=reversed),
  )
}

///|
test "repair07 1D slew and load coordinates agree with hand calculated path and SI loads" {
  let lib = r07_lib(linear=true)
  let n = r07_net()
  let c = r07_constraints(lib, n)
  let r = run(n, c, lib~)
  // d = base + 0.1 * input_slew(ns); slew(ns) = base + load(pF).
  // Rise: 0.08+0.31+0.1053+0.4022; Fall: 0.05+0.21+0.1543+0.5032.
  near(
    endpoint(r, "y", Rise).arrival_seconds.unwrap(),
    0.8975e-9,
    tolerance=1.0e-24,
  )
  near(
    endpoint(r, "y", Fall).arrival_seconds.unwrap(),
    0.9175e-9,
    tolerance=1.0e-24,
  )
  near(node(r, "pair/X", Rise).load_farads, 0.003e-12, tolerance=1.0e-29)
  near(node(r, "invert/Y", Fall).load_farads, 0.002e-12, tolerance=1.0e-29)
  near(node(r, "pair/Y", Rise).slew_seconds, 0.07e-9, tolerance=1.0e-24)
  near(node(r, "pair/Y", Fall).slew_seconds, 0.08e-9, tolerance=1.0e-24)
}

///|
test "repair07 a real output feedback loop still fails explicitly" {
  let lib = r07_lib()
  let n = r07_net()
  let c = r07_constraints(lib, n)
  let gates = n.gates.map(g => {
    if g.name == "pair" {
      {
        ..g,
        connections: g.connections.map(p => {
          if p.pin == "B" {
            { ..p, net: "y", }
          } else {
            p
          }
        }),
      }
    } else {
      g
    }
  })
  try run({ ..n, gates, }, c, lib~) catch {
    e =>
      assert_true(
        "\{@debug.Debug::to_repr(e)}".contains("CombinationalLoopDetected"),
      )
  } noraise {
    _ => fail("real pin cycle was accepted")
  }
}
