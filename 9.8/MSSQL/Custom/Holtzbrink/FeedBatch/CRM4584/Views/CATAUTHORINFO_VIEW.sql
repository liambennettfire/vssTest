if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CATAUTHORINFO_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CATAUTHORINFO_VIEW]
GO
create view dbo.CATAUTHORINFO_VIEW(BOOKKEY, CATAUTHORINFO)  AS 
  SELECT bc.BOOKKEY, bc.COMMENTTEXT
    FROM dbo.BOOKCOMMENTS bc
    WHERE ((bc.PRINTINGKEY = 1) AND 
            (bc.COMMENTTYPECODE = 3) AND 
            (bc.COMMENTTYPESUBCODE = 29))


go
GRANT SELECT ON CATAUTHORINFO_VIEW TO public
go