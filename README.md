# db-learning — 1-Month PostgreSQL / Database Expert Track

Goal: expert-level competence in database design, schema modeling, FHIR data modeling, ACID/transactions, auth, maintenance, and migrations. PostgreSQL is the vehicle; every principle is engine-agnostic and noted as such.

**Pace:** ~1–2 h/day (~10 h/week), 30 days.
**Capstone:** "WellSync-lite" — a mini healthcare records system (patients, practitioners, encounters, observations, medications) built up week by week.
**Note rule:** for every topic, write the *generic principle first*, then "how Postgres does it" (see `notes/`).

## Quick start

```bash
docker compose up -d
psql -h localhost -U postgres -d wellsync   # password: postgres
```

pgAdmin: http://localhost:5050 (admin@local.dev / admin)

## Progress tracker

### Week 1 — Data modeling & schema design
- [ ] Day 1–2: Setup + relational model theory (keys, functional dependencies)
- [ ] Day 3–4: Normalization 1NF→BCNF + when to denormalize
- [ ] Day 5–6: ER modeling, Postgres type system, constraints as the real schema
- [ ] Day 7: **Capstone pt 1** — WellSync-lite schema v1 (ER diagram + DDL + DESIGN.md)

### Week 2 — ACID, transactions, engine internals
- [ ] Day 8–9: ACID rigorously; WAL; crash-recovery experiment (kill -9 mid-txn)
- [ ] Day 10–11: Isolation levels, MVCC, locking; reproduce write skew + deadlock
- [ ] Day 12–13: Indexing (B-tree/GIN/GiST/BRIN/partial) + EXPLAIN ANALYZE; make slow query fast on 1M rows
- [ ] Day 14: **Capstone pt 2** — seed data, 5 core queries indexed with EXPLAIN evidence, txn with serialization retry

### Week 3 — Operations: auth, maintenance, backup
- [ ] Day 15–16: Authn/authz, pg_hba.conf, roles/GRANT, **Row-Level Security**, pooling
- [ ] Day 17–18: VACUUM/autovacuum, bloat, statistics, wraparound; pg_stat_statements
- [ ] Day 19–20: pg_dump vs physical backup, PITR drill (restore before bad DELETE), replication concepts
- [ ] Day 21: **Capstone pt 3** — roles, RLS policies, backup script, OPERATIONS.md runbook

### Week 4 — FHIR, migrations, capstone finish
- [ ] Day 22–23: FHIR fundamentals (resources, references, CodeableConcept, LOINC/SNOMED)
- [ ] Day 24–25: FHIR storage strategies (relational vs jsonb vs **hybrid**); migrate capstone to hybrid
- [ ] Day 26–27: Migrations: expand-and-contract, lock-safe DDL, CREATE INDEX CONCURRENTLY; retrofit capstone as migration series
- [ ] Day 28–30: End-to-end run, PRINCIPLES.md, 1-hour cold schema-design self-test

## Repo layout

```
docker-compose.yml     # Postgres 16 + pgAdmin + pg_stat_statements
week1-design/          # ER models, normalization exercises, DDL
week2-internals/       # ACID, transactions, indexing, query plans
week3-ops/             # auth, backup/restore, maintenance
week4-fhir-capstone/   # FHIR schema + migrations + capstone
notes/                 # one file per topic: generic principle → Postgres specifics
```

## References

- [PostgreSQL docs](https://www.postgresql.org/docs/current/) — primary text
- *Designing Data-Intensive Applications* (Kleppmann) — ch. 2, 3, 7
- [Use The Index, Luke](https://use-the-index-luke.com/) — indexing
- [FHIR spec](https://hl7.org/fhir/) — week 4
- [Row-Level Security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [pgexercises.com](https://pgexercises.com/) — query drills
