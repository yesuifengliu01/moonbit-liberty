///|
fn cut_field(value : Json, key : String) -> Json {
  match value {
    Object(fields) => fields[key]
    _ => abort("fixture object")
  }
}

///|
fn cut_text(value : Json) -> String {
  match value {
    String(text) => text
    _ => abort("fixture text")
  }
}

///|
fn cut_case(catalog : Json, name : String) -> Json {
  guard cut_field(catalog, "cases") is Array(cases) else {
    abort("fixture cases")
  }
  cases
  .iter()
  .find_first(value => cut_text(cut_field(value, "name")) == name)
  .unwrap()
}

///|
fn cut_source(catalog : Json, fixture : Json) -> String {
  if cut_field(fixture, "library") == "existing-sky130" {
    @testdata.library()
  } else {
    cut_text(
      cut_field(
        cut_field(catalog, "libraries"),
        cut_text(cut_field(fixture, "library")),
      ),
    )
  }
}

///|
fn cut_inputs(
  catalog : Json,
  name : String,
) -> (@liberty.Library, @sta.Netlist) raise {
  let fixture = cut_case(catalog, name)
  (
    @liberty.load_library(cut_source(catalog, fixture)),
    @sta.netlist_from_json(cut_field(fixture, "netlist")),
  )
}

///|
/// Compare complete independent records, including omitted fields and ordering.
fn cut_receive(actual : Json, expected : Json) -> Unit raise {
  match (actual, expected) {
    (Number(a, ..), Number(e, ..)) => {
      let relative = e.abs() * 1.0e-14
      near(a, e, tolerance=if relative > 1.0e-12 { relative } else { 1.0e-12 })
    }
    (Array(a), Array(e)) => {
      assert_eq(a.length(), e.length())
      for i, value in a {
        cut_receive(value, e[i])
      }
    }
    (Object(a), Object(e)) => {
      assert_eq(a.length(), e.length())
      for key, value in e {
        assert_true(a.contains(key))
        cut_receive(a[key], value)
      }
    }
    _ => assert_eq(actual, expected)
  }
}

///|
test "cell usage full21 frozen reports and identity errors" {
  let catalog = @json.parse(@testdata.cell_usage_cases())
  guard cut_field(catalog, "cases") is Array(cases) else { fail("cases") }
  assert_eq(cases.length(), 21)
  for fixture in cases {
    let result = @json.parse(
      @sta.analyze_cell_usage_json(
        cut_source(catalog, fixture),
        cut_field(fixture, "netlist").stringify(),
      ),
    )
    assert_eq(cut_field(result, "schema"), "moonbit.sta.cell-usage.v1")
    let expected = cut_field(fixture, "expected")
    if expected is { "error": String(message), .. } {
      assert_eq(cut_field(result, "ok"), false)
      assert_true(cut_text(cut_field(result, "error")).contains(message))
    } else {
      assert_eq(cut_field(result, "ok"), true)
      cut_receive(cut_field(result, "usage"), expected)
    }
  }
}

///|
test "cell usage typed standalone needs no units constraints or timing tables" {
  let catalog = @json.parse(@testdata.cell_usage_cases())
  let (library, netlist) = cut_inputs(catalog, "complete-no-timing")
  assert_true(library.units is None)
  assert_eq(library.cells[0].pins[0].timings.length(), 0)
  let report = @sta.analyze_cell_usage(library, netlist)
  assert_eq(report.status, @sta.UsageComplete)
  assert_eq(report.instance_count, 3)
  assert_eq(report.cells.length(), 2)
  assert_eq(report.total_declared_area, Some(5.0))
  assert_eq(report.instances[0].instance, "u/~😀")
  assert_eq(report.instances[0].cell, "BUF/~😀")
}

///|
test "cell usage typed partial data retains known subtotal and explicit reasons" {
  let catalog = @json.parse(@testdata.cell_usage_cases())
  let (library, netlist) = cut_inputs(catalog, "mixed-coverage")
  let report = @sta.analyze_cell_usage(library, netlist)
  assert_eq(report.status, @sta.UsageIncomplete)
  assert_eq(report.known_area_subtotal, Some(3.75))
  assert_true(report.total_declared_area is None)
  assert_eq(report.instances[2].area_state, @sta.MissingArea)
  assert_eq(report.instances[3].area_state, @sta.InvalidArea)
  assert_eq(report.instances[4].area_state, @sta.UnmappedCell)
  assert_eq(report.instances[3].raw_area, Some("-0.5"))
  assert_true(report.instances[3].declared_area is None)
}

///|
test "cell usage product and subtotal overflow never serialize invented totals" {
  let catalog = @json.parse(@testdata.cell_usage_cases())
  for name in ["group-product-overflow", "subtotal-overflow"] {
    let (library, netlist) = cut_inputs(catalog, name)
    let report = @sta.analyze_cell_usage(library, netlist)
    assert_eq(report.status, @sta.UsageIncomplete)
    assert_true(report.area_overflow)
    assert_true(report.known_area_subtotal is None)
    assert_true(report.total_declared_area is None)
    assert_eq(report.cells[0].area_overflow, name == "group-product-overflow")
    assert_true(!ToJson::to_json(report).stringify().contains("Infinity"))
  }
  let (library, netlist) = cut_inputs(catalog, "large-finite")
  assert_eq(
    @sta.analyze_cell_usage(library, netlist).total_declared_area,
    Some(1.0e308),
  )
}

///|
test "cell usage owned output cannot mutate inputs or later reports" {
  let catalog = @json.parse(@testdata.cell_usage_cases())
  let (library, netlist) = cut_inputs(catalog, "complete-no-timing")
  let before = ToJson::to_json(netlist)
  let report = @sta.analyze_cell_usage(library, netlist)
  report.instances.clear()
  report.cells.clear()
  assert_eq(ToJson::to_json(netlist), before)
  assert_eq(library.cells[0].area, Some(1.25))
  let next = @sta.analyze_cell_usage(library, netlist)
  assert_eq(next.instances.length(), 3)
  assert_eq(next.cells.length(), 2)
  assert_eq(next.total_declared_area, Some(5.0))
}

///|
test "cell usage typed identity failures and public numeric cell metadata" {
  let catalog = @json.parse(@testdata.cell_usage_cases())
  for name in ["duplicate-instance", "empty-instance"] {
    let (library, netlist) = cut_inputs(catalog, name)
    let rejected = try {
      let _ = @sta.analyze_cell_usage(library, netlist)
      false
    } catch {
      @sta.InvalidInput(message) => message.contains("duplicate/empty instance")
      _ => false
    }
    assert_true(rejected)
  }
  let (library, netlist) = cut_inputs(catalog, "complete-no-timing")
  // Programmatic Library.cell area remains the public numeric source of truth.
  library.cells[0] = { ..library.cells[0], area: Some(7.5), }
  let report = @sta.analyze_cell_usage(library, netlist)
  assert_eq(report.total_declared_area, Some(17.5))
  assert_eq(report.cells[0].raw_area, Some("1.25"))
}
