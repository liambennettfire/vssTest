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
  @i_orglevel          integer,
  @i_orgentry          integer,
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
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**	06/24/2016   Colman      38505 - Add org filter
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT,
          @v_usageclass_qsicode INT,
          @v_journalkey INT,
          @v_journal_relationship_datacode INT

  IF @i_journalitemkey > 0 BEGIN
    SET @v_journalkey = 0
    
    SELECT @v_usageclass_qsicode = COALESCE(qsicode,0)
      FROM subgentables
     WHERE tableid = 550
       AND datacode = @i_itemtype
       AND datasubcode = @i_usageclass
    
    SELECT @v_journal_relationship_datacode = COALESCE(datacode,0)
      FROM gentables
     WHERE tableid = 582
       AND qsicode = 1

    SELECT @v_journalkey = COALESCE(relatedprojectkey,0) 
      FROM projectrelationshipview 
     WHERE taqprojectkey = @i_journalitemkey
       AND relationshipcode = @v_journal_relationship_datacode

    IF @v_usageclass_qsicode = 8 BEGIN
      -- volume
      --IF @v_journalkey > 0 BEGIN  
        SELECT TOP(1) c.*
          FROM coreprojectinfo c 
               LEFT OUTER JOIN projectrelationshipview v 
               ON c.projectkey = v.taqprojectkey
         WHERE c.searchitemcode = @i_itemtype 
           AND COALESCE(c.usageclasscode,0) in (0,@i_usageclass)
           AND c.templateind = 1
           AND c.defaulttemplateind = 1
           AND COALESCE(v.relatedprojectkey,0) in (0,@v_journalkey)
           AND dbo.qproject_is_orgfiltered(c.projectkey, @i_orglevel, @i_orgentry) > 0
        ORDER BY dbo.qproject_is_orgfiltered(c.projectkey, @i_orglevel, @i_orgentry) DESC
      --END
    END
    ELSE IF @v_usageclass_qsicode = 5 BEGIN
      -- issue
      --IF @v_journalkey > 0 BEGIN  
        SELECT TOP(1) c.*
          FROM coreprojectinfo c 
          LEFT OUTER JOIN projectrelationshipview i 
          ON c.projectkey = i.taqprojectkey
         WHERE c.searchitemcode = @i_itemtype 
          AND COALESCE(c.usageclasscode,0) in (0,@i_usageclass)
          AND c.templateind = 1
          AND c.defaulttemplateind = 1
          AND COALESCE(i.relatedprojectkey,0) in (0,@v_journalkey)
          AND dbo.qproject_is_orgfiltered(c.projectkey, @i_orglevel, @i_orgentry) > 0
        ORDER BY dbo.qproject_is_orgfiltered(c.projectkey, @i_orglevel, @i_orgentry) DESC
      --END
    END
    ELSE IF @v_usageclass_qsicode = 6 BEGIN
      -- content unit
      --IF @v_journalkey > 0 BEGIN  
        SELECT TOP(1) c.*
          FROM coreprojectinfo c 
          LEFT OUTER JOIN projectrelationshipview cu 
          ON c.projectkey = cu.taqprojectkey
        WHERE c.searchitemcode = @i_itemtype 
          AND COALESCE(c.usageclasscode,0) in (0,@i_usageclass)
          AND c.templateind = 1
          AND c.defaulttemplateind = 1
          AND COALESCE(cu.relatedprojectkey,0) in (0,@v_journalkey)
          AND dbo.qproject_is_orgfiltered(c.projectkey, @i_orglevel, @i_orgentry) > 0
        ORDER BY dbo.qproject_is_orgfiltered(c.projectkey, @i_orglevel, @i_orgentry) DESC
      ----END
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
    SELECT TOP(1) c.*
      FROM coreprojectinfo c
    WHERE c.searchitemcode = @i_itemtype 
      AND c.usageclasscode = @i_usageclass
      AND c.defaulttemplateind = 1
      AND c.templateind = 1
      AND dbo.qproject_is_orgfiltered(c.projectkey, @i_orglevel, @i_orgentry) > 0
    ORDER BY dbo.qproject_is_orgfiltered(c.projectkey, @i_orglevel, @i_orgentry) DESC
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


