///|
/// Existing Liberty and Netlist JSON texts, with no SDC or timing requirement.
pub fn analyze_cell_usage_json(
  liberty_text : String,
  netlist_text : String,
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
    {
      "ok": true,
      "schema": "moonbit.sta.cell-usage.v1",
      "usage": ToJson::to_json(analyze_cell_usage(library, netlist)),
    }
  } catch {
    error =>
      {
        "ok": false,
        "schema": "moonbit.sta.cell-usage.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
      }
  }
  result.stringify()
}
