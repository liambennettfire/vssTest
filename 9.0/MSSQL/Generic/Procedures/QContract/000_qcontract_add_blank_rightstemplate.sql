if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_add_blank_rightstemplate') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_add_blank_rightstemplate
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_add_blank_rightstemplate
 (@i_rightsdesc						varchar(255),
	@i_userkey							integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_add_blank_rightstemplate
**  Desc: This procedure will create rows for a new blank rights template
**
**	Auth: Dustin Miller
**	Date: June 18 2012
*******************************************************************************/

  DECLARE @v_projectkey					INT,
					@v_rightskey					INT,
					@v_territoryrightskey INT,
					@v_searchitemcode			INT,
					@v_usageclasscode			INT,
					@v_statuscode					INT,
					@v_error							INT,
          @v_rowcount						INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_projectkey = NULL
  SET @v_rightskey = NULL
  SET @v_territoryrightskey = NULL
  SET @v_searchitemcode = NULL
  SET @v_usageclasscode = NULL
  SET @v_statuscode = NULL
	
  SELECT @v_searchitemcode=datacode FROM gentables
	WHERE tableid=550
		AND qsicode=5
		AND upper(deletestatus) <> 'Y'
		
	SELECT @v_usageclasscode=datacode FROM gentables
	WHERE tableid=521
		AND qsicode=3
		AND upper(deletestatus) <> 'Y'
		
	SELECT @v_statuscode=datacode FROM gentables
	WHERE tableid=522
		AND qsicode=3
		AND upper(deletestatus) <> 'Y'
		
	IF @v_searchitemcode IS NOT NULL AND @v_usageclasscode IS NOT NULL AND @v_statuscode IS NOT NULL
	BEGIN
		EXEC get_next_key 'qsidba', @v_projectkey OUTPUT
		EXEC get_next_key 'qsidba', @v_rightskey OUTPUT
		EXEC get_next_key 'qsidba', @v_territoryrightskey OUTPUT
		IF @v_projectkey IS NOT NULL AND @v_rightskey IS NOT NULL AND @v_territoryrightskey IS NOT NULL
		BEGIN
			BEGIN TRAN
			
			INSERT INTO taqproject
			(taqprojectkey, taqprojectownerkey, taqprojecttitle, taqprojectstatuscode, searchitemcode, usageclasscode, taqprojecttype, templateind,
			lastuserid, lastmaintdate)
			VALUES
			(@v_projectkey, @i_userkey, @i_rightsdesc, @v_statuscode, @v_searchitemcode, @v_usageclasscode, @v_usageclasscode, 1,
			'qsidba', GETDATE())
			
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error inserting to taqproject (projectkey=' + cast(@v_projectkey as varchar) + ')'
				ROLLBACK TRAN
				RETURN  
			END
			
			INSERT INTO taqprojectrights
			(rightskey, taqprojectkey, lastuserid, lastmaintdate)
			VALUES
			(@v_rightskey, @v_projectkey, 'qsidba', GETDATE())
			
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error inserting to taqprojectrights (projectkey=' + cast(@v_projectkey as varchar) + ')'
				ROLLBACK TRAN
				RETURN  
			END
			
			INSERT INTO territoryrights
			(territoryrightskey, itemtype, taqprojectkey, rightskey, lastuserid, lastmaintdate)
			VALUES
			(@v_territoryrightskey, 10, @v_projectkey, @v_rightskey, 'qsidba', GETDATE())
			
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error inserting to taqproject (projectkey=' + cast(@v_projectkey as varchar) + ')'
				ROLLBACK TRAN
				RETURN  
			END
			
			COMMIT TRAN
		END
	END
  ELSE BEGIN
		SET @o_error_code = -1
    SET @o_error_desc = 'Error obtaining search item code/usage class code for rights templates.'
    RETURN 
	END
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error creating blank rights template (projectkey=' + cast(@v_projectkey as varchar) + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_add_blank_rightstemplate TO PUBLIC
GO