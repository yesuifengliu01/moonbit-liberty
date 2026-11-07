///|
pub(all) enum Direction {
  Input
  Output
} derive(Eq, Debug, ToJson)

///|
pub(all) enum Edge {
  Rise
  Fall
} derive(Eq, Debug, ToJson)

///|
pub(all) struct Port {
  name : String
  net : String
  direction : Direction
} derive(Debug, ToJson)

///|
pub(all) struct Connection {
  pin : String
  net : String
} derive(Debug, ToJson)

///|
pub(all) struct GateInstance {
  name : String
  cell : String
  connections : Array[Connection]
} derive(Debug, ToJson)

///|
pub(all) struct Net {
  name : String
  wire_cap_farads : Double
} derive(Debug, ToJson)

///|
pub(all) struct Netlist {
  ports : Array[Port]
  gates : Array[GateInstance]
  nets : Array[Net]
} derive(Debug, ToJson)

///|
pub(all) struct Clock {
  name : String
  port : String
  period_seconds : Double
  rise_slew_seconds : Double
  fall_slew_seconds : Double
  latency_seconds : Double
  uncertainty_seconds : Double
} derive(Debug, ToJson)

///|
pub(all) struct PortValue {
  port : String
  rise : Double?
  fall : Double?
} derive(Debug, ToJson)

///|
pub(all) struct TimingConstraints {
  clock : Clock
  input_delays : Array[PortValue]
  output_delays : Array[PortValue]
  input_slews : Array[PortValue]
  output_loads : Array[PortValue]
} derive(Debug, ToJson)

///|
pub(all) struct PathStep {
  pin : String
  edge : Edge
  delay_seconds : Double
  arrival_seconds : Double
  arc : String
} derive(Debug, ToJson)

///|
pub(all) struct NodeTiming {
  pin : String
  edge : Edge
  arrival_seconds : Double?
  slew_seconds : Double
  load_farads : Double
  path : Array[PathStep]
  slew_contributor : String
} derive(Debug, ToJson)

///|
pub(all) struct EndpointTiming {
  pin : String
  edge : Edge
  arrival_seconds : Double?
  required_seconds : Double?
  slack_seconds : Double?
  setup_seconds : Double?
  path : Array[PathStep]
} derive(Debug, ToJson)

///|
pub(all) struct STAResult {
  nodes : Array[NodeTiming]
  endpoints : Array[EndpointTiming]
  worst_slack_seconds : Double?
  diagnostics : Array[String]
  topological_order : Array[String]
} derive(Debug, ToJson)

///|
pub suberror STAError {
  InvalidInput(String)
  Unsupported(String)
  UnresolvedNet(String)
  MultipleDrivers(String)
  CombinationalLoopDetected(Array[String])
  MissingTimingArc(String, String, String)
  LibraryFailure(String)
} derive(Debug)

///|
pub struct STAEngine {
  library : @liberty.Library
  netlist : Netlist
  constraints : TimingConstraints
  policy : @liberty.RangePolicy
}

///|
pub fn STAEngine::new(
  library : @liberty.Library,
  netlist : Netlist,
  constraints : TimingConstraints,
  policy~ : @liberty.RangePolicy = Extrapolate,
) -> STAEngine {
  { library, netlist, constraints, policy, }
}

///|
fn edge_index(edge : Edge) -> Int32 {
  match edge {
    Rise => 0
    Fall => 1
  }
}

///|
// Report identity components use the RFC 6901 token escapes. Keeping '/' only
// as the instance/pin separator makes ports and qualified pins disjoint.
fn report_part(name : String) -> String {
  let out = StringBuilder()
  for ch in name.to_array() {
    match ch {
      '~' => out.write_string("~0")
      '/' => out.write_string("~1")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
fn report_pin(instance : String, pin : String) -> String {
  report_part(instance) + "/" + report_part(pin)
}

///|
fn port_value(values : Array[PortValue], port : String, edge : Edge) -> Double? {
  for v in values {
    if v.port == port {
      return match edge {
        Rise => v.rise
        Fall => v.fall
      }
    }
  }
  None
}

///|
fn finite(v : Double) -> Bool {
  !v.is_nan() && !v.is_inf()
}

///|
fn checked_finite(value : Double, context : String) -> Double raise STAError {
  if !finite(value) {
    raise InvalidInput("nonfinite derived " + context)
  }
  value
}

///|
fn[T] prefer(a : T?, b : T?) -> T? {
  match a {
    Some(_) => a
    None => b
  }
}

///|
fn nonnegative(v : Double, label : String) -> Unit raise STAError {
  if !finite(v) || v < 0.0 {
    raise InvalidInput(label + " must be finite and nonnegative")
  }
}

///|
pub extend Direction with Eq::{not_equal, equal}

///|
pub extend Direction with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Direction with ToJson::{to_json}

///|
pub extend Edge with Eq::{not_equal, equal}

///|
pub extend Edge with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Edge with ToJson::{to_json}

///|
pub extend Port with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Port with ToJson::{to_json}

///|
pub extend Connection with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Connection with ToJson::{to_json}

///|
pub extend GateInstance with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GateInstance with ToJson::{to_json}

///|
pub extend Net with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Net with ToJson::{to_json}

///|
pub extend Netlist with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Netlist with ToJson::{to_json}

///|
pub extend Clock with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Clock with ToJson::{to_json}

///|
pub extend PortValue with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend PortValue with ToJson::{to_json}

///|
pub extend TimingConstraints with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TimingConstraints with ToJson::{to_json}

///|
pub extend PathStep with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend PathStep with ToJson::{to_json}

///|
pub extend NodeTiming with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend NodeTiming with ToJson::{to_json}

///|
pub extend EndpointTiming with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EndpointTiming with ToJson::{to_json}

///|
pub extend STAResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend STAResult with ToJson::{to_json}

///|
pub extend STAError with @moonbitlang/core/debug.Debug::{to_repr}
