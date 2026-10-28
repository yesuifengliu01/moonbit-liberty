///|
/// Start of a failing restricted-SDC command, not the exact bad token.
/// Line/column are 1-based; column/offset count UTF-16 code units.
/// Offset is 0-based in the original String. LF starts a new line, CRLF
/// contributes two offset units, and a tab contributes one column unit.
pub(all) struct SdcSourcePosition {
  line : Int
  column : Int
  offset : Int
} derive(Debug, Eq, ToJson)

///|
/// The original typed parser error and an optional command-start position.
/// Text-budget, library-precondition and missing-clock errors have no position.
pub suberror SdcDiagnostic {
  SdcDiagnostic(STAError, SdcSourcePosition?)
} derive(Debug)

///|
priv struct SdcCursor {
  mut position : SdcSourcePosition?
}

///|
/// Parse the same profile as `parse_sdc`, retaining the original error inside
/// a source diagnostic. Source is not normalized, including Unicode and CRLF.
pub fn parse_sdc_with_diagnostics(
  text : String,
  library : @liberty.Library,
  netlist : Netlist,
) -> TimingConstraints raise SdcDiagnostic {
  let cursor : SdcCursor = { position: None, }
  parse_sdc_impl(text, library, netlist, Some(cursor)) catch {
    error => raise SdcDiagnostic(error, cursor.position)
  }
}
