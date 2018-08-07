if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_selected_version') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qpl_get_selected_version
GO

CREATE FUNCTION qpl_get_selected_version (
  @i_taqprojectkey as integer
  ) 
RETURNS int

/**************************************************************************************************************************************************
**  Name: qpl_get_selected_version
**  Desc: This function returns the selected version based on the maximum Sortorder of the PL Stage for that Project, 0 if they don't exist,
**        and -1 for an error. 
**
**  Auth: Uday A. Khisty
**  Date: July 11 2014
**************************************************************************************************************************************************/

BEGIN 
  DECLARE
    @v_selectedversionkey INT,
    @error_var    INT,
    @v_plstagecode INT
  
    SET @v_plstagecode = dbo.qpl_get_most_recent_stage(@i_taqprojectkey) 
  
    IF @v_plstagecode IS NULL OR @v_plstagecode < 0 BEGIN
	  return -1
     END
  
    SELECT @v_selectedversionkey = selectedversionkey
    FROM taqplstage
    WHERE taqprojectkey = @i_taqprojectkey AND
      plstagecode = @v_plstagecode 

    SELECT @error_var = @@ERROR
    IF @error_var <> 0 
      SET @v_selectedversionkey = -1

    RETURN @v_selectedversionkey
  
END
GO

GRANT EXEC ON dbo.qpl_get_selected_version TO PUBLIC
GO
