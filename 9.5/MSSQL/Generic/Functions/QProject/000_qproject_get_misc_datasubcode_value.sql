if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_misc_datasubcode_value') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_misc_datasubcode_value
GO

CREATE FUNCTION dbo.qproject_get_misc_datasubcode_value
(
  @i_projectkey as integer,
  @i_misckey as integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qproject_get_misc_datasubcode_value
**  Desc: This function returns the miscellaneous checkbox value for specific Project as an integer.
**
**  Auth: Uday A. Khisty
**  Date: April 15 2015
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_datacode INT,
    @v_datasubcode INT,
    @v_misctype INT,    
    @v_return_datasubcode INT
    
  SET @v_datasubcode = 0
  SET @v_return_datasubcode = 0 
  -- First check if this misckey is valid
  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE misckey = @i_misckey and activeind = 1
  
  IF @v_count = 0
    RETURN 0   --this misckey doesn't exist - return NULL
       
  -- Get the Type and Gentable datacode value associated with this misckey
  SELECT @v_misctype = misctype, @v_datacode = COALESCE(datacode, 0)
  FROM bookmiscitems 
  WHERE misckey = @i_misckey and activeind = 1
  
  IF @v_misctype = 5 AND @v_datacode > 0 BEGIN--Gentable
  -- Get misc values for this misc item and title
     IF EXISTS (SELECT * FROM taqprojectmisc WHERE taqprojectkey = @i_projectkey AND misckey = @i_misckey) BEGIN
		 SELECT @v_datasubcode = COALESCE(longvalue, 0)
		 FROM taqprojectmisc
		 WHERE taqprojectkey = @i_projectkey AND misckey = @i_misckey	
		 
		 SET @v_return_datasubcode = @v_datasubcode
	 END
	 ELSE BEGIN 
		 IF EXISTS (SELECT * FROM bookmiscdefaults WHERE misckey = @i_misckey AND orgentrykey IN (SELECT orgentrykey FROM taqprojectorgentry WHERE taqprojectkey = @i_projectkey)) BEGIN
			 SELECT TOP(1) @v_datasubcode = COALESCE(d.longvalue, 0)
			 FROM bookmiscdefaults d JOIN taqprojectorgentry t ON d.orgentrykey = t.orgentrykey AND d.misckey = @i_misckey 
			 WHERE d.orgentrykey IN (SELECT orgentrykey FROM taqprojectorgentry WHERE taqprojectkey = @i_projectkey)
			 ORDER BY d.orglevel DESC
			 
			 SET @v_return_datasubcode = @v_datasubcode
		END	 
	 END
  END   
  
  RETURN @v_return_datasubcode
  
END
GO

GRANT EXEC ON dbo.qproject_get_misc_datasubcode_value TO public
GO
