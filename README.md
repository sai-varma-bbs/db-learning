# db-learning — 1-Week PostgreSQL / Database Intensive

7 days × 3 h = ~21 h. Goal: working competence in database design, ACID/transactions, indexing, auth, backup, migrations, and FHIR data modeling — PostgreSQL as vehicle, every principle engine-agnostic (each topic noted as *generic principle → how Postgres does it*).

**Capstone thread:** "WellSync-lite" — mini healthcare records DB (patients, practitioners, encounters, observations). Built Day 2, exercised every day after, FHIR-ified Day 7.

## Environment (already set up ✅)

```bash
docker compose up -d        # Postgres 16 (:5432, postgres/postgres, db: wellsync) + pgAdmin (:5050)
colima start                # if docker daemon not running after reboot
docker start fhir-candle    # FHIR R4B server (:5826) — in-memory, restart wipes data
cd ../pyronis && npm run dev  # FHIR EMR UI (:3000)
psql -h localhost -U postgres -d wellsync
```

---

## Day 1 — FHIR hands-on via Pyronis (3 h)

*Why first: touch real healthcare data shapes before designing schema for them.*

- **(1 h)** Open http://localhost:3000 (continue without token). Register patient → Raw JSON viewer → find same `Patient` in fhir-candle browser (http://localhost:5826). Start Encounter, record vitals, add ICD-10 diagnosis, prescribe medication.
- **(1 h)** For each resource created (Patient, Encounter, Observation, Condition, MedicationRequest): read raw JSON side-by-side with its page at hl7.org/fhir. Understand: resource `id` vs `identifier` (MRN), references (`Observation.subject`), CodeableConcept + LOINC/ICD-10, extensions.
- **(0.5 h)** Study README "How each UI action maps to FHIR" table in `../pyronis`. Create a FHIR Subscription, trigger it, see notification Bundle.
- **(0.5 h)** Notes: `notes/fhir-fundamentals.md`. Export 2–3 resources as JSON files into `week4-fhir-capstone/fixtures/` — Day 7 loads these into Postgres.

## Day 2 — Schema design: keys, normalization, constraints + capstone v1 (3 h)

- **(0.5 h)** Run `week1-design/day1/exercise-keys.sql`; answer its questions. Generic: primary/candidate/natural/surrogate keys, tradeoffs (identity vs uuid).
- **(0.75 h)** Normalization fast-path: take one deliberately bad wide table (patient + encounter + practitioner in one), normalize to 3NF stepwise in SQL. One sentence per step on which anomaly it kills. Know *when to denormalize* (read-heavy/reporting) — decision with cost.
- **(0.75 h)** Postgres type/constraint craft: `text` not varchar, `timestamptz` always, `numeric` for money, enums vs lookup tables, jsonb when shape varies. Constraints ARE the schema: `NOT NULL` default, `CHECK`, `UNIQUE`, FK `ON DELETE` semantics.
- **(1 h)** **Capstone:** design WellSync-lite v1 — Mermaid ER diagram + DDL in `week1-design/capstone/`: patients, practitioners, encounters, observations. Model on the FHIR resources you saw Day 1. Short `DESIGN.md`: justify each key + constraint.

## Day 3 — ACID, transactions, isolation, locking (3 h)

*The expert-separator day.*

- **(0.5 h)** ACID precisely: each letter + the failure it prevents. WAL as generic mechanism (every serious engine has one). Experiment: `docker kill db-learning-pg` mid-transaction, restart, watch recovery in logs.
- **(1 h)** Anomalies → isolation levels: dirty read, non-repeatable read, phantom, lost update, write skew → Read Committed / Repeatable Read / Serializable. MVCC: readers don't block writers; dead-tuple cost comes Day 6.
- **(1 h)** Two-terminal labs (commit scripts to `week2-internals/`): (a) demonstrate non-repeatable read at RC, gone at RR; (b) write skew at RR, fixed by Serializable — observe serialization failure, write retry loop; (c) force a deadlock, read the error.
- **(0.5 h)** `SELECT ... FOR UPDATE`, advisory locks. Capstone: wrap encounter+observations insert in one transaction with serialization retry. Notes: `notes/isolation-and-mvcc.md`.

## Day 4 — Indexing & query plans (3 h)

- **(0.5 h)** B-tree mental model (generic, identical across engines). Index cost: writes slower, space. Postgres extras: GIN (jsonb), partial, covering, expression indexes.
- **(1 h)** Seed 1M observations via `generate_series` into capstone. `EXPLAIN (ANALYZE, BUFFERS)`: seq vs index vs bitmap scan; nested loop / hash / merge join (generic algorithms); why planner ignores index (selectivity, stale stats).
- **(1 h)** Lab: 5 realistic capstone queries ("latest vitals for patient", "encounters this week per practitioner", …). Make each fast; commit before/after plans as proof to `week2-internals/tuning/`.
- **(0.5 h)** Use The Index, Luke skim: composite index column order, index-only scans. Notes: `notes/indexing.md`.

## Day 5 — Auth: roles, GRANT, Row-Level Security (3 h)

- **(0.5 h)** Generic: authn vs authz, least privilege, role-per-service. Postgres authn: `pg_hba.conf`, scram-sha-256.
- **(1 h)** Roles + `GRANT`/`REVOKE`: build `app_rw`, `app_ro`, `admin` for capstone; verify `app_ro` can't write. Schema vs table vs column grants. `SECURITY DEFINER` risk in one paragraph.
- **(1 h)** **RLS** (healthcare-critical): policy so a practitioner sees only own patients' rows. Test as different roles with `SET ROLE`. Commit to `week3-ops/rls/`.
- **(0.5 h)** Connection pooling: why connections expensive (generic), PgBouncer transaction pooling + what breaks (session state). Reading only. Notes: `notes/auth-roles-rls.md`.

## Day 6 — Maintenance, backup, restore (3 h)

- **(0.75 h)** VACUUM/autovacuum: MVCC garbage (generic problem), bloat, `ANALYZE`/statistics, txid wraparound (why it's the famous outage). `pg_stat_statements`: find your own worst query from Day 4.
- **(1.5 h)** Disaster drill: `pg_dump` capstone → drop database → restore → verify counts. Then PITR concept + lab-lite: deliberate bad `DELETE`, restore dump from before. Logical vs physical backup tradeoffs. Script into `week3-ops/backup/`. Principle: untested backup = no backup.
- **(0.5 h)** Replication concepts (reading only): streaming vs logical, sync vs async = durability vs latency. Failover basics.
- **(0.25 h)** Notes: `notes/backup-and-maintenance.md`. Write 10-line `OPERATIONS.md` runbook for capstone.

## Day 7 — Migrations + FHIR storage + synthesis (3 h)

- **(1 h)** Migrations: forward-only vs up/down; **expand-and-contract** for zero downtime; never edit applied migration. Postgres gotchas: DDL locks, `CREATE INDEX CONCURRENTLY`, safe `NOT NULL` addition. Retrofit capstone as ordered migration series (plain SQL + `dbmate` or bare psql runner) in `week4-fhir-capstone/migrations/`.
- **(1.25 h)** FHIR storage strategies — the transferable design lesson: (1) pure relational: queryable, evolves painfully; (2) pure jsonb: flexible, weak integrity; (3) **hybrid**: jsonb document + generated columns for hot search params + GIN — what production FHIR stores do. Build hybrid `observation_fhir` table, load Day-1 fixtures, query via both generated columns and jsonb ops.
- **(0.75 h)** Synthesis: `PRINCIPLES.md` — every engine-agnostic principle learned, one line each, mapped to Postgres mechanism. Self-test: cold-design a schema for unfamiliar domain (inventory+orders) in 30 min, no references; gaps = follow-up list.

---

## Progress

- [ ] Day 1 — FHIR via Pyronis
- [ ] Day 2 — Schema design + capstone v1
- [ ] Day 3 — ACID / isolation / locking
- [ ] Day 4 — Indexing / EXPLAIN
- [ ] Day 5 — Roles / GRANT / RLS
- [ ] Day 6 — Maintenance / backup drill
- [ ] Day 7 — Migrations / FHIR hybrid / synthesis

## Repo layout

```
docker-compose.yml     # Postgres 16 + pgAdmin + pg_stat_statements
week1-design/          # Day 2: keys exercise, normalization, capstone DDL
week2-internals/       # Day 3–4: isolation labs, tuning evidence
week3-ops/             # Day 5–6: RLS, backup scripts, runbook
week4-fhir-capstone/   # Day 1 fixtures, Day 7 migrations + hybrid FHIR store
notes/                 # per-topic: generic principle → Postgres specifics
```

## References

- [Pyronis EMR](https://github.com/berkant-k/pyronis) (cloned at `../pyronis`) + [fhir-candle](https://github.com/FHIR/fhir-candle) — Day 1, 7
- [PostgreSQL docs](https://www.postgresql.org/docs/current/) — primary text
- [FHIR spec](https://hl7.org/fhir/) — resource pages as needed
- [Use The Index, Luke](https://use-the-index-luke.com/) — Day 4
- [Row-Level Security docs](https://www.postgresql.org/docs/current/ddl-rowsecurity.html) — Day 5
- *Designing Data-Intensive Applications* ch. 7 — optional Day 3 depth
