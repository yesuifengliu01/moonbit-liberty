#!/usr/bin/env node
// Three real files in; parsing, binding and source diagnostics stay in MoonBit.
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
const usage = 'Usage: node tools/check-sdc.cjs LIBERTY.lib NETLIST.json CONSTRAINTS.sdc';
process.stdout.on('error', error => {
  process.exitCode = 2;
  console.error('stdout: ' + String(error));
});
function readUtf8(file, label) {
  const bytes = fs.readFileSync(file);
  const text = bytes.toString('utf8');
  if (!Buffer.from(text, 'utf8').equals(bytes)) {
    throw new Error('Invalid UTF-8 in ' + label);
  }
  return text;
}
try {
  if (args.length === 1 && args[0] === '--help') {
    console.log(`${usage}

Check the documented restricted single-clock SDC profile without running STA.
NETLIST.json is a standalone netlist object (ports, gates, nets).
Inputs must be UTF-8. Library/netlist may have one initial BOM; SDC is verbatim.
JSON stdout uses moonbit.sta.sdc.v1. Exit 0: valid constraints. Exit 2: error.
SDC errors retain the original error and have position or null.
Position anchors the failing command, not the exact token: 1-based line/column,
0-based offset, UTF-16 code units; LF starts a line, CRLF counts two offsets,
tab counts one column. Global errors have null position. No Tcl evaluation.
Host IO/encoding diagnostics use stderr. --help needs no build or input files.
Build: moon build --target js --release`);
  } else if (args.length !== 3) {
    console.error(usage);
    process.exitCode = 2;
  } else {
    const library = readUtf8(args[0], 'Liberty input');
    const netlist = readUtf8(args[1], 'netlist input');
    const source = readUtf8(args[2], 'SDC input');
    const core = require(path.join(__dirname, '../_build/js/release/build/js/js.js'));
    const result = core.check_sdc_json(library, netlist, source);
    console.log(result);
    if (!JSON.parse(result).ok) process.exitCode = 2;
  }
} catch (error) {
  console.error(String(error));
  process.exitCode = 2;
}
