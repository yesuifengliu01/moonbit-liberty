///|
fn sdc_tokens(
  line : String,
  comments? : Bool = true,
  brackets? : Bool = true,
) -> Array[String] raise STAError {
  let result = []
  let mut word = ""
  let mut square = 0
  let mut brace = 0
  for ch in line.to_array() {
    if comments && ch == '#' && square == 0 && brace == 0 && word.is_empty() {
      break
    }
    if ch == '"' || ch == '$' || ch == ';' || ch == '\\' {
      raise Unsupported(
        "SDC scripting/quoting is outside the restricted profile",
      )
    }
    if ch == '[' && brace == 0 && brackets {
      square += 1
    }
    if ch == ']' && brace == 0 && brackets {
      square -= 1
    }
    if ch == '{' {
      brace += 1
    }
    if ch == '}' {
      brace -= 1
    }
    if square < 0 || square > 1 || brace < 0 || brace > 1 {
      raise InvalidInput("bad SDC grouping")
    }
    if (ch == ' ' || ch == '\t' || ch == '\r') && square == 0 && brace == 0 {
      if !word.is_empty() {
        result.push(word)
        word = ""
      }
    } else {
      word += ch.to_string()
    }
  }
  if square != 0 || brace != 0 {
    raise InvalidInput("unclosed SDC group")
  }
  if !word.is_empty() {
    result.push(word)
  }
  result
}

///|
fn sdc_objects(token : String, kind : String) -> Array[String] raise STAError {
  if token.length() < 3 || token[0] != '[' || token[token.length() - 1] != ']' {
    raise InvalidInput("expected [get_" + kind + " ...]")
  }
  let inner = token[1:token.length() - 1].to_owned()
  let tokens = sdc_tokens(inner, comments=false)
  if tokens.length() < 2 || tokens[0] != "get_" + kind {
    raise Unsupported("SDC object selector")
  }
  let names = []
  for token in tokens[1:] {
    let token = if token.length() >= 2 &&
      token[0] == '{' &&
      token[token.length() - 1] == '}' {
      token[1:token.length() - 1].to_owned()
    } else {
      token
    }
    names.append(sdc_tokens(token, comments=false, brackets=false))
  }
  if names.is_empty() {
    raise InvalidInput("empty SDC selector")
  }
  names
}

///|
fn sdc_number(s : String) -> Double raise STAError {
  let v = @string.parse_double(s) catch {
    _ => raise InvalidInput("SDC number: " + s)
  }
  if !finite(v) {
    raise InvalidInput("SDC value must be finite")
  }
  v
}

///|
fn set_port_value(
  values : Array[PortValue],
  port : String,
  value : Double,
  rise : Bool,
  fall : Bool,
) -> Unit {
  for i in 0..<values.length() {
    if values[i].port == port {
      let old = values[i]
      values[i] = {
        port,
        rise: if rise {
          Some(value)
        } else {
          old.rise
        },
        fall: if fall {
          Some(value)
        } else {
          old.fall
        },
      }
      return
    }
  }
  values.push({
    port,
    rise: if rise {
      Some(value)
    } else {
      None
    },
    fall: if fall {
      Some(value)
    } else {
      None
    },
  })
}

///|
/// Parse the documented single-clock SDC data profile. This does not evaluate Tcl.
/// Numeric command units are taken from the supplied Liberty library.
pub fn parse_sdc(
  text : String,
  library : @liberty.Library,
  netlist : Netlist,
) -> TimingConstraints raise STAError {
  if text.length() > 1000000 {
    raise InvalidInput("SDC text budget exceeded")
  }
  let units = validate_library(library)
  let mut clock : Clock? = None
  let inputs = []
  let outputs = []
  let slews = []
  let loads = []
  for line in text.split("\n") {
    let tokens = sdc_tokens(line.to_owned())
    if tokens.is_empty() {
      continue
    }
    let cmd = tokens[0]
    let allowed = match cmd {
      "create_clock" => ["-name", "-period", "-waveform"]
      "set_input_delay" | "set_output_delay" =>
        ["-clock", "-max", "-rise", "-fall"]
      "set_input_transition" => ["-rise", "-fall"]
      "set_load" => []
      "set_clock_transition" => ["-rise", "-fall"]
      "set_clock_latency" => []
      "set_clock_uncertainty" => ["-setup"]
      _ => raise Unsupported("SDC command " + cmd)
    }
    let flags : Map[String, String] = Map([])
    let positional = []
    let mut i = 1
    while i < tokens.length() {
      let t = tokens[i]
      if t.length() > 1 && t[0] == '-' && t[1] >= 'a' && t[1] <= 'z' {
        if !allowed.contains(t) || flags.contains(t) {
          raise Unsupported("SDC flag " + t + " for " + cmd)
        }
        if ["-name", "-period", "-waveform", "-clock"].contains(t) {
          i += 1
          if i == tokens.length() {
            raise InvalidInput("missing SDC flag value")
          }
          flags[t] = tokens[i]
        } else {
          flags[t] = "true"
        }
      } else {
        positional.push(t)
      }
      i += 1
    }
    if cmd == "create_clock" {
      if clock is Some(_) {
        raise Unsupported("only one create_clock is supported")
      }
      if positional.length() != 1 ||
        !flags.contains("-period") ||
        !flags.contains("-name") {
        raise InvalidInput("create_clock requires name, period and exact port")
      }
      let names = sdc_objects(positional[0], "ports")
      if names.length() != 1 {
        raise Unsupported("one real clock port required")
      }
      let clock_name = flags["-name"]
      if clock_name.is_empty() ||
        clock_name
        .to_array()
        .any(ch => {
          ch == '{' ||
          ch == '}' ||
          ch == '[' ||
          ch == ']' ||
          ch == ' ' ||
          ch == '\t' ||
          ch == '\r'
        }) {
        raise InvalidInput("clock name must be a nonempty plain name")
      }
      let port = netlist.ports.iter().find_first(p => p.name == names[0])
      guard port is Some(port) else {
        raise InvalidInput("unknown clock port " + names[0])
      }
      if port.direction != Input {
        raise InvalidInput("clock must name one input port")
      }
      let period = sdc_number(flags["-period"]) * units.time_seconds
      nonnegative(period, "period")
      if period == 0.0 {
        raise InvalidInput("period must be positive")
      }
      if flags.get("-waveform") is Some(w) {
        if w.length() < 2 || w[0] != '{' || w[w.length() - 1] != '}' {
          raise InvalidInput("clock waveform grouping")
        }
        let wave = sdc_tokens(w[1:w.length() - 1].to_owned(), comments=false)
        if wave.length() != 2 ||
          sdc_number(wave[0]) != 0.0 ||
          sdc_number(wave[1]) * units.time_seconds != period / 2.0 {
          raise Unsupported("only 0/T/2 clock waveform supported")
        }
      }
      clock = Some({
        name: flags["-name"],
        port: names[0],
        period_seconds: period,
        rise_slew_seconds: 0.0,
        fall_slew_seconds: 0.0,
        latency_seconds: 0.0,
        uncertainty_seconds: 0.0,
      })
      continue
    }
    let clk = match clock {
      Some(c) => c
      None => raise InvalidInput("create_clock must precede timing commands")
    }
    if positional.length() != 2 {
      raise InvalidInput(cmd + " requires number and selector")
    }
    let value = sdc_number(positional[0])
    let rise = flags.contains("-rise") || !flags.contains("-fall")
    let fall = flags.contains("-fall") || !flags.contains("-rise")
    if ["set_clock_transition", "set_clock_latency", "set_clock_uncertainty"].contains(
        cmd,
      ) {
      let names = sdc_objects(positional[1], "clocks")
      if names != [clk.name] {
        raise InvalidInput("unknown clock selector")
      }
      let v = value * units.time_seconds
      if cmd == "set_clock_latency" {
        ignore(checked_finite(v, "clock latency"))
      } else {
        nonnegative(v, cmd)
      }
      clock = Some(
        match cmd {
          "set_clock_transition" =>
            {
              ..clk,
              rise_slew_seconds: if rise {
                v
              } else {
                clk.rise_slew_seconds
              },
              fall_slew_seconds: if fall {
                v
              } else {
                clk.fall_slew_seconds
              },
            }
          "set_clock_latency" => { ..clk, latency_seconds: v, }
          _ => { ..clk, uncertainty_seconds: v, }
        },
      )
      continue
    }
    if cmd == "set_input_delay" || cmd == "set_output_delay" {
      if flags.get("-clock") != Some(clk.name) {
        raise InvalidInput("I/O delay requires the single clock name")
      }
    }
    let names = sdc_objects(positional[1], "ports")
    let direction = if cmd == "set_output_delay" || cmd == "set_load" {
      Output
    } else {
      Input
    }
    let selected = if names == ["*"] {
      netlist.ports
      .filter(p => p.direction == direction && p.name != clk.port)
      .map(p => p.name)
    } else {
      names
    }
    for name in selected {
      let port = netlist.ports.iter().find_first(p => p.name == name)
      guard port is Some(port) else {
        raise InvalidInput("unknown port " + name)
      }
      if port.direction != direction || name == clk.port {
        raise InvalidInput("wrong SDC port direction " + name)
      }
      let v = value *
        (if cmd == "set_load" {
          units.capacitance_farads
        } else {
          units.time_seconds
        })
      match cmd {
        "set_input_delay" => set_port_value(inputs, name, v, rise, fall)
        "set_output_delay" => set_port_value(outputs, name, v, rise, fall)
        "set_input_transition" => {
          nonnegative(v, "input transition")
          set_port_value(slews, name, v, rise, fall)
        }
        _ => {
          nonnegative(v, "output load")
          set_port_value(loads, name, v, rise, fall)
        }
      }
    }
  }
  let clock = match clock {
    Some(c) => c
    None => raise InvalidInput("missing clock")
  }
  {
    clock,
    input_delays: inputs,
    output_delays: outputs,
    input_slews: slews,
    output_loads: loads,
  }
}
