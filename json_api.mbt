///|
fn json_field(j : Json, key : String) -> Json raise STAError {
  match j {
    Object(m) =>
      match m.get(key) {
        Some(v) => v
        None => raise InvalidInput("missing JSON field " + key)
      }
    _ => raise InvalidInput("JSON object required")
  }
}

///|
fn json_string(j : Json) -> String raise STAError {
  match j {
    String(s) => s
    _ => raise InvalidInput("JSON string required")
  }
}

///|
fn json_array(j : Json) -> Array[Json] raise STAError {
  match j {
    Array(a) => a
    _ => raise InvalidInput("JSON array required")
  }
}

///|
pub fn netlist_from_json(j : Json) -> Netlist raise STAError {
  netlist_from_json_impl(j, None)
}

///|
fn netlist_from_json_impl(
  j : Json,
  cursor : NetlistJsonCursor?,
) -> Netlist raise STAError {
  let ports = json_array(netlist_json_field(j, "ports", "", cursor)).mapi((i, p) => {
    let path = if cursor is Some(_) { "/ports/" + i.to_string() } else { "" }
    let direction = match
      json_string(netlist_json_field(p, "direction", path, cursor)) {
      "input" | "Input" => Input
      "output" | "Output" => Output
      _ => raise InvalidInput("JSON port direction")
    }
    {
      name: json_string(netlist_json_field(p, "name", path, cursor)),
      net: json_string(netlist_json_field(p, "net", path, cursor)),
      direction,
    }
  })
  let gates = json_array(netlist_json_field(j, "gates", "", cursor)).mapi((i, g) => {
    let path = if cursor is Some(_) { "/gates/" + i.to_string() } else { "" }
    let connections = json_array(
      netlist_json_field(g, "connections", path, cursor),
    ).mapi((k, c) => {
      let connection_path = if cursor is Some(_) {
        path + "/connections/" + k.to_string()
      } else {
        ""
      }
      {
        pin: json_string(netlist_json_field(c, "pin", connection_path, cursor)),
        net: json_string(netlist_json_field(c, "net", connection_path, cursor)),
      }
    })
    {
      name: json_string(netlist_json_field(g, "name", path, cursor)),
      cell: json_string(netlist_json_field(g, "cell", path, cursor)),
      connections,
    }
  })
  let nets = json_array(netlist_json_field(j, "nets", "", cursor)).mapi((i, n) => {
    let path = if cursor is Some(_) { "/nets/" + i.to_string() } else { "" }
    let cap = match netlist_json_field(n, "wire_cap_farads", path, cursor) {
      Number(v, ..) => v
      _ => raise InvalidInput("JSON wire capacitance number")
    }
    {
      name: json_string(netlist_json_field(n, "name", path, cursor)),
      wire_cap_farads: cap,
    }
  })
  { ports, gates, nets, }
}

///|
/// Host-friendly JSON boundary. The request contains netlist, sdc, and optional
/// range_policy (extrapolate/reject/clamp). Times in the result are seconds.
pub fn analyze_json(liberty_text : String, request_text : String) -> String {
  let result : Json = try {
    let request = @json.parse(request_text) catch {
      _ => raise InvalidInput("invalid request JSON")
    }
    let netlist = netlist_from_json(json_field(request, "netlist"))
    let library = @liberty.load_library(liberty_text) catch {
      @liberty.LibertyError(code, message, _) =>
        raise LibraryFailure(code + ": " + message)
    }
    let constraints = parse_sdc(
      json_string(json_field(request, "sdc")),
      library,
      netlist,
    )
    let policy = match request {
      { "range_policy": String("reject"), .. } => @liberty.Reject
      { "range_policy": String("clamp"), .. } => @liberty.Clamp
      { "range_policy": String("extrapolate"), .. } => @liberty.Extrapolate
      { "range_policy": _, .. } => raise InvalidInput("unknown range_policy")
      _ => @liberty.Extrapolate
    }
    let want_budget = match request {
      { "period_budget": True, .. } => true
      { "period_budget": False, .. } => false
      { "period_budget": _, .. } =>
        raise InvalidInput("period_budget must be boolean")
      _ => false
    }
    let want_summary = match request {
      { "setup_summary": True, .. } => true
      { "setup_summary": False, .. } => false
      { "setup_summary": _, .. } =>
        raise InvalidInput("setup_summary must be boolean")
      _ => false
    }
    let engine = STAEngine::new(library, netlist, constraints, policy~)
    if want_budget {
      let analysis = engine.run_period_analysis()
      if want_summary {
        {
          "ok": true,
          "schema": "moonbit.sta.v1",
          "result": ToJson::to_json(analysis.timing),
          "period_budget": ToJson::to_json(analysis.budget),
          "setup_summary": ToJson::to_json(analysis.timing.setup_summary()),
        }
      } else {
        {
          "ok": true,
          "schema": "moonbit.sta.v1",
          "result": ToJson::to_json(analysis.timing),
          "period_budget": ToJson::to_json(analysis.budget),
        }
      }
    } else {
      let report = engine.run_setup_analysis()
      if want_summary {
        {
          "ok": true,
          "schema": "moonbit.sta.v1",
          "result": ToJson::to_json(report),
          "setup_summary": ToJson::to_json(report.setup_summary()),
        }
      } else {
        {
          "ok": true,
          "schema": "moonbit.sta.v1",
          "result": ToJson::to_json(report),
        }
      }
    }
  } catch {
    e =>
      {
        "ok": false,
        "schema": "moonbit.sta.v1",
        "error": "\{@debug.Debug::to_repr(e)}",
      }
  }
  result.stringify()
}
