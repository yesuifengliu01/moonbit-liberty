#!/usr/bin/env node
// IO only: accepted arc weights and path query computation belong to MoonBit.
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
const usage = 'Usage: node tools/path-query.cjs LIB.lib NETLIST.json CONSTRAINTS.sdc QUERY.json';
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

Query one exact input_port/register_q to output_port/register_d edge path.
Use raw name or instance/pin components, kind, and edge rise/fall in from/to.
Optional range_policy: extrapolate (default), reject, clamp.
Uses original full-design GBA slew/load and accepted arc delays, not PBA.
JSON stdout: moonbit.sta.path-query.v1, original result and path_query.
Found has queried_arrival_seconds, optional required_seconds/queried_slack_seconds,
and an owned path. NoPath/UnconstrainedLaunch have no numerical values or timed path.
Query slack is distinct from global WNS. Q is a launch; D-to-Q is not a data edge.
All four files are UTF-8. Library/netlist/query accept one initial BOM; SDC is verbatim.
Relative paths use the caller cwd. Inputs are never rewritten.
Exit 0: a valid Found/NoPath/UnconstrainedLaunch result, including negative slack.
Exit 2: arguments, IO/encoding, analysis/query or stdout failure.
--help needs no build or input files. Build: moon build --target js --release`);
  } else if (args.length !== 4) {
    console.error(usage);
    process.exitCode = 2;
  } else {
    const library = readUtf8(args[0], 'Liberty input');
    const netlist = readUtf8(args[1], 'netlist input');
    const source = readUtf8(args[2], 'SDC input');
    const query = readUtf8(args[3], 'query input');
    const core = require(path.join(__dirname, '../_build/js/release/build/js/js.js'));
    const result = core.analyze_path_query_json(library, netlist, source, query);
    console.log(result);
    if (!JSON.parse(result).ok) process.exitCode = 2;
  }
} catch (error) {
  console.error(String(error));
  process.exitCode = 2;
}
