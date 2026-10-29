///|
/// Complete pre-fix named-graph membership and original output facts.
pub fn cycle_diagnosis_cases() -> String {
  let text =
    #|{
    #|  "basis": "21 full hand-defined directed graph/participant/order/precedence facts before fix. All complete old responses actual;3 healthy and3 earlier-error controls remain byte-identical. Corrected cycle lists are literal manual facts, not generated SCC results. Primary old repro and preparation02 matching captures reused without repeating. Original name-collision bad graph retained as an explicit unchanged precedence control; only symbolic test instance a/b/c/d names prefixed g. New generated128-tail topology has manually fixed sole cycle loop, not an old/scientific trial.",
    #|  "libraries": {
    #|    "buf": "library (cycle_diagnosis) {\n  time_unit : \"1ns\";\n  capacitive_load_unit (1,pf);\n  delay_model : table_lookup;\n  lu_table_template (line) { variable_1 : input_net_transition; index_1 (\"0,1\"); }\n  cell (BUF) {\n    pin (A) { direction : input; capacitance : 0; }\n    pin (Z) { direction : output; function : \"A\";\n      timing () { related_pin : \"A\"; timing_sense : positive_unate;\n        cell_rise (line) { values (\"0.25,0.25\"); }\n        cell_fall (line) { values (\"0.25,0.25\"); }\n        rise_transition (line) { values (\"0.1,0.1\"); }\n        fall_transition (line) { values (\"0.1,0.1\"); }\n      }\n    }\n  }\n}\n",
    #|    "full": "library (cycle_diagnosis) {\n  time_unit : \"1ns\";\n  capacitive_load_unit (1,pf);\n  delay_model : table_lookup;\n  lu_table_template (line) { variable_1 : input_net_transition; index_1 (\"0,1\"); }\n  cell (BUF) {\n    pin (A) { direction : input; capacitance : 0; }\n    pin (Z) { direction : output; function : \"A\";\n      timing () { related_pin : \"A\"; timing_sense : positive_unate;\n        cell_rise (line) { values (\"0.25,0.25\"); }\n        cell_fall (line) { values (\"0.25,0.25\"); }\n        rise_transition (line) { values (\"0.1,0.1\"); }\n        fall_transition (line) { values (\"0.1,0.1\"); }\n      }\n    }\n  }\n  cell (JOIN2) {\n    pin (A) { direction : input; capacitance : 0; }\n    pin (B) { direction : input; capacitance : 0; }\n    pin (Z) { direction : output; function : \"A & B\";\n      timing () { related_pin : \"A\"; timing_sense : positive_unate;\n        cell_rise (line) { values (\"0.25,0.25\"); }\n        cell_fall (line) { values (\"0.25,0.25\"); }\n        rise_transition (line) { values (\"0.1,0.1\"); }\n        fall_transition (line) { values (\"0.1,0.1\"); }\n      }\n      timing () { related_pin : \"B\"; timing_sense : positive_unate;\n        cell_rise (line) { values (\"0.25,0.25\"); }\n        cell_fall (line) { values (\"0.25,0.25\"); }\n        rise_transition (line) { values (\"0.1,0.1\"); }\n        fall_transition (line) { values (\"0.1,0.1\"); }\n      }\n    }\n  }\n  cell (DUAL) {\n    pin (A) { direction : input; capacitance : 0; }\n    pin (B) { direction : input; capacitance : 0; }\n    pin (X) { direction : output; function : \"A\";\n      timing () { related_pin : \"A\"; timing_sense : positive_unate;\n        cell_rise (line) { values (\"0.25,0.25\"); }\n        cell_fall (line) { values (\"0.25,0.25\"); }\n        rise_transition (line) { values (\"0.1,0.1\"); }\n        fall_transition (line) { values (\"0.1,0.1\"); }\n      }\n    }\n    pin (Y) { direction : output; function : \"B\";\n      timing () { related_pin : \"B\"; timing_sense : positive_unate;\n        cell_rise (line) { values (\"0.25,0.25\"); }\n        cell_fall (line) { values (\"0.25,0.25\"); }\n        rise_transition (line) { values (\"0.1,0.1\"); }\n        fall_transition (line) { values (\"0.1,0.1\"); }\n      }\n    }\n  }\n}\n"
    #|  },
    #|  "cases": [
    #|    {
    #|      "name": "self-loop-tail",
    #|      "group": "descendants",
    #|      "library": "buf",
    #|      "request": "{\r\n  \"netlist\": {\r\n    \"ports\": [\r\n      {\r\n        \"name\": \"clk\",\r\n        \"net\": \"clk\",\r\n        \"direction\": \"input\"\r\n      },\r\n      {\r\n        \"name\": \"a\",\r\n        \"net\": \"a\",\r\n        \"direction\": \"input\"\r\n      },\r\n      {\r\n        \"name\": \"out\",\r\n        \"net\": \"tail_n\",\r\n        \"direction\": \"output\"\r\n      }\r\n    ],\r\n    \"gates\": [\r\n      {\r\n        \"name\": \"loop\",\r\n        \"cell\": \"BUF\",\r\n        \"connections\": [\r\n          {\r\n            \"pin\": \"A\",\r\n            \"net\": \"loop_n\"\r\n          },\r\n          {\r\n            \"pin\": \"Z\",\r\n            \"net\": \"loop_n\"\r\n          }\r\n        ]\r\n      },\r\n      {\r\n        \"name\": \"tail\",\r\n        \"cell\": \"BUF\",\r\n        \"connections\": [\r\n          {\r\n            \"pin\": \"A\",\r\n            \"net\": \"loop_n\"\r\n          },\r\n          {\r\n            \"pin\": \"Z\",\r\n            \"net\": \"tail_n\"\r\n          }\r\n        ]\r\n      }\r\n    ],\r\n    \"nets\": [\r\n      {\r\n        \"name\": \"clk\",\r\n        \"wire_cap_farads\": 0\r\n      },\r\n      {\r\n        \"name\": \"a\",\r\n        \"wire_cap_farads\": 0\r\n      },\r\n      {\r\n        \"name\": \"loop_n\",\r\n        \"wire_cap_farads\": 0\r\n      },\r\n      {\r\n        \"name\": \"tail_n\",\r\n        \"wire_cap_farads\": 0\r\n      }\r\n    ]\r\n  },\r\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\r\n}\r\n",
    #|      "expected_cycle_instances": [
    #|        "loop"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "loop",
    #|        "tail"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": true,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"loop\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\", \"tail\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "self-loop-only",
    #|      "group": "descendants",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"n\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"loop\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"n\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"n\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "loop"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "loop"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"loop\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "two-node-tail",
    #|      "group": "components",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"ga\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"b_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"a_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"gb\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"b_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"b_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "ga",
    #|        "gb"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "ga",
    #|        "gb",
    #|        "tail"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"ga\\\", \\\"gb\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"ga\", \"gb\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"ga\", \"gb\", \"tail\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "prefix-loop-tail",
    #|      "group": "descendants",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"prefix\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"p\"\n          }\n        ]\n      },\n      {\n        \"name\": \"loop\",\n        \"cell\": \"JOIN2\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"B\",\n            \"net\": \"p\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"p\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "loop"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "loop",
    #|        "tail"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"loop\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\", \"tail\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "disjoint-cycles",
    #|      "group": "components",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"ga\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"b_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"a_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"gb\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"b_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"gc\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"c_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"c_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"merge\",\n        \"cell\": \"JOIN2\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"b_n\"\n          },\n          {\n            \"pin\": \"B\",\n            \"net\": \"c_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"m\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"m\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"b_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"c_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"m\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "ga",
    #|        "gb",
    #|        "gc"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "ga",
    #|        "gb",
    #|        "gc",
    #|        "merge",
    #|        "tail"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"ga\\\", \\\"gb\\\", \\\"gc\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"ga\", \"gb\", \"gc\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"ga\", \"gb\", \"gc\", \"merge\", \"tail\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "one-way-connected-cycles",
    #|      "group": "components",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"ga\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"b_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"a_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"gb\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"b_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"gc\",\n        \"cell\": \"JOIN2\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"c_n\"\n          },\n          {\n            \"pin\": \"B\",\n            \"net\": \"b_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"c_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"c_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"b_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"c_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "ga",
    #|        "gb",
    #|        "gc"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "ga",
    #|        "gb",
    #|        "gc",
    #|        "tail"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"ga\\\", \\\"gb\\\", \\\"gc\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"ga\", \"gb\", \"gc\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"ga\", \"gb\", \"gc\", \"tail\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "cross-edge-scc",
    #|      "group": "components",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"ga\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"c_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"a_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"gb\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"b_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"gc\",\n        \"cell\": \"JOIN2\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"b_n\"\n          },\n          {\n            \"pin\": \"B\",\n            \"net\": \"d_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"c_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"gd\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"b_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"d_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"c_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"c_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"b_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"d_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "ga",
    #|        "gb",
    #|        "gc",
    #|        "gd"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "ga",
    #|        "gb",
    #|        "gc",
    #|        "gd",
    #|        "tail"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"ga\\\", \\\"gb\\\", \\\"gc\\\", \\\"gd\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"ga\", \"gb\", \"gc\", \"gd\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"ga\", \"gb\", \"gc\", \"gd\", \"tail\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "bridge-between-cycles",
    #|      "group": "components",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"ga\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"a_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"bridge\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"m\"\n          }\n        ]\n      },\n      {\n        \"name\": \"gc\",\n        \"cell\": \"JOIN2\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"c_n\"\n          },\n          {\n            \"pin\": \"B\",\n            \"net\": \"m\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"c_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"c_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"m\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"c_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "ga",
    #|        "gc"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "ga",
    #|        "bridge",
    #|        "gc",
    #|        "tail"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"ga\\\", \\\"gc\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"ga\", \"gc\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"ga\", \"bridge\", \"gc\", \"tail\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "declaration-order",
    #|      "group": "identity",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      },\n      {\n        \"name\": \"gb\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"b_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"ga\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"b_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"a_n\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"b_n\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "gb",
    #|        "ga"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "tail",
    #|        "gb",
    #|        "ga"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"gb\\\", \\\"ga\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"gb\", \"ga\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"tail\", \"gb\", \"ga\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "one-cyclic-output",
    #|      "group": "outputs",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"split\",\n        \"cell\": \"DUAL\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"x\"\n          },\n          {\n            \"pin\": \"B\",\n            \"net\": \"a\"\n          },\n          {\n            \"pin\": \"X\",\n            \"net\": \"x\"\n          },\n          {\n            \"pin\": \"Y\",\n            \"net\": \"y\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"x\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"x\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"y\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "split"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "split",
    #|        "tail"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"split\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"split\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"split\", \"tail\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "two-self-output-cycles",
    #|      "group": "outputs",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"split\",\n        \"cell\": \"DUAL\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"x\"\n          },\n          {\n            \"pin\": \"B\",\n            \"net\": \"y\"\n          },\n          {\n            \"pin\": \"X\",\n            \"net\": \"x\"\n          },\n          {\n            \"pin\": \"Y\",\n            \"net\": \"y\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"JOIN2\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"x\"\n          },\n          {\n            \"pin\": \"B\",\n            \"net\": \"y\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"x\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"y\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "split"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "split",
    #|        "tail"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"split\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"split\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"split\", \"tail\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "two-output-mutual-cycle",
    #|      "group": "outputs",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"split\",\n        \"cell\": \"DUAL\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"y\"\n          },\n          {\n            \"pin\": \"B\",\n            \"net\": \"x\"\n          },\n          {\n            \"pin\": \"X\",\n            \"net\": \"x\"\n          },\n          {\n            \"pin\": \"Y\",\n            \"net\": \"y\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"x\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"y\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"x\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "split"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "split",
    #|        "tail"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"split\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"split\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"split\", \"tail\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "output-channel-dag",
    #|      "group": "healthy",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"x\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"split\",\n        \"cell\": \"DUAL\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"b_n\"\n          },\n          {\n            \"pin\": \"B\",\n            \"net\": \"a\"\n          },\n          {\n            \"pin\": \"X\",\n            \"net\": \"x\"\n          },\n          {\n            \"pin\": \"Y\",\n            \"net\": \"y\"\n          }\n        ]\n      },\n      {\n        \"name\": \"bridge\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"y\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"b_n\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"b_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"x\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"y\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": null,
    #|      "expected_before_cycle_instances": null,
    #|      "expected_kind": "Success",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":true,\"schema\":\"moonbit.sta.v1\",\"result\":{\"nodes\":[{\"pin\":\"clk\",\"edge\":\"Rise\",\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[],\"slew_contributor\":\"clk\"},{\"pin\":\"clk\",\"edge\":\"Fall\",\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[],\"slew_contributor\":\"clk\"},{\"pin\":\"a\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"}],\"slew_contributor\":\"a\"},{\"pin\":\"a\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"}],\"slew_contributor\":\"a\"},{\"pin\":\"split/Y\",\"edge\":\"Rise\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"}],\"slew_contributor\":\"split/B\"},{\"pin\":\"split/Y\",\"edge\":\"Fall\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"}],\"slew_contributor\":\"split/B\"},{\"pin\":\"bridge/Z\",\"edge\":\"Rise\",\"arrival_seconds\":1.5e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"bridge/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"}],\"slew_contributor\":\"bridge/A\"},{\"pin\":\"bridge/Z\",\"edge\":\"Fall\",\"arrival_seconds\":1.5e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"bridge/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"}],\"slew_contributor\":\"bridge/A\"},{\"pin\":\"split/X\",\"edge\":\"Rise\",\"arrival_seconds\":1.75e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"bridge/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"split/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"},{\"pin\":\"split/X\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.75e-9,\"arc\":\"A->X\"}],\"slew_contributor\":\"split/A\"},{\"pin\":\"split/X\",\"edge\":\"Fall\",\"arrival_seconds\":1.75e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"bridge/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"split/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"},{\"pin\":\"split/X\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.75e-9,\"arc\":\"A->X\"}],\"slew_contributor\":\"split/A\"},{\"pin\":\"split/A\",\"edge\":\"Rise\",\"arrival_seconds\":1.5e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"bridge/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"split/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"}],\"slew_contributor\":\"bridge/A\"},{\"pin\":\"split/A\",\"edge\":\"Fall\",\"arrival_seconds\":1.5e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"bridge/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"split/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"}],\"slew_contributor\":\"bridge/A\"},{\"pin\":\"split/B\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}],\"slew_contributor\":\"a\"},{\"pin\":\"split/B\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}],\"slew_contributor\":\"a\"},{\"pin\":\"bridge/A\",\"edge\":\"Rise\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"}],\"slew_contributor\":\"split/B\"},{\"pin\":\"bridge/A\",\"edge\":\"Fall\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"}],\"slew_contributor\":\"split/B\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"arrival_seconds\":1.75e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"bridge/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"split/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"},{\"pin\":\"split/X\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.75e-9,\"arc\":\"A->X\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.75e-9,\"arc\":\"net\"}],\"slew_contributor\":\"split/A\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"arrival_seconds\":1.75e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"bridge/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"split/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"},{\"pin\":\"split/X\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.75e-9,\"arc\":\"A->X\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.75e-9,\"arc\":\"net\"}],\"slew_contributor\":\"split/A\"}],\"endpoints\":[{\"pin\":\"out\",\"edge\":\"Rise\",\"arrival_seconds\":1.75e-9,\"required_seconds\":3.0000000000000004e-9,\"slack_seconds\":1.2500000000000002e-9,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"bridge/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"split/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"},{\"pin\":\"split/X\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.75e-9,\"arc\":\"A->X\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.75e-9,\"arc\":\"net\"}]},{\"pin\":\"out\",\"edge\":\"Fall\",\"arrival_seconds\":1.75e-9,\"required_seconds\":3.0000000000000004e-9,\"slack_seconds\":1.2500000000000002e-9,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"split/B\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"split/Y\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"B->Y\"},{\"pin\":\"bridge/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"bridge/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"split/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"},{\"pin\":\"split/X\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.75e-9,\"arc\":\"A->X\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.75e-9,\"arc\":\"net\"}]}],\"worst_slack_seconds\":1.2500000000000002e-9,\"diagnostics\":[\"graph-based max-arrival/max-slew propagation; zero wire resistance and delay\"],\"topological_order\":[\"split\",\"bridge\",\"split\"]}}\n",
    #|      "expected_exit": 0,
    #|      "expected": {
    #|        "ok": true,
    #|        "schema": "moonbit.sta.v1",
    #|        "result": {
    #|          "nodes": [
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Rise",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Fall",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "split/Y",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/B"
    #|            },
    #|            {
    #|              "pin": "split/Y",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/B"
    #|            },
    #|            {
    #|              "pin": "bridge/Z",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "bridge/A"
    #|            },
    #|            {
    #|              "pin": "bridge/Z",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "bridge/A"
    #|            },
    #|            {
    #|              "pin": "split/X",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.75e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/A"
    #|            },
    #|            {
    #|              "pin": "split/X",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.75e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/A"
    #|            },
    #|            {
    #|              "pin": "split/A",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "bridge/A"
    #|            },
    #|            {
    #|              "pin": "split/A",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "bridge/A"
    #|            },
    #|            {
    #|              "pin": "split/B",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "split/B",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "bridge/A",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/B"
    #|            },
    #|            {
    #|              "pin": "bridge/A",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/B"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.75e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/A"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.75e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/A"
    #|            }
    #|          ],
    #|          "endpoints": [
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.75e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 1.2500000000000002e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.75e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 1.2500000000000002e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            }
    #|          ],
    #|          "worst_slack_seconds": 1.2500000000000002e-09,
    #|          "diagnostics": [
    #|            "graph-based max-arrival/max-slew propagation; zero wire resistance and delay"
    #|          ],
    #|          "topological_order": [
    #|            "split",
    #|            "bridge",
    #|            "split"
    #|          ]
    #|        }
    #|      },
    #|      "expected_before": {
    #|        "ok": true,
    #|        "schema": "moonbit.sta.v1",
    #|        "result": {
    #|          "nodes": [
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Rise",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Fall",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "split/Y",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/B"
    #|            },
    #|            {
    #|              "pin": "split/Y",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/B"
    #|            },
    #|            {
    #|              "pin": "bridge/Z",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "bridge/A"
    #|            },
    #|            {
    #|              "pin": "bridge/Z",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "bridge/A"
    #|            },
    #|            {
    #|              "pin": "split/X",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.75e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/A"
    #|            },
    #|            {
    #|              "pin": "split/X",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.75e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/A"
    #|            },
    #|            {
    #|              "pin": "split/A",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "bridge/A"
    #|            },
    #|            {
    #|              "pin": "split/A",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "bridge/A"
    #|            },
    #|            {
    #|              "pin": "split/B",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "split/B",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "bridge/A",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/B"
    #|            },
    #|            {
    #|              "pin": "bridge/A",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/B"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.75e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/A"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.75e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "split/A"
    #|            }
    #|          ],
    #|          "endpoints": [
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.75e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 1.2500000000000002e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.75e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 1.2500000000000002e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "split/B",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/Y",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "B->Y"
    #|                },
    #|                {
    #|                  "pin": "bridge/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "bridge/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "split/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "split/X",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "A->X"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.75e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            }
    #|          ],
    #|          "worst_slack_seconds": 1.2500000000000002e-09,
    #|          "diagnostics": [
    #|            "graph-based max-arrival/max-slew propagation; zero wire resistance and delay"
    #|          ],
    #|          "topological_order": [
    #|            "split",
    #|            "bridge",
    #|            "split"
    #|          ]
    #|        }
    #|      }
    #|    },
    #|    {
    #|      "name": "raw-unicode-instance",
    #|      "group": "identity",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"loop/~😀\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail~1/~😀\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "loop/~😀"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "loop/~😀",
    #|        "tail~1/~😀"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"loop/~😀\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"loop/~😀\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"loop/~😀\", \"tail~1/~😀\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "raw-escape-like-instances",
    #|      "group": "identity",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"u/Y\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"u~1Y\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "u/Y"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "u/Y",
    #|        "u~1Y"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"u/Y\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"u/Y\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"u/Y\", \"u~1Y\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "long-blocked-tail",
    #|      "group": "descendants",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t127\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"loop\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail0\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t0\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail1\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t0\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t1\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail2\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t1\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t2\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail3\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t2\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t3\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail4\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t3\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t4\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail5\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t4\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t5\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail6\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t5\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t6\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail7\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t6\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t7\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail8\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t7\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t8\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail9\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t8\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t9\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail10\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t9\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t10\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail11\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t10\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t11\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail12\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t11\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t12\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail13\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t12\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t13\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail14\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t13\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t14\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail15\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t14\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t15\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail16\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t15\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t16\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail17\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t16\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t17\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail18\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t17\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t18\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail19\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t18\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t19\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail20\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t19\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t20\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail21\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t20\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t21\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail22\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t21\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t22\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail23\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t22\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t23\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail24\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t23\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t24\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail25\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t24\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t25\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail26\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t25\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t26\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail27\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t26\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t27\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail28\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t27\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t28\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail29\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t28\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t29\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail30\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t29\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t30\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail31\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t30\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t31\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail32\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t31\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t32\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail33\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t32\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t33\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail34\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t33\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t34\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail35\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t34\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t35\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail36\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t35\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t36\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail37\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t36\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t37\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail38\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t37\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t38\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail39\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t38\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t39\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail40\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t39\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t40\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail41\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t40\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t41\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail42\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t41\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t42\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail43\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t42\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t43\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail44\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t43\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t44\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail45\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t44\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t45\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail46\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t45\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t46\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail47\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t46\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t47\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail48\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t47\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t48\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail49\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t48\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t49\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail50\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t49\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t50\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail51\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t50\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t51\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail52\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t51\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t52\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail53\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t52\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t53\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail54\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t53\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t54\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail55\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t54\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t55\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail56\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t55\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t56\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail57\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t56\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t57\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail58\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t57\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t58\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail59\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t58\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t59\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail60\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t59\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t60\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail61\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t60\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t61\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail62\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t61\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t62\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail63\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t62\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t63\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail64\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t63\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t64\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail65\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t64\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t65\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail66\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t65\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t66\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail67\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t66\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t67\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail68\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t67\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t68\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail69\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t68\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t69\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail70\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t69\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t70\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail71\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t70\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t71\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail72\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t71\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t72\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail73\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t72\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t73\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail74\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t73\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t74\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail75\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t74\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t75\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail76\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t75\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t76\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail77\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t76\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t77\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail78\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t77\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t78\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail79\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t78\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t79\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail80\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t79\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t80\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail81\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t80\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t81\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail82\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t81\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t82\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail83\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t82\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t83\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail84\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t83\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t84\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail85\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t84\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t85\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail86\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t85\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t86\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail87\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t86\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t87\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail88\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t87\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t88\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail89\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t88\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t89\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail90\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t89\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t90\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail91\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t90\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t91\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail92\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t91\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t92\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail93\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t92\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t93\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail94\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t93\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t94\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail95\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t94\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t95\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail96\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t95\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t96\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail97\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t96\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t97\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail98\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t97\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t98\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail99\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t98\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t99\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail100\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t99\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t100\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail101\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t100\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t101\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail102\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t101\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t102\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail103\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t102\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t103\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail104\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t103\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t104\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail105\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t104\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t105\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail106\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t105\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t106\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail107\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t106\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t107\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail108\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t107\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t108\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail109\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t108\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t109\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail110\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t109\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t110\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail111\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t110\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t111\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail112\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t111\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t112\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail113\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t112\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t113\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail114\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t113\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t114\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail115\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t114\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t115\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail116\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t115\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t116\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail117\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t116\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t117\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail118\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t117\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t118\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail119\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t118\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t119\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail120\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t119\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t120\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail121\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t120\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t121\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail122\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t121\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t122\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail123\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t122\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t123\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail124\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t123\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t124\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail125\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t124\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t125\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail126\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t125\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t126\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail127\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"t126\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t127\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t0\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t1\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t2\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t3\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t4\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t5\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t6\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t7\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t8\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t9\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t10\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t11\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t12\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t13\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t14\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t15\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t16\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t17\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t18\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t19\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t20\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t21\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t22\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t23\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t24\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t25\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t26\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t27\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t28\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t29\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t30\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t31\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t32\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t33\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t34\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t35\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t36\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t37\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t38\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t39\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t40\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t41\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t42\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t43\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t44\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t45\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t46\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t47\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t48\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t49\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t50\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t51\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t52\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t53\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t54\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t55\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t56\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t57\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t58\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t59\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t60\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t61\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t62\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t63\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t64\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t65\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t66\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t67\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t68\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t69\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t70\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t71\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t72\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t73\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t74\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t75\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t76\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t77\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t78\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t79\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t80\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t81\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t82\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t83\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t84\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t85\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t86\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t87\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t88\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t89\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t90\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t91\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t92\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t93\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t94\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t95\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t96\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t97\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t98\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t99\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t100\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t101\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t102\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t103\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t104\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t105\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t106\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t107\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t108\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t109\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t110\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t111\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t112\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t113\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t114\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t115\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t116\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t117\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t118\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t119\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t120\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t121\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t122\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t123\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t124\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t125\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t126\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t127\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": [
    #|        "loop"
    #|      ],
    #|      "expected_before_cycle_instances": [
    #|        "loop",
    #|        "tail0",
    #|        "tail1",
    #|        "tail2",
    #|        "tail3",
    #|        "tail4",
    #|        "tail5",
    #|        "tail6",
    #|        "tail7",
    #|        "tail8",
    #|        "tail9",
    #|        "tail10",
    #|        "tail11",
    #|        "tail12",
    #|        "tail13",
    #|        "tail14",
    #|        "tail15",
    #|        "tail16",
    #|        "tail17",
    #|        "tail18",
    #|        "tail19",
    #|        "tail20",
    #|        "tail21",
    #|        "tail22",
    #|        "tail23",
    #|        "tail24",
    #|        "tail25",
    #|        "tail26",
    #|        "tail27",
    #|        "tail28",
    #|        "tail29",
    #|        "tail30",
    #|        "tail31",
    #|        "tail32",
    #|        "tail33",
    #|        "tail34",
    #|        "tail35",
    #|        "tail36",
    #|        "tail37",
    #|        "tail38",
    #|        "tail39",
    #|        "tail40",
    #|        "tail41",
    #|        "tail42",
    #|        "tail43",
    #|        "tail44",
    #|        "tail45",
    #|        "tail46",
    #|        "tail47",
    #|        "tail48",
    #|        "tail49",
    #|        "tail50",
    #|        "tail51",
    #|        "tail52",
    #|        "tail53",
    #|        "tail54",
    #|        "tail55",
    #|        "tail56",
    #|        "tail57",
    #|        "tail58",
    #|        "tail59",
    #|        "tail60",
    #|        "tail61",
    #|        "tail62",
    #|        "tail63",
    #|        "tail64",
    #|        "tail65",
    #|        "tail66",
    #|        "tail67",
    #|        "tail68",
    #|        "tail69",
    #|        "tail70",
    #|        "tail71",
    #|        "tail72",
    #|        "tail73",
    #|        "tail74",
    #|        "tail75",
    #|        "tail76",
    #|        "tail77",
    #|        "tail78",
    #|        "tail79",
    #|        "tail80",
    #|        "tail81",
    #|        "tail82",
    #|        "tail83",
    #|        "tail84",
    #|        "tail85",
    #|        "tail86",
    #|        "tail87",
    #|        "tail88",
    #|        "tail89",
    #|        "tail90",
    #|        "tail91",
    #|        "tail92",
    #|        "tail93",
    #|        "tail94",
    #|        "tail95",
    #|        "tail96",
    #|        "tail97",
    #|        "tail98",
    #|        "tail99",
    #|        "tail100",
    #|        "tail101",
    #|        "tail102",
    #|        "tail103",
    #|        "tail104",
    #|        "tail105",
    #|        "tail106",
    #|        "tail107",
    #|        "tail108",
    #|        "tail109",
    #|        "tail110",
    #|        "tail111",
    #|        "tail112",
    #|        "tail113",
    #|        "tail114",
    #|        "tail115",
    #|        "tail116",
    #|        "tail117",
    #|        "tail118",
    #|        "tail119",
    #|        "tail120",
    #|        "tail121",
    #|        "tail122",
    #|        "tail123",
    #|        "tail124",
    #|        "tail125",
    #|        "tail126",
    #|        "tail127"
    #|      ],
    #|      "expected_kind": "CombinationalLoopDetected",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"CombinationalLoopDetected([\\\"loop\\\"])\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\"])"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected(\n  [\n    \"loop\",\n    \"tail0\",\n    \"tail1\",\n    \"tail2\",\n    \"tail3\",\n    \"tail4\",\n    \"tail5\",\n    \"tail6\",\n    \"tail7\",\n    \"tail8\",\n    \"tail9\",\n    \"tail10\",\n    \"tail11\",\n    \"tail12\",\n    \"tail13\",\n    \"tail14\",\n    \"tail15\",\n    \"tail16\",\n    \"tail17\",\n    \"tail18\",\n    \"tail19\",\n    \"tail20\",\n    \"tail21\",\n    \"tail22\",\n    \"tail23\",\n    \"tail24\",\n    \"tail25\",\n    \"tail26\",\n    \"tail27\",\n    \"tail28\",\n    \"tail29\",\n    \"tail30\",\n    \"tail31\",\n    \"tail32\",\n    \"tail33\",\n    \"tail34\",\n    \"tail35\",\n    \"tail36\",\n    \"tail37\",\n    \"tail38\",\n    \"tail39\",\n    \"tail40\",\n    \"tail41\",\n    \"tail42\",\n    \"tail43\",\n    \"tail44\",\n    \"tail45\",\n    \"tail46\",\n    \"tail47\",\n    \"tail48\",\n    \"tail49\",\n    \"tail50\",\n    \"tail51\",\n    \"tail52\",\n    \"tail53\",\n    \"tail54\",\n    \"tail55\",\n    \"tail56\",\n    \"tail57\",\n    \"tail58\",\n    \"tail59\",\n    \"tail60\",\n    \"tail61\",\n    \"tail62\",\n    \"tail63\",\n    \"tail64\",\n    \"tail65\",\n    \"tail66\",\n    \"tail67\",\n    \"tail68\",\n    \"tail69\",\n    \"tail70\",\n    \"tail71\",\n    \"tail72\",\n    \"tail73\",\n    \"tail74\",\n    \"tail75\",\n    \"tail76\",\n    \"tail77\",\n    \"tail78\",\n    \"tail79\",\n    \"tail80\",\n    \"tail81\",\n    \"tail82\",\n    \"tail83\",\n    \"tail84\",\n    \"tail85\",\n    \"tail86\",\n    \"tail87\",\n    \"tail88\",\n    \"tail89\",\n    \"tail90\",\n    \"tail91\",\n    \"tail92\",\n    \"tail93\",\n    \"tail94\",\n    \"tail95\",\n    \"tail96\",\n    \"tail97\",\n    \"tail98\",\n    \"tail99\",\n    \"tail100\",\n    \"tail101\",\n    \"tail102\",\n    \"tail103\",\n    \"tail104\",\n    \"tail105\",\n    \"tail106\",\n    \"tail107\",\n    \"tail108\",\n    \"tail109\",\n    \"tail110\",\n    \"tail111\",\n    \"tail112\",\n    \"tail113\",\n    \"tail114\",\n    \"tail115\",\n    \"tail116\",\n    \"tail117\",\n    \"tail118\",\n    \"tail119\",\n    \"tail120\",\n    \"tail121\",\n    \"tail122\",\n    \"tail123\",\n    \"tail124\",\n    \"tail125\",\n    \"tail126\",\n    \"tail127\",\n  ],\n)"
    #|      }
    #|    },
    #|    {
    #|      "name": "direct-port-dag",
    #|      "group": "healthy",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"a\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": null,
    #|      "expected_before_cycle_instances": null,
    #|      "expected_kind": "Success",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":true,\"schema\":\"moonbit.sta.v1\",\"result\":{\"nodes\":[{\"pin\":\"clk\",\"edge\":\"Rise\",\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[],\"slew_contributor\":\"clk\"},{\"pin\":\"clk\",\"edge\":\"Fall\",\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[],\"slew_contributor\":\"clk\"},{\"pin\":\"a\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"}],\"slew_contributor\":\"a\"},{\"pin\":\"a\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"}],\"slew_contributor\":\"a\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}],\"slew_contributor\":\"a\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}],\"slew_contributor\":\"a\"}],\"endpoints\":[{\"pin\":\"out\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"required_seconds\":3.0000000000000004e-9,\"slack_seconds\":2e-9,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}]},{\"pin\":\"out\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"required_seconds\":3.0000000000000004e-9,\"slack_seconds\":2e-9,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}]}],\"worst_slack_seconds\":2e-9,\"diagnostics\":[\"graph-based max-arrival/max-slew propagation; zero wire resistance and delay\"],\"topological_order\":[]}}\n",
    #|      "expected_exit": 0,
    #|      "expected": {
    #|        "ok": true,
    #|        "schema": "moonbit.sta.v1",
    #|        "result": {
    #|          "nodes": [
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Rise",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Fall",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            }
    #|          ],
    #|          "endpoints": [
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 2e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 2e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            }
    #|          ],
    #|          "worst_slack_seconds": 2e-09,
    #|          "diagnostics": [
    #|            "graph-based max-arrival/max-slew propagation; zero wire resistance and delay"
    #|          ],
    #|          "topological_order": []
    #|        }
    #|      },
    #|      "expected_before": {
    #|        "ok": true,
    #|        "schema": "moonbit.sta.v1",
    #|        "result": {
    #|          "nodes": [
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Rise",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Fall",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            }
    #|          ],
    #|          "endpoints": [
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 2e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 2e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            }
    #|          ],
    #|          "worst_slack_seconds": 2e-09,
    #|          "diagnostics": [
    #|            "graph-based max-arrival/max-slew propagation; zero wire resistance and delay"
    #|          ],
    #|          "topological_order": []
    #|        }
    #|      }
    #|    },
    #|    {
    #|      "name": "buffer-chain-dag",
    #|      "group": "healthy",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"z\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"first\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"m\"\n          }\n        ]\n      },\n      {\n        \"name\": \"second\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"m\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"z\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"m\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"z\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": null,
    #|      "expected_before_cycle_instances": null,
    #|      "expected_kind": "Success",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":true,\"schema\":\"moonbit.sta.v1\",\"result\":{\"nodes\":[{\"pin\":\"clk\",\"edge\":\"Rise\",\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[],\"slew_contributor\":\"clk\"},{\"pin\":\"clk\",\"edge\":\"Fall\",\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[],\"slew_contributor\":\"clk\"},{\"pin\":\"a\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"}],\"slew_contributor\":\"a\"},{\"pin\":\"a\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"}],\"slew_contributor\":\"a\"},{\"pin\":\"first/Z\",\"edge\":\"Rise\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"first/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Z\"}],\"slew_contributor\":\"first/A\"},{\"pin\":\"first/Z\",\"edge\":\"Fall\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"first/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Z\"}],\"slew_contributor\":\"first/A\"},{\"pin\":\"second/Z\",\"edge\":\"Rise\",\"arrival_seconds\":1.5e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"first/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Z\"},{\"pin\":\"second/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"second/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"}],\"slew_contributor\":\"second/A\"},{\"pin\":\"second/Z\",\"edge\":\"Fall\",\"arrival_seconds\":1.5e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"first/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Z\"},{\"pin\":\"second/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"second/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"}],\"slew_contributor\":\"second/A\"},{\"pin\":\"first/A\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}],\"slew_contributor\":\"a\"},{\"pin\":\"first/A\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}],\"slew_contributor\":\"a\"},{\"pin\":\"second/A\",\"edge\":\"Rise\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"first/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Z\"},{\"pin\":\"second/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"}],\"slew_contributor\":\"first/A\"},{\"pin\":\"second/A\",\"edge\":\"Fall\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"first/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Z\"},{\"pin\":\"second/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"}],\"slew_contributor\":\"first/A\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"arrival_seconds\":1.5e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"first/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Z\"},{\"pin\":\"second/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"second/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"}],\"slew_contributor\":\"second/A\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"arrival_seconds\":1.5e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"first/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Z\"},{\"pin\":\"second/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"second/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"}],\"slew_contributor\":\"second/A\"}],\"endpoints\":[{\"pin\":\"out\",\"edge\":\"Rise\",\"arrival_seconds\":1.5e-9,\"required_seconds\":3.0000000000000004e-9,\"slack_seconds\":1.5000000000000002e-9,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"first/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Z\"},{\"pin\":\"second/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"second/Z\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"}]},{\"pin\":\"out\",\"edge\":\"Fall\",\"arrival_seconds\":1.5e-9,\"required_seconds\":3.0000000000000004e-9,\"slack_seconds\":1.5000000000000002e-9,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"first/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"first/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Z\"},{\"pin\":\"second/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"},{\"pin\":\"second/Z\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.5e-9,\"arc\":\"A->Z\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.5e-9,\"arc\":\"net\"}]}],\"worst_slack_seconds\":1.5000000000000002e-9,\"diagnostics\":[\"graph-based max-arrival/max-slew propagation; zero wire resistance and delay\"],\"topological_order\":[\"first\",\"second\"]}}\n",
    #|      "expected_exit": 0,
    #|      "expected": {
    #|        "ok": true,
    #|        "schema": "moonbit.sta.v1",
    #|        "result": {
    #|          "nodes": [
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Rise",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Fall",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "first/Z",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "first/A"
    #|            },
    #|            {
    #|              "pin": "first/Z",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "first/A"
    #|            },
    #|            {
    #|              "pin": "second/Z",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "second/A"
    #|            },
    #|            {
    #|              "pin": "second/Z",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "second/A"
    #|            },
    #|            {
    #|              "pin": "first/A",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "first/A",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "second/A",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "first/A"
    #|            },
    #|            {
    #|              "pin": "second/A",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "first/A"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "second/A"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "second/A"
    #|            }
    #|          ],
    #|          "endpoints": [
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.5e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 1.5000000000000002e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.5e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 1.5000000000000002e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            }
    #|          ],
    #|          "worst_slack_seconds": 1.5000000000000002e-09,
    #|          "diagnostics": [
    #|            "graph-based max-arrival/max-slew propagation; zero wire resistance and delay"
    #|          ],
    #|          "topological_order": [
    #|            "first",
    #|            "second"
    #|          ]
    #|        }
    #|      },
    #|      "expected_before": {
    #|        "ok": true,
    #|        "schema": "moonbit.sta.v1",
    #|        "result": {
    #|          "nodes": [
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Rise",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "clk",
    #|              "edge": "Fall",
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [],
    #|              "slew_contributor": "clk"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "a",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "first/Z",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "first/A"
    #|            },
    #|            {
    #|              "pin": "first/Z",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "first/A"
    #|            },
    #|            {
    #|              "pin": "second/Z",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "second/A"
    #|            },
    #|            {
    #|              "pin": "second/Z",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                }
    #|              ],
    #|              "slew_contributor": "second/A"
    #|            },
    #|            {
    #|              "pin": "first/A",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "first/A",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "a"
    #|            },
    #|            {
    #|              "pin": "second/A",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "first/A"
    #|            },
    #|            {
    #|              "pin": "second/A",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.25e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "first/A"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "second/A"
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.5e-09,
    #|              "slew_seconds": 1.0000000000000002e-10,
    #|              "load_farads": 0,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ],
    #|              "slew_contributor": "second/A"
    #|            }
    #|          ],
    #|          "endpoints": [
    #|            {
    #|              "pin": "out",
    #|              "edge": "Rise",
    #|              "arrival_seconds": 1.5e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 1.5000000000000002e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Rise",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            },
    #|            {
    #|              "pin": "out",
    #|              "edge": "Fall",
    #|              "arrival_seconds": 1.5e-09,
    #|              "required_seconds": 3.0000000000000004e-09,
    #|              "slack_seconds": 1.5000000000000002e-09,
    #|              "path": [
    #|                {
    #|                  "pin": "a",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 1e-09,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "input_delay"
    #|                },
    #|                {
    #|                  "pin": "first/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "first/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "second/A",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.25e-09,
    #|                  "arc": "net"
    #|                },
    #|                {
    #|                  "pin": "second/Z",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 2.5e-10,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "A->Z"
    #|                },
    #|                {
    #|                  "pin": "out",
    #|                  "edge": "Fall",
    #|                  "delay_seconds": 0,
    #|                  "arrival_seconds": 1.5e-09,
    #|                  "arc": "net"
    #|                }
    #|              ]
    #|            }
    #|          ],
    #|          "worst_slack_seconds": 1.5000000000000002e-09,
    #|          "diagnostics": [
    #|            "graph-based max-arrival/max-slew propagation; zero wire resistance and delay"
    #|          ],
    #|          "topological_order": [
    #|            "first",
    #|            "second"
    #|          ]
    #|        }
    #|      }
    #|    },
    #|    {
    #|      "name": "multiple-driver-precedes-cycle",
    #|      "group": "precedence",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"n\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"loop\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"other\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"n\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"n\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": null,
    #|      "expected_before_cycle_instances": null,
    #|      "expected_kind": "MultipleDrivers",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"MultipleDrivers(\\\"n\\\")\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "MultipleDrivers(\"n\")"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "MultipleDrivers(\"n\")"
    #|      }
    #|    },
    #|    {
    #|      "name": "undriven-net-precedes-cycle",
    #|      "group": "precedence",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"loop\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"undriven\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": null,
    #|      "expected_before_cycle_instances": null,
    #|      "expected_kind": "UnresolvedNet",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"UnresolvedNet(\\\"no driver for undriven\\\")\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "UnresolvedNet(\"no driver for undriven\")"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "UnresolvedNet(\"no driver for undriven\")"
    #|      }
    #|    },
    #|    {
    #|      "name": "duplicate-instance-precedes-cycle",
    #|      "group": "precedence",
    #|      "library": "full",
    #|      "request": "{\n  \"netlist\": {\n    \"ports\": [\n      {\n        \"name\": \"clk\",\n        \"net\": \"clk\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"a\",\n        \"net\": \"a\",\n        \"direction\": \"input\"\n      },\n      {\n        \"name\": \"out\",\n        \"net\": \"t\",\n        \"direction\": \"output\"\n      }\n    ],\n    \"gates\": [\n      {\n        \"name\": \"a\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"b_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"a_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"b\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"b_n\"\n          }\n        ]\n      },\n      {\n        \"name\": \"tail\",\n        \"cell\": \"BUF\",\n        \"connections\": [\n          {\n            \"pin\": \"A\",\n            \"net\": \"a_n\"\n          },\n          {\n            \"pin\": \"Z\",\n            \"net\": \"t\"\n          }\n        ]\n      }\n    ],\n    \"nets\": [\n      {\n        \"name\": \"clk\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"b_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"a_n\",\n        \"wire_cap_farads\": 0\n      },\n      {\n        \"name\": \"t\",\n        \"wire_cap_farads\": 0\n      }\n    ]\n  },\n  \"sdc\": \"create_clock -name clk -period 4 [get_ports clk]\\nset_clock_transition 0.1 [get_clocks clk]\\nset_input_delay -clock clk 1 [get_ports a]\\nset_input_transition 0.1 [get_ports a]\\nset_output_delay -clock clk 1 [get_ports out]\\n\"\n}\n",
    #|      "expected_cycle_instances": null,
    #|      "expected_before_cycle_instances": null,
    #|      "expected_kind": "InvalidInput",
    #|      "primary": false,
    #|      "expected_stdout_utf8": "{\"ok\":false,\"schema\":\"moonbit.sta.v1\",\"error\":\"InvalidInput(\\\"duplicate/empty instance a\\\")\"}\n",
    #|      "expected_exit": 2,
    #|      "expected": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "InvalidInput(\"duplicate/empty instance a\")"
    #|      },
    #|      "expected_before": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "InvalidInput(\"duplicate/empty instance a\")"
    #|      }
    #|    }
    #|  ],
    #|  "extra_json_expected": [
    #|    {
    #|      "name": "period",
    #|      "result": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "context",
    #|      "result": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.constraint-context.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "pin-limits",
    #|      "result": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.pin-limits.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\"])"
    #|      }
    #|    },
    #|    {
    #|      "name": "path-query",
    #|      "result": {
    #|        "ok": false,
    #|        "schema": "moonbit.sta.path-query.v1",
    #|        "error": "CombinationalLoopDetected([\"loop\"])"
    #|      }
    #|    }
    #|  ],
    #|  "path_query": {
    #|    "from": {
    #|      "kind": "input_port",
    #|      "name": "a",
    #|      "edge": "rise"
    #|    },
    #|    "to": {
    #|      "kind": "output_port",
    #|      "name": "out",
    #|      "edge": "rise"
    #|    }
    #|  },
    #|  "typed_methods": [
    #|    "setup",
    #|    "period",
    #|    "pin-limits",
    #|    "context",
    #|    "path-query"
    #|  ],
    #|  "primary": "self-loop-tail"
    #|}
  text
}
