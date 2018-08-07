if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_process_background_recalc') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_process_background_recalc
GO

CREATE PROCEDURE qpl_process_background_recalc (  
  @i_reset_minutes  integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*********************************************************************************************************************************
**  Name: qpl_process_background_recalc
**  Desc: This is the timed stored procedure running in the background to process the recalculation of
**        p&l summmary items that do not need to be processed immediately.
**
**  Auth: Kate
**  Date: January 26 2016
**********************************************************************************************************************************
**	Change History
**********************************************************************************************************************************
**	Date      Author  Description
**	------    ------  -----------
**	05/23/16  Kate    Added the missing logic to reset processingind to 0 for older rows, based on passed @i_reset_minutes value.
**  09/15/16  Uday    Case 40486
**********************************************************************************************************************************/

DECLARE
  @v_count INT,
  @v_errorcode  INT,
  @v_errordesc  VARCHAR(2000),
  @v_jointacctgind  TINYINT,
  @v_plstage  INT,
  @v_plversion  INT,
  @v_projectkey INT,
  @v_recalcgroup  INT,
  @v_summarylevel INT,
  @v_userid VARCHAR(30),
  @v_debug INT
  
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_debug = 0
  
  -- Reset the in-progress indicator for any rows where lastmaintdate is older than @i_reset_minutes (default 60 minutes, if passed)
  IF @i_reset_minutes > 0
    UPDATE taqversionrecalcneeded
    SET processingind = 0
    WHERE processingind = 1 
	  AND lastmaintdate < DATEADD(MI, -COALESCE(@i_reset_minutes,60), GETDATE())

  -- Continue looping through all rows that are set to process in the background
  WHILE ((SELECT COUNT(*) FROM taqversionrecalcneeded r
			INNER JOIN plsummaryitemrecalcorder o 
				ON  r.summarylevelcode = o.summarylevelcode 
				AND  r.jointacctgonlyind = o.jointacctgind
				WHERE r.processingind = 0) > 0)
  BEGIN

    -- Get the top row to process (earliest row based on timestamp)   
    SELECT TOP 1 @v_projectkey = r.taqprojectkey, @v_plstage = r.plstagecode, @v_plversion = r.taqversionkey, 
	  @v_summarylevel = r.summarylevelcode, @v_jointacctgind = r.jointacctgonlyind, @v_userid = r.lastuserid, @v_recalcgroup = o.recalcgroup
    FROM taqversionrecalcneeded r, plsummaryitemrecalcorder o
    WHERE r.summarylevelcode = o.summarylevelcode AND
      r.jointacctgonlyind = o.jointacctgind AND
      r.processingind = 0
    ORDER BY r.lastmaintdate, o.recalcgroup, o.sortwithingroup
    
	IF @v_debug = 1 BEGIN
		PRINT '--'
		PRINT '@v_projectkey=' + CONVERT(VARCHAR, @v_projectkey)
		PRINT '@v_plstage=' + CONVERT(VARCHAR, @v_plstage)
		PRINT '@v_plversion=' + CONVERT(VARCHAR, @v_plversion)
		PRINT '@v_summarylevel=' + CONVERT(VARCHAR, @v_summarylevel)
		PRINT '@v_jointacctgind=' + CONVERT(VARCHAR, @v_jointacctgind)
		PRINT '@v_recalcgroup=' + CONVERT(VARCHAR, @v_recalcgroup)
	END

    -- *** Check if rows exist for lower recalc group than this one - could be still calculating or not calculated yet ***
    IF @v_jointacctgind = 1 BEGIN
      -- NOTE: Right now, no joint acctg rows depend on other, but this can change if we use saved Version-level items
      -- when calculating Stage-level items. We will need to check if rows exist for lower recalc groups for that projectkey and jointacctgind=1.
      SET @v_count = 0  
    END
    ELSE IF @v_summarylevel = 5 BEGIN
      -- For Consolidated Stage level rows (always for Master projects), check if any Joint Acctg rows exist for lower recalc groups, p&l-related projects
      SELECT @v_count = COUNT(*)
      FROM taqversionrecalcneeded r, plsummaryitemrecalcorder o
      WHERE r.summarylevelcode = o.summarylevelcode AND
        r.jointacctgonlyind = o.jointacctgind AND
        r.jointacctgonlyind = 1 AND
        o.recalcgroup < @v_recalcgroup AND
        r.taqprojectkey IN 
          (SELECT relatedprojectkey FROM projectrelationshipview 
            WHERE taqprojectkey = @v_projectkey AND relationshipcode IN (SELECT datacode FROM gentables WHERE tableid = 582 AND gen1ind = 1)) --P&L Relationship
    END
    ELSE BEGIN
      -- For non-Joint Acctg rows (other than Consolidated), check if any rows exist for lower recalc groups for this current project
      SELECT @v_count = COUNT(*)
      FROM taqversionrecalcneeded r, plsummaryitemrecalcorder o
      WHERE r.summarylevelcode = o.summarylevelcode AND
        r.jointacctgonlyind = o.jointacctgind AND
        r.jointacctgonlyind = 0 AND
        o.recalcgroup < @v_recalcgroup AND
        r.taqprojectkey = @v_projectkey
    END

	IF @v_debug = 1 BEGIN
		PRINT '@v_count=' + CONVERT(VARCHAR, @v_count)
	END
	
    IF @v_count > 0
      CONTINUE

    -- Call the stored procedure that will execute recalculation of any active p&l summary items
    -- of this specific level/joint acctg for the current project version
    EXEC qpl_process_recalc @v_projectkey, @v_plstage, @v_plversion, @v_summarylevel, @v_jointacctgind, 
      @v_userid, @v_errorcode OUTPUT, @v_errordesc OUTPUT

    IF @v_errorcode <> 0
      GOTO ERROR

  END --loop

  RETURN

  ERROR:
  SET @o_error_code = -1
  SET @o_error_desc = 'Recalc of P&L summary items failed: taqprojectkey = ' + CAST(@v_projectkey AS VARCHAR)
  IF @v_errordesc <> ''
    SET @o_error_desc = @o_error_desc + ' (' + @v_errordesc + ')'
  RETURN

END
GO

GRANT EXEC ON qpl_process_background_recalc TO PUBLIC
GO
