# Cell-usage verification scope

This addition accepts existing Liberty and flat Netlist JSON and reports declared cell usage without timing setup. It does not change timing/graph/SDC math, dependency versions, or existing report schemas. Complete means area coverage only.

The21-case catalog retains the original20 pre-implementation numeric, identity and row facts, including counts, grouping order, raw names/area, omitted fields, incomplete states, product/sum overflow, empty design, identity errors and an unchanged real Sky130 source. One mistaken expected library label was corrected directly from that file's header to sky130_sta_demo, with the original expectation/failure retained. A failed acceptance check exposed pinned upstream quoted non-BMP cell-name truncation. An explicit fixture revision uses the same legal bare identifier for positive cases and retains the exact original two-file input as case21 with an independently stated partial-binding expectation. No original input/failure evidence is discarded and no parser/dependency/census workaround is added. These expected area/count facts are not outputs of the census algorithm. The six focused MoonBit tests also call the typed API independently, check owned outputs, and exercise public programmatic Cell.area values.

The relevant local pass for this addition is:

```sh
moon check --target all --deny-warn
moon fmt --check
moon test --target js --deny-warn --filter 'cell usage*'
moon test --target wasm-gc --deny-warn --filter 'cell usage*'
moon test --target native --deny-warn --filter 'cell usage*'
moon build --target js --release --deny-warn
python3 tools/ci-cell-usage.py
```

`ci-cell-usage.py` runs21 real two-file processes and a separately compiled public-package recipient returning five typed reports. It compares every field/omission/order with frozen facts and also checks source-only help, arguments, both UTF-8 inputs, malformed JSON/Liberty/schema, BOM, missing files and a closed stdout receiver. All process stdout/stderr, actual input-copy hashes and exit codes survive failures under `_build/cell-usage-receipts` and `_build/ci-cell-usage.json`. These are self-authored integrations, not external adoption. Files use caller-relative Unicode names in a different cwd.

The existing required GitHub Actions quality job remains intact and must pass on the exact pushed final head. Once per final head, it runs its configured all-target check, formatting, full JS/Wasm-GC/native suites (94 existing +6 new tests), release builds and all old receiving gates plus the necessary new cell-usage step. A focused local run is not reported as a full suite. The old suites/133 recipients are not separately repeated locally for this addition; existing configured remote CI is the regression boundary. Historical OpenSTA/scientific generators and old batch reference samples are not rerun or counted as new evidence.

For delivery, retain failed attempts and one clean relevant pass, freeze the final-head tracked-source ZIP with every member read back, and distinguish Git object identity, blob-payload SHA256, working bytes, actual tested input copies, locally compiled artifacts and raw outputs. Remote CI source/status metadata does not establish byte identity with a local executable. Stop after these required checks; additional unrelated hardening or reference reruns need a concrete failure or a new request.
