if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_verify_delete_journal_item') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_verify_delete_journal_item
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_verify_delete_journal_item
 (@i_projectkey                integer,
  @o_num_children              integer output,
  @o_error_code                integer output,
  @o_error_desc                varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_verify_delete_journal_item
**  Desc: This stored procedure verifies whether a journal item can be deleted
**        based on the existence of children items
**
**    Auth: Alan Katzen
**    Date: 16 October 2008
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:         Description:
**    --------    --------        -------------------------------------------
**    4/12/2016   AK              Remove references to functional tables
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_count INT,
          @v_usageclass_qsicode INT,
          @v_itemtype INT,
          @v_usageclass INT,
          @v_contentunit_datacode int,
          @v_issue_datacode int,
          @v_volume_datacode int,
          @v_journal_datacode int

          
  SET @o_num_children = 0        
  SET @o_error_code = 1
  SET @o_error_desc = ''
          
  IF (@i_projectkey is null OR @i_projectkey = 0) BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'ProjectKey is empty'
    RETURN  
  END
  
   -- coreprojectinfo with project key and get itemtype/searchitem and usage class  
	SELECT @v_itemtype = COALESCE(searchitemcode,0),
	       @v_usageclass = COALESCE(usageclasscode,0)
	  FROM coreprojectinfo
	 WHERE projectkey = @i_projectkey

  IF @v_itemtype <> 6 BEGIN
    SET @o_error_desc = 'Not a Journal'
    RETURN  
  END

  SELECT @v_usageclass_qsicode = qsicode
    FROM subgentables
   WHERE tableid = 550 
     AND datacode = @v_itemtype
     AND datasubcode = @v_usageclass

  -- content unit - last in hierarchy - no children
  IF @v_usageclass_qsicode = 6  BEGIN 
    RETURN  
  END

  SELECT @v_contentunit_datacode = COALESCE(datacode,0)
    FROM gentables
   WHERE tableid = 582
     AND qsicode = 4 

  SELECT @v_issue_datacode = COALESCE(datacode,0)
    FROM gentables
   WHERE tableid = 582
     AND qsicode = 3

  SELECT @v_volume_datacode = COALESCE(datacode,0)
    FROM gentables
   WHERE tableid = 582
     AND qsicode = 2 

  SELECT @v_journal_datacode = COALESCE(datacode,0)
    FROM gentables
   WHERE tableid = 582
     AND qsicode = 1

  -- issues - can only be deleted if no content units 
  IF @v_usageclass_qsicode = 5 BEGIN 
    -- check for content units     
    SELECT @v_count = count(*) 
      FROM projectrelationshipview
     WHERE taqprojectkey = @i_projectkey
       AND relationshipcode = @v_contentunit_datacode

    IF @v_count > 0 BEGIN
      SET @o_num_children = @v_count        
      RETURN  
    END
  END

  -- volumes - can only be deleted if no issues or content units 
  IF @v_usageclass_qsicode = 8 BEGIN 
    -- check for content units 
    SELECT @v_count = count(*) 
      FROM projectrelationshipview
     WHERE taqprojectkey = @i_projectkey
       AND relationshipcode = @v_contentunit_datacode
    
    IF @v_count > 0 BEGIN
      SET @o_num_children = @v_count        
      RETURN  
    END

    -- check for issues
    SELECT @v_count = count(*) 
      FROM projectrelationshipview
     WHERE taqprojectkey = @i_projectkey
       AND relationshipcode = @v_issue_datacode
     
    IF @v_count > 0 BEGIN
      SET @o_num_children = @v_count        
      RETURN  
    END
  END

  -- journals - can only be deleted if no volumes, issues, or content units 
  IF @v_usageclass_qsicode = 4  BEGIN   
    -- check for content units
    SELECT @v_count = count(*) 
      FROM projectrelationshipview
     WHERE taqprojectkey = @i_projectkey
       AND relationshipcode = @v_contentunit_datacode
     
    IF @v_count > 0 BEGIN
      SET @o_num_children = @v_count        
      RETURN  
    END

    -- check for issues 
    SELECT @v_count = count(*) 
      FROM projectrelationshipview
     WHERE taqprojectkey = @i_projectkey
       AND relationshipcode = @v_issue_datacode
    
    IF @v_count > 0 BEGIN
      SET @o_num_children = @v_count        
      RETURN  
    END
    
    -- check for volumes
    SELECT @v_count = count(*) 
      FROM projectrelationshipview
     WHERE taqprojectkey = @i_projectkey
       AND relationshipcode = @v_volume_datacode
     
    IF @v_count > 0 BEGIN
      SET @o_num_children = @v_count        
      RETURN  
    END
  END  
GO
GRANT EXEC ON qproject_verify_delete_journal_item TO PUBLIC
GO


