DECLARE
  @v_count  INT,
  @v_maxkey INT,
  @v_tabcode  INT,
  @v_datetypecode  INT,
  @v_usageclass INT,
  @v_datetype_pubdate INT,
  @v_label_pubdate VARCHAR(40),
  @v_datetype_releasedate INT,
  @v_label_releasedate VARCHAR(40),
  @v_datetype_bbdate INT,
  @v_label_bbdate VARCHAR(40),
  @v_projectrole_code INT,
  @v_titlerole_code INT,
  @v_roletypecode_code INT,
  @v_roletype_label VARCHAR(40),
  @v_productid_code1	INT,
  @v_productid1_label	VARCHAR(100),
  @v_productid_code2	INT,
  @v_productid2_label	VARCHAR(100),
  @v_related_itemtypecode	INT,
  @v_related_usageclass	INT,
  @v_createnewrelate_code	INT,
  @v_createexistsrelate_code	INT,
  @v_create2newrelate_code	INT,
  @v_create2existsrelate_code	INT,
  @v_itemtypecode INT,
  @v_datetype_podate INT,
  @v_label_podate VARCHAR(40),
  @v_createitemtypecode INT,
  @v_createusageclasscode INT,
  @v_create2itemtypecode INT,
  @v_create2usageclasscode INT
  
--We will need sql to create a row for the PO Reports tab for the Purchase Order/Purchase Order item type/class  - 
--add PO Date, PO # and PO Amendment # as product ids. 
--Set the createitemtypecode to Purchase Ordesr and createclasscode to Proforma PO Report. 
--Set the createexistrelatecode 'Purchase Orders (for PO Reports)' and createnewrelatecode to 'PO Report' .   
--Set the create2itemtypecode to Purchase Orders and create2classcode to Final PO Report. 
--Set the create2existrelatecode to 'Purchase Orders (for PO Reports)' and create2newrelatecode to 'PO Report' . 
--Do not allow for Relating anything.  
--NOTE :  All tasks, roles etc added should not be hardcoded for datacode but rather search for the datacode based on qsicode or description  

BEGIN
  --PO Reports tab for the Purchase Orders item type
  SELECT @v_maxkey = MAX(taqrelationshiptabconfigkey)
  FROM taqrelationshiptabconfig
  
  IF @v_maxkey IS NULL
    SET @v_maxkey = 0
    
  SELECT @v_tabcode = datacode 
  FROM gentables 
  WHERE tableid = 583 AND qsicode = 35  --PO Reports
  
  SELECT @v_itemtypecode = datacode 
  FROM gentables 
  WHERE tableid = 550 AND qsicode = 15  --Purchase Orders
  
  SELECT @v_usageclass = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 AND datacode = @v_itemtypecode AND lower(datadesc) = 'purchase orders' -- Purchase Order
  
  SELECT @v_createitemtypecode = datacode 
  FROM gentables 
  WHERE tableid = 550 AND qsicode = 15  --Purchase Orders

  SELECT @v_createusageclasscode = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 AND datacode = @v_itemtypecode AND lower(datadesc) = 'proforma po report' -- Proforma PO Report

  SELECT @v_createexistsrelate_code = datacode
    FROM gentables 
   WHERE tableid = 582 AND qsicode = 27  --Purchase Orders (for PO Reports)

  SELECT @v_createnewrelate_code = datacode
    FROM gentables 
   WHERE tableid = 582 AND qsicode = 28  --PO Report

  SELECT @v_create2itemtypecode = datacode 
  FROM gentables 
  WHERE tableid = 550 AND qsicode = 15  --Purchase Orders

  SELECT @v_create2usageclasscode = datasubcode 
  FROM subgentables 
  WHERE tableid = 550 AND datacode = @v_itemtypecode AND lower(datadesc) = 'final po report' -- Final PO Report

  SELECT @v_create2existsrelate_code = datacode
    FROM gentables 
   WHERE tableid = 582 AND qsicode = 27  --Purchase Orders (on PO Reports)

  SELECT @v_create2newrelate_code = datacode
    FROM gentables 
   WHERE tableid = 582 AND qsicode = 28  --PO Report
   
  IF @v_tabcode > 0 AND @v_itemtypecode > 0
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM datetype
    WHERE lower(description) = 'po date'

    SET @v_datetype_podate = NULL
    SET @v_label_podate = NULL
    IF @v_count > 0
      SELECT @v_datetype_podate = datetypecode, @v_label_podate = datelabel
      FROM datetype
      WHERE lower(description) = 'po date'
                      
    -- Product id of PO #
   SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 594
      AND qsicode = 7
      
   SET @v_productid_code1 = NULL
   SET @v_productid1_label = NULL
   IF @v_count > 0
      SELECT @v_productid_code1 = datacode, @v_productid1_label = datadesc
        FROM gentables
        WHERE tableid = 594
          AND qsicode = 7

    SELECT @v_count = COUNT(*)
    FROM taqrelationshiptabconfig
    WHERE relationshiptabcode = @v_tabcode AND
      itemtypecode = @v_itemtypecode 
      
    -- Product id of PO Amendment #
   SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 594
      AND qsicode = 13
      
   SET @v_productid_code2 = NULL
   SET @v_productid2_label = NULL
   IF @v_count > 0
      SELECT @v_productid_code2 = datacode, @v_productid2_label = datadesc
        FROM gentables
        WHERE tableid = 594
          AND qsicode = 13

    SELECT @v_count = COUNT(*)
    FROM taqrelationshiptabconfig
    WHERE relationshiptabcode = @v_tabcode AND
      itemtypecode = @v_itemtypecode AND
      usageclass = @v_usageclass
    
    IF @v_count = 0
    BEGIN
      SET @v_maxkey = @v_maxkey + 1
      
      INSERT INTO taqrelationshiptabconfig
        (taqrelationshiptabconfigkey, relationshiptabcode, itemtypecode, usageclass, datetypecode1,date1label,
         datetypecode2, date2label, datetypecode3, date3label,createitemtypecode,createclasscode,
         productidcode1,productid1label,productidcode2,productid2label,
         createprojrolecode,createtitlerolecode,roletypecode1,roletype1label,lastuserid,lastmaintdate, 
         hidethisrelind, hideotherrelind, hidefiltersind, hideclassind, hidetypeind, hidenotesind, hideownerind, addrelateditemind, 
         relateitemtypecode, relateclasscode, relate2itemtypecode, relate2classcode, relate3itemtypecode, relate3classcode,
         createnewrelatecode, createexistrelatecode,create2itemtypecode,create2classcode,create2newrelatecode,create2existrelatecode)
      VALUES
        (@v_maxkey, @v_tabcode, @v_itemtypecode, @v_usageclass, @v_datetype_podate,@v_label_podate,
         NULL,NULL,NULL,NULL,@v_createitemtypecode,@v_createusageclasscode,
         @v_productid_code1,@v_productid1_label,@v_productid_code2,@v_productid2_label,
         NULL,NULL,@v_roletypecode_code,@v_roletype_label,'QIADMIN',getdate(),
         1, 1, 1, 1, 0, 1, 1, 0, 
         NULL, NULL, NULL, NULL, NULL, NULL,
         @v_createnewrelate_code,@v_createexistsrelate_code,
         @v_create2itemtypecode,@v_create2usageclasscode,@v_create2newrelate_code,@v_create2existsrelate_code)
    END
  END
  
END
go
