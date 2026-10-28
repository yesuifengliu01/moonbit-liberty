///|
pub(all) enum SetupSummaryStatus {
  Met
  Violated
  PartialCoverage
  NoCoverage
  NoEndpoints
} derive(Eq, Debug, ToJson)

///|
pub(all) struct SetupSummary {
  status : SetupSummaryStatus
  endpoint_count : Int
  constrained_endpoint_edges : Int
  unconstrained_endpoint_edges : Int
  violating_endpoint_edges : Int
  violating_endpoints : Int
  worst_slack_seconds : Double?
  worst_negative_slack_seconds : Double?
} derive(Debug, ToJson)

///|
/// Summarize the endpoint slacks already in this report, without rerunning STA.
/// Violated includes known violations in a report that also has unknown edges.
pub fn STAResult::setup_summary(
  self : STAResult,
) -> SetupSummary raise STAError {
  let pins : Map[String, Bool] = Map([])
  let failing : Map[String, Bool] = Map([])
  let mut endpoint_count = 0
  let mut constrained = 0
  let mut unconstrained = 0
  let mut violating_edges = 0
  let mut violating_pins = 0
  let mut worst : Double? = None
  for e in self.endpoints {
    if !pins.contains(e.pin) {
      pins[e.pin] = true
      endpoint_count += 1
    }
    match e.slack_seconds {
      Some(s) => {
        let s = checked_finite(s, "summary slack at " + e.pin)
        constrained += 1
        if worst is None || s < worst.unwrap() {
          worst = Some(s)
        }
        if s < 0.0 {
          violating_edges += 1
          if !failing.contains(e.pin) {
            failing[e.pin] = true
            violating_pins += 1
          }
        }
      }
      None => unconstrained += 1
    }
  }
  let status = if endpoint_count == 0 {
    NoEndpoints
  } else if violating_edges > 0 {
    Violated
  } else if constrained == 0 {
    NoCoverage
  } else if unconstrained > 0 {
    PartialCoverage
  } else {
    Met
  }
  {
    status,
    endpoint_count,
    constrained_endpoint_edges: constrained,
    unconstrained_endpoint_edges: unconstrained,
    violating_endpoint_edges: violating_edges,
    violating_endpoints: violating_pins,
    worst_slack_seconds: worst,
    worst_negative_slack_seconds: worst.map(s => if s < 0.0 { s } else { 0.0 }),
  }
}
