"""Exercise the mapped Yosys JSON request through the public Node CLI."""

import copy
import json
import pathlib
import subprocess
import tempfile


ROOT = pathlib.Path(__file__).resolve().parents[1]
EXAMPLES = ROOT / "examples"
CLI = ROOT / "tools" / "sta.cjs"
LIBERTY = EXAMPLES / "sky130-demo.lib"


def run(request):
    process = subprocess.run(
        ["node", str(CLI), str(LIBERTY), str(request)],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        timeout=30,
    )
    assert not process.stderr, process.stderr
    return process.returncode, json.loads(process.stdout)


code, native = run(EXAMPLES / "chain.json")
assert code == 0 and native["ok"] is True
code, imported = run(EXAMPLES / "yosys-chain.json")
assert code == 0 and imported["ok"] is True


def ordered_report(payload):
    result = copy.deepcopy(payload["result"])
    for rows in ("nodes", "endpoints"):
        result[rows].sort(key=lambda row: (row["pin"], row["edge"]))
    return result


assert ordered_report(imported) == ordered_report(native), "Yosys import changed timing report"

fixture = json.loads((EXAMPLES / "yosys-chain.json").read_text(encoding="utf-8"))
with tempfile.TemporaryDirectory(prefix="yosys-import-", dir=ROOT / "_build") as tmp:
    request = pathlib.Path(tmp) / "request.json"
    cases = []
    constant = copy.deepcopy(fixture)
    constant["yosys_netlist"]["modules"]["chain"]["cells"]["b0"]["connections"]["A"] = ["0"]
    cases.append(("constant", constant))
    vector = copy.deepcopy(fixture)
    vector["yosys_netlist"]["modules"]["chain"]["ports"]["a"]["bits"] = [3, 7]
    cases.append(("vector", vector))
    unknown_module = copy.deepcopy(fixture)
    unknown_module["yosys_module"] = "absent"
    cases.append(("unknown module", unknown_module))
    ambiguous = copy.deepcopy(fixture)
    ambiguous["netlist"] = {"ports": [], "gates": [], "nets": []}
    cases.append(("ambiguous request", ambiguous))
    for name, payload in cases:
        request.write_text(json.dumps(payload), encoding="utf-8")
        code, result = run(request)
        assert code == 2 and result["ok"] is False, (name, code, result)
        assert result["schema"] == "moonbit.sta.v1" and result["error"], name

print(json.dumps({"mapped_yosys_matches_native": True, "rejected_cases": len(cases)}))
