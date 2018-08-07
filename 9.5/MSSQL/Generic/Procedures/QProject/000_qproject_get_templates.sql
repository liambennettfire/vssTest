if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_templates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_templates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_templates
 (@i_itemtype          integer,
  @i_usageclass        integer,
  @i_relatedkey integer,
  @o_error_code        integer       output,
  @o_error_desc        varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_templates
**  Desc: This gets all Project/Journal Templates for a itemtype/usageclass.
**
**    Auth: Alan Katzen
**    Date: 2 July 2008
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  05/06/2016   UK          Case 37900
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT,
          @v_usageclass_qsicode INT

  SELECT @v_usageclass_qsicode = COALESCE(qsicode,0)
	 FROM subgentables
	 WHERE tableid = 550
	   AND datacode = @i_itemtype
	   AND datasubcode = @i_usageclass

  IF @i_relatedkey > 0 BEGIN    
    IF @i_itemtype = 14 BEGIN 
      -- printing project - get all existing printings for the title
      SELECT cp.*
        FROM taqprojectprinting_view t 
        LEFT JOIN coreprojectinfo cp ON cp.projectkey = t.taqprojectkey
       WHERE t.bookkey = @i_relatedkey
      ORDER BY COALESCE(t.printingnum,0) DESC, cp.projecttitle ASC      
    END
    ELSE IF @v_usageclass_qsicode = 8 BEGIN
      -- volume
      SELECT c.* 
        FROM coreprojectinfo c 
             LEFT OUTER JOIN projectrelationshipview v 
             ON c.projectkey = v.taqprojectkey
       WHERE c.searchitemcode = @i_itemtype 
         AND COALESCE(c.usageclasscode,0) in (0,@i_usageclass)
         AND c.templateind = 1
         AND COALESCE(v.relatedprojectkey,0) in (0,@i_relatedkey)
       ORDER BY c.projecttitle ASC         
    END
    ELSE IF @v_usageclass_qsicode = 5 BEGIN
      -- issue
      SELECT c.*
        FROM coreprojectinfo c 
             LEFT OUTER JOIN projectrelationshipview i 
             ON c.projectkey = i.taqprojectkey
       WHERE c.searchitemcode = @i_itemtype 
         AND COALESCE(c.usageclasscode,0) in (0,@i_usageclass)
         AND c.templateind = 1
         AND COALESCE(i.relatedprojectkey,0) in (0,@i_relatedkey)
       ORDER BY c.projecttitle ASC         
    END
    ELSE IF @v_usageclass_qsicode = 6 BEGIN
      -- content unit
      SELECT c.*
        FROM coreprojectinfo c 
             LEFT OUTER JOIN projectrelationshipview cu 
             ON c.projectkey = cu.taqprojectkey
       WHERE c.searchitemcode = @i_itemtype 
         AND COALESCE(c.usageclasscode,0) in (0,@i_usageclass)
         AND c.templateind = 1
         AND COALESCE(cu.relatedprojectkey,0) in (0,@i_relatedkey)
       ORDER BY c.projecttitle ASC         
    END
    ELSE BEGIN
      -- return all templates for item type/usage class
      SELECT c.*
        FROM coreprojectinfo c
       WHERE c.searchitemcode = @i_itemtype 
         AND COALESCE(c.usageclasscode,0) in (0,@i_usageclass)
         AND templateind = 1
       ORDER BY c.projecttitle ASC         
    END    
  END
  ELSE BEGIN
    IF @v_usageclass_qsicode IN (29,44) BEGIN  
		  SELECT c.*
		    FROM coreprojectinfo c
		   WHERE c.searchitemcode = @i_itemtype 
		     AND COALESCE(c.usageclasscode,0) in (0,@i_usageclass)
          ORDER BY c.projecttitle ASC		       
    END
    ELSE BEGIN
		  SELECT c.*
		    FROM coreprojectinfo c
		   WHERE c.searchitemcode = @i_itemtype 
		     AND COALESCE(c.usageclasscode,0) in (0,@i_usageclass)
		     AND templateind = 1
          ORDER BY c.projecttitle ASC		     
    END   
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: @i_itemtype = ' + cast(@i_itemtype AS VARCHAR) + ' / usageclass = ' + cast(@i_usageclass AS VARCHAR)
  END 

GO
GRANT EXEC ON qproject_get_templates TO PUBLIC
GO


