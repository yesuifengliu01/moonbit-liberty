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
/// A separate package uses only the public typed census, not the JSON adapter.
fn main raise {
  let catalog = @json.parse(@testdata.cell_usage_cases())
  guard field(catalog, "cases") is Array(cases) else { abort("cases") }
  let reports : Array[@sta.CellUsageReport] = []
  for
    name in [
      "complete-no-timing", "mixed-coverage", "zero-area", "subtotal-overflow", "real-sky130",
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
    let library = @liberty.load_library(source)
    let netlist = @sta.netlist_from_json(field(fixture, "netlist"))
    reports.push(@sta.analyze_cell_usage(library, netlist))
  }
  println(ToJson::to_json(reports).stringify())
}
