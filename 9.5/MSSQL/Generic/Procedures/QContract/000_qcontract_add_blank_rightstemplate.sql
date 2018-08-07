if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_add_blank_rightstemplate') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_add_blank_rightstemplate
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_add_blank_rightstemplate
 (@i_rightsdesc    varchar(255),
  @i_userkey       integer,
  @i_orgkey1       integer,
  @i_orgkey2       integer,
  @i_orgkey3       integer,
  @o_error_code    integer output,
  @o_error_desc    varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_add_blank_rightstemplate
**  Desc: This procedure will create rows for a new blank rights template
**
**	Auth: Dustin Miller
**	Date: June 18 2012
********************************
**  Modified By: Colman
**  Date: December 18, 2015
**	Desc: Modified to add orgentry parameters for Case 28988
********************************
**  Modified By: Alan
**  Date: March 28, 2016
**	Desc: Modified to allow no orgentries to be created for Case 28988
*******************************************************************************/

  DECLARE @v_projectkey			    INT,
          @v_rightskey			    INT,
          @v_territoryrightskey INT,
          @v_searchitemcode		  INT,
          @v_usageclasscode		  INT,
          @v_projecttype		    INT,	
          @v_statuscode			    INT,
          @v_error				      INT,
          @v_rowcount			      INT,
          @v_userid             varchar(30)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_projectkey = NULL
  SET @v_rightskey = NULL
  SET @v_territoryrightskey = NULL
  SET @v_searchitemcode = NULL
  SET @v_usageclasscode = NULL
  SET @v_projecttype = NULL
  SET @v_statuscode = NULL
	
  SELECT @v_searchitemcode=datacode, @v_usageclasscode = datasubcode  
  FROM subgentables
  WHERE tableid=550 AND 
        qsicode=50
		
  SELECT @v_projecttype=datacode FROM gentables
  WHERE tableid=521
	AND qsicode=3
	AND upper(deletestatus) <> 'Y'
		
  SELECT @v_statuscode=datacode FROM gentables
  WHERE tableid=522
	AND qsicode=3
	--AND upper(deletestatus) <> 'Y'
		
  SET @v_userid = ''
  select @v_userid = userid FROM qsiusers
  where userkey = @i_userkey

  if @v_userid is null or rtrim(ltrim(@v_userid)) = '' begin
    SET @v_userid = 'BLANKTEMPLATE'
  end

	IF @v_searchitemcode IS NOT NULL AND @v_usageclasscode IS NOT NULL AND @v_projecttype IS NOT NULL AND @v_statuscode IS NOT NULL
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
			(@v_projectkey, @i_userkey, @i_rightsdesc, @v_statuscode, @v_searchitemcode, @v_usageclasscode, @v_projecttype, 1,
			@v_userid, GETDATE())
			
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
			(@v_rightskey, @v_projectkey, @v_userid, GETDATE())
			
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
			(@v_territoryrightskey, 10, @v_projectkey, @v_rightskey, @v_userid, GETDATE())
			
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error inserting to taqproject (projectkey=' + cast(@v_projectkey as varchar) + ')'
				ROLLBACK TRAN
				RETURN  
			END
			
      -- CREATE PROJECT ORG ENTRY RECORDS
      IF @i_orgkey1 > 0 BEGIN
        SELECT @v_rowcount = count(*)
        FROM taqprojectorgentry
        WHERE taqprojectkey = @v_projectkey
        AND orglevelkey = 1
        AND orgentrykey = @i_orgkey1
        
        IF @v_rowcount = 0 BEGIN
          INSERT INTO taqprojectorgentry(taqprojectkey, orglevelkey, orgentrykey, lastmaintdate, lastuserid)
          VALUES(@v_projectkey, 1, @i_orgkey1, getdate(), @v_userid)
        END
      END

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error inserting to taqprojectorgentry (projectkey=' + cast(@v_projectkey as varchar) + ')'
				ROLLBACK TRAN
				RETURN  
			END
			
      IF @i_orgkey2 > 0 BEGIN
        SELECT @v_rowcount = count(*)
        FROM taqprojectorgentry
        WHERE taqprojectkey = @v_projectkey
        AND orglevelkey = 2
        AND orgentrykey = @i_orgkey2
        
        IF @v_rowcount = 0 BEGIN
          INSERT INTO taqprojectorgentry(taqprojectkey, orglevelkey, orgentrykey, lastmaintdate, lastuserid)
          VALUES(@v_projectkey, 2, @i_orgkey2, getdate(), @v_userid)
        END
      END

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error inserting to taqprojectorgentry (projectkey=' + cast(@v_projectkey as varchar) + ')'
				ROLLBACK TRAN
				RETURN  
			END
			
      IF @i_orgkey3 > 0 BEGIN
        SELECT @v_rowcount = count(*)
        FROM taqprojectorgentry
        WHERE taqprojectkey = @v_projectkey
        AND orglevelkey = 3
        AND orgentrykey = @i_orgkey3
        
        IF @v_rowcount = 0 BEGIN
          INSERT INTO taqprojectorgentry(taqprojectkey, orglevelkey, orgentrykey, lastmaintdate, lastuserid)
          VALUES(@v_projectkey, 3, @i_orgkey3, getdate(), @v_userid)
        END 
      END
      
			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Error inserting to taqprojectorgentry (projectkey=' + cast(@v_projectkey as varchar) + ')'
				ROLLBACK TRAN
				RETURN  
			END
			
			COMMIT TRAN
		END
	END
  ELSE BEGIN
		SET @o_error_code = -1
    SET @o_error_desc = 'Error obtaining search item code/usage class code or initial status or initial type for rights templates.'
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