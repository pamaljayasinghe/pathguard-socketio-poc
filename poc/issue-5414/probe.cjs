const assert = require("node:assert/strict");
const pkg = require("@socket.io/redis-streams-emitter/package.json");
console.log(`EMITTER_VERSION=${pkg.version}`);
console.log(`DEPENDENCIES=${JSON.stringify(pkg.dependencies)}`);
try {
  require.resolve("socket.io-adapter");
  console.error("Isolation invalid: socket.io-adapter is available");
  process.exit(2);
} catch (error) {
  if (error.code !== "MODULE_NOT_FOUND") throw error;
  console.log("ADAPTER_ABSENT=true");
}
try {
  const { Emitter } = require("@socket.io/redis-streams-emitter");
  assert.equal(typeof Emitter, "function");
  console.log("PACKAGE_LOAD=PASS");
} catch (error) {
  console.error(`ERROR_CODE=${error.code}`);
  console.error(error.stack);
  process.exit(1);
}
