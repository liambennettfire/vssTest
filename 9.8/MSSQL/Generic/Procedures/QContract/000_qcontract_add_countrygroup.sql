if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontract_add_countrygroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontract_add_countrygroup
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontract_add_countrygroup
 (@i_groupname			  varchar(40),
  @i_bookkey			  integer,
  @i_printingkey		  integer,
  @i_projectkey			  integer,
  @i_userid				  varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontract_add_countrygroup
**  Desc: This procedure adds a new country group relation with the given name
**
**	Auth: Dustin Miller
**	Date: May 14 2012
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:       Author:            Description:
**  -------   ------------      ----------------------------------------------------
**  10/25/15   Uday A. Khisty   Handle Org Level Filtering on Country Groups.
*******************************************************************************/

  DECLARE @v_newdatacode		INT,
		  @v_duplicatecount	    INT,
		  @v_lockresult			INT,
		  @v_error				INT,
          @v_rowcount			INT,
          @v_filterorglevelkey  INT,
          @v_orgentrykey		INT,
          @v_orgentrydesc		VARCHAR(40),
          @v_GroupNameWithOrgLevelDescription Varchar(40)

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_orgentrykey = 0
  SET @v_orgentrydesc = ''
  
  SELECT @v_filterorglevelkey = COALESCE(filterorglevelkey, 0)
  FROM gentablesdesc where tableid = 633
  
  IF @v_filterorglevelkey > 0 BEGIN
	 IF @i_bookkey > 0 AND @i_printingkey > 0 BEGIN
		SELECT @v_orgentrykey = orgentrykey 
		FROM bookorgentry WHERE bookkey = @i_bookkey AND orglevelkey = @v_filterorglevelkey
	 END
	 ELSE IF @i_projectkey > 0 BEGIN
		SELECT @v_orgentrykey = orgentrykey 
		FROM taqprojectorgentry WHERE taqprojectkey = @i_projectkey AND orglevelkey = @v_filterorglevelkey		
	 END
	 
	 IF @v_orgentrykey > 0 BEGIN
		SELECT @v_orgentrydesc = LTRIM(RTRIM(orgentryshortdesc)) 
		FROM orgentry 
		WHERE orgentrykey = @v_orgentrykey AND orglevelkey = @v_filterorglevelkey
		
		IF @v_orgentrydesc IS NULL OR @v_orgentrydesc = '' BEGIN
			SELECT @v_orgentrydesc = LTRIM(RTRIM(orgentrydesc)) 
			FROM orgentry 
			WHERE orgentrykey = @v_orgentrykey AND orglevelkey = @v_filterorglevelkey			
		END
	 END
  END
  
  IF LEN(@v_orgentrydesc) > 0 BEGIN
	SET @v_GroupNameWithOrgLevelDescription = LEFT(@i_groupname + ' [' + @v_orgentrydesc + ']', 40)
  END 
  ELSE 
	SET @v_GroupNameWithOrgLevelDescription = @i_groupname
	
  SELECT @v_duplicatecount = COUNT(*)
	FROM gentables
	WHERE tableid=633
		AND LOWER(datadesc) = LOWER(@v_GroupNameWithOrgLevelDescription)
		
	IF @v_duplicatecount = 0
	BEGIN
		BEGIN TRANSACTION
		EXEC @v_lockresult = sp_getapplock @Resource = 'qcontract_add_countrygroup', @LockMode = 'Exclusive', @LockTimeout = 3000 --Time to wait for the lock
		IF @v_lockresult <> 0
		BEGIN
		 ROLLBACK TRANSACTION
		 SET @o_error_code = -1
		 SET @o_error_desc = 'Error. There is already a Country Group with that name (group name=' + @v_GroupNameWithOrgLevelDescription + ')'
		END
		ELSE BEGIN
			SELECT @v_newdatacode = MAX(datacode) + 1
			FROM gentables
			WHERE tableid=633
			
			IF @v_newdatacode IS NULL
			BEGIN
				SET @v_newdatacode = 1
			END
			
			IF LEN(@v_GroupNameWithOrgLevelDescription) >= 20 BEGIN
			   INSERT INTO gentables
			   (tableid, datadesc, datadescshort, tablemnemonic, lockbyqsiind, datacode, lastuserid, lastmaintdate)
			   VALUES
			   (633, @v_GroupNameWithOrgLevelDescription, NULL, 'CTRYGRP', 1, @v_newdatacode, @i_userid, GETDATE())			
			END
			ELSE BEGIN
			   INSERT INTO gentables
			   (tableid, datadesc, datadescshort, tablemnemonic, lockbyqsiind, datacode, lastuserid, lastmaintdate)
			   VALUES
			   (633, @v_GroupNameWithOrgLevelDescription, @v_GroupNameWithOrgLevelDescription, 'CTRYGRP', 1, @v_newdatacode, @i_userid, GETDATE())			
			END
			
			IF @v_orgentrykey > 0 BEGIN
			   INSERT INTO gentablesorglevel
			   (tableid, datacode, orgentrykey, lastuserid, lastmaintdate)
			   VALUES
			   (633, @v_newdatacode, @v_orgentrykey, @i_userid, GETDATE())				
			END
			
			COMMIT TRANSACTION
			SELECT @v_newdatacode AS datacode
		END
	END
	ELSE BEGIN
		SET @o_error_code = -1
    SET @o_error_desc = 'Error. There is already a Country Group with that name (group name=' + @v_GroupNameWithOrgLevelDescription + ')'
    RETURN  
	END
		
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error inserting country group to gentables (group name=' + @v_GroupNameWithOrgLevelDescription + ')'
    RETURN  
  END   
GO

GRANT EXEC ON qcontract_add_countrygroup TO PUBLIC
GO