# Day 1 — Setup + relational model warm-up

## 1. Environment check

```bash
docker compose up -d
psql -h localhost -U postgres -d wellsync -c 'select version();'
```

## 2. Reading (~45 min)

- Postgres docs: [Tutorial ch. 2 — The SQL Language](https://www.postgresql.org/docs/current/tutorial-sql.html) (skim what you know)
- Kleppmann DDIA ch. 2 "Data Models and Query Languages" — relational vs document section
- Think about: what does the relational model *guarantee* that a JSON blob store doesn't?

## 3. Exercise: keys (~30 min)

Run `exercise-keys.sql` against the DB, then answer inline questions in comments.

## 4. Notes

Start `notes/keys-and-dependencies.md` from the template:
- Primary vs candidate vs surrogate vs natural key — generic definitions
- When surrogate (`bigint generated always as identity` / `uuid`) beats natural, and cost of each
