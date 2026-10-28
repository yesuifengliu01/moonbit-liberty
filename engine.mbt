///|
priv struct SetupAnalysis {
  timing : STAResult
  relative_arrivals : Array[Double?]
}

///|
fn finite_option(value : Double) -> Double? {
  if finite(value) {
    Some(value)
  } else {
    None
  }
}

///|
fn clock_slack(clock : Clock, offset : Double, arrival : Double?) -> Double? {
  match arrival {
    Some(a) =>
      Some(
        sum_constraints(
          clock.period_seconds,
          -clock.uncertainty_seconds,
          -offset,
          -a,
        ),
      )
    None => None
  }
}

///|
fn later_arrival(
  absolute : Double,
  relative : Double?,
  best_absolute : Double,
  best_relative : Double?,
  latency : Double,
) -> Bool {
  match (relative, best_relative) {
    (Some(a), Some(b)) => a > b
    // With finite absolute times, an unrepresentable relative time has a known
    // sign. Keep legacy finite ranges even when subtracting latency overflows.
    (Some(_), None) => best_absolute < latency
    (None, Some(_)) => absolute > latency
    (None, None) => absolute > best_absolute
  }
}

///|
fn endpoint(
  pin : String,
  state : NodeTiming,
  required : Double?,
  setup : Double?,
  stable_slack : Double?,
) -> EndpointTiming raise STAError {
  if required is Some(r) {
    ignore(checked_finite(r, "required time at " + pin))
  }
  let slack = match (required, state.arrival_seconds) {
    (Some(r), Some(a)) =>
      match stable_slack {
        Some(value) => Some(checked_finite(value, "slack at " + pin))
        None => Some(checked_finite(r - a, "slack at " + pin))
      }
    _ => None
  }
  {
    pin,
    edge: state.edge,
    arrival_seconds: state.arrival_seconds,
    required_seconds: required,
    slack_seconds: slack,
    setup_seconds: setup,
    path: state.path,
  }
}

///|
fn sink_states(pin : String, states : Array[NodeTiming]) -> Array[NodeTiming] {
  states.map(s => {
    let path = s.path.copy()
    if s.arrival_seconds is Some(a) {
      path.push({
        pin,
        edge: s.edge,
        delay_seconds: 0.0,
        arrival_seconds: a,
        arc: "net",
      })
    }
    { ..s, pin, path, }
  })
}

///|
pub fn STAEngine::run_setup_analysis(
  self : STAEngine,
) -> STAResult raise STAError {
  self.analyze_setup().timing
}

///|
fn STAEngine::analyze_setup(self : STAEngine) -> SetupAnalysis raise STAError {
  let library = self.library
  let netlist = self.netlist
  let c = self.constraints
  let clock = c.clock
  nonnegative(clock.period_seconds, "clock period")
  if clock.period_seconds == 0.0 || clock.name.is_empty() {
    raise InvalidInput("positive clock period and name required")
  }
  nonnegative(clock.rise_slew_seconds, "clock rise slew")
  nonnegative(clock.fall_slew_seconds, "clock fall slew")
  nonnegative(clock.uncertainty_seconds, "clock uncertainty")
  if !finite(clock.latency_seconds) {
    raise InvalidInput("clock latency must be finite")
  }
  let units = validate_library(library)
  let graph = build_graph(library, netlist, c, units)
  let diagnostics : Array[String] = [
    "graph-based max-arrival/max-slew propagation; zero wire resistance and delay",
  ]
  let states : Map[String, Array[NodeTiming]] = Map([])
  let relative_states : Map[String, Array[Double?]] = Map([])
  let nodes = []
  let endpoints = []
  let endpoint_relative : Array[Double?] = []
  for p in netlist.ports {
    if p.direction != Input {
      continue
    }
    let pair = []
    let relative_pair = []
    for edge in [Rise, Fall] {
      let slew = if p.name == clock.port {
        if edge == Rise {
          clock.rise_slew_seconds
        } else {
          clock.fall_slew_seconds
        }
      } else {
        match port_value(c.input_slews, p.name, edge) {
          Some(v) => v
          None => raise InvalidInput("missing input transition for " + p.name)
        }
      }
      let arrival = if p.name == clock.port {
        None
      } else {
        port_value(c.input_delays, p.name, edge).map(x => {
          checked_finite(
            x + clock.latency_seconds,
            "input arrival at " + p.name,
          )
        })
      }
      let path = match arrival {
        Some(a) =>
          [
            {
              pin: report_part(p.name),
              edge,
              delay_seconds: a,
              arrival_seconds: a,
              arc: "input_delay",
            },
          ]
        None => []
      }
      let s : NodeTiming = {
        pin: report_part(p.name),
        edge,
        arrival_seconds: arrival,
        slew_seconds: slew,
        load_farads: graph.loads[p.net][edge_index(edge)],
        path,
        slew_contributor: report_part(p.name),
      }
      pair.push(s)
      relative_pair.push(
        if p.name == clock.port {
          None
        } else {
          port_value(c.input_delays, p.name, edge)
        },
      )
      nodes.push(s)
    }
    states[p.net] = pair
    relative_states[p.net] = relative_pair
  }
  // Register outputs launch from the ideal clock and cut sequential feedback.
  for i, r in graph.registers {
    guard r is Some(r) else { continue }
    let gate = netlist.gates[i]
    let cell = graph.cells[i]
    let output = cell.pin(r.output).unwrap()
    let net = graph.connections[i][r.output]
    let pair = []
    let relative_pair = []
    for edge in [Rise, Fall] {
      let mut delay : Double? = None
      let mut slew = 0.0
      for arc in output.timings {
        if !arc.related_pins.contains(r.clock) ||
          arc.timing_type != Some("rising_edge") {
          continue
        }
        if arc.condition != None {
          raise Unsupported("conditional clock-to-Q")
        }
        if !propagation_model_for_edge(arc, edge, cell.name) {
          continue
        }
        let delay_kind = if edge == Rise { "cell_rise" } else { "cell_fall" }
        let slew_kind = if edge == Rise {
          "rise_transition"
        } else {
          "fall_transition"
        }
        let load = graph.loads[net][edge_index(edge)]
        let d = table_value(
          find_table(arc, delay_kind, cell.name),
          clock.rise_slew_seconds,
          load,
          0.0,
          false,
          units,
          self.policy,
          diagnostics,
        )
        let s = table_value(
          find_table(arc, slew_kind, cell.name),
          clock.rise_slew_seconds,
          load,
          0.0,
          false,
          units,
          self.policy,
          diagnostics,
        )
        delay = Some(
          match delay {
            Some(v) => if d > v { d } else { v }
            None => d
          },
        )
        if s > slew {
          slew = s
        }
      }
      let delay = match delay {
        Some(v) => v
        None => raise MissingTimingArc(cell.name, r.clock, r.output)
      }
      let a = checked_finite(
        clock.latency_seconds + delay,
        "clock-to-Q arrival at " + gate.name + "/" + r.output,
      )
      let label = report_pin(gate.name, r.output)
      let path : Array[PathStep] = []
      if clock.latency_seconds != 0.0 {
        path.push({
          pin: report_pin(gate.name, r.clock),
          edge: Rise,
          delay_seconds: clock.latency_seconds,
          arrival_seconds: clock.latency_seconds,
          arc: "clock_latency",
        })
      }
      path.push({
        pin: label,
        edge,
        delay_seconds: delay,
        arrival_seconds: a,
        arc: r.clock + "->" + r.output,
      })
      let s : NodeTiming = {
        pin: label,
        edge,
        arrival_seconds: Some(a),
        slew_seconds: slew,
        load_farads: graph.loads[net][edge_index(edge)],
        path,
        slew_contributor: report_pin(gate.name, r.clock),
      }
      nodes.push(s)
      pair.push(s)
      relative_pair.push(Some(delay))
    }
    states[net] = pair
    relative_states[net] = relative_pair
  }
  let evaluation_order : Array[String] = []
  for (i, output_name) in graph.order {
    let gate = netlist.gates[i]
    let cell = graph.cells[i]
    if evaluation_order.is_empty() ||
      evaluation_order[evaluation_order.length() - 1] != gate.name {
      evaluation_order.push(gate.name)
    }
    let output = cell.pin(output_name).unwrap()
    let net = graph.connections[i][output.name]
    let senses = inferred_senses(output, diagnostics)
    let pair = []
    let relative_pair = []
    for edge in [Rise, Fall] {
      let mut best : Double? = None
      let mut best_relative : Double? = None
      let mut best_path = []
      let mut worst_slew = 0.0
      let mut slew_contributor = ""
      let mut found = false
      for arc in output.timings {
        if arc.timing_type != None &&
          !["combinational", "combinational_rise", "combinational_fall"].contains(
            arc.timing_type.unwrap(),
          ) {
          continue
        }
        if (arc.timing_type == Some("combinational_rise") && edge == Fall) ||
          (arc.timing_type == Some("combinational_fall") && edge == Rise) {
          continue
        }
        if !propagation_model_for_edge(arc, edge, cell.name) {
          continue
        }
        for related in arc.related_pins {
          let input_net = match graph.connections[i].get(related) {
            Some(n) => n
            None => raise MissingTimingArc(cell.name, related, output.name)
          }
          let input_states = sink_states(
            report_pin(gate.name, related),
            states[input_net],
          )
          for from_edge in [Rise, Fall] {
            if !arc_accepts(arc, from_edge, edge, senses.get(related)) {
              continue
            }
            let input = input_states[edge_index(from_edge)]
            let load = graph.loads[net][edge_index(edge)]
            let dk = if edge == Rise { "cell_rise" } else { "cell_fall" }
            let sk = if edge == Rise {
              "rise_transition"
            } else {
              "fall_transition"
            }
            let d = table_value(
              find_table(arc, dk, cell.name),
              input.slew_seconds,
              load,
              0.0,
              false,
              units,
              self.policy,
              diagnostics,
            )
            let s = table_value(
              find_table(arc, sk, cell.name),
              input.slew_seconds,
              load,
              0.0,
              false,
              units,
              self.policy,
              diagnostics,
            )
            // NLDM extrapolation can cross zero; retain the physical zero
            // floor and a real contributor even when every result is zero.
            let s = if s < 0.0 { 0.0 } else { s }
            if !found || s > worst_slew {
              worst_slew = s
              slew_contributor = input.pin
            }
            found = true
            if input.arrival_seconds is Some(a) {
              let a = checked_finite(
                a + d,
                "combinational arrival at " + gate.name + "/" + output.name,
              )
              let relative = match
                relative_states[input_net][edge_index(from_edge)] {
                Some(r) => finite_option(r + d)
                None => finite_option(a - clock.latency_seconds)
              }
              if best is None ||
                later_arrival(
                  a,
                  relative,
                  best.unwrap(),
                  best_relative,
                  clock.latency_seconds,
                ) {
                best = Some(a)
                best_relative = relative
                best_path = input.path.copy()
                best_path.push({
                  pin: report_pin(gate.name, output.name),
                  edge,
                  delay_seconds: d,
                  arrival_seconds: a,
                  arc: related + "->" + output.name,
                })
              }
            }
          }
        }
      }
      if !found {
        raise MissingTimingArc(cell.name, "*", output.name)
      }
      let s : NodeTiming = {
        pin: report_pin(gate.name, output.name),
        edge,
        arrival_seconds: best,
        slew_seconds: worst_slew,
        load_farads: graph.loads[net][edge_index(edge)],
        path: best_path,
        slew_contributor,
      }
      pair.push(s)
      relative_pair.push(best_relative)
      nodes.push(s)
    }
    states[net] = pair
    relative_states[net] = relative_pair
  }
  // An unrelated input of a multioutput cell can arrive after its first output
  // is evaluated. Report all input pins once, after the output DAG is complete.
  for i, cell in graph.cells {
    if graph.registers[i] is Some(_) {
      continue
    }
    let gate = netlist.gates[i]
    for input in cell.pins {
      if input.direction == Some("input") {
        let net = graph.connections[i][input.name]
        let ss = match states.get(net) {
          Some(s) => s
          None => raise UnresolvedNet(net)
        }
        nodes.append(sink_states(report_pin(gate.name, input.name), ss))
      }
    }
  }
  for i, r in graph.registers {
    guard r is Some(r) else { continue }
    let gate = netlist.gates[i]
    let cell = graph.cells[i]
    for input_name in [r.clock, r.data] {
      nodes.append(
        sink_states(
          report_pin(gate.name, input_name),
          states[graph.connections[i][input_name]],
        ),
      )
    }
    let pin = cell.pin(r.data).unwrap()
    let input = sink_states(
      report_pin(gate.name, r.data),
      states[graph.connections[i][r.data]],
    )
    for edge in [Rise, Fall] {
      let s = input[edge_index(edge)]
      let mut setup : Double? = None
      for arc in pin.timings {
        if arc.timing_type != Some("setup_rising") ||
          !arc.related_pins.contains(r.clock) {
          continue
        }
        if arc.condition != None {
          raise Unsupported("conditional setup check")
        }
        let kind = if edge == Rise {
          "rise_constraint"
        } else {
          "fall_constraint"
        }
        if !arc.tables.any(t => t.kind == kind) &&
          arc.tables.any(t => {
            ["rise_constraint", "fall_constraint"].contains(t.kind)
          }) {
          continue
        }
        let v = table_value(
          find_table(arc, kind, cell.name),
          s.slew_seconds,
          0.0,
          clock.rise_slew_seconds,
          true,
          units,
          self.policy,
          diagnostics,
        )
        if setup is None || v > setup.unwrap() {
          setup = Some(v)
        }
      }
      let setup = match setup {
        Some(v) => v
        None => raise MissingTimingArc(cell.name, r.clock, r.data + ":setup")
      }
      endpoints.push(
        endpoint(
          s.pin,
          s,
          Some(
            sum_constraints(
              clock.period_seconds,
              clock.latency_seconds,
              -clock.uncertainty_seconds,
              -setup,
            ),
          ),
          Some(setup),
          clock_slack(
            clock,
            setup,
            relative_states[graph.connections[i][r.data]][edge_index(edge)],
          ),
        ),
      )
      endpoint_relative.push(
        relative_states[graph.connections[i][r.data]][edge_index(edge)],
      )
    }
  }
  for p in netlist.ports {
    if p.direction != Output {
      continue
    }
    let ss = sink_states(report_part(p.name), states[p.net])
    for s in ss {
      nodes.push(s)
      let required = port_value(c.output_delays, p.name, s.edge).map(d => {
        sum_constraints(
          clock.period_seconds,
          clock.latency_seconds,
          -clock.uncertainty_seconds,
          -d,
        )
      })
      let stable_slack = match port_value(c.output_delays, p.name, s.edge) {
        Some(d) =>
          clock_slack(clock, d, relative_states[p.net][edge_index(s.edge)])
        None => None
      }
      let relative_arrival = relative_states[p.net][edge_index(s.edge)]
      endpoints.push(
        endpoint(report_part(p.name), s, required, None, stable_slack),
      )
      endpoint_relative.push(relative_arrival)
    }
  }
  let mut worst : Double? = None
  for e in endpoints {
    if e.slack_seconds is Some(s) {
      if worst is None || s < worst.unwrap() {
        worst = Some(s)
      }
    } else {
      diagnostics.push("unconstrained:" + e.pin)
    }
  }
  {
    timing: {
      nodes,
      endpoints,
      worst_slack_seconds: worst,
      diagnostics,
      topological_order: evaluation_order,
    },
    relative_arrivals: endpoint_relative,
  }
}
