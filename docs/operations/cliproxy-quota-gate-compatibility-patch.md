# CLIProxy quota-gate compatibility patch

## Status

**Active local compatibility patch. Preserve across CodexHost/Codex Desktop updates until upstream Codex Desktop fixes the custom-provider composer quota regression and the removal gate below passes.**

Qualified on 2026-09-28 with:

- Codex Desktop `26.924.22138` (build `11645`)
- bundled Codex CLI `0.158.0-alpha.2.1`
- CodexHost `0.10.2` source rebased onto upstream `203301e1`
- Codex Router production/qualified commit `da616761de3f6edbd8f027f350679e309941abb8`
- signed Router mode retained (`requires_openai_auth = true`)

Patch commits:

- `62de9888` - `fix(renderer): bypass Codex quota gate for CLIProxy routes`
- `c727e94d` - `fix(renderer): recognize current Desktop model selection`

The second commit is required for the current Desktop React shape. Do not preserve only the first commit.

## User-visible regression

When the authenticated OpenAI workspace exhausts Codex/Work usage, Codex Desktop displays the exhausted-usage banner and globally disables Composer submission even when the selected model is a valid external Codex Router / CLIProxy model.

Observed failure state:

```text
OpenAI workspace usage exhausted
+ signed Codex Router provider remains authenticated
+ selected model is cliproxy/*
= Composer Send disabled before any request reaches Codex Router
```

Router health and CLIProxy model availability do not fix this because the request is blocked in the Desktop renderer before transport.

## Required behavior

The local patch is deliberately narrower than login-free mode or a global quota bypass:

```text
selected native Codex model starts with cliproxy/
    -> bypass the Codex account/reserve usage gate for that Composer

native OpenAI model or unknown model identity
    -> preserve the stock Codex usage gate
```

It MUST NOT change:

- OpenAI login/session state
- `requires_openai_auth`
- Codex Router signed/login-free mode
- shared quota/account store values
- Plugins / Codex app tools
- Remote configuration
- native OpenAI quota enforcement
- Router or CLIProxy request routing

## Root cause and implementation boundary

CodexHost upstream already has a renderer-local Codex usage-gate projection used for external Harnesses. It leaves shared quota stores untouched and projects the account/reserve gate only for the affected Composer. Current upstream also handles the Desktop Composer wrapper's derived `submitDisabled` state.

The missing behavior was activation for external models that still use the native `codex` agent through Codex Router.

The first canary attempted to read the older native model React shape:

```text
fallbackPowerSelection.model
```

On Desktop `26.924.22138`, live CDP/Fiber inspection showed that the active native model control instead exposes:

```text
selectedLabelCandidate = {
  id: "cliproxy/<model>:<effort>",
  model: "cliproxy/<model>",
  modelLabel: "...",
  reasoningEffort: "..."
}
```

The compatibility reader therefore supports both shapes. The bypass predicate remains fail-closed and accepts only model IDs beginning with `cliproxy/`.

Relevant source:

- `packages/renderer-extension/src/renderer-composer-dom.ts`
  - `isNativeModelControlCandidate(...)`
  - `nativeModelIdForComposer(...)`
  - `shouldBypassCodexUsageGateForNativeModel(...)`
- `packages/renderer-extension/src/renderer-binding-probe.ts`
  - combines external-Harness readiness with the CLIProxy native-model predicate before `codexUsageGate.update(...)`
- `packages/renderer-extension/test/renderer-agent-picker.test.ts`
- `packages/renderer-extension/test/renderer-codex-usage-gate.test.ts`

## Qualification evidence

Before deployment:

```text
focused model/gate tests: 22/22 PASS
renderer-extension suite: 528/528 PASS
TypeScript build: PASS
renderer build: PASS
git diff --check: PASS
```

Live inspection confirmed the current Desktop model shape and a real `cliproxy/*` model ID.

Production acceptance was two-sided while the OpenAI workspace was still at exhausted usage:

```text
CLIProxy model selected  -> Send enabled and submission completed successfully
native GPT-6 Sol selected -> Send remained disabled
```

The exhausted-usage banner may remain visible. That is expected: the patch does not falsify or mutate account quota state.

## Update / regression procedure

After every Codex Desktop or CodexHost update:

1. Fetch/reconcile upstream source first. Do not patch installed runtime files by hand.
2. Check whether upstream changed `renderer-codex-usage-gate.ts`, Composer model-control detection, or the native model React shape.
3. Rebase/replay the two compatibility commits semantically, not mechanically. If upstream already implements equivalent behavior, prefer upstream and run the removal gate below.
4. Run at minimum:

```bash
npm exec vitest -- run \
  packages/renderer-extension/test/renderer-agent-picker.test.ts \
  packages/renderer-extension/test/renderer-codex-usage-gate.test.ts

npm exec vitest -- run packages/renderer-extension/test
npm run build:typescript
npm run build:renderer
git diff --check
```

5. With an exhausted OpenAI quota condition available, perform the two-sided live acceptance test:
   - select a `cliproxy/*` model: Send must be enabled and a request must complete;
   - select a native OpenAI model: Send must remain quota-gated.
6. Confirm Router health separately. A healthy Router does not prove the renderer gate is correct.
7. Confirm Plugins/app-tools and Remote remain available. Do not use login-free mode as a substitute for this patch.

If a Desktop update changes the model-control React shape, use read-only CDP/Fiber inspection. Prefer structured model metadata over visible button text. Fail closed when model identity cannot be proven.

## Removal gate

Remove this local patch only when all of the following are true on a stock/upstream build with the local compatibility patch absent:

1. OpenAI Codex/Work usage is exhausted.
2. A signed custom provider / `cliproxy/*` model remains selectable.
3. Send is enabled for that external model and the request completes.
4. Switching to a native OpenAI model still enforces the exhausted quota.
5. OpenAI login, Plugins/app tools, and Remote continue to work.
6. Focused and renderer regression suites pass.

Do not remove the patch merely because an upstream issue is closed or a release note claims a quota fix. Verify the two-sided behavior above.

## Rollback

Source rollback is preferred: revert the two compatibility commits in reverse order after review.

The pre-v2 installed-package backup captured during qualification is:

```text
~/codexhost-backups/20260928-025540-pre-cliproxy-quota-canary-v2
```

An earlier pre-v1 backup also exists:

```text
~/codexhost-backups/20260928-024420-pre-cliproxy-quota-canary
```

These paths are machine-local operational recovery points, not portable source history. The Git commits are the canonical patch record.

## Safety invariants

Never "fix" this incident by globally forcing usage/quota stores to available, setting every Composer's `submitDisabled` to false, disabling OpenAI authentication, or enabling Router login-free mode without a separate explicit decision. The intended invariant is provider-specific: external CLIProxy submission can continue independently while native OpenAI usage limits remain enforced.
