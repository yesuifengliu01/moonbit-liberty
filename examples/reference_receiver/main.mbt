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
/// A separately compiled package consumes only public typed reference APIs.
fn main raise {
  let catalog = @json.parse(@testdata.reference_cases())
  guard field(catalog, "cases") is Array(cases) else { abort("cases") }
  let reports : Array[@sta.NetlistReferenceReport] = []
  for
    name in [
      "resolved-no-timing", "all14-issues", "raw-names-native-directions", "cycle-outside-scope",
      "real-sky130",
    ] {
    let fixture = cases
      .iter()
      .find_first(value => text(field(value, "name")) == name)
      .unwrap()
    let source = if field(fixture, "library") == "existing-sky130" {
      @testdata.library()
    } else {
      text(field(field(catalog, "libraries"), "simple"))
    }
    reports.push(
      @sta.check_netlist_references(
        @liberty.load_library(source),
        @sta.netlist_from_json(field(fixture, "netlist")),
      ),
    )
  }
  println(ToJson::to_json(reports).stringify())
}
