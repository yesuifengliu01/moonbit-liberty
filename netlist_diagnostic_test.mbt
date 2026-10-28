///|
fn njson_fixture() -> Json {
  // Deliberately reverse root key order. Arrays are authored in visible order.
  {
    "nets": [
      { "name": "clk", "wire_cap_farads": 0 },
      { "name": "a", "wire_cap_farads": 0 },
      { "name": "mid", "wire_cap_farads": 0 },
      { "name": "y", "wire_cap_farads": 0 },
    ],
    "gates": [
      {
        "name": "first",
        "cell": "BUF",
        "connections": [
          { "pin": "A", "net": "a" },
          { "pin": "Y", "net": "mid" },
        ],
      },
      {
        "name": "门😀/~",
        "cell": "BUF",
        "connections": [
          { "pin": "A", "net": "mid" },
          { "pin": "Y", "net": "y" },
        ],
        "扩展/键~😀": { "保留": true },
      },
    ],
    "ports": [
      { "name": "clk", "net": "clk", "direction": "Input" },
      { "name": "数😀", "net": "a", "direction": "input" },
      { "name": "y", "net": "y", "direction": "Output" },
    ],
    "备注/键~😀": "unknown keys stay ignored",
  }
}

///|
fn njson_fields(value : Json) -> Map[String, Json] {
  guard! value is Object(fields)
  fields
}

///|
fn njson_items(value : Json, key : String) -> Array[Json] {
  guard! njson_fields(value)[key] is Array(items)
  items
}

///|
fn njson_connection(
  value : Json,
  gate : Int,
  connection : Int,
) -> Map[String, Json] {
  njson_fields(
    njson_items(njson_items(value, "gates")[gate], "connections")[connection],
  )
}

///|
fn njson_expect_error(
  value : Json,
  error : String,
  pointer : String,
) -> Unit raise {
  let before = value.stringify()
  try @sta.netlist_from_json_with_diagnostics(value) catch {
    @sta.NetlistJsonDiagnostic(original, actual) => {
      assert_eq("\{@debug.Debug::to_repr(original)}", error)
      assert_eq(actual, pointer)
    }
  } noraise {
    _ => fail("expected Netlist field diagnostic")
  }
  try @sta.netlist_from_json(value) catch {
    original => assert_eq("\{@debug.Debug::to_repr(original)}", error)
  } noraise {
    _ => fail("legacy reader unexpectedly accepted the same input")
  }
  assert_eq(value.stringify(), before)
}

///|
test "Netlist diagnostics disambiguate identical errors in separate objects" {
  let connection_error = njson_fixture()
  njson_connection(connection_error, 1, 1)["net"] = 17
  njson_expect_error(
    connection_error, "InvalidInput(\"JSON string required\")", "/gates/1/connections/1/net",
  )
  let port_error = njson_fixture()
  njson_fields(njson_items(port_error, "ports")[2])["name"] = 17
  njson_expect_error(
    port_error, "InvalidInput(\"JSON string required\")", "/ports/2/name",
  )
}

///|
test "Netlist missing fields identify the intended absent child" {
  let connection_error = njson_fixture()
  ignore(njson_connection(connection_error, 1, 1).remove("pin"))
  njson_expect_error(
    connection_error, "InvalidInput(\"missing JSON field pin\")", "/gates/1/connections/1/pin",
  )
  let gate_error = njson_fixture()
  ignore(njson_fields(njson_items(gate_error, "gates")[1]).remove("cell"))
  njson_expect_error(
    gate_error, "InvalidInput(\"missing JSON field cell\")", "/gates/1/cell",
  )
  let root_error = njson_fixture()
  ignore(njson_fields(root_error).remove("nets"))
  njson_expect_error(
    root_error, "InvalidInput(\"missing JSON field nets\")", "/nets",
  )
}

///|
test "Netlist wrong containers point to the value instead of an imagined child" {
  njson_expect_error([], "InvalidInput(\"JSON object required\")", "")
  let port_error = njson_fixture()
  njson_items(port_error, "ports")[1] = 17
  njson_expect_error(
    port_error, "InvalidInput(\"JSON object required\")", "/ports/1",
  )
  let connections_error = njson_fixture()
  njson_fields(njson_items(connections_error, "gates")[1])["connections"] = false
  njson_expect_error(
    connections_error, "InvalidInput(\"JSON array required\")", "/gates/1/connections",
  )
  let connection_error = njson_fixture()
  njson_items(njson_items(connection_error, "gates")[1], "connections")[1] = null
  njson_expect_error(
    connection_error, "InvalidInput(\"JSON object required\")", "/gates/1/connections/1",
  )
}

///|
test "Netlist first error retains field order independent of JSON key order" {
  let ports_first = njson_fixture()
  njson_fields(ports_first)["gates"] = false
  let port = njson_fields(njson_items(ports_first, "ports")[0])
  ignore(port.remove("name"))
  port["direction"] = false
  njson_expect_error(
    ports_first, "InvalidInput(\"JSON string required\")", "/ports/0/direction",
  )
  let connections_first = njson_fixture()
  njson_fields(connections_first)["nets"] = false
  ignore(
    njson_fields(njson_items(connections_first, "gates")[1]).remove("name"),
  )
  njson_connection(connections_first, 1, 0)["pin"] = false
  njson_expect_error(
    connections_first, "InvalidInput(\"JSON string required\")", "/gates/1/connections/0/pin",
  )
  let capacitance_first = njson_fixture()
  let net = njson_fields(njson_items(capacitance_first, "nets")[2])
  ignore(net.remove("name"))
  net["wire_cap_farads"] = false
  njson_expect_error(
    capacitance_first, "InvalidInput(\"JSON wire capacitance number\")", "/nets/2/wire_cap_farads",
  )
  let direction_value = njson_fixture()
  njson_fields(njson_items(direction_value, "ports")[1])["direction"] = "inout"
  njson_expect_error(
    direction_value, "InvalidInput(\"JSON port direction\")", "/ports/1/direction",
  )
}

///|
test "Netlist valid Unicode extensions aliases and decoded input are preserved" {
  let value = njson_fixture()
  let before = value.stringify()
  let legacy = @sta.netlist_from_json(value)
  let detailed = @sta.netlist_from_json_with_diagnostics(value)
  assert_eq(ToJson::to_json(detailed), ToJson::to_json(legacy))
  assert_eq(detailed.ports.length(), 3)
  assert_eq(detailed.ports[0].direction, @sta.Input)
  assert_eq(detailed.ports[1].name, "数😀")
  assert_eq(detailed.ports[2].direction, @sta.Output)
  assert_eq(detailed.gates[1].name, "门😀/~")
  assert_eq(detailed.gates[1].connections[1].pin, "Y")
  assert_eq(detailed.gates[1].connections[1].net, "y")
  assert_eq(value.stringify(), before)
  // Lower-case output is the other accepted public spelling.
  njson_fields(njson_items(value, "ports")[2])["direction"] = "output"
  assert_eq(
    @sta.netlist_from_json_with_diagnostics(value).ports[2].direction,
    @sta.Output,
  )
}

///|
test "Netlist structural diagnostics preserve numeric and empty-array acceptance" {
  let value = njson_fixture()
  njson_fields(njson_items(value, "nets")[0])["wire_cap_farads"] = -1.0e-12
  njson_fields(njson_items(value, "nets")[1])["wire_cap_farads"] = 1.0e300
  let legacy = @sta.netlist_from_json(value)
  let detailed = @sta.netlist_from_json_with_diagnostics(value)
  assert_eq(detailed.nets[0].wire_cap_farads, -1.0e-12)
  assert_eq(detailed.nets[1].wire_cap_farads, 1.0e300)
  assert_eq(ToJson::to_json(detailed), ToJson::to_json(legacy))
  assert_eq(@json.parse(@sta.check_netlist_json(value.stringify())), {
    "ok": true,
    "schema": "moonbit.sta.netlist.v1",
  })
  let empty : Json = { "ports": [], "gates": [], "nets": [], "扩展": 1 }
  let decoded = @sta.netlist_from_json_with_diagnostics(empty)
  assert_eq(decoded.ports.length(), 0)
  assert_eq(decoded.gates.length(), 0)
  assert_eq(decoded.nets.length(), 0)
}

///|
test "Netlist JSON boundary distinguishes syntax from decoded semantic root" {
  assert_eq(@json.parse(@sta.check_netlist_json("{")), {
    "ok": false,
    "schema": "moonbit.sta.netlist.v1",
    "error": "InvalidInput(\"invalid netlist JSON\")",
    "pointer": null,
  })
  assert_eq(@json.parse(@sta.check_netlist_json("[]")), {
    "ok": false,
    "schema": "moonbit.sta.netlist.v1",
    "error": "InvalidInput(\"JSON object required\")",
    "pointer": "",
  })
  let value = njson_fixture()
  njson_connection(value, 1, 1)["net"] = 17
  assert_eq(@json.parse(@sta.check_netlist_json(value.stringify())), {
    "ok": false,
    "schema": "moonbit.sta.netlist.v1",
    "error": "InvalidInput(\"JSON string required\")",
    "pointer": "/gates/1/connections/1/net",
  })
}
