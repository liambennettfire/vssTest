if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qscale_check_scale_duplicates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qscale_check_scale_duplicates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qscale_check_scale_duplicates
 (@i_projectkey               integer,
  @o_error_code               integer output,
  @o_error_desc               varchar(2000) output)
AS

/******************************************************************************
**  Name: qscale_check_scale_duplicates
**  Desc: This stored procedure will check the given scale for duplicates,
**				and set the status to pending if any duplicates are found
**
**    Auth: Dustin Miller
**    Date: August 1, 2012
*******************************************************************************/

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_current_proj_status	int,
          @v_currenttime	datetime,
          @v_duplicate_count	int,
          @v_projstatus_active	int,
          @v_corescaleparameterkey	int,
          @v_taqprojectkey	int,
          @v_scalename	varchar(255),
          @v_scaletype	int,
          @v_scaletypedesc	varchar(50),
          @v_scalestatuscode	int,
          @v_scalestatusdesc	varchar(50),
          @v_orgentrykey	int,
          @v_vendorkey	int,
          @v_effectivedate	datetime,
          @v_expirationdate	datetime,
          @v_lastuserid	varchar(30),
          @v_lastmaintdate	datetime,
					@v_parameter1categorycode int,
          @v_parameter1categorydesc varchar(50),
          @v_parameter1code int,
          @v_parameter1desc varchar(50),
          @v_parameter1value int,
          @v_parameter1value2 int,
          @v_parameter2categorycode int,
          @v_parameter2categorydesc varchar(50),
          @v_parameter2code int,
          @v_parameter2desc varchar(50),
          @v_parameter2value int,
          @v_parameter2value2 int,
          @v_parameter3categorycode int,
          @v_parameter3categorydesc varchar(50),
          @v_parameter3code int,
          @v_parameter3desc varchar(50),
          @v_parameter3value int,
          @v_parameter3value2 int,
          @v_parameter4categorycode int,
          @v_parameter4categorydesc varchar(50),
          @v_parameter4code int,
          @v_parameter4desc varchar(50),
          @v_parameter4value int,
          @v_parameter4value2 int,
          @v_parameter5categorycode int,
          @v_parameter5categorydesc varchar(50),
          @v_parameter5code int,
          @v_parameter5desc varchar(50),
          @v_parameter5value int,
          @v_parameter5value2 int,
          @v_parameter6categorycode int,
          @v_parameter6categorydesc varchar(50),
          @v_parameter6code int,
          @v_parameter6desc varchar(50),
          @v_parameter6value int,
          @v_parameter6value2 int,
          @v_parameter7categorycode int,
          @v_parameter7categorydesc varchar(50),
          @v_parameter7code int,
          @v_parameter7desc varchar(50),
          @v_parameter7value int,
          @v_parameter7value2 int,
          @v_parameter8categorycode int,
          @v_parameter8categorydesc varchar(50),
          @v_parameter8code int,
          @v_parameter8desc varchar(50),
          @v_parameter8value int,
          @v_parameter8value2 int,
          @v_parameter9categorycode int,
          @v_parameter9categorydesc varchar(50),
          @v_parameter9code int,
          @v_parameter9desc varchar(50),
          @v_parameter9value int,
          @v_parameter9value2 int,
          @v_parameter10categorycode int,
          @v_parameter10categorydesc varchar(50),
          @v_parameter10code int,
          @v_parameter10desc varchar(50),
          @v_parameter10value int,
          @v_parameter10value2 int,
          @v_parameter11categorycode int,
          @v_parameter11categorydesc varchar(50),
          @v_parameter11code int,
          @v_parameter11desc varchar(50),
          @v_parameter11value int,
          @v_parameter11value2 int,
          @v_parameter12categorycode int,
          @v_parameter12categorydesc varchar(50),
          @v_parameter12code int,
          @v_parameter12desc varchar(50),
          @v_parameter12value int,
          @v_parameter12value2 int,
          @v_parameter13categorycode int,
          @v_parameter13categorydesc varchar(50),
          @v_parameter13code int,
          @v_parameter13desc varchar(50),
          @v_parameter13value int,
          @v_parameter13value2 int,
          @v_parameter14categorycode int,
          @v_parameter14categorydesc varchar(50),
          @v_parameter14code int,
          @v_parameter14desc varchar(50),
          @v_parameter14value int,
          @v_parameter14value2 int,
          @v_parameter15categorycode int,
          @v_parameter15categorydesc varchar(50),
          @v_parameter15code int,
          @v_parameter15desc varchar(50),
          @v_parameter15value int,
          @v_parameter15value2 int,
          @v_parameter16categorycode int,
          @v_parameter16categorydesc varchar(50),
          @v_parameter16code int,
          @v_parameter16desc varchar(50),
          @v_parameter16value int,
          @v_parameter16value2 int,
          @v_parameter17categorycode int,
          @v_parameter17categorydesc varchar(50),
          @v_parameter17code int,
          @v_parameter17desc varchar(50),
          @v_parameter17value int,
          @v_parameter17value2 int,
          @v_parameter18categorycode int,
          @v_parameter18categorydesc varchar(50),
          @v_parameter18code int,
          @v_parameter18desc varchar(50),
          @v_parameter18value int,
          @v_parameter18value2 int,
          @v_parameter19categorycode int,
          @v_parameter19categorydesc varchar(50),
          @v_parameter19code int,
          @v_parameter19desc varchar(50),
          @v_parameter19value int,
          @v_parameter19value2 int,
          @v_parameter20categorycode int,
          @v_parameter20categorydesc varchar(50),
          @v_parameter20code int,
          @v_parameter20desc varchar(50),
          @v_parameter20value int,
          @v_parameter20value2 int
          
  -- initialize parameter values
	SET @v_parameter1value = null
	SET @v_parameter2value = null
	SET @v_parameter3value = null
	SET @v_parameter4value = null
	SET @v_parameter5value = null
	SET @v_parameter6value = null
	SET @v_parameter7value = null
	SET @v_parameter8value = null
	SET @v_parameter9value = null
	SET @v_parameter10value = null
	SET @v_parameter11value = null
	SET @v_parameter12value = null
	SET @v_parameter13value = null
	SET @v_parameter14value = null
	SET @v_parameter15value = null
	SET @v_parameter16value = null
	SET @v_parameter17value = null
	SET @v_parameter18value = null
	SET @v_parameter19value = null
	SET @v_parameter20value = null
	SET @v_parameter1value2 = null
	SET @v_parameter2value2 = null
	SET @v_parameter3value2 = null
	SET @v_parameter4value2 = null
	SET @v_parameter5value2 = null
	SET @v_parameter6value2 = null
	SET @v_parameter7value2 = null
	SET @v_parameter8value2 = null
	SET @v_parameter9value2 = null
	SET @v_parameter10value2 = null
	SET @v_parameter11value2 = null
	SET @v_parameter12value2 = null
	SET @v_parameter13value2 = null
	SET @v_parameter14value2 = null
	SET @v_parameter15value2 = null
	SET @v_parameter16value2 = null
	SET @v_parameter17value2 = null
	SET @v_parameter18value2 = null
	SET @v_parameter19value2 = null
	SET @v_parameter20value2 = null
  
  SET @v_currenttime = GETDATE()
  SET @v_duplicate_count = 0
  
  SELECT @v_current_proj_status = taqprojectstatuscode
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey
  
  SELECT @v_projstatus_active = datacode
  FROM gentables
  WHERE tableid = 522
		AND qsicode = 3
  
  DECLARE scale_cur CURSOR FAST_FORWARD FOR
  SELECT * FROM corescaleparameters
  WHERE taqprojectkey = @i_projectkey
  
  OPEN scale_cur
  
  FETCH NEXT FROM scale_cur INTO
		@v_corescaleparameterkey,
		@v_taqprojectkey,
		@v_scalename,
		@v_scaletype,
		@v_scaletypedesc,
		@v_scalestatuscode,
		@v_scalestatusdesc,
		@v_orgentrykey,
		@v_vendorkey,
		@v_effectivedate,
		@v_expirationdate,
		@v_parameter1categorycode,
		@v_parameter1categorydesc,
		@v_parameter1code,
		@v_parameter1desc,
		@v_parameter1value,
		@v_parameter1value2,
		@v_parameter2categorycode,
		@v_parameter2categorydesc,
		@v_parameter2code,
		@v_parameter2desc,
		@v_parameter2value,
		@v_parameter2value2,
		@v_parameter3categorycode,
		@v_parameter3categorydesc,
		@v_parameter3code,
		@v_parameter3desc,
		@v_parameter3value,
		@v_parameter3value2,
		@v_parameter4categorycode,
		@v_parameter4categorydesc,
		@v_parameter4code,
		@v_parameter4desc,
		@v_parameter4value,
		@v_parameter4value2,
		@v_parameter5categorycode,
		@v_parameter5categorydesc,
		@v_parameter5code,
		@v_parameter5desc,
		@v_parameter5value,
		@v_parameter5value2,
		@v_parameter6categorycode,
		@v_parameter6categorydesc,
		@v_parameter6code,
		@v_parameter6desc,
		@v_parameter6value,
		@v_parameter6value2,
		@v_parameter7categorycode,
		@v_parameter7categorydesc,
		@v_parameter7code,
		@v_parameter7desc,
		@v_parameter7value,
		@v_parameter7value2,
		@v_parameter8categorycode,
		@v_parameter8categorydesc,
		@v_parameter8code,
		@v_parameter8desc,
		@v_parameter8value,
		@v_parameter8value2,
		@v_parameter9categorycode,
		@v_parameter9categorydesc,
		@v_parameter9code,
		@v_parameter9desc,
		@v_parameter9value,
		@v_parameter9value2,
		@v_parameter10categorycode,
		@v_parameter10categorydesc,
		@v_parameter10code,
		@v_parameter10desc,
		@v_parameter10value,
		@v_parameter10value2,
		@v_parameter11categorycode,
		@v_parameter11categorydesc,
		@v_parameter11code,
		@v_parameter11desc,
		@v_parameter11value,
		@v_parameter11value2,
		@v_parameter12categorycode,
		@v_parameter12categorydesc,
		@v_parameter12code,
		@v_parameter12desc,
		@v_parameter12value,
		@v_parameter12value2,
		@v_parameter13categorycode,
		@v_parameter13categorydesc,
		@v_parameter13code,
		@v_parameter13desc,
		@v_parameter13value,
		@v_parameter13value2,
		@v_parameter14categorycode,
		@v_parameter14categorydesc,
		@v_parameter14code,
		@v_parameter14desc,
		@v_parameter14value,
		@v_parameter14value2,
		@v_parameter15categorycode,
		@v_parameter15categorydesc,
		@v_parameter15code,
		@v_parameter15desc,
		@v_parameter15value,
		@v_parameter15value2,
		@v_parameter16categorycode,
		@v_parameter16categorydesc,
		@v_parameter16code,
		@v_parameter16desc,
		@v_parameter16value,
		@v_parameter16value2,
		@v_parameter17categorycode,
		@v_parameter17categorydesc,
		@v_parameter17code,
		@v_parameter17desc,
		@v_parameter17value,
		@v_parameter17value2,
		@v_parameter18categorycode,
		@v_parameter18categorydesc,
		@v_parameter18code,
		@v_parameter18desc,
		@v_parameter18value,
		@v_parameter18value2,
		@v_parameter19categorycode,
		@v_parameter19categorydesc,
		@v_parameter19code,
		@v_parameter19desc,
		@v_parameter19value,
		@v_parameter19value2,
		@v_parameter20categorycode,
		@v_parameter20categorydesc,
		@v_parameter20code,
		@v_parameter20desc,
		@v_parameter20value,
		@v_parameter20value2,
		@v_lastuserid,
		@v_lastmaintdate
  
  WHILE (@@FETCH_STATUS = 0)
	BEGIN
		--if current curson item is active and within date range...
	
		SELECT @v_duplicate_count = @v_duplicate_count + COUNT(*)
		FROM corescaleparameters
		WHERE taqprojectkey <> @v_taqprojectkey
			AND scaletype = @v_scaletype
			AND scalestatuscode = @v_projstatus_active
			AND vendorkey = @v_vendorkey
			AND orgentrykey = @v_orgentrykey
			AND (effectivedate IS NULL OR effectivedate <= @v_currenttime)
			AND (expirationdate IS NULL OR expirationdate > @v_currenttime)
			AND
			(
				(COALESCE(parameter1categorycode, 0) = COALESCE(@v_parameter1categorycode, 0) AND
				 COALESCE(parameter1code, 0) = COALESCE(@v_parameter1code, 0) AND
				 --parameter1code IS NOT NULL AND
				 COALESCE(parameter1value1, 0) = COALESCE(@v_parameter1value, 0))
				AND
				(COALESCE(parameter2categorycode, 0) = COALESCE(@v_parameter2categorycode, 0) AND
				 COALESCE(parameter2code, 0) = COALESCE(@v_parameter2code, 0) AND
				 --parameter2code IS NOT NULL AND
				 COALESCE(parameter2value1, 0) = COALESCE(@v_parameter2value, 0))
				AND
				(COALESCE(parameter3categorycode, 0) = COALESCE(@v_parameter3categorycode, 0) AND
				 COALESCE(parameter3code, 0) = COALESCE(@v_parameter3code, 0) AND
				 --parameter3code IS NOT NULL AND
				 COALESCE(parameter3value1, 0) = COALESCE(@v_parameter3value, 0))
				AND
				(COALESCE(parameter4categorycode, 0) = COALESCE(@v_parameter4categorycode, 0) AND
				 COALESCE(parameter4code, 0) = COALESCE(@v_parameter4code, 0) AND
				 --parameter4code IS NOT NULL AND
				 COALESCE(parameter4value1, 0) = COALESCE(@v_parameter4value, 0))
				AND
				(COALESCE(parameter5categorycode, 0) = COALESCE(@v_parameter5categorycode, 0) AND
				 COALESCE(parameter5code, 0) = COALESCE(@v_parameter5code, 0) AND
				 --parameter5code IS NOT NULL AND
				 COALESCE(parameter5value1, 0) = COALESCE(@v_parameter5value, 0))
				AND
				(COALESCE(parameter6categorycode, 0) = COALESCE(@v_parameter6categorycode, 0) AND
				 COALESCE(parameter6code, 0) = COALESCE(@v_parameter6code, 0) AND
				 --parameter6code IS NOT NULL AND
				 COALESCE(parameter6value1, 0) = COALESCE(@v_parameter6value, 0))
				AND
				(COALESCE(parameter7categorycode, 0) = COALESCE(@v_parameter7categorycode, 0) AND
				 COALESCE(parameter7code, 0) = COALESCE(@v_parameter7code, 0) AND
				 --parameter7code IS NOT NULL AND
				 COALESCE(parameter7value1, 0) = COALESCE(@v_parameter7value, 0))
				AND
				(COALESCE(parameter8categorycode, 0) = COALESCE(@v_parameter8categorycode, 0) AND
				 COALESCE(parameter8code, 0) = COALESCE(@v_parameter8code, 0) AND
				 --parameter8code IS NOT NULL AND
				 COALESCE(parameter8value1, 0) = COALESCE(@v_parameter8value, 0))
				AND
				(COALESCE(parameter9categorycode, 0) = COALESCE(@v_parameter9categorycode, 0) AND
				 COALESCE(parameter9code, 0) = COALESCE(@v_parameter9code, 0) AND
				 --parameter9code IS NOT NULL AND
				 COALESCE(parameter9value1, 0) = COALESCE(@v_parameter9value, 0))
				AND
				(COALESCE(parameter10categorycode, 0) = COALESCE(@v_parameter10categorycode, 0) AND
				 COALESCE(parameter10code, 0) = COALESCE(@v_parameter10code, 0) AND
				 --parameter10code IS NOT NULL AND
				 COALESCE(parameter10value1, 0) = COALESCE(@v_parameter10value, 0))
				AND
				(COALESCE(parameter11categorycode, 0) = COALESCE(@v_parameter11categorycode, 0) AND
				 COALESCE(parameter11code, 0) = COALESCE(@v_parameter11code, 0) AND
				 --parameter11code IS NOT NULL AND
				 COALESCE(parameter11value1, 0) = COALESCE(@v_parameter11value, 0))
				AND
				(COALESCE(parameter12categorycode, 0) = COALESCE(@v_parameter12categorycode, 0) AND
				 COALESCE(parameter12code, 0) = COALESCE(@v_parameter12code, 0) AND
				 --parameter12code IS NOT NULL AND
				 COALESCE(parameter12value1, 0) = COALESCE(@v_parameter12value, 0))
				AND
				(COALESCE(parameter13categorycode, 0) = COALESCE(@v_parameter13categorycode, 0) AND
				 COALESCE(parameter13code, 0) = COALESCE(@v_parameter13code, 0) AND
				 --parameter13code IS NOT NULL AND
				 COALESCE(parameter13value1, 0) = COALESCE(@v_parameter13value, 0))
				AND
				(COALESCE(parameter14categorycode, 0) = COALESCE(@v_parameter14categorycode, 0) AND
				 COALESCE(parameter14code, 0) = COALESCE(@v_parameter14code, 0) AND
				 --parameter14code IS NOT NULL AND
				 COALESCE(parameter14value1, 0) = COALESCE(@v_parameter14value, 0))
				AND
				(COALESCE(parameter15categorycode, 0) = COALESCE(@v_parameter15categorycode, 0) AND
				 COALESCE(parameter15code, 0) = COALESCE(@v_parameter15code, 0) AND
				 --parameter15code IS NOT NULL AND
				 COALESCE(parameter15value1, 0) = COALESCE(@v_parameter15value, 0))
				AND
				(COALESCE(parameter16categorycode, 0) = COALESCE(@v_parameter16categorycode, 0) AND
				 COALESCE(parameter16code, 0) = COALESCE(@v_parameter16code, 0) AND
				 --parameter16code IS NOT NULL AND
				 COALESCE(parameter16value1, 0) = COALESCE(@v_parameter16value, 0))
				AND
				(COALESCE(parameter17categorycode, 0) = COALESCE(@v_parameter17categorycode, 0) AND
				 COALESCE(parameter17code, 0) = COALESCE(@v_parameter17code, 0) AND
				 --parameter17code IS NOT NULL AND
				 COALESCE(parameter17value1, 0) = COALESCE(@v_parameter17value, 0))
				AND
				(COALESCE(parameter18categorycode, 0) = COALESCE(@v_parameter18categorycode, 0) AND
				 COALESCE(parameter18code, 0) = COALESCE(@v_parameter18code, 0) AND
				 --parameter18code IS NOT NULL AND
				 COALESCE(parameter18value1, 0) = COALESCE(@v_parameter18value, 0))
				AND
				(COALESCE(parameter19categorycode, 0) = COALESCE(@v_parameter19categorycode, 0) AND
				 COALESCE(parameter19code, 0) = COALESCE(@v_parameter19code, 0) AND
				 --parameter19code IS NOT NULL AND
				 COALESCE(parameter19value1, 0) = COALESCE(@v_parameter19value, 0))
				AND
				(COALESCE(parameter20categorycode, 0) = COALESCE(@v_parameter20categorycode, 0) AND
				 COALESCE(parameter20code, 0) = COALESCE(@v_parameter20code, 0) AND
				 --parameter20code IS NOT NULL AND
				 COALESCE(parameter20value1, 0) = COALESCE(@v_parameter20value, 0))
			)
		
		FETCH NEXT FROM scale_cur INTO
			@v_corescaleparameterkey,
			@v_taqprojectkey,
			@v_scalename,
			@v_scaletype,
			@v_scaletypedesc,
			@v_scalestatuscode,
			@v_scalestatusdesc,
			@v_orgentrykey,
			@v_vendorkey,
			@v_effectivedate,
			@v_expirationdate,
			@v_parameter1categorycode,
			@v_parameter1categorydesc,
			@v_parameter1code,
			@v_parameter1desc,
			@v_parameter1value,
			@v_parameter1value2,
			@v_parameter2categorycode,
			@v_parameter2categorydesc,
			@v_parameter2code,
			@v_parameter2desc,
			@v_parameter2value,
			@v_parameter2value2,
			@v_parameter3categorycode,
			@v_parameter3categorydesc,
			@v_parameter3code,
			@v_parameter3desc,
			@v_parameter3value,
			@v_parameter3value2,
			@v_parameter4categorycode,
			@v_parameter4categorydesc,
			@v_parameter4code,
			@v_parameter4desc,
			@v_parameter4value,
			@v_parameter4value2,
			@v_parameter5categorycode,
			@v_parameter5categorydesc,
			@v_parameter5code,
			@v_parameter5desc,
			@v_parameter5value,
			@v_parameter5value2,
			@v_parameter6categorycode,
			@v_parameter6categorydesc,
			@v_parameter6code,
			@v_parameter6desc,
			@v_parameter6value,
			@v_parameter6value2,
			@v_parameter7categorycode,
			@v_parameter7categorydesc,
			@v_parameter7code,
			@v_parameter7desc,
			@v_parameter7value,
			@v_parameter7value2,
			@v_parameter8categorycode,
			@v_parameter8categorydesc,
			@v_parameter8code,
			@v_parameter8desc,
			@v_parameter8value,
			@v_parameter8value2,
			@v_parameter9categorycode,
			@v_parameter9categorydesc,
			@v_parameter9code,
			@v_parameter9desc,
			@v_parameter9value,
			@v_parameter9value2,
			@v_parameter10categorycode,
			@v_parameter10categorydesc,
			@v_parameter10code,
			@v_parameter10desc,
			@v_parameter10value,
			@v_parameter10value2,
			@v_parameter11categorycode,
			@v_parameter11categorydesc,
			@v_parameter11code,
			@v_parameter11desc,
			@v_parameter11value,
			@v_parameter11value2,
			@v_parameter12categorycode,
			@v_parameter12categorydesc,
			@v_parameter12code,
			@v_parameter12desc,
			@v_parameter12value,
			@v_parameter12value2,
			@v_parameter13categorycode,
			@v_parameter13categorydesc,
			@v_parameter13code,
			@v_parameter13desc,
			@v_parameter13value,
			@v_parameter13value2,
			@v_parameter14categorycode,
			@v_parameter14categorydesc,
			@v_parameter14code,
			@v_parameter14desc,
			@v_parameter14value,
			@v_parameter14value2,
			@v_parameter15categorycode,
			@v_parameter15categorydesc,
			@v_parameter15code,
			@v_parameter15desc,
			@v_parameter15value,
			@v_parameter15value2,
			@v_parameter16categorycode,
			@v_parameter16categorydesc,
			@v_parameter16code,
			@v_parameter16desc,
			@v_parameter16value,
			@v_parameter16value2,
			@v_parameter17categorycode,
			@v_parameter17categorydesc,
			@v_parameter17code,
			@v_parameter17desc,
			@v_parameter17value,
			@v_parameter17value2,
			@v_parameter18categorycode,
			@v_parameter18categorydesc,
			@v_parameter18code,
			@v_parameter18desc,
			@v_parameter18value,
			@v_parameter18value2,
			@v_parameter19categorycode,
			@v_parameter19categorydesc,
			@v_parameter19code,
			@v_parameter19desc,
			@v_parameter19value,
			@v_parameter19value2,
			@v_parameter20categorycode,
			@v_parameter20categorydesc,
			@v_parameter20code,
			@v_parameter20desc,
			@v_parameter20value,
			@v_parameter20value2,
			@v_lastuserid,
			@v_lastmaintdate
	END
	
	CLOSE scale_cur
	DEALLOCATE scale_cur
  
  SELECT @v_duplicate_count AS duplicatecount, COALESCE(@v_current_proj_status, 0) AS currentprojectstatus
	
END

GO
GRANT EXEC ON qscale_check_scale_duplicates TO PUBLIC
GO


