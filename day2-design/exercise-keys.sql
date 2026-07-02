-- Day 1 exercise: keys and identity
-- Run: psql -h localhost -U postgres -d wellsync -f exercise-keys.sql

begin;

-- A deliberately naive patients table. You will critique and fix it.
create table patients_naive (
    ssn         text,          -- "natural key"?
    full_name   text,
    email       text,
    born        date
);

-- Q1: Why is ssn a bad primary key for a healthcare system?
--     (Think: not everyone has one, they get corrected, they're sensitive PII,
--      other countries. Write your answer here.)

-- Q2: Rewrite with a surrogate key. Which do you pick and why?
--     bigint generated always as identity  -> compact, ordered, leaks row count
--     uuid (gen_random_uuid())             -> opaque, mergeable across systems, bigger index
create table patients (
    id          bigint generated always as identity primary key,
    ssn         text unique,              -- natural identifier demoted to UNIQUE, nullable
    full_name   text not null,
    email       text,
    born        date not null,
    check (born > date '1900-01-01' and born <= current_date)
);

-- Q3: Insert two patients with the same email. Should that be allowed?
--     Families share emails. Decide, and add/skip a constraint deliberately.
insert into patients (ssn, full_name, email, born)
values ('123-45-6789', 'Ada Lovelace', 'fam@example.com', '1985-12-10'),
       (null,          'Alan Turing',  'fam@example.com', '1982-06-23');

-- Q4: Try to violate identity: this should FAIL. Understand the error.
-- insert into patients (id, full_name, born) values (999, 'Hacker', '1990-01-01');

select * from patients;

rollback;  -- keep DB clean; change to commit when you want to keep it
