DECLARE @table_id AS INT
DECLARE @name_column_id AS INT
DECLARE @sql nvarchar(255) 

-- Find table id
SET @table_id = OBJECT_ID('titlerelationshiptabconfig')

--Remove hidemisc1ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidemisc1ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidemisc1ind

--Remove hidemisc2ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidemisc2ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidemisc2ind

--Remove hidemisc3ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidemisc3ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidemisc3ind

--Remove hidemisc4ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidemisc4ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidemisc4ind

--Remove hidemisc5ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidemisc5ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidemisc5ind

--Remove hidemisc6ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidemisc6ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidemisc6ind

--Remove hidedate1ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidedate1ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidedate1ind

--Remove hidedate2ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidedate2ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidedate2ind

--Remove hidedate3ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidedate3ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidedate3ind

--Remove hidedate4ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidedate4ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidedate4ind

--Remove hidedate5ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidedate5ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidedate5ind

--Remove hidedate6ind constraints and column
SELECT @name_column_id = column_id
FROM sys.columns
WHERE object_id = @table_id
AND name = 'hidedate6ind'

SELECT @sql = 'ALTER TABLE titlerelationshiptabconfig DROP CONSTRAINT ' + D.name
FROM sys.default_constraints AS D
WHERE D.parent_object_id = @table_id
AND D.parent_column_id = @name_column_id

EXECUTE sp_executesql @sql

ALTER TABLE titlerelationshiptabconfig
DROP COLUMN hidedate6ind