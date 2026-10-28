///|
/// Three-text context boundary using the default Extrapolate setup policy.
/// It explains existing unknown endpoint edges; it does not run period analysis
/// or turn successful analysis into a constraint-completeness certificate.
pub fn analyze_constraint_context_json(
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
    let constraints = parse_sdc(sdc_text, library, netlist)
    let analysis = STAEngine::new(library, netlist, constraints).run_setup_with_constraint_context()
    {
      "ok": true,
      "schema": "moonbit.sta.constraint-context.v1",
      "result": ToJson::to_json(analysis.timing),
      "setup_summary": ToJson::to_json(analysis.timing.setup_summary()),
      "constraint_context": ToJson::to_json(analysis.constraint_context),
    }
  } catch {
    error =>
      {
        "ok": false,
        "schema": "moonbit.sta.constraint-context.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
      }
  }
  result.stringify()
}
