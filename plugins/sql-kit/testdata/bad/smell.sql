-- Intentional smells for sql-rg-gate discrimination (not product code).
SELECT * FROM users WHERE id = 1;

DECLARE @sql NVARCHAR(MAX);
SET @sql = 'SELECT name FROM users WHERE id = ' + @id;
EXEC(@sql);

EXECUTE IMMEDIATE 'DROP TABLE t';
