///|
/// Check a standalone netlist JSON object and verbatim restricted SDC text.
/// This parses/binds constraints; it does not run STA or validate the full graph.
/// The separate schema leaves analyze_json's error/output contract unchanged.
pub fn check_sdc_json(
  liberty_text : String,
  netlist_text : String,
  sdc_text : String,
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
    let constraints = parse_sdc_with_diagnostics(sdc_text, library, netlist)
    {
      "ok": true,
      "schema": "moonbit.sta.sdc.v1",
      "constraints": ToJson::to_json(constraints),
    }
  } catch {
    SdcDiagnostic(error, position) =>
      {
        "ok": false,
        "schema": "moonbit.sta.sdc.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
        "position": match position {
          Some(position) => ToJson::to_json(position)
          None => null
        },
      }
    error =>
      {
        "ok": false,
        "schema": "moonbit.sta.sdc.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
        "position": null,
      }
  }
  result.stringify()
}
