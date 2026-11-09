///|
// Yosys write_json uses integer bit IDs for connections. Keep those IDs as
// opaque net identities: netnames can contain several aliases for one bit.
fn yosys_pointer_token(name : String) -> String {
  let out = StringBuilder()
  for ch in name.to_array() {
    match ch {
      '~' => out.write_string("~0")
      '/' => out.write_string("~1")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn yosys_path(parent : String, key : String) -> String {
  parent + "/" + yosys_pointer_token(key)
}

///|
fn yosys_problem(path : String, message : String) -> String {
  "Yosys JSON pointer \"" + path + "\": " + message
}

///|
fn yosys_object(
  value : Json,
  path : String,
) -> Map[String, Json] raise STAError {
  match value {
    Object(fields) => fields
    _ => raise InvalidInput(yosys_problem(path, "object required"))
  }
}

///|
fn yosys_field(
  fields : Map[String, Json],
  key : String,
  parent : String,
) -> Json raise STAError {
  match fields.get(key) {
    Some(value) => value
    None =>
      raise InvalidInput(
        yosys_problem(yosys_path(parent, key), "missing field"),
      )
  }
}

///|
fn yosys_string(value : Json, path : String) -> String raise STAError {
  match value {
    String(text) => text
    _ => raise InvalidInput(yosys_problem(path, "string required"))
  }
}

///|
fn yosys_bit(value : Json, path : String) -> Int32 raise STAError {
  let bits = match value {
    Array(items) => items
    _ => raise InvalidInput(yosys_problem(path, "bit array required"))
  }
  if bits.length() != 1 {
    raise Unsupported(
      yosys_problem(path, "only one-bit ports and pins are supported"),
    )
  }
  match bits[0] {
    Number(number, ..) if finite(number) &&
      number >= 2.0 &&
      number < 2147483648.0 &&
      number.floor() == number => number.to_int()
    String(bit) if bit == "0" || bit == "1" || bit == "x" || bit == "z" =>
      raise Unsupported(
        yosys_problem(path + "/0", "constant bits are not supported"),
      )
    _ =>
      raise InvalidInput(
        yosys_problem(path + "/0", "positive integer bit ID required"),
      )
  }
}

///|
fn yosys_sorted_keys(fields : Map[String, Json]) -> Array[String] {
  let keys = fields.keys().to_array()
  keys.sort()
  keys
}

///|
fn yosys_net_name(bit : Int32) -> String {
  "yosys_bit_" + bit.to_string()
}

///|
fn yosys_record_bit(
  seen : Map[Int32, Bool],
  bit : Int32,
  path : String,
) -> Unit raise STAError {
  if !seen.contains(bit) && seen.length() >= 1000000 {
    raise Unsupported(yosys_problem(path, "net budget exceeded"))
  }
  seen[bit] = true
}

///|
// Yosys writes Boolean attributes as bit strings by default, or as numbers
// with write_json -compat-int. Only the exact value one declares blackbox.
fn yosys_blackbox_attribute(value : Json) -> Bool {
  match value {
    Number(number, ..) => number == 1.0
    String(bits) => {
      let chars = bits.to_array()
      if chars.is_empty() || chars[chars.length() - 1] != '1' {
        return false
      }
      for index, ch in chars {
        if index < chars.length() - 1 && ch != '0' {
          return false
        }
      }
      true
    }
    _ => false
  }
}

///|
fn yosys_is_blackbox(value : Json) -> Bool {
  match value {
    Object(fields) =>
      match fields.get("attributes") {
        Some(Object(attributes)) =>
          match attributes.get("blackbox") {
            Some(flag) => yosys_blackbox_attribute(flag)
            None => false
          }
        _ => false
      }
    _ => false
  }
}

///|
/// Import one flat, mapped, scalar module from Yosys `write_json` output.
/// A repeated integer bit ID always names the same zero-wire-capacitance net.
/// Top-level port and cell/pin names are preserved for Liberty and SDC binding.
/// The caller can run `check_netlist_references` before timing analysis.
pub fn netlist_from_yosys_json(
  value : Json,
  module_name : String,
) -> Netlist raise STAError {
  if module_name.is_empty() {
    raise InvalidInput(yosys_problem("/modules", "module name required"))
  }
  let root = yosys_object(value, "")
  let modules = yosys_object(yosys_field(root, "modules", ""), "/modules")
  let module_path = yosys_path("/modules", module_name)
  let selected = yosys_object(
    yosys_field(modules, module_name, "/modules"),
    module_path,
  )
  match selected.get("memories") {
    Some(memories) => {
      let entries = yosys_object(memories, module_path + "/memories")
      if !entries.is_empty() {
        raise Unsupported(
          yosys_problem(module_path + "/memories", "memories are not supported"),
        )
      }
    }
    None => ()
  }
  let seen_bits : Map[Int32, Bool] = Map([])
  let port_path = module_path + "/ports"
  let source_ports = yosys_object(
    yosys_field(selected, "ports", module_path),
    port_path,
  )
  if source_ports.length() > 1000000 {
    raise Unsupported(yosys_problem(port_path, "port budget exceeded"))
  }
  let ports : Array[Port] = []
  for name in yosys_sorted_keys(source_ports) {
    let path = yosys_path(port_path, name)
    if name.is_empty() {
      raise InvalidInput(yosys_problem(path, "empty port name"))
    }
    let detail = yosys_object(source_ports[name], path)
    let direction = match
      yosys_string(yosys_field(detail, "direction", path), path + "/direction") {
      "input" => Input
      "output" => Output
      "inout" =>
        raise Unsupported(
          yosys_problem(path + "/direction", "inout port is not supported"),
        )
      _ =>
        raise InvalidInput(
          yosys_problem(path + "/direction", "input or output required"),
        )
    }
    let bit = yosys_bit(yosys_field(detail, "bits", path), path + "/bits")
    yosys_record_bit(seen_bits, bit, path + "/bits/0")
    ports.push({ name, net: yosys_net_name(bit), direction, })
  }
  let cells_path = module_path + "/cells"
  let source_cells = yosys_object(
    yosys_field(selected, "cells", module_path),
    cells_path,
  )
  if source_cells.length() > 100000 {
    raise Unsupported(yosys_problem(cells_path, "cell budget exceeded"))
  }
  let gates : Array[GateInstance] = []
  let mut connection_count = 0
  for name in yosys_sorted_keys(source_cells) {
    let path = yosys_path(cells_path, name)
    if name.is_empty() {
      raise InvalidInput(yosys_problem(path, "empty cell instance name"))
    }
    let detail = yosys_object(source_cells[name], path)
    let cell = yosys_string(yosys_field(detail, "type", path), path + "/type")
    if cell.is_empty() {
      raise InvalidInput(yosys_problem(path + "/type", "empty cell type"))
    }
    if cell[0] == '$' {
      raise Unsupported(
        yosys_problem(path + "/type", "unmapped Yosys cell is not supported"),
      )
    }
    if modules.get(cell) is Some(candidate) && !yosys_is_blackbox(candidate) {
      raise Unsupported(
        yosys_problem(
          path + "/type",
          "hierarchical module is not a blackbox cell",
        ),
      )
    }
    match detail.get("parameters") {
      Some(parameters) => {
        let entries = yosys_object(parameters, path + "/parameters")
        if !entries.is_empty() {
          raise Unsupported(
            yosys_problem(
              path + "/parameters",
              "parameterized cells are not supported",
            ),
          )
        }
      }
      None => ()
    }
    let connections_path = path + "/connections"
    let source_connections = yosys_object(
      yosys_field(detail, "connections", path),
      connections_path,
    )
    if source_connections.length() > 1000000 - connection_count {
      raise Unsupported(
        yosys_problem(connections_path, "connection budget exceeded"),
      )
    }
    connection_count += source_connections.length()
    let directions = match detail.get("port_directions") {
      Some(value) => Some(yosys_object(value, path + "/port_directions"))
      None => None
    }
    let connections : Array[Connection] = []
    for pin in yosys_sorted_keys(source_connections) {
      let connection_path = yosys_path(connections_path, pin)
      if pin.is_empty() {
        raise InvalidInput(
          yosys_problem(connection_path, "empty cell pin name"),
        )
      }
      if directions is Some(known) {
        match known.get(pin) {
          Some(value) => {
            let direction_path = yosys_path(path + "/port_directions", pin)
            match yosys_string(value, direction_path) {
              "input" | "output" => ()
              "inout" =>
                raise Unsupported(
                  yosys_problem(direction_path, "inout pin is not supported"),
                )
              _ =>
                raise InvalidInput(
                  yosys_problem(direction_path, "input or output required"),
                )
            }
          }
          None => ()
        }
      }
      let bit = yosys_bit(source_connections[pin], connection_path)
      yosys_record_bit(seen_bits, bit, connection_path + "/0")
      connections.push({ pin, net: yosys_net_name(bit), })
    }
    gates.push({ name, cell, connections, })
  }
  let bit_ids = seen_bits.keys().to_array()
  bit_ids.sort()
  let nets : Array[Net] = []
  for bit in bit_ids {
    nets.push({ name: yosys_net_name(bit), wire_cap_farads: 0.0, })
  }
  { ports, gates, nets, }
}
