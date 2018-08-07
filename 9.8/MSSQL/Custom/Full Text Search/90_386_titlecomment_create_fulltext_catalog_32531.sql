
IF  EXISTS (SELECT * FROM sys.fulltext_indexes fti WHERE fti.object_id = OBJECT_ID(N'[dbo].[bookcomments]'))
  ALTER FULLTEXT INDEX ON [dbo].[bookcomments] DISABLE
GO

IF  EXISTS (SELECT * FROM sys.fulltext_indexes fti WHERE fti.object_id = OBJECT_ID(N'[dbo].[bookcomments]'))
  DROP FULLTEXT INDEX ON [dbo].[bookcomments]
GO

IF  EXISTS (SELECT * FROM sysfulltextcatalogs ftc WHERE ftc.name = N'TMMBookCommentsCatalog')
  DROP FULLTEXT CATALOG [TMMBookCommentsCatalog]
GO

CREATE FULLTEXT CATALOG [TMMBookCommentsCatalog] WITH ACCENT_SENSITIVITY = ON
AS DEFAULT
AUTHORIZATION [dbo]
GO

CREATE FULLTEXT INDEX ON dbo.bookcomments (commenttext) 
KEY INDEX bookcomments_FSU01 
ON TMMBookCommentsCatalog
GO
