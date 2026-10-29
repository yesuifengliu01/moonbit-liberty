///|
/// Consume only the endpoint identity/slack view of the original success
/// report. Unused original result fields/extensions are intentionally ignored.
fn setup_report_snapshots(
  text : String,
  side : String,
) -> Array[SetupSnapshot] raise STAError {
  let value = @json.parse(text) catch {
    _ => raise InvalidInput("invalid " + side + " report JSON")
  }
  guard value
    is {
      "ok": True,
      "schema": String("moonbit.sta.v1"),
      "result": Object(result),
      ..
    } else {
    raise InvalidInput("invalid " + side + " report schema")
  }
  let endpoints = match result.get("endpoints") {
    Some(Array(values)) => values
    _ => raise InvalidInput("invalid " + side + " endpoints")
  }
  endpoints.map(value => {
    guard value is Object(fields) else {
      raise InvalidInput("invalid " + side + " endpoint")
    }
    let pin = match fields.get("pin") {
      Some(String(value)) => value
      _ => raise InvalidInput("invalid " + side + " endpoint pin")
    }
    let edge = match fields.get("edge") {
      Some(String("Rise")) => Rise
      Some(String("Fall")) => Fall
      _ => raise InvalidInput("invalid " + side + " endpoint edge")
    }
    let slack = match fields.get("slack_seconds") {
      None | Some(Null) => None
      Some(Number(value, ..)) if finite(value) => Some(value)
      _ => raise InvalidInput("invalid " + side + " slack_seconds")
    }
    { pin, edge, slack, }
  })
}

///|
/// Original successful moonbit.sta.v1 reports and an explicit SI loss budget.
pub fn compare_setup_json(
  baseline_text : String,
  candidate_text : String,
  max_slack_loss_seconds : Double,
) -> String {
  let result : Json = try {
    let baseline = setup_report_snapshots(baseline_text, "baseline")
    let candidate = setup_report_snapshots(candidate_text, "candidate")
    {
      "ok": true,
      "schema": "moonbit.sta.setup-compare.v1",
      "comparison": ToJson::to_json(
        compare_setup_snapshots(baseline, candidate, max_slack_loss_seconds),
      ),
    }
  } catch {
    error =>
      {
        "ok": false,
        "schema": "moonbit.sta.setup-compare.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
      }
  }
  result.stringify()
}
