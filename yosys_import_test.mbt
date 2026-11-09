///|
fn yi_fixture() -> Json {
  {
    "creator": "Yosys fixture",
    "modules": {
      "top": {
        "ports": {
          "y": { "direction": "output", "bits": [5] },
          "a": { "direction": "input", "bits": [2] },
        },
        "cells": {
          "u2": {
            "type": "INV",
            "parameters": {},
            "connections": { "Y": [5], "A": [4] },
          },
          "u1": {
            "type": "INV",
            "parameters": {},
            "connections": { "Y": [4], "A": [2] },
          },
        },
        "netnames": {
          "middle": { "bits": [4] },
          "alias/of~middle": { "bits": [4] },
        },
        "memories": {},
      },
    },
  }
}

///|
fn yi_fields(value : Json) -> Map[String, Json] {
  guard! value is Object(fields)
  fields
}

///|
fn yi_top(value : Json) -> Map[String, Json] {
  yi_fields(yi_fields(yi_fields(value)["modules"])["top"])
}

///|
fn yi_port(value : Json, name : String) -> Map[String, Json] {
  yi_fields(yi_fields(yi_top(value)["ports"])[name])
}

///|
fn yi_cell(value : Json, name : String) -> Map[String, Json] {
  yi_fields(yi_fields(yi_top(value)["cells"])[name])
}

///|
fn yi_expect_error(
  value : Json,
  module_name : String,
  pointer : String,
  fragment : String,
) -> Unit raise {
  try @sta.netlist_from_yosys_json(value, module_name) catch {
    @sta.InvalidInput(message) => {
      assert_true(message.contains("pointer \"" + pointer + "\""))
      assert_true(message.contains(fragment))
    }
    @sta.Unsupported(message) => {
      assert_true(message.contains("pointer \"" + pointer + "\""))
      assert_true(message.contains(fragment))
    }
    _ => fail("unexpected import error")
  } noraise {
    _ => fail("expected Yosys import error")
  }
}

///|
test "Yosys import keeps bit identity, aliases and deterministic order" {
  let source = yi_fixture()
  let before = source.stringify()
  let netlist = @sta.netlist_from_yosys_json(source, "top")
  assert_eq(source.stringify(), before)
  assert_eq(netlist.ports.length(), 2)
  assert_eq(netlist.ports[0].name, "a")
  assert_eq(netlist.ports[0].direction, @sta.Input)
  assert_eq(netlist.ports[0].net, "yosys_bit_2")
  assert_eq(netlist.ports[1].name, "y")
  assert_eq(netlist.ports[1].direction, @sta.Output)
  assert_eq(netlist.ports[1].net, "yosys_bit_5")
  assert_eq(netlist.gates.length(), 2)
  assert_eq(netlist.gates[0].name, "u1")
  assert_eq(netlist.gates[1].name, "u2")
  assert_eq(netlist.gates[0].connections[0].pin, "A")
  assert_eq(netlist.gates[0].connections[0].net, "yosys_bit_2")
  assert_eq(netlist.gates[0].connections[1].pin, "Y")
  assert_eq(netlist.gates[0].connections[1].net, "yosys_bit_4")
  assert_eq(netlist.gates[1].connections[0].net, "yosys_bit_4")
  assert_eq(netlist.gates[1].connections[1].net, "yosys_bit_5")
  assert_eq(netlist.nets.length(), 3)
  assert_eq(netlist.nets[0].name, "yosys_bit_2")
  assert_eq(netlist.nets[1].name, "yosys_bit_4")
  assert_eq(netlist.nets[2].name, "yosys_bit_5")
  for net in netlist.nets {
    assert_eq(net.wire_cap_farads, 0.0)
  }
}

///|
test "Yosys import rejects vector and constant bits at exact paths" {
  let vector_port = yi_fixture()
  yi_port(vector_port, "a")["bits"] = [2, 3]
  yi_expect_error(vector_port, "top", "/modules/top/ports/a/bits", "one-bit")
  let vector_pin = yi_fixture()
  yi_fields(yi_cell(vector_pin, "u1")["connections"])["A"] = [2, 3]
  yi_expect_error(
    vector_pin, "top", "/modules/top/cells/u1/connections/A", "one-bit",
  )
  let constant = yi_fixture()
  yi_fields(yi_cell(constant, "u1")["connections"])["A"] = ["0"]
  yi_expect_error(
    constant, "top", "/modules/top/cells/u1/connections/A/0", "constant",
  )
  let fractional = yi_fixture()
  yi_fields(yi_cell(fractional, "u1")["connections"])["A"] = [2.5]
  yi_expect_error(
    fractional, "top", "/modules/top/cells/u1/connections/A/0", "integer bit ID",
  )
  let malformed_string = yi_fixture()
  yi_fields(yi_cell(malformed_string, "u1")["connections"])["A"] = ["bogus"]
  try @sta.netlist_from_yosys_json(malformed_string, "top") catch {
    @sta.InvalidInput(message) => {
      assert_true(message.contains("/modules/top/cells/u1/connections/A/0"))
      assert_true(message.contains("integer bit ID"))
    }
    _ => fail("malformed string must be InvalidInput, not a constant")
  } noraise {
    _ => fail("malformed bit string was accepted")
  }
}

///|
test "Yosys import rejects unsupported structure and unmapped cells" {
  let inout = yi_fixture()
  yi_port(inout, "a")["direction"] = "inout"
  yi_expect_error(inout, "top", "/modules/top/ports/a/direction", "inout")
  let memory = yi_fixture()
  yi_top(memory)["memories"] = { "ram": { "width": 1 } }
  yi_expect_error(memory, "top", "/modules/top/memories", "memories")
  let unmapped = yi_fixture()
  yi_cell(unmapped, "u1")["type"] = "$_NOT_"
  yi_expect_error(unmapped, "top", "/modules/top/cells/u1/type", "unmapped")
  yi_expect_error(yi_fixture(), "missing", "/modules/missing", "missing field")
}

///|
test "Yosys import escapes original names in error pointers" {
  let source = yi_fixture()
  let cells = yi_fields(yi_top(source)["cells"])
  cells["u/~"] = cells["u1"]
  cells.remove("u1")
  let connections = yi_fields(yi_cell(source, "u/~")["connections"])
  connections["A/~😀"] = [2, 3]
  connections.remove("A")
  yi_expect_error(
    source, "top", "/modules/top/cells/u~1~0/connections/A~1~0😀", "one-bit",
  )
}

///|
test "Yosys import rejects hierarchy but permits declared blackbox cells" {
  let hierarchy = yi_fixture()
  let modules = yi_fields(yi_fields(hierarchy)["modules"])
  modules["INV"] = { "attributes": {}, "ports": {}, "cells": {} }
  yi_expect_error(
    hierarchy, "top", "/modules/top/cells/u1/type", "hierarchical module",
  )
  modules["INV"] = {
    "attributes": { "blackbox": "00000000000000000000000000000001" },
    "ports": {},
    "cells": {},
  }
  let imported = @sta.netlist_from_yosys_json(hierarchy, "top")
  assert_eq(imported.gates.length(), 2)
  modules["INV"] = { "attributes": { "blackbox": 1 }, "ports": {}, "cells": {} }
  assert_eq(@sta.netlist_from_yosys_json(hierarchy, "top").gates.length(), 2)
}

///|
test "Yosys import rejects oversized cell collection before sorting" {
  let source = yi_fixture()
  let cells = yi_fields(yi_top(source)["cells"])
  for index in 0..<100001 {
    cells["u" + index.to_string()] = {}
  }
  yi_expect_error(source, "top", "/modules/top/cells", "cell budget")
}
