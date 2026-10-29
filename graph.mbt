///|
priv struct Graph {
  cells : Array[@liberty.Cell]
  registers : Array[Register?]
  connections : Array[Map[String, String]]
  loads : Map[String, Array[Double]]
  order : Array[(Int, String)]
}

///|
fn input_cap(
  pin : @liberty.Pin,
  edge : Edge,
  library : @liberty.Library,
) -> Double raise STAError {
  let key = if edge == Rise { "rise_capacitance" } else { "fall_capacitance" }
  let text = prefer(
    pin.source.text(key),
    prefer(
      pin.source.text("capacitance"),
      library.source.text("default_input_pin_cap"),
    ),
  )
  let value = match text {
    Some(s) =>
      @liberty.finite_number(s) catch {
        _ => raise InvalidInput("bad capacitance " + pin.name)
      }
    None => raise InvalidInput("missing capacitance " + pin.name)
  }
  nonnegative(value, "pin capacitance")
  value
}

///|
fn build_graph(
  library : @liberty.Library,
  netlist : Netlist,
  c : TimingConstraints,
  units : @liberty.Units,
) -> Graph raise STAError {
  if netlist.gates.length() > 100000 || netlist.nets.length() > 1000000 {
    raise InvalidInput("netlist budget exceeded")
  }
  let loads : Map[String, Array[Double]] = Map([])
  for n in netlist.nets {
    nonnegative(n.wire_cap_farads, "wire capacitance")
    if n.name.is_empty() || loads.contains(n.name) {
      raise InvalidInput("duplicate/empty net " + n.name)
    }
    loads[n.name] = [n.wire_cap_farads, n.wire_cap_farads]
  }
  let drivers : Map[String, (Int, String)] = Map([])
  fn drive(net : String, driver : (Int, String)) -> Unit raise STAError {
    if !loads.contains(net) {
      raise UnresolvedNet(net)
    }
    if drivers.contains(net) {
      raise MultipleDrivers(net)
    }
    drivers[net] = driver
  }
  let names : Map[String, Bool] = Map([])
  let ports : Map[String, Direction] = Map([])
  for p in netlist.ports {
    if p.name.is_empty() || names.contains(p.name) {
      raise InvalidInput("duplicate/empty port " + p.name)
    }
    if !loads.contains(p.net) {
      raise UnresolvedNet(p.net)
    }
    names[p.name] = true
    ports[p.name] = p.direction
    if p.direction == Input {
      drive(p.net, (-1, p.name))
    }
    if p.direction == Output {
      for edge in [Rise, Fall] {
        let value = port_value(c.output_loads, p.name, edge).unwrap_or(0.0)
        nonnegative(value, "output load")
        loads[p.net][edge_index(edge)] += value
      }
    }
  }
  if ports.get(c.clock.port) != Some(Input) {
    raise InvalidInput("clock must name one input port")
  }
  for
    (values, direction, label) in [
      (c.input_delays, Input, "input delay"),
      (c.output_delays, Output, "output delay"),
      (c.input_slews, Input, "input slew"),
      (c.output_loads, Output, "output load"),
    ] {
    let seen : Map[String, Bool] = Map([])
    for v in values {
      if seen.contains(v.port) ||
        ports.get(v.port) != Some(direction) ||
        v.port == c.clock.port {
        raise InvalidInput("invalid or duplicate " + label + " port " + v.port)
      }
      seen[v.port] = true
      for x in [v.rise, v.fall] {
        if x is Some(x) {
          if !finite(x) {
            raise InvalidInput("nonfinite " + label)
          }
          if label == "input slew" || label == "output load" {
            nonnegative(x, label)
          }
        }
      }
    }
  }
  let cells = []
  let registers = []
  let connections = []
  for index, gate in netlist.gates {
    if gate.name.is_empty() || names.contains(gate.name) {
      raise InvalidInput("duplicate/empty instance " + gate.name)
    }
    names[gate.name] = true
    let cell = match library.cell(gate.cell) {
      Some(v) => v
      None => raise InvalidInput("unknown cell " + gate.cell)
    }
    let reg = register(cell)
    let conn : Map[String, String] = Map([])
    for v in gate.connections {
      if conn.contains(v.pin) || cell.pin(v.pin) is None {
        raise InvalidInput("invalid pin " + gate.name + "/" + v.pin)
      }
      if !loads.contains(v.net) {
        raise UnresolvedNet(v.net)
      }
      conn[v.pin] = v.net
    }
    for pin in cell.pins {
      let net = match conn.get(pin.name) {
        Some(n) => n
        None =>
          raise InvalidInput("unconnected pin " + gate.name + "/" + pin.name)
      }
      match pin.direction {
        Some("input") =>
          for edge in [Rise, Fall] {
            loads[net][edge_index(edge)] += input_cap(pin, edge, library) *
              units.capacitance_farads
          }
        Some("output") => drive(net, (index, pin.name))
        _ =>
          raise Unsupported(
            "only scalar input/output pins supported: " +
            gate.cell +
            "/" +
            pin.name,
          )
      }
    }
    if reg is Some(reg) {
      let clock_port = netlist.ports
        .iter()
        .find_first(p => p.name == c.clock.port)
        .unwrap()
      if conn[reg.clock] != clock_port.net {
        raise Unsupported(
          "all registers must use the single ideal clock directly",
        )
      }
      if cell.pins.length() != 3 {
        raise Unsupported("only simple D/CLK/Q ff supported")
      }
    }
    cells.push(cell)
    registers.push(reg)
    connections.push(conn)
  }
  for n in netlist.nets {
    if !drivers.contains(n.name) {
      raise UnresolvedNet("no driver for " + n.name)
    }
    for value in loads[n.name] {
      nonnegative(value, "total load")
    }
  }
  // Vertices are driven output pins. Collapsing a multioutput cell into one
  // vertex can create a false cycle between otherwise independent channels.
  let tasks : Array[(Int, String)] = []
  let task_by_net : Map[String, Int] = Map([])
  for i, cell in cells {
    if registers[i] is Some(_) {
      continue
    }
    for pin in cell.pins {
      if pin.direction == Some("output") {
        task_by_net[connections[i][pin.name]] = tasks.length()
        tasks.push((i, pin.name))
      }
    }
  }
  let indegree = Array::make(tasks.length(), 0)
  let next : Array[Array[Int]] = Array::makei(tasks.length(), _ => [])
  for task, (i, output_name) in tasks {
    let cell = cells[i]
    let output = cell.pin(output_name).unwrap()
    let deps : Map[Int, Bool] = Map([])
    for arc in output.timings {
      if arc.timing_type != None &&
        !["combinational", "combinational_rise", "combinational_fall"].contains(
          arc.timing_type.unwrap(),
        ) {
        continue
      }
      for related in arc.related_pins {
        guard cell.pin(related) is Some(pin) && pin.direction == Some("input") else {
          raise InvalidInput(
            "timing related pin must be an input: " + cell.name + "/" + related,
          )
        }
        let net = connections[i][related]
        if task_by_net.get(net) is Some(j) && !deps.contains(j) {
          deps[j] = true
          indegree[task] += 1
          next[j].push(task)
        }
      }
    }
  }
  let queue = []
  for i in 0..<indegree.length() {
    if indegree[i] == 0 {
      queue.push(i)
    }
  }
  let mut at = 0
  while at < queue.length() {
    let i = queue[at]
    at += 1
    for j in next[i] {
      indegree[j] -= 1
      if indegree[j] == 0 {
        queue.push(j)
      }
    }
  }
  if queue.length() != tasks.length() {
    let members = graph_cyclic_members(next, indegree.map(value => value > 0))
    let cyclic = []
    let cyclic_seen : Map[String, Bool] = Map([])
    for i in 0..<tasks.length() {
      if members[i] {
        let name = netlist.gates[tasks[i].0].name
        if !cyclic_seen.contains(name) {
          cyclic_seen[name] = true
          cyclic.push(name)
        }
      }
    }
    // The original incomplete-order condition still always rejects the graph.
    raise CombinationalLoopDetected(cyclic)
  }
  { cells, registers, connections, loads, order: queue.map(i => tasks[i]), }
}
