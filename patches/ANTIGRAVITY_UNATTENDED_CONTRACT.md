# Antigravity Unattended Delegation Contract

For Antigravity `create` sessions:

1. An explicit `permissionModeId` always wins.
2. If no explicit mode is provided and `executionPolicy` is `unattended-full-access`, the effective mode is `dangerously-skip-permissions`.
3. If the execution policy is absent or `default`, normal sessions preserve the upstream default (`configured`).
4. The effective skip mode is wired through the existing CLI argument builder, so the final `agy` invocation receives `--dangerously-skip-permissions`.

No broader permission bypass is allowed. Desktop approvals, configured permissions, interactive questions, subagent lifecycle, model selection, thinking options, transport encoding, tool projection, and file-change behavior remain unchanged unless upstream changes require a focused compatibility update.

The focused Antigravity test suite covers all four clauses, including an isolated fake `agy` shim that captures the final argument vector.

