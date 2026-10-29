///|
/// Existing three input texts and an explicit existing NLDM policy token.
pub fn analyze_pin_limits_json(
  liberty_text : String,
  netlist_text : String,
  sdc_text : String,
  range_policy : String,
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
    let policy = match range_policy {
      "reject" => @liberty.Reject
      "clamp" => @liberty.Clamp
      "extrapolate" => @liberty.Extrapolate
      _ => raise InvalidInput("unknown range_policy")
    }
    let analysis = STAEngine::new(library, netlist, constraints, policy~).run_pin_limit_analysis()
    {
      "ok": true,
      "schema": "moonbit.sta.pin-limits.v1",
      "result": ToJson::to_json(analysis.timing),
      "pin_limits": ToJson::to_json(analysis.pin_limits),
    }
  } catch {
    error =>
      {
        "ok": false,
        "schema": "moonbit.sta.pin-limits.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
      }
  }
  result.stringify()
}
