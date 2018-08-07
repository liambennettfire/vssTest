if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_exists_misc_default_entry') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_exists_misc_default_entry
GO

CREATE FUNCTION dbo.qtitle_exists_misc_default_entry
(
  @i_bookkey as integer,
  @i_misckey as integer
) 
RETURNS INT

/*******************************************************************************************************
**  Name: qtitle_exists_misc_default_entry
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
	 IF EXISTS (SELECT * FROM bookmiscitems i join miscitemsection s  on 
						i.misckey = s.misckey    
						left outer JOIN bookmiscdefaults d on 
						d.misckey = i.misckey AND
						d.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)			
				WHERE   i.activeind = 1 AND
					    s.itemtypecode = @v_itemtypecode AND
				        s.usageclasscode IN (@v_usageclasscode, 0) AND 
				        s.misckey = @i_misckey AND 
				        orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)) BEGIN
				        
		SET @v_result = 1
	  END
	  --ELSE IF EXISTS (SELECT * 
			--		 FROM bookmiscitems i,   
			--			  miscitemsection s 
			--		 WHERE i.misckey = s.misckey AND
			--			  i.activeind =  1 AND s.itemtypecode = @v_itemtypecode AND s.usageclasscode IN(@v_usageclasscode, 0) AND i.misckey = @i_misckey) BEGIN
	
			--SET @v_result = 1
	  --END		  
  
  RETURN @v_result
  
END
GO

GRANT EXEC ON dbo.qtitle_exists_misc_default_entry TO public
GO
