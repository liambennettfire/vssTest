/* Alter Data Types */

ALTER TABLE gentablesdesc ALTER COLUMN usedivisionind tinyint
ALTER TABLE gentablesdesc ALTER COLUMN userupdatableind tinyint
ALTER TABLE gentablesdesc ALTER COLUMN lockind tinyint
ALTER TABLE gentablesdesc ALTER COLUMN subgenallowed smallint
ALTER TABLE gentablesdesc ALTER COLUMN subjectcategoryind smallint
ALTER TABLE gentablesdesc ALTER COLUMN sub2genallowed smallint
ALTER TABLE gentablesdesc ALTER COLUMN requiredlevels tinyint
ALTER TABLE gentablesdesc ALTER COLUMN updatedescallowed tinyint
ALTER TABLE gentablesdesc ALTER COLUMN activeind tinyint

/****** Object:  Index [gentables_ix1]     ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[gentables]') AND name = N'gentables_ix1')
DROP INDEX [gentables_ix1] ON [dbo].[gentables] WITH ( ONLINE = OFF )
GO
/****** Object:  Statistic [gentables_stat2]    ******/
if  exists (select * from sys.stats where name = N'gentables_stat2' and object_id = object_id(N'[dbo].[gentables]'))
DROP STATISTICS [dbo].[gentables].[gentables_stat2]
GO
/****** Object:  Statistic [gentables_stat3]     ******/
if  exists (select * from sys.stats where name = N'gentables_stat3' and object_id = object_id(N'[dbo].[gentables]'))
DROP STATISTICS [dbo].[gentables].[gentables_stat3]
GO
/****** Object:  Statistic [gentables_stat4]     ******/
if  exists (select * from sys.stats where name = N'gentables_stat4' and object_id = object_id(N'[dbo].[gentables]'))
DROP STATISTICS [dbo].[gentables].[gentables_stat4]
GO
/****** Object:  Statistic [gentables_stat5]    Script Date: 07/22/2013 14:14:55 ******/
if  exists (select * from sys.stats where name = N'gentables_stat5' and object_id = object_id(N'[dbo].[gentables]'))
DROP STATISTICS [dbo].[gentables].[gentables_stat5]
GO
/****** Object:  Index [GENTABLES_QS_04]      ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[gentables]') AND name = N'GENTABLES_QS_04')
DROP INDEX [GENTABLES_QS_04] ON [dbo].[gentables] WITH ( ONLINE = OFF )
GO
/****** Object:  Statistic [taqprojecttask_stat3]     ******/
if  exists (select * from sys.stats where name = N'taqprojecttask_stat3' and object_id = object_id(N'[dbo].[gentables]'))
DROP STATISTICS [dbo].[gentables].[taqprojecttask_stat3]
GO
ALTER TABLE gentables ALTER COLUMN gen1ind tinyint
ALTER TABLE gentables ALTER COLUMN gen2ind tinyint
ALTER TABLE gentables ALTER COLUMN qsicode smallint

/****** Object:  Index [gentables_ix1]     ******/
CREATE NONCLUSTERED INDEX [gentables_ix1] ON [dbo].[gentables] 
(
	[tableid] ASC,
	[gen1ind] ASC,
	[deletestatus] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Statistic [gentables_stat2]     ******/
CREATE STATISTICS [gentables_stat2] ON [dbo].[gentables]([gen1ind], [datacode], [tableid])
GO
/****** Object:  Statistic [gentables_stat3]     ******/
CREATE STATISTICS [gentables_stat3] ON [dbo].[gentables]([tableid], [gen1ind], [deletestatus])
GO
/****** Object:  Statistic [gentables_stat4]     ******/
CREATE STATISTICS [gentables_stat4] ON [dbo].[gentables]([datacode], [datadesc], [datadescshort], [eloquencefieldtag], [qsicode], [tableid], [gen1ind])
GO
/** Object:  Statistic [gentables_stat5]     ******/
CREATE STATISTICS [gentables_stat5] ON [dbo].[gentables]([deletestatus], [datacode], [tableid], [gen1ind], [datadesc], [datadescshort], [eloquencefieldtag], [qsicode])
GO
/****** Object:  Index [GENTABLES_QS_04]     ******/
CREATE NONCLUSTERED INDEX [GENTABLES_QS_04] ON [dbo].[gentables] 
(
	[tableid] ASC,
	[qsicode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [SECONDARY]
GO

/****** Object:  Statistic [taqprojecttask_stat3]     ******/
CREATE STATISTICS [taqprojecttask_stat3] ON [dbo].[gentables]([qsicode], [datacode], [tableid])
GO

-- Drop all Defaults for subgentables
DECLARE @sql nvarchar(max)
SET @sql = ''
SELECT @sql = @sql + 'alter table subgentables drop constraint ' + name  + ';'
FROM sys.default_constraints 
WHERE parent_object_id = object_id('subgentables') AND type = 'D'
EXEC sp_executesql @sql

ALTER TABLE subgentables ALTER COLUMN alldivisionsind tinyint
ALTER TABLE subgentables ALTER COLUMN subgen1ind tinyint
ALTER TABLE subgentables ALTER COLUMN subgen2ind tinyint
ALTER TABLE subgentables ALTER COLUMN subgen3ind tinyint
ALTER TABLE subgentables ALTER COLUMN qsicode smallint


ALTER TABLE [dbo].[subgentables] ADD  DEFAULT ((0)) FOR [subgen1ind]
GO
ALTER TABLE [dbo].[subgentables] ADD  DEFAULT ((0)) FOR [subgen2ind]
GO
ALTER TABLE [dbo].[subgentables] ADD  DEFAULT ((0)) FOR [subgen3ind]
GO
ALTER TABLE [dbo].[subgentables] ADD  DEFAULT ((0)) FOR [subgen4ind]
GO


GRANT SELECT ON gentables TO PUBLIC
GO
GRANT SELECT ON subgentables TO PUBLIC
GO
GRANT SELECT ON gentablesdesc TO PUBLIC
GO
