SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_taqrelationshiptabconfig_button' ) 
drop procedure qutl_insert_taqrelationshiptabconfig_button
go

CREATE PROCEDURE [dbo].[qutl_insert_taqrelationshiptabconfig_button]
 (@i_relationtabqsicode			integer,
  @i_relationtabdatadesc		varchar (40),
  @i_itemqsicode				integer,
  @i_classqsicode				integer,
  @i_button_type			    integer,     -- 0, no button, 1 for Create, 2 for Relate
  @i_button_itemqsicode			integer,
  @i_button_classqsicode		integer,
  @i_newrelateqsicode			integer,     -- only needed for create for proj-proj
  @i_newrelatedesc				varchar(40), -- only needed for create for proj-proj
  @i_existrelateqsicode			integer,     -- only needed for create for proj-proj
  @i_existrelatedesc			varchar(40), -- only needed for create for proj-proj 
  @i_projroleqsicode			integer,     -- only needed for create for proj-title
  @i_projroledesc				varchar(40), -- only needed for create for proj-title
  @i_titleroleqsicode			integer,	 -- only needed for create for proj-title
  @i_titleroledesc				varchar(40), -- only needed for create for proj-title
  @o_taqrelationshipconfigkey   integer output,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/***********************************************************************************************
**  Name: qutl_insert_taqrelationshiptabconfig_button
**  Desc: This stored procedure searches to see if a the taqrelationshiptabconfig row exists 
**        for the item type/class/tab code sent.  If no, it will create it. Then it will search
**        for an existing create (button type 1) or relate (button type 2)button based on 
**        item/class and update relationship codes it if it exist; if no buttons of the determined 
**        are used for this item class, the next unused button will be used if any exist.   
**        the relate and create buttons based on the item/classes sent for each.  All item type   
**        and classes will be identified by qsicode since they can differ on each database.  
**        The tab is identified by either qsicode or datadesc as are the relationships.  
**    Auth: SLB
**    Date: 9 Jan 2015
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:       Author:        Description:
**    --------    --------        ---------------------------------------------------------------
**    2/12/16     SLB			  Added Related Button capibility using existing parameters so 
**                                existing calls should still work           
************************************************************************************************/

  DECLARE 
	@v_button_itemcode	    integer,
	@v_button_classcode		integer,
	@v_newrelatecode		integer,
    @v_existrelatecode		integer,
    @v_projrolecode			integer,
    @v_titlerolecode		integer,
    @v_button_number		integer,
    @v_count                integer,
	@v_error_code			integer,
	@v_error_desc			varchar (2000)
	     
  SET @o_taqrelationshipconfigkey = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_button_itemcode = 0	        
  SET @v_button_classcode = 0			
  SET @v_newrelatecode = 0		
  SET @v_existrelatecode= 0 	
  SET @v_projrolecode = 0	    
  SET @v_titlerolecode =0		
  SET @v_button_number = 0
  SET @v_count = 0    
  SET @v_error_code = 0
  SET @v_error_desc = ''
    
BEGIN
	
	
	--Find if taqrelationshipconfig row exists for this tab/item/class; if not insert it
	exec qutl_insert_taqrelationshiptabconfig @i_relationtabqsicode, @i_relationtabdatadesc, @i_itemqsicode, @i_classqsicode,
		  @o_taqrelationshipconfigkey output, @o_error_code output, @o_error_desc output
	 IF @o_error_code <> 0 BEGIN
		  RETURN
		END 
	
	IF @i_button_type = 0 -- NO BUTTON  
	  RETURN
	  
	--Button Type must be 1(create) or 2 (replace) to continue
	IF @i_button_type <> 1 AND @i_button_type <>2  BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'button type must be 0 (no button), 1 (create) or 2 (replace)for tab.  Button Type  = ' +  cast(@i_button_type AS VARCHAR) 
	  RETURN  
	 END
	  
 	--Find button item/class 
	exec qutl_get_item_class_datacodes_from_qsicodes @i_button_itemqsicode, @i_button_classqsicode,  @v_button_itemcode output,  @v_button_classcode output,
      @v_error_code output,@v_error_desc output
	IF @v_error_code <> 0 BEGIN
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Error finding BUTTON item-class: item qsicode=' + cast(@i_button_itemqsicode AS VARCHAR)+ ', classqsicode = ' +  cast(@i_button_classqsicode AS VARCHAR)
	  RETURN
	END 
	
	--Button Item Code must exist	  
 	IF @v_button_itemcode = NULL BEGIN  -- Item is required
	  SET @o_error_code = -1
	  SET @o_error_desc = 'Item Type must exist for button on tab with desc = ' +  @i_relationtabdatadesc + ' and tab qsicode = ' +cast(@i_relationtabqsicode AS VARCHAR) 
	  RETURN
	END    
 
  IF @i_button_type = 2  BEGIN -- RELATE BUTTON  
     --Check to see if button exists already
    
  --Find Open Button      
  --   IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
  --        WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (relateitemtypecode IS NULL OR relateitemtypecode = 0 ))
	 --  SET @v_button_number = 1
  --   ELSE IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
  --        WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (relate2itemtypecode IS NULL OR relate2itemtypecode = 0))
	 --  SET @v_button_number = 2
  --   ELSE IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
  --        WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (relate3itemtypecode IS NULL OR relate3itemtypecode = 0))
	 --  SET @v_button_number = 3 
	 -- ELSE  BEGIN  --No Open Buttons
	 --  SET @o_error_code = -1
	 --  SET @o_error_desc = 'No Open Relate buttons exist on tab with desc = ' +  @i_relationtabdatadesc + ' and tab qsicode = ' +cast(@i_relationtabqsicode AS VARCHAR) 
	 --  RETURN
	 --END       
     
        --See if Create Button exists already for item/class
   IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
        WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (@v_button_itemcode = relateitemtypecode) 
        AND (@v_button_classcode = relateclasscode))
     SET @v_button_number = 1
     ELSE IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
          WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (@v_button_itemcode = relate2itemtypecode) 
          AND (@v_button_classcode = relate2classcode))
	 SET @v_button_number = 2
     ELSE IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
          WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (@v_button_itemcode = relate3itemtypecode) 
          AND (@v_button_classcode = relate3classcode))
      SET @v_button_number = 3 
      ELSE  BEGIN  --Does not exist already; Find Open Button      
		 IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
			  WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (relateitemtypecode IS NULL OR relateitemtypecode = 0 ))
		   SET @v_button_number = 1
		 ELSE IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
			  WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (relate2itemtypecode IS NULL OR relate2itemtypecode = 0))
		   SET @v_button_number = 2
		 ELSE IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
			  WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (relate3itemtypecode IS NULL OR relate3itemtypecode = 0))
		   SET @v_button_number = 3 
		  ELSE  BEGIN  --No Open Buttons
		   SET @o_error_code = -1
		   SET @o_error_desc = 'No Open relate buttons exist on tab with desc = ' +  @i_relationtabdatadesc + ' and tab qsicode = ' +cast(@i_relationtabqsicode AS VARCHAR) 
		   RETURN
		  END       
       END  --Find Open Button
     
    --Find relationship/role datacodes
    exec @v_newrelatecode = qutl_get_gentables_datacode 582, @i_newrelateqsicode , @i_newrelatedesc
    IF @v_newrelatecode = 0
     Set @v_newrelatecode = NULL
        
    exec @v_existrelatecode = qutl_get_gentables_datacode 582, @i_existrelateqsicode , @i_existrelatedesc
    IF @v_existrelatecode = 0
     Set @v_existrelatecode = NULL
         
    exec @v_projrolecode = qutl_get_gentables_datacode 604, @i_projroleqsicode, @i_projroledesc
    IF @v_projrolecode = 0
     Set @v_projrolecode = NULL
        
    exec @v_titlerolecode = qutl_get_gentables_datacode 605, @i_titleroleqsicode , @i_titleroledesc
    IF @v_titlerolecode = 0
     Set @v_titlerolecode = NULL
     
   IF @v_button_number = 1
     UPDATE taqrelationshiptabconfig SET relateitemtypecode = @v_button_itemcode, relateclasscode = @v_button_classcode, 
       relaterelatedprojrelcode =  @v_newrelatecode,  relatecurrentprojrelcode = @v_existrelatecode,
       relateprojrolecode = @v_projrolecode, relatetitlerolecode = @v_titlerolecode
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey
   ELSE IF @v_button_number = 2
     UPDATE taqrelationshiptabconfig SET relate2itemtypecode = @v_button_itemcode, relate2classcode = @v_button_classcode, 
       relate2relatedprojrelcode =  @v_newrelatecode,  relate2currentprojrelcode = @v_existrelatecode,
       relate2projrolecode = @v_projrolecode, relate2titlerolecode = @v_titlerolecode
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey   
   ELSE IF @v_button_number = 3
     UPDATE taqrelationshiptabconfig SET relate3itemtypecode = @v_button_itemcode, relate3classcode = @v_button_classcode, 
       relate3relatedprojrelcode =  @v_newrelatecode,  relate3currentprojrelcode = @v_existrelatecode,
       relate3projrolecode = @v_projrolecode, relate3titlerolecode = @v_titlerolecode 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey 

    SELECT @v_error_code = @@ERROR
    IF @v_error_code <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + cast(@i_relationtabdatadesc AS VARCHAR)
     END 
   	 
     RETURN   
   END --RELATE BUTTON 

   --See if Create Button exists already for item/class
   IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
        WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (@v_button_itemcode = createitemtypecode) 
        AND (@v_button_classcode = createclasscode))
     SET @v_button_number = 1
     ELSE IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
          WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (@v_button_itemcode = create2itemtypecode) 
          AND (@v_button_classcode = create2classcode))
	 SET @v_button_number = 2
     ELSE IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
          WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (@v_button_itemcode = create3itemtypecode) 
          AND (@v_button_classcode = create3classcode))
      SET @v_button_number = 3 
      ELSE  BEGIN  --Does not exist already; Find Open Button      
		 IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
			  WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (createitemtypecode IS NULL OR createitemtypecode = 0 ))
		   SET @v_button_number = 1
		 ELSE IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
			  WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (create2itemtypecode IS NULL OR create2itemtypecode = 0))
		   SET @v_button_number = 2
		 ELSE IF EXISTS (SELECT 1 FROM taqrelationshiptabconfig  
			  WHERE (@o_taqrelationshipconfigkey = taqrelationshiptabconfigkey) AND (create3itemtypecode IS NULL OR create3itemtypecode = 0))
		   SET @v_button_number = 3 
		  ELSE  BEGIN  --No Open Buttons
		   SET @o_error_code = -1
		   SET @o_error_desc = 'No Open Create buttons exist on tab with desc = ' +  @i_relationtabdatadesc + ' and tab qsicode = ' +cast(@i_relationtabqsicode AS VARCHAR) 
		   RETURN
		  END       
       END  --Find Open Button
       
   --Find relationship/role datacodes
   exec @v_newrelatecode = qutl_get_gentables_datacode 582, @i_newrelateqsicode , @i_newrelatedesc
   IF @v_newrelatecode = 0
     Set @v_newrelatecode = NULL
        
   exec @v_existrelatecode = qutl_get_gentables_datacode 582, @i_existrelateqsicode , @i_existrelatedesc
   IF @v_existrelatecode = 0
     Set @v_existrelatecode = NULL
         
   exec @v_projrolecode = qutl_get_gentables_datacode 604, @i_projroleqsicode, @i_projroledesc
   IF @v_projrolecode = 0
     Set @v_projrolecode = NULL
        
   exec @v_titlerolecode = qutl_get_gentables_datacode 605, @i_titleroleqsicode , @i_titleroledesc
   IF @v_titlerolecode = 0
     Set @v_titlerolecode = NULL
     
   IF @v_button_number = 1
     UPDATE taqrelationshiptabconfig SET createitemtypecode = @v_button_itemcode, createclasscode = @v_button_classcode, 
       createnewrelatecode =  @v_newrelatecode, createexistrelatecode = @v_existrelatecode,
       createprojrolecode = @v_projrolecode, createtitlerolecode = @v_titlerolecode
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey
   ELSE IF @v_button_number = 2
     UPDATE taqrelationshiptabconfig SET create2itemtypecode = @v_button_itemcode, create2classcode = @v_button_classcode, 
       create2newrelatecode =  @v_newrelatecode, create2existrelatecode = @v_existrelatecode,
       create2projrolecode = @v_projrolecode, create2titlerolecode = @v_titlerolecode 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey   
   ELSE IF @v_button_number = 3
     UPDATE taqrelationshiptabconfig SET create3itemtypecode = @v_button_itemcode, create3classcode = @v_button_classcode, 
       create3newrelatecode =  @v_newrelatecode, create3existrelatecode = @v_existrelatecode,
       create3projrolecode = @v_projrolecode, create3titlerolecode = @v_titlerolecode 
       WHERE @o_taqrelationshipconfigkey = taqrelationshiptabconfigkey 

   SELECT @v_error_code = @@ERROR
   IF @v_error_code <> 0 BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'update to taqrelationshiptabconfig table had an error: relationship tab =' + cast(@i_relationtabdatadesc AS VARCHAR)
     END 
   
    RETURN   
    
END  --PROCEDURE END


GO


