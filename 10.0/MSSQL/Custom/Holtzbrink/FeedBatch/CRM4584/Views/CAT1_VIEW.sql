if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CAT1_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CAT1_VIEW]
GO
create view dbo.CAT1_VIEW(BOOKKEY, CATEGORY1)  AS 
  SELECT dbo.BOOK.BOOKKEY, dbo.GENTABLES.DATADESC AS CATEGORY1
    FROM dbo.BOOK, dbo.BOOKCATEGORY, dbo.GENTABLES
    WHERE ((dbo.BOOK.BOOKKEY = dbo.BOOKCATEGORY.BOOKKEY) AND 
            (dbo.BOOKCATEGORY.SORTORDER = 1) AND 
            (dbo.BOOKCATEGORY.CATEGORYCODE = dbo.GENTABLES.DATACODE) AND 
            (dbo.GENTABLES.TABLEID = 317))


go
GRANT SELECT ON CAT1_VIEW TO public
go