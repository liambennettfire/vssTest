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
  @i_orgentrystring varchar(MAX),
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
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:       Author:            Description:
**  -------   ------------      ----------------------------------------------------
**  02/03/17   Uday A. Khisty   Case 43344
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
          @v_userid             varchar(30),
		  @v_OrgKeyAsString  varchar(100),
		  @v_OrgKey          INT,
		  @v_CommaIndex INT,  -- Reused as the start index for the key.
		  @v_StartLocation INT,
		  @v_orglevelkey INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_projectkey = NULL
  SET @v_rightskey = NULL
  SET @v_territoryrightskey = NULL
  SET @v_searchitemcode = NULL
  SET @v_usageclasscode = NULL
  SET @v_projecttype = NULL
  SET @v_statuscode = NULL
  SET @v_OrgKey = 0
  SET @v_orglevelkey = 0
	
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
	  WHILE LEN(@i_orgentrystring) > 0
	  BEGIN
		  SET @i_orgentrystring = REPLACE(@i_orgentrystring, '(', '')
		  SET @i_orgentrystring = REPLACE(@i_orgentrystring, ')', '')
		  SET @v_OrgKey = 0	     
		  SET @v_CommaIndex = CHARINDEX(',', @i_orgentrystring)

		  IF @v_CommaIndex is not null and  @v_CommaIndex <> 0
		  BEGIN
			SET @v_OrgKeyAsString = SUBSTRING(@i_orgentrystring, 0, @v_CommaIndex)

			IF ISNUMERIC(LTRIM(RTRIM(@v_OrgKeyAsString))) = 1 BEGIN
				SET @v_OrgKey = CONVERT(int, LTRIM(RTRIM(@v_OrgKeyAsString)))
			END

  			SET @v_StartLocation = LEN(@v_OrgKeyAsString)
			SET @i_orgentrystring = SUBSTRING(@i_orgentrystring, @v_CommaIndex + 1, LEN(@i_orgentrystring) - @v_StartLocation)
		  END
		  ELSE IF @v_CommaIndex = 0 BEGIN
			IF ISNUMERIC(LTRIM(RTRIM(@i_orgentrystring))) = 1 BEGIN
				SET @v_OrgKey = CONVERT(int, LTRIM(RTRIM(@i_orgentrystring)))
			END		

			SET @i_orgentrystring = ''
		  END

		  IF @v_OrgKey > 0 BEGIN
			SET @v_orglevelkey = @v_orglevelkey + 1

			SELECT @v_rowcount = count(*)
			FROM taqprojectorgentry
			WHERE taqprojectkey = @v_projectkey
			AND orglevelkey = 1
			AND orgentrykey = @v_OrgKey
        
			IF @v_rowcount = 0 BEGIN
			  INSERT INTO taqprojectorgentry(taqprojectkey, orglevelkey, orgentrykey, lastmaintdate, lastuserid)
			  VALUES(@v_projectkey, @v_orglevelkey, @v_OrgKey, getdate(), @v_userid)
			END
		  END

		  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		  IF @v_error <> 0 BEGIN
			  SET @o_error_code = -1
			  SET @o_error_desc = 'Error inserting to taqprojectorgentry (projectkey=' + cast(@v_projectkey as varchar) + ')'
			  ROLLBACK TRAN
			  RETURN  
		  END
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