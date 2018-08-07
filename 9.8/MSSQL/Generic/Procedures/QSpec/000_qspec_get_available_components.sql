if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qspec_get_available_components') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qspec_get_available_components
GO

CREATE PROCEDURE qspec_get_available_components (  
  @i_projectkey   integer,
  @i_vendorkey    integer,
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qspec_get_available_components
**  Desc: This stored procedure returns available components for the given project and vendor.
**
**  Auth: Uday A. Khisty
**  Date: September 9 2014
****************************************************************************************************************************
**  Change History
****************************************************************************************************************************
**  Date:       Author:   Description:
**  --------    -------   --------------------------------------
**	04/13/17    Joshua    Pulled logic out of table variable, eliminated view from not exists replicating the logic
**  05/31/17    Colman    45291 - When a PO is voided cannot create new PO 
***********************************************************************************************/

BEGIN

  DECLARE
    @v_error  INT,
    @v_plstagecode INT,
    @v_selected_versionkey INT
    
  -- Get the most recent stage for this project, and the selected version for that stage.
  -- NOTE: This function will be called after Stage and Version are created if they don't yet exist, so these should always return values.
  SELECT @v_plstagecode = dbo.qpl_get_most_recent_stage(@i_projectkey)
  SELECT @v_selected_versionkey =  dbo.qpl_get_selected_version(@i_projectkey)
     
  -- NOTE: The first part of the UNION returns components not associated with any projects (other than self),
  -- and the second part of the UNION returns components associated with VOID (inactive) projects
  IF @i_vendorkey > 0
	SELECT c.taqversionspecategorykey AS speccategorykey, c.itemcategorycode AS speccategorycode, 
		   c.speccategorydescription AS speccategorydescription, c.sortorder AS category_sort, g.sortorder AS gentable_sort
    FROM taqversionspeccategory c 
      JOIN gentables g ON g.tableid = 616 AND g.datacode = c.itemcategorycode
    WHERE c.taqprojectkey = @i_projectkey
      AND c.plstagecode = @v_plstagecode 
      AND c.taqversionkey = @v_selected_versionkey 
      AND c.vendorcontactkey = @i_vendorkey  
      AND COALESCE(c.relatedspeccategorykey,0) = 0
	  AND NOT EXISTS(SELECT 1 FROM taqversionspeccategory ch 
					WHERE c.taqversionspecategorykey = ch.relatedspeccategorykey
					AND NULLIF(ch.relatedspeccategorykey,0) != 0)
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
		  
    ORDER BY c.sortorder, g.sortorder
  ELSE
   SELECT c.taqversionspecategorykey AS speccategorykey, c.itemcategorycode AS speccategorycode, 
		   c.speccategorydescription AS speccategorydescription, c.sortorder AS category_sort, g.sortorder AS gentable_sort
    FROM taqversionspeccategory c 
      JOIN gentables g ON g.tableid = 616 AND g.datacode = c.itemcategorycode
    WHERE c.taqprojectkey = @i_projectkey
      AND c.plstagecode = @v_plstagecode 
      AND c.taqversionkey = @v_selected_versionkey 
      AND COALESCE(c.relatedspeccategorykey,0) = 0
	  AND NOT EXISTS(SELECT 1 FROM taqversionspeccategory ch 
					WHERE c.taqversionspecategorykey = ch.relatedspeccategorykey
					AND NULLIF(ch.relatedspeccategorykey,0) != 0)      
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
    ORDER BY c.sortorder, g.sortorder

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionspeccategory tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qspec_get_available_components TO PUBLIC
GO
