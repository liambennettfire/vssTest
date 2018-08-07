IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qse_get_usageclass_for_list')
BEGIN
  PRINT 'Dropping Procedure qse_get_usageclass_for_list'
  DROP PROCEDURE  qse_get_usageclass_for_list
END
GO

PRINT 'Creating Procedure qse_get_usageclass_for_list'
GO

CREATE PROCEDURE [dbo].[qse_get_usageclass_for_list]
(
  @i_listkey          INT,
  @i_itemtypecode     INT,
  @o_usageclasscode   INT OUT,
  @o_error_code       INT OUT,
  @o_error_desc       VARCHAR(2000) OUT 
)
AS

/******************************************************************************
**  Name: qse_get_usageclass_for_list
**  Desc: This stored procedure will return the usageclass for a list if
**        the results are all in the same usageclass - otherwise it will return 0.
**
**  Auth: Alan Katzen
**  Date: May 16, 2012
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

BEGIN
  DECLARE 
    @CheckCount INT,
    @v_error_code INT,
    @v_error_desc VARCHAR(2000)  
    

  SET NOCOUNT ON
  
  SET @o_usageclasscode = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
      
  ---- Get list details for the given listkey
  --SELECT @SearchType = searchtypecode, @SearchItem = searchitemcode, @ListUsageClass = usageclasscode,
  --    @ListType = listtypecode, @ListOwnerKey = userkey
  --FROM qse_searchlist
  --WHERE listkey = @i_listkey

  --SELECT @ErrorValue = @@ERROR, @RowcountValue = @@ROWCOUNT
  --IF @ErrorValue <> 0 OR @RowcountValue = 0 BEGIN
  --  SET @o_error_code = -1
  --  SET @o_error_desc = 'Missing qse_searchlist record for listkey ' + CONVERT(VARCHAR, @i_ListKey)
  --  RETURN
  --END
  
  IF COALESCE(@i_listkey,0) = 0 BEGIN
    RETURN
  END

  IF COALESCE(@i_itemtypecode,0) = 0 BEGIN
    RETURN
  END
  
  IF @i_itemtypecode = 1 BEGIN	    -- Titles
    -- see if results are have the same usageclass
    SELECT @CheckCount = count(*) FROM 
      (SELECT distinct c.usageclasscode
         FROM qse_searchresults sr, coretitleinfo c
        WHERE sr.key1 = c.bookkey 
          and sr.key2 = c.printingkey
          and c.itemtypecode = @i_itemtypecode
          and sr.listkey = @i_listkey) as d
          
    IF @CheckCount = 1 BEGIN
      SELECT TOP 1 @o_usageclasscode = c.usageclasscode
        FROM qse_searchresults sr, coretitleinfo c
       WHERE sr.key1 = c.bookkey 
         and sr.key2 = c.printingkey
         and c.itemtypecode = @i_itemtypecode
         and sr.listkey = @i_listkey      
    END
  END
  ELSE IF @i_itemtypecode = 2 BEGIN  -- Contacts
    SET @o_usageclasscode = 0
  END    
  ELSE IF @i_itemtypecode = 3 OR @i_itemtypecode = 6 OR @i_itemtypecode = 9 OR
          @i_itemtypecode = 10 OR @i_itemtypecode = 11 BEGIN  -- Projects,Journals,Works,Contracts,Scales
    -- see if results are have the same usageclass
    SELECT @CheckCount = count(*) FROM 
      (SELECT distinct c.usageclasscode
         FROM qse_searchresults sr, coreprojectinfo c
        WHERE sr.key1 = c.projectkey 
          and c.searchitemcode = @i_itemtypecode
          and sr.listkey = @i_listkey) as d
          
    IF @CheckCount = 1 BEGIN
      SELECT TOP 1 @o_usageclasscode = c.usageclasscode
        FROM qse_searchresults sr, coreprojectinfo c
       WHERE sr.key1 = c.projectkey 
         and c.searchitemcode = @i_itemtypecode
         and sr.listkey = @i_listkey      
    END  
  END
  
  --PRINT '@UsageClass:' + CONVERT(VARCHAR, @o_usageclasscode)
  
END
GO

GRANT EXEC ON dbo.qse_get_usageclass_for_list TO PUBLIC
GO
