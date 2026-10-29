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
test "setup priority full valid JSON facts" {
  let (cases, reports) = priority_test_catalog()
  for case in cases {
    if priority_test_field(case, "expected_exit") == 0 {
      let source = priority_test_field(
        reports,
        priority_test_text(priority_test_field(case, "report")),
      )
      let got = @json.parse(
        @sta.prioritize_setup_json(
          priority_test_text(source),
          priority_test_limit(case),
        ),
      )
      assert_eq(got, priority_test_field(case, "expected"))
    }
  }
}

///|
test "setup priority full invalid report facts" {
  let (cases, reports) = priority_test_catalog()
  for case in cases {
    let name = priority_test_text(priority_test_field(case, "name"))
    if priority_test_field(case, "expected_exit") == 2 &&
      !name.contains("limit") {
      let source = priority_test_field(
        reports,
        priority_test_text(priority_test_field(case, "report")),
      )
      assert_eq(
        @json.parse(
          @sta.prioritize_setup_json(
            priority_test_text(source),
            priority_test_limit(case),
          ),
        ),
        priority_test_field(case, "expected"),
      )
    }
  }
}

///|
test "setup priority full JSON setting facts" {
  let (cases, reports) = priority_test_catalog()
  for case in cases {
    let name = priority_test_text(priority_test_field(case, "name"))
    if priority_test_field(case, "expected_exit") == 2 && name.contains("limit") {
      assert_eq(
        @json.parse(
          @sta.prioritize_setup_json(
            priority_test_text(
              priority_test_field(
                reports,
                priority_test_text(priority_test_field(case, "report")),
              ),
            ),
            priority_test_limit(case),
          ),
        ),
        priority_test_field(case, "expected"),
      )
    }
  }
}

///|
test "setup priority public typed facts and original paths" {
  let (cases, reports) = priority_test_catalog()
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
      let got = source.prioritize_setup_endpoints(
        max_endpoints=priority_test_limit(case).to_int(),
      )
      assert_eq(
        ToJson::to_json(got),
        priority_test_field(priority_test_field(case, "expected"), "priorities"),
      )
      for row in got.rows {
        let original = source.endpoints[row.worst_source_index.unwrap()]
        assert_eq(original.pin, row.pin)
        assert_eq(Some(original.edge), row.worst_edge)
        assert_eq(original.slack_seconds, row.worst_slack_seconds)
        assert_true(!original.path.is_empty())
      }
      assert_eq(ToJson::to_json(source), before)
    }
  }
}

///|
test "setup priority default and owned result arrays" {
  let (cases, reports) = priority_test_catalog()
  let fixture = cases
    .iter()
    .find_first(case => {
      priority_test_field(case, "name") == "default-ten-truncates-known-only"
    })
    .unwrap()
  let source = priority_test_source(
    priority_test_text(
      priority_test_field(
        reports,
        priority_test_text(priority_test_field(fixture, "report")),
      ),
    ),
  )
  let before = ToJson::to_json(source)
  let got = source.prioritize_setup_endpoints()
  assert_eq(
    ToJson::to_json(got),
    priority_test_field(priority_test_field(fixture, "expected"), "priorities"),
  )
  got.rows.clear()
  got.unranked_endpoints.clear()
  assert_eq(ToJson::to_json(source), before)
  assert_eq(source.prioritize_setup_endpoints().rows.length(), 10)
}

///|
test "setup priority typed validation is complete before selection" {
  fn source(slack : Double?, duplicate : Bool) -> @sta.STAResult {
    let endpoint : @sta.EndpointTiming = {
      pin: "p",
      edge: @sta.Rise,
      arrival_seconds: None,
      required_seconds: None,
      slack_seconds: slack,
      setup_seconds: None,
      path: [],
    }
    {
      nodes: [],
      endpoints: if duplicate {
        [endpoint, endpoint]
      } else {
        [endpoint]
      },
      worst_slack_seconds: None,
      diagnostics: [],
      topological_order: [],
    }
  }
  for
    (value, limit) in [
      (source(Some(0.0), false), -1),
      (source(Some(0.0 / 0.0), false), 0),
      (source(Some(1.0 / 0.0), false), 0),
      (source(Some(-1.0 / 0.0), false), 0),
      (source(Some(-1.0), true), 1),
    ] {
    let rejected = try {
      let _ = value.prioritize_setup_endpoints(max_endpoints=limit)
      false
    } catch {
      @sta.InvalidInput(_) => true
      _ => false
    }
    assert_true(rejected)
  }
}
