# AGENTS.md — monedasegura-decision-service

Instructions for any coding agent (Claude Code, Antigravity, others) working in this repo.

## What this repo is
The **decision-service** of MonedaSegura (Spring Boot 4.1, Java 21): the core of the system. It receives transactions, computes features, evaluates rules, asks the scoring-service for a score behind a circuit breaker, decides `APPROVE | REVIEW | BLOCK`, manages fraud cases, rules, model registry, users and RBAC, publishes decisions to Kafka, re-evaluates degraded decisions and runs the daily retraining job.

Owner: Nicolás. Status: **skeleton** — business code starts once the data model (ERD) is approved.

## Read first (shared context)
The shared specification lives in the sibling repo `../monedasegura-infra/docs/`. Read it; never copy it here.

| File | Why |
|---|---|
| `CONTEXT.md`, `MVP_PLAN.md` | the challenge and the MVP scope |
| `api/decision-api.yaml` | **the contract this service implements** (base path `/api/v1`) |
| `api/scoring-api.yaml` | the contract of the service this one calls |
| `model.md` | the database schema this service owns, the verdict algorithm (§5), rule lifecycle (§6), cases (§7), retraining (§8) |
| `features.md` | the exact feature names and definitions to compute |
| `architecture.md` | where this service sits in both flows |

If the code and those documents disagree, the documents win: change them first with a PR against `monedasegura-infra`, then the code.

**If `../monedasegura-infra` does not exist, stop and set up the workspace before doing anything else** — never guess a contract, a feature name or a table:

```bash
# from the folder that contains this repo
git clone https://github.com/nickkmm/monedasegura-infra.git
sh monedasegura-infra/scripts/bootstrap-workspace.sh
```

The repos are not linked through git; they only rely on being sibling folders inside one workspace folder (e.g. `SecureMoney/`).

## Language policy
- **Everything is in English**: code, identifiers, comments, logs, error messages, docs, commit messages, PR titles and descriptions.
- The only Spanish in the system is user-facing text in the Flutter app; this service returns English codes and enums, and the app translates them.

## Rules for this repo
- Implement the contract exactly: paths, status codes, field names (camelCase JSON) and RFC 9457 errors (`application/problem+json`).
- Authorization is **by permission, never by role**: `@PreAuthorize("hasAuthority('RULE_APPROVE')")`, using the permission listed in the operation's `x-required-permission`.
- Two-step approval: an approver can never approve their own rule version (`approved_by_id <> created_by_id`).
- This service owns the schema: every table change is a versioned migration that matches `docs/model.md`.
- `scenario` and `source` are never features and are never sent to the scoring-service.
- The critical path (`POST /transactions`) must stay under 500 ms: no Kafka publishing, retraining or other slow work before the response. Scoring calls go through the circuit breaker with a short timeout; on failure decide with rules only and set `degraded = true`.
- Postgres is the source of truth; Redis is a rebuildable cache. If Redis fails, recompute features from Postgres.
- Secrets only from environment variables (`JWT_SECRET`, `SCORING_SERVICE_TOKEN`, datasource); never in code or committed config.
- Do not modify the other repos from here.

## Commands
```bash
./mvnw verify                       # compile + tests (needs JDK 21+)
./mvnw spring-boot:run              # run locally on :8080, base path /api/v1
docker build -t monedasegura/decision-service:dev .
```
The full stack (Postgres, Redis, Kafka, the other services) runs from `../monedasegura-infra` with `docker compose --profile apps up -d --build`.

## Branches and commits
- Never push to `develop` or `main`. Create `feature/<task>`, `fix/<task>` or `docs/<task>` and open a PR against `develop`.
- `develop → main` is opened and merged only by Nicolás.
- CI (`.github/workflows/ci.yml`) must pass before merging.
- One topic per PR; commit messages in English, imperative mood.

## Skills
Repo-specific skills go in `.agents/skills/<name>/SKILL.md` (`.claude/skills` is a symlink to it), so they stay versioned with the code.
