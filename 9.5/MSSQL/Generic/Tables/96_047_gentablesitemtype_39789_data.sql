
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
    
   SET @v_tableid = 598
   SET @v_datacode = 13  -- Misc Items
   SET @v_datasubcode = 0
   SET @v_datasub2code = 0
   SET @v_itemtype = 0
   SET @v_class = 0
   
   SELECT @v_itemtype = datacode
   FROM gentables
   WHERE tableid = 550 AND qsicode = 3  -- Projects
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc

   SET @v_tableid = 592
   SET @v_datacode = 12  -- Misc Items
   SET @v_datasubcode = 0
   SET @v_datasub2code = 0
   SET @v_itemtype = 0
   SET @v_class = 0
   
   SELECT @v_itemtype = datacode
   FROM gentables
   WHERE tableid = 550 AND qsicode = 1  -- Titles
    

exec qutl_insert_gentablesitemtype @v_tableid, @v_datacode,@v_datasubcode, @v_datasub2code, @v_itemtype, @v_class,@v_error_code OUTPUT,@v_error_desc OUTPUT
 
print 'errorcode = ' + CAST(@v_error_code AS varchar)
print 'error message =' + @v_error_desc
    
END  
  
 GO