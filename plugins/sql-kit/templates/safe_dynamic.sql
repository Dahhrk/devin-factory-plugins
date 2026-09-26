-- Named boundary: prefer allowlisted identifiers + binds over EXECUTE IMMEDIATE /
-- EXEC(@sql) / sp_executesql with string concat.
-- Document intentional dynamic seams with sql-rg-allow on the smell line.

-- Anti-pattern (banned without allow):
--   SET @sql = 'SELECT * FROM ' + @table;
--   EXEC(@sql);

-- Prefer: static SQL with binds, or an allowlisted table map in the host language.
-- Example host seam (not executed here): only run dynamic SQL when @table is in
-- ('users','orders') and values are bound parameters, never concatenated.
SELECT 'use host allowlist + binds; sql-rg-allow only on proven seams' AS guidance;
