///|
fn plt_field(value : Json, key : String) -> Json {
  match value {
    Object(fields) => fields[key]
    _ => abort("fixture object")
  }
}

///|
fn plt_text(value : Json) -> String {
  match value {
    String(text) => text
    _ => abort("fixture string")
  }
}

///|
fn plt_array(value : Json) -> Array[Json] {
  match value {
    Array(values) => values
    _ => abort("fixture array")
  }
}

///|
fn plt_number(value : Json) -> Double {
  match value {
    Number(number, ..) => number
    _ => abort("fixture number")
  }
}

///|
fn plt_library(catalog : Json, name : String) -> String {
  if name == "existing-sky130" {
    @testdata.library()
  } else {
    plt_text(plt_field(plt_field(catalog, "libraries"), name))
  }
}

///|
fn plt_engine(
  catalog : Json,
  library? : String = "strict",
  netlist? : String = "base",
  sdc? : String = "base",
  policy? : @liberty.RangePolicy = @liberty.Reject,
) -> @sta.STAEngine raise {
  let library = @liberty.load_library(plt_library(catalog, library))
  let netlist = @sta.netlist_from_json(
    plt_field(plt_field(catalog, "netlists"), netlist),
  )
  let constraints = @sta.parse_sdc(
    plt_text(plt_field(plt_field(catalog, "sdc"), sdc)),
    library,
    netlist,
  )
  @sta.STAEngine::new(library, netlist, constraints, policy~)
}

///|
test "pin limits complete frozen22-case reports match independent rows and errors" {
  let catalog = @json.parse(@testdata.pin_limit_cases())
  let cases = plt_array(plt_field(catalog, "cases"))
  assert_eq(cases.length(), 22)
  for fixture in cases {
    let result = @json.parse(
      @sta.analyze_pin_limits_json(
        plt_library(catalog, plt_text(plt_field(fixture, "library"))),
        plt_field(
          plt_field(catalog, "netlists"),
          plt_text(plt_field(fixture, "netlist")),
        ).stringify(),
        plt_text(
          plt_field(
            plt_field(catalog, "sdc"),
            plt_text(plt_field(fixture, "sdc")),
          ),
        ),
        plt_text(plt_field(fixture, "policy")),
      ),
    )
    let expected = plt_field(fixture, "expected")
    assert_eq(plt_field(result, "schema"), "moonbit.sta.pin-limits.v1")
    if expected is { "error": String(message), .. } {
      assert_eq(plt_field(result, "ok"), false)
      assert_true(plt_text(plt_field(result, "error")).contains(message))
      continue
    }
    assert_eq(plt_field(result, "ok"), true)
    let report = plt_field(result, "pin_limits")
    for
      key in [
        "status", "checked_rules", "violated_rules", "unspecified_rules", "invalid_rules",
      ] {
      assert_eq(plt_field(report, key), plt_field(expected, key))
    }
    let actual_rows = plt_array(plt_field(report, "checks"))
    let expected_rows = plt_array(plt_field(expected, "checks"))
    assert_eq(actual_rows.length(), expected_rows.length())
    for i, actual in actual_rows {
      let reference = expected_rows[i]
      guard actual is Object(fields) else { fail("row object") }
      guard reference is Object(expected_fields) else { fail("expected row") }
      for
        key in [
          "instance", "cell", "library_pin", "pin", "edge", "kind", "unit", "status",
          "source", "source_attribute", "raw_limit", "issue",
        ] {
        assert_eq(fields.get(key), expected_fields.get(key))
      }
      for key in ["actual_si", "limit_si", "margin_si"] {
        match expected_fields.get(key) {
          None => assert_true(!fields.contains(key))
          Some(value) => {
            let value = plt_number(value)
            let absolute = if plt_field(reference, "unit") == "farads" {
              1.0e-27
            } else {
              1.0e-21
            }
            let magnitude = if value < 0.0 { -value } else { value }
            let relative = magnitude * 1.0e-14
            near(
              plt_number(fields[key]),
              value,
              tolerance=if relative > absolute { relative } else { absolute },
            )
          }
        }
      }
    }
  }
}

///|
test "pin limits distinguish same setup-Met timing with strict versus loose bounds" {
  let catalog = @json.parse(@testdata.pin_limit_cases())
  let strict = plt_engine(catalog).run_pin_limit_analysis()
  let loose = plt_engine(catalog, library="met").run_pin_limit_analysis()
  assert_eq(ToJson::to_json(strict.timing), ToJson::to_json(loose.timing))
  assert_eq(strict.timing.setup_summary().status, @sta.Met)
  assert_eq(strict.pin_limits.status, @sta.LimitsViolated)
  assert_eq(strict.pin_limits.violated_rules, 4)
  assert_eq(loose.pin_limits.status, @sta.LimitsMet)
  assert_eq(strict.pin_limits.checks[3].kind, @sta.MaxCapacitance)
  near(strict.pin_limits.checks[3].actual_si, 1.25e-12, tolerance=1.0e-26)
  assert_eq(strict.pin_limits.checks[3].pin, "u~1~0😀/Y")
}

///|
test "pin limits invalid accepted declaration retains original successful setup" {
  let catalog = @json.parse(@testdata.pin_limit_cases())
  let engine = plt_engine(catalog, library="invalid_pin")
  let before = engine.run_setup_analysis()
  let analysis = engine.run_pin_limit_analysis()
  assert_eq(ToJson::to_json(before), ToJson::to_json(analysis.timing))
  assert_eq(analysis.pin_limits.status, @sta.InvalidLimits)
  assert_eq(analysis.pin_limits.invalid_rules, 2)
  assert_eq(analysis.pin_limits.checks[0].raw_limit, Some("-0.1"))
  assert_true(analysis.pin_limits.checks[0].limit_si is None)
  assert_true(analysis.pin_limits.checks[0].margin_si is None)
}

///|
test "pin limits full physical loads survive Clamp and missing data arrival" {
  let catalog = @json.parse(@testdata.pin_limit_cases())
  let clamped = plt_engine(catalog, sdc="high", policy=@liberty.Clamp).run_pin_limit_analysis()
  near(clamped.pin_limits.checks[2].actual_si, 3.5e-12, tolerance=1.0e-26)
  near(clamped.pin_limits.checks[3].actual_si, 3.75e-12, tolerance=1.0e-26)
  let unknown = plt_engine(catalog, sdc="unknown").run_pin_limit_analysis()
  assert_true(node(unknown.timing, "u~1~0😀/Y", Rise).arrival_seconds is None)
  assert_eq(unknown.pin_limits.violated_rules, 4)
  near(unknown.pin_limits.checks[4].actual_si, 0.2e-9)
}

///|
test "pin limits explicit pin override suppresses unused invalid library default" {
  let catalog = @json.parse(@testdata.pin_limit_cases())
  let report = plt_engine(catalog, library="override_default").run_pin_limit_analysis().pin_limits
  assert_eq(report.status, @sta.LimitsMet)
  assert_eq(report.invalid_rules, 0)
  assert_eq(report.checks[10].source, Some(@sta.PinAttribute))
  near(report.checks[10].limit_si.unwrap(), 0.2e-9)
}

///|
test "pin limit result rows are owned independently of timing and future calls" {
  let catalog = @json.parse(@testdata.pin_limit_cases())
  let engine = plt_engine(catalog)
  let analysis = engine.run_pin_limit_analysis()
  analysis.pin_limits.checks[3] = {
    ..analysis.pin_limits.checks[3],
    actual_si: 100.0,
  }
  near(
    node(analysis.timing, "u~1~0😀/Y", Fall).load_farads,
    1.25e-12,
    tolerance=1.0e-26,
  )
  near(
    engine.run_pin_limit_analysis().pin_limits.checks[3].actual_si,
    1.25e-12,
    tolerance=1.0e-26,
  )
}
