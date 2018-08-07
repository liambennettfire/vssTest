IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_create_working_list_from_bookmiscitem')
  BEGIN
    DROP PROCEDURE  qutl_create_working_list_from_bookmiscitem
  END
GO

PRINT 'Creating Procedure qutl_create_working_list_from_bookmiscitem'
GO

CREATE PROCEDURE qutl_create_working_list_from_bookmiscitem
 (@i_misckey      integer, -- bookmiscitems.misckey
  @i_userkey      integer,
  @o_listkey      integer output,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_create_working_list_from_bookmiscitem
**  Desc: Execute a custom SQL search as defined in miscitemcalc for a Calculated Search Int (11)
**        or Calculated Search Text (12) misc item and create a working list from the results.
**
**  Auth: Colman
**  Case: 48094
**  Date: Jan 8, 2018
**
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:       Author:   Description:
**  --------    -------   -----------------------------------------------------
*******************************************************************************/
BEGIN
  DECLARE 
    @v_searchtypecode INT,
    @v_searchsql      VARCHAR(max),
    @v_sql            NVARCHAR(max),
    @v_userid         VARCHAR(30),
    @v_itemtypecode   INT,
    @v_usageclasscode INT,
    @v_error          INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_usageclasscode = 0
  SET @o_listkey = -1
  
  SELECT @v_searchtypecode = ISNULL(searchtype, 0)
  FROM bookmiscitems 
  WHERE misckey = @i_misckey

  SELECT TOP 1 @v_userid = userid
  FROM qsiusers
  WHERE userkey = @i_userkey

  EXEC qutl_get_misc_calcsql @i_misckey, @i_userkey, @v_userid, @v_searchsql OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
   
  IF @o_error_code <> 0 OR @v_searchtypecode <= 0 OR ISNULL(@v_searchsql, '') = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'qutl_create_working_list_from_bookmiscitem called for misconfigured miscitem: misckey=' + CONVERT(VARCHAR, @i_misckey)
    RETURN
  END 

  -- The custom SQL code must be in this form:
  -- SELECT (whateverkey, whateverkey, whatever) FROM the table expected by the searchtype

  CREATE TABLE #MiscItemSearchResults (
    sortorder INT IDENTITY(1,1) PRIMARY KEY,
    key1 INT NOT NULL,
    key2 INT NULL,
    key3 INT NULL
  );

  SET @v_searchsql = 'INSERT INTO #MiscItemSearchResults (key1, key2, key3) ' + @v_searchsql
  
  -- Get SearchItemCode - hardcoding results table based on search type (as seen in qutl_update_recent_use_list)
  IF @v_searchtypecode = 1 OR @v_searchtypecode = 6
    -- Titles
    SET @v_itemtypecode = 1
  ELSE IF @v_searchtypecode = 7 OR @v_searchtypecode = 10
    -- Projects
    SET @v_itemtypecode = 3
  ELSE IF @v_searchtypecode = 8
    -- Contacts
    SET @v_itemtypecode = 2   
  ELSE IF @v_searchtypecode = 16
    -- Lists
    SET @v_itemtypecode = 4
  ELSE IF @v_searchtypecode = 17
    -- P&L Templates
    SET @v_itemtypecode = 5
  ELSE IF @v_searchtypecode = 18
    -- Journals
    SET @v_itemtypecode = 6
  ELSE IF @v_searchtypecode = 19 OR @v_searchtypecode = 20
    -- Task Views/Groups
    SET @v_itemtypecode = 8
  ELSE IF @v_searchtypecode = 22      
    -- works
    SET @v_itemtypecode = 9
  ELSE IF @v_searchtypecode = 24
    -- Scales
    SET @v_itemtypecode = 11
  ELSE IF @v_searchtypecode = 25
    -- Contracts
    SET @v_itemtypecode = 10
  ELSE IF @v_searchtypecode = 28
    -- Printings
    SET @v_itemtypecode = 14
  ELSE IF @v_searchtypecode = 29
    -- Purchase Orders
    SET @v_itemtypecode = 15
  ELSE IF @v_searchtypecode = 30
  BEGIN
    -- Admin Spec Templates
    SET @v_itemtypecode = 5
    SET @v_usageclasscode = 2
  END

  -- Get Current Working List key for the search type
  SELECT @o_listkey = listkey 
  FROM qse_searchlist 
  WHERE userkey = @i_userkey 
    AND searchtypecode = @v_searchtypecode 
    AND listtypecode = 1

  IF @o_listkey IS NULL
  BEGIN
    EXEC next_generic_key @v_userid, @o_listkey output, @o_error_code output, @o_error_desc output
    
    INSERT INTO qse_searchlist
      (listkey, userkey, searchtypecode, listtypecode, listdesc, saveascriteriaind, defaultind, lastuserid, lastmaintdate,
      autofindind, hidecriteriaind, hideorgfilterind, searchitemcode, createddate, createdbyuserid, privateind, usageclasscode, includeorglevelsind,
      firebrandlockind, resultswithnoorgsind, resultsviewkey, defaultonpopupsind)
    VALUES
      (@o_listkey, @i_userkey, @v_searchtypecode, 1, 'Current Working List', 0, 1, @v_userid, GETDATE(),
      0, 0, 0, @v_itemtypecode, GETDATE(), @v_userid, 0, @v_usageclasscode, 0, 1, 0, null, 0)
  END
  ELSE BEGIN
    DELETE FROM qse_searchresults
    WHERE listkey = @o_listkey
  END

  SET @v_sql = @v_searchsql
  
  EXECUTE sp_executesql @v_sql

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error executing custom search for bookmiscitems.misckey = ' + CONVERT(VARCHAR, @i_misckey) + ' : ' + @v_searchsql
  END 
  ELSE BEGIN
    INSERT INTO qse_searchresults
      (listkey, key1, key2, key3, selectedind, sortorder)
    SELECT
      @o_listkey, key1, ISNULL(key2,0), ISNULL(key3,0), 0, sortorder
    FROM #MiscItemSearchResults
  END
  
  DROP TABLE #MiscItemSearchResults
END

GO

GRANT EXEC ON qutl_create_working_list_from_bookmiscitem TO PUBLIC
GO
