# Real published-package bug: Socket.IO issue #5414

Original report: https://github.com/socketio/socket.io/issues/5414
Upstream fix: https://github.com/socketio/socket.io/commit/7617707ed8f0defd0e19cb7c6963504ce7b87f6b

The published `@socket.io/redis-streams-emitter@0.1.0` imports `socket.io-adapter` at runtime without declaring it as a dependency. A fresh consumer can install the emitter but cannot load it. Version 0.1.1 removes the external import and uses local adapter definitions instead.

This reproduction uses unmodified published packages and locked dependencies in separate temporary consumer projects outside the monorepo. It verifies that socket.io-adapter is absent before loading each emitter. No Redis server is needed: the defect occurs at module load time.

| Package | Expected raw load result | Verification job |
|---|---|---|
| 0.1.0 | `MODULE_NOT_FOUND: Cannot find module 'socket.io-adapter'`, exit 1 | Pass only if this specific failure occurs |
| 0.1.1 | Emitter loads, exit 0 | Pass only if loading succeeds |

**A green reproduction workflow means the historical failure and the fixed behavior were both verified. It does not mean version 0.1.0 works.** Unexpected errors or outcomes fail the verification job. Raw load exit codes and error messages are logged and uploaded as artifacts.

With Node 24, run from the repository root:

```bash
bash poc/issue-5414/reproduce.sh 0.1.0
bash poc/issue-5414/reproduce.sh 0.1.1
```

The workflow runs these two cases independently on Linux using Node 24.22.1. Dependency lifecycle scripts are disabled for these install-and-load checks.

This is a real import/dependency defect, separate from the synthetic path-filter PoC. This experiment does not establish that a path filter caused issue #5414. Do not merge this demonstration PR into upstream.
