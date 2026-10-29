///|
fn sct_field(value : Json, key : String) -> Json {
  match value {
    Object(fields) => fields[key]
    _ => abort("fixture object")
  }
}

///|
fn sct_text(value : Json) -> String {
  match value {
    String(text) => text
    _ => abort("fixture string")
  }
}

///|
fn sct_number(value : Json) -> Double {
  match value {
    Number(number, ..) => number
    _ => abort("fixture number")
  }
}

///|
fn sct_case(catalog : Json, name : String) -> Json {
  guard sct_field(catalog, "cases") is Array(cases) else { abort("cases") }
  cases
  .iter()
  .find_first(value => sct_text(sct_field(value, "name")) == name)
  .unwrap()
}

///|
fn sct_optional(value : Json, key : String) -> Double? {
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
/// Typed fixture input reconstructs only the consumed public endpoint view.
fn sct_result(catalog : Json, name : String) -> @sta.STAResult raise {
  let source = sct_text(sct_field(sct_field(catalog, "reports"), name))
  let result = sct_field(@json.parse(source), "result")
  guard sct_field(result, "endpoints") is Array(values) else {
    abort("endpoints")
  }
  let endpoints : Array[@sta.EndpointTiming] = values.map(value => {
    pin: sct_text(sct_field(value, "pin")),
    edge: if sct_field(value, "edge") == "Rise" {
      @sta.Rise
    } else {
      @sta.Fall
    },
    arrival_seconds: sct_optional(value, "arrival_seconds"),
    required_seconds: sct_optional(value, "required_seconds"),
    slack_seconds: sct_optional(value, "slack_seconds"),
    setup_seconds: sct_optional(value, "setup_seconds"),
    path: [],
  })
  {
    nodes: [],
    endpoints,
    worst_slack_seconds: sct_optional(result, "worst_slack_seconds"),
    diagnostics: [],
    topological_order: [],
  }
}

///|
/// Full independent field/omission/order checks, tolerating only stated floats.
fn sct_receive(actual : Json, expected : Json) -> Unit raise {
  match (actual, expected) {
    (Number(a, ..), Number(e, ..)) => {
      let relative = e.abs() * 1.0e-14
      near(a, e, tolerance=if relative > 1.0e-21 { relative } else { 1.0e-21 })
    }
    (Array(a), Array(e)) => {
      assert_eq(a.length(), e.length())
      for index, value in a {
        sct_receive(value, e[index])
      }
    }
    (Object(a), Object(e)) => {
      assert_eq(a.length(), e.length())
      for key, value in e {
        assert_true(a.contains(key))
        sct_receive(a[key], value)
      }
    }
    _ => assert_eq(actual, expected)
  }
}

///|
test "setup comparison full30 frozen existing reports and complete expected changes" {
  let catalog = @json.parse(@testdata.setup_comparison_cases())
  guard sct_field(catalog, "cases") is Array(cases) else { fail("cases") }
  assert_eq(cases.length(), 30)
  let reports = sct_field(catalog, "reports")
  for fixture in cases {
    let result = @json.parse(
      @sta.compare_setup_json(
        sct_text(sct_field(reports, sct_text(sct_field(fixture, "baseline")))),
        sct_text(sct_field(reports, sct_text(sct_field(fixture, "candidate")))),
        sct_number(sct_field(fixture, "max_slack_loss_seconds")),
      ),
    )
    assert_eq(sct_field(result, "schema"), "moonbit.sta.setup-compare.v1")
    let expected = sct_field(fixture, "expected")
    if expected is { "error": String(message), .. } {
      assert_eq(sct_field(result, "ok"), false)
      assert_true(sct_text(sct_field(result, "error")).contains(message))
    } else {
      assert_eq(sct_field(result, "ok"), true)
      sct_receive(sct_field(result, "comparison"), expected)
    }
  }
}

///|
test "setup comparison detects relative loss while both absolute setup reports are Met" {
  let catalog = @json.parse(@testdata.setup_comparison_cases())
  let baseline = sct_result(catalog, "base")
  let candidate = sct_result(catalog, "loss")
  assert_eq(baseline.setup_summary().status, @sta.Met)
  assert_eq(candidate.setup_summary().status, @sta.Met)
  let strict = @sta.compare_setup_results(baseline, candidate)
  assert_eq(strict.status, @sta.SetupRegressed)
  assert_eq(strict.regressed_endpoint_edges, 1)
  assert_eq(strict.rows[0].slack_delta_seconds, Some(-0.25))
  let allowed = @sta.compare_setup_results(
    baseline,
    candidate,
    max_slack_loss_seconds=0.25,
  )
  assert_eq(allowed.status, @sta.NoSetupRegression)
  assert_eq(allowed.rows[0].status, @sta.SetupDeltaTolerated)
}

///|
test "setup comparison full identity union keeps known regressions and incomplete edges" {
  let catalog = @json.parse(@testdata.setup_comparison_cases())
  let report = @sta.compare_setup_results(
    sct_result(catalog, "base"),
    sct_result(catalog, "mixed"),
  )
  assert_eq(report.status, @sta.SetupRegressed)
  assert_eq(report.matched_endpoint_edges, 1)
  assert_eq(report.incomplete_endpoint_edges, 2)
  assert_eq(report.rows[1].status, @sta.SetupDeltaBaselineOnly)
  assert_eq(report.rows[2].status, @sta.SetupDeltaCandidateOnly)
  sct_receive(
    ToJson::to_json(report),
    sct_field(sct_case(catalog, "known-regression-and-set-changes"), "expected"),
  )
  let empty = sct_result(catalog, "empty")
  assert_eq(
    @sta.compare_setup_results(empty, empty).status,
    @sta.SetupComparisonIncomplete,
  )
}

///|
test "setup comparison finite huge boundary and overflow retain honest unknown delta" {
  let catalog = @json.parse(@testdata.setup_comparison_cases())
  let huge = sct_result(catalog, "huge")
  let half = sct_result(catalog, "half")
  let negative = sct_result(catalog, "negative-huge")
  let report = @sta.compare_setup_results(huge, negative)
  assert_eq(report.status, @sta.SetupComparisonIncomplete)
  assert_eq(report.rows[0].status, @sta.SetupDeltaOverflow)
  assert_true(report.rows[0].slack_delta_seconds is None)
  assert_eq(report.rows[0].baseline_slack_seconds, Some(1.0e308))
  assert_true(!ToJson::to_json(report).stringify().contains("Infinity"))
  let finite = @sta.compare_setup_results(
    huge,
    half,
    max_slack_loss_seconds=5.0e307,
  )
  assert_eq(finite.status, @sta.NoSetupRegression)
  assert_eq(finite.rows[0].slack_delta_seconds, Some(-5.0e307))
}

///|
test "setup comparison owned rows leave both original report arrays untouched" {
  let catalog = @json.parse(@testdata.setup_comparison_cases())
  let baseline = sct_result(catalog, "base")
  let candidate = sct_result(catalog, "loss")
  let before = (ToJson::to_json(baseline), ToJson::to_json(candidate))
  @sta.compare_setup_results(baseline, candidate).rows.clear()
  assert_eq((ToJson::to_json(baseline), ToJson::to_json(candidate)), before)
  assert_eq(@sta.compare_setup_results(baseline, candidate).rows.length(), 2)
}

///|
test "setup comparison rejects ambiguous typed identities and invalid loss settings" {
  let catalog = @json.parse(@testdata.setup_comparison_cases())
  let one = sct_result(catalog, "one")
  let duplicate = sct_result(catalog, "duplicate")
  let duplicate_rejected = try {
    let _ = @sta.compare_setup_results(duplicate, one)
    false
  } catch {
    @sta.InvalidInput(message) =>
      message.contains("duplicate/empty baseline endpoint")
    _ => false
  }
  assert_true(duplicate_rejected)
  let invalid_budget = try {
    let _ = @sta.compare_setup_results(one, one, max_slack_loss_seconds=-1.0)
    false
  } catch {
    @sta.InvalidInput(message) => message.contains("finite and nonnegative")
    _ => false
  }
  assert_true(invalid_budget)
}
