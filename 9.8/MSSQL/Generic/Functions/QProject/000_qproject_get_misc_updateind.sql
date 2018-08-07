if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_misc_updateind') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_misc_updateind
GO

CREATE FUNCTION dbo.qproject_get_misc_updateind
(
  @i_projectkey as integer,
  @i_misckey as integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qproject_get_misc_updateind
**  Desc: This function returns 0 if the miscellaneous value is read only or 1 if it is editable for a Title.
**
**  Auth: Uday A. Khisty
**  Date: April 22 2015
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_itemtypecode INT,
    @v_usageclasscode INT,
    @v_misctype INT,
    @v_result INT,
    @v_datacode INT
    
  SET @v_result = 1  
  
  IF COALESCE(@i_projectkey, 0) = 0 BEGIN
	RETURN 0 
  END  
  
  SELECT @v_itemtypecode = searchitemcode, @v_usageclasscode = usageclasscode 
  FROM taqproject 
  WHERE taqprojectkey = @i_projectkey
  
  IF EXISTS (SELECT * FROM miscitemsection 
			 WHERE misckey = @i_misckey 
			  AND itemtypecode = @v_itemtypecode 
			  AND usageclasscode IN (@v_usageclasscode , 0)
			  AND updateind = 0) BEGIN
			  
	SET @v_result = 0		  
  END
    
  RETURN @v_result
  
END
GO

GRANT EXEC ON dbo.qproject_get_misc_updateind TO public
GO
