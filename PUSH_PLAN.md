# Push Plan

This schedule preserves the requested README-first publication and daily limits. Day numbers are relative to the day you begin; do not push two main-level feature branches on one day. The README-only push on Day 1 is the required documentation-first exception and is not one of the `ui`, `backend`, or `mock-api` feature branches tracked by the push helper.

## Day 1: README First

On `main`, commit and push only `README.md`. Do not push any feature branch before this operation completes.

```powershell
git switch main
git pull --ff-only origin main
git add README.md
git commit -m "docs: document Flutter app and repository workflow"
git push origin main
```

Still on Day 1, publish the existing Flutter application and the remaining setup files as a separate, small baseline commit on `main`. This ensures every feature branch starts from the complete project rather than the repository's original README-only commit.

```powershell
git add -A
git commit -m "chore: add Flutter application and CI scaffolding"
git push origin main
```

## Day 2: UI Branch

Create `ui` from the updated `main`, then push only `ui`.

```powershell
git switch main
git pull --ff-only origin main
git switch -c ui
git push --set-upstream origin ui
```

## Day 3: Backend Workstream

Create `backend` from `main`, then push only `backend`. In this Flutter repository the branch is for repository/data/reporting code, not an Express service.

```powershell
git switch main
git switch -c backend
git push --set-upstream origin backend
```

## Day 4: UI Sub-Branches

Git cannot have `ui` and `ui/screens` (or `ui/components`) at the same time: a branch ref cannot also be a parent directory for another ref. Use the Git-valid names `ui-screens` and `ui-components`, both created from `ui`. These are the screen/component sub-branches, and two is the daily maximum.

```powershell
git switch ui
git switch -c ui-screens
git push --set-upstream origin ui-screens
git switch ui
git switch -c ui-components
git push --set-upstream origin ui-components
```

## Day 5: Temporary Mock Branch

Create `mock-api` from `main` and push it. The app's current mock is an in-process Dart API adapter, not an HTTP server; its compile-time switch is `ENABLE_DEMO=true`, not `USE_MOCK_API=true`.

```powershell
git switch main
git switch -c mock-api
git push --set-upstream origin mock-api
```

## Automated Push Helper

After all five local branches exist, run the matching helper from inside the repository once for each scheduled branch. It chooses the next branch in the sequence above, verifies the `origin` URL, refuses daily-limit violations, and records successful pushes in `.git/push-next-state.json`. It does not push `main` or publish the README; Day 1 is intentionally manual so README publication is explicit.

```powershell
.\scripts\push-next.ps1
```

```bash
./scripts/push-next.sh
```

For each successful helper call, wait until the next calendar day before pushing the next main-level branch (`ui`, `backend`, `mock-api`). The two UI sub-branches may both be pushed on Day 4. State is local and is not committed; do not delete it to bypass the rate limits.