///|
fn field(value : Json, key : String) -> Json {
  match value {
    Object(fields) => fields[key]
    _ => abort("fixture object")
  }
}

///|
fn text(value : Json) -> String {
  match value {
    String(value) => value
    _ => abort("fixture string")
  }
}

///|
fn number(value : Json) -> Double {
  match value {
    Number(value, ..) => value
    _ => abort("fixture number")
  }
}

///|
fn optional_number(value : Json, key : String) -> Double? {
  match value {
    Object(fields) =>
      match fields.get(key) {
        Some(Number(value, ..)) => Some(value)
        _ => None
      }
    _ => abort("fixture object")
  }
}

///|
/// Reconstruct the public endpoint view, without evaluating timing or matching
/// endpoints here. Nodes/paths are not consumed by the public comparison API.
fn endpoint_view(source : String) -> @sta.STAResult raise {
  let result = field(@json.parse(source), "result")
  guard field(result, "endpoints") is Array(values) else { abort("endpoints") }
  let endpoints : Array[@sta.EndpointTiming] = values.map(value => {
    pin: text(field(value, "pin")),
    edge: if field(value, "edge") == "Rise" {
      @sta.Rise
    } else {
      @sta.Fall
    },
    arrival_seconds: optional_number(value, "arrival_seconds"),
    required_seconds: optional_number(value, "required_seconds"),
    slack_seconds: optional_number(value, "slack_seconds"),
    setup_seconds: optional_number(value, "setup_seconds"),
    path: [],
  })
  {
    nodes: [],
    endpoints,
    worst_slack_seconds: optional_number(result, "worst_slack_seconds"),
    diagnostics: [],
    topological_order: [],
  }
}

///|
/// A separate package invokes only the public typed comparison, not JSON API.
fn main raise {
  let catalog = @json.parse(@testdata.setup_comparison_cases())
  guard field(catalog, "cases") is Array(cases) else { abort("cases") }
  let reports = field(catalog, "reports")
  let comparisons : Array[@sta.SetupComparison] = []
  for
    name in [
      "positive-slack-loss", "exact-tolerance-allowed", "candidate-slack-missing",
      "known-regression-and-set-changes", "actual-old-cli-both-met",
    ] {
    let fixture = cases
      .iter()
      .find_first(value => text(field(value, "name")) == name)
      .unwrap()
    comparisons.push(
      @sta.compare_setup_results(
        endpoint_view(text(field(reports, text(field(fixture, "baseline"))))),
        endpoint_view(text(field(reports, text(field(fixture, "candidate"))))),
        max_slack_loss_seconds=number(field(fixture, "max_slack_loss_seconds")),
      ),
    )
  }
  println(ToJson::to_json(comparisons).stringify())
}
