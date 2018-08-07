if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EST_NOTE]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[EST_NOTE]
GO
create view dbo.EST_NOTE(ESTKEY, NOTEKEY, VERSIONKEY, BOOKKEY, NOTEKEY_N, PRINTINGKEY, [TEXT])  AS 


  SELECT 
      dbo.ESTSPECS.ESTKEY, 
      dbo.ESTSPECS.NOTEKEY, 
      dbo.ESTSPECS.VERSIONKEY, 
      dbo.NOTE.BOOKKEY, 
      dbo.NOTE.NOTEKEY AS NOTEKEY_N, 
      dbo.NOTE.PRINTINGKEY, 
      dbo.NOTE.[TEXT]
    FROM dbo.ESTSPECS, dbo.NOTE
    WHERE ((dbo.ESTSPECS.NOTEKEY = dbo.NOTE.NOTEKEY) AND 
            (dbo.ESTSPECS.VERSIONKEY = 1))


go
GRANT SELECT ON EST_NOTE TO public
go