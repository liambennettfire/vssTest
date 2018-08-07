DECLARE @table NVARCHAR(512), @sql NVARCHAR(MAX);

DROP INDEX [globalcontactlock_qp] ON [dbo].[globalcontactlock]

SELECT @table = N'dbo.globalcontactlock';

SELECT @sql = 'ALTER TABLE ' + @table 
    + ' DROP CONSTRAINT ' + name + ';'
    FROM sys.key_constraints
    WHERE [type] = 'PK'
    AND [parent_object_id] = OBJECT_ID(@table);

EXEC sp_executeSQL @sql;

-- add new unique key
ALTER TABLE dbo.globalcontactlock ADD globalcontactlockkey INT IDENTITY(1,1)

ALTER TABLE dbo.globalcontactlock
ADD CONSTRAINT PK_globalcontactlock PRIMARY KEY CLUSTERED (globalcontactlockkey)
go

DROP INDEX [taqprojectlock_qp] ON [dbo].[taqprojectlock]

DECLARE @table NVARCHAR(512), @sql NVARCHAR(MAX);

SELECT @table = N'dbo.taqprojectlock';

SELECT @sql = 'ALTER TABLE ' + @table 
    + ' DROP CONSTRAINT ' + name + ';'
    FROM sys.key_constraints
    WHERE [type] = 'PK'
    AND [parent_object_id] = OBJECT_ID(@table);

EXEC sp_executeSQL @sql;

-- add new unique key
ALTER TABLE dbo.taqprojectlock ADD taqprojectlockkey INT IDENTITY(1,1)

ALTER TABLE dbo.taqprojectlock
ADD CONSTRAINT PK_taqprojectlock PRIMARY KEY CLUSTERED (taqprojectlockkey)

go
