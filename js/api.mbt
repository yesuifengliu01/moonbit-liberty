///|
// A decoded file signature is metadata only at the start of the whole text.
fn without_initial_bom(text : String) -> String {
  if !text.is_empty() && text[0] == 0xFEFF {
    text[1:].to_owned()
  } else {
    text
  }
}

///|
/// Existing-report priority query; optional initial file BOM only.
pub fn prioritize_setup_json(report : String, max_endpoints : Double) -> String {
  @sta.prioritize_setup_json(without_initial_bom(report), max_endpoints)
}

///|
/// Compare two existing success-report files, each with an optional file BOM.
pub fn compare_setup_json(
  baseline : String,
  candidate : String,
  max_slack_loss_seconds : Double,
) -> String {
  @sta.compare_setup_json(
    without_initial_bom(baseline),
    without_initial_bom(candidate),
    max_slack_loss_seconds,
  )
}

///|
/// Scalar reference preflight; decoded files accept one initial BOM each.
pub fn check_netlist_references_json(
  library : String,
  netlist : String,
) -> String {
  @sta.check_netlist_references_json(
    without_initial_bom(library),
    without_initial_bom(netlist),
  )
}

///|
/// Standalone declared-cell census; both UTF-8 files accept an initial BOM.
pub fn analyze_cell_usage_json(library : String, netlist : String) -> String {
  @sta.analyze_cell_usage_json(
    without_initial_bom(library),
    without_initial_bom(netlist),
  )
}

///|
/// Three UTF-8 decoded files plus the existing NLDM policy name; SDC verbatim.
pub fn analyze_pin_limits_json(
  library : String,
  netlist : String,
  sdc : String,
  range_policy : String,
) -> String {
  @sta.analyze_pin_limits_json(
    without_initial_bom(library),
    without_initial_bom(netlist),
    sdc,
    range_policy,
  )
}

///|
/// Query files accept one initial BOM; SDC remains verbatim.
pub fn analyze_path_query_json(
  library : String,
  netlist : String,
  sdc : String,
  query : String,
) -> String {
  @sta.analyze_path_query_json(
    without_initial_bom(library),
    without_initial_bom(netlist),
    sdc,
    without_initial_bom(query),
  )
}

///|
/// Standalone Netlist structural checking with optional initial file BOM.
pub fn check_netlist_json(netlist : String) -> String {
  @sta.check_netlist_json(without_initial_bom(netlist))
}

///|
/// Preserve SDC verbatim while accepting the existing library/netlist file BOM.
pub fn analyze_constraint_context_json(
  library : String,
  netlist : String,
  sdc : String,
) -> String {
  @sta.analyze_constraint_context_json(
    without_initial_bom(library),
    without_initial_bom(netlist),
    sdc,
  )
}

///|
/// Standalone SDC-file checking. Preserve SDC source units exactly for positions.
pub fn check_sdc_json(
  library : String,
  netlist : String,
  sdc : String,
) -> String {
  @sta.check_sdc_json(
    without_initial_bom(library),
    without_initial_bom(netlist),
    sdc,
  )
}

///|
/// JavaScript export adapter; domain computation belongs to the root package.
pub fn analyze_json(library : String, request : String) -> String {
  @sta.analyze_json(without_initial_bom(library), without_initial_bom(request))
}

///|
/// Request the existing summary for an explicit host setup check. Invalid JSON,
/// non-objects and invalid flag types retain the normal core error behavior.
pub fn analyze_json_for_setup_check(
  library : String,
  request : String,
) -> String {
  let library = without_initial_bom(library)
  let request = without_initial_bom(request)
  let decoded = @json.parse(request) catch {
    _ => return @sta.analyze_json(library, request)
  }
  match decoded {
    Object(fields) =>
      match fields.get("setup_summary") {
        None | Some(True) | Some(False) => {
          fields["setup_summary"] = Json::boolean(true)
          let normalized = Json::object(fields)
          @sta.analyze_json(library, normalized.stringify())
        }
        _ => @sta.analyze_json(library, request)
      }
    _ => @sta.analyze_json(library, request)
  }
}
