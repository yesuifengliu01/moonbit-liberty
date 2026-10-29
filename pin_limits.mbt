///|
pub(all) enum PinLimitKind {
  MaxCapacitance
  MaxTransition
} derive(Eq, Debug, ToJson)

///|
pub(all) enum PinLimitSource {
  PinAttribute
  LibraryDefault
} derive(Eq, Debug, ToJson)

///|
pub(all) enum PinLimitState {
  Satisfied
  Exceeded
  NotSpecified
  InvalidLimit
} derive(Eq, Debug, ToJson)

///|
pub(all) enum PinLimitReportStatus {
  LimitsMet
  LimitsViolated
  InvalidLimits
  NoDeclaredLimits
} derive(Eq, Debug)

///|
/// Unique typed constructors preserve existing unqualified SetupSummary names.
pub impl ToJson for PinLimitReportStatus with fn to_json(
  self : PinLimitReportStatus,
) -> Json {
  let text : String = match self {
    LimitsMet => "Met"
    LimitsViolated => "Violated"
    InvalidLimits => "InvalidLimits"
    NoDeclaredLimits => "NoDeclaredLimits"
  }
  ToJson::to_json(text)
}

///|
/// One rule/pin/edge. SI units are seconds or farads as named by `unit`.
/// Invalid/missing bounds never become zero; actuals retain original GBA values.
pub(all) struct PinLimitCheck {
  instance : String
  cell : String
  library_pin : String
  pin : String
  edge : Edge
  kind : PinLimitKind
  unit : String
  actual_si : Double
  status : PinLimitState
  source : PinLimitSource?
  source_attribute : String?
  raw_limit : String?
  limit_si : Double?
  margin_si : Double?
  issue : String?
} derive(Debug, ToJson)

///|
/// Counts are rule/pin/edge records, not unique pins. Met describes applicable
/// declared supported bounds; unspecified pins are not a coverage certificate.
pub(all) struct PinLimitReport {
  status : PinLimitReportStatus
  checked_rules : Int
  violated_rules : Int
  unspecified_rules : Int
  invalid_rules : Int
  checks : Array[PinLimitCheck]
} derive(Debug, ToJson)

///|
pub(all) struct PinLimitAnalysis {
  timing : STAResult
  pin_limits : PinLimitReport
} derive(Debug, ToJson)

///|
priv struct PinBound {
  source : PinLimitSource
  attribute : String
  raw : String?
  value : Double?
  issue : String?
}

///|
fn declared_pin_bound(
  group : @liberty.Group,
  attribute : String,
  scale : Double,
  source : PinLimitSource,
) -> PinBound? {
  let raw = group.text(attribute)
  let unsupported = group.complex(attribute) != None ||
    !group.groups(attribute).is_empty()
  if raw is None && !unsupported {
    return None
  }
  if unsupported {
    return Some({
      source,
      attribute,
      raw,
      value: None,
      issue: Some("limit must be a simple scalar attribute"),
    })
  }
  let parsed = Some(@liberty.finite_number(raw.unwrap())) catch { _ => None }
  let value = match parsed {
    Some(v) if v >= 0.0 => {
      let scaled = v * scale
      if finite(scaled) && (v == 0.0 || scaled > 0.0) {
        Some(scaled)
      } else {
        None
      }
    }
    _ => None
  }
  Some({
    source,
    attribute,
    raw,
    value,
    issue: if value is None {
      Some("limit is not a representable nonnegative SI scalar")
    } else {
      None
    },
  })
}

///|
fn make_pin_limit_check(
  gate : GateInstance,
  pin : @liberty.Pin,
  state : NodeTiming,
  kind : PinLimitKind,
  bound : PinBound?,
) -> PinLimitCheck {
  let actual = if kind == MaxCapacitance {
    state.load_farads
  } else {
    state.slew_seconds
  }
  let value = match bound {
    Some(b) => b.value
    None => None
  }
  let status = match (bound, value) {
    (None, _) => NotSpecified
    (Some(_), None) => InvalidLimit
    (_, Some(limit)) => if actual > limit { Exceeded } else { Satisfied }
  }
  {
    instance: gate.name,
    cell: gate.cell,
    library_pin: pin.name,
    pin: state.pin,
    edge: state.edge,
    kind,
    unit: if kind == MaxCapacitance {
      "farads"
    } else {
      "seconds"
    },
    actual_si: actual,
    status,
    source: bound.map(b => b.source),
    source_attribute: bound.map(b => b.attribute),
    raw_limit: match bound {
      Some(b) => b.raw
      None => None
    },
    limit_si: value,
    margin_si: value.map(limit => limit - actual),
    issue: match bound {
      Some(b) => b.issue
      None => None
    },
  }
}

///|
/// Run original setup once, then compare its full-design pin slew/output load
/// with supported declared Liberty bounds. Original setup errors are unchanged.
pub fn STAEngine::run_pin_limit_analysis(
  self : STAEngine,
) -> PinLimitAnalysis raise STAError {
  let timing = self.run_setup_analysis()
  // The original analysis validated units and all instances/connections.
  let units = self.library.units.unwrap()
  let default_transition = declared_pin_bound(
    self.library.source,
    "default_max_transition",
    units.time_seconds,
    LibraryDefault,
  )
  let nodes : Map[String, Array[NodeTiming]] = Map([])
  for node in timing.nodes {
    match nodes.get(node.pin) {
      Some(pair) => pair.push(node)
      None => nodes[node.pin] = [node]
    }
  }
  let checks = []
  for gate in self.netlist.gates {
    // Use the same library.cell selection as original graph construction.
    let cell = self.library.cell(gate.cell).unwrap()
    for pin in cell.pins {
      if pin.direction != Some("input") && pin.direction != Some("output") {
        continue
      }
      let pair = nodes[report_pin(gate.name, pin.name)]
      if pin.direction == Some("output") {
        let bound = declared_pin_bound(
          pin.source,
          "max_capacitance",
          units.capacitance_farads,
          PinAttribute,
        )
        for edge in [Rise, Fall] {
          checks.push(
            make_pin_limit_check(
              gate,
              pin,
              pair[edge_index(edge)],
              MaxCapacitance,
              bound,
            ),
          )
        }
      }
      let bound = match
        declared_pin_bound(
          pin.source,
          "max_transition",
          units.time_seconds,
          PinAttribute,
        ) {
        Some(bound) => Some(bound)
        None => default_transition
      }
      for edge in [Rise, Fall] {
        checks.push(
          make_pin_limit_check(
            gate,
            pin,
            pair[edge_index(edge)],
            MaxTransition,
            bound,
          ),
        )
      }
    }
  }
  let mut checked = 0
  let mut violated = 0
  let mut unspecified = 0
  let mut invalid = 0
  for check in checks {
    match check.status {
      Satisfied => checked += 1
      Exceeded => {
        checked += 1
        violated += 1
      }
      NotSpecified => unspecified += 1
      InvalidLimit => invalid += 1
    }
  }
  let status = if violated > 0 {
    LimitsViolated
  } else if invalid > 0 {
    InvalidLimits
  } else if checked == 0 {
    NoDeclaredLimits
  } else {
    LimitsMet
  }
  {
    timing,
    pin_limits: {
      status,
      checked_rules: checked,
      violated_rules: violated,
      unspecified_rules: unspecified,
      invalid_rules: invalid,
      checks,
    },
  }
}
