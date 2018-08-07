if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qprinting_insert_first_printings_summarycomponent') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qprinting_insert_first_printings_summarycomponent
GO

CREATE PROCEDURE qprinting_insert_first_printings_summarycomponent
 (@i_projectkey     integer,
  @i_bookkey      integer,
  @i_printingkey    integer,
  @i_userid        VARCHAR(30),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/****************************************************************************************************************************************
**  Name: qprinting_insert_first_printings_summarycomponent
**  Desc: This stored procedure adds a Summary component with specification items if it not present for the Title's first Printing.
**  Auth: Uday A. Khisty
**  Date: February 4, 2015
*****************************************************************************************************************************************
**  Change History
**********************************************************************************************************************
**  Date:    Author: Description:
**  -----    ------  -------------------------------------------
**  05/25/17 Uday    Case 45275
**  12/19/17 Colman  Case 48909 Inactive spec items are being added
********************************************************************************************************************/
  
DECLARE
  @v_error    INT,
  @v_rowcount INT,
  @v_projectkey INT,
  @v_itemtype INT,
  @v_usageclass INT,
  @v_qsicode_project INT,
  @v_itemtype_title INT,
  @v_usageclass_title INT,
  @v_itemtype_printing INT,
  @v_usageclass_printing INT,
  @v_specitemcategory INT,
  @v_bookkey INT,
  @v_plstage INT,
  @v_versionkey INT,
  @v_taqprojectformatkey INT,
  @v_taqversionspecategorykey_new INT,
  @v_taqversionspecitemkey_new INT,
  @v_specitemcategorydesc nvarchar(255),
  @v_userkey INT,
  @v_itemkey INT,
  @v_culturecode INT,
  @v_uomvalue INT,
  @v_clientoption_Production_On_Web INT,
  @v_printingprojectkey INT    
  
BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT @v_clientoption_Production_On_Web = COALESCE(optionvalue, 0) 
  FROM clientoptions where optionid = 117

  IF @v_clientoption_Production_On_Web = 0 BEGIN
    RETURN
  END
  
  IF @i_bookkey > 0 AND (@v_projectkey IS NULL OR @v_projectkey <= 0) 
  BEGIN
    SELECT TOP(1) @v_projectkey = taqprojectkey
    FROM taqprojectprinting_view
    WHERE bookkey = @i_bookkey AND printingkey = @i_printingkey
    ORDER BY printingkey ASC
    
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
     SET @o_error_desc = 'Could not access taqprojectprinting_view to get bookkey.'
     GOTO RETURN_ERROR
    END  
  END
  ELSE BEGIN
    SET @v_projectkey = @i_projectkey
  END

  IF @v_projectkey IS NULL OR @v_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
  
  SET @v_userkey = null
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE userid = @i_userid

  IF @v_userkey IS NULL BEGIN
    SELECT @v_userkey = clientdefaultvalue
    FROM clientdefaults
    WHERE clientdefaultid = 48
  END

  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_userkey is null BEGIN
    SET @v_userkey = -1
  END    
    
  SELECT @v_itemtype = searchitemcode, @v_usageclass = usageclasscode 
  FROM coreprojectinfo  
  WHERE projectkey = @v_projectkey
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Could not access coreprojectinfo to get itemtype and usageclass.'
    GOTO RETURN_ERROR
  END    
  
  SELECT @v_itemtype_title = datacode 
  FROM gentables 
  WHERE tableid = 550 AND qsicode = 1  
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Could not access gentables 550 to get qsicode 1.'
    GOTO RETURN_ERROR
  END    
  
  SELECT @v_itemtype_printing = datacode 
  FROM gentables 
  WHERE tableid = 550 AND qsicode = 14  
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Could not access gentables 550 to get qsicode 14.'
    GOTO RETURN_ERROR
  END    
  
  SELECT @v_qsicode_project = COALESCE(qsicode, 0)
  FROM subgentables  
  WHERE tableid = 550 AND datacode = @v_itemtype AND datasubcode = @v_usageclass
 
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Could not access subgentables 550 to get qsicode.'
    GOTO RETURN_ERROR
  END    
  
  SELECT @v_bookkey = bookkey
  FROM taqprojectprinting_view
  WHERE taqprojectkey = @v_projectkey
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Could not access taqprojectprinting_view to get bookkey.'
    GOTO RETURN_ERROR
  END    
  
  -- Return if not a Printing
  IF @v_qsicode_project <> 40 BEGIN
    RETURN
  END
  
  -- Check to see if it is the First Printing, if not, Return
  SELECT @v_rowcount = COUNT(*)
  FROM taqprojectprinting_view
  WHERE bookkey = @v_bookkey
  
  IF @v_rowcount = 0 OR @v_rowcount > 1 BEGIN
    RETURN
  END
  
  -- Check to see if this is the Titles's First Printing
  SELECT TOP(1) @v_printingprojectkey = taqprojectkey 
  FROM taqprojectprinting_view
  WHERE bookkey = @v_bookkey  
  ORDER BY printingkey ASC
  
  IF @v_printingprojectkey <> @v_projectkey BEGIN
    RETURN
  END
  
  IF NOT EXISTS(SELECT * FROM taqversionformat  WHERE taqprojectkey = @v_projectkey) BEGIN
    --insert a row for it
    RETURN
  END
  
  SELECT TOP(1) @v_plstage = plstagecode, @v_versionkey = taqversionkey, @v_taqprojectformatkey = taqprojectformatkey
  FROM taqversionformat 
  WHERE taqprojectkey = @v_projectkey
 
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    RETURN  -- Not always guaranteed to have a format row (because of client option 119 that inserts row in code)
  END   
  
  SELECT @v_culturecode = qsiusersculturecode FROM dbo.get_culture(@v_userkey, 0, 0)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Could not access function get_culture to get qsiusersculturecode.'
    GOTO RETURN_ERROR
  END    
  
  SELECT @v_specitemcategory = datacode, @v_specitemcategorydesc = datadesc
  FROM gentables  
  WHERE tableid = 616 AND qsicode = 1
 
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Could not access gentables 616 to get datacode.'
    GOTO RETURN_ERROR
  END      
  
  -- Deleting any Summary components that have no specification items
  IF EXISTS (
    SELECT 1 FROM taqversionspeccategory 
    WHERE taqprojectkey = @v_projectkey AND 
      plstagecode = @v_plstage AND 
      taqversionkey = @v_versionkey AND 
      taqversionformatkey = @v_taqprojectformatkey AND
      itemcategorycode = @v_specitemcategory
  ) 
  BEGIN
          
    IF EXISTS (
      SELECT 1 FROM taqversionspecitems
      WHERE taqversionspecategorykey IN 
        (SELECT taqversionspecategorykey FROM taqversionspeccategory 
         WHERE taqprojectkey = @v_projectkey AND 
          plstagecode = @v_plstage AND 
          taqversionkey = @v_versionkey AND 
          taqversionformatkey = @v_taqprojectformatkey AND
          itemcategorycode = @v_specitemcategory)
    ) 
    BEGIN
      RETURN                    
    END        

    DELETE FROM taqversionspecnotes WHERE taqversionspecategorykey IN 
      (SELECT taqversionspecategorykey FROM taqversionspeccategory 
       WHERE taqprojectkey = @v_projectkey AND 
         plstagecode = @v_plstage AND 
         taqversionkey = @v_versionkey AND 
         taqversionformatkey = @v_taqprojectformatkey AND
         itemcategorycode = @v_specitemcategory)
    
    DELETE FROM taqversionspeccategory 
    WHERE taqprojectkey = @v_projectkey AND 
      plstagecode = @v_plstage AND 
      taqversionkey = @v_versionkey AND 
      taqversionformatkey = @v_taqprojectformatkey AND
      itemcategorycode = @v_specitemcategory 
  END    
  
  EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecategorykey_new OUT  
      
  INSERT INTO taqversionspeccategory
         (taqversionspecategorykey
         ,taqprojectkey
         ,plstagecode
         ,taqversionkey
         ,taqversionformatkey
         ,itemcategorycode
         ,speccategorydescription
         ,scaleprojecttype
         ,vendorcontactkey
         ,lastuserid
         ,lastmaintdate
         ,finishedgoodind
         ,sortorder
         ,deriveqtyfromfgqty
         ,spoilagepercentage)
      SELECT            
         @v_taqversionspecategorykey_new
         ,@v_projectkey
         ,@v_plstage
         ,@v_versionkey
         ,@v_taqprojectformatkey
         ,@v_specitemcategory
         ,@v_specitemcategorydesc
         ,0
         ,NULL
         ,@i_userid
         ,getdate()
         ,0
         ,1
         ,0
         ,NULL
  
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Could not access taqversionspeccategory table (taqprojectkey=' + CAST(@v_projectkey AS VARCHAR) + 
      ', plstagecode=' + CAST(@v_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey AS VARCHAR) + 
      ', taqprojectformatkey=' + CAST(@v_taqprojectformatkey AS VARCHAR) + ').'
      GOTO RETURN_ERROR      
    END  
  
    DECLARE specitems_cursor_insert CURSOR FOR
      SELECT DISTINCT s.datasubcode
      FROM subgentables s 
        INNER JOIN gentablesitemtype gi ON gi.tableid = s.tableid AND gi.datacode = s.datacode AND gi.datasubcode = s.datasubcode
      WHERE s.tableid = 616 AND    
        gi.itemtypecode IN(@v_itemtype_printing, @v_itemtype_title) AND
        s.datacode = @v_specitemcategory AND
        s.deletestatus = 'N'
    
    OPEN specitems_cursor_insert
     
    FETCH specitems_cursor_insert
    INTO @v_itemkey

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
      EXEC dbo.get_next_key 'QSIDBA', @v_taqversionspecitemkey_new OUT  
       
      SELECT @v_uomvalue = defaultunitofmeasurecode 
      FROM taqspecadmin
      WHERE itemcategorycode = @v_specitemcategory and culturecode =  @v_culturecode and itemcode = @v_itemkey       
       
      INSERT INTO taqversionspecitems
             (taqversionspecitemkey
             ,taqversionspecategorykey
             ,itemcode
             ,itemdetailcode
             ,itemdetailsubcode
             ,itemdetailsub2code
             ,quantity
             ,validforprtgscode
             ,description
             ,description2
             ,decimalvalue
             ,unitofmeasurecode
             ,lastuserid
             ,lastmaintdate)
         SELECT  @v_taqversionspecitemkey_new
             ,@v_taqversionspecategorykey_new
             ,@v_itemkey
             ,NULL
             ,NULL
             ,NULL               
             ,NULL
             ,3
             ,NULL
             ,NULL
             ,NULL
             ,@v_uomvalue
             ,@i_userid
             ,getdate()     
      
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not access taqversionspecitems table (taqprojectkey=' + CAST(@v_projectkey AS VARCHAR) + 
        ', plstagecode=' + CAST(@v_plstage AS VARCHAR) + ', taqversionkey=' + CAST(@v_versionkey AS VARCHAR) + 
        ', taqprojectformatkey=' + CAST(@v_taqprojectformatkey AS VARCHAR) + ').'
        GOTO RETURN_ERROR          
      END              
      
      FETCH specitems_cursor_insert
      INTO @v_itemkey
    END

  CLOSE specitems_cursor_insert
  DEALLOCATE specitems_cursor_insert            

  RETURN  

RETURN_ERROR:  
  SET @o_error_code = -1
  RETURN  
  
END
go

GRANT EXEC ON qprinting_insert_first_printings_summarycomponent TO PUBLIC
go
