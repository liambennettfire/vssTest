  DECLARE 
    @v_misckey              integer,
    @v_count                integer,
	@o_taqrelationshipconfigkey int,
	@o_error_code			integer,
	@o_error_desc			varchar(2000),
	@v_relationshiptabcode integer,
	@v_error_code			integer,
	@v_error_desc			varchar (2000),
	@i_itemqsicode			integer,
    @i_classqsicode			integer,
	@i_hidedeletebuttonind	integer,
    @i_relationtabqsicode	integer,
    @i_relationtabdatadesc	varchar (40)
	     
  SET @o_taqrelationshipconfigkey = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_count = 0   
  SET @v_relationshiptabcode = 0
  SET @v_error_code = 0
  SET @v_error_desc = ''  
  SET @i_hidedeletebuttonind = 1
    
BEGIN
-----------------------------------------------------------------------------------------------------------------------------------------------   
	 SET @i_relationtabqsicode = 31
	 SET @i_relationtabdatadesc = 'Printings (on Titles)'
	 SET @i_itemqsicode = NULL
	 SET @i_classqsicode = NULL 
	 	 	 		   	 
    --Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	 exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
	  @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   PRINT @o_error_desc
	 END   
		
     UPDATE taqrelationshiptabconfig SET hidedeletebuttonind = @i_hidedeletebuttonind 
     WHERE taqrelationshiptabconfigkey = @o_taqrelationshipconfigkey
	       
     SELECT @v_error_code = @@ERROR
     IF @v_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END 
      
-----------------------------------------------------------------------------------------------------------------------------------------------      
      
	 SET @o_taqrelationshipconfigkey = 0
	 SET @o_error_code = 0
	 SET @o_error_desc = ''
	 SET @v_count = 0   
	 SET @v_relationshiptabcode = 0
	 SET @v_error_code = 0
	 SET @v_error_desc = ''        
	 SET @i_relationtabqsicode = 32
	 SET @i_relationtabdatadesc = 'Purchase Orders (on Printings)'
	 SET @i_itemqsicode = 14
	 SET @i_classqsicode = 40 
 
    --Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	 exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
	   @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   PRINT @o_error_desc
	 END   
		
     UPDATE taqrelationshiptabconfig SET hidedeletebuttonind = @i_hidedeletebuttonind 
     WHERE taqrelationshiptabconfigkey = @o_taqrelationshipconfigkey 
	       
     SELECT @v_error_code = @@ERROR
     IF @v_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END    
		
-----------------------------------------------------------------------------------------------------------------------------------------------		
	 SET @o_taqrelationshipconfigkey = 0
	 SET @o_error_code = 0
	 SET @o_error_desc = ''
	 SET @v_count = 0   
	 SET @v_relationshiptabcode = 0
	 SET @v_error_code = 0
	 SET @v_error_desc = ''     		
	 SET @i_relationtabqsicode = 33
	 SET @i_relationtabdatadesc = 'Printings (on Purchase Orders)'
	 SET @i_itemqsicode = 15
	 SET @i_classqsicode = NULL 
	 	 
    --Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	 exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
	   @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   PRINT @o_error_desc
	 END   
		
     UPDATE taqrelationshiptabconfig SET hidedeletebuttonind = @i_hidedeletebuttonind 
     WHERE taqrelationshiptabconfigkey = @o_taqrelationshipconfigkey
	       
     SELECT @v_error_code = @@ERROR
     IF @v_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END    
     
-----------------------------------------------------------------------------------------------------------------------------------------------     
	 SET @o_taqrelationshipconfigkey = 0
	 SET @o_error_code = 0
	 SET @o_error_desc = ''
	 SET @v_count = 0   
	 SET @v_relationshiptabcode = 0
	 SET @v_error_code = 0
	 SET @v_error_desc = ''          
	 SET @i_relationtabqsicode = 34
	 SET @i_relationtabdatadesc = 'Purchase Orders (on PO Reports)'
	 SET @i_itemqsicode = 15
	 SET @i_classqsicode = 42
	 
    --Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	 exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
	   @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   PRINT @o_error_desc
	 END   
		
     UPDATE taqrelationshiptabconfig SET hidedeletebuttonind = @i_hidedeletebuttonind 
     WHERE taqrelationshiptabconfigkey = @o_taqrelationshipconfigkey  
	       
     SELECT @v_error_code = @@ERROR
     IF @v_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END         
          
	 SET @o_taqrelationshipconfigkey = 0
	 SET @o_error_code = 0
	 SET @o_error_desc = ''
	 SET @v_count = 0   
	 SET @v_relationshiptabcode = 0
	 SET @v_error_code = 0
	 SET @v_error_desc = ''               
	 SET @i_relationtabqsicode = 34
	 SET @i_relationtabdatadesc = 'Purchase Orders (on PO Reports)'
	 SET @i_itemqsicode = 15
	 SET @i_classqsicode = 43
	 
    --Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	 exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
	   @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   PRINT @o_error_desc
	 END   
		
     UPDATE taqrelationshiptabconfig SET hidedeletebuttonind = @i_hidedeletebuttonind 
     WHERE taqrelationshiptabconfigkey = @o_taqrelationshipconfigkey
	       
     SELECT @v_error_code = @@ERROR
     IF @v_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END       
     
-----------------------------------------------------------------------------------------------------------------------------------------------
	 SET @o_taqrelationshipconfigkey = 0
	 SET @o_error_code = 0
	 SET @o_error_desc = ''
	 SET @v_count = 0   
	 SET @v_relationshiptabcode = 0
	 SET @v_error_code = 0
	 SET @v_error_desc = ''          
	 SET @i_relationtabqsicode = 35
	 SET @i_relationtabdatadesc = 'PO Reports'
	 SET @i_itemqsicode = 15
	 SET @i_classqsicode = 41	 	 
	 
    --Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	 exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
	   @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   PRINT @o_error_desc
	 END   
		
     UPDATE taqrelationshiptabconfig SET hidedeletebuttonind = @i_hidedeletebuttonind 
     WHERE taqrelationshiptabconfigkey = @o_taqrelationshipconfigkey
	       
     SELECT @v_error_code = @@ERROR
     IF @v_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END           
				
-----------------------------------------------------------------------------------------------------------------------------------------------			
	 SET @o_taqrelationshipconfigkey = 0
	 SET @o_error_code = 0
	 SET @o_error_desc = ''
	 SET @v_count = 0   
	 SET @v_relationshiptabcode = 0
	 SET @v_error_code = 0
	 SET @v_error_desc = ''     	
	 SET @i_relationtabqsicode = 36
	 SET @i_relationtabdatadesc = 'Printings (on PO Reports)'
	 SET @i_itemqsicode = 15
	 SET @i_classqsicode = 42 
	 
    --Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	 exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
	   @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   PRINT @o_error_desc
	 END   
		
     UPDATE taqrelationshiptabconfig SET hidedeletebuttonind = @i_hidedeletebuttonind 
     WHERE taqrelationshiptabconfigkey = @o_taqrelationshipconfigkey  
	       
     SELECT @v_error_code = @@ERROR
     IF @v_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END   		
     
	 SET @o_taqrelationshipconfigkey = 0
	 SET @o_error_code = 0
	 SET @o_error_desc = ''
	 SET @v_count = 0   
	 SET @v_relationshiptabcode = 0
	 SET @v_error_code = 0
	 SET @v_error_desc = ''          
	 SET @i_relationtabqsicode = 36
	 SET @i_relationtabdatadesc = 'Printings (on PO Reports)'
	 SET @i_itemqsicode = 15
	 SET @i_classqsicode = 43
	 
    --Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	 exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
	   @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   PRINT @o_error_desc
	 END   
		
     UPDATE taqrelationshiptabconfig SET hidedeletebuttonind = @i_hidedeletebuttonind 
     WHERE taqrelationshiptabconfigkey = @o_taqrelationshipconfigkey   
	       
     SELECT @v_error_code = @@ERROR
     IF @v_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END       		

-----------------------------------------------------------------------------------------------------------------------------------------------
	 SET @o_taqrelationshipconfigkey = 0
	 SET @o_error_code = 0
	 SET @o_error_desc = ''
	 SET @v_count = 0   
	 SET @v_relationshiptabcode = 0
	 SET @v_error_code = 0
	 SET @v_error_desc = ''     
	 SET @i_relationtabqsicode = 37
	 SET @i_relationtabdatadesc = 'PO Reports (on Printings)'
	 SET @i_itemqsicode = 14
	 SET @i_classqsicode = 40
	 
    --Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	 exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
	   @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
	   PRINT @o_error_desc
	 END   
		
     UPDATE taqrelationshiptabconfig SET hidedeletebuttonind = @i_hidedeletebuttonind 
     WHERE taqrelationshiptabconfigkey = @o_taqrelationshipconfigkey   
	       
     SELECT @v_error_code = @@ERROR
     IF @v_error_code <> 0 BEGIN
	   SET @o_error_code = -1
	   SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + @i_relationtabdatadesc 
     END       							
-----------------------------------------------------------------------------------------------------------------------------------------------    
END

GO
		