DECLARE @table NVARCHAR(512), @sql NVARCHAR(MAX);

SELECT @table = N'dbo.booklock';

SELECT @sql = 'ALTER TABLE ' + @table 
    + ' DROP CONSTRAINT ' + name + ';'
    FROM sys.key_constraints
    WHERE [type] = 'PK'
    AND [parent_object_id] = OBJECT_ID(@table);

EXEC sp_executeSQL @sql;

-- add new unique key
ALTER TABLE dbo.booklock ADD booklockkey INT IDENTITY(1,1)

ALTER TABLE dbo.booklock
ADD CONSTRAINT PK_booklock PRIMARY KEY CLUSTERED (booklockkey)


