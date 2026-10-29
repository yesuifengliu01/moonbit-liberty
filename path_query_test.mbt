///|
fn pqt_field(value : Json, key : String) -> Json {
  match value {
    Object(fields) => fields[key]
    _ => abort("expected fixture object")
  }
}

///|
fn pqt_text(value : Json) -> String {
  match value {
    String(text) => text
    _ => abort("expected fixture string")
  }
}

///|
fn pqt_array(value : Json) -> Array[Json] {
  match value {
    Array(values) => values
    _ => abort("expected fixture array")
  }
}

///|
fn pqt_number(value : Json) -> Double {
  match value {
    Number(number, ..) => number
    _ => abort("expected fixture number")
  }
}

///|
fn pqt_optional_number(
  actual : Json,
  expected : Json,
  key : String,
) -> Unit raise {
  let expected = pqt_field(expected, key)
  guard actual is Object(fields) else { fail("query object required") }
  if expected is Null {
    assert_true(!fields.contains(key))
  } else {
    near(pqt_number(fields[key]), pqt_number(expected), tolerance=1.0e-21)
  }
}

///|
fn pqt_engine(
  catalog : Json,
  library? : String = "base",
  netlist? : String = "base",
  sdc? : String = "base",
) -> @sta.STAEngine raise {
  let library = @liberty.load_library(
    pqt_text(pqt_field(pqt_field(catalog, "libraries"), library)),
  )
  let netlist = @sta.netlist_from_json(
    pqt_field(pqt_field(catalog, "netlists"), netlist),
  )
  let constraints = @sta.parse_sdc(
    pqt_text(pqt_field(pqt_field(catalog, "sdc"), sdc)),
    library,
    netlist,
  )
  @sta.STAEngine::new(library, netlist, constraints)
}

///|
test "path query matches all frozen hand paths times statuses and errors" {
  let catalog = @json.parse(@testdata.path_query_cases())
  let cases = pqt_array(pqt_field(catalog, "cases"))
  assert_eq(cases.length(), 39)
  for fixture in cases {
    let expected = pqt_field(fixture, "expected")
    let result = @json.parse(
      @sta.analyze_path_query_json(
        pqt_text(
          pqt_field(
            pqt_field(catalog, "libraries"),
            pqt_text(pqt_field(fixture, "library")),
          ),
        ),
        pqt_field(
          pqt_field(catalog, "netlists"),
          pqt_text(pqt_field(fixture, "netlist")),
        ).stringify(),
        pqt_text(
          pqt_field(
            pqt_field(catalog, "sdc"),
            pqt_text(pqt_field(fixture, "sdc")),
          ),
        ),
        pqt_field(fixture, "query").stringify(),
      ),
    )
    assert_eq(pqt_field(result, "schema"), "moonbit.sta.path-query.v1")
    if expected is { "error": String(message), .. } {
      assert_eq(pqt_field(result, "ok"), false)
      assert_true(pqt_text(pqt_field(result, "error")).contains(message))
      continue
    }
    assert_eq(pqt_field(result, "ok"), true)
    let queried = pqt_field(result, "path_query")
    assert_eq(pqt_field(queried, "status"), pqt_field(expected, "status"))
    let path = pqt_array(pqt_field(queried, "path"))
    if pqt_field(expected, "status") != "Found" {
      assert_true(path.is_empty())
      guard queried is Object(fields) else { fail("query object") }
      for
        key in [
          "queried_arrival_seconds", "required_seconds", "queried_slack_seconds",
        ] {
        assert_true(!fields.contains(key))
      }
      continue
    }
    for
      key in [
        "queried_arrival_seconds", "required_seconds", "queried_slack_seconds",
      ] {
      pqt_optional_number(queried, expected, key)
    }
    let pins = pqt_array(pqt_field(expected, "pins"))
    let edges = pqt_array(pqt_field(expected, "edges"))
    let arcs = pqt_array(pqt_field(expected, "arcs"))
    let delays = pqt_array(pqt_field(expected, "delays_seconds"))
    let arrivals = pqt_array(pqt_field(expected, "arrivals_seconds"))
    assert_eq(path.length(), pins.length())
    for i, step in path {
      assert_eq(pqt_field(step, "pin"), pins[i])
      assert_eq(pqt_field(step, "edge"), edges[i])
      assert_eq(pqt_field(step, "arc"), arcs[i])
      near(
        pqt_number(pqt_field(step, "delay_seconds")),
        pqt_number(delays[i]),
        tolerance=1.0e-21,
      )
      near(
        pqt_number(pqt_field(step, "arrival_seconds")),
        pqt_number(arrivals[i]),
        tolerance=1.0e-21,
      )
    }
  }
}

///|
test "path query typed losing branch is distinct from identical global winners" {
  let catalog = @json.parse(@testdata.path_query_cases())
  let query : @sta.PathQuery = {
    launch: InputPort("b", Rise),
    capture: OutputPort("out", Rise),
  }
  let original = pqt_engine(catalog).run_setup_path_query(query)
  let changed = pqt_engine(catalog, library="changed").run_setup_path_query(
    query,
  )
  assert_eq(ToJson::to_json(original.timing), ToJson::to_json(changed.timing))
  assert_eq(original.path_query.status, @sta.Found)
  near(original.path_query.queried_arrival_seconds.unwrap(), 0.8e-9)
  near(original.path_query.queried_slack_seconds.unwrap(), 1.0e-9)
  near(changed.path_query.queried_arrival_seconds.unwrap(), 1.0e-9)
  near(changed.path_query.queried_slack_seconds.unwrap(), 0.8e-9)
  assert_eq(original.path_query.path.map(step => step.pin), [
    "b", "g/B", "g/Y", "h/A", "h/Y", "out",
  ])
  near(original.timing.worst_slack_seconds.unwrap(), 0.3e-9)
}

///|
test "path query typed endpoint roles and error precedence" {
  let catalog = @json.parse(@testdata.path_query_cases())
  let engine = pqt_engine(catalog)
  try
    engine.run_setup_path_query({
      launch: InputPort("absent", Rise),
      capture: OutputPort("absent", Rise),
    })
  catch {
    e =>
      assert_true("\{@debug.Debug::to_repr(e)}".contains("invalid path launch"))
  } noraise {
    _ => fail("invalid launch accepted")
  }
  let sequential = pqt_engine(catalog, netlist="sequential", sdc="sequential")
  try
    sequential.run_setup_path_query({
      launch: RegisterQ("f0", "D", Rise),
      capture: OutputPort("y", Rise),
    })
  catch {
    e =>
      assert_true("\{@debug.Debug::to_repr(e)}".contains("invalid path launch"))
  } noraise {
    _ => fail("D accepted as launch")
  }
  try
    sequential.run_setup_path_query({
      launch: RegisterQ("f0", "Q", Rise),
      capture: RegisterD("f1", "Q", Rise),
    })
  catch {
    e =>
      assert_true(
        "\{@debug.Debug::to_repr(e)}".contains("invalid path capture"),
      )
  } noraise {
    _ => fail("Q accepted as capture")
  }
}

///|
test "path query reachability precedes unknown arrival and sequential launch cuts" {
  let catalog = @json.parse(@testdata.path_query_cases())
  let engine = pqt_engine(catalog, sdc="unknown_launch")
  let unknown = engine.run_setup_path_query({
      launch: InputPort("b", Rise),
      capture: OutputPort("out", Rise),
    }).path_query
  assert_eq(unknown.status, @sta.UnconstrainedLaunch)
  assert_true(
    unknown.path.is_empty() && unknown.queried_arrival_seconds is None,
  )
  let blocked_path = engine.run_setup_path_query({
      launch: InputPort("b", Rise),
      capture: OutputPort("out", Fall),
    }).path_query
  assert_eq(blocked_path.status, @sta.NoPath)
  let sequential = pqt_engine(catalog, netlist="sequential", sdc="sequential")
  let cut = sequential.run_setup_path_query({
      launch: InputPort("a", Rise),
      capture: RegisterD("f1", "D", Rise),
    }).path_query
  assert_eq(cut.status, @sta.NoPath)
  let launched = sequential.run_setup_path_query({
      launch: RegisterQ("f0", "Q", Fall),
      capture: RegisterD("f1", "D", Fall),
    }).path_query
  assert_eq(launched.status, @sta.Found)
  near(launched.queried_slack_seconds.unwrap(), 1.3e-9, tolerance=1.0e-21)
  assert_eq(launched.path[0].pin, "f0/CLK")
  assert_eq(launched.path[1].pin, "f0/Q")
}

///|
test "path query owned path leaves original report and subsequent calls intact" {
  let catalog = @json.parse(@testdata.path_query_cases())
  let engine = pqt_engine(catalog)
  let query : @sta.PathQuery = {
    launch: InputPort("b", Rise),
    capture: OutputPort("out", Rise),
  }
  let analysis = engine.run_setup_path_query(query)
  analysis.path_query.path[0] = {
    ..analysis.path_query.path[0],
    pin: "changed",
  }
  assert_eq(node(analysis.timing, "b", Rise).path[0].pin, "b")
  assert_eq(engine.run_setup_path_query(query).path_query.path[0].pin, "b")
  assert_eq(endpoint(analysis.timing, "out", Rise).path[0].pin, "a")
}
