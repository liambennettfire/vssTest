if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_listkey_for_usergroup') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_listkey_for_usergroup
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_listkey_for_usergroup
 (@i_userid             varchar(30),
  @i_listkey			integer		  output,
  @o_error_code         integer       output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_listkey_for_usergroup
**  Desc: This returns the listkey for the contacts related to the groupkey of the user
**
**
**    Auth: Uday A. Khisty
**    Date: 20 May 2015
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT,
		  @rowcount_var INT,
		  @v_userkey  INT,
		  @v_count  INT,
		  @v_error  INT,
		  @v_listkey INT,
		  @v_contactkey INT
		  
  -- Get the userkey for the passed User ID
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE userid = @i_userid
  
  SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
  IF @v_error <> 0 OR @v_count = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get userkey from qsiusers table for UserID: ' + CONVERT(VARCHAR, @i_userid)
    RETURN
  END
		  

  IF NOT EXISTS(SELECT * FROM qse_searchlist 
			WHERE userkey = @v_userkey AND 
				  searchtypecode = 8 AND 
				  listtypecode = 4 AND
				  searchitemcode = 2) BEGIN
				  
      -- Generate new listkey
      EXECUTE get_next_key @i_userid, @v_listkey OUTPUT				  
					
	  INSERT INTO qse_searchlist 
		(listkey,
		userkey,
		searchtypecode,
		listtypecode,
		listdesc,
		lastuserid,
		lastmaintdate,
		defaultind,
		searchitemcode,
		usageclasscode,
		firebrandlockind,
		resultswithnoorgsind)
    VALUES
		(@v_listkey,
		@v_userkey,
		8,
		4,
		'Temp Search',
		@i_userid,
		getdate(),
		1,
		2,
		0,
		0,
		0)			
  END
  ELSE BEGIN
	SELECT @v_listkey = listkey FROM qse_searchlist 
				WHERE userkey = @v_userkey AND 
					  searchtypecode = 8 AND 
					  listtypecode = 4 AND
					  searchitemcode = 2	
  END
  
  DELETE FROM qse_searchresults WHERE listkey = @v_listkey
  
  SELECT DISTINCT TOP(1) @v_contactkey = globalcontactkey from globalcontact where userid = @v_userkey
  
  INSERT INTO qse_searchresults (listkey, key1, key2, key3)
  SELECT DISTINCT @v_listkey, globalcontactkey, 0, 0 FROM globalcontact WHERE userid IN
																				(SELECT accesstouserkey FROM qsiprivateuserlist WHERE primaryuserkey = @v_userkey)  
  UNION SELECT DISTINCT @v_listkey, globalcontactkey, 0, 0 FROM globalcontact WHERE userid = @v_userkey
  																				
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Unable to insert values into qse_searchresults '
  END   				  
  
  
  SET @i_listkey = @v_listkey
  
GO
GRANT EXEC ON qutl_get_listkey_for_usergroup TO PUBLIC
GO


