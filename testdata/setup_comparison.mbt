///|
/// Full independent comparison facts, including verbatim prior CLI reports.
pub fn setup_comparison_cases() -> String {
  let text =
    #|{
    #|  "basis": "Full hand binary64 arithmetic/identity/order/coverage facts before comparator code. Actual two original CLI outputs are verbatim, separately checked against1ns+0.25/0.5ns and2ns hand timing. Synthetic canonical existing report envelopes are endpoint-view test states, not new timing solutions/signoff.",
    #|  "relative_tolerance": 1e-14,
    #|  "absolute_tolerance": 1e-21,
    #|  "reports": {
    #|    "base": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1.0,\n        \"slack_seconds\": 1.0\n      },\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Fall\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 2.0,\n        \"slack_seconds\": 2.0\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "loss": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 0.75,\n        \"slack_seconds\": 0.75\n      },\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Fall\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 2.5,\n        \"slack_seconds\": 2.5\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "improved": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1.25,\n        \"slack_seconds\": 1.25\n      },\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Fall\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 2.25,\n        \"slack_seconds\": 2.25\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "negative": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"n\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": -1.0,\n        \"slack_seconds\": -1.0\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "one": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"p\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1.0,\n        \"slack_seconds\": 1.0\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "unknown": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"p\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": []\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "empty": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "mixed": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 0.5,\n        \"slack_seconds\": 0.5\n      },\n      {\n        \"pin\": \"new\",\n        \"edge\": \"Fall\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 4,\n        \"slack_seconds\": 4\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "reordered": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Fall\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 2,\n        \"slack_seconds\": 2\n      },\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1,\n        \"slack_seconds\": 1\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "huge": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"h\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1e+308,\n        \"slack_seconds\": 1e+308\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "half": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"h\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 5e+307,\n        \"slack_seconds\": 5e+307\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "negative-huge": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"h\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": -1e+308,\n        \"slack_seconds\": -1e+308\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "raw-base": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"u~1~0😀/D\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1,\n        \"slack_seconds\": 1\n      },\n      {\n        \"pin\": \"u~1~0😀/D\",\n        \"edge\": \"Fall\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 2,\n        \"slack_seconds\": 2\n      },\n      {\n        \"pin\": \"p|Rise😀\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 3,\n        \"slack_seconds\": 3\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "raw-loss": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"u~1~0😀/D\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 0.75,\n        \"slack_seconds\": 0.75\n      },\n      {\n        \"pin\": \"u~1~0😀/D\",\n        \"edge\": \"Fall\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 2,\n        \"slack_seconds\": 2\n      },\n      {\n        \"pin\": \"p|Rise😀\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 3,\n        \"slack_seconds\": 3\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "duplicate": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"p\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1,\n        \"slack_seconds\": 1\n      },\n      {\n        \"pin\": \"p\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 2,\n        \"slack_seconds\": 2\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "empty-pin": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1,\n        \"slack_seconds\": 1\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "bad-edge": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"p\",\n        \"edge\": \"rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1.0,\n        \"slack_seconds\": 1.0\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "bad-slack": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"p\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1.0,\n        \"slack_seconds\": \"bad\"\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "bad-schema": "{\n  \"ok\": true,\n  \"schema\": \"other\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"p\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1.0,\n        \"slack_seconds\": 1.0\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n",
    #|    "extra-fields": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 1.0,\n        \"slack_seconds\": 1.0\n      },\n      {\n        \"pin\": \"out/~😀\",\n        \"edge\": \"Fall\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"required_seconds\": 2.0,\n        \"slack_seconds\": 2.0\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": [],\n    \"extra\": \"ignored\"\n  },\n  \"notes/~😀\": {\n    \"kept\": true\n  }\n}\n",
    #|    "actual-baseline": "{\"ok\":true,\"schema\":\"moonbit.sta.v1\",\"result\":{\"nodes\":[{\"pin\":\"clk\",\"edge\":\"Rise\",\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[],\"slew_contributor\":\"clk\"},{\"pin\":\"clk\",\"edge\":\"Fall\",\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[],\"slew_contributor\":\"clk\"},{\"pin\":\"a\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"}],\"slew_contributor\":\"a\"},{\"pin\":\"a\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"}],\"slew_contributor\":\"a\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Rise\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Y\"}],\"slew_contributor\":\"u~1~0😀/A\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Fall\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Y\"}],\"slew_contributor\":\"u~1~0😀/A\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}],\"slew_contributor\":\"a\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}],\"slew_contributor\":\"a\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Y\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"}],\"slew_contributor\":\"u~1~0😀/A\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"arrival_seconds\":1.25e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Y\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"}],\"slew_contributor\":\"u~1~0😀/A\"}],\"endpoints\":[{\"pin\":\"out\",\"edge\":\"Rise\",\"arrival_seconds\":1.25e-9,\"required_seconds\":2e-9,\"slack_seconds\":7.500000000000001e-10,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Rise\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Y\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"}]},{\"pin\":\"out\",\"edge\":\"Fall\",\"arrival_seconds\":1.25e-9,\"required_seconds\":2e-9,\"slack_seconds\":7.500000000000001e-10,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Fall\",\"delay_seconds\":2.5e-10,\"arrival_seconds\":1.25e-9,\"arc\":\"A->Y\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.25e-9,\"arc\":\"net\"}]}],\"worst_slack_seconds\":7.500000000000001e-10,\"diagnostics\":[\"graph-based max-arrival/max-slew propagation; zero wire resistance and delay\"],\"topological_order\":[\"u/~😀\"]},\"setup_summary\":{\"status\":\"Met\",\"endpoint_count\":1,\"constrained_endpoint_edges\":2,\"unconstrained_endpoint_edges\":0,\"violating_endpoint_edges\":0,\"violating_endpoints\":0,\"worst_slack_seconds\":7.500000000000001e-10,\"worst_negative_slack_seconds\":0}}\n",
    #|    "actual-candidate": "{\"ok\":true,\"schema\":\"moonbit.sta.v1\",\"result\":{\"nodes\":[{\"pin\":\"clk\",\"edge\":\"Rise\",\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[],\"slew_contributor\":\"clk\"},{\"pin\":\"clk\",\"edge\":\"Fall\",\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[],\"slew_contributor\":\"clk\"},{\"pin\":\"a\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"}],\"slew_contributor\":\"a\"},{\"pin\":\"a\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"}],\"slew_contributor\":\"a\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Rise\",\"arrival_seconds\":1.5000000000000002e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Rise\",\"delay_seconds\":5e-10,\"arrival_seconds\":1.5000000000000002e-9,\"arc\":\"A->Y\"}],\"slew_contributor\":\"u~1~0😀/A\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Fall\",\"arrival_seconds\":1.5000000000000002e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Fall\",\"delay_seconds\":5e-10,\"arrival_seconds\":1.5000000000000002e-9,\"arc\":\"A->Y\"}],\"slew_contributor\":\"u~1~0😀/A\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Rise\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}],\"slew_contributor\":\"a\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Fall\",\"arrival_seconds\":1e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"}],\"slew_contributor\":\"a\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"arrival_seconds\":1.5000000000000002e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Rise\",\"delay_seconds\":5e-10,\"arrival_seconds\":1.5000000000000002e-9,\"arc\":\"A->Y\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.5000000000000002e-9,\"arc\":\"net\"}],\"slew_contributor\":\"u~1~0😀/A\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"arrival_seconds\":1.5000000000000002e-9,\"slew_seconds\":1.0000000000000002e-10,\"load_farads\":0,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Fall\",\"delay_seconds\":5e-10,\"arrival_seconds\":1.5000000000000002e-9,\"arc\":\"A->Y\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.5000000000000002e-9,\"arc\":\"net\"}],\"slew_contributor\":\"u~1~0😀/A\"}],\"endpoints\":[{\"pin\":\"out\",\"edge\":\"Rise\",\"arrival_seconds\":1.5000000000000002e-9,\"required_seconds\":2e-9,\"slack_seconds\":4.999999999999999e-10,\"path\":[{\"pin\":\"a\",\"edge\":\"Rise\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Rise\",\"delay_seconds\":5e-10,\"arrival_seconds\":1.5000000000000002e-9,\"arc\":\"A->Y\"},{\"pin\":\"out\",\"edge\":\"Rise\",\"delay_seconds\":0,\"arrival_seconds\":1.5000000000000002e-9,\"arc\":\"net\"}]},{\"pin\":\"out\",\"edge\":\"Fall\",\"arrival_seconds\":1.5000000000000002e-9,\"required_seconds\":2e-9,\"slack_seconds\":4.999999999999999e-10,\"path\":[{\"pin\":\"a\",\"edge\":\"Fall\",\"delay_seconds\":1e-9,\"arrival_seconds\":1e-9,\"arc\":\"input_delay\"},{\"pin\":\"u~1~0😀/A\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1e-9,\"arc\":\"net\"},{\"pin\":\"u~1~0😀/Y\",\"edge\":\"Fall\",\"delay_seconds\":5e-10,\"arrival_seconds\":1.5000000000000002e-9,\"arc\":\"A->Y\"},{\"pin\":\"out\",\"edge\":\"Fall\",\"delay_seconds\":0,\"arrival_seconds\":1.5000000000000002e-9,\"arc\":\"net\"}]}],\"worst_slack_seconds\":4.999999999999999e-10,\"diagnostics\":[\"graph-based max-arrival/max-slew propagation; zero wire resistance and delay\"],\"topological_order\":[\"u/~😀\"]},\"setup_summary\":{\"status\":\"Met\",\"endpoint_count\":1,\"constrained_endpoint_edges\":2,\"unconstrained_endpoint_edges\":0,\"violating_endpoint_edges\":0,\"violating_endpoints\":0,\"worst_slack_seconds\":4.999999999999999e-10,\"worst_negative_slack_seconds\":0}}\n",
    #|    "explicit-null": "{\n  \"ok\": true,\n  \"schema\": \"moonbit.sta.v1\",\n  \"result\": {\n    \"nodes\": [],\n    \"endpoints\": [\n      {\n        \"pin\": \"p\",\n        \"edge\": \"Rise\",\n        \"arrival_seconds\": 0.0,\n        \"path\": [],\n        \"slack_seconds\": null\n      }\n    ],\n    \"diagnostics\": [],\n    \"topological_order\": []\n  }\n}\n"
    #|  },
    #|  "invalid_budget_tokens": [
    #|    "-1",
    #|    "NaN",
    #|    "Infinity"
    #|  ],
    #|  "cases": [
    #|    {
    #|      "name": "unchanged",
    #|      "baseline": "base",
    #|      "candidate": "base",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "NoSetupRegression",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 2,
    #|        "compared_endpoint_edges": 2,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": 1,
    #|            "candidate_slack_seconds": 1,
    #|            "slack_delta_seconds": 0
    #|          },
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": 2,
    #|            "candidate_slack_seconds": 2,
    #|            "slack_delta_seconds": 0
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "positive-slack-loss",
    #|      "baseline": "base",
    #|      "candidate": "loss",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupRegressed",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 2,
    #|        "compared_endpoint_edges": 2,
    #|        "regressed_endpoint_edges": 1,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaRegressed",
    #|            "baseline_slack_seconds": 1,
    #|            "candidate_slack_seconds": 0.75,
    #|            "slack_delta_seconds": -0.25
    #|          },
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaImproved",
    #|            "baseline_slack_seconds": 2,
    #|            "candidate_slack_seconds": 2.5,
    #|            "slack_delta_seconds": 0.5
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "exact-tolerance-allowed",
    #|      "baseline": "base",
    #|      "candidate": "loss",
    #|      "max_slack_loss_seconds": 0.25,
    #|      "expected": {
    #|        "status": "NoSetupRegression",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0.25,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 2,
    #|        "compared_endpoint_edges": 2,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaTolerated",
    #|            "baseline_slack_seconds": 1,
    #|            "candidate_slack_seconds": 0.75,
    #|            "slack_delta_seconds": -0.25
    #|          },
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaImproved",
    #|            "baseline_slack_seconds": 2,
    #|            "candidate_slack_seconds": 2.5,
    #|            "slack_delta_seconds": 0.5
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "loss-over-tolerance",
    #|      "baseline": "base",
    #|      "candidate": "loss",
    #|      "max_slack_loss_seconds": 0.125,
    #|      "expected": {
    #|        "status": "SetupRegressed",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0.125,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 2,
    #|        "compared_endpoint_edges": 2,
    #|        "regressed_endpoint_edges": 1,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaRegressed",
    #|            "baseline_slack_seconds": 1,
    #|            "candidate_slack_seconds": 0.75,
    #|            "slack_delta_seconds": -0.25
    #|          },
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaImproved",
    #|            "baseline_slack_seconds": 2,
    #|            "candidate_slack_seconds": 2.5,
    #|            "slack_delta_seconds": 0.5
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "improved",
    #|      "baseline": "base",
    #|      "candidate": "improved",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "NoSetupRegression",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 2,
    #|        "compared_endpoint_edges": 2,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaImproved",
    #|            "baseline_slack_seconds": 1,
    #|            "candidate_slack_seconds": 1.25,
    #|            "slack_delta_seconds": 0.25
    #|          },
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaImproved",
    #|            "baseline_slack_seconds": 2,
    #|            "candidate_slack_seconds": 2.25,
    #|            "slack_delta_seconds": 0.25
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "already-negative-unchanged",
    #|      "baseline": "negative",
    #|      "candidate": "negative",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "NoSetupRegression",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 1,
    #|        "candidate_endpoint_edges": 1,
    #|        "matched_endpoint_edges": 1,
    #|        "compared_endpoint_edges": 1,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "n",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": -1,
    #|            "candidate_slack_seconds": -1,
    #|            "slack_delta_seconds": 0
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "candidate-slack-missing",
    #|      "baseline": "one",
    #|      "candidate": "unknown",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupComparisonIncomplete",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 1,
    #|        "candidate_endpoint_edges": 1,
    #|        "matched_endpoint_edges": 1,
    #|        "compared_endpoint_edges": 0,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 1,
    #|        "rows": [
    #|          {
    #|            "pin": "p",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaCandidateUnknown",
    #|            "baseline_slack_seconds": 1
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "baseline-slack-missing",
    #|      "baseline": "unknown",
    #|      "candidate": "one",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupComparisonIncomplete",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 1,
    #|        "candidate_endpoint_edges": 1,
    #|        "matched_endpoint_edges": 1,
    #|        "compared_endpoint_edges": 0,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 1,
    #|        "rows": [
    #|          {
    #|            "pin": "p",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaBaselineUnknown",
    #|            "candidate_slack_seconds": 1
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "both-slacks-missing",
    #|      "baseline": "unknown",
    #|      "candidate": "unknown",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupComparisonIncomplete",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 1,
    #|        "candidate_endpoint_edges": 1,
    #|        "matched_endpoint_edges": 1,
    #|        "compared_endpoint_edges": 0,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 1,
    #|        "rows": [
    #|          {
    #|            "pin": "p",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaBothUnknown"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "baseline-only",
    #|      "baseline": "one",
    #|      "candidate": "empty",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupComparisonIncomplete",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 1,
    #|        "candidate_endpoint_edges": 0,
    #|        "matched_endpoint_edges": 0,
    #|        "compared_endpoint_edges": 0,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 1,
    #|        "rows": [
    #|          {
    #|            "pin": "p",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaBaselineOnly",
    #|            "baseline_slack_seconds": 1
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "candidate-only",
    #|      "baseline": "empty",
    #|      "candidate": "one",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupComparisonIncomplete",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 0,
    #|        "candidate_endpoint_edges": 1,
    #|        "matched_endpoint_edges": 0,
    #|        "compared_endpoint_edges": 0,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 1,
    #|        "rows": [
    #|          {
    #|            "pin": "p",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaCandidateOnly",
    #|            "candidate_slack_seconds": 1
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "known-regression-and-set-changes",
    #|      "baseline": "base",
    #|      "candidate": "mixed",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupRegressed",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 1,
    #|        "compared_endpoint_edges": 1,
    #|        "regressed_endpoint_edges": 1,
    #|        "incomplete_endpoint_edges": 2,
    #|        "rows": [
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaRegressed",
    #|            "baseline_slack_seconds": 1,
    #|            "candidate_slack_seconds": 0.5,
    #|            "slack_delta_seconds": -0.5
    #|          },
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaBaselineOnly",
    #|            "baseline_slack_seconds": 2
    #|          },
    #|          {
    #|            "pin": "new",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaCandidateOnly",
    #|            "candidate_slack_seconds": 4
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "candidate-reordered",
    #|      "baseline": "base",
    #|      "candidate": "reordered",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "NoSetupRegression",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 2,
    #|        "compared_endpoint_edges": 2,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": 1,
    #|            "candidate_slack_seconds": 1,
    #|            "slack_delta_seconds": 0
    #|          },
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": 2,
    #|            "candidate_slack_seconds": 2,
    #|            "slack_delta_seconds": 0
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "baseline-order-retained",
    #|      "baseline": "reordered",
    #|      "candidate": "base",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "NoSetupRegression",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 2,
    #|        "compared_endpoint_edges": 2,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": 2,
    #|            "candidate_slack_seconds": 2,
    #|            "slack_delta_seconds": 0
    #|          },
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": 1,
    #|            "candidate_slack_seconds": 1,
    #|            "slack_delta_seconds": 0
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "two-empty-reports",
    #|      "baseline": "empty",
    #|      "candidate": "empty",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupComparisonIncomplete",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 0,
    #|        "candidate_endpoint_edges": 0,
    #|        "matched_endpoint_edges": 0,
    #|        "compared_endpoint_edges": 0,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": []
    #|      }
    #|    },
    #|    {
    #|      "name": "large-finite-boundary",
    #|      "baseline": "huge",
    #|      "candidate": "half",
    #|      "max_slack_loss_seconds": 5e+307,
    #|      "expected": {
    #|        "status": "NoSetupRegression",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 5e+307,
    #|        "baseline_endpoint_edges": 1,
    #|        "candidate_endpoint_edges": 1,
    #|        "matched_endpoint_edges": 1,
    #|        "compared_endpoint_edges": 1,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "h",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaTolerated",
    #|            "baseline_slack_seconds": 1e+308,
    #|            "candidate_slack_seconds": 5e+307,
    #|            "slack_delta_seconds": -5e+307
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "loss-delta-overflow",
    #|      "baseline": "huge",
    #|      "candidate": "negative-huge",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupComparisonIncomplete",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 1,
    #|        "candidate_endpoint_edges": 1,
    #|        "matched_endpoint_edges": 1,
    #|        "compared_endpoint_edges": 0,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 1,
    #|        "rows": [
    #|          {
    #|            "pin": "h",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaOverflow",
    #|            "baseline_slack_seconds": 1e+308,
    #|            "candidate_slack_seconds": -1e+308
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "improvement-delta-overflow",
    #|      "baseline": "negative-huge",
    #|      "candidate": "huge",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupComparisonIncomplete",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 1,
    #|        "candidate_endpoint_edges": 1,
    #|        "matched_endpoint_edges": 1,
    #|        "compared_endpoint_edges": 0,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 1,
    #|        "rows": [
    #|          {
    #|            "pin": "h",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaOverflow",
    #|            "baseline_slack_seconds": -1e+308,
    #|            "candidate_slack_seconds": 1e+308
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "raw-report-identity-and-edge",
    #|      "baseline": "raw-base",
    #|      "candidate": "raw-loss",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupRegressed",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 3,
    #|        "candidate_endpoint_edges": 3,
    #|        "matched_endpoint_edges": 3,
    #|        "compared_endpoint_edges": 3,
    #|        "regressed_endpoint_edges": 1,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "u~1~0😀/D",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaRegressed",
    #|            "baseline_slack_seconds": 1,
    #|            "candidate_slack_seconds": 0.75,
    #|            "slack_delta_seconds": -0.25
    #|          },
    #|          {
    #|            "pin": "u~1~0😀/D",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": 2,
    #|            "candidate_slack_seconds": 2,
    #|            "slack_delta_seconds": 0
    #|          },
    #|          {
    #|            "pin": "p|Rise😀",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": 3,
    #|            "candidate_slack_seconds": 3,
    #|            "slack_delta_seconds": 0
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "duplicate-baseline",
    #|      "baseline": "duplicate",
    #|      "candidate": "one",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "error": "duplicate/empty baseline endpoint"
    #|      }
    #|    },
    #|    {
    #|      "name": "duplicate-candidate",
    #|      "baseline": "one",
    #|      "candidate": "duplicate",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "error": "duplicate/empty candidate endpoint"
    #|      }
    #|    },
    #|    {
    #|      "name": "empty-baseline-pin",
    #|      "baseline": "empty-pin",
    #|      "candidate": "one",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "error": "duplicate/empty baseline endpoint"
    #|      }
    #|    },
    #|    {
    #|      "name": "invalid-edge",
    #|      "baseline": "bad-edge",
    #|      "candidate": "one",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "error": "invalid baseline endpoint edge"
    #|      }
    #|    },
    #|    {
    #|      "name": "invalid-slack",
    #|      "baseline": "bad-slack",
    #|      "candidate": "one",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "error": "invalid baseline slack_seconds"
    #|      }
    #|    },
    #|    {
    #|      "name": "invalid-schema",
    #|      "baseline": "bad-schema",
    #|      "candidate": "one",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "error": "invalid baseline report schema"
    #|      }
    #|    },
    #|    {
    #|      "name": "unused-fields-ignored",
    #|      "baseline": "extra-fields",
    #|      "candidate": "base",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "NoSetupRegression",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 2,
    #|        "compared_endpoint_edges": 2,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": 1,
    #|            "candidate_slack_seconds": 1,
    #|            "slack_delta_seconds": 0
    #|          },
    #|          {
    #|            "pin": "out/~😀",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaUnchanged",
    #|            "baseline_slack_seconds": 2,
    #|            "candidate_slack_seconds": 2,
    #|            "slack_delta_seconds": 0
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "actual-old-cli-both-met",
    #|      "baseline": "actual-baseline",
    #|      "candidate": "actual-candidate",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupRegressed",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 2,
    #|        "compared_endpoint_edges": 2,
    #|        "regressed_endpoint_edges": 2,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "out",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaRegressed",
    #|            "baseline_slack_seconds": 7.5e-10,
    #|            "candidate_slack_seconds": 5e-10,
    #|            "slack_delta_seconds": -2.5e-10
    #|          },
    #|          {
    #|            "pin": "out",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaRegressed",
    #|            "baseline_slack_seconds": 7.5e-10,
    #|            "candidate_slack_seconds": 5e-10,
    #|            "slack_delta_seconds": -2.5e-10
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "actual-old-cli-tolerance",
    #|      "baseline": "actual-baseline",
    #|      "candidate": "actual-candidate",
    #|      "max_slack_loss_seconds": 5e-10,
    #|      "expected": {
    #|        "status": "NoSetupRegression",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 5e-10,
    #|        "baseline_endpoint_edges": 2,
    #|        "candidate_endpoint_edges": 2,
    #|        "matched_endpoint_edges": 2,
    #|        "compared_endpoint_edges": 2,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 0,
    #|        "rows": [
    #|          {
    #|            "pin": "out",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaTolerated",
    #|            "baseline_slack_seconds": 7.5e-10,
    #|            "candidate_slack_seconds": 5e-10,
    #|            "slack_delta_seconds": -2.5e-10
    #|          },
    #|          {
    #|            "pin": "out",
    #|            "edge": "Fall",
    #|            "status": "SetupDeltaTolerated",
    #|            "baseline_slack_seconds": 7.5e-10,
    #|            "candidate_slack_seconds": 5e-10,
    #|            "slack_delta_seconds": -2.5e-10
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "negative-budget",
    #|      "baseline": "base",
    #|      "candidate": "base",
    #|      "max_slack_loss_seconds": -1,
    #|      "expected": {
    #|        "error": "max_slack_loss_seconds must be finite and nonnegative"
    #|      }
    #|    },
    #|    {
    #|      "name": "explicit-null-slack",
    #|      "baseline": "explicit-null",
    #|      "candidate": "one",
    #|      "max_slack_loss_seconds": 0,
    #|      "expected": {
    #|        "status": "SetupComparisonIncomplete",
    #|        "unit": "seconds",
    #|        "max_slack_loss_seconds": 0,
    #|        "baseline_endpoint_edges": 1,
    #|        "candidate_endpoint_edges": 1,
    #|        "matched_endpoint_edges": 1,
    #|        "compared_endpoint_edges": 0,
    #|        "regressed_endpoint_edges": 0,
    #|        "incomplete_endpoint_edges": 1,
    #|        "rows": [
    #|          {
    #|            "pin": "p",
    #|            "edge": "Rise",
    #|            "status": "SetupDeltaBaselineUnknown",
    #|            "candidate_slack_seconds": 1
    #|          }
    #|        ]
    #|      }
    #|    }
    #|  ]
    #|}
  text
}
