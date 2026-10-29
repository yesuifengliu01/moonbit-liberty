///|
pub(all) enum ReferenceIssueCode {
  RefEmptyNetName
  RefDuplicateNetName
  RefEmptyPortName
  RefDuplicatePortName
  RefEmptyInstanceName
  RefDuplicateInstanceName
  RefUnknownCell
  RefDuplicateConnectionPin
  RefUnknownPin
  RefMissingPin
  RefUnresolvedNet
} derive(Eq, Debug, ToJson)

///|
pub(all) enum ReferenceCheckStatus {
  ReferencesResolved
  ReferenceIssuesFound
} derive(Eq, Debug, ToJson)

///|
/// A semantic JSON Pointer plus raw offending/expected name. For a duplicate,
/// first_pointer identifies the first declaration; missing pin points at the
/// gate's connections array. This is not a source-character position.
pub(all) struct NetlistReferenceIssue {
  code : ReferenceIssueCode
  pointer : String
  name : String
  first_pointer : String?
} derive(Debug, ToJson)

///|
/// Only the named scalar-reference profile: no drivers, cycles, pin direction,
/// numeric ranges, hierarchy, sequential/timing readiness or graph signoff.
/// matched_pin_connections counts records matching a library pin, including
/// duplicates and connections whose net target is unresolved.
pub(all) struct NetlistReferenceReport {
  status : ReferenceCheckStatus
  scope : String
  library : String
  port_count : Int
  instance_count : Int
  net_count : Int
  connection_count : Int
  matched_instances : Int
  matched_pin_connections : Int
  issue_count : Int
  issues : Array[NetlistReferenceIssue]
} derive(Debug, ToJson)

///|
fn reference_issue(
  code : ReferenceIssueCode,
  pointer : String,
  name : String,
  first_pointer? : String? = None,
) -> NetlistReferenceIssue {
  { code, pointer, name, first_pointer, }
}

///|
fn reference_declaration(
  issues : Array[NetlistReferenceIssue],
  names : Map[String, String],
  name : String,
  pointer : String,
  empty_code : ReferenceIssueCode,
  duplicate_code : ReferenceIssueCode,
) -> Unit {
  if name.is_empty() {
    issues.push(reference_issue(empty_code, pointer, name))
  } else {
    match names.get(name) {
      Some(first) =>
        issues.push(
          reference_issue(
            duplicate_code,
            pointer,
            name,
            first_pointer=Some(first),
          ),
        )
      None => names[name] = pointer
    }
  }
}

///|
fn reference_net(
  issues : Array[NetlistReferenceIssue],
  nets : Map[String, String],
  name : String,
  pointer : String,
) -> Unit {
  if !nets.contains(name) {
    issues.push(reference_issue(RefUnresolvedNet, pointer, name))
  }
}

///|
/// Return all independent scalar name/reference findings without timing/SDC.
/// Uses original first-match Library.cell/Cell.pin resolution, checks every
/// directly modeled library pin, and returns an owned issue list. Unknown cells
/// suppress unknowable pin/missing-pin findings; other checks still proceed.
pub fn check_netlist_references(
  library : @liberty.Library,
  netlist : Netlist,
) -> NetlistReferenceReport {
  let issues = []
  let nets : Map[String, String] = Map([])
  for index, net in netlist.nets {
    reference_declaration(
      issues,
      nets,
      net.name,
      "/nets/" + index.to_string() + "/name",
      RefEmptyNetName,
      RefDuplicateNetName,
    )
  }
  // Ports and instances share the original graph's identity namespace.
  let names : Map[String, String] = Map([])
  for index, port in netlist.ports {
    let pointer = "/ports/" + index.to_string()
    reference_declaration(
      issues,
      names,
      port.name,
      pointer + "/name",
      RefEmptyPortName,
      RefDuplicatePortName,
    )
    reference_net(issues, nets, port.net, pointer + "/net")
  }
  let mut connection_count = 0
  let mut matched_instances = 0
  let mut matched_pin_connections = 0
  for index, gate in netlist.gates {
    let pointer = "/gates/" + index.to_string()
    reference_declaration(
      issues,
      names,
      gate.name,
      pointer + "/name",
      RefEmptyInstanceName,
      RefDuplicateInstanceName,
    )
    let cell = library.cell(gate.cell)
    match cell {
      Some(_) => matched_instances += 1
      None =>
        issues.push(
          reference_issue(RefUnknownCell, pointer + "/cell", gate.cell),
        )
    }
    let pins : Map[String, String] = Map([])
    for connection_index, connection in gate.connections {
      connection_count += 1
      let location = pointer + "/connections/" + connection_index.to_string()
      match pins.get(connection.pin) {
        Some(first) =>
          issues.push(
            reference_issue(
              RefDuplicateConnectionPin,
              location + "/pin",
              connection.pin,
              first_pointer=Some(first),
            ),
          )
        None => pins[connection.pin] = location + "/pin"
      }
      if cell is Some(cell) {
        if cell.pin(connection.pin) is Some(_) {
          matched_pin_connections += 1
        } else {
          issues.push(
            reference_issue(RefUnknownPin, location + "/pin", connection.pin),
          )
        }
      }
      reference_net(issues, nets, connection.net, location + "/net")
    }
    if cell is Some(cell) {
      for pin in cell.pins {
        if !pins.contains(pin.name) {
          issues.push(
            reference_issue(RefMissingPin, pointer + "/connections", pin.name),
          )
        }
      }
    }
  }
  {
    status: if issues.is_empty() {
      ReferencesResolved
    } else {
      ReferenceIssuesFound
    },
    scope: "scalar_names_and_references",
    library: library.name,
    port_count: netlist.ports.length(),
    instance_count: netlist.gates.length(),
    net_count: netlist.nets.length(),
    connection_count,
    matched_instances,
    matched_pin_connections,
    issue_count: issues.length(),
    issues,
  }
}
