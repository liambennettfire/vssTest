DECLARE
  @v_count  INT,
  @v_itemtype INT,
  @v_newkey INT,
  @v_usageclasscode INT
  
  
     
BEGIN  
  SELECT @v_itemtype = datacode FROM gentables WHERE tableid = 550 and qsicode = 2 --Contacts

  SELECT @v_count = COUNT(*)
  FROM qsiconfigobjects
  WHERE lower(configobjectid) = 'vendorandshippinginformation' AND itemtypecode = @v_itemtype

  IF @v_count = 0 BEGIN
    EXEC dbo.get_next_key 'QSIDBA', @v_newkey OUT
    
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, defaultminimizedind, itemtypecode, miscsectionind,
      position, configobjecttype, groupkey, sectioncontrolname)
    SELECT @v_newkey, windowid, 'VendorandShippingInformation', 'Vendor and Shipping Information', 'Vendor and Shipping Information',
      'QSIDBA', getdate(), 0, 0, @v_itemtype, 1, null, 3, @v_newkey, '~/PageControls/Contacts/Sections/Summary/ContactsMisc.ascx'
    FROM qsiwindows
    WHERE lower(windowname) = 'contactsummary'
  END
END
go

