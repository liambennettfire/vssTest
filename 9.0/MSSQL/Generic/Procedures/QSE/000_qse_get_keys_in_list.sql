IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_keys_in_list')
BEGIN
  PRINT 'Dropping Procedure qse_get_keys_in_list'
  DROP  Procedure  qse_get_keys_in_list
END
GO

PRINT 'Creating Procedure qse_get_keys_in_list'
GO

CREATE PROCEDURE qse_get_keys_in_list
 (@i_listkey      INT,
  @i_selectall    INT,
  @o_error_code   INT OUT,
  @o_error_desc   VARCHAR(2000) OUT)
AS

/******************************************************************************
**  Name: qse_get_keys_in_list
**
**  Auth: Alan Katzen
**  Date: 2/26/2008
*******************************************************************************/

BEGIN
  DECLARE
    @error_var    INT,
    @rowcount_var INT,
    @errormsg_var VARCHAR(2000),
    @ListType INT,
    @ListOwnerKey INT,
    @SearchItem SMALLINT,
    @SearchType INT,
    @UsageClass SMALLINT,
    @indicator1 INT,
    @indicator2 INT,
    @quantity1 INT,
    @quantity2 INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

	SET @indicator1 = 0
	SET @indicator2 = 0
	SET @quantity1 = 0
	SET @quantity2 = 0
  
  -- verify primary listkey is filled in
  IF @i_listkey IS NULL OR @i_listkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to select list: listkey is empty.'
    RETURN
  END 

  -- Get list details for the given listkey
  SELECT @SearchType = searchtypecode, @SearchItem = searchitemcode, @UsageClass = usageclasscode,
         @ListType = listtypecode, @ListOwnerKey = userkey
    FROM qse_searchlist
   WHERE listkey = @i_listkey

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Missing qse_searchlist record for listkey ' + CONVERT(VARCHAR, @i_listkey)
    RETURN
  END

  IF @SearchItem = 1 		    -- Titles
    BEGIN
      IF @i_selectall = 1 BEGIN
        -- Return all items in list
        SELECT key1, COALESCE(key2, 1) key2, @indicator1 as indicator1, @indicator2 as indicator2, @quantity1 as quantity1, @quantity2 as quantity2,
           COALESCE(dbo.qtitle_get_authors_from_qsicomments(key1),c.authorname) as authors,
		      (SELECT workkey FROM book WHERE bookkey = c.bookkey) c_workkey,       
          CASE
            WHEN (SELECT COUNT(*) FROM book WHERE workkey = c.bookkey and bookkey <> workkey) > 0 THEN 1
            ELSE 0
          END c_hassubordinates,
          CASE
            WHEN (SELECT COUNT(*) FROM book WHERE propagatefrombookkey = c.bookkey) > 0 THEN 1
            ELSE 0
          END c_ispropagating,
          CASE
            WHEN (SELECT COUNT(*) FROM bookauthor WHERE bookkey = c.bookkey AND primaryind=1) = 1 THEN (SELECT authorkey FROM bookauthor WHERE bookkey = c.bookkey AND primaryind=1)
            ELSE 0
          END authorkey,
          (SELECT editiondescription FROM bookdetail WHERE bookkey = c.bookkey) editiondescription,
          COALESCE((SELECT TOP 1 p.taqprojectkey FROM taqproject p WHERE p.workkey = c.workkey AND p.searchitemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode=9)),
            COALESCE((SELECT TOP 1 t.taqprojectkey FROM taqprojecttitle t WHERE c.bookkey = t.bookkey AND t.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode=1)),0)) c_workprojectkey,          
          dbo.get_gentables_desc(312,c.mediatypecode,'long') mediadesc,
          c.*,
		  CASE	  
			  WHEN c.title IS NOT NULL THEN c.title + ' / ' + COALESCE(c.authorname, '')
			  ELSE c.authorname
		  END titleauthorname,
		  CASE	  
			  WHEN c.bisacstatusdesc IS NOT NULL THEN c.bisacstatusdesc + ' / ' + (SELECT COALESCE(editiondescription, '') FROM bookdetail WHERE bookkey = c.bookkey)
			  ELSE (SELECT COALESCE(editiondescription, '') FROM bookdetail WHERE bookkey = c.bookkey)
		  END bisacstatuseditiondescription,
		 (SELECT datadesc FROM gentables WHERE tableid = 312 AND datacode = c.mediatypecode) + ' / ' + c.formatname formatdesc
        FROM qse_searchresults r, coretitleinfo c
        WHERE r.key1 = c.bookkey
           ANd r.key2 = c.printingkey 
           AND listkey = @i_listkey
        ORDER BY workkey, linklevelcode
      END
      ELSE BEGIN
        --Return only the selected items in list
        SELECT key1, COALESCE(key2, 1) key2, @indicator1 as indicator1, @indicator2 as indicator2, @quantity1 as quantity1, @quantity2 as quantity2,
           COALESCE(dbo.qtitle_get_authors_from_qsicomments(key1),c.authorname) as authors,
		      (SELECT workkey FROM book WHERE bookkey = c.bookkey) c_workkey,       
          CASE
            WHEN (SELECT COUNT(*) FROM book WHERE workkey = c.bookkey and bookkey <> workkey) > 0 THEN 1
            ELSE 0
          END c_hassubordinates,
          CASE
            WHEN (SELECT COUNT(*) FROM book WHERE propagatefrombookkey = c.bookkey) > 0 THEN 1
            ELSE 0
          END c_ispropagating,
          CASE
            WHEN (SELECT COUNT(*) FROM bookauthor WHERE bookkey = c.bookkey AND primaryind=1) = 1 THEN (SELECT authorkey FROM bookauthor WHERE bookkey = c.bookkey AND primaryind=1)
            ELSE 0
          END authorkey,
          (SELECT editiondescription FROM bookdetail WHERE bookkey = c.bookkey) editiondescription,
          COALESCE((SELECT TOP 1 p.taqprojectkey FROM taqproject p WHERE p.workkey = c.workkey AND p.searchitemcode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode=9)),
            COALESCE((SELECT TOP 1 t.taqprojectkey FROM taqprojecttitle t WHERE c.bookkey = t.bookkey AND t.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode=1)),0)) c_workprojectkey,         
          dbo.get_gentables_desc(312,c.mediatypecode,'long') mediadesc,
          c.*,
		  CASE	  
			  WHEN c.title IS NOT NULL THEN c.title + ' / ' + COALESCE(c.authorname, '')
			  ELSE c.authorname
		  END titleauthorname,
		  CASE	  
			  WHEN c.bisacstatusdesc IS NOT NULL THEN c.bisacstatusdesc + ' / ' + (SELECT COALESCE(editiondescription, '') FROM bookdetail WHERE bookkey = c.bookkey)
			  ELSE (SELECT COALESCE(editiondescription, '') FROM bookdetail WHERE bookkey = c.bookkey)
		  END bisacstatuseditiondescription,
		 (SELECT datadesc FROM gentables WHERE tableid = 312 AND datacode = c.mediatypecode) + ' / ' + c.formatname formatdesc
        FROM qse_searchresults r, coretitleinfo c
        WHERE r.key1 = c.bookkey
           AND r.key2 = c.printingkey 
           AND listkey = @i_listkey
           AND selectedind = 1
        ORDER BY workkey, linklevelcode
      END
    END
    
  ELSE IF @SearchItem = 2   -- Contacts
    BEGIN
      IF @i_selectall = 1 BEGIN
        -- Return all items in list
        SELECT key1, key2, c.*
          FROM qse_searchresults r, corecontactinfo c
         WHERE r.key1 = c.contactkey 
           AND listkey = @i_listkey
      END
      ELSE BEGIN
        --Return only the selected items in list
        SELECT key1, key2, c.*
          FROM qse_searchresults r, corecontactinfo c
         WHERE r.key1 = c.contactkey 
           AND listkey = @i_listkey 
           AND selectedind = 1
      END
    END
    
  ELSE IF @SearchItem = 4   --Lists
    BEGIN
      IF @i_selectall = 1 BEGIN
        -- Return all items in list
        SELECT key1, key2, l.*
          FROM qse_searchresults r, qse_searchlist l
         WHERE r.listkey = @i_listkey
      END
      ELSE BEGIN
        --Return only the selected items in list
        SELECT key1, key2, l.*
          FROM qse_searchresults r, qse_searchlist l
         WHERE r.listkey = @i_listkey 
           AND r.selectedind = 1
      END
    END
 
  ELSE IF @SearchItem = 8   --Task View/Groups
    BEGIN
      IF @i_selectall = 1 BEGIN
        -- Return all items in list
        SELECT key1, key2, tv.*
          FROM qse_searchresults r, taskview tv
         WHERE r.key1 = tv.taskviewkey
           AND r.listkey = @i_listkey
      END
      ELSE BEGIN
        --Return only the selected items in list
        SELECT key1, key2, tv.*
          FROM qse_searchresults r, taskview tv
         WHERE r.key1 = tv.taskviewkey
           AND r.listkey = @i_listkey
           AND r.selectedind = 1
      END
    END

  ELSE  --all project type items
    BEGIN
      IF @i_selectall = 1 BEGIN
        -- Return all items in list
        SELECT key1, key2, c.*, @indicator1 as indicator1, @indicator2 as indicator2, @quantity1 as quantity1, @quantity2 as quantity2
          FROM qse_searchresults r, coreprojectinfo c
         WHERE r.key1 = c.projectkey 
           AND listkey = @i_listkey
      END
      ELSE BEGIN
        --Return only the selected items in list
        SELECT key1, key2, c.*, @indicator1 as indicator1, @indicator2 as indicator2, @quantity1 as quantity1, @quantity2 as quantity2
          FROM qse_searchresults r, coreprojectinfo c
         WHERE r.key1 = c.projectkey 
           AND listkey = @i_listkey 
           AND selectedind = 1
      END
    END  
  
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'List does not exist for listkey = ' + cast(@i_listkey AS VARCHAR) + '.'
  END
    
END
GO

GRANT EXEC ON qse_get_keys_in_list TO PUBLIC
GO
