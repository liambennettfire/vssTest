CREATE PROCEDURE TAQ_Cleanup(@v_projectkey integer)
AS

  DECLARE @v_bookkey int, @v_catkey1 int, @v_catkey2 int

  -- Delete duplicate components --

  ;WITH cte AS (
    SELECT taqversionspecategorykey ctecat,
       row_number() OVER(PARTITION BY plstagecode, taqversionkey, itemcategorycode, speccategorydescription ORDER BY taqversionspecategorykey) AS rownum
    FROM taqversionspeccategory
    where taqprojectkey=@v_projectkey
  )
  DELETE FROM taqversionspecitems WHERE taqversionspecategorykey IN (SELECT ctecat FROM cte WHERE rownum > 1)

  ;WITH cte AS (
    SELECT taqversionspecategorykey ctecat,
       row_number() OVER(PARTITION BY plstagecode, taqversionkey, itemcategorycode, speccategorydescription ORDER BY taqversionspecategorykey) AS rownum
    FROM taqversionspeccategory
    where taqprojectkey=@v_projectkey
  )
  DELETE FROM taqversionspeccategory WHERE taqversionspecategorykey IN (SELECT ctecat FROM cte WHERE rownum > 1)

  -- Reset P&L Version status
  UPDATE taqversion SET plstatuscode=1 WHERE taqprojectkey=@v_projectkey

  -- Delete bogus title
  SELECT @v_bookkey = bookkey FROM taqprojecttitle WHERE taqprojectkey=@v_projectkey AND bookkey IS NOT NULL
  DELETE FROM book WHERE bookkey=@v_bookkey
  DELETE FROM coretitleinfo WHERE bookkey=@v_bookkey
  UPDATE taqprojecttitle SET bookkey=NULL WHERE taqprojectkey=@v_projectkey AND bookkey IS NOT NULL

GO

EXEC TAQ_Cleanup 27097578
EXEC TAQ_Cleanup 27151777

DROP PROCEDURE dbo.TAQ_Cleanup
GO
