///|
fn rct_field(value : Json, key : String) -> Json {
  match value {
    Object(fields) => fields[key]
    _ => abort("fixture object")
  }
}

///|
fn rct_text(value : Json) -> String {
  match value {
    String(text) => text
    _ => abort("fixture string")
  }
}

///|
fn rct_case(catalog : Json, name : String) -> Json {
  guard rct_field(catalog, "cases") is Array(cases) else { abort("cases") }
  cases
  .iter()
  .find_first(value => rct_text(rct_field(value, "name")) == name)
  .unwrap()
}

///|
fn rct_source(catalog : Json, fixture : Json) -> String {
  if rct_field(fixture, "library") == "existing-sky130" {
    @testdata.library()
  } else {
    rct_text(rct_field(rct_field(catalog, "libraries"), "simple"))
  }
}

///|
fn rct_inputs(
  catalog : Json,
  name : String,
) -> (@liberty.Library, @sta.Netlist) raise {
  let fixture = rct_case(catalog, name)
  (
    @liberty.load_library(rct_source(catalog, fixture)),
    @sta.netlist_from_json(rct_field(fixture, "netlist")),
  )
}

///|
test "reference check full24 independent reports pointers and errors" {
  let catalog = @json.parse(@testdata.reference_cases())
  guard rct_field(catalog, "cases") is Array(cases) else { fail("cases") }
  assert_eq(cases.length(), 24)
  for fixture in cases {
    let result = @json.parse(
      @sta.check_netlist_references_json(
        rct_source(catalog, fixture),
        rct_field(fixture, "netlist").stringify(),
      ),
    )
    assert_eq(rct_field(result, "schema"), "moonbit.sta.references.v1")
    let expected = rct_field(fixture, "expected")
    if expected is { "error": String(message), .. } {
      assert_eq(rct_field(result, "ok"), false)
      assert_true(rct_text(rct_field(result, "error")).contains(message))
      assert_eq(rct_field(result, "pointer"), rct_field(expected, "pointer"))
    } else {
      assert_eq(rct_field(result, "ok"), true)
      assert_eq(rct_field(result, "references"), expected)
    }
  }
}

///|
test "reference check typed no units capacitance tables or constraints" {
  let catalog = @json.parse(@testdata.reference_cases())
  let (library, netlist) = rct_inputs(catalog, "resolved-no-timing")
  assert_true(library.units is None)
  assert_true(library.cells[0].pins[0].capacitance is None)
  assert_eq(library.cells[0].pins[1].timings.length(), 0)
  let report = @sta.check_netlist_references(library, netlist)
  assert_eq(report.status, @sta.ReferencesResolved)
  assert_eq(report.scope, "scalar_names_and_references")
  assert_eq(report.matched_instances, 1)
  assert_eq(report.matched_pin_connections, 2)
  assert_eq(report.issue_count, 0)
}

///|
test "reference check all14 independent findings retain order and first witnesses" {
  let catalog = @json.parse(@testdata.reference_cases())
  let (library, netlist) = rct_inputs(catalog, "all14-issues")
  let report = @sta.check_netlist_references(library, netlist)
  assert_eq(report.status, @sta.ReferenceIssuesFound)
  assert_eq(report.issues.length(), 14)
  assert_eq(report.matched_instances, 1)
  assert_eq(report.matched_pin_connections, 0)
  assert_eq(report.issues[0].first_pointer, Some("/nets/0/name"))
  assert_eq(report.issues[4].first_pointer, Some("/ports/0/name"))
  assert_eq(report.issues[7].first_pointer, Some("/gates/0/connections/0/pin"))
  assert_eq(report.issues[13].code, @sta.RefUnresolvedNet)
  assert_eq(
    ToJson::to_json(report),
    rct_field(rct_case(catalog, "all14-issues"), "expected"),
  )
}

///|
test "reference check owned issues do not mutate input or subsequent reports" {
  let catalog = @json.parse(@testdata.reference_cases())
  let (library, netlist) = rct_inputs(catalog, "all14-issues")
  let before = ToJson::to_json(netlist)
  let report = @sta.check_netlist_references(library, netlist)
  report.issues.clear()
  assert_eq(ToJson::to_json(netlist), before)
  assert_eq(library.cells[0].pins[0].name, "A")
  assert_eq(@sta.check_netlist_references(library, netlist).issues.length(), 14)
}

///|
test "reference check explicitly leaves directions drivers cycles and numbers outside scope" {
  let catalog = @json.parse(@testdata.reference_cases())
  for
    name in [
      "metadata-pin-directions", "cycle-outside-scope", "numeric-and-drivers-outside-scope",
    ] {
    let (library, netlist) = rct_inputs(catalog, name)
    assert_eq(
      @sta.check_netlist_references(library, netlist).status,
      @sta.ReferencesResolved,
    )
  }
}

///|
test "reference check preserves first cell match and uses public typed pin metadata" {
  let catalog = @json.parse(@testdata.reference_cases())
  let (library, netlist) = rct_inputs(catalog, "resolved-no-timing")
  library.cells[1] = { ..library.cells[1], name: "BUF", }
  assert_eq(
    @sta.check_netlist_references(library, netlist).status,
    @sta.ReferencesResolved,
  )
  library.cells[0].pins[0] = { ..library.cells[0].pins[0], name: "renamed", }
  let report = @sta.check_netlist_references(library, netlist)
  assert_eq(report.issue_count, 2)
  assert_eq(report.issues[0].code, @sta.RefUnknownPin)
  assert_eq(report.issues[0].name, "A")
  assert_eq(report.issues[1].code, @sta.RefMissingPin)
  assert_eq(report.issues[1].name, "renamed")
}
