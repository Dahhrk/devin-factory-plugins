-- Named boundary: prefer bound parameters over SELECT * or SQL string concat.
-- Copy into product sources; keep sql-rg-allow only on intentional seams.
-- Postgres-style $1 binds shown; swap for ? / :name / @name per dialect.

SELECT id, email, created_at
FROM users
WHERE id = $1
  AND status = $2;
