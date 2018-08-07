IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_check_private_status')
BEGIN
  PRINT 'Dropping Procedure qse_check_private_status'
  DROP PROCEDURE qse_check_private_status
END
GO

PRINT 'Creating Procedure qse_check_private_status'
GO

CREATE PROCEDURE qse_check_private_status
 (@i_ListKey  INT,
  @o_PrivateInd TINYINT OUT,
  @o_error_code INT OUT,
  @o_error_desc VARCHAR(2000) OUT)
AS

BEGIN
  DECLARE 
    @v_ListType   INT,
    @v_ListDesc   VARCHAR(100),
    @v_NumPrivate INT,
    @v_SearchType INT,
    @v_UserKey    INT,
    @v_error_var  INT
      
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  -- Get userkey and searchtype associated with this list
  SELECT @v_ListDesc = listdesc, @v_UserKey = userkey, @v_SearchType = searchtypecode
  FROM qse_searchlist
  WHERE listkey = @i_ListKey
      
  -- Check if any private items exist on this list
  IF @v_SearchType = 8  --Contact search
    SELECT @v_NumPrivate = COUNT(*)
    FROM qse_searchresults, corecontactinfo
    WHERE qse_searchresults.key1 = corecontactinfo.contactkey AND
        qse_searchresults.listkey = @i_ListKey AND
        corecontactinfo.privateind = 1
  ELSE IF @v_SearchType = 7 --Project search
    SELECT @v_NumPrivate = COUNT(*)
    FROM qse_searchresults, coreprojectinfo
    WHERE qse_searchresults.key1 = coreprojectinfo.projectkey AND
        qse_searchresults.listkey = @i_ListKey AND
        coreprojectinfo.privateind = 1
  ELSE
    SET @v_NumPrivate = 0
    
  -- Set the Private indicator
  IF @v_NumPrivate > 0
    SET @o_PrivateInd = 1 
  ELSE
    SET @o_PrivateInd = 0 
      
  -- If this list is private, make sure it is removed from all lists of lists
  -- for all users except the owner of the list and people on his/her private team
  IF @o_PrivateInd = 1
  BEGIN
    -- Determine listtype based on the searchtype
    SET @v_ListType =
    CASE @v_SearchType
      WHEN 6 THEN 5 --Titles
      WHEN 7 THEN 7 --Projects
      WHEN 8 THEN 6 --Contacts
    END
    
    -- Remove the private list from all lists of lists for all users
    -- except the list owner and people on his/her private team
    DELETE FROM qse_searchresults
    WHERE key1 = @i_ListKey AND listkey IN 
     (SELECT listkey FROM qse_searchlist 
      WHERE searchtypecode = 16 AND
          listtypecode = @v_ListType AND
          userkey <> @v_UserKey AND
          userkey NOT IN (SELECT primaryuserkey 
                          FROM qsiprivateuserlist 
                          WHERE accesstouserkey = @v_UserKey))
                          
    SELECT @v_error_var = @@ERROR
    IF @v_error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not remove private list ' + UPPER(@v_ListDesc) + ' from existing lists owned by users outside of current private team (' + CONVERT(VARCHAR, @v_UserKey) + ').'
    END
                          
  END  
  
END
GO

GRANT EXEC ON qse_check_private_status TO PUBLIC
GO
