if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_listkey_for_itemtype') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_listkey_for_itemtype
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_listkey_for_itemtype
 (@i_projectkey			integer,
  @i_bookkey			integer,
  @i_printingkey		integer,
  @i_contactkey			integer,
  @i_itemtypecode		integer,
  @i_usageclascode		integer,
  @i_userid             varchar(30),
  @i_listkey			integer		  output,
  @o_error_code         integer       output,
  @o_error_desc         varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_listkey_for_itemtype
**  Desc: This returns the listkey for the contacts related to the itemtype
**
**
**    Auth: Uday A. Khisty
**    Date: 31 August 2015
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT,
		  @rowcount_var INT,
		  @v_userkey  INT,
		  @v_count  INT,
		  @v_error  INT,
		  @v_listkey INT,
		  @v_contactkey INT,
		  @v_searchtypecode INT,
		  @v_usageclascode INT
		  
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
  
  SET @v_searchtypecode = 0
  SET @v_usageclascode = 0
  
  IF @i_itemtypecode = 1 BEGIN -- Titles
	SET @v_searchtypecode = 1
  END
  ELSE IF @i_itemtypecode = 3 BEGIN -- Projects
  	SET @v_searchtypecode = 7
  END
  ELSE IF @i_itemtypecode = 2 BEGIN -- Contacts
  	SET @v_searchtypecode = 8
  END  
  ELSE IF @i_itemtypecode = 4 BEGIN -- Lists
  	SET @v_searchtypecode = 16
  END
  ELSE IF @i_itemtypecode = 5 AND @i_usageclascode = 1 BEGIN -- P&L Templates
  	SET @v_searchtypecode = 17
  	SET @v_usageclascode = @i_usageclascode
  END
  ELSE IF @i_itemtypecode = 6 BEGIN -- Journals
  	SET @v_searchtypecode = 18
  END	
  ELSE IF @i_itemtypecode = 9 BEGIN  -- works
  	SET @v_searchtypecode = 22
  END	  	  
  ELSE IF @i_itemtypecode = 11 BEGIN -- Scales
  	SET @v_searchtypecode = 24
  END	 		
  ELSE IF @i_itemtypecode = 10 BEGIN -- Contracts
  	SET @v_searchtypecode = 25
  END	       
  ELSE IF @i_itemtypecode = 14 BEGIN  -- Printings
  	SET @v_searchtypecode = 28
  END	  
  ELSE IF @i_itemtypecode = 15 BEGIN -- Purchase Orders
  	SET @v_searchtypecode = 29
  END	
  ELSE IF @i_itemtypecode = 5 AND @i_usageclascode = 2 BEGIN
  	SET @v_searchtypecode = 30
  	SET @v_usageclascode = @i_usageclascode  	
  END	

  IF @v_searchtypecode = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get get searchtypecode for ItemTypeCode: ' + CONVERT(VARCHAR, @i_itemtypecode)
    RETURN
  END

  IF NOT EXISTS(SELECT * FROM qse_searchlist 
			WHERE userkey = @v_userkey AND 
				  searchtypecode = @v_searchtypecode AND 
				  listtypecode = 4 AND
				  searchitemcode = @i_itemtypecode AND
				  usageclasscode  = @v_usageclascode) BEGIN
				  
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
		@v_searchtypecode,
		4,
		'Temp Search',
		@i_userid,
		getdate(),
		1,
		@i_itemtypecode,
		@v_usageclascode,
		0,
		0)			
  END
  ELSE BEGIN
	SELECT @v_listkey = listkey FROM qse_searchlist 
				WHERE userkey = @v_userkey AND 
					  searchtypecode = @v_searchtypecode AND 
					  listtypecode = 4 AND
					  searchitemcode = @i_itemtypecode	AND
					  usageclasscode = @v_usageclascode
  END
  
  DELETE FROM qse_searchresults WHERE listkey = @v_listkey
  
  IF @i_itemtypecode IN (1) BEGIN -- Titles
	INSERT INTO qse_searchresults (listkey, key1, key2, key3)
    VALUES(@v_listkey, @i_bookkey, @i_printingkey, 0)	
  END  
  
  IF @i_itemtypecode IN (3, 5, 6, 11, 10, 15) BEGIN -- Projects, P&L Templates, Journals, Scales, Contracts, Purchase Orders
    INSERT INTO qse_searchresults (listkey, key1, key2, key3)
    VALUES(@v_listkey, @i_projectkey, 0, 0)	
  END
  
  IF @i_itemtypecode IN (2) BEGIN  -- Contacts
	INSERT INTO qse_searchresults (listkey, key1, key2, key3)
    VALUES(@v_listkey, @i_contactkey, 0, 0)	
  END  
  
  IF @i_itemtypecode IN (9) BEGIN  -- Works
	INSERT INTO qse_searchresults (listkey, key1, key2, key3)
    VALUES(@v_listkey, @i_projectkey, @i_bookkey, 0)	
  END   
  
  IF @i_itemtypecode IN (14) BEGIN  -- Printings
	INSERT INTO qse_searchresults (listkey, key1, key2, key3)
    VALUES(@v_listkey, @i_projectkey, @i_bookkey, @i_printingkey)	
  END    
    																				
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Unable to insert values into qse_searchresults '
  END   				  
  
  
  SET @i_listkey = @v_listkey
  
GO
GRANT EXEC ON qutl_get_listkey_for_itemtype TO PUBLIC
GO
