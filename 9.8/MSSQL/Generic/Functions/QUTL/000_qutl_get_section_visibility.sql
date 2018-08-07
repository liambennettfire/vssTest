if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_section_visibility') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qutl_get_section_visibility
GO

CREATE FUNCTION dbo.qutl_get_section_visibility
(
  @i_configobjectkey as integer,
  @i_qsiwindowviewkey as integer,
  @i_configobjecttype as integer,
  @i_groupkey as integer,
  @i_itemtypecode as integer,
  @i_usageclasscode as integer
) 
RETURNS integer

/*******************************************************************************************************
**  Name: qutl_get_section_visibility
**  Desc: This function returns whether or not a section should be visible based on its
**        configobjecttype and groupkey.
**
**  Auth: Alan Katzen
**  Date: May 11, 2010
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_total_count  INT,
    @v_num_sections  INT,
    @v_position INT,
    @v_group_position INT,
    @v_visibleind  INT,
    @v_default_windowviewkey INT,
    @v_windowid INT
    
  SELECT @v_default_windowviewkey = qsiwindowviewkey
    FROM qsiwindowview wv
   WHERE wv.defaultind = 1
     AND wv.itemtypecode = @i_itemtypecode
     AND COALESCE(wv.usageclasscode,0) = COALESCE(@i_usageclasscode,0)

  SELECT @v_windowid = co.windowid
    FROM qsiconfigdetail cd, qsiconfigobjects co
   WHERE cd.configobjectkey = co.configobjectkey
     AND cd.qsiwindowviewkey = @i_qsiwindowviewkey
    
  IF @i_configobjecttype = 3 BEGIN
    -- this is an individual section that is not part of a group section
    IF @i_configobjectkey = @i_groupkey BEGIN
      -- visible 
      RETURN 1
    END
    
    -- check if this section is set as not visible
    SELECT @v_visibleind = COALESCE(cd.visibleind,co.defaultvisibleind,1)
      FROM qsiconfigdetail cd, qsiconfigobjects co
     WHERE cd.configobjectkey = co.configobjectkey
       AND cd.qsiwindowviewkey = @i_qsiwindowviewkey
       AND co.configobjectkey = @i_configobjectkey

    IF @v_visibleind is null BEGIN
      SELECT @v_visibleind = COALESCE(cd.visibleind,co.defaultvisibleind,1)
        FROM qsiconfigdetail cd, qsiconfigobjects co
       WHERE cd.configobjectkey = co.configobjectkey
         AND cd.qsiwindowviewkey = @v_default_windowviewkey
         AND co.configobjectkey = @i_configobjectkey
    END
    
    IF @v_visibleind is null BEGIN
      SELECT @v_visibleind = COALESCE(co.defaultvisibleind,1)
        FROM qsiconfigobjects co
       WHERE co.configobjectkey = @i_configobjectkey
    END 
    
    IF @v_visibleind = 0 BEGIN
      RETURN 0
    END
    
    -- get position of group section
    SELECT @v_group_position = COALESCE(cd.position,co.position,0)
      FROM qsiconfigdetail cd, qsiconfigobjects co 
     WHERE cd.configobjectkey = co.configobjectkey
       AND cd.qsiwindowviewkey = @i_qsiwindowviewkey
       AND co.configobjectkey = @i_groupkey
       AND co.configobjecttype = 4
       
    IF @v_group_position is null OR @v_group_position <=0 BEGIN
      SELECT @v_group_position = COALESCE(cd.position,co.position,0)
        FROM qsiconfigdetail cd, qsiconfigobjects co 
       WHERE cd.configobjectkey = co.configobjectkey
         AND cd.qsiwindowviewkey = @v_default_windowviewkey
         AND co.configobjectkey = @i_groupkey
         AND co.configobjecttype = 4
    END
    
    IF @v_group_position is null OR @v_group_position <=0 BEGIN
      SELECT @v_group_position = COALESCE(co.position,0)
        FROM qsiconfigobjects co 
       WHERE co.configobjectkey = @i_groupkey
         AND co.configobjecttype = 4
    END

    -- if all sections within the group section have the same position,
    -- then this section will not be visible 
    SELECT @v_num_sections = count(*)
      FROM qsiconfigobjects co 
     WHERE co.groupkey = @i_groupkey
       AND co.configobjecttype = 3
       
    IF @v_num_sections > 0 BEGIN
      SET @v_total_count = 0
    
      SELECT @v_count = count(*)
        FROM qsiconfigdetail cd, qsiconfigobjects co
       WHERE cd.configobjectkey = co.configobjectkey
         AND co.groupkey = @i_groupkey
         AND co.configobjecttype = 3
         AND cd.qsiwindowviewkey = @i_qsiwindowviewkey
         AND COALESCE(cd.position,co.position,0) = @v_group_position

      IF @v_count > 0 BEGIN
        SET @v_total_count = @v_total_count + @v_count
      END
      
      SELECT @v_count = count(*)
        FROM qutl_get_default_windowviews(@v_windowid) 
       WHERE configobjecttype = 3
         AND itemtypecode = @i_itemtypecode
         AND COALESCE(usageclasscode,0) = COALESCE(@i_usageclasscode,0)
         AND groupkey = @i_groupkey     
         AND position = @v_group_position
         AND configobjectkey not in (SELECT cd2.configobjectkey FROM qsiconfigdetail cd2 WHERE cd2.qsiwindowviewkey = @i_qsiwindowviewkey)  

      IF @v_count > 0 BEGIN
        SET @v_total_count = @v_total_count + @v_count
      END
               
      IF @v_total_count = @v_num_sections BEGIN
        RETURN 0
      END
      ELSE BEGIN
        RETURN 1
      END
    END
      
    RETURN 1   
  END
  ELSE IF @i_configobjecttype = 4 BEGIN
    -- must be at least 1 subsection visible for a group section to be visible
    SELECT @v_count = count(*)
     FROM qsiconfigdetail cd, qsiconfigobjects co
    WHERE cd.configobjectkey = co.configobjectkey
      AND co.groupkey = @i_groupkey
      AND co.configobjecttype = 3
      AND cd.qsiwindowviewkey = @i_qsiwindowviewkey
      AND COALESCE(cd.visibleind,co.defaultvisibleind,1) = 1

    IF @v_count is null OR @v_count = 0 BEGIN
      SELECT @v_count = count(*)       
        FROM qutl_get_default_windowviews(@v_windowid) 
       WHERE configobjecttype = 3
         AND itemtypecode = @i_itemtypecode
         AND COALESCE(usageclasscode,0) = COALESCE(@i_usageclasscode,0)
         AND groupkey = @i_groupkey     
         AND visibleind = 1
         AND configobjectkey not in (SELECT cd2.configobjectkey FROM qsiconfigdetail cd2 WHERE cd2.qsiwindowviewkey = @i_qsiwindowviewkey)  
    END 
          
    IF @v_count = 0 BEGIN
      -- all sections within the group are not visible so make the group section not visible
      RETURN 0
    END
       
    -- get position of group section
    SELECT @v_group_position = COALESCE(cd.position,co.position,0)
      FROM qsiconfigdetail cd, qsiconfigobjects co 
     WHERE cd.configobjectkey = co.configobjectkey
       AND cd.qsiwindowviewkey = @i_qsiwindowviewkey
       AND co.configobjectkey = @i_groupkey
    
    IF @v_group_position is null OR @v_group_position <=0 BEGIN
      SELECT @v_group_position = COALESCE(cd.position,co.position,0)      
        FROM qsiconfigdetail cd, qsiconfigobjects co 
       WHERE cd.configobjectkey = co.configobjectkey
         AND cd.qsiwindowviewkey = @v_default_windowviewkey
         AND co.configobjectkey = @i_groupkey
    END
    
    IF @v_group_position is null OR @v_group_position <=0 BEGIN
      SELECT @v_group_position = COALESCE(co.position,0)
        FROM qsiconfigobjects co 
       WHERE co.configobjectkey = @i_groupkey
    END 

    -- if all sections within the group section have the same position,
    -- then the group section will be visible 
    SELECT @v_num_sections = count(*)
      FROM qsiconfigobjects co 
     WHERE co.groupkey = @i_groupkey
       AND co.configobjecttype = 3
       
    IF @v_num_sections > 0 BEGIN
      SET @v_total_count = 0
    
      SELECT @v_count = count(*)
        FROM qsiconfigdetail cd, qsiconfigobjects co
       WHERE cd.configobjectkey = co.configobjectkey
         AND co.groupkey = @i_groupkey
         AND co.configobjecttype = 3
         AND cd.qsiwindowviewkey = @i_qsiwindowviewkey
         AND COALESCE(cd.position,co.position,0) = @v_group_position

      IF @v_count > 0 BEGIN
        SET @v_total_count = @v_total_count + @v_count
      END
      
      SELECT @v_count = count(*)
        FROM qutl_get_default_windowviews(@v_windowid) 
       WHERE configobjecttype = 3
         AND itemtypecode = @i_itemtypecode
         AND COALESCE(usageclasscode,0) = COALESCE(@i_usageclasscode,0)
         AND groupkey = @i_groupkey     
         AND position = @v_group_position
         AND configobjectkey not in (SELECT cd2.configobjectkey FROM qsiconfigdetail cd2 WHERE cd2.qsiwindowviewkey = @i_qsiwindowviewkey)  

      IF @v_count > 0 BEGIN
        SET @v_total_count = @v_total_count + @v_count
      END
               
      IF @v_total_count = @v_num_sections BEGIN
        RETURN 1
      END
      ELSE BEGIN
        RETURN 0
      END
    END
    
    RETURN 1
  END
  
  RETURN 1
END
GO

GRANT EXEC ON dbo.qutl_get_section_visibility TO public
GO
