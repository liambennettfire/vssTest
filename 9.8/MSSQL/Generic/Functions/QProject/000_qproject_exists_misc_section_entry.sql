if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_exists_misc_section_entry') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_exists_misc_section_entry
GO

CREATE FUNCTION dbo.qproject_exists_misc_section_entry
(
  @i_projectkey as integer,
  @i_misckey as integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qproject_exists_misc_section_entry
**  Desc: This function returns 1 if the miscellaneous default entry exists or 0 if it does not exist for a Title.
**
**  Auth: Uday A. Khisty
**  Date: April 23 2015
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_misctype INT,
    @v_result INT,
    @v_itemtypecode INT,
    @v_usageclasscode INT    
    
  SELECT @v_itemtypecode = searchitemcode, @v_usageclasscode = usageclasscode 
  FROM taqproject 
  WHERE taqprojectkey = @i_projectkey    
    
  SET @v_result = 0  
  -- First check if this misckey is valid

	 IF EXISTS (SELECT * 
				FROM bookmiscitems i,   
						  miscitemsection s 
				WHERE i.misckey = s.misckey AND
						  i.activeind =  1 AND s.itemtypecode = @v_itemtypecode AND s.usageclasscode IN(@v_usageclasscode, 0) AND i.misckey = @i_misckey) BEGIN
	
			SET @v_result = 1
	 END	  
  
  RETURN @v_result
  
END
GO

GRANT EXEC ON dbo.qproject_exists_misc_section_entry TO public
GO
