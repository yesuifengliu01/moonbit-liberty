#!/usr/bin/env node
// IO and exit policy only: request parsing and STA remain in MoonBit.
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const args = process.argv.slice(2);
const help = args.length === 1 && args[0] === '--help';
// Only the prefix contains options; the final two arguments remain paths.
const options = args.slice(0, -2);
const files = args.slice(-2);
const check = options.includes('--check-setup');
const requestStdin = options.includes('--request-stdin');
if (!help && (args.length < 2 || args.length > 4 ||
    options.some(option => option !== '--check-setup' && option !== '--request-stdin') ||
    new Set(options).size !== options.length || (requestStdin && files[1] !== '-'))) {
  console.error('Usage: node tools/sta.cjs [--check-setup] LIBERTY.lib REQUEST.json\n' +
    '       node tools/sta.cjs [--check-setup] --request-stdin LIBERTY.lib -\n' +
    '       node tools/sta.cjs --help');
  process.exit(2);
}
process.stdout.on('error', error => {
  process.exitCode = 2;
  console.error('stdout: ' + String(error));
});
function readUtf8(source, label) {
  const bytes = fs.readFileSync(source);
  const text = bytes.toString('utf8');
  if (!Buffer.from(text, 'utf8').equals(bytes)) {
    throw new Error('Invalid UTF-8 in ' + label);
  }
  return text;
}
try {
  if (help) {
    console.log(`MoonBit STA - single-clock setup analysis

Usage:
  node tools/sta.cjs [--check-setup] LIBERTY.lib REQUEST.json
  node tools/sta.cjs [--check-setup] --request-stdin LIBERTY.lib -
  node tools/sta.cjs --help

--help           Show this help without a build or input files; exit 0.
--check-setup    Request the setup summary and check its coverage/status.
--request-stdin  Read one UTF-8 JSON request through EOF; final argument must be -.
The two analysis flags may be given in either order, once each.
Without --request-stdin, - is a literal filename. Positional --help is also a file.

Inputs: valid UTF-8, optionally one initial BOM; internal characters are preserved.
The JSON request contains netlist and sdc; range_policy, period_budget and
setup_summary are optional. Full schema and examples: README.md and examples/.
Default successful analysis exits 0 even with negative slack.
Check exits: 0 Met; 3 Violated; 4 PartialCoverage, NoCoverage or NoEndpoints.
Errors exit 2: arguments, input/encoding, JSON/analysis or stdout writing.
Analysis reports are JSON on stdout; host IO diagnostics use stderr.

Build analysis core: moon build --target js --release
Model: one ideal rising clock, single corner NLDM, lumped C and zero wire R/delay.
No hold, latch, multiple clocks, RC/OCV or full Tcl/Verilog. See README.md.`);
  } else {
    const core = require(path.join(root, '_build/js/release/build/js/js.js'));
    const library = readUtf8(files[0], 'Liberty input');
    const request = readUtf8(requestStdin ? 0 : files[1], 'request input');
    const result = check ? core.analyze_json_for_setup_check(library, request) : core.analyze_json(library, request);
    console.log(result);
    const payload = JSON.parse(result);
    if (!payload.ok) process.exitCode = 2;
    else if (check) {
      const status = payload.setup_summary && payload.setup_summary.status;
      switch (status) {
        case 'Met': break;
        case 'Violated': process.exitCode = 3; break;
        case 'PartialCoverage':
        case 'NoCoverage':
        case 'NoEndpoints': process.exitCode = 4; break;
        default: throw new Error('Missing or unknown setup_summary status');
      }
    }
  }
} catch (e) {
  console.error(String(e));
  process.exitCode = 2;
}
