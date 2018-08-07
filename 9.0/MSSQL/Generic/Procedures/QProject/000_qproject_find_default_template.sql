if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_find_default_template') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_find_default_template
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_find_default_template
 (@i_itemtype          integer,
  @i_usageclass        integer,
  @i_journalitemkey    integer,
  @o_error_code        integer       output,
  @o_error_desc        varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_find_default_template
**  Desc: This finds the default Template for a itemtype/usageclass.
** 
**  NOTE: @i_journalitemkey is the projectkey of the volume, issue, or 
**        content unit that the user wants to make the default template.
**        It needs to correspond to the item type and usage class.  
**        Pass 0 if not used.
**
**    Auth: Alan Katzen
**    Date: 13 August 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT,
          @v_usageclass_qsicode INT,
          @v_journalkey INT

  IF @i_journalitemkey > 0 BEGIN
    SET @v_journalkey = 0
    
    SELECT @v_usageclass_qsicode = COALESCE(qsicode,0)
      FROM subgentables
     WHERE tableid = 550
       AND datacode = @i_itemtype
       AND datasubcode = @i_usageclass
    
    IF @v_usageclass_qsicode = 8 BEGIN
      -- volume
      SELECT @v_journalkey = COALESCE(v.journalkey,0)
        FROM dbo.qproject_get_volume() v
       WHERE v.volumekey = @i_journalitemkey
       
      --IF @v_journalkey > 0 BEGIN  
        SELECT c.*
          FROM coreprojectinfo c, dbo.qproject_get_volume() v
         WHERE c.projectkey = v.volumekey
           AND c.searchitemcode = @i_itemtype 
           AND c.usageclasscode = @i_usageclass
           AND c.templateind = 1
           AND c.defaulttemplateind = 1
           AND v.journalkey = @v_journalkey
      --END
    END
    ELSE IF @v_usageclass_qsicode = 5 BEGIN
      -- issue
      SELECT @v_journalkey = COALESCE(i.journalkey,0)
        FROM dbo.qproject_get_issue() i
       WHERE i.issuekey = @i_journalitemkey

      --IF @v_journalkey > 0 BEGIN  
        SELECT c.*
          FROM coreprojectinfo c, dbo.qproject_get_issue() i
         WHERE c.projectkey = i.issuekey
           AND c.searchitemcode = @i_itemtype 
           AND c.usageclasscode = @i_usageclass
           AND c.templateind = 1
           AND c.defaulttemplateind = 1
           AND i.journalkey = @v_journalkey
      --END
    END
    ELSE IF @v_usageclass_qsicode = 6 BEGIN
      -- content unit
      SELECT @v_journalkey = COALESCE(cu.journalkey,0)
        FROM dbo.qproject_get_contentunit() cu
       WHERE cu.contentunitkey = @i_journalitemkey

      --IF @v_journalkey > 0 BEGIN  
        SELECT c.*
          FROM coreprojectinfo c, dbo.qproject_get_contentunit() cu
         WHERE c.projectkey = cu.contentunitkey
           AND c.searchitemcode = @i_itemtype 
           AND c.usageclasscode = @i_usageclass
           AND c.templateind = 1
           AND c.defaulttemplateind = 1
           AND cu.contentunitkey = @v_journalkey
      --END
    END
    ELSE BEGIN    
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to Find Default Template: itemtype = ' + cast(@i_itemtype AS VARCHAR) + 
                          ' / usageclass = ' + cast(@i_usageclass AS VARCHAR) +
                          ' / projectkey = ' + cast(@i_journalitemkey AS VARCHAR)
      return
    END    
  END
  ELSE BEGIN
    SELECT c.*
      FROM coreprojectinfo c
     WHERE c.searchitemcode = @i_itemtype 
       AND c.usageclasscode = @i_usageclass
       AND c.defaulttemplateind = 1
       AND c.templateind = 1
  END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: @i_itemtype = ' + cast(@i_itemtype AS VARCHAR) + ' / usageclass = ' + cast(@i_usageclass AS VARCHAR)
  END 

GO
GRANT EXEC ON qproject_find_default_template TO PUBLIC
GO


