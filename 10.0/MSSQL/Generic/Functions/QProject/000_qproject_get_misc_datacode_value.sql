if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_misc_datacode_value') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_misc_datacode_value
GO

CREATE FUNCTION dbo.qproject_get_misc_datacode_value
(
  @i_projectkey as integer,
  @i_misckey as integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qproject_get_misc_datacode_value
**  Desc: This function returns the miscellaneous gentables datacode value for specific Project as an integer.
**
**  Auth: Uday A. Khisty
**  Date: April 9 2015
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_misctype INT,
    @v_return_datacode INT,
    @v_datacode INT
    
  SET @v_return_datacode = 0  
  -- First check if this misckey is valid
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey and activeind = 1
  
  IF @v_count = 0
    RETURN 0   --this misckey doesn't exist - return NULL
  
  -- Get the Type, Field Format, and Gentable datacode value associated with this misckey
  SELECT @v_misctype = misctype, @v_datacode = COALESCE(datacode, 0)
  FROM bookmiscitems 
  WHERE misckey = @i_misckey  and activeind = 1
  
  IF @v_misctype = 5 --Gentable
	 SET @v_return_datacode = @v_datacode
	 
  IF EXISTS (SELECT * FROM taqprojectmisc WHERE taqprojectkey = @i_projectkey AND misckey = @i_misckey) BEGIN   	 
	 RETURN @v_return_datacode
  END
  ELSE BEGIN
	 IF EXISTS (SELECT * FROM bookmiscdefaults WHERE misckey = @i_misckey AND orgentrykey IN (SELECT orgentrykey FROM taqprojectorgentry WHERE taqprojectkey = @i_projectkey)) BEGIN
		  SELECT TOP(1) @v_datacode = COALESCE(d.datacode, 0)
		  FROM bookmiscdefaults d JOIN taqprojectorgentry t ON d.orgentrykey = t.orgentrykey AND d.misckey = @i_misckey 
		  WHERE d.orgentrykey IN (SELECT orgentrykey FROM taqprojectorgentry WHERE taqprojectkey = @i_projectkey)
		  ORDER BY d.orglevel DESC
		  
		  /* Format value based on its type */
		  IF @v_misctype = 5  -- datacode
			SET @v_return_datacode = @v_datacode
	 END		  
  END 
  
  RETURN @v_return_datacode
  
END
GO

GRANT EXEC ON dbo.qproject_get_misc_datacode_value TO public
GO
