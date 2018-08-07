IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[isbn]') AND name = N'PI4isbn')
DROP INDEX [PI4isbn] ON [dbo].[isbn] WITH ( ONLINE = OFF )
/****** Object:  Index [PI4isbn]    Script Date: 08/08/2008 16:20:21 ******/
CREATE NONCLUSTERED INDEX [PI4isbn] ON [dbo].[isbn] 
(
	[itemnumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]