# Day 2 warm-up — keys & relational model

## 1. Reading (~20 min)

- Kleppmann DDIA ch. 2 "Data Models and Query Languages" — relational vs document section
- Think about: what does the relational model *guarantee* that a JSON blob store doesn't?

## 2. Exercise: keys (~30 min)

Run `exercise-keys.sql` against the DB, then answer inline questions in comments:

```bash
psql -h localhost -U postgres -d wellsync -f exercise-keys.sql
```

## 3. Notes

Start `notes/keys-and-dependencies.md` from the template:
- Primary vs candidate vs surrogate vs natural key — generic definitions
- When surrogate (`bigint generated always as identity` / `uuid`) beats natural, and cost of each
