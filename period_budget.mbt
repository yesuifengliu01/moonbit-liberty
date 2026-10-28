///|
pub(all) enum PeriodBudgetStatus {
  Complete
  Partial
  Unconstrained
  NoPositiveLimit
  FrequencyOverflow
} derive(Eq, Debug, ToJson)

///|
pub(all) struct EndpointPeriodBound {
  pin : String
  edge : Edge
  bound_seconds : Double?
} derive(Debug, ToJson)

///|
pub(all) struct PeriodBudget {
  status : PeriodBudgetStatus
  constrained_endpoint_edges : Int
  unconstrained_endpoint_edges : Int
  endpoint_bounds : Array[EndpointPeriodBound]
  minimum_period_seconds : Double?
  maximum_frequency_hz : Double?
  limiting_endpoints : Array[EndpointPeriodBound]
} derive(Debug, ToJson)

///|
pub(all) struct PeriodAnalysis {
  timing : STAResult
  budget : PeriodBudget
} derive(Debug, ToJson)

///|
/// Analyze timing and the period bound while all non-period constraints stay fixed.
/// A global frequency is reported only when every endpoint edge is constrained.
pub fn STAEngine::run_period_analysis(
  self : STAEngine,
) -> PeriodAnalysis raise STAError {
  let analysis = self.analyze_setup()
  let timing = analysis.timing
  let c = self.constraints
  let output_delays : Map[String, PortValue] = Map([])
  for v in c.output_delays {
    output_delays[report_part(v.port)] = v
  }
  let bounds : Array[EndpointPeriodBound] = []
  let mut constrained = 0
  let mut unconstrained = 0
  let mut maximum : Double? = None
  for index, e in timing.endpoints {
    let bound = if e.arrival_seconds is Some(arrival) &&
      e.required_seconds is Some(_) {
      let offset = match e.setup_seconds {
        Some(setup) => setup
        None => {
          let value = match output_delays.get(e.pin) {
            Some(v) => if e.edge == Rise { v.rise } else { v.fall }
            None => None
          }
          guard value is Some(value) else {
            raise InvalidInput("period budget missing output delay at " + e.pin)
          }
          value
        }
      }
      // Use the relative arrival retained during propagation, rather than
      // subtracting rounded absolute arrival/latency or period/slack values.
      let value = checked_finite(
        match analysis.relative_arrivals[index] {
          Some(value) =>
            sum_constraints(value, c.clock.uncertainty_seconds, offset, 0.0)
          None =>
            sum_constraints(
              arrival,
              -c.clock.latency_seconds,
              c.clock.uncertainty_seconds,
              offset,
            )
        },
        "period bound at " + e.pin,
      )
      constrained += 1
      if maximum is None || value > maximum.unwrap() {
        maximum = Some(value)
      }
      Some(value)
    } else {
      unconstrained += 1
      None
    }
    bounds.push({ pin: e.pin, edge: e.edge, bound_seconds: bound, })
  }
  let mut status = Unconstrained
  let mut minimum : Double? = None
  let mut frequency : Double? = None
  let mut limiting : Array[EndpointPeriodBound] = []
  if constrained > 0 && unconstrained == 0 {
    let raw = maximum.unwrap()
    let period = if raw > 0.0 { raw } else { 0.0 }
    minimum = Some(period)
    if period == 0.0 {
      status = NoPositiveLimit
    } else {
      limiting = bounds.filter(e => e.bound_seconds == Some(raw))
      let hz = 1.0 / period
      if finite(hz) {
        status = Complete
        frequency = Some(hz)
      } else {
        status = FrequencyOverflow
      }
    }
  } else if constrained > 0 {
    status = Partial
  }
  {
    timing,
    budget: {
      status,
      constrained_endpoint_edges: constrained,
      unconstrained_endpoint_edges: unconstrained,
      endpoint_bounds: bounds,
      minimum_period_seconds: minimum,
      maximum_frequency_hz: frequency,
      limiting_endpoints: limiting,
    },
  }
}
