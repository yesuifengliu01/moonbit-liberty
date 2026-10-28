///|
pub(all) enum MissingLaunchKind {
  MissingInputDelay
  IdealClockNoDataArrival
} derive(Eq, Debug, ToJson)

///|
/// A causal step, not a timed arrival. Source has no delay; net delay is zero
/// in the current model; timing arcs retain their evaluated delay in seconds.
pub(all) struct ConstraintWitnessStep {
  pin : String
  edge : Edge
  arc : String
  delay_seconds : Double?
} derive(Debug, ToJson)

///|
/// One missing launch that reaches the endpoint through accepted timing arcs.
/// `port` is the raw constraint target; `pin` uses the existing report identity.
pub(all) struct MissingLaunchWitness {
  kind : MissingLaunchKind
  port : String
  pin : String
  edge : Edge
  path : Array[ConstraintWitnessStep]
} derive(Debug, ToJson)

///|
/// Context for an existing endpoint edge with unknown slack. This supplies at
/// most one launch witness, not an enumeration or certificate of path coverage.
pub(all) struct EndpointConstraintContext {
  pin : String
  edge : Edge
  missing_output_delay_port : String?
  launch_witness : MissingLaunchWitness?
} derive(Debug, ToJson)

///|
pub(all) struct ConstraintContextAnalysis {
  timing : STAResult
  constraint_context : Array[EndpointConstraintContext]
} derive(Debug, ToJson)

///|
priv enum ConstraintTraceLink {
  Source(MissingLaunchKind, String, String, Edge)
  Hop(ConstraintTraceLink, ConstraintWitnessStep)
}

///|
priv struct ConstraintTrace {
  missing : Map[String, Array[ConstraintTraceLink?]]
  endpoints : Array[EndpointConstraintContext]
}

///|
fn context_seed_input(
  context : ConstraintTrace,
  port : Port,
  clock : Clock,
  pair : Array[NodeTiming],
) -> Unit {
  context.missing[port.net] = pair.map(state => {
    if state.arrival_seconds is None {
      Some(
        Source(
          if port.name == clock.port {
            IdealClockNoDataArrival
          } else {
            MissingInputDelay
          },
          port.name,
          state.pin,
          state.edge,
        ),
      )
    } else {
      None
    }
  })
}

///|
fn context_output_edge(
  context : ConstraintTrace,
  net : String,
  edge : Edge,
  witness : ConstraintTraceLink?,
) -> Unit {
  if edge == Rise {
    context.missing[net] = [witness, None]
  } else {
    context.missing[net][1] = witness
  }
}

///|
fn context_materialize(link : ConstraintTraceLink) -> MissingLaunchWitness {
  let reversed = []
  for cursor = link {
    match cursor {
      Source(kind, port, pin, edge) => {
        reversed.push({ pin, edge, arc: "source", delay_seconds: None, })
        break {
          kind,
          port,
          pin,
          edge,
          path: [
            for i in 0..<reversed.length() => {
              reversed[reversed.length() - 1 - i]
            }
          ],
        }
      }
      Hop(parent, step) => {
        reversed.push(step)
        continue parent
      }
    }
  }
}

///|
fn context_endpoint(
  context : ConstraintTrace,
  endpoint : EndpointTiming,
  net : String,
  output_port : String?,
) -> Unit {
  if endpoint.slack_seconds is Some(_) {
    return
  }
  let witness = if endpoint.arrival_seconds is None {
    context.missing[net][edge_index(endpoint.edge)].map(parent => {
      context_materialize(
        Hop(parent, {
          pin: endpoint.pin,
          edge: endpoint.edge,
          arc: "net",
          delay_seconds: Some(0.0),
        }),
      )
    })
  } else {
    None
  }
  context.endpoints.push({
    pin: endpoint.pin,
    edge: endpoint.edge,
    missing_output_delay_port: if endpoint.required_seconds is None {
      output_port
    } else {
      None
    },
    launch_witness: witness,
  })
}

///|
/// Run setup once, adding causal context only for the report's unknown-slack
/// endpoint edges. Known alternate arrivals retain the original coverage rule.
/// The first accepted missing launch is a witness, not an exhaustive path check.
pub fn STAEngine::run_setup_with_constraint_context(
  self : STAEngine,
) -> ConstraintContextAnalysis raise STAError {
  let context : ConstraintTrace = { missing: Map([]), endpoints: [], }
  let timing = self.analyze_setup(context~).timing
  { timing, constraint_context: context.endpoints, }
}
