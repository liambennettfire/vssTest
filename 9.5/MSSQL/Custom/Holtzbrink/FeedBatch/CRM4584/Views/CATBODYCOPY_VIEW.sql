if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CATBODYCOPY_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CATBODYCOPY_VIEW]
GO
create view dbo.CATBODYCOPY_VIEW(BOOKKEY, CATBODYCOPY)  AS 
  SELECT bc.BOOKKEY, bc.COMMENTTEXT
    FROM dbo.BOOKCOMMENTS bc
    WHERE ((bc.PRINTINGKEY = 1) AND 
            (bc.COMMENTTYPECODE = 3) AND 
            (bc.COMMENTTYPESUBCODE = 1))


go
GRANT SELECT ON CATBODYCOPY_VIEW TO public
go