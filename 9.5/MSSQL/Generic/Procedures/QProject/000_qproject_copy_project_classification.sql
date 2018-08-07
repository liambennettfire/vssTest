IF EXISTS (SELECT *
             FROM dbo.sysobjects
             WHERE id = object_id(N'dbo.qproject_copy_project_classification')
               AND
               OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE dbo.qproject_copy_project_classification

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qproject_copy_project_classification]
	 (@i_copy_projectkey  integer,
		@i_new_projectkey		integer output,
		@i_userid					  varchar(30),
		@o_error_code				integer output,
		@o_error_desc				varchar(2000) output)
AS

/******************************************************************************
**  Name: [qproject_copy_project_classification]
**  Desc: This stored procedure copies the classification info.
** 
**
**			If you call this procedure from anyplace other than qproject_copy_project,
**			you must do your own transaction/commit/rollbacks on return from this procedure.
**
**    Auth: Colman
**    Date: 8 August 2016
*******************************************************************************/

DECLARE @error_var		INT,
        @v_work_template_projkey INT,
        @v_proposedterritorycode INT,
        @v_titletypecode INT,
        @v_canadianrestrictioncode INT,
        @v_returncode INT,
        @v_restrictioncode INT,
        @v_origincode INT,
        @v_copyrightyear INT,
        @v_languagecode INT,
        @v_languagecode2 INT,
        @v_allagesind TINYINT,
        @v_agelowupind TINYINT,
        @v_agelow FLOAT,
        @v_agehighupind TINYINT,
        @v_agehigh FLOAT,
        @v_gradelowupind TINYINT,
        @v_gradelow VARCHAR(4),
        @v_gradehighupind TINYINT,
        @v_gradehigh VARCHAR(4),
        @v_audiencecode INT,
        @v_sortorder INT
        
BEGIN
	SET @o_error_code = 0
	SET @o_error_desc = ''

  SELECT 
      @v_proposedterritorycode = proposedterritorycode, @v_titletypecode = titletypecode, @v_canadianrestrictioncode = canadianrestrictioncode, @v_returncode = returncode, 
      @v_restrictioncode = restrictioncode, @v_origincode = origincode, @v_copyrightyear = copyrightyear, @v_languagecode = languagecode, @v_languagecode2 = languagecode2, 
      @v_allagesind = allagesind, @v_agelowupind = agelowupind, @v_agelow = agelow, @v_agehighupind = agehighupind, @v_agehigh = agehigh, @v_gradelowupind = gradelowupind, 
      @v_gradelow = gradelow, @v_gradehighupind = gradehighupind, @v_gradehigh = gradehigh
  FROM taqproject
  WHERE taqprojectkey = @i_copy_projectkey

  UPDATE taqproject
  SET proposedterritorycode = @v_proposedterritorycode, titletypecode = @v_titletypecode, canadianrestrictioncode = @v_canadianrestrictioncode, returncode = @v_returncode, 
      restrictioncode = @v_restrictioncode, origincode = @v_origincode, copyrightyear = @v_copyrightyear, languagecode = @v_languagecode, languagecode2 = @v_languagecode2, 
      allagesind = @v_allagesind, agelowupind = @v_agelowupind, agelow = @v_agelow, agehighupind = @v_agehighupind, agehigh = @v_agehigh, gradelowupind = @v_gradelowupind, 
      gradelow = @v_gradelow, gradehighupind = @v_gradehighupind, gradehigh = @v_gradehigh
  WHERE 
      taqprojectkey = @i_new_projectkey
  
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Copy of taqproject classification data failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
    RETURN
  END 
  
  DECLARE audience_cur CURSOR FOR
  SELECT audiencecode, sortorder
  FROM taqprojectaudience
  WHERE taqprojectkey = @i_copy_projectkey 

  OPEN audience_cur
	FETCH audience_cur
  INTO @v_audiencecode, @v_sortorder

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
    INSERT INTO taqprojectaudience (taqprojectkey, audiencecode, sortorder, lastuserid, lastmaintdate)
    VALUES (@i_new_projectkey, @v_audiencecode, @v_sortorder, @i_userid, getdate())
    
    SELECT @error_var = @@ERROR
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Copy of taqproject classification audience data failed (' + cast(@error_var AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
      RETURN
    END 
		
    FETCH audience_cur
    INTO @v_audiencecode, @v_sortorder
	END

	CLOSE audience_cur
	DEALLOCATE audience_cur
 	
END
GO

GRANT EXEC ON qproject_copy_project_classification TO PUBLIC
GO