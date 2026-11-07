///|
fn query_json_edge(point : Json) -> Edge raise STAError {
  match point {
    { "edge": String("rise"), .. } => Rise
    { "edge": String("fall"), .. } => Fall
    _ => raise InvalidInput("query edge must be rise or fall")
  }
}

///|
fn query_json_launch(point : Json) -> PathLaunch raise STAError {
  let edge = query_json_edge(point)
  match point {
    { "kind": String("input_port"), "name": String(name), .. } =>
      InputPort(name, edge)
    {
      "kind": String("register_q"),
      "instance": String(instance),
      "pin": String(pin),
      ..
    } => RegisterQ(instance, pin, edge)
    _ =>
      raise InvalidInput(
        "query launch kind/name must be input_port or register_q",
      )
  }
}

///|
fn query_json_capture(point : Json) -> PathCapture raise STAError {
  let edge = query_json_edge(point)
  match point {
    { "kind": String("output_port"), "name": String(name), .. } =>
      OutputPort(name, edge)
    {
      "kind": String("register_d"),
      "instance": String(instance),
      "pin": String(pin),
      ..
    } => RegisterD(instance, pin, edge)
    _ =>
      raise InvalidInput(
        "query capture kind/name must be output_port or register_d",
      )
  }
}

///|
/// Four decoded texts. Old analysis schemas and flags are unchanged.
pub fn analyze_path_query_json(
  liberty_text : String,
  netlist_text : String,
  sdc_text : String,
  query_text : String,
) -> String {
  let result : Json = try {
    let decoded = @json.parse(netlist_text) catch {
      _ => raise InvalidInput("invalid netlist JSON")
    }
    let netlist = netlist_from_json(decoded)
    let library = @liberty.load_library(liberty_text) catch {
      @liberty.LibertyError(code, message, _) =>
        raise LibraryFailure(code + ": " + message)
    }
    let constraints = parse_sdc(sdc_text, library, netlist)
    let decoded_query = @json.parse(query_text) catch {
      _ => raise InvalidInput("invalid path query JSON")
    }
    let query : PathQuery = {
      launch: query_json_launch(json_field(decoded_query, "from")),
      capture: query_json_capture(json_field(decoded_query, "to")),
    }
    let policy = match decoded_query {
      { "range_policy": String("reject"), .. } => @liberty.Reject
      { "range_policy": String("clamp"), .. } => @liberty.Clamp
      { "range_policy": String("extrapolate"), .. } => @liberty.Extrapolate
      { "range_policy": _, .. } => raise InvalidInput("unknown range_policy")
      _ => @liberty.Extrapolate
    }
    let analysis = STAEngine::new(library, netlist, constraints, policy~).run_setup_path_query(
      query,
    )
    {
      "ok": true,
      "schema": "moonbit.sta.path-query.v1",
      "result": ToJson::to_json(analysis.timing),
      "path_query": ToJson::to_json(analysis.path_query),
    }
  } catch {
    error =>
      {
        "ok": false,
        "schema": "moonbit.sta.path-query.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
      }
  }
  result.stringify()
}

///|
/// A JSON object with a queries array and optional range_policy. Each array
/// item has the same from/to shape as the single-query JSON entry point.
pub fn analyze_path_queries_json(
  liberty_text : String,
  netlist_text : String,
  sdc_text : String,
  queries_text : String,
) -> String {
  let result : Json = try {
    let decoded = @json.parse(netlist_text) catch {
      _ => raise InvalidInput("invalid netlist JSON")
    }
    let netlist = netlist_from_json(decoded)
    let library = @liberty.load_library(liberty_text) catch {
      @liberty.LibertyError(code, message, _) =>
        raise LibraryFailure(code + ": " + message)
    }
    let constraints = parse_sdc(sdc_text, library, netlist)
    let decoded_batch = @json.parse(queries_text) catch {
      _ => raise InvalidInput("invalid path queries JSON")
    }
    let items = json_array(json_field(decoded_batch, "queries"))
    if items.length() > 1024 {
      raise InvalidInput("path query batch limit exceeded")
    }
    let queries : Array[PathQuery] = items.map(item => {
      launch: query_json_launch(json_field(item, "from")),
      capture: query_json_capture(json_field(item, "to")),
    })
    let policy = match decoded_batch {
      { "range_policy": String("reject"), .. } => @liberty.Reject
      { "range_policy": String("clamp"), .. } => @liberty.Clamp
      { "range_policy": String("extrapolate"), .. } => @liberty.Extrapolate
      { "range_policy": _, .. } => raise InvalidInput("unknown range_policy")
      _ => @liberty.Extrapolate
    }
    let analysis = STAEngine::new(library, netlist, constraints, policy~).run_setup_path_queries(
      queries,
    )
    {
      "ok": true,
      "schema": "moonbit.sta.path-queries.v1",
      "result": ToJson::to_json(analysis.timing),
      "path_queries": ToJson::to_json(analysis.path_queries),
    }
  } catch {
    error =>
      {
        "ok": false,
        "schema": "moonbit.sta.path-queries.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
      }
  }
  result.stringify()
}
