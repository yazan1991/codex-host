# Yazan Codex Plus Maintained Fork

## Repository contract

- Official upstream: https://github.com/BytePioneer-AI/codex-host.git
- Maintained fork: https://github.com/yazan1991/codex-host.git
- Canonical branch: `yazan/codex-plus`
- Shared source policy: macOS arm64 and Linux x64 build from the same canonical source branch. Create a platform-specific source branch only when a genuine platform-specific source difference is demonstrated.

This fork carries a narrow compatibility patch for Antigravity unattended delegation. The historical implementation is a semantic reference, not a code-shape requirement. The current patch maps an unattended create request to Antigravity's existing `dangerously-skip-permissions` mode while preserving explicit permission choices and normal upstream behavior.

## Current patch surface

- `packages/adapters/antigravity/src/antigravity-adapter.ts`
- `packages/adapters/antigravity/test/antigravity-adapter.test.ts`
- `patches/ANTIGRAVITY_UNATTENDED_CONTRACT.md`
- `scripts/verify-yazan-patch.sh`

The source change is intentionally limited to create-session permission selection. It does not alter resume selection, approval hooks, questions, subagents, model or thinking selection, transport, tool projection, or file-change behavior.

## Updating from upstream

1. Fetch and inspect upstream changes without changing production installations.
2. Rebase or merge the canonical branch using normal Git review practices; do not rewrite history.
3. Re-run `scripts/verify-yazan-patch.sh`.
4. Confirm the explicit-permission precedence and real `agy` argument assertion still hold.
5. Review the diff for accidental expansion beyond the two Antigravity source/test files and the maintained-fork documentation.

Source anchors for the original behavior are historical commits `7091141` (`fix: map unattended Antigravity delegation permissions`) and `b02c37b` (`test: fix Antigravity realpath import after upstream merge`). The latter is only a test import repair and is not a separate behavior to preserve. Rollback should remove the narrow mapping and its focused tests through a reviewed source change; do not roll back by modifying an installed runtime.

## Operational rules (not source patches)

- Linux root CodexHost Remote is authoritative.
- The managed entrypoint remains a regular CodexHost shim.
- Stock Codex belongs in `stockCodexPath`.
- The legacy `codex-remote-control.service` remains disabled.
- Paseo CodexHost Remote remains separate/stopped unless explicitly needed.
- Stale socket remediation targets only the proven socket owner.

These are deployment and verification rules. They are not implemented in the Antigravity adapter and must not be reintroduced as source-level permission logic.

