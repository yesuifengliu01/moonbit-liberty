///|
fn diagnostic_netlist() -> @sta.Netlist {
  {
    ports: ["clk", "数😀", "y"].map(name => {
      name,
      net: name,
      direction: if name == "y" {
        Output
      } else {
        Input
      },
    }),
    gates: [],
    nets: ["clk", "数😀", "y"].map(name => { name, wire_cap_farads: 0.0, }),
  }
}

///|
fn diagnostic_prefix() -> String {
  // Manually counted UTF-16 lengths including CRLF: 6 + 2 + 48 + 48 + 9 = 113.
  "# 😀\r\n\r\n" +
  "create_clock -name c -period 2 [get_ports clk]\r\n" +
  "set_input_delay -clock c 0.2 [get_ports {数😀}]\r\n" +
  "\t# tail\r\n"
}

///|
fn expect_sdc_diagnostic(
  source : String,
  expected_error : String,
  position : @sta.SdcSourcePosition?,
) -> Unit raise {
  let library = @liberty.load_library(@testdata.library())
  let netlist = diagnostic_netlist()
  try @sta.parse_sdc_with_diagnostics(source, library, netlist) catch {
    @sta.SdcDiagnostic(error, actual) => {
      assert_eq("\{@debug.Debug::to_repr(error)}", expected_error)
      assert_eq(actual, position)
    }
  } noraise {
    _ => fail("expected a structured SDC diagnostic")
  }
  // A diagnostic must not change the old error category, message or precedence.
  try @sta.parse_sdc(source, library, netlist) catch {
    error => assert_eq("\{@debug.Debug::to_repr(error)}", expected_error)
  } noraise {
    _ => fail("legacy parser unexpectedly accepted the same error")
  }
}

///|
test "SDC diagnostic anchors the CRLF Unicode file at the hand-counted command" {
  expect_sdc_diagnostic(
    diagnostic_prefix() + " \tset_load -min 0.1 [get_ports y]\r\n",
    "Unsupported(\"SDC flag -min for set_load\")",
    Some({ line: 6, column: 3, offset: 115, }),
  )
}

///|
test "SDC diagnostic locates LF lexical grouping and unsupported-command failures" {
  // '# ' is 2 units, emoji2, LF1, tab1: command offset6, line2/column2.
  // No final LF: the last command must still retain its position.
  for
    (command, error) in [
      (
        "set_load 0.1 [get_ports y];", "Unsupported(\"SDC scripting/quoting is outside the restricted profile\")",
      ),
      ("set_load 0.1 [get_ports y", "InvalidInput(\"unclosed SDC group\")"),
      (
        "set_false_path [get_ports y]", "Unsupported(\"SDC command set_false_path\")",
      ),
    ] {
    expect_sdc_diagnostic(
      "# 😀\n\t" + command,
      error,
      Some({ line: 2, column: 2, offset: 6, }),
    )
  }
}

///|
test "SDC diagnostic anchors numeric and selector errors without changing them" {
  for
    (command, error) in [
      ("set_load bad [get_ports y]", "InvalidInput(\"SDC number: bad\")"),
      (
        "set_load 0.1 [get_ports missing]", "InvalidInput(\"unknown port missing\")",
      ),
      (
        "set_load 0.1 [get_ports {数😀}]", "InvalidInput(\"wrong SDC port direction 数😀\")",
      ),
    ] {
    expect_sdc_diagnostic(
      diagnostic_prefix() + " \t" + command,
      error,
      Some({ line: 6, column: 3, offset: 115, }),
    )
  }
}

///|
test "SDC global failures have no fabricated command position" {
  expect_sdc_diagnostic(
    "# 😀\r\n\t# no clock\r\n",
    "InvalidInput(\"missing clock\")",
    None,
  )
  let oversized = StringBuilder()
  for _ in 0..<1000001 {
    oversized.write_char(' ')
  }
  expect_sdc_diagnostic(
    oversized.to_string(),
    "InvalidInput(\"SDC text budget exceeded\")",
    None,
  )
}

///|
test "SDC diagnostic parser preserves valid Unicode constraints and SI values" {
  let library = @liberty.load_library(@testdata.library())
  let netlist = diagnostic_netlist()
  let source = diagnostic_prefix() + "  set_load 0.1 [get_ports y]"
  let legacy = @sta.parse_sdc(source, library, netlist)
  let detailed = @sta.parse_sdc_with_diagnostics(source, library, netlist)
  assert_eq(ToJson::to_json(detailed), ToJson::to_json(legacy))
  assert_eq(detailed.clock.name, "c")
  near(detailed.clock.period_seconds, 2.0e-9, tolerance=1.0e-24)
  assert_eq(detailed.input_delays.length(), 1)
  assert_eq(detailed.input_delays[0].port, "数😀")
  near(detailed.input_delays[0].rise.unwrap(), 0.2e-9, tolerance=1.0e-24)
  near(detailed.input_delays[0].fall.unwrap(), 0.2e-9, tolerance=1.0e-24)
  assert_eq(detailed.output_loads[0].port, "y")
  near(detailed.output_loads[0].rise.unwrap(), 0.1e-12, tolerance=1.0e-27)
}

///|
test "SDC JSON schema is separate and legacy analysis errors stay unchanged" {
  let source = diagnostic_prefix() + " \tset_load -min 0.1 [get_ports y]\r\n"
  let netlist = ToJson::to_json(diagnostic_netlist())
  let diagnostic = @json.parse(
    @sta.check_sdc_json(@testdata.library(), netlist.stringify(), source),
  )
  assert_eq(diagnostic, {
    "ok": false,
    "schema": "moonbit.sta.sdc.v1",
    "error": "Unsupported(\"SDC flag -min for set_load\")",
    "position": { "line": 6, "column": 3, "offset": 115 },
  })
  let request : Json = { "netlist": netlist, "sdc": source }
  let legacy = @json.parse(
    @sta.analyze_json(@testdata.library(), request.stringify()),
  )
  assert_eq(legacy, {
    "ok": false,
    "schema": "moonbit.sta.v1",
    "error": "Unsupported(\"SDC flag -min for set_load\")",
  })
  assert_eq(
    @json.parse(@sta.check_sdc_json(@testdata.library(), "{", source)),
    {
      "ok": false,
      "schema": "moonbit.sta.sdc.v1",
      "error": "InvalidInput(\"invalid netlist JSON\")",
      "position": null,
    },
  )
}
