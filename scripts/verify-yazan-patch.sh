#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

npm run build:typescript
npx vitest run \
  packages/adapters/antigravity/test/antigravity-adapter.test.ts \
  --pool=forks \
  --maxWorkers=1

permission_mode_test="packages/adapters/antigravity/test/permission-modes.test.ts"
if [[ -f "$permission_mode_test" ]]; then
  npx vitest run "$permission_mode_test" --pool=forks --maxWorkers=1
fi

git diff --check

