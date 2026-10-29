///|
/// One exact pin, with its worst known source edge and explicit unknown edges.
/// Source indices refer to the unchanged original STAResult.endpoints array.
pub(all) struct SetupEndpointPriority {
  pin : String
  first_source_index : Int
  endpoint_edges : Int
  known_edges : Int
  unknown_edges : Int
  worst_source_index : Int?
  worst_edge : Edge?
  worst_slack_seconds : Double?
} derive(Debug, ToJson)

///|
/// A bounded priority query, not a setup pass or an enumeration of timing paths.
/// All-unknown pins remain visible even when the known selection limit is zero.
pub(all) struct SetupEndpointPriorities {
  unit : String
  max_endpoints : Int
  endpoint_count : Int
  endpoint_edges : Int
  known_endpoint_edges : Int
  unknown_endpoint_edges : Int
  rankable_endpoints : Int
  unrankable_endpoints : Int
  selected_endpoints : Int
  omitted_rankable_endpoints : Int
  rows : Array[SetupEndpointPriority]
  unranked_endpoints : Array[SetupEndpointPriority]
} derive(Debug, ToJson)

///|
fn prioritize_setup_snapshots(
  values : Array[SetupSnapshot],
  max_endpoints : Int,
) -> SetupEndpointPriorities raise STAError {
  if max_endpoints < 0 {
    raise InvalidInput("max_endpoints must be nonnegative")
  }
  // Validate the full source, including rows outside the requested selection.
  let _ = setup_snapshot_index(values, "source")
  let groups : Array[SetupEndpointPriority] = []
  let by_pin : Map[String, Int] = Map([])
  let mut known = 0
  for index, value in values {
    let group_index = match by_pin.get(value.pin) {
      Some(found) => found
      None => {
        let found = groups.length()
        by_pin[value.pin] = found
        groups.push({
          pin: value.pin,
          first_source_index: index,
          endpoint_edges: 0,
          known_edges: 0,
          unknown_edges: 0,
          worst_source_index: None,
          worst_edge: None,
          worst_slack_seconds: None,
        })
        found
      }
    }
    let previous = groups[group_index]
    let is_known = value.slack is Some(_)
    if is_known {
      known += 1
    }
    let replace = match (value.slack, previous.worst_slack_seconds) {
      (Some(_), None) => true
      (Some(slack), Some(worst)) => slack < worst
      _ => false
    }
    groups[group_index] = {
      pin: previous.pin,
      first_source_index: previous.first_source_index,
      endpoint_edges: previous.endpoint_edges + 1,
      known_edges: previous.known_edges + (if is_known { 1 } else { 0 }),
      unknown_edges: previous.unknown_edges + (if is_known { 0 } else { 1 }),
      worst_source_index: if replace {
        Some(index)
      } else {
        previous.worst_source_index
      },
      worst_edge: if replace {
        Some(value.edge)
      } else {
        previous.worst_edge
      },
      worst_slack_seconds: if replace {
        value.slack
      } else {
        previous.worst_slack_seconds
      },
    }
  }
  let ranked = []
  let unranked = []
  for group in groups {
    if group.worst_slack_seconds is Some(_) {
      ranked.push(group)
    } else {
      unranked.push(group)
    }
  }
  ranked.sort_by((a, b) => {
    let before = a.worst_slack_seconds.unwrap()
    let after = b.worst_slack_seconds.unwrap()
    if before < after {
      -1
    } else if before > after {
      1
    } else {
      a.first_source_index - b.first_source_index
    }
  })
  let rows = []
  for index, value in ranked {
    if index < max_endpoints {
      rows.push(value)
    }
  }
  {
    unit: "s",
    max_endpoints,
    endpoint_count: groups.length(),
    endpoint_edges: values.length(),
    known_endpoint_edges: known,
    unknown_endpoint_edges: values.length() - known,
    rankable_endpoints: ranked.length(),
    unrankable_endpoints: unranked.length(),
    selected_endpoints: rows.length(),
    omitted_rankable_endpoints: ranked.length() - rows.length(),
    rows,
    unranked_endpoints: unranked,
  }
}

///|
/// Select distinct exact pins by their worst known slack; ties retain first
/// source pin/edge order. Unknown coverage remains explicit and is never zero.
/// This reads only endpoint pin/edge/slack; the caller retains original paths.
pub fn STAResult::prioritize_setup_endpoints(
  self : STAResult,
  max_endpoints? : Int = 10,
) -> SetupEndpointPriorities raise STAError {
  prioritize_setup_snapshots(
    self.endpoints.map(endpoint => {
      pin: endpoint.pin,
      edge: endpoint.edge,
      slack: endpoint.slack_seconds,
    }),
    max_endpoints,
  )
}
