///|
priv struct Register {
  data : String
  clock : String
  output : String
}

///|
fn register(cell : @liberty.Cell) -> Register? raise STAError {
  let ffs = cell.source.groups("ff")
  if !cell.source.groups("latch").is_empty() ||
    !cell.source.groups("ff_bank").is_empty() ||
    !cell.source.groups("statetable").is_empty() {
    raise Unsupported("unsupported sequential cell " + cell.name)
  }
  if ffs.is_empty() {
    return None
  }
  if ffs.length() != 1 {
    raise Unsupported("multiple ff groups in " + cell.name)
  }
  let ff = ffs[0]
  if ff.text("clear") != None ||
    ff.text("preset") != None ||
    ff.arguments.is_empty() {
    raise Unsupported("async or incomplete ff " + cell.name)
  }
  let clk = ff.text("clocked_on").unwrap_or("")
  let data = ff.text("next_state").unwrap_or("")
  if cell.pin(clk) is None || cell.pin(data) is None {
    raise Unsupported("complex ff equations " + cell.name)
  }
  let state = @liberty.atoms_text(ff.arguments[0])
  let outputs = cell.pins.filter(p => {
    p.direction == Some("output") && p.function == Some(state)
  })
  if outputs.length() != 1 {
    raise Unsupported("ff output mapping " + cell.name)
  }
  Some({ data, clock: clk, output: outputs[0].name, })
}

///|
fn validate_library(
  library : @liberty.Library,
) -> @liberty.Units raise STAError {
  let units = match library.units {
    Some(u) => u
    None => raise InvalidInput("library must declare time/capacitance units")
  }
  @liberty.validate_units(units) catch {
    @liberty.LibertyError(code, message, _) =>
      raise LibraryFailure(code + ": " + message)
  }
  for edge in ["rise", "fall"] {
    fn threshold(key : String, fallback : Double) -> Double raise STAError {
      let v = match library.source.text(key) {
        Some(s) =>
          @liberty.finite_number(s) catch {
            _ => raise InvalidInput("invalid " + key)
          }
        None => fallback
      }
      if v <= 0.0 || v >= 100.0 {
        raise Unsupported("threshold outside 0..100: " + key)
      }
      v
    }
    let input = threshold("input_threshold_pct_" + edge, 50.0)
    let output = threshold("output_threshold_pct_" + edge, 50.0)
    if input != output {
      raise Unsupported(
        "input/output voltage thresholds must match in this profile",
      )
    }
    let lower = threshold("slew_lower_threshold_pct_" + edge, 20.0)
    let upper = threshold("slew_upper_threshold_pct_" + edge, 80.0)
    if lower >= upper {
      raise InvalidInput("slew thresholds must be increasing")
    }
  }
  if library.source.text("delay_model") != Some("table_lookup") {
    raise Unsupported("NLDM table_lookup required")
  }
  for key in ["slew_derate_from_library"] {
    if library.source.text(key) is Some(s) {
      let v = @liberty.finite_number(s) catch { _ => raise InvalidInput(key) }
      if v != 1.0 {
        raise Unsupported(key + " must be 1 for this profile")
      }
    }
  }
  for f in library.findings {
    if f.severity == @liberty.Error {
      raise LibraryFailure(f.code + ": " + f.message)
    }
  }
  units
}

///|
fn find_table(
  arc : @liberty.TimingArc,
  kind : String,
  cell : String,
) -> @liberty.Table raise STAError {
  let tables = arc.tables.filter(t => t.kind == kind)
  if tables.length() != 1 {
    raise MissingTimingArc(cell, arc.related_pins.join(" "), kind)
  }
  tables[0]
}

///|
// A timing group may describe only one output edge. A completely missing model
// still fails instead of being mistaken for an edge that belongs to another group.
fn propagation_model_for_edge(
  arc : @liberty.TimingArc,
  edge : Edge,
  cell : String,
) -> Bool raise STAError {
  let kinds = if edge == Rise {
    ["cell_rise", "rise_transition"]
  } else {
    ["cell_fall", "fall_transition"]
  }
  if arc.tables.any(t => kinds.contains(t.kind)) {
    return true
  }
  if arc.tables.any(t => {
      ["cell_rise", "rise_transition", "cell_fall", "fall_transition"].contains(
        t.kind,
      )
    }) {
    return false
  }
  raise MissingTimingArc(cell, arc.related_pins.join(" "), kinds[0])
}

///|
// Infer occurrence polarity from the upstream Boolean AST, without evaluating
// side-input cases or overriding an explicitly declared timing_sense.
fn inferred_senses(
  output : @liberty.Pin,
  diagnostics : Array[String],
) -> Map[String, String] {
  let result : Map[String, String] = Map([])
  if !output.timings.any(a => a.timing_sense == None) {
    return result
  }
  guard output.function is Some(text) else { return result }
  let logic = @liberty.parse_logic(text) catch {
    _ => {
      diagnostics.push(
        "conservative timing_sense:unparsed function at " + output.name,
      )
      return result
    }
  }
  let polarity : Map[String, Int] = Map([])
  // Bit 1: positive occurrence; bit 2: negative occurrence. XOR permits both.
  let pending = [(logic, false, false)]
  while pending.pop() is Some((expr, inverted, mixed)) {
    match expr {
      Signal(name) => {
        let mask = if mixed { 3 } else if inverted { 2 } else { 1 }
        polarity[name] = polarity.get(name).unwrap_or(0) | mask
      }
      Constant(_) => ()
      Not(inner) => pending.push((inner, !inverted, mixed))
      And(a, b) | Or(a, b) => {
        pending.push((a, inverted, mixed))
        pending.push((b, inverted, mixed))
      }
      Xor(a, b) => {
        pending.push((a, inverted, true))
        pending.push((b, inverted, true))
      }
    }
  }
  for name, mask in polarity {
    result[name] = match mask {
      1 => "positive_unate"
      2 => "negative_unate"
      _ => "non_unate"
    }
  }
  result
}

///|
fn table_value(
  table : @liberty.Table,
  input_slew : Double,
  load : Double,
  clock_slew : Double,
  check : Bool,
  units : @liberty.Units,
  policy : @liberty.RangePolicy,
  diagnostics : Array[String],
) -> Double raise STAError {
  fn coordinate(variable : String?) -> Double raise STAError {
    match variable {
      Some("input_net_transition") | Some("input_transition_time") if !check =>
        input_slew / units.time_seconds
      Some("total_output_net_capacitance") if !check =>
        load / units.capacitance_farads
      Some("related_pin_transition") if check => clock_slew / units.time_seconds
      Some("constrained_pin_transition") if check =>
        input_slew / units.time_seconds
      _ => raise Unsupported("unsupported table axis in " + table.kind)
    }
  }
  let x = if table.index_1.is_empty() {
    0.0
  } else {
    coordinate(table.variable_1)
  }
  let y = if table.index_2.is_empty() {
    None
  } else {
    Some(coordinate(table.variable_2))
  }
  let value = @liberty.lookup_table(table, x, y?, policy~) catch {
    @liberty.LibertyError(code, message, _) =>
      raise LibraryFailure(code + ": " + message)
  }
  if value.extrapolated {
    diagnostics.push("extrapolated:" + table.kind)
  }
  if value.clamped {
    diagnostics.push("clamped:" + table.kind)
  }
  let result = value.value * units.time_seconds
  if !finite(result) {
    raise InvalidInput("nonfinite table result")
  }
  result
}

///|
fn arc_accepts(
  arc : @liberty.TimingArc,
  input : Edge,
  output : Edge,
  inferred : String?,
) -> Bool raise STAError {
  if arc.condition != None {
    raise Unsupported("conditional timing arc requires case analysis")
  }
  match prefer(arc.timing_sense, inferred) {
    Some("positive_unate") => input == output
    Some("negative_unate") => input != output
    Some("non_unate") | None => true
    _ => raise Unsupported("unknown timing_sense")
  }
}
