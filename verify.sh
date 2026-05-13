#!/bin/bash
# verify.sh — byte-for-byte runtime verification of CoolCoin (0xc86d80c1...)
# Compiles CoolCoin.sol with soljson v0.1.7 (optimizer ON) and compares
# against the on-chain runtime bytecode.
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
SOLC_VERSION="${SOLC_VERSION:-v0.1.7+commit.b4e666cc}"
SOLJSON="/tmp/soljson/soljson-${SOLC_VERSION}.js"

if [ ! -f "$SOLJSON" ]; then
  echo "Missing soljson at $SOLJSON"
  echo "Download with:"
  echo "  mkdir -p /tmp/soljson && cd /tmp/soljson && \\"
  echo "  curl -sSLo soljson-${SOLC_VERSION}.js https://binaries.soliditylang.org/bin/soljson-${SOLC_VERSION}.js && \\"
  echo "  npm init -y >/dev/null && npm i solc@0.4.26 >/dev/null"
  exit 1
fi

node -e "
const solc = require('/tmp/soljson/node_modules/solc');
const soljson = require('$SOLJSON');
const compiler = solc.setupMethods(soljson);
const source = require('fs').readFileSync('$ROOT/CoolCoin.sol', 'utf8');
const result = compiler.compile(source, 1);
const out = (typeof result === 'string') ? JSON.parse(result) : result;
const c = out.contracts['CoolCoin'] || out.contracts[':CoolCoin'];
require('fs').writeFileSync('/tmp/coolcoin_compiled_runtime.hex', '0x' + c.runtimeBytecode);
console.log('compiled runtime: ' + (c.runtimeBytecode.length/2) + ' bytes');
"

ONCHAIN=$(tr -d '\n' < "$ROOT/onchain_runtime.hex")
COMPILED=$(tr -d '\n' < /tmp/coolcoin_compiled_runtime.hex)

if [ "$ONCHAIN" = "$COMPILED" ]; then
  echo "✅ EXACT MATCH (1018 bytes)"
  exit 0
else
  echo "❌ MISMATCH"
  diff <(echo "$ONCHAIN" | fold -w 80) <(echo "$COMPILED" | fold -w 80) | head -20
  exit 1
fi
