///|
/// Exact raw names. RegisterQ must identify a supported ff's real Q pin.
pub(all) enum PathLaunch {
  InputPort(String, Edge)
  RegisterQ(String, String, Edge)
} derive(Eq, Debug, ToJson)

///|
/// Exact raw names. RegisterD must identify a supported ff's real D pin.
pub(all) enum PathCapture {
  OutputPort(String, Edge)
  RegisterD(String, String, Edge)
} derive(Eq, Debug, ToJson)

///|
pub(all) struct PathQuery {
  launch : PathLaunch
  capture : PathCapture
} derive(Eq, Debug, ToJson)

///|
pub(all) enum PathQueryStatus {
  Found
  NoPath
  UnconstrainedLaunch
} derive(Eq, Debug, ToJson)

///|
/// Selected-source GBA path, not isolated-path slew analysis or global WNS.
/// Non-Found results have an empty owned path and no numerical query values.
pub(all) struct QueriedPath {
  status : PathQueryStatus
  launch_pin : String
  launch_edge : Edge
  capture_pin : String
  capture_edge : Edge
  queried_arrival_seconds : Double?
  required_seconds : Double?
  queried_slack_seconds : Double?
  path : Array[PathStep]
} derive(Debug, ToJson)

///|
pub(all) struct PathQueryAnalysis {
  timing : STAResult
  path_query : QueriedPath
} derive(Debug, ToJson)

///|
priv struct QuerySeed {
  net : String
  state : NodeTiming
  relative : Double?
}

///|
priv struct QueryArc {
  input_net : String
  input_pin : String
  input_edge : Edge
  output_net : String
  output_pin : String
  output_edge : Edge
  delay : Double
  arc : String
}

///|
priv struct QueryCapture {
  net : String
  endpoint : EndpointTiming
  offset : Double?
}

///|
priv struct PathQueryTrace {
  seeds : Map[String, Array[QuerySeed]]
  arcs : Array[QueryArc]
  captures : Map[String, Array[QueryCapture]]
}

///|
priv enum QueryPathLink {
  Seed(Array[PathStep])
  Step(QueryPathLink, PathStep)
}

///|
priv struct QueryArrival {
  absolute : Double
  relative : Double?
  link : QueryPathLink
}

///|
fn path_query_seed(
  trace : PathQueryTrace,
  net : String,
  pair : Array[NodeTiming],
  relative : Array[Double?],
) -> Unit {
  trace.seeds[pair[0].pin] = pair.map(state => {
    net,
    state,
    relative: relative[edge_index(state.edge)],
  })
}

///|
fn path_query_capture(
  trace : PathQueryTrace,
  net : String,
  endpoint : EndpointTiming,
  offset : Double?,
) -> Unit {
  let capture : QueryCapture = { net, endpoint, offset, }
  match trace.captures.get(endpoint.pin) {
    Some(pair) => pair.push(capture)
    None => trace.captures[endpoint.pin] = [capture]
  }
}

///|
fn query_path_materialize(link : QueryPathLink) -> Array[PathStep] {
  let reversed = []
  for cursor = link {
    match cursor {
      Seed(prefix) => {
        let result = prefix.copy()
        for i in 0..<reversed.length() {
          result.push(reversed[reversed.length() - 1 - i])
        }
        break result
      }
      Step(parent, step) => {
        reversed.push(step)
        continue parent
      }
    }
  }
}

///|
fn resolve_path_query(
  trace : PathQueryTrace,
  query : PathQuery,
  clock : Clock,
) -> QueriedPath raise STAError {
  let (launch_pin, launch_edge) = match query.launch {
    InputPort(name, edge) => (report_part(name), edge)
    RegisterQ(instance, pin, edge) => (report_pin(instance, pin), edge)
  }
  // Seed/capture identity namespaces also validate role: only PI/Q are seeds,
  // only PO/D are captures. Escaping keeps a literal port slash distinct.
  let seed = match trace.seeds.get(launch_pin) {
    Some(pair) => pair[edge_index(launch_edge)]
    None => raise InvalidInput("invalid path launch " + launch_pin)
  }
  let (capture_pin, capture_edge) = match query.capture {
    OutputPort(name, edge) => (report_part(name), edge)
    RegisterD(instance, pin, edge) => (report_pin(instance, pin), edge)
  }
  let capture = match trace.captures.get(capture_pin) {
    Some(pair) => pair[edge_index(capture_edge)]
    None => raise InvalidInput("invalid path capture " + capture_pin)
  }
  let empty : QueriedPath = {
    status: NoPath,
    launch_pin,
    launch_edge,
    capture_pin,
    capture_edge,
    queried_arrival_seconds: None,
    required_seconds: None,
    queried_slack_seconds: None,
    path: [],
  }
  let reaches : Map[String, Array[Bool]] = Map([])
  reaches[seed.net] = [launch_edge == Rise, launch_edge == Fall]
  // Decide reachability before any selected-source arithmetic. Missing launch
  // constraints cannot turn an unreachable edge into UnconstrainedLaunch.
  for arc in trace.arcs {
    let reachable = match reaches.get(arc.input_net) {
      Some(pair) => pair[edge_index(arc.input_edge)]
      None => false
    }
    if reachable {
      let pair = match reaches.get(arc.output_net) {
        Some(pair) => pair
        None => {
          let pair = [false, false]
          reaches[arc.output_net] = pair
          pair
        }
      }
      pair[edge_index(arc.output_edge)] = true
    }
  }
  let reachable = match reaches.get(capture.net) {
    Some(pair) => pair[edge_index(capture_edge)]
    None => false
  }
  if !reachable {
    return empty
  }
  if seed.state.arrival_seconds is None {
    return { ..empty, status: UnconstrainedLaunch, }
  }
  let arrivals : Map[String, Array[QueryArrival?]] = Map([])
  if seed.state.arrival_seconds is Some(a) {
    let pair : Array[QueryArrival?] = [None, None]
    pair[edge_index(launch_edge)] = Some({
      absolute: a,
      relative: seed.relative,
      link: Seed(seed.state.path),
    })
    arrivals[seed.net] = pair
  }
  // These records are ordered by the original output DAG, then output edge,
  // timing group, related pin and input edge. Keep strict > tie selection.
  for arc in trace.arcs {
    let input = match arrivals.get(arc.input_net) {
      Some(pair) => pair[edge_index(arc.input_edge)]
      None => None
    }
    guard input is Some(input) else { continue }
    let absolute = checked_finite(
      input.absolute + arc.delay,
      "queried arrival at " + arc.output_pin,
    )
    let relative = match input.relative {
      Some(r) => finite_option(r + arc.delay)
      None => finite_option(absolute - clock.latency_seconds)
    }
    let pair = match arrivals.get(arc.output_net) {
      Some(pair) => pair
      None => {
        let pair : Array[QueryArrival?] = [None, None]
        arrivals[arc.output_net] = pair
        pair
      }
    }
    let better = match pair[edge_index(arc.output_edge)] {
      None => true
      Some(best) =>
        later_arrival(
          absolute,
          relative,
          best.absolute,
          best.relative,
          clock.latency_seconds,
        )
    }
    if better {
      let net_step : PathStep = {
        pin: arc.input_pin,
        edge: arc.input_edge,
        delay_seconds: 0.0,
        arrival_seconds: input.absolute,
        arc: "net",
      }
      let gate_step : PathStep = {
        pin: arc.output_pin,
        edge: arc.output_edge,
        delay_seconds: arc.delay,
        arrival_seconds: absolute,
        arc: arc.arc,
      }
      pair[edge_index(arc.output_edge)] = Some({
        absolute,
        relative,
        link: Step(Step(input.link, net_step), gate_step),
      })
    }
  }
  let arrival = arrivals[capture.net][edge_index(capture_edge)].unwrap()
  let required = capture.endpoint.required_seconds
  let slack = match required {
    Some(r) => {
      let stable = match capture.offset {
        Some(offset) => clock_slack(clock, offset, arrival.relative)
        None => None
      }
      Some(
        checked_finite(
          match stable {
            Some(value) => value
            None => r - arrival.absolute
          },
          "queried slack at " + capture_pin,
        ),
      )
    }
    None => None
  }
  let path = query_path_materialize(
    Step(arrival.link, {
      pin: capture_pin,
      edge: capture_edge,
      delay_seconds: 0.0,
      arrival_seconds: arrival.absolute,
      arc: "net",
    }),
  )
  {
    ..empty,
    status: Found,
    queried_arrival_seconds: Some(arrival.absolute),
    required_seconds: required,
    queried_slack_seconds: slack,
    path,
  }
}

///|
/// One exact launch/capture-edge query under the original full-design GBA slew
/// and load. Original setup errors precede point validation; launch precedes
/// capture validation, then NoPath precedes UnconstrainedLaunch. No D-to-Q edge.
pub fn STAEngine::run_setup_path_query(
  self : STAEngine,
  query : PathQuery,
) -> PathQueryAnalysis raise STAError {
  let trace : PathQueryTrace = { seeds: Map([]), arcs: [], captures: Map([]), }
  let timing = self.analyze_setup(path_query=trace).timing
  let path_query = resolve_path_query(trace, query, self.constraints.clock)
  { timing, path_query, }
}
