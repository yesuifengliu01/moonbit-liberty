///|
pub(all) enum CellAreaState {
  KnownArea
  MissingArea
  InvalidArea
  UnmappedCell
} derive(Eq, Debug, ToJson)

///|
pub(all) enum CellUsageStatus {
  UsageComplete
  UsageIncomplete
} derive(Eq, Debug)

///|
pub impl ToJson for CellUsageStatus with fn to_json(self : CellUsageStatus) -> Json {
  let text : String = match self {
    UsageComplete => "Complete"
    UsageIncomplete => "Incomplete"
  }
  ToJson::to_json(text)
}

///|
/// One declared instance, in input order. Names are raw, without pin escaping.
pub(all) struct InstanceUsage {
  index : Int
  instance : String
  cell : String
  area_state : CellAreaState
  declared_area : Double?
  raw_area : String?
  issue : String?
} derive(Debug, ToJson)

///|
/// One used cell, in first-use order. No missing area is replaced with zero.
pub(all) struct CellUsage {
  cell : String
  instance_count : Int
  area_state : CellAreaState
  declared_area : Double?
  raw_area : String?
  issue : String?
  area_overflow : Bool
  total_declared_area : Double?
} derive(Debug, ToJson)

///|
/// Flat mapped-instance census, independent of timing/SDC. Area stays in raw
/// Liberty declared units; Complete describes area coverage, not graph/signoff.
pub(all) struct CellUsageReport {
  status : CellUsageStatus
  unit : String
  library : String
  instance_count : Int
  mapped_instances : Int
  unmapped_instances : Int
  known_area_instances : Int
  missing_area_instances : Int
  invalid_area_instances : Int
  area_overflow : Bool
  known_area_subtotal : Double?
  total_declared_area : Double?
  cells : Array[CellUsage]
  instances : Array[InstanceUsage]
} derive(Debug, ToJson)

///|
fn cell_usage_definition(
  library : @liberty.Library,
  name : String,
) -> CellUsage {
  // Use the original Library.cell first-match binding, once per used name.
  let cell = library.cell(name)
  let raw = match cell {
    Some(value) => value.source.text("area")
    None => None
  }
  let (state, area, issue) = match cell {
    None => (UnmappedCell, None, Some("cell not found in library"))
    Some(value) => {
      let unsupported = value.source.complex("area") != None ||
        !value.source.groups("area").is_empty()
      match value.area {
        Some(area) if !unsupported && finite(area) && area >= 0.0 =>
          (KnownArea, Some(area), None)
        None if raw is None && !unsupported =>
          (MissingArea, None, Some("area is not declared"))
        _ =>
          (
            InvalidArea,
            None,
            Some("area must be a simple finite nonnegative scalar"),
          )
      }
    }
  }
  {
    cell: name,
    instance_count: 0,
    area_state: state,
    declared_area: area,
    raw_area: raw,
    issue,
    area_overflow: false,
    total_declared_area: None,
  }
}

///|
/// Count every flat gate, even disconnected/unused outputs. Only instance
/// identity is checked here; connections, pins and timing models are not checked.
/// Returned arrays are owned and do not borrow/mutate the library or netlist.
pub fn analyze_cell_usage(
  library : @liberty.Library,
  netlist : Netlist,
) -> CellUsageReport raise STAError {
  let names : Map[String, Bool] = Map([])
  let by_cell : Map[String, Int] = Map([])
  let cells : Array[CellUsage] = []
  let instances : Array[InstanceUsage] = []
  let mut known = 0
  let mut missing = 0
  let mut invalid = 0
  let mut unmapped = 0
  for index, gate in netlist.gates {
    if gate.name.is_empty() || names.contains(gate.name) {
      raise InvalidInput("duplicate/empty instance " + gate.name)
    }
    names[gate.name] = true
    let group = match by_cell.get(gate.cell) {
      Some(group) => group
      None => {
        let group = cells.length()
        by_cell[gate.cell] = group
        cells.push(cell_usage_definition(library, gate.cell))
        group
      }
    }
    let entry = cells[group]
    cells[group] = { ..entry, instance_count: entry.instance_count + 1, }
    match entry.area_state {
      KnownArea => known += 1
      MissingArea => missing += 1
      InvalidArea => invalid += 1
      UnmappedCell => unmapped += 1
    }
    instances.push({
      index,
      instance: gate.name,
      cell: gate.cell,
      area_state: entry.area_state,
      declared_area: entry.declared_area,
      raw_area: entry.raw_area,
      issue: entry.issue,
    })
  }
  let mut subtotal = Some(0.0)
  let mut overflow = false
  for index, entry in cells {
    match entry.declared_area {
      Some(area) => {
        let contribution = area * entry.instance_count.to_double()
        let group_overflow = !finite(contribution)
        cells[index] = {
          ..entry,
          area_overflow: group_overflow,
          total_declared_area: if group_overflow {
            None
          } else {
            Some(contribution)
          },
        }
        if group_overflow {
          overflow = true
          subtotal = None
        } else if subtotal is Some(sum) {
          let next = sum + contribution
          if finite(next) {
            subtotal = Some(next)
          } else {
            overflow = true
            subtotal = None
          }
        }
      }
      None => ()
    }
  }
  let complete = known == instances.length() && !overflow
  {
    status: if complete {
      UsageComplete
    } else {
      UsageIncomplete
    },
    unit: "liberty_declared_area",
    library: library.name,
    instance_count: instances.length(),
    mapped_instances: instances.length() - unmapped,
    unmapped_instances: unmapped,
    known_area_instances: known,
    missing_area_instances: missing,
    invalid_area_instances: invalid,
    area_overflow: overflow,
    known_area_subtotal: subtotal,
    total_declared_area: if complete {
      subtotal
    } else {
      None
    },
    cells,
    instances,
  }
}
