///|
fn priority_test_field(value : Json, key : String) -> Json {
  guard value is Object(fields) else { abort("fixture object") }
  fields[key]
}

///|
fn priority_test_text(value : Json) -> String {
  guard value is String(text) else { abort("fixture string") }
  text
}

///|
fn priority_test_number(value : Json) -> Double {
  guard value is Number(number, ..) else { abort("fixture number") }
  number
}

///|
fn priority_test_optional(value : Json, key : String) -> Double? {
  guard value is Object(fields) else { abort("fixture object") }
  match fields.get(key) {
    Some(Number(value, ..)) => Some(value)
    _ => None
  }
}

///|
fn priority_test_edge(value : Json) -> @sta.Edge {
  match value {
    String("Rise") => @sta.Rise
    String("Fall") => @sta.Fall
    _ => abort("fixture edge")
  }
}

///|
fn priority_test_source(text : String) -> @sta.STAResult raise {
  let result = priority_test_field(@json.parse(text), "result")
  guard priority_test_field(result, "endpoints") is Array(values) else {
    abort("fixture endpoints")
  }
  let endpoints : Array[@sta.EndpointTiming] = values.map(value => {
    guard priority_test_field(value, "path") is Array(steps) else {
      abort("fixture path")
    }
    {
      pin: priority_test_text(priority_test_field(value, "pin")),
      edge: priority_test_edge(priority_test_field(value, "edge")),
      arrival_seconds: priority_test_optional(value, "arrival_seconds"),
      required_seconds: priority_test_optional(value, "required_seconds"),
      slack_seconds: priority_test_optional(value, "slack_seconds"),
      setup_seconds: priority_test_optional(value, "setup_seconds"),
      path: steps.map(step => {
        pin: priority_test_text(priority_test_field(step, "pin")),
        edge: priority_test_edge(priority_test_field(step, "edge")),
        delay_seconds: priority_test_number(
          priority_test_field(step, "delay_seconds"),
        ),
        arrival_seconds: priority_test_number(
          priority_test_field(step, "arrival_seconds"),
        ),
        arc: priority_test_text(priority_test_field(step, "arc")),
      }),
    }
  })
  {
    nodes: [],
    endpoints,
    worst_slack_seconds: priority_test_optional(result, "worst_slack_seconds"),
    diagnostics: [],
    topological_order: [],
  }
}

///|
fn priority_test_catalog() -> (Array[Json], Json) raise {
  let catalog = @json.parse(@testdata.setup_priority_cases())
  guard priority_test_field(catalog, "cases") is Array(cases) else {
    abort("fixture cases")
  }
  (cases, priority_test_field(catalog, "reports"))
}

///|
fn priority_test_limit(case : Json) -> Double {
  guard case is Object(fields) else { abort("fixture case") }
  match fields.get("special_limit") {
    Some(String("nan")) => 0.0 / 0.0
    Some(String("positive-infinity")) => 1.0 / 0.0
    Some(String("negative-infinity")) => -1.0 / 0.0
    _ => priority_test_number(fields["max_endpoints"])
  }
}

///|
// A separate package consumes only the public query and original endpoint/path.
fn main raise {
  let (cases, reports) = priority_test_catalog()
  let outputs : Array[Json] = []
  for case in cases {
    if priority_test_field(case, "public_typed") == true {
      let source = priority_test_source(
        priority_test_text(
          priority_test_field(
            reports,
            priority_test_text(priority_test_field(case, "report")),
          ),
        ),
      )
      let before = ToJson::to_json(source)
      let priorities = source.prioritize_setup_endpoints(
        max_endpoints=priority_test_limit(case).to_int(),
      )
      let selected : Array[Json] = priorities.rows.map(row => {
        ToJson::to_json(source.endpoints[row.worst_source_index.unwrap()])
      })
      outputs.push({
        "name": priority_test_field(case, "name"),
        "priorities": ToJson::to_json(priorities),
        "selected_source_endpoints": ToJson::to_json(selected),
        "original_unchanged": ToJson::to_json(source) == before,
      })
    }
  }
  println(ToJson::to_json(outputs).stringify())
}
