///|
/// Frozen independent facts; input and expectation corrections are documented.
pub fn cell_usage_cases() -> String {
  let text =
    #|{
    #|  "basis": "Complete hand area/count/group/instance facts before code; numeric groups and totals supplied explicitly. No new exporter/checker supplies expected data. Real area fields read from existing licensed Sky130 source, not physical-area or external-tool equivalence evidence. Explicit revision: main library uses the same legal bare non-BMP identifier because pinned upstream quoted parsing drops surrogate units. All original20 expected records remain byte-for-byte equal as JSON; exact original quoted input is retained as case21 with independently stated model-binding coverage. This is an upstream limitation, not a fixed bug or a supported-name rejection. Revision02 corrects only the real-library expected header label to sky130_sta_demo from the unchanged file header. All area/count/numeric/identity/row facts and all21 actual input pairs are unchanged; the mistaken original expectation and failed log remain preserved.",
    #|  "relative_tolerance": 1e-14,
    #|  "absolute_tolerance": 1e-12,
    #|  "existingSky130Path": "examples/sky130-demo.lib",
    #|  "libraries": {
    #|    "simple": "library (usage_demo) {\ncell (BUF/~😀) { area : 1.25;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"DFF\") { area : 2.5;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"ZERO\") { area : 0;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"UNUSED\") { area : 100;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"MISSING\") { \n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"NEGATIVE\") { area : -0.5;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"BAD\") { area : \"bad\";\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"COMPLEX\") { area (2);\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"HUGE\") { area : 1e308;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"HUGE2\") { area : 1e308;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"HALF\") { area : 5e307;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"LEXICAL\") { area : 1.2500;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\n}\n",
    #|    "quoted-original": "library (usage_demo) {\ncell (\"BUF/~😀\") { area : 1.25;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"DFF\") { area : 2.5;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"ZERO\") { area : 0;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"UNUSED\") { area : 100;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"MISSING\") { \n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"NEGATIVE\") { area : -0.5;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"BAD\") { area : \"bad\";\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"COMPLEX\") { area (2);\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"HUGE\") { area : 1e308;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"HUGE2\") { area : 1e308;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"HALF\") { area : 5e307;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\ncell (\"LEXICAL\") { area : 1.2500;\n      pin (A) { direction : input; }\n      pin (Y) { direction : output; function : \"A\"; }\n    }\n}\n"
    #|  },
    #|  "cases": [
    #|    {
    #|      "name": "complete-no-timing",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n3",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "u/~😀",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "u1",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "ff",
    #|            "cell": "DFF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n2"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n3"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n3",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Complete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 3,
    #|        "mapped_instances": 3,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 3,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "BUF/~😀",
    #|            "instance_count": 2,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25",
    #|            "area_overflow": false,
    #|            "total_declared_area": 2.5
    #|          },
    #|          {
    #|            "cell": "DFF",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5",
    #|            "area_overflow": false,
    #|            "total_declared_area": 2.5
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "u/~😀",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "u1",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 2,
    #|            "instance": "ff",
    #|            "cell": "DFF",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 5,
    #|        "total_declared_area": 5
    #|      }
    #|    },
    #|    {
    #|      "name": "zero-area",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n1",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "z",
    #|            "cell": "ZERO",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Complete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 1,
    #|        "mapped_instances": 1,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 1,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "ZERO",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 0,
    #|            "raw_area": "0",
    #|            "area_overflow": false,
    #|            "total_declared_area": 0
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "z",
    #|            "cell": "ZERO",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 0,
    #|            "raw_area": "0"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 0,
    #|        "total_declared_area": 0
    #|      }
    #|    },
    #|    {
    #|      "name": "missing-area",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n2",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "b",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "m",
    #|            "cell": "MISSING",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Incomplete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 2,
    #|        "mapped_instances": 2,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 1,
    #|        "missing_area_instances": 1,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "BUF/~😀",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25",
    #|            "area_overflow": false,
    #|            "total_declared_area": 1.25
    #|          },
    #|          {
    #|            "cell": "MISSING",
    #|            "instance_count": 1,
    #|            "area_state": "MissingArea",
    #|            "issue": "area is not declared",
    #|            "area_overflow": false
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "b",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "m",
    #|            "cell": "MISSING",
    #|            "area_state": "MissingArea",
    #|            "issue": "area is not declared"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 1.25
    #|      }
    #|    },
    #|    {
    #|      "name": "negative-area",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n2",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "b",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "n",
    #|            "cell": "NEGATIVE",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Incomplete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 2,
    #|        "mapped_instances": 2,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 1,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 1,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "BUF/~😀",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25",
    #|            "area_overflow": false,
    #|            "total_declared_area": 1.25
    #|          },
    #|          {
    #|            "cell": "NEGATIVE",
    #|            "instance_count": 1,
    #|            "area_state": "InvalidArea",
    #|            "raw_area": "-0.5",
    #|            "issue": "area must be a simple finite nonnegative scalar",
    #|            "area_overflow": false
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "b",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "n",
    #|            "cell": "NEGATIVE",
    #|            "area_state": "InvalidArea",
    #|            "raw_area": "-0.5",
    #|            "issue": "area must be a simple finite nonnegative scalar"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 1.25
    #|      }
    #|    },
    #|    {
    #|      "name": "nonnumeric-area",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n2",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "b",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "n",
    #|            "cell": "BAD",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Incomplete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 2,
    #|        "mapped_instances": 2,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 1,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 1,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "BUF/~😀",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25",
    #|            "area_overflow": false,
    #|            "total_declared_area": 1.25
    #|          },
    #|          {
    #|            "cell": "BAD",
    #|            "instance_count": 1,
    #|            "area_state": "InvalidArea",
    #|            "raw_area": "bad",
    #|            "issue": "area must be a simple finite nonnegative scalar",
    #|            "area_overflow": false
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "b",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "n",
    #|            "cell": "BAD",
    #|            "area_state": "InvalidArea",
    #|            "raw_area": "bad",
    #|            "issue": "area must be a simple finite nonnegative scalar"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 1.25
    #|      }
    #|    },
    #|    {
    #|      "name": "complex-area",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n1",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "n",
    #|            "cell": "COMPLEX",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Incomplete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 1,
    #|        "mapped_instances": 1,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 0,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 1,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "COMPLEX",
    #|            "instance_count": 1,
    #|            "area_state": "InvalidArea",
    #|            "issue": "area must be a simple finite nonnegative scalar",
    #|            "area_overflow": false
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "n",
    #|            "cell": "COMPLEX",
    #|            "area_state": "InvalidArea",
    #|            "issue": "area must be a simple finite nonnegative scalar"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 0
    #|      }
    #|    },
    #|    {
    #|      "name": "unmapped-cell",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n2",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "b",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "x",
    #|            "cell": "UNKNOWN",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Incomplete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 2,
    #|        "mapped_instances": 1,
    #|        "unmapped_instances": 1,
    #|        "known_area_instances": 1,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "BUF/~😀",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25",
    #|            "area_overflow": false,
    #|            "total_declared_area": 1.25
    #|          },
    #|          {
    #|            "cell": "UNKNOWN",
    #|            "instance_count": 1,
    #|            "area_state": "UnmappedCell",
    #|            "issue": "cell not found in library",
    #|            "area_overflow": false
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "b",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "x",
    #|            "cell": "UNKNOWN",
    #|            "area_state": "UnmappedCell",
    #|            "issue": "cell not found in library"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 1.25
    #|      }
    #|    },
    #|    {
    #|      "name": "mixed-coverage",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n5",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "b",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "f",
    #|            "cell": "DFF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "m",
    #|            "cell": "MISSING",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n2"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n3"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "n",
    #|            "cell": "NEGATIVE",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n3"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n4"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "x",
    #|            "cell": "UNKNOWN",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n4"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n5"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n3",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n4",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n5",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Incomplete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 5,
    #|        "mapped_instances": 4,
    #|        "unmapped_instances": 1,
    #|        "known_area_instances": 2,
    #|        "missing_area_instances": 1,
    #|        "invalid_area_instances": 1,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "BUF/~😀",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25",
    #|            "area_overflow": false,
    #|            "total_declared_area": 1.25
    #|          },
    #|          {
    #|            "cell": "DFF",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5",
    #|            "area_overflow": false,
    #|            "total_declared_area": 2.5
    #|          },
    #|          {
    #|            "cell": "MISSING",
    #|            "instance_count": 1,
    #|            "area_state": "MissingArea",
    #|            "issue": "area is not declared",
    #|            "area_overflow": false
    #|          },
    #|          {
    #|            "cell": "NEGATIVE",
    #|            "instance_count": 1,
    #|            "area_state": "InvalidArea",
    #|            "raw_area": "-0.5",
    #|            "issue": "area must be a simple finite nonnegative scalar",
    #|            "area_overflow": false
    #|          },
    #|          {
    #|            "cell": "UNKNOWN",
    #|            "instance_count": 1,
    #|            "area_state": "UnmappedCell",
    #|            "issue": "cell not found in library",
    #|            "area_overflow": false
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "b",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "f",
    #|            "cell": "DFF",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5"
    #|          },
    #|          {
    #|            "index": 2,
    #|            "instance": "m",
    #|            "cell": "MISSING",
    #|            "area_state": "MissingArea",
    #|            "issue": "area is not declared"
    #|          },
    #|          {
    #|            "index": 3,
    #|            "instance": "n",
    #|            "cell": "NEGATIVE",
    #|            "area_state": "InvalidArea",
    #|            "raw_area": "-0.5",
    #|            "issue": "area must be a simple finite nonnegative scalar"
    #|          },
    #|          {
    #|            "index": 4,
    #|            "instance": "x",
    #|            "cell": "UNKNOWN",
    #|            "area_state": "UnmappedCell",
    #|            "issue": "cell not found in library"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 3.75
    #|      }
    #|    },
    #|    {
    #|      "name": "group-product-overflow",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n2",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "h0",
    #|            "cell": "HUGE",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "h1",
    #|            "cell": "HUGE",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Incomplete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 2,
    #|        "mapped_instances": 2,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 2,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": true,
    #|        "cells": [
    #|          {
    #|            "cell": "HUGE",
    #|            "instance_count": 2,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1e+308,
    #|            "raw_area": "1e308",
    #|            "area_overflow": true
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "h0",
    #|            "cell": "HUGE",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1e+308,
    #|            "raw_area": "1e308"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "h1",
    #|            "cell": "HUGE",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1e+308,
    #|            "raw_area": "1e308"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "subtotal-overflow",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n2",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "h0",
    #|            "cell": "HUGE",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "h1",
    #|            "cell": "HUGE2",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Incomplete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 2,
    #|        "mapped_instances": 2,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 2,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": true,
    #|        "cells": [
    #|          {
    #|            "cell": "HUGE",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1e+308,
    #|            "raw_area": "1e308",
    #|            "area_overflow": false,
    #|            "total_declared_area": 1e+308
    #|          },
    #|          {
    #|            "cell": "HUGE2",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1e+308,
    #|            "raw_area": "1e308",
    #|            "area_overflow": false,
    #|            "total_declared_area": 1e+308
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "h0",
    #|            "cell": "HUGE",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1e+308,
    #|            "raw_area": "1e308"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "h1",
    #|            "cell": "HUGE2",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1e+308,
    #|            "raw_area": "1e308"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "large-finite",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n2",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "h0",
    #|            "cell": "HALF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "h1",
    #|            "cell": "HALF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Complete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 2,
    #|        "mapped_instances": 2,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 2,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "HALF",
    #|            "instance_count": 2,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 5e+307,
    #|            "raw_area": "5e307",
    #|            "area_overflow": false,
    #|            "total_declared_area": 1e+308
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "h0",
    #|            "cell": "HALF",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 5e+307,
    #|            "raw_area": "5e307"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "h1",
    #|            "cell": "HALF",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 5e+307,
    #|            "raw_area": "5e307"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 1e+308,
    #|        "total_declared_area": 1e+308
    #|      }
    #|    },
    #|    {
    #|      "name": "empty-design",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n0",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Complete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 0,
    #|        "mapped_instances": 0,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 0,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [],
    #|        "instances": [],
    #|        "known_area_subtotal": 0,
    #|        "total_declared_area": 0
    #|      }
    #|    },
    #|    {
    #|      "name": "first-use-order",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n3",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "f",
    #|            "cell": "DFF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "b0",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "b1",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n2"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n3"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n3",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Complete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 3,
    #|        "mapped_instances": 3,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 3,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "DFF",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5",
    #|            "area_overflow": false,
    #|            "total_declared_area": 2.5
    #|          },
    #|          {
    #|            "cell": "BUF/~😀",
    #|            "instance_count": 2,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25",
    #|            "area_overflow": false,
    #|            "total_declared_area": 2.5
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "f",
    #|            "cell": "DFF",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "b0",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 2,
    #|            "instance": "b1",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 5,
    #|        "total_declared_area": 5
    #|      }
    #|    },
    #|    {
    #|      "name": "port-aliases",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n3",
    #|            "direction": "output"
    #|          },
    #|          {
    #|            "name": "alias/~😀",
    #|            "net": "n3",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "u/~😀",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "u1",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "ff",
    #|            "cell": "DFF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n2"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n3"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n3",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Complete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 3,
    #|        "mapped_instances": 3,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 3,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "BUF/~😀",
    #|            "instance_count": 2,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25",
    #|            "area_overflow": false,
    #|            "total_declared_area": 2.5
    #|          },
    #|          {
    #|            "cell": "DFF",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5",
    #|            "area_overflow": false,
    #|            "total_declared_area": 2.5
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "u/~😀",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "u1",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 2,
    #|            "instance": "ff",
    #|            "cell": "DFF",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 5,
    #|        "total_declared_area": 5
    #|      }
    #|    },
    #|    {
    #|      "name": "native-direction-json",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "Input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n3",
    #|            "direction": "Output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "u/~😀",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "u1",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "ff",
    #|            "cell": "DFF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n2"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n3"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n3",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Complete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 3,
    #|        "mapped_instances": 3,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 3,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "BUF/~😀",
    #|            "instance_count": 2,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25",
    #|            "area_overflow": false,
    #|            "total_declared_area": 2.5
    #|          },
    #|          {
    #|            "cell": "DFF",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5",
    #|            "area_overflow": false,
    #|            "total_declared_area": 2.5
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "u/~😀",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "u1",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.25"
    #|          },
    #|          {
    #|            "index": 2,
    #|            "instance": "ff",
    #|            "cell": "DFF",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 5,
    #|        "total_declared_area": 5
    #|      }
    #|    },
    #|    {
    #|      "name": "raw-area-text",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n1",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "lex",
    #|            "cell": "LEXICAL",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Complete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 1,
    #|        "mapped_instances": 1,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 1,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "LEXICAL",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.2500",
    #|            "area_overflow": false,
    #|            "total_declared_area": 1.25
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "lex",
    #|            "cell": "LEXICAL",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 1.25,
    #|            "raw_area": "1.2500"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 1.25,
    #|        "total_declared_area": 1.25
    #|      }
    #|    },
    #|    {
    #|      "name": "unmapped-only",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n1",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "x",
    #|            "cell": "UNKNOWN",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Incomplete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 1,
    #|        "mapped_instances": 0,
    #|        "unmapped_instances": 1,
    #|        "known_area_instances": 0,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "UNKNOWN",
    #|            "instance_count": 1,
    #|            "area_state": "UnmappedCell",
    #|            "issue": "cell not found in library",
    #|            "area_overflow": false
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "x",
    #|            "cell": "UNKNOWN",
    #|            "area_state": "UnmappedCell",
    #|            "issue": "cell not found in library"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 0
    #|      }
    #|    },
    #|    {
    #|      "name": "duplicate-instance",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n2",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "same",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "same",
    #|            "cell": "DFF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "error": "duplicate/empty instance"
    #|      }
    #|    },
    #|    {
    #|      "name": "empty-instance",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n1",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "error": "duplicate/empty instance"
    #|      }
    #|    },
    #|    {
    #|      "name": "real-sky130",
    #|      "library": "existing-sky130",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n6",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "i0",
    #|            "cell": "sky130_fd_sc_hd__inv_1",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "n0",
    #|            "cell": "sky130_fd_sc_hd__nand2_1",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "i1",
    #|            "cell": "sky130_fd_sc_hd__inv_1",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n2"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n3"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "f0",
    #|            "cell": "sky130_fd_sc_hd__dfxtp_1",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n3"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n4"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "cell": "sky130_fd_sc_hd__nand2_1",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n4"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n5"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "i2",
    #|            "cell": "sky130_fd_sc_hd__inv_1",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n5"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n6"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n3",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n4",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n5",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n6",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Complete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "sky130_sta_demo",
    #|        "instance_count": 6,
    #|        "mapped_instances": 6,
    #|        "unmapped_instances": 0,
    #|        "known_area_instances": 6,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "sky130_fd_sc_hd__inv_1",
    #|            "instance_count": 3,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 3.7536,
    #|            "raw_area": "3.7536",
    #|            "area_overflow": false,
    #|            "total_declared_area": 11.2608
    #|          },
    #|          {
    #|            "cell": "sky130_fd_sc_hd__nand2_1",
    #|            "instance_count": 2,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 3.7536,
    #|            "raw_area": "3.7536",
    #|            "area_overflow": false,
    #|            "total_declared_area": 7.5072
    #|          },
    #|          {
    #|            "cell": "sky130_fd_sc_hd__dfxtp_1",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 20.0192,
    #|            "raw_area": "20.0192",
    #|            "area_overflow": false,
    #|            "total_declared_area": 20.0192
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "i0",
    #|            "cell": "sky130_fd_sc_hd__inv_1",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 3.7536,
    #|            "raw_area": "3.7536"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "n0",
    #|            "cell": "sky130_fd_sc_hd__nand2_1",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 3.7536,
    #|            "raw_area": "3.7536"
    #|          },
    #|          {
    #|            "index": 2,
    #|            "instance": "i1",
    #|            "cell": "sky130_fd_sc_hd__inv_1",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 3.7536,
    #|            "raw_area": "3.7536"
    #|          },
    #|          {
    #|            "index": 3,
    #|            "instance": "f0",
    #|            "cell": "sky130_fd_sc_hd__dfxtp_1",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 20.0192,
    #|            "raw_area": "20.0192"
    #|          },
    #|          {
    #|            "index": 4,
    #|            "instance": "n1",
    #|            "cell": "sky130_fd_sc_hd__nand2_1",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 3.7536,
    #|            "raw_area": "3.7536"
    #|          },
    #|          {
    #|            "index": 5,
    #|            "instance": "i2",
    #|            "cell": "sky130_fd_sc_hd__inv_1",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 3.7536,
    #|            "raw_area": "3.7536"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 38.7872,
    #|        "total_declared_area": 38.7872
    #|      }
    #|    },
    #|    {
    #|      "name": "quoted-original-upstream-binding",
    #|      "library": "quoted-original",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "n3",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "u/~😀",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "u1",
    #|            "cell": "BUF/~😀",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n2"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "ff",
    #|            "cell": "DFF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n2"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n3"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n3",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "Incomplete",
    #|        "unit": "liberty_declared_area",
    #|        "library": "usage_demo",
    #|        "instance_count": 3,
    #|        "mapped_instances": 1,
    #|        "unmapped_instances": 2,
    #|        "known_area_instances": 1,
    #|        "missing_area_instances": 0,
    #|        "invalid_area_instances": 0,
    #|        "area_overflow": false,
    #|        "cells": [
    #|          {
    #|            "cell": "BUF/~😀",
    #|            "instance_count": 2,
    #|            "area_state": "UnmappedCell",
    #|            "issue": "cell not found in library",
    #|            "area_overflow": false
    #|          },
    #|          {
    #|            "cell": "DFF",
    #|            "instance_count": 1,
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5",
    #|            "area_overflow": false,
    #|            "total_declared_area": 2.5
    #|          }
    #|        ],
    #|        "instances": [
    #|          {
    #|            "index": 0,
    #|            "instance": "u/~😀",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "UnmappedCell",
    #|            "issue": "cell not found in library"
    #|          },
    #|          {
    #|            "index": 1,
    #|            "instance": "u1",
    #|            "cell": "BUF/~😀",
    #|            "area_state": "UnmappedCell",
    #|            "issue": "cell not found in library"
    #|          },
    #|          {
    #|            "index": 2,
    #|            "instance": "ff",
    #|            "cell": "DFF",
    #|            "area_state": "KnownArea",
    #|            "declared_area": 2.5,
    #|            "raw_area": "2.5"
    #|          }
    #|        ],
    #|        "known_area_subtotal": 2.5
    #|      }
    #|    }
    #|  ]
    #|}
  text
}
