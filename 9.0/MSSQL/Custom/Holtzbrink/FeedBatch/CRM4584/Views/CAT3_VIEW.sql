if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CAT3_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CAT3_VIEW]
GO
create view dbo.CAT3_VIEW(BOOKKEY, CATEGORY3)  AS 
  SELECT dbo.BOOK.BOOKKEY, dbo.GENTABLES.DATADESC AS CATEGORY3
    FROM dbo.BOOK, dbo.BOOKCATEGORY, dbo.GENTABLES
    WHERE ((dbo.BOOK.BOOKKEY = dbo.BOOKCATEGORY.BOOKKEY) AND 
            (dbo.BOOKCATEGORY.SORTORDER = 3) AND 
            (dbo.BOOKCATEGORY.CATEGORYCODE = dbo.GENTABLES.DATACODE) AND 
            (dbo.GENTABLES.TABLEID = 317))


go
GRANT SELECT ON CAT3_VIEW TO public
go