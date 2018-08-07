
--Dropped indexes
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[titlehistory]') AND name = N'IX_titlehistory_fbs06')
DROP INDEX IX_titlehistory_fbs06 ON titlehistory
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[titlehistory]') AND name = N'IX_titlehistory_fbs11')
DROP INDEX IX_titlehistory_fbs11 ON titlehistory
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bookdates]') AND name = N'IX_bookdates_fbs06')
DROP INDEX IX_bookdates_fbs06 ON bookdates
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bookdates]') AND name = N'IX_bookdates_fbs07')
DROP INDEX IX_bookdates_fbs07 ON bookdates
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[bookmisc]') AND name = N'IX_bookmisc_fbs06')
DROP INDEX IX_bookmisc_fbs06 ON bookmisc
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[taqprojecttask]') AND name = N'taqprojecttask_qs2')
DROP INDEX taqprojecttask_qs2 ON taqprojecttask
GO


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[taqprojecttask]') AND name = N'IX_taqProjectTask_bkpda')
CREATE NONCLUSTERED INDEX [IX_taqProjectTask_bkpda] ON [dbo].[taqprojecttask]
(
	[bookkey] ASC,
	[printingkey] ASC,
	[datetypecode] ASC,
	[activedate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
