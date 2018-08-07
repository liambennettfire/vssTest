IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qpl_get_taqversionspeccategory_basic')
  DROP PROCEDURE qpl_get_taqversionspeccategory_basic
GO

CREATE PROCEDURE qpl_get_taqversionspeccategory_basic (
  @i_projectkey integer,
  @i_plstage    integer,
  @i_versionkey integer,
  @i_formatkey integer,
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT)
AS

/*****************************************************************************************************
**  Name: qpl_get_taqversionspeccategory_basic
**  Desc: This stored procedure returns basic taqversionspeccategory data for a format/version.
**
**  Auth: Kate
**  Date: 10/2/2014
******************************************************************************************************/

BEGIN
  DECLARE 
    @v_error  INT,
    @v_rowcount INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT c.taqversionspecategorykey, c.itemcategorycode, 
    CASE
      WHEN c.relatedspeccategorykey > 0 THEN (SELECT speccategorydescription FROM taqversionspeccategory WHERE taqversionspecategorykey = c.relatedspeccategorykey)
      ELSE c.speccategorydescription
    END speccategorydescription,
	g.datadesc, g.sortorder, CASE WHEN g.qsicode = 1 THEN 1 ELSE 0 END is_summary
  FROM taqversionspeccategory c, gentables g 
  WHERE c.itemcategorycode = g.datacode 
    AND g.tableid = 616 
    AND taqprojectkey = @i_projectkey
    AND plstagecode = @i_plstage
    AND taqversionkey = @i_versionkey
    AND taqversionformatkey = @i_formatkey
  ORDER BY is_summary DESC, g.sortorder, g.datadesc
      
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionspeccategory table (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@i_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@i_versionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
    RETURN
  END

END
GO

GRANT EXEC ON qpl_get_taqversionspeccategory_basic TO PUBLIC
GO
