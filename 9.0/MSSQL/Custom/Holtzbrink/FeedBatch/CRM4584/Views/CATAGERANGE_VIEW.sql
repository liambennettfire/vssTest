if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CATAGERANGE_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CATAGERANGE_VIEW]
GO
create view dbo.CATAGERANGE_VIEW(BOOKKEY, SUBJECTKEY, CATEGORYCODE, CATEGORYDESC, CATEGORYSUBCODE, CATEGORYSUBDESC, SORTORDER, LASTUSERID, LASTMAINTDATE)  AS 

  /*****
  *  WARNING ORA2MS-4033 line: 1 col: 1: ORDER BY clause forces usage of TOP in VIEW declaration.
  *****/

  SELECT TOP 100 PERCENT 
      bs.BOOKKEY, 
      bs.SUBJECTKEY, 
      g.DATACODE, 
      g.DATADESC, 
      sg.DATASUBCODE, 
      sg.DATADESC AS expression_5, 
      bs.SORTORDER, 
      bs.LASTUSERID, 
      bs.LASTMAINTDATE
    FROM dbo.GENTABLES g, dbo.BOOKSUBJECTCATEGORY bs
       LEFT JOIN dbo.SUBGENTABLES sg  ON ((sg.TABLEID = bs.CATEGORYTABLEID) AND 
              (sg.DATACODE = bs.CATEGORYCODE) AND 
              (sg.DATASUBCODE = bs.CATEGORYSUBCODE))
    WHERE ((bs.CATEGORYTABLEID = 413) AND 
            (g.TABLEID = bs.CATEGORYTABLEID) AND 
            (g.DATACODE = bs.CATEGORYCODE))
  ORDER BY bs.SORTORDER


go
GRANT SELECT ON CATAGERANGE_VIEW TO public
go