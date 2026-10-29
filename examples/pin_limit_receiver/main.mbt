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
    String(text) => text
    _ => abort("fixture string")
  }
}

///|
fn consume(
  catalog : Json,
  library : String,
  design : String,
  sdc : String,
) -> @sta.PinLimitAnalysis raise {
  let library = @liberty.load_library(
    text(field(field(catalog, "libraries"), library)),
  )
  let netlist = @sta.netlist_from_json(
    field(field(catalog, "netlists"), design),
  )
  let constraints = @sta.parse_sdc(
    text(field(field(catalog, "sdc"), sdc)),
    library,
    netlist,
  )
  @sta.STAEngine::new(library, netlist, constraints, policy=@liberty.Reject).run_pin_limit_analysis()
}

///|
/// Separate package: only public STA/library APIs and frozen input literals.
fn main raise {
  let catalog = @json.parse(@testdata.pin_limit_cases())
  println(
    ToJson::to_json([
      consume(catalog, "strict", "base", "base"),
      consume(catalog, "met", "base", "base"),
      consume(catalog, "no_limits", "base", "base"),
      consume(catalog, "invalid_default", "base", "base"),
      consume(catalog, "strict", "ff", "ff"),
    ]).stringify(),
  )
}
