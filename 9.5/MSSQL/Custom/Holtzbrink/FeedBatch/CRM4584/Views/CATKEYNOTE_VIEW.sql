if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CATKEYNOTE_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CATKEYNOTE_VIEW]
GO
create view dbo.CATKEYNOTE_VIEW(BOOKKEY, CATKEYNOTE)  AS 
  SELECT bc.BOOKKEY, bc.COMMENTTEXT
    FROM dbo.BOOKCOMMENTS bc
    WHERE ((bc.PRINTINGKEY = 1) AND 
            (bc.COMMENTTYPECODE = 3) AND 
            (bc.COMMENTTYPESUBCODE = 17))


go
GRANT SELECT ON CATKEYNOTE_VIEW TO public
go