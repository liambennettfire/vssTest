if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AUTHREP2_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[AUTHREP2_VIEW]
GO

create view dbo.AUTHREP2_VIEW(BOOKKEY, DISPLAYNAME, FIRSTNAME, MIDDLENAME, LASTNAME, AUTHNAMEREP2)  AS 
  SELECT 
      dbo.BOOK.BOOKKEY, 
      dbo.AUTHOR.DISPLAYNAME, 
      dbo.AUTHOR.FIRSTNAME, 
      dbo.AUTHOR.MIDDLENAME, 
      dbo.AUTHOR.LASTNAME, 
      CASE dbo.AUTHOR.MIDDLENAME WHEN  NULL THEN (isnull(dbo.AUTHOR.FIRSTNAME, '') + ' ' + isnull(dbo.AUTHOR.LASTNAME, '')) ELSE (isnull(dbo.AUTHOR.FIRSTNAME, '') + ' ' + isnull(dbo.AUTHOR.MIDDLENAME, '') + ' ' + isnull(dbo.AUTHOR.LASTNAME, '')) END AS AUTHNAMEREP2
    FROM dbo.BOOK, dbo.BOOKAUTHOR, dbo.AUTHOR
    WHERE ((dbo.BOOK.BOOKKEY = dbo.BOOKAUTHOR.BOOKKEY) AND 
            (dbo.BOOKAUTHOR.SORTORDER = 2) AND 
            (dbo.BOOKAUTHOR.REPORTIND = 1) AND 
            (dbo.AUTHOR.AUTHORKEY = dbo.BOOKAUTHOR.AUTHORKEY))




go
GRANT SELECT ON AUTHREP2_VIEW TO public
go