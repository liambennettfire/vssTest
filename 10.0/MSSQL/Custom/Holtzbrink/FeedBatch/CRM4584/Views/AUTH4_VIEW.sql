if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AUTH4_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[AUTH4_VIEW]
GO

create view dbo.AUTH4_VIEW(BOOKKEY, DISPLAYNAME, FIRSTNAME, MIDDLENAME, LASTNAME, AUTHNAME4)  AS 
  SELECT 
      dbo.BOOK.BOOKKEY, 
      dbo.AUTHOR.DISPLAYNAME, 
      dbo.AUTHOR.FIRSTNAME, 
      dbo.AUTHOR.MIDDLENAME, 
      dbo.AUTHOR.LASTNAME, 
      CASE dbo.AUTHOR.MIDDLENAME WHEN  NULL THEN (isnull(dbo.AUTHOR.FIRSTNAME, '') + ' ' + isnull(dbo.AUTHOR.LASTNAME, '')) ELSE (isnull(dbo.AUTHOR.FIRSTNAME, '') + ' ' + isnull(dbo.AUTHOR.MIDDLENAME, '') + ' ' + isnull(dbo.AUTHOR.LASTNAME, '')) END AS AUTHNAME4
    FROM dbo.BOOK, dbo.BOOKAUTHOR, dbo.AUTHOR
    WHERE ((dbo.BOOK.BOOKKEY = dbo.BOOKAUTHOR.BOOKKEY) AND 
            (dbo.BOOKAUTHOR.SORTORDER = 4) AND 
            (dbo.BOOKAUTHOR.PRIMARYIND = 1) AND 
            (dbo.AUTHOR.AUTHORKEY = dbo.BOOKAUTHOR.AUTHORKEY))

go
GRANT SELECT ON AUTH4_VIEW TO public
go