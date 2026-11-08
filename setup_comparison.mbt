///|
pub(all) enum SetupChangeStatus {
  SetupDeltaRegressed
  SetupDeltaImproved
  SetupDeltaUnchanged
  SetupDeltaTolerated
  SetupDeltaBaselineOnly
  SetupDeltaCandidateOnly
  SetupDeltaBaselineUnknown
  SetupDeltaCandidateUnknown
  SetupDeltaBothUnknown
  SetupDeltaOverflow
} derive(Eq, Debug, ToJson)

///|
pub(all) enum SetupComparisonStatus {
  NoSetupRegression
  SetupRegressed
  SetupComparisonIncomplete
} derive(Eq, Debug, ToJson)

///|
/// Exact existing report pin/edge identity. Unknown/nonrepresentable values
/// are omitted rather than invented as zero. Delta is candidate minus baseline.
pub(all) struct SetupSlackChange {
  pin : String
  edge : Edge
  status : SetupChangeStatus
  baseline_slack_seconds : Double?
  candidate_slack_seconds : Double?
  slack_delta_seconds : Double?
} derive(Debug, ToJson)

///|
/// Relative setup-slack preservation only, not absolute setup compliance or
/// proof of matching model/constraints. Rows follow baseline then added order.
pub(all) struct SetupComparison {
  status : SetupComparisonStatus
  unit : String
  max_slack_loss_seconds : Double
  baseline_endpoint_edges : Int32
  candidate_endpoint_edges : Int32
  matched_endpoint_edges : Int32
  compared_endpoint_edges : Int32
  regressed_endpoint_edges : Int32
  incomplete_endpoint_edges : Int32
  rows : Array[SetupSlackChange]
} derive(Debug, ToJson)

///|
priv struct SetupSnapshot {
  pin : String
  edge : Edge
  slack : Double?
}

///|
fn setup_snapshot_index(
  values : Array[SetupSnapshot],
  side : String,
) -> Array[Map[String, Int32]] raise STAError {
  let maps : Array[Map[String, Int32]] = [Map([]), Map([])]
  for index, value in values {
    let names = maps[edge_index(value.edge)]
    if value.pin.is_empty() || names.contains(value.pin) {
      raise InvalidInput("duplicate/empty " + side + " endpoint " + value.pin)
    }
    if value.slack is Some(slack) && !finite(slack) {
      raise InvalidInput("invalid " + side + " slack_seconds")
    }
    names[value.pin] = index
  }
  maps
}

///|
fn setup_slack_change(
  baseline : SetupSnapshot?,
  candidate : SetupSnapshot?,
  limit : Double,
) -> SetupSlackChange {
  let identity = match baseline {
    Some(value) => value
    None => candidate.unwrap()
  }
  let before = match baseline {
    Some(value) => value.slack
    None => None
  }
  let after = match candidate {
    Some(value) => value.slack
    None => None
  }
  let (status, delta) = match (baseline, candidate) {
    (None, _) => (SetupDeltaCandidateOnly, None)
    (_, None) => (SetupDeltaBaselineOnly, None)
    (Some(_), Some(_)) =>
      match (before, after) {
        (None, None) => (SetupDeltaBothUnknown, None)
        (None, Some(_)) => (SetupDeltaBaselineUnknown, None)
        (Some(_), None) => (SetupDeltaCandidateUnknown, None)
        (Some(b), Some(c)) => {
          let delta = c - b
          if !finite(delta) {
            // Both inputs are finite, so an unrepresentable difference has a
            // definite sign. Its magnitude exceeds every finite loss limit.
            (if c < b { SetupDeltaRegressed } else { SetupDeltaImproved }, None)
          } else {
            let status = if delta < -limit {
              SetupDeltaRegressed
            } else if delta > 0.0 {
              SetupDeltaImproved
            } else if delta < 0.0 {
              SetupDeltaTolerated
            } else {
              SetupDeltaUnchanged
            }
            (status, Some(delta))
          }
        }
      }
  }
  {
    pin: identity.pin,
    edge: identity.edge,
    status,
    baseline_slack_seconds: before,
    candidate_slack_seconds: after,
    slack_delta_seconds: delta,
  }
}

///|
fn compare_setup_snapshots(
  baseline : Array[SetupSnapshot],
  candidate : Array[SetupSnapshot],
  max_slack_loss_seconds : Double,
) -> SetupComparison raise STAError {
  if !finite(max_slack_loss_seconds) || max_slack_loss_seconds < 0.0 {
    raise InvalidInput("max_slack_loss_seconds must be finite and nonnegative")
  }
  let before = setup_snapshot_index(baseline, "baseline")
  let after = setup_snapshot_index(candidate, "candidate")
  let rows = []
  let mut matched = 0
  for value in baseline {
    let partner = after[edge_index(value.edge)]
      .get(value.pin)
      .map(index => candidate[index])
    if partner is Some(_) {
      matched += 1
    }
    rows.push(setup_slack_change(Some(value), partner, max_slack_loss_seconds))
  }
  for value in candidate {
    if !before[edge_index(value.edge)].contains(value.pin) {
      rows.push(setup_slack_change(None, Some(value), max_slack_loss_seconds))
    }
  }
  let mut compared = 0
  let mut regressed = 0
  let mut incomplete = 0
  for row in rows {
    match row.status {
      SetupDeltaRegressed => {
        compared += 1
        regressed += 1
      }
      SetupDeltaImproved | SetupDeltaUnchanged | SetupDeltaTolerated =>
        compared += 1
      _ => incomplete += 1
    }
  }
  {
    status: if regressed > 0 {
      SetupRegressed
    } else if incomplete > 0 || compared == 0 {
      SetupComparisonIncomplete
    } else {
      NoSetupRegression
    },
    unit: "seconds",
    max_slack_loss_seconds,
    baseline_endpoint_edges: baseline.length(),
    candidate_endpoint_edges: candidate.length(),
    matched_endpoint_edges: matched,
    compared_endpoint_edges: compared,
    regressed_endpoint_edges: regressed,
    incomplete_endpoint_edges: incomplete,
    rows,
  }
}

///|
/// Compare existing endpoint slacks without rerunning either analysis. Exact
/// pin/edge identities must be nonempty/unique and known slacks finite. A loss
/// equal to the nonnegative SI threshold is allowed. Any unmatched/unknown or
/// overflowing row prevents a passing certificate; a known regression wins.
pub fn compare_setup_results(
  baseline : STAResult,
  candidate : STAResult,
  max_slack_loss_seconds~ : Double = 0.0,
) -> SetupComparison raise STAError {
  let before : Array[SetupSnapshot] = baseline.endpoints.map(endpoint => {
    pin: endpoint.pin,
    edge: endpoint.edge,
    slack: endpoint.slack_seconds,
  })
  let after : Array[SetupSnapshot] = candidate.endpoints.map(endpoint => {
    pin: endpoint.pin,
    edge: endpoint.edge,
    slack: endpoint.slack_seconds,
  })
  compare_setup_snapshots(before, after, max_slack_loss_seconds)
}

///|
pub extend SetupChangeStatus with Eq::{not_equal, equal}

///|
pub extend SetupChangeStatus with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SetupChangeStatus with ToJson::{to_json}

///|
pub extend SetupComparisonStatus with Eq::{not_equal, equal}

///|
pub extend SetupComparisonStatus with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SetupComparisonStatus with ToJson::{to_json}

///|
pub extend SetupSlackChange with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SetupSlackChange with ToJson::{to_json}

///|
pub extend SetupComparison with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SetupComparison with ToJson::{to_json}
