///|
fn cycle_test_field(value : Json, key : String) -> Json {
  guard value is Object(fields) else { abort("fixture object") }
  fields[key]
}

///|
fn cycle_test_text(value : Json) -> String {
  guard value is String(text) else { abort("fixture text") }
  text
}

///|
fn cycle_test_catalog() -> (Json, Array[Json]) raise {
  let catalog = @json.parse(@testdata.cycle_diagnosis_cases())
  guard cycle_test_field(catalog, "cases") is Array(cases) else {
    abort("fixture cases")
  }
  (catalog, cases)
}

///|
fn cycle_test_engine(
  catalog : Json,
  case : Json,
) -> (@sta.STAEngine, @sta.Netlist, @sta.TimingConstraints) raise {
  let library = @liberty.load_library(
    cycle_test_text(
      cycle_test_field(
        cycle_test_field(catalog, "libraries"),
        cycle_test_text(cycle_test_field(case, "library")),
      ),
    ),
  )
  let request = @json.parse(cycle_test_text(cycle_test_field(case, "request")))
  let netlist = @sta.netlist_from_json(cycle_test_field(request, "netlist"))
  let constraints = @sta.parse_sdc(
    cycle_test_text(cycle_test_field(request, "sdc")),
    library,
    netlist,
  )
  (@sta.STAEngine::new(library, netlist, constraints), netlist, constraints)
}

///|
fn main raise {
  let (catalog, cases) = cycle_test_catalog()
  let outputs : Array[Json] = []
  for case in cases {
    let (engine, netlist, constraints) = cycle_test_engine(catalog, case)
    let before_netlist = ToJson::to_json(netlist)
    let before_constraints = ToJson::to_json(constraints)
    let observed : Json = try {
      let timing = engine.run_setup_analysis()
      { "kind": "Success", "timing": ToJson::to_json(timing) }
    } catch {
      @sta.CombinationalLoopDetected(names) =>
        {
          "kind": "CombinationalLoopDetected",
          "instances": ToJson::to_json(names),
        }
      error =>
        { "kind": "OtherError", "error": "\{@debug.Debug::to_repr(error)}" }
    }
    outputs.push({
      "name": cycle_test_field(case, "name"),
      "observed": observed,
      "netlist_unchanged": ToJson::to_json(netlist) == before_netlist,
      "constraints_unchanged": ToJson::to_json(constraints) ==
      before_constraints,
    })
  }
  let primary = cases
    .iter()
    .find_first(case => cycle_test_field(case, "primary") == true)
    .unwrap()
  let (engine, _, _) = cycle_test_engine(catalog, primary)
  let query : @sta.PathQuery = {
    launch: @sta.InputPort("a", @sta.Rise),
    capture: @sta.OutputPort("out", @sta.Rise),
  }
  let methods : Array[Json] = []
  for operation in ["setup", "period", "pin-limits", "context", "path-query"] {
    let observed : Json = try {
      match operation {
        "setup" => {
          let _ = engine.run_setup_analysis()
        }
        "period" => {
          let _ = engine.run_period_analysis()
        }
        "pin-limits" => {
          let _ = engine.run_pin_limit_analysis()
        }
        "context" => {
          let _ = engine.run_setup_with_constraint_context()
        }
        _ => {
          let _ = engine.run_setup_path_query(query)
        }
      }
      { "kind": "unexpected_success" }
    } catch {
      @sta.CombinationalLoopDetected(names) =>
        {
          "kind": "CombinationalLoopDetected",
          "instances": ToJson::to_json(names),
        }
      error =>
        { "kind": "OtherError", "error": "\{@debug.Debug::to_repr(error)}" }
    }
    methods.push({ "name": operation, "observed": observed })
  }
  println(
    (
      { "cases": ToJson::to_json(outputs), "methods": ToJson::to_json(methods) } :
      Json).stringify(),
  )
}
