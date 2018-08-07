if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qspec_get_avail_components') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qspec_get_avail_components
GO

CREATE FUNCTION dbo.qspec_get_avail_components (  
  @i_projectkey   integer,
  @i_vendorkey    integer)
  
RETURNS @specitemlist TABLE(
  speccategorykey integer, 
  speccategorycode integer, 
  speccategorydescription varchar(255),
  category_sort integer,
  gentable_sort integer
)
AS

/**************************************************************************************************
**  Name: qspec_get_avail_components
**  Desc: This funtion returns a table of available components for the given project and vendor
**        i.e. components that are not associated with any other active (not Void) project.
**
**  Auth: Kate W.
**  Date: September 12 2014
*************************************************************************************************/

BEGIN

  DECLARE
    @v_plstagecode INT,
    @v_selected_versionkey INT
    
  -- Get the most recent stage for this project, and the selected version for that stage.
  -- NOTE: This function will be called after Stage and Version are created if they don't yet exist, so these should always return values.
  SELECT @v_plstagecode = dbo.qpl_get_most_recent_stage(@i_projectkey)
  SELECT @v_selected_versionkey =  dbo.qpl_get_selected_version(@i_projectkey)
     
  -- NOTE: The first part of the UNION returns components not associated with any projects (other than self),
  -- and the second part of the UNION returns components associated with VOID (inactive) projects
  IF @i_vendorkey > 0
    INSERT INTO @specitemlist (speccategorykey, speccategorycode, speccategorydescription, category_sort, gentable_sort)
    SELECT c.taqversionspecategorykey, c.itemcategorycode, c.speccategorydescription, c.sortorder, g.sortorder
    FROM taqversionspeccategory c 
      JOIN gentables g ON g.tableid = 616 AND g.datacode = c.itemcategorycode
    WHERE c.taqprojectkey = @i_projectkey
      AND c.plstagecode = @v_plstagecode 
      AND c.taqversionkey = @v_selected_versionkey 
      AND c.vendorcontactkey = @i_vendorkey  
      AND COALESCE(c.relatedspeccategorykey,0) = 0
      AND NOT EXISTS (SELECT * FROM taqversionrelatedcomponents_view v 
        WHERE v.relatedcategorykey = c.taqversionspecategorykey
          AND v.relatedprojectkey <> v.taqprojectkey)
    UNION
    SELECT c.taqversionspecategorykey, c.itemcategorycode, c.speccategorydescription, c.sortorder, g.sortorder
    FROM taqversionspeccategory c 
      JOIN gentables g ON g.tableid = 616 AND g.datacode = c.itemcategorycode
      JOIN taqversionrelatedcomponents_view v ON v.relatedcategorykey = c.taqversionspecategorykey
        AND v.relatedprojectkey <> v.taqprojectkey 
        AND v.activeind = 0    
    WHERE c.taqprojectkey = @i_projectkey
      AND c.plstagecode = @v_plstagecode 
      AND c.taqversionkey = @v_selected_versionkey 
      AND c.vendorcontactkey = @i_vendorkey 
      AND NOT EXISTS (SELECT * FROM taqversionrelatedcomponents_view v2 
        WHERE v2.relatedcategorykey = c.taqversionspecategorykey
          AND v2.relatedprojectkey <> v2.taqprojectkey AND v2.activeind = 1)
    ORDER BY c.sortorder, g.sortorder
  ELSE
    INSERT INTO @specitemlist (speccategorykey, speccategorycode, speccategorydescription, category_sort, gentable_sort)
    SELECT c.taqversionspecategorykey, c.itemcategorycode, c.speccategorydescription, c.sortorder, g.sortorder
    FROM taqversionspeccategory c 
      JOIN gentables g ON g.tableid = 616 AND g.datacode = c.itemcategorycode
    WHERE c.taqprojectkey = @i_projectkey
      AND c.plstagecode = @v_plstagecode 
      AND c.taqversionkey = @v_selected_versionkey 
      AND COALESCE(c.relatedspeccategorykey,0) = 0
      AND NOT EXISTS (SELECT * FROM taqversionrelatedcomponents_view v 
        WHERE v.relatedcategorykey = c.taqversionspecategorykey
          AND v.relatedprojectkey <> v.taqprojectkey)          
    UNION
    SELECT c.taqversionspecategorykey, c.itemcategorycode, c.speccategorydescription, c.sortorder, g.sortorder
    FROM taqversionspeccategory c 
      JOIN gentables g ON g.tableid = 616 AND g.datacode = c.itemcategorycode
      JOIN taqversionrelatedcomponents_view v ON v.relatedcategorykey = c.taqversionspecategorykey
        AND v.relatedprojectkey <> v.taqprojectkey 
        AND v.activeind = 0           
    WHERE c.taqprojectkey = @i_projectkey
      AND c.plstagecode = @v_plstagecode 
      AND c.taqversionkey = @v_selected_versionkey 
      AND NOT EXISTS (SELECT * FROM taqversionrelatedcomponents_view v2 
        WHERE v2.relatedcategorykey = c.taqversionspecategorykey
          AND v2.relatedprojectkey <> v2.taqprojectkey AND v2.activeind = 1)            
    ORDER BY c.sortorder, g.sortorder

  RETURN
  
END
GO
