///|
/// Existing structural diagnostic decoder followed by standalone reference
/// checks. Findings are ok:true reports; parsing/IO is a different boundary.
pub fn check_netlist_references_json(
  liberty_text : String,
  netlist_text : String,
) -> String {
  let result : Json = try {
    let value = @json.parse(netlist_text) catch {
      _ => raise InvalidInput("invalid netlist JSON")
    }
    let netlist = netlist_from_json_with_diagnostics(value)
    let library = @liberty.load_library(liberty_text) catch {
      @liberty.LibertyError(code, message, _) =>
        raise LibraryFailure(code + ": " + message)
    }
    {
      "ok": true,
      "schema": "moonbit.sta.references.v1",
      "references": ToJson::to_json(check_netlist_references(library, netlist)),
    }
  } catch {
    NetlistJsonDiagnostic(error, pointer) =>
      {
        "ok": false,
        "schema": "moonbit.sta.references.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
        "pointer": pointer,
      }
    error =>
      {
        "ok": false,
        "schema": "moonbit.sta.references.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
        "pointer": null,
      }
  }
  result.stringify()
}
