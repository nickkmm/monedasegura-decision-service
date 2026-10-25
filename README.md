# monedasegura-decision-service

Core of MonedaSegura: transactions, features, rules, decisions, cases, RBAC, Kafka re-evaluation and daily retraining.

**Stack:** Spring Boot 4.1 · Java 21 · **Owners:** Nicolás · **Status:** skeleton

Part of MonedaSegura (Universidad Icesi + Lovelytics). The shared specification — context, MVP plan, data model, architecture and API contracts — lives in [`monedasegura-infra`](https://github.com/nickkmm/monedasegura-infra), cloned next to this repo inside a `SecureMoney/` workspace folder. Contract: `../monedasegura-infra/docs/api/decision-api.yaml` (implements) and `scoring-api.yaml` (calls).

## Run

```bash
./mvnw verify
./mvnw spring-boot:run          # http://localhost:8080/api/v1/actuator/health
docker build -t monedasegura/decision-service:dev .
```

The whole stack (Postgres, Redis, Kafka and the three services) runs from `../monedasegura-infra` with `docker compose --profile apps up -d --build`.

## Contributing

Branch from `develop` (`feature/…`, `fix/…`, `docs/…`) and open a PR against `develop`; `main` only receives `develop → main` from Nicolás. CI must pass. Everything is in English; only user-facing app text is in Spanish. Agent instructions: [`AGENTS.md`](AGENTS.md).
