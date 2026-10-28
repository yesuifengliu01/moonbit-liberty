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
