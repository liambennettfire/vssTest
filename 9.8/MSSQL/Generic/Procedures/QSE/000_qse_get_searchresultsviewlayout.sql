IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qse_get_searchresultsviewlayout]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qse_get_searchresultsviewlayout]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qse_get_searchresultsviewlayout]
 (@i_resultsviewkey     integer,
  @i_searchtypecode     integer,
  @i_itemtypecode       integer,
  @i_usageclasscode     integer,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qse_get_searchresultsviewlayout
**  Desc: This stored procedure returns layout info for a specific result view from the 
**        qse_searchresultsviewlayout table.
**
**  Auth: Alan Katzen
**  Date: May 10, 2012
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

DECLARE @error_var                   INT,
        @rowcount_var                INT,
        @v_count                     INT,
        @v_searchtype                INT,
        @v_itemtype                  INT,
        @v_usageclass                INT,
        @v_ContactRelationshipCode1  INT,
        @v_ContactRelationshipCode2  INT,
        @v_ContactCommentTypeCode    INT        
          
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF @i_resultsviewkey > 0  
  BEGIN      
    SELECT @v_searchtype = searchtypecode, @v_itemtype = itemtypecode, @v_usageclass = usageclasscode
    FROM qse_searchresultsview 
    WHERE resultsviewkey =  @i_resultsviewkey 
    
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error accessing qse_searchresultsview table (resultsviewkey = ' + cast(@i_resultsviewkey as varchar) + ').'
    END   
    
    IF @v_searchtype = 8 AND @v_itemtype = 2 BEGIN
		SELECT @v_ContactRelationshipCode1 = COALESCE(clientdefaultvalue, 0) FROM clientdefaults WHERE clientdefaultid = 64
		SELECT @v_ContactRelationshipCode2 = COALESCE(clientdefaultvalue, 0) FROM clientdefaults WHERE clientdefaultid = 65
	    SELECT @v_ContactCommentTypeCode = COALESCE(clientdefaultvalue, 0) FROM clientdefaults WHERE clientdefaultid = 82
    END    
 
    SELECT srv.resultsviewkey, srv.columnnumber, srv.columnorder, srv.columnwidth, 
      CASE WHEN srv.columnorder > 0 THEN 'true' ELSE 'false' END selectedind,
      CASE WHEN (columnnumber = 8 AND @v_searchtype = 8 AND @v_itemtype = 2 AND @v_ContactRelationshipCode1 > 0) THEN dbo.get_gentables_desc(519,@v_ContactRelationshipCode1,'long')
      ELSE CASE WHEN (columnnumber = 9 AND @v_searchtype = 8 AND @v_itemtype = 2 AND @v_ContactRelationshipCode2 > 0) THEN dbo.get_gentables_desc(519,@v_ContactRelationshipCode2,'long')
      ELSE CASE WHEN (columnnumber = 10 AND @v_searchtype = 8 AND @v_itemtype = 2 AND @v_ContactCommentTypeCode > 0) THEN dbo.get_gentables_desc(528,@v_ContactCommentTypeCode,'long')      
      ELSE CASE (SELECT COUNT(*) FROM qse_searchresultscolumns t 
            WHERE t.columnnumber = srv.columnnumber AND searchtypecode = @v_searchtype AND searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass)
        WHEN 0 THEN (SELECT columnlabel FROM qse_searchresultscolumns t 
                     WHERE t.columnnumber = srv.columnnumber AND searchtypecode = @v_searchtype AND searchitemcode = @v_itemtype AND usageclasscode = 0)
        ELSE (SELECT columnlabel FROM qse_searchresultscolumns t 
              WHERE t.columnnumber = srv.columnnumber AND searchtypecode = @v_searchtype AND searchitemcode = @v_itemtype AND usageclasscode = @v_usageclass) 
      END END END END columnlabel
    FROM qse_searchresultsviewlayout srv
    WHERE srv.resultsviewkey = @i_resultsviewkey
    
  END
  ELSE
  BEGIN
    SELECT @v_count = count(*)
    FROM qse_searchresultscolumns 
    WHERE searchtypecode = @i_searchtypecode AND 
      searchitemcode = @i_itemtypecode AND 
      usageclasscode = @i_usageclasscode AND 
      displayind = 1
      
    IF @i_searchtypecode = 8 AND @i_itemtypecode = 2 BEGIN
		SELECT @v_ContactRelationshipCode1 = COALESCE(clientdefaultvalue, 0) FROM clientdefaults WHERE clientdefaultid = 64
		SELECT @v_ContactRelationshipCode2 = COALESCE(clientdefaultvalue, 0) FROM clientdefaults WHERE clientdefaultid = 65
	    SELECT @v_ContactCommentTypeCode = COALESCE(clientdefaultvalue, 0) FROM clientdefaults WHERE clientdefaultid = 82
    END         

    IF @v_count > 0 BEGIN
      SELECT -1 resultsviewkey, columnnumber, websortorder columnorder, defaultwidth columnwidth, 
        CASE WHEN websortorder > 0 THEN 'true' ELSE 'false' END selectedind,
		CASE WHEN (columnnumber = 8 AND @i_searchtypecode = 8 AND @i_itemtypecode = 2 AND @v_ContactRelationshipCode1 > 0) THEN dbo.get_gentables_desc(519,@v_ContactRelationshipCode1,'long')
		ELSE CASE WHEN (columnnumber = 9 AND @i_searchtypecode = 8 AND @i_itemtypecode = 2 AND @v_ContactRelationshipCode2 > 0) THEN dbo.get_gentables_desc(519,@v_ContactRelationshipCode2,'long')
		ELSE CASE WHEN (columnnumber = 10 AND @i_searchtypecode = 8 AND @i_itemtypecode = 2 AND @v_ContactCommentTypeCode > 0) THEN dbo.get_gentables_desc(528,@v_ContactCommentTypeCode,'long')        
		ELSE columnlabel
        END END END columnlabel        
      FROM qse_searchresultscolumns 
      WHERE searchtypecode = @i_searchtypecode AND 
        searchitemcode = @i_itemtypecode AND 
        usageclasscode = @i_usageclasscode AND 
        displayind = 1
    END
    ELSE BEGIN
      -- there is no default setup for usageclass - try just itemtype
      SELECT -1 resultsviewkey, columnnumber, websortorder columnorder, defaultwidth columnwidth, 
        CASE WHEN websortorder > 0 THEN 'true' ELSE 'false' END selectedind, 
		CASE WHEN (columnnumber = 8 AND @i_searchtypecode = 8 AND @i_itemtypecode = 2 AND @v_ContactRelationshipCode1 > 0) THEN dbo.get_gentables_desc(519,@v_ContactRelationshipCode1,'long')
		ELSE CASE WHEN (columnnumber = 9 AND @i_searchtypecode = 8 AND @i_itemtypecode = 2 AND @v_ContactRelationshipCode2 > 0) THEN dbo.get_gentables_desc(519,@v_ContactRelationshipCode2,'long')
		ELSE CASE WHEN (columnnumber = 10 AND @i_searchtypecode = 8 AND @i_itemtypecode = 2 AND @v_ContactCommentTypeCode > 0) THEN dbo.get_gentables_desc(528,@v_ContactCommentTypeCode,'long')        
		ELSE columnlabel
        END END END columnlabel        
      FROM qse_searchresultscolumns 
      WHERE searchtypecode = @i_searchtypecode AND 
        searchitemcode = @i_itemtypecode AND 
        usageclasscode = 0 AND 
        displayind = 1
    END
  END
     
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qse_searchresultsviewlayout table (resultsviewkey = ' + cast(@i_resultsviewkey as varchar) + ')'
  END 

END
GO

GRANT EXEC on qse_get_searchresultsviewlayout TO PUBLIC
GO

