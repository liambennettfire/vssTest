if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AUTHALL1_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[AUTHALL1_VIEW]
GO

create view dbo.AUTHALL1_VIEW(BOOKKEY, DISPLAYNAME, FIRSTNAME, MIDDLENAME, LASTNAME, AUTHNAMEALL1)  AS 
  SELECT 
      dbo.BOOK.BOOKKEY, 
      dbo.AUTHOR.DISPLAYNAME, 
      dbo.AUTHOR.FIRSTNAME, 
      dbo.AUTHOR.MIDDLENAME, 
      dbo.AUTHOR.LASTNAME, 
      CASE dbo.AUTHOR.MIDDLENAME WHEN  NULL THEN (isnull(dbo.AUTHOR.FIRSTNAME, '') + ' ' + isnull(dbo.AUTHOR.LASTNAME, '')) ELSE (isnull(dbo.AUTHOR.FIRSTNAME, '') + ' ' + isnull(dbo.AUTHOR.MIDDLENAME, '') + ' ' + isnull(dbo.AUTHOR.LASTNAME, '')) END AS AUTHNAMEALL1
    FROM dbo.BOOK, dbo.BOOKAUTHOR, dbo.AUTHOR
    WHERE ((dbo.BOOK.BOOKKEY = dbo.BOOKAUTHOR.BOOKKEY) AND 
            (dbo.BOOKAUTHOR.SORTORDER = 1) AND 
            (dbo.AUTHOR.AUTHORKEY = dbo.BOOKAUTHOR.AUTHORKEY))
go
GRANT SELECT ON AUTHALL1_VIEW TO public
go