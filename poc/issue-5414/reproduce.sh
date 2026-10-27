#!/usr/bin/env bash
set -euo pipefail
version="${1:?Supply 0.1.0 or 0.1.1}"
case "$version" in
  0.1.0) expected=1 ;;
  0.1.1) expected=0 ;;
  *) echo 'Unsupported version' >&2; exit 2 ;;
esac
script_dir="$(cd "$(dirname "$0")" && pwd)"
consumer_dir="$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/issue-5414-${version}.XXXXXX")"
cp "$script_dir/fixtures/$version/"*.json "$consumer_dir/"
cp "$script_dir/probe.cjs" "$consumer_dir/"
cd "$consumer_dir"
unset NODE_PATH NODE_OPTIONS
exec > >(tee evidence.log) 2>&1
node --version
npm --version
npm ci --ignore-scripts --no-audit --no-fund
npm ls --all
set +e
node probe.cjs > load.log 2>&1
actual=$?
set -e
cat load.log
echo "LOAD_EXIT_CODE=$actual"
if [ "$actual" -ne "$expected" ]; then
  echo "Unexpected package-load outcome: expected $expected, received $actual"
  exit 1
fi
grep -Fq 'ADAPTER_ABSENT=true' load.log
if [ "$version" = '0.1.0' ]; then
  grep -Fq 'ERROR_CODE=MODULE_NOT_FOUND' load.log
  grep -Fq "Cannot find module 'socket.io-adapter'" load.log
  grep -Fq 'redis-streams-emitter/dist/index.js' load.log
  echo 'VERIFIED: published 0.1.0 reproduces issue #5414 (expected load failure).'
else
  grep -Fq 'PACKAGE_LOAD=PASS' load.log
  echo 'VERIFIED: published 0.1.1 loads without socket.io-adapter.'
fi
