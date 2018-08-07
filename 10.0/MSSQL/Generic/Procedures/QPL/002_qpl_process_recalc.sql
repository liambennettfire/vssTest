if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_process_recalc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_process_recalc
GO

CREATE PROCEDURE qpl_process_recalc (  
  @i_projectkey     integer,
  @i_plstage        integer,
  @i_plversion      integer,
  @i_summarylevel   integer,
  @i_jointacctgind  tinyint,
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**********************************************************************************************************************
**  Name: qpl_process_recalc
**  Desc: This stored procedure checks the taqversionrecalcneeded table to see if any rows need recalculation of 
**        p&l summary items, and if so, calls the qpl_recalc_pl_items. It is called from the timed stored procedure 
**        qpl_process_background_recalc as well as from TMM when trying to view p&l summary items 
**        (P&L Summary: stage-level, P&L Versions: version-level, and P&L Version by Year: year-level).
**
**  Auth: Kate
**  Date: July 9 2014
***********************************************************************************************************************
**	Change History
***********************************************************************************************************************
**	Date      Author  Description
**	--------  ------  -----------
**	03/31/16  Kate    Case 35972 - Background recalc - modified to call by summary level/jointacctgind
**  04/29/16  Colman  Close cursors on error out
**  05/19/16  Kate    Case 35972 - Background recalc adjustments
**  06/18/16  Kate    Set processingind to 100 instead of 0 if something goes wrong with recalc
**  09/15/16  Uday    Case 40486
**********************************************************************************************************************/

DECLARE
  @v_count  INT,
  @v_deletestatus CHAR(1),
  @v_plstagecode  INT,
  @v_versionkey INT,
  @v_debug INT

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_debug = 0
  
  IF @v_debug = 1 BEGIN
	  PRINT 'inside process recalc'
	  PRINT '@i_projectkey=' + CONVERT(VARCHAR, @i_projectkey)
	  PRINT '@i_plstage=' + CONVERT(VARCHAR, @i_plstage)
	  PRINT '@i_plversion=' + CONVERT(VARCHAR, @i_plversion)
	  PRINT '@i_summarylevel=' + CONVERT(VARCHAR, @i_summarylevel)
	  PRINT '@i_jointacctgind=' + CONVERT(VARCHAR, @i_jointacctgind)
  END
  
  -- The summary level must be active
  SELECT @v_deletestatus = COALESCE(UPPER(deletestatus), 'N')
  FROM gentables
  WHERE tableid = 561 AND datacode = @i_summarylevel

  IF @v_deletestatus = 'Y'
    GOTO CLEANUP_AND_EXIT

  -- At least one active saved summary item must exist for the given summary level to be processed
  IF @i_jointacctgind = 1
    SELECT @v_count = COUNT(*)
    FROM plsummaryitemdefinition 
    WHERE summarylevelcode = @i_summarylevel AND activeind = 1 AND alwaysrecalcind = 0 AND jointacctgind = 1
  ELSE
    SELECT @v_count = COUNT(*)
    FROM plsummaryitemdefinition 
    WHERE summarylevelcode = @i_summarylevel AND activeind = 1 AND alwaysrecalcind = 0
   
  IF @v_count = 0
    GOTO CLEANUP_AND_EXIT

  -- For Stage and Consolidated Stage levels, if plstage was not passed in, we need to made sure that all stages for this project
  -- get recalculated that have the taqversionrecalcneeded rows - it means that this stored procedure was probably called from TMM
  -- trying to view the Stage-level (or Consolidated Stage-level) items. The screen displays all Stages.
  IF (@i_summarylevel = 1 OR @i_summarylevel = 5) AND @i_plstage = 0
    DECLARE plstages_cur CURSOR FOR
      SELECT DISTINCT plstagecode 
      FROM taqversionrecalcneeded 
      WHERE taqprojectkey = @i_projectkey
  ELSE
    DECLARE plstages_cur CURSOR FOR
      SELECT @i_plstage
      
  OPEN plstages_cur 

  FETCH plstages_cur INTO @v_plstagecode

  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
	IF @v_debug = 1 BEGIN
       PRINT '@v_plstagecode=' + CONVERT(VARCHAR, @v_plstagecode)
	END

    IF @i_plversion = 0
      DECLARE plversions_cur CURSOR FOR
        SELECT taqversionkey
        FROM taqversion
        WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode
    ELSE
      DECLARE plversions_cur CURSOR FOR
        SELECT @i_plversion

    OPEN plversions_cur 

    FETCH plversions_cur INTO @v_versionkey

    WHILE (@@FETCH_STATUS=0)
    BEGIN
    
      IF @v_debug = 1 BEGIN
		PRINT '@v_versionkey=' + CONVERT(VARCHAR, @v_versionkey)
	  END
      
      -- Mark this row as being processed
      -- NOTE: If processing all items (jointacctgind=0), we should mark both jointacctg=1 and jointacctg=0 rows as processed (and later delete both)
      UPDATE taqversionrecalcneeded
      SET processingind = 1
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode AND taqversionkey IN (@v_versionkey,0)
        AND summarylevelcode = @i_summarylevel AND jointacctgonlyind IN (@i_jointacctgind,1)

      -- Call the recalc stored procedure to process this specific passed P&L Summary Level/Joint Accounting row
      EXEC qpl_recalc_pl_items @i_projectkey, @v_plstagecode, @v_versionkey, @i_summarylevel, @i_jointacctgind, 
	      @i_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT

      IF @o_error_code <> 0
      BEGIN
        -- Something went wrong with the recalc - reset processingind to 100 to indicate a warning so that the background process can proceed to next row
        UPDATE taqversionrecalcneeded
        SET processingind = 100
        WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode AND taqversionkey IN (@v_versionkey,0)
          AND summarylevelcode = @i_summarylevel AND jointacctgonlyind IN (@i_jointacctgind,1)
        
        CLOSE plversions_cur
        DEALLOCATE plversions_cur
        CLOSE plstages_cur
        DEALLOCATE plstages_cur
        RETURN
      END      

      -- Delete this row from taqversionrecalcneeded - recalc successfully completed
      DELETE FROM taqversionrecalcneeded
      WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode AND taqversionkey IN (@v_versionkey,0)
        AND summarylevelcode = @i_summarylevel AND jointacctgonlyind IN (@i_jointacctgind,1)

      FETCH plversions_cur INTO @v_versionkey
    END

    CLOSE plversions_cur
    DEALLOCATE plversions_cur

    FETCH plstages_cur INTO @v_plstagecode
  END

  CLOSE plstages_cur
  DEALLOCATE plstages_cur

  RETURN

  CLEANUP_AND_EXIT:
  -- Delete this row from taqversionrecalcneeded - recalc was not needed
  DELETE FROM taqversionrecalcneeded
  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstage AND taqversionkey = @i_plversion
    AND summarylevelcode = @i_summarylevel AND jointacctgonlyind = @i_jointacctgind

  RETURN

END
GO

GRANT EXEC ON qpl_process_recalc TO PUBLIC
GO
