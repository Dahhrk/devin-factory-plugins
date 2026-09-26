-- Good fixture: explicit columns, binds, documented allow.
SELECT id, email FROM users WHERE id = $1;

-- Documented intentional seam (legacy report); keep allow on the smell line.
SELECT * FROM legacy_report_v1; -- sql-rg-allow: fixture documents allow marker for intentional star seam
