IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qpl_get_fg_quantity') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qpl_get_fg_quantity
GO

CREATE PROCEDURE [dbo].[qpl_get_fg_quantity]
 (@i_formatkey       INTEGER,
  @i_plstagecode     INTEGER,
  @i_taqversionkey   INTEGER,
  @o_fg_categorykey  INTEGER OUTPUT,
  @o_fg_quantity     INTEGER OUTPUT,
  @o_error_code      INTEGER OUTPUT,
  @o_error_desc      VARCHAR(2000) OUTPUT)
AS

/*********************************************************************************
**  Name: qpl_get_fg_quantity
**  Desc: 
**
**  Auth: Colman
**  Date: May 22, 2017
**
**   @i_plstagecode    (not used)
**   @i_taqversionkey  (not used)
**
**********************************************************************************
**    Change History
**********************************************************************************
**    Date:        Author:        Description:
**    ----------   ----------     ------------------------------------------------
***********************************************************************************/
  
DECLARE
  @v_sharedposectionind INT,
  @v_fg_categorykey  INT,
  @v_error_code INT,
  @v_error_desc VARCHAR(2000)

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_fg_categorykey = 0
  SET @o_fg_quantity = 0

  IF @v_sharedposectionind = 1
  BEGIN
    -- PRINT 'IF format is shared po section, total the quantities on taqversionformatrelatedproject'
    SELECT @o_fg_quantity = SUM(ISNULL(quantity, 0)) FROM taqversionformatrelatedproject WHERE taqversionformatkey = @i_formatkey
  END
  ELSE
  BEGIN
    -- Not shared section format
    -- PRINT 'SELECT finished good FROM current format'
    SELECT @o_fg_quantity = ISNULL(quantity, 0), @o_fg_categorykey = taqversionspecategorykey 
    FROM taqversionspeccategory 
    WHERE taqversionformatkey = @i_formatkey AND finishedgoodind = 1
    
    IF @@ROWCOUNT = 0
    BEGIN
      -- PRINT 'If NOT found, get quantity FROM shared section if related format belongs to one'
      SELECT @o_fg_quantity = ISNULL(r.quantity, 0)
      FROM taqversionformatrelatedproject r
        JOIN taqversionformat fs ON fs.taqprojectformatkey = r.taqversionformatkey AND fs.sharedposectionind = 1
        JOIN taqversionspeccategory c ON c.taqversionformatkey = r.taqversionformatkey AND ISNULL(c.finishedgoodind,0) = 1
      WHERE r.relatedversionformatkey = @i_formatkey

      IF @@ROWCOUNT = 0
      BEGIN
        -- PRINT 'If NOT found, SELECT fg=1 FROM related components on format'
        SELECT @o_fg_quantity = ISNULL(quantity,0), @o_fg_categorykey = taqversionspecategorykey 
        FROM taqversionspeccategory 
        WHERE finishedgoodind=1
          AND taqversionspecategorykey 
            IN (SELECT relatedspeccategorykey FROM taqversionspeccategory WHERE taqversionformatkey = @i_formatkey)
      END
    END
  END
  
  SELECT @v_error_code = @@ERROR
  IF @v_error_code <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could NOT access taqversionspeccategories or taqversionformatrelatedproject table: taqprojectformatkey=' + CAST(@i_formatkey AS VARCHAR) + ').'
  END

END

go

GRANT EXEC ON qpl_get_fg_quantity TO PUBLIC
go