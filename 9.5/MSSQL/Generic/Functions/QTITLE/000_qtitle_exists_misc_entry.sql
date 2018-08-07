if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_exists_misc_entry') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_exists_misc_entry
GO

CREATE FUNCTION dbo.qtitle_exists_misc_entry
(
  @i_bookkey as integer,
  @i_misckey as integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qtitle_exists_misc_entry
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
    
  SELECT TOP(1) @v_itemtypecode = itemtypecode, @v_usageclasscode = usageclasscode 
  FROM coretitleinfo 
  WHERE bookkey = @i_bookkey ORDER BY printingkey ASC
      
  SET @v_result = 0  
  -- First check if this misckey is valid
	 IF EXISTS (SELECT * FROM miscitemsection s, bookmiscitems i, bookmisc b
				  WHERE s.misckey = i.misckey AND 
					  i.misckey = b.misckey AND
					  b.bookkey = @i_bookkey AND
					  i.activeind = 1 AND
					  s.itemtypecode = @v_itemtypecode AND
					  s.usageclasscode IN(@v_usageclasscode, 0) AND b.bookkey = @i_bookkey AND b.misckey = @i_misckey) BEGIN
		SET @v_result = 1
	 END
  
  RETURN @v_result
  
END
GO

GRANT EXEC ON dbo.qtitle_exists_misc_entry TO public
GO
