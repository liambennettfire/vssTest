if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qspec_get_available_components') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qspec_get_available_components
GO

CREATE PROCEDURE qspec_get_available_components (  
  @i_projectkey   integer,
  @i_po_projectkey   integer,
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
**  04/13/17    Joshua    Pulled logic out of table variable, eliminated view from not exists replicating the logic
**  05/31/17    Colman    45291 - When a PO is voided cannot create new PO 
**  06/26/17    Colman    45995 - Need to be able to move components from the existing PO
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
  SELECT c.taqversionspecategorykey AS speccategorykey, c.taqprojectkey, c.taqversionformatkey, c.itemcategorycode AS speccategorycode, 
        c.speccategorydescription AS speccategorydescription, c.sortorder AS category_sort, g.sortorder AS gentable_sort
  FROM taqversionspeccategory c 
    JOIN gentables g ON g.tableid = 616 AND g.datacode = c.itemcategorycode
  WHERE c.taqprojectkey = @i_projectkey
    AND c.plstagecode = @v_plstagecode 
    AND c.taqversionkey = @v_selected_versionkey 
    AND (ISNULL(@i_vendorkey, 0) = 0 OR c.vendorcontactkey = @i_vendorkey)
    AND COALESCE(c.relatedspeccategorykey,0) = 0
  AND NOT EXISTS(SELECT 1 FROM taqversionspeccategory ch 
        WHERE c.taqversionspecategorykey = ch.relatedspeccategorykey
        AND NULLIF(ch.relatedspeccategorykey,0) != 0)      
  UNION
  SELECT c.taqversionspecategorykey AS speccategorykey, c.taqprojectkey, c.taqversionformatkey, c.itemcategorycode AS speccategorycode, 
        c.speccategorydescription AS speccategorydescription, c.sortorder AS category_sort, g.sortorder AS gentable_sort
  FROM taqversionspeccategory c 
    JOIN gentables g ON g.tableid = 616 AND g.datacode = c.itemcategorycode
    JOIN taqversionrelatedcomponents_view v ON v.relatedcategorykey = c.taqversionspecategorykey
      AND v.relatedprojectkey <> v.taqprojectkey 
      AND v.activeind = 0           
  WHERE c.taqprojectkey = @i_projectkey
    AND c.plstagecode = @v_plstagecode 
    AND c.taqversionkey = @v_selected_versionkey 
    AND (ISNULL(@i_vendorkey, 0) = 0 OR c.vendorcontactkey = @i_vendorkey)
  UNION
  -- Components on the PO that are related to a specific printing
  SELECT cpo.taqversionspecategorykey AS speccategorykey, cpo.taqprojectkey, cpo.taqversionformatkey, cpo.itemcategorycode AS speccategorycode, 
          cpo.speccategorydescription AS speccategorydescription, cpo.sortorder AS category_sort, g.sortorder AS gentable_sort
  FROM taqversionspeccategory cpo
    JOIN gentables g ON g.tableid = 616 AND g.datacode = cpo.itemcategorycode
    JOIN taqversionformatrelatedproject r ON r.taqprojectkey = @i_po_projectkey AND r.relatedprojectkey = @i_projectkey
    JOIN taqversionformat f ON f.taqprojectformatkey = r.taqversionformatkey
  WHERE ISNULL(@i_po_projectkey, 0) > 0
    AND cpo.taqversionformatkey = f.taqprojectformatkey
    AND ISNULL(cpo.relatedspeccategorykey, 0) = 0
    AND ISNULL(f.sharedposectionind, 0) = 0
    AND (ISNULL(@i_vendorkey, 0) = 0 OR cpo.vendorcontactkey = @i_vendorkey)
  UNION
  -- Components on a printing that are related to this PO (but not in a shared section)
  SELECT cpr.taqversionspecategorykey AS speccategorykey, cpr.taqprojectkey, cpr.taqversionformatkey, cpr.itemcategorycode AS speccategorycode, 
          cpr.speccategorydescription AS speccategorydescription, cpr.sortorder AS category_sort, g.sortorder AS gentable_sort
  FROM taqversionspeccategory cpr
    JOIN gentables g ON g.tableid = 616 AND g.datacode = cpr.itemcategorycode
    JOIN taqversionformatrelatedproject r ON r.taqprojectkey = @i_po_projectkey AND r.relatedprojectkey = @i_projectkey
    JOIN taqversionformat f ON f.taqprojectformatkey = r.taqversionformatkey
    JOIN taqversionspeccategory cpo ON cpo.relatedspeccategorykey = cpr.taqversionspecategorykey
  WHERE ISNULL(@i_po_projectkey, 0) > 0
    AND cpo.taqversionformatkey = f.taqprojectformatkey
    AND ISNULL(f.sharedposectionind, 0) = 0
    AND (ISNULL(@i_vendorkey, 0) = 0 OR cpr.vendorcontactkey = @i_vendorkey)
      
  ORDER BY category_sort, gentable_sort

  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqversionspeccategory tables (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qspec_get_available_components TO PUBLIC
GO
