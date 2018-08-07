if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CAT4_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CAT4_VIEW]
GO
create view dbo.CAT4_VIEW(BOOKKEY, CATEGORY4)  AS 
  SELECT dbo.BOOK.BOOKKEY, dbo.GENTABLES.DATADESC AS CATEGORY4
    FROM dbo.BOOK, dbo.BOOKCATEGORY, dbo.GENTABLES
    WHERE ((dbo.BOOK.BOOKKEY = dbo.BOOKCATEGORY.BOOKKEY) AND 
            (dbo.BOOKCATEGORY.SORTORDER = 4) AND 
            (dbo.BOOKCATEGORY.CATEGORYCODE = dbo.GENTABLES.DATACODE) AND 
            (dbo.GENTABLES.TABLEID = 317))


go
GRANT SELECT ON CAT4_VIEW TO public
go