///|
/// Consume the original success-report endpoint view, without running timing.
/// A Double limit lets the JS boundary reject fractional/nonfinite values before
/// conversion to MoonBit Int; the typed API accepts a nonnegative Int directly.
pub fn prioritize_setup_json(
  report_text : String,
  max_endpoints : Double,
) -> String {
  let result : Json = try {
    if !finite(max_endpoints) ||
      max_endpoints < 0.0 ||
      max_endpoints > 2147483647.0 ||
      max_endpoints.to_int().to_double() != max_endpoints {
      raise InvalidInput("max_endpoints must be an integer in 0..2147483647")
    }
    let snapshots = setup_report_snapshots(report_text, "source")
    {
      "ok": true,
      "schema": "moonbit.sta.setup-priority.v1",
      "priorities": ToJson::to_json(
        prioritize_setup_snapshots(snapshots, max_endpoints.to_int()),
      ),
    }
  } catch {
    error =>
      {
        "ok": false,
        "schema": "moonbit.sta.setup-priority.v1",
        "error": "\{@debug.Debug::to_repr(error)}",
      }
  }
  result.stringify()
}
