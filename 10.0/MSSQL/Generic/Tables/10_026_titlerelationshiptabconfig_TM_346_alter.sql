DECLARE @table_id AS INT
DECLARE @name_column_id AS INT
DECLARE @sql nvarchar(255) 

-- Find table id
SET @table_id = OBJECT_ID('titlerelationshiptabconfig')

-- Find hidesalesunitind name column id
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidesalesunitind'

-- Remove default constraint from hidesalesunitind column
SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

-- Find hidegrossunitind name column id
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidegrossunitind'

-- Remove default constraint from hidegrossunitind column
SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidesalesunitind

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidegrossunitind