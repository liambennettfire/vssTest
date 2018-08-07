
/******************************************************************************************
**  Executes the qutl_insert_gentable_value procedure
*******************************************************************************************/

BEGIN

  DECLARE
   @v_tableid              integer,
   @v_datacode INT,
   @v_datasubcode INT,
   @v_datasub2code INT,
   @v_itemtype INT,
   @v_class INT,   
   @v_error_code  INT,
   @v_error_desc varchar(2000) 
    
--- Name    
   SET @v_tableid = 636
   SET @v_datacode = 13
   SET @v_datasubcode = 1
   SET @v_datasub2code = 0
   SET @v_itemtype = 10
   SET @v_class = 0   
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc

UPDATE gentablesitemtype SET sortorder = 1, numericdesc1 = 1 WHERE tableid = @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class

--- Status    
   SET @v_tableid = 636
   SET @v_datacode = 13
   SET @v_datasubcode = 2
   SET @v_datasub2code = 0
   SET @v_itemtype = 10
   SET @v_class = 0   
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc

UPDATE gentablesitemtype SET sortorder = 2, numericdesc1 = 1 WHERE tableid = @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class

--- DivisionImprint    
   SET @v_tableid = 636
   SET @v_datacode = 13
   SET @v_datasubcode = 4
   SET @v_datasub2code = 0
   SET @v_itemtype = 10
   SET @v_class = 0   
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc

UPDATE gentablesitemtype SET sortorder = 3, numericdesc1 = 1 WHERE tableid = @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class


--- Class    
   SET @v_tableid = 636
   SET @v_datacode = 13
   SET @v_datasubcode = 13
   SET @v_datasub2code = 0
   SET @v_itemtype = 10
   SET @v_class = 0   
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc

UPDATE gentablesitemtype SET sortorder = 1, numericdesc1 = 2 WHERE tableid = @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class

--- Type    
   SET @v_tableid = 636
   SET @v_datacode = 13
   SET @v_datasubcode = 3
   SET @v_datasub2code = 0
   SET @v_itemtype = 10
   SET @v_class = 0   
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc

UPDATE gentablesitemtype SET sortorder = 1, numericdesc1 = 3 WHERE tableid = @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class

--- Template    
   SET @v_tableid = 636
   SET @v_datacode = 13
   SET @v_datasubcode = 12
   SET @v_datasub2code = 0
   SET @v_itemtype = 10
   SET @v_class = 0   
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc

UPDATE gentablesitemtype SET sortorder = 1, numericdesc1 = 4 WHERE tableid = @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class

--- Owner    
   SET @v_tableid = 636
   SET @v_datacode = 13
   SET @v_datasubcode = 15
   SET @v_datasub2code = 0
   SET @v_itemtype = 10
   SET @v_class = 0   
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc

UPDATE gentablesitemtype SET sortorder = 2, numericdesc1 = 4 WHERE tableid = @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class


--- Prod 1    
   SET @v_tableid = 636
   SET @v_datacode = 13
   SET @v_datasubcode = 16
   SET @v_datasub2code = 0
   SET @v_itemtype = 10
   SET @v_class = 0   
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc

UPDATE gentablesitemtype SET sortorder = 3, numericdesc1 = 4 WHERE tableid = @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class

--- Prod 2
   SET @v_tableid = 636
   SET @v_datacode = 13
   SET @v_datasubcode = 17
   SET @v_datasub2code = 0
   SET @v_itemtype = 10
   SET @v_class = 0   
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc

UPDATE gentablesitemtype SET sortorder = 4, numericdesc1 = 4 WHERE tableid = @v_tableid AND datacode = @v_datacode AND datasubcode = @v_datasubcode AND itemtypecode = @v_itemtype AND itemtypesubcode = @v_class

END  
  
 GO