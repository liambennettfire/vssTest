if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_most_recent_stage') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_get_most_recent_stage
GO

CREATE FUNCTION qpl_get_most_recent_stage (
  @i_taqprojectkey as integer
  ) 
RETURNS int

/**************************************************************************************************************************************************
**  Name: qpl_get_most_recent_stage
**  Desc: This function returns the most recent stage based on the maximum Sortorder of the PL Stage for that Project, 0 if they don't exist,
**        and -1 for an error. 
**
**  Auth: Uday A. Khisty
**  Date: July 11 2014
**************************************************************************************************************************************************/

BEGIN 
  DECLARE
    @error_var    INT,
    @v_plstagecode INT,  
    @v_itemtypecode INT,
    @v_usageclasscode INT,
    @v_active_filtered_count INT

  SELECT @v_itemtypecode = searchitemcode, @v_usageclasscode = usageclasscode 
  FROM coreprojectinfo 
  WHERE projectkey = @i_taqprojectkey
  
  SELECT @v_active_filtered_count = COUNT(*) 
  FROM gentablesitemtype gi, gentables g 
   WHERE gi.tableid = g.tableid AND
          gi.datacode = g.datacode AND
		  g.deletestatus = 'N' AND
          gi.tableid = 562 AND
          gi.itemtypecode = @v_itemtypecode AND
          (gi.itemtypesubcode = @v_usageclasscode OR gi.itemtypesubcode = 0)   
            
IF @v_active_filtered_count > 0 BEGIN                    
  SELECT TOP(1) @v_plstagecode = gi.datacode
	  FROM gentablesitemtype gi, gentables g, taqplstage p 
		  WHERE gi.tableid = g.tableid AND
			  gi.datacode = g.datacode AND
			  p.plstagecode = g.datacode AND
			  p.selectedversionkey > 0 AND
			  p.taqprojectkey = @i_taqprojectkey AND          
			  g.deletestatus = 'N' AND
			  gi.tableid = 562 AND
			  gi.itemtypecode = @v_itemtypecode AND
			  (gi.itemtypesubcode = @v_usageclasscode OR gi.itemtypesubcode = 0)   
	  ORDER BY gi.sortorder DESC, g.sortorder DESC 
  END
  ELSE BEGIN
  SELECT TOP(1) @v_plstagecode = g.datacode
	  FROM gentables g, taqplstage p 
		  WHERE p.plstagecode = g.datacode AND
			  p.selectedversionkey > 0 AND
			  p.taqprojectkey = @i_taqprojectkey AND          
			  g.deletestatus = 'N' AND
			  g.tableid = 562
	  ORDER BY g.sortorder DESC   
  END        
   
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 
    SET @v_plstagecode = -1

  IF @v_plstagecode IS NULL BEGIN
	return -1
  END
  
  RETURN @v_plstagecode
  
END
GO

GRANT EXEC ON dbo.qpl_get_most_recent_stage TO PUBLIC
GO
