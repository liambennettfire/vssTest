


/******************************************************************************************
**  Executes the qutl_insert_gentable_value procedure
assign formats of work tab to new title tab group and make visible for co-edition title class 
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
    
   SET @v_tableid = 440
   SET @v_datacode = 5
   SET @v_datasubcode = 0
   SET @v_datasub2code = 0
   SET @v_itemtype = 10
   SET @v_class = 2   
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc
    
END  
  
 GO