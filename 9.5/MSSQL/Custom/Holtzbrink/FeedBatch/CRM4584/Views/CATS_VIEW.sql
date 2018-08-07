if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CATS_VIEW]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[CATS_VIEW]
GO
create view dbo.CATS_VIEW(BOOKKEY, CATEGORIES)  AS 

  /*****
  *  INFO ORA2MS-6002 line: 12 col: 1: WHERE clause was transformed to the join's conditions in the FROM clause.
  *****/

  SELECT dbo.CAT1_VIEW.BOOKKEY, CASE dbo.CAT1_VIEW.CATEGORY1 WHEN  NULL THEN  NULL ELSE CASE dbo.CAT2_VIEW.CATEGORY2 WHEN  NULL THEN dbo.CAT1_VIEW.CATEGORY1 ELSE CASE dbo.CAT3_VIEW.CATEGORY3 WHEN  NULL THEN (isnull(dbo.CAT1_VIEW.CATEGORY1, '') + ', ' + isnull(dbo.CAT2_VIEW.CATEGORY2, '')) ELSE CASE dbo.CAT4_VIEW.CATEGORY4 WHEN  NULL THEN (isnull(dbo.CAT1_VIEW.CATEGORY1, '') + ', ' + isnull(dbo.CAT2_VIEW.CATEGORY2, '') + ', ' + isnull(dbo.CAT3_VIEW.CATEGORY3, '')) ELSE (isnull(dbo.CAT1_VIEW.CATEGORY1, '') + ', ' + isnull(dbo.CAT2_VIEW.CATEGORY2, '') + ', ' + isnull(dbo.CAT3_VIEW.CATEGORY3, '') + ', ' + isnull(dbo.CAT4_VIEW.CATEGORY4, '')) END END END END AS CATEGORIES
    FROM dbo.CAT1_VIEW
       LEFT JOIN dbo.CAT2_VIEW  ON (dbo.CAT1_VIEW.BOOKKEY = dbo.CAT2_VIEW.BOOKKEY)
       LEFT JOIN dbo.CAT3_VIEW  ON (dbo.CAT1_VIEW.BOOKKEY = dbo.CAT3_VIEW.BOOKKEY)
       LEFT JOIN dbo.CAT4_VIEW  ON (dbo.CAT1_VIEW.BOOKKEY = dbo.CAT4_VIEW.BOOKKEY)


go
GRANT SELECT ON CATS_VIEW TO public
go