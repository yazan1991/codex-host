# Yazan Codex Plus Maintained Fork

## Repository contract

- Official upstream: https://github.com/BytePioneer-AI/codex-host.git
- Maintained fork: https://github.com/yazan1991/codex-host.git
- Canonical branch: `yazan/codex-plus`
- Shared source policy: macOS arm64 and Linux x64 build from the same canonical source branch. Create a platform-specific source branch only when a genuine platform-specific source difference is demonstrated.

## Current maintained-fork delta

As of 2026-09-28, the historical Antigravity unattended-delegation source patch is no longer an active fork delta. Current upstream implements a stronger unattended permission policy and current DeepSeek Harness support has also superseded the old local `0.1.6-alpha.1` compatibility work. Do not replay those historical runtime patches onto newer upstream source unless a new regression independently proves they are needed.

The active local compatibility delta is the **CLIProxy quota-gate patch** documented in:

- `docs/operations/cliproxy-quota-gate-compatibility-patch.md`

It preserves signed OpenAI authentication, Plugins/Remote, and native OpenAI quota enforcement while allowing a selected `cliproxy/*` model to submit when the OpenAI workspace quota is exhausted.

### Updating from upstream

1. Fetch and inspect upstream without changing the production installation.
2. Preserve the repository contract and replay only active local deltas.
3. Treat historical Antigravity/DeepSeek commits as semantic history, not mandatory patches.
4. Follow the CLIProxy quota patch regression/removal procedure before changing or dropping that compatibility layer.
5. Never replace the provider-specific quota patch with a global quota bypass or Router login-free mode unless that is an explicit architectural decision.

Historical Antigravity source anchors remain `7091141` and `b02c37b`; they are retained for archaeology only.

## Operational rules (not source patches)

- Linux root CodexHost Remote is authoritative.
- The managed entrypoint remains a regular CodexHost shim.
- Stock Codex belongs in `stockCodexPath`.
- The legacy `codex-remote-control.service` remains disabled.
- Paseo CodexHost Remote remains separate/stopped unless explicitly needed.
- Stale socket remediation targets only the proven socket owner.

These are deployment and verification rules. They are not implemented in the Antigravity adapter and must not be reintroduced as source-level permission logic.

