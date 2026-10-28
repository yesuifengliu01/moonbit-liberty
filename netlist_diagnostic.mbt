///|
/// Original structural decode error and a semantic JSON Pointer relative to
/// the standalone Netlist root. Empty string is root; array indices are 0-based.
/// Missing fields point to the intended child; non-object values to themselves.
/// This is not a source character span. Unknown fields remain ignored.
pub suberror NetlistJsonDiagnostic {
  NetlistJsonDiagnostic(STAError, String)
} derive(Debug)

///|
priv struct NetlistJsonCursor {
  mut pointer : String
}

///|
// Only existing ASCII schema keys and decimal array indices form these paths.
// Keep the old field helper as the sole source of field/object errors.
fn netlist_json_field(
  value : Json,
  key : String,
  parent : String,
  cursor : NetlistJsonCursor?,
) -> Json raise STAError {
  if cursor is Some(cursor) {
    cursor.pointer = match value {
      Object(_) => parent + "/" + key
      _ => parent
    }
  }
  json_field(value, key)
}

///|
/// Decode exactly the same structure and values as `netlist_from_json`, with
/// the first error's semantic pointer. Field read order is preserved: ports
/// before gates before nets; direction before port name/net; gate connections
/// (pin before net) before name/cell; net capacitance before name. Arrays ascend.
/// Does not validate a complete timing graph or change numeric acceptance.
pub fn netlist_from_json_with_diagnostics(
  value : Json,
) -> Netlist raise NetlistJsonDiagnostic {
  let cursor : NetlistJsonCursor = { pointer: "", }
  netlist_from_json_impl(value, Some(cursor)) catch {
    error => raise NetlistJsonDiagnostic(error, cursor.pointer)
  }
}

///|
/// Standalone structural JSON-file boundary, separate from analysis and SDC.
/// Syntax errors have null pointer; a decoded wrong root has empty-string root.
pub fn check_netlist_json(text : String) -> String {
  let result : Json = try {
    let value = @json.parse(text) catch {
      _ => raise InvalidInput("invalid netlist JSON")
    }
    ignore(netlist_from_json_with_diagnostics(value))
    { "ok": true, "schema": "moonbit.sta.netlist.v1" }
  } catch {
    NetlistJsonDiagnostic(error, pointer) =>
      {
        "ok": false,
        "schema": "moonbit.sta.netlist.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
        "pointer": pointer,
      }
    error =>
      {
        "ok": false,
        "schema": "moonbit.sta.netlist.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
        "pointer": null,
      }
  }
  result.stringify()
}
