if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CAT2_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CAT2_VIEW]
GO
create view dbo.CAT2_VIEW(BOOKKEY, CATEGORY2)  AS 
  SELECT dbo.BOOK.BOOKKEY, dbo.GENTABLES.DATADESC AS CATEGORY2
    FROM dbo.BOOK, dbo.BOOKCATEGORY, dbo.GENTABLES
    WHERE ((dbo.BOOK.BOOKKEY = dbo.BOOKCATEGORY.BOOKKEY) AND 
            (dbo.BOOKCATEGORY.SORTORDER = 2) AND 
            (dbo.BOOKCATEGORY.CATEGORYCODE = dbo.GENTABLES.DATACODE) AND 
            (dbo.GENTABLES.TABLEID = 317))


go
GRANT SELECT ON CAT2_VIEW TO public
go