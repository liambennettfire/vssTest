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
  @i_relatedkey        integer,
  @i_orgentrykey       integer,
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
**  03/05/2018   Colman      Case 50068 Added support for org filtering
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''

  DECLARE
    @v_error  INT,
    @v_orglevelkey INT,
    @v_orgentrykey INT,
    @v_parent_orgentrykey INT,
    @v_restrictedind  TINYINT,
    @v_usageclass_qsicode INT

  -- exec qutl_trace 'qproject_get_templates',
    -- '@i_itemtype', @i_itemtype, NULL,
    -- '@i_usageclass', @i_usageclass, NULL,
    -- '@i_relatedkey', @i_relatedkey, NULL,
    -- '@i_orgentrykey', @i_orgentrykey, NULL

  DECLARE @AllTemplates TABLE (
    projectkey INT, 
    projecttitle VARCHAR(MAX), 
    projectstatus INT, 
    projecttype INT,
    searchitemcode INT,
    usageclasscode INT,
    defaulttemplateind INT, 
    sortorder INT IDENTITY
  )
  DECLARE @FilteredTemplates TABLE (
    projectkey INT, 
    projecttitle VARCHAR(MAX), 
    projectstatus INT, 
    projecttype INT,
    searchitemcode INT,
    usageclasscode INT,
    defaulttemplateind INT, 
    sortorder INT IDENTITY
  )

  SELECT @v_usageclass_qsicode = ISNULL(qsicode,0)
   FROM subgentables
   WHERE tableid = 550
     AND datacode = @i_itemtype
     AND datasubcode = @i_usageclass

    IF @i_relatedkey > 0 
    BEGIN    
      IF @i_itemtype = 14 
      BEGIN 
        -- printing project - get all existing printings for the title
        INSERT INTO @AllTemplates (projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, defaulttemplateind)
        SELECT c.projectkey, c.projecttitle, c.projectstatus, c.projecttype, c.searchitemcode, c.usageclasscode, c.defaulttemplateind
        FROM taqprojectprinting_view t 
          LEFT JOIN coreprojectinfo c ON c.projectkey = t.taqprojectkey
        WHERE t.bookkey = @i_relatedkey
        ORDER BY ISNULL(t.printingnum,0) DESC, c.projecttitle ASC      
      END
      ELSE IF @v_usageclass_qsicode = 8 
      BEGIN
        -- volume
        INSERT INTO @AllTemplates (projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, defaulttemplateind)
        SELECT c.projectkey, c.projecttitle, c.projectstatus, c.projecttype, c.searchitemcode, c.usageclasscode, c.defaulttemplateind
        FROM coreprojectinfo c 
          LEFT OUTER JOIN projectrelationshipview v 
            ON c.projectkey = v.taqprojectkey
        WHERE c.searchitemcode = @i_itemtype 
          AND c.usageclasscode = @i_usageclass
          AND c.templateind = 1
          AND v.relatedprojectkey = @i_relatedkey
        ORDER BY c.projecttitle ASC         
      END
      ELSE IF @v_usageclass_qsicode = 5 
      BEGIN
        -- issue
        INSERT INTO @AllTemplates (projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, defaulttemplateind)
        SELECT c.projectkey, c.projecttitle, c.projectstatus, c.projecttype, c.searchitemcode, c.usageclasscode, c.defaulttemplateind
        FROM coreprojectinfo c 
          LEFT OUTER JOIN projectrelationshipview i 
            ON c.projectkey = i.taqprojectkey
        WHERE c.searchitemcode = @i_itemtype 
          AND c.usageclasscode = @i_usageclass
          AND c.templateind = 1
          AND i.relatedprojectkey = @i_relatedkey
        ORDER BY c.projecttitle ASC         
      END
      ELSE IF @v_usageclass_qsicode = 6 
      BEGIN
        -- content unit
        INSERT INTO @AllTemplates (projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, defaulttemplateind)
        SELECT c.projectkey, c.projecttitle, c.projectstatus, c.projecttype, c.searchitemcode, c.usageclasscode, c.defaulttemplateind
        FROM coreprojectinfo c 
          LEFT OUTER JOIN projectrelationshipview cu 
            ON c.projectkey = cu.taqprojectkey
        WHERE c.searchitemcode = @i_itemtype 
          AND c.usageclasscode = @i_usageclass
          AND c.templateind = 1
          AND cu.relatedprojectkey = @i_relatedkey
        ORDER BY c.projecttitle ASC         
      END
      ELSE 
      BEGIN
        -- return all templates for item type/usage class
        INSERT INTO @AllTemplates (projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, defaulttemplateind)
        SELECT c.projectkey, c.projecttitle, c.projectstatus, c.projecttype, c.searchitemcode, c.usageclasscode, c.defaulttemplateind
        FROM coreprojectinfo c
        WHERE c.searchitemcode = @i_itemtype 
          AND c.usageclasscode = @i_usageclass
          AND templateind = 1
        ORDER BY c.projecttitle ASC         
      END    
    END
    ELSE 
    BEGIN
      IF @v_usageclass_qsicode IN (29,44) 
      BEGIN  
        INSERT INTO @AllTemplates (projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, defaulttemplateind)
        SELECT c.projectkey, c.projecttitle, c.projectstatus, c.projecttype, c.searchitemcode, c.usageclasscode, c.defaulttemplateind
          FROM coreprojectinfo c
        WHERE c.searchitemcode = @i_itemtype 
          AND c.usageclasscode = @i_usageclass
        ORDER BY c.projecttitle ASC           
      END
      ELSE 
      BEGIN
        INSERT INTO @AllTemplates (projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, defaulttemplateind)
        SELECT c.projectkey, c.projecttitle, c.projectstatus, c.projecttype, c.searchitemcode, c.usageclasscode, c.defaulttemplateind
          FROM coreprojectinfo c
        WHERE c.searchitemcode = @i_itemtype 
          AND c.usageclasscode = @i_usageclass
          AND templateind = 1
        ORDER BY c.projecttitle ASC         
      END   
    END

  -- Do org filtering if requested
  IF @i_orgentrykey > 0 
  BEGIN
    SELECT @v_orglevelkey = orglevelkey, @v_restrictedind = ISNULL(restricttemplatesind,0)
      FROM orgentry
     WHERE orgentrykey = @i_orgentrykey

    SELECT @v_error = @@ERROR
    IF @v_error <> 0  BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not get orglevel from orgentry for orgentrykey ' + cast(@i_orgentrykey as varchar)
    END
    
    -- need to find templates for orgentrykey and templates at higher levels 
    IF @v_orglevelkey > 0 
    BEGIN
      -- find all the templates for the orgentrykey passed IN
      INSERT INTO @FilteredTemplates (projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, defaulttemplateind)
      SELECT DISTINCT t.projectkey, t.projecttitle, t.projectstatus, t.projecttype, t.searchitemcode, t.usageclasscode, t.defaulttemplateind
      FROM @AllTemplates t, taqprojectorgentry o
      WHERE t.projectkey = o.taqprojectkey
        AND o.orgentrykey = @i_orgentrykey
        
      SELECT @v_error = @@ERROR
      IF @v_error <> 0  BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not get project templates from taqproject table.'
        RETURN
      END
      
      IF @v_orglevelkey > 1 
      BEGIN
        -- work backwards from the orglevel for the passed IN orgentrykey 
        -- to find templates at higher levels for the parentorgentrykeys
        SET @v_orgentrykey = @i_orgentrykey
        SET @v_orglevelkey = @v_orglevelkey - 1
        
        WHILE @v_orglevelkey >= 1 AND @v_restrictedind = 0 
        BEGIN 
          SELECT 
            @v_parent_orgentrykey = orgentryparentkey, 
            @v_restrictedind = (
              SELECT ISNULL(o.restricttemplatesind,0) 
              FROM orgentry o 
              WHERE o.orgentrykey = orgentry.orgentryparentkey
          )
          FROM orgentry
          WHERE orgentrykey = @v_orgentrykey

          SELECT @v_error = @@ERROR
          IF @v_error <> 0  BEGIN
            SET @o_error_code = -1
            SET @o_error_desc = 'Could not get parent orgentrykey from orgentry for orgentrykey ' + CAST(@v_orgentrykey AS VARCHAR)
            RETURN
          END

          SET @v_orgentrykey = @v_parent_orgentrykey
                   
          IF @v_orgentrykey > 0 
          BEGIN
            -- find templates defined only up to the parent level 
            INSERT INTO @FilteredTemplates (projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, defaulttemplateind)
            SELECT DISTINCT t.projectkey, t.projecttitle, t.projectstatus, t.projecttype, t.searchitemcode, t.usageclasscode, t.defaulttemplateind
            FROM @AllTemplates t, taqprojectorgentry o
            WHERE t.projectkey = o.taqprojectkey
              AND o.orgentrykey = @v_orgentrykey
              AND t.projectkey IN (
                SELECT taqprojectkey 
                FROM taqprojectorgentry
                GROUP BY taqprojectkey
                HAVING COUNT(*) = @v_orglevelkey
              )

            SELECT @v_error = @@ERROR
            IF @v_error <> 0  BEGIN
              SET @o_error_code = -1
              SET @o_error_desc = 'Could not get project templates for orgentrykey ' + CAST(@v_orgentrykey AS VARCHAR)
              RETURN
            END          
          END

          SET @v_orglevelkey = @v_orglevelkey - 1
        END
      END
       
      SELECT projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, ISNULL(defaulttemplateind, 0) defaulttemplateind
      FROM @FilteredTemplates
      ORDER BY sortorder
    END
  END
  ELSE 
  BEGIN
    SELECT projectkey, projecttitle, projectstatus, projecttype, searchitemcode, usageclasscode, ISNULL(defaulttemplateind, 0) defaulttemplateind
    FROM @AllTemplates
    ORDER BY sortorder
  END  
GO

GRANT EXEC ON qproject_get_templates TO PUBLIC
GO
