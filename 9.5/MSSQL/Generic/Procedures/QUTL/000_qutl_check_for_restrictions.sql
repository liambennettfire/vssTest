IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_check_for_restrictions')
BEGIN
  PRINT 'Dropping Procedure qutl_check_for_restrictions'
  DROP  Procedure  qutl_check_for_restrictions
END
GO

PRINT 'Creating Procedure qutl_check_for_restrictions'
GO

CREATE PROCEDURE qutl_check_for_restrictions
 (@i_datetypecode   integer,
  @i_bookkey        integer,
  @i_printingkey    integer,
  @i_taqprojectkey  integer,
  @i_formatkey      integer,
  @i_elementtype    integer,
  @i_elementkey     integer,
  @o_taqtaskkey     integer output,
  @o_returncode     integer output,
  @o_restrcode      integer output,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_check_for_restrictions
**              
**    Parameters:
**    Input              
**    ----------         
**    datetypecode, bookkey, printingkey, taqprojectkey, formatkey, elementtpe, elementkey
**    
**    Output
**    -----------
**    taqtaskkey
**    returncode  0 No duplicates found
**                1 Duplicate element task found
**                2 Duplicate title task found
**                3 Duplicate "project" task found
**                4 Duplicate task per Title/Format found
**               -1 Error
**
**  Auth: Kusum Basra
**  Date: 07/31/2012
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:     Author:   Description:
**  --------  -------   ------------
**  2/21/13   Kate      Duplicate task per title/format + elements bug
*******************************************************************************/

DECLARE
  @v_count  INT,
  @v_relateddatacode  INT,
  @v_taqtaskkey INT

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @o_taqtaskkey = 0
  SET @o_returncode = 0
  SET @o_restrcode = 0  

  IF @i_elementkey > 0 AND @i_elementtype IS NOT NULL
  BEGIN

    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323
      AND datacode = @i_datetypecode
      AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 7)
      AND itemtypesubcode = @i_elementtype

    IF @v_count > 0
      SELECT @v_relateddatacode = COALESCE(relateddatacode,0)
      FROM gentablesitemtype
      WHERE tableid = 323
        AND datacode = @i_datetypecode
        AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 7)
        AND itemtypesubcode = @i_elementtype   
    ELSE
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesitemtype
      WHERE tableid = 323
        AND datacode = @i_datetypecode
        AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 7)
        AND COALESCE(itemtypesubcode,0) = 0

      IF @v_count > 0
        SELECT @v_relateddatacode = COALESCE(relateddatacode,0)
        FROM gentablesitemtype
        WHERE tableid = 323
          AND datacode = @i_datetypecode
          AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 7)
          AND COALESCE(itemtypesubcode,0) = 0
    END

    IF @v_relateddatacode > 0
      SET @o_restrcode = @v_relateddatacode
    
    IF @v_relateddatacode = 2 --only 1 task allowed
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM taqprojecttaskelement_view
      WHERE taqelementkey = @i_elementkey AND datetypecode = @i_datetypecode

      IF @v_count > 0
      BEGIN
        SELECT @v_taqtaskkey = taqtaskkey
        FROM taqprojecttaskelement_view
        WHERE taqelementkey = @i_elementkey AND datetypecode = @i_datetypecode 

        SET @o_taqtaskkey = @v_taqtaskkey
        SET @o_returncode = 1        
        RETURN
      END
    END 
  END  --IF @i_elementkey > 0 AND @i_elementtype IS NOT NULL

  IF @i_taqprojectkey > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323
      AND datacode = @i_datetypecode
      AND itemtypecode = (SELECT searchitemcode FROM taqproject WHERE taqprojectkey = @i_taqprojectkey)
      AND itemtypesubcode = (SELECT usageclasscode FROM taqproject WHERE taqprojectkey = @i_taqprojectkey)

    IF @v_count > 0
      SELECT @v_relateddatacode = COALESCE(relateddatacode,0)
      FROM gentablesitemtype
      WHERE tableid = 323
        AND datacode = @i_datetypecode
        AND itemtypecode = (SELECT searchitemcode FROM taqproject WHERE taqprojectkey = @i_taqprojectkey)
        AND itemtypesubcode = (SELECT usageclasscode FROM taqproject WHERE taqprojectkey = @i_taqprojectkey)
    ELSE
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesitemtype
      WHERE tableid = 323
        AND datacode = @i_datetypecode
        AND itemtypecode = (SELECT searchitemcode FROM taqproject WHERE taqprojectkey = @i_taqprojectkey)
        AND COALESCE(itemtypesubcode,0) = 0

      IF @v_count > 0
        SELECT @v_relateddatacode = COALESCE(relateddatacode,0)
        FROM gentablesitemtype
        WHERE tableid = 323
          AND datacode = @i_datetypecode
          AND itemtypecode = (SELECT searchitemcode FROM taqproject WHERE taqprojectkey = @i_taqprojectkey)
          AND COALESCE(itemtypesubcode,0) = 0
    END 

    IF @v_relateddatacode > 0
      SET @o_restrcode = @v_relateddatacode
    
    IF @v_relateddatacode = 2 --only 1 task allowed
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM taqprojecttask
      WHERE taqprojectkey = @i_taqprojectkey
        AND datetypecode = @i_datetypecode

      IF @v_count > 0
      BEGIN
        SELECT @v_taqtaskkey = taqtaskkey
        FROM taqprojecttask
        WHERE taqprojectkey = @i_taqprojectkey
        AND datetypecode = @i_datetypecode 

        SET @o_taqtaskkey = @v_taqtaskkey
        SET @o_returncode = 3
        RETURN
      END
    END
    ELSE IF @v_relateddatacode = 4  --Only 1 task per Title/Format
    BEGIN
      IF @i_formatkey > 0
        SELECT @v_count = COUNT(*)
        FROM taqprojecttask
        WHERE taqprojectkey = @i_taqprojectkey
          AND datetypecode = @i_datetypecode
          AND taqprojectformatkey = @i_formatkey
      ELSE
        SELECT @v_count = COUNT(*)
        FROM taqprojecttask
        WHERE taqprojectkey = @i_taqprojectkey
          AND datetypecode = @i_datetypecode
          AND COALESCE(bookkey,0) = COALESCE(@i_bookkey,0)

      IF @v_count > 0 
      BEGIN
        IF @i_formatkey > 0
          SELECT @v_taqtaskkey = taqtaskkey
          FROM taqprojecttask
          WHERE taqprojectkey = @i_taqprojectkey
            AND datetypecode = @i_datetypecode
            AND taqprojectformatkey = @i_formatkey
        ELSE
          SELECT TOP 1 @v_taqtaskkey = taqtaskkey
          FROM taqprojecttask t
            LEFT OUTER JOIN taqprojecttitle pt ON t.taqprojectformatkey = pt.taqprojectformatkey 
          WHERE t.taqprojectkey = @i_taqprojectkey
            AND t.datetypecode = @i_datetypecode
            AND COALESCE(t.bookkey,0) = COALESCE(@i_bookkey,0)
          ORDER BY primaryformatind DESC

        SET @o_taqtaskkey = @v_taqtaskkey
        SET @o_returncode = 4
        RETURN
      END
    END    
  END  ---@i_taqprojectkey IS NOT NULL AND @i_taqprojectkey > 0 
 
  IF @i_bookkey > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM gentablesitemtype
    WHERE tableid = 323
      AND datacode = @i_datetypecode
      AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 1)
      AND itemtypesubcode = (SELECT usageclasscode FROM book WHERE bookkey = @i_bookkey)

    IF @v_count > 0
      SELECT @v_relateddatacode = COALESCE(relateddatacode,0)
      FROM gentablesitemtype
      WHERE tableid = 323
        AND datacode = @i_datetypecode
        AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 1)
        AND itemtypesubcode = (SELECT usageclasscode FROM book WHERE bookkey = @i_bookkey)
    ELSE
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM gentablesitemtype
      WHERE tableid = 323
        AND datacode = @i_datetypecode
        AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 1)
        AND COALESCE(itemtypesubcode,0) = 0

      IF @v_count > 0
        SELECT @v_relateddatacode = COALESCE(relateddatacode,0)
        FROM gentablesitemtype
        WHERE tableid = 323
          AND datacode = @i_datetypecode
          AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 1)
          AND COALESCE(itemtypesubcode,0) = 0
    END

    IF @v_relateddatacode > 0 AND ((@i_taqprojectkey > 0 AND @o_restrcode = 0) OR @i_taqprojectkey = 0)
      SET @o_restrcode = @v_relateddatacode
      
    IF @v_relateddatacode = 2 --only 1 task allowed
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM taqprojecttask
      WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND datetypecode = @i_datetypecode

      IF @v_count > 0
      BEGIN
        SELECT @v_taqtaskkey = taqtaskkey
        FROM taqprojecttask
        WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey AND datetypecode = @i_datetypecode 

        SET @o_taqtaskkey = @v_taqtaskkey
        SET @o_returncode = 2
        SET @o_restrcode = @v_relateddatacode
        RETURN
      END
    END
  END  ---@i_bookkey IS NOT NULL AND @i_bookkey > 0
 
END
GO

GRANT EXEC ON qutl_check_for_restrictions TO PUBLIC
GO
