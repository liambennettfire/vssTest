IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qproject_copy_project_sharedsections]') AND type IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qproject_copy_project_sharedsections]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_sharedsections]
(
  @i_copy_projectkey INTEGER,
  @i_new_projectkey INTEGER,
  @i_userid VARCHAR(30),
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS

/**************************************************************************************************************************
**  Name: qproject_copy_project_sharedsections
**  Desc: Copy Shared Sections of a Print Run PO without related printings
**
**      If you call this procedure from anyplace other than qproject_copy_project,
**      you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Colman
**    Date: June 6, 2017
*****************************************************************************************************************************
**    Date:        Author:         Description:
**    --------     --------        --------------------------------------------------------------------------------------
*****************************************************************************************************************************/

DECLARE 
	@v_itemtype                 INT,
	@v_usageclass               INT,
  @v_new_taqversionformatkey  INT,
  @v_plstagecode              INT, 
  @v_taqversionkey            INT, 
  @v_taqprojectformatkey      INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''  
  
  DECLARE taqversionformat_cursor CURSOR FOR
    SELECT taqprojectformatkey, plstagecode, taqversionkey
    FROM taqversionformat
    WHERE taqprojectkey = @i_copy_projectkey 
      AND sharedposectionind = 1

  OPEN taqversionformat_cursor

  FETCH taqversionformat_cursor
  INTO @v_taqprojectformatkey, @v_plstagecode, @v_taqversionkey

  WHILE (@@FETCH_STATUS = 0)
  BEGIN
    EXEC qpl_copy_format @i_new_projectkey, @v_plstagecode, @v_taqversionkey, 0, @v_taqprojectformatkey, 
      NULL, 3, 0, @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT

    IF @o_error_code <> 0 BEGIN
      PRINT 'Copy Shared Sections ' + @o_error_desc
      RETURN
    END 
    
    FETCH taqversionformat_cursor
    INTO @v_taqprojectformatkey, @v_plstagecode, @v_taqversionkey
  END

  CLOSE taqversionformat_cursor
  DEALLOCATE taqversionformat_cursor   

