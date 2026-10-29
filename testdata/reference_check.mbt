///|
/// Independent complete scalar-reference facts, frozen before implementation.
pub fn reference_cases() -> String {
  let text =
    #|{
    #|  "basis": "Explicit counters and all14 issue records, positions/order/first witnesses hand-fixed before new checker. No checker/exporter supplies expected data. Real source header and exact INV/FF pin facts from unchanged own Sky130 subset.",
    #|  "existingSky130Path": "examples/sky130-demo.lib",
    #|  "libraries": {
    #|    "simple": "library (reference_demo) {\n  cell (BUF) {\n    pin (A) { direction : input; }\n    pin (Y) { direction : output; function : \"A\"; }\n  }\n  cell (PAIR) {\n    pin (\"A[0]\") { direction : input; }\n    pin (\"B/#~\") { direction : input; }\n    pin (Y) { direction : output; }\n  }\n  cell (IO) { pin (P) { direction : inout; } }\n  cell (META) { pin (X) { } }\n  cell (EMPTY) { }\n}\n"
    #|  },
    #|  "cases": [
    #|    {
    #|      "name": "resolved-no-timing",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
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
    #|        "status": "ReferencesResolved",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 0,
    #|        "issues": []
    #|      }
    #|    },
    #|    {
    #|      "name": "unknown-cell",
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
    #|            "name": "u/~😀",
    #|            "cell": "MISSING",
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 0,
    #|        "matched_pin_connections": 0,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefUnknownCell",
    #|            "pointer": "/gates/0/cell",
    #|            "name": "MISSING"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "unknown-pin-and-missing",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
    #|            "connections": [
    #|              {
    #|                "pin": "TYPO",
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 1,
    #|        "issue_count": 2,
    #|        "issues": [
    #|          {
    #|            "code": "RefUnknownPin",
    #|            "pointer": "/gates/0/connections/0/pin",
    #|            "name": "TYPO"
    #|          },
    #|          {
    #|            "code": "RefMissingPin",
    #|            "pointer": "/gates/0/connections",
    #|            "name": "A"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "duplicate-pin",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 3,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 3,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefDuplicateConnectionPin",
    #|            "pointer": "/gates/0/connections/1/pin",
    #|            "name": "A",
    #|            "first_pointer": "/gates/0/connections/0/pin"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "missing-pin",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 1,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 1,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefMissingPin",
    #|            "pointer": "/gates/0/connections",
    #|            "name": "Y"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "unresolved-gate-net",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "absent"
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefUnresolvedNet",
    #|            "pointer": "/gates/0/connections/0/net",
    #|            "name": "absent"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "unresolved-port-net",
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
    #|            "net": "absent",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefUnresolvedNet",
    #|            "pointer": "/ports/1/net",
    #|            "name": "absent"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "duplicate-net",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
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
    #|          },
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 3,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefDuplicateNetName",
    #|            "pointer": "/nets/2/name",
    #|            "name": "n0",
    #|            "first_pointer": "/nets/0/name"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "empty-net",
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
    #|            "net": "",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": ""
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
    #|            "name": "",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 3,
    #|        "issues": [
    #|          {
    #|            "code": "RefEmptyNetName",
    #|            "pointer": "/nets/1/name",
    #|            "name": ""
    #|          },
    #|          {
    #|            "code": "RefUnresolvedNet",
    #|            "pointer": "/ports/1/net",
    #|            "name": ""
    #|          },
    #|          {
    #|            "code": "RefUnresolvedNet",
    #|            "pointer": "/gates/0/connections/1/net",
    #|            "name": ""
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "duplicate-port",
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
    #|          },
    #|          {
    #|            "name": "a",
    #|            "net": "n1",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 3,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefDuplicatePortName",
    #|            "pointer": "/ports/2/name",
    #|            "name": "a",
    #|            "first_pointer": "/ports/0/name"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "empty-port",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefEmptyPortName",
    #|            "pointer": "/ports/0/name",
    #|            "name": ""
    #|          }
    #|        ]
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
    #|            "net": "n1",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 2,
    #|        "net_count": 2,
    #|        "connection_count": 4,
    #|        "matched_instances": 2,
    #|        "matched_pin_connections": 4,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefDuplicateInstanceName",
    #|            "pointer": "/gates/1/name",
    #|            "name": "u/~😀",
    #|            "first_pointer": "/gates/0/name"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "instance-port-collision",
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
    #|            "name": "a",
    #|            "cell": "BUF",
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefDuplicateInstanceName",
    #|            "pointer": "/gates/0/name",
    #|            "name": "a",
    #|            "first_pointer": "/ports/0/name"
    #|          }
    #|        ]
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
    #|            "cell": "BUF",
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
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 1,
    #|        "issues": [
    #|          {
    #|            "code": "RefEmptyInstanceName",
    #|            "pointer": "/gates/0/name",
    #|            "name": ""
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "all14-issues",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "nets": [
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n0",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ],
    #|        "ports": [
    #|          {
    #|            "name": "a",
    #|            "net": "n0",
    #|            "direction": "input"
    #|          },
    #|          {
    #|            "name": "a",
    #|            "net": "absent",
    #|            "direction": "output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "a",
    #|            "cell": "BUF",
    #|            "connections": [
    #|              {
    #|                "pin": "BOGUS",
    #|                "net": "absent"
    #|              },
    #|              {
    #|                "pin": "BOGUS",
    #|                "net": "n0"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "",
    #|            "cell": "MISSING",
    #|            "connections": [
    #|              {
    #|                "pin": "X",
    #|                "net": "absent"
    #|              }
    #|            ]
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "ReferenceIssuesFound",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 2,
    #|        "net_count": 3,
    #|        "connection_count": 3,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 0,
    #|        "issue_count": 14,
    #|        "issues": [
    #|          {
    #|            "code": "RefDuplicateNetName",
    #|            "pointer": "/nets/1/name",
    #|            "name": "n0",
    #|            "first_pointer": "/nets/0/name"
    #|          },
    #|          {
    #|            "code": "RefEmptyNetName",
    #|            "pointer": "/nets/2/name",
    #|            "name": ""
    #|          },
    #|          {
    #|            "code": "RefDuplicatePortName",
    #|            "pointer": "/ports/1/name",
    #|            "name": "a",
    #|            "first_pointer": "/ports/0/name"
    #|          },
    #|          {
    #|            "code": "RefUnresolvedNet",
    #|            "pointer": "/ports/1/net",
    #|            "name": "absent"
    #|          },
    #|          {
    #|            "code": "RefDuplicateInstanceName",
    #|            "pointer": "/gates/0/name",
    #|            "name": "a",
    #|            "first_pointer": "/ports/0/name"
    #|          },
    #|          {
    #|            "code": "RefUnknownPin",
    #|            "pointer": "/gates/0/connections/0/pin",
    #|            "name": "BOGUS"
    #|          },
    #|          {
    #|            "code": "RefUnresolvedNet",
    #|            "pointer": "/gates/0/connections/0/net",
    #|            "name": "absent"
    #|          },
    #|          {
    #|            "code": "RefDuplicateConnectionPin",
    #|            "pointer": "/gates/0/connections/1/pin",
    #|            "name": "BOGUS",
    #|            "first_pointer": "/gates/0/connections/0/pin"
    #|          },
    #|          {
    #|            "code": "RefUnknownPin",
    #|            "pointer": "/gates/0/connections/1/pin",
    #|            "name": "BOGUS"
    #|          },
    #|          {
    #|            "code": "RefMissingPin",
    #|            "pointer": "/gates/0/connections",
    #|            "name": "A"
    #|          },
    #|          {
    #|            "code": "RefMissingPin",
    #|            "pointer": "/gates/0/connections",
    #|            "name": "Y"
    #|          },
    #|          {
    #|            "code": "RefEmptyInstanceName",
    #|            "pointer": "/gates/1/name",
    #|            "name": ""
    #|          },
    #|          {
    #|            "code": "RefUnknownCell",
    #|            "pointer": "/gates/1/cell",
    #|            "name": "MISSING"
    #|          },
    #|          {
    #|            "code": "RefUnresolvedNet",
    #|            "pointer": "/gates/1/connections/0/net",
    #|            "name": "absent"
    #|          }
    #|        ]
    #|      }
    #|    },
    #|    {
    #|      "name": "raw-names-native-directions",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [
    #|          {
    #|            "name": "a/#~😀",
    #|            "net": "n/~😀",
    #|            "direction": "Input"
    #|          },
    #|          {
    #|            "name": "b",
    #|            "net": "b",
    #|            "direction": "Input"
    #|          },
    #|          {
    #|            "name": "out",
    #|            "net": "z",
    #|            "direction": "Output"
    #|          }
    #|        ],
    #|        "gates": [
    #|          {
    #|            "name": "u/~😀",
    #|            "cell": "PAIR",
    #|            "connections": [
    #|              {
    #|                "pin": "A[0]",
    #|                "net": "n/~😀"
    #|              },
    #|              {
    #|                "pin": "B/#~",
    #|                "net": "b"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "z"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "n/~😀",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "b",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "z",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "ReferencesResolved",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 3,
    #|        "instance_count": 1,
    #|        "net_count": 3,
    #|        "connection_count": 3,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 3,
    #|        "issue_count": 0,
    #|        "issues": []
    #|      }
    #|    },
    #|    {
    #|      "name": "metadata-pin-directions",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [],
    #|        "gates": [
    #|          {
    #|            "name": "io",
    #|            "cell": "IO",
    #|            "connections": [
    #|              {
    #|                "pin": "P",
    #|                "net": "p"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "meta",
    #|            "cell": "META",
    #|            "connections": [
    #|              {
    #|                "pin": "X",
    #|                "net": "x"
    #|              }
    #|            ]
    #|          }
    #|        ],
    #|        "nets": [
    #|          {
    #|            "name": "p",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "x",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "ReferencesResolved",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 0,
    #|        "instance_count": 2,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 2,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 0,
    #|        "issues": []
    #|      }
    #|    },
    #|    {
    #|      "name": "cycle-outside-scope",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [],
    #|        "gates": [
    #|          {
    #|            "name": "u0",
    #|            "cell": "BUF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n0"
    #|              }
    #|            ]
    #|          },
    #|          {
    #|            "name": "u1",
    #|            "cell": "BUF",
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
    #|        "status": "ReferencesResolved",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 0,
    #|        "instance_count": 2,
    #|        "net_count": 2,
    #|        "connection_count": 4,
    #|        "matched_instances": 2,
    #|        "matched_pin_connections": 4,
    #|        "issue_count": 0,
    #|        "issues": []
    #|      }
    #|    },
    #|    {
    #|      "name": "numeric-and-drivers-outside-scope",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
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
    #|            "cell": "BUF",
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
    #|            "wire_cap_farads": -1
    #|          },
    #|          {
    #|            "name": "n1",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "ReferencesResolved",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 2,
    #|        "net_count": 2,
    #|        "connection_count": 4,
    #|        "matched_instances": 2,
    #|        "matched_pin_connections": 4,
    #|        "issue_count": 0,
    #|        "issues": []
    #|      }
    #|    },
    #|    {
    #|      "name": "empty-design",
    #|      "library": "simple",
    #|      "netlist": {
    #|        "ports": [],
    #|        "gates": [],
    #|        "nets": []
    #|      },
    #|      "expected": {
    #|        "status": "ReferencesResolved",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 0,
    #|        "instance_count": 0,
    #|        "net_count": 0,
    #|        "connection_count": 0,
    #|        "matched_instances": 0,
    #|        "matched_pin_connections": 0,
    #|        "issue_count": 0,
    #|        "issues": []
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
    #|            "name": "clk",
    #|            "net": "clk",
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
    #|            "name": "inv",
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
    #|            "name": "ff",
    #|            "cell": "sky130_fd_sc_hd__dfxtp_1",
    #|            "connections": [
    #|              {
    #|                "pin": "CLK",
    #|                "net": "clk"
    #|              },
    #|              {
    #|                "pin": "D",
    #|                "net": "n1"
    #|              },
    #|              {
    #|                "pin": "Q",
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
    #|            "name": "clk",
    #|            "wire_cap_farads": 0
    #|          },
    #|          {
    #|            "name": "n2",
    #|            "wire_cap_farads": 0
    #|          }
    #|        ]
    #|      },
    #|      "expected": {
    #|        "status": "ReferencesResolved",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "sky130_sta_demo",
    #|        "port_count": 3,
    #|        "instance_count": 2,
    #|        "net_count": 4,
    #|        "connection_count": 5,
    #|        "matched_instances": 2,
    #|        "matched_pin_connections": 5,
    #|        "issue_count": 0,
    #|        "issues": []
    #|      }
    #|    },
    #|    {
    #|      "name": "structural-missing-pin",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
    #|            "connections": [
    #|              {
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
    #|        "error": "missing JSON field pin",
    #|        "pointer": "/gates/0/connections/0/pin"
    #|      }
    #|    },
    #|    {
    #|      "name": "structural-root",
    #|      "library": "simple",
    #|      "netlist": [],
    #|      "expected": {
    #|        "error": "JSON object required",
    #|        "pointer": ""
    #|      }
    #|    },
    #|    {
    #|      "name": "unknown-extensions",
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
    #|            "name": "u/~😀",
    #|            "cell": "BUF",
    #|            "connections": [
    #|              {
    #|                "pin": "A",
    #|                "net": "n0"
    #|              },
    #|              {
    #|                "pin": "Y",
    #|                "net": "n1"
    #|              }
    #|            ],
    #|            "extra": {
    #|              "pin": 5
    #|            }
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
    #|        ],
    #|        "extra/~😀": {
    #|          "unrelated": true
    #|        }
    #|      },
    #|      "expected": {
    #|        "status": "ReferencesResolved",
    #|        "scope": "scalar_names_and_references",
    #|        "library": "reference_demo",
    #|        "port_count": 2,
    #|        "instance_count": 1,
    #|        "net_count": 2,
    #|        "connection_count": 2,
    #|        "matched_instances": 1,
    #|        "matched_pin_connections": 2,
    #|        "issue_count": 0,
    #|        "issues": []
    #|      }
    #|    }
    #|  ]
    #|}
  text
}
