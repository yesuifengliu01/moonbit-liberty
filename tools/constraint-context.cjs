#!/usr/bin/env node
// IO only. The optional MoonBit analysis collects accepted-arc causal witnesses.
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
const usage = 'Usage: node tools/constraint-context.cjs LIB.lib NETLIST.json CONSTRAINTS.sdc';
process.stdout.on('error', error => {
  process.exitCode = 2;
  console.error('stdout: ' + String(error));
});
function readUtf8(file, label) {
  const bytes = fs.readFileSync(file);
  const text = bytes.toString('utf8');
  if (!Buffer.from(text, 'utf8').equals(bytes)) throw new Error('Invalid UTF-8 in ' + label);
  return text;
}
try {
  if (args.length === 1 && args[0] === '--help') {
    console.log(`${usage}

Explain existing unknown-slack endpoint edges with one causal launch witness.
Witnesses retain source port/edge, accepted net/arc steps and SI arc delays.
They are not timed arrivals, exhaustive missing-input lists or path coverage.
Default setup policy: Extrapolate. No legacy request flags or period analysis.
Library/netlist accept one leading BOM; SDC is verbatim. All files are UTF-8.
JSON stdout: moonbit.sta.constraint-context.v1, original result, setup_summary,
constraint_context. Source input files are never rewritten.
Exit 0: analysis completed, including PartialCoverage or negative slack.
Exit 2: arguments, IO/encoding, analysis or stdout error; host errors on stderr.
No timing-closure/signoff certificate. --help needs no build or input files.
Build: moon build --target js --release`);
  } else if (args.length !== 3) {
    console.error(usage);
    process.exitCode = 2;
  } else {
    const library = readUtf8(args[0], 'Liberty input');
    const netlist = readUtf8(args[1], 'netlist input');
    const source = readUtf8(args[2], 'SDC input');
    const core = require(path.join(__dirname, '../_build/js/release/build/js/js.js'));
    const result = core.analyze_constraint_context_json(library, netlist, source);
    console.log(result);
    if (!JSON.parse(result).ok) process.exitCode = 2;
  }
} catch (error) {
  console.error(String(error));
  process.exitCode = 2;
}
