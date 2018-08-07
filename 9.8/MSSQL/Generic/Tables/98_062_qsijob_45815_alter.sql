
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name='ix_qsijob_001' AND object_id = OBJECT_ID('qsijob'))
CREATE NONCLUSTERED INDEX [ix_qsijob_001] ON [dbo].[qsijob]
(
	[jobtypecode] ASC,
	reviewind,
	startdatetime DESC
)
INCLUDE ( 	[qsijobkey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
GO
