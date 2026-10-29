///|
fn field(value : Json, key : String) -> Json {
  match value {
    Object(fields) => fields[key]
    _ => abort("fixture object required")
  }
}

///|
fn text(value : Json) -> String {
  match value {
    String(value) => value
    _ => abort("fixture string required")
  }
}

///|
fn engine(
  catalog : Json,
  library : String,
  design : String,
  sdc : String,
) -> @sta.STAEngine raise {
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
  @sta.STAEngine::new(library, netlist, constraints)
}

///|
/// A separate executable package consuming only the public typed STA API.
fn main raise {
  let catalog = @json.parse(@testdata.path_query_cases())
  let query : @sta.PathQuery = {
    launch: InputPort("b", Rise),
    capture: OutputPort("out", Rise),
  }
  let base = engine(catalog, "base", "base", "base").run_setup_path_query(query)
  let changed = engine(catalog, "changed", "base", "base").run_setup_path_query(
    query,
  )
  let no_path = engine(catalog, "base", "inv", "base").run_setup_path_query(
    query,
  )
  let unknown = engine(catalog, "base", "base", "unknown_launch").run_setup_path_query(
    query,
  )
  let sequential = engine(catalog, "base", "sequential", "sequential").run_setup_path_query({
      launch: RegisterQ("f0", "Q", Rise),
      capture: RegisterD("f1", "D", Rise),
    },
  )
  println(
    ToJson::to_json([base, changed, no_path, unknown, sequential]).stringify(),
  )
}
