if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_misc_sendtoeloquence_value') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_misc_sendtoeloquence_value
GO

CREATE FUNCTION dbo.qtitle_get_misc_sendtoeloquence_value
(
  @i_bookkey as integer,
  @i_misckey as integer
) 
RETURNS TINYINT

/*******************************************************************************************************
**  Name: qtitle_get_misc_sendtoeloquence_value
**  Desc: This function returns the sendtoeloquenceind value for specific title as an integer.
**
**  Auth: Uday A. Khisty
**  Date: April 10 2015
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,   
    @v_itemtypecode INT,
    @v_usageclasscode INT, 
    @v_@v_sendtoeloquenceind_return_value TINYINT,
    @v_sendtoeloquenceind TINYINT
    
  IF COALESCE(@i_bookkey, 0) = 0 BEGIN
	RETURN 0 
  END    
  
  SELECT TOP(1) @v_itemtypecode = itemtypecode, @v_usageclasscode = usageclasscode 
  FROM coretitleinfo 
  WHERE bookkey = @i_bookkey ORDER BY printingkey ASC  
    
  SET @v_@v_sendtoeloquenceind_return_value = 0  
  SET @v_sendtoeloquenceind = 0
      
  IF EXISTS (SELECT * 
  FROM miscitemsection s, bookmiscitems i, bookmisc b
  WHERE s.misckey = i.misckey AND 
	  i.misckey = b.misckey AND
	  b.bookkey = @i_bookkey AND
	  b.misckey = @i_misckey AND 
	  i.activeind = 1 AND
	  s.usageclasscode IN(@v_usageclasscode, 0)) BEGIN
  
	  SELECT TOP(1) @v_sendtoeloquenceind = COALESCE(b.sendtoeloquenceind,0)
	  FROM miscitemsection s, bookmiscitems i, bookmisc b
	  WHERE s.misckey = i.misckey AND 
		  i.misckey = b.misckey AND
		  b.bookkey = @i_bookkey AND
		  b.misckey = @i_misckey AND 
		  i.activeind = 1 AND
		  s.usageclasscode IN(@v_usageclasscode, 0)
	  ORDER BY s.columnnumber, s.itemposition    
	  
	  SET @v_@v_sendtoeloquenceind_return_value = @v_sendtoeloquenceind
  END
  ELSE IF EXISTS (SELECT * FROM bookmiscitems i join miscitemsection s  on 
				  i.misckey = s.misckey    
						left outer JOIN bookmiscdefaults d on 
							d.misckey = i.misckey AND
					  d.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)			
				  WHERE i.activeind = 1 AND
					  s.misckey = @i_misckey 
					  AND s.usageclasscode IN(@v_usageclasscode, 0)) BEGIN
					  
  SELECT TOP(1) @v_sendtoeloquenceind = i.sendtoeloquenceind FROM bookmiscitems i join miscitemsection s  on 
					  i.misckey = s.misckey    
							left outer JOIN bookmiscdefaults d on 
								d.misckey = i.misckey AND
						  d.orgentrykey IN (SELECT orgentrykey FROM bookorgentry WHERE bookkey = @i_bookkey)			
					  WHERE i.activeind = 1 AND
						  s.misckey = @i_misckey 
						  AND s.usageclasscode IN(@v_usageclasscode, 0)		
						  
	 SET @v_@v_sendtoeloquenceind_return_value = @v_sendtoeloquenceind				  			  					  					  
  END
  ELSE BEGIN
    SET @v_@v_sendtoeloquenceind_return_value = 0
  END 						  					  					 
	 
  RETURN @v_@v_sendtoeloquenceind_return_value
  
END
GO

GRANT EXEC ON dbo.qtitle_get_misc_sendtoeloquence_value TO public
GO
