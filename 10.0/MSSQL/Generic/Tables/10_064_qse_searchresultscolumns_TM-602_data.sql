DELETE FROM qse_searchresultscolumns WHERE searchtypecode=8 and searchitemcode=2 and usageclasscode=0 and columnnumber IN (11,12,13,14,15,16,17,18,19)

IF NOT EXISTS (SELECT 1 FROM qse_searchresultscolumns WHERE searchtypecode=8 and searchitemcode=2 and usageclasscode=0 and columnnumber=11)
  INSERT INTO qse_searchresultscolumns (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
  VALUES (8, 2, 0, 11, 'First Name', 'First Name', NULL, 'globalcontact', 'firstname', 1, 0, 10, 10, 'left', '(SELECT TOP 1 firstname from globalcontact WHERE corecontactinfo.contactkey = globalcontact.globalcontactkey)')

IF NOT EXISTS (SELECT 1 FROM qse_searchresultscolumns WHERE searchtypecode=8 and searchitemcode=2 and usageclasscode=0 and columnnumber=12)
  INSERT INTO qse_searchresultscolumns (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
  VALUES (8, 2, 0, 12, 'Last Name', 'Last Name', NULL, 'globalcontact', 'lastname', 1, 0, 11, 11, 'left', '(SELECT TOP 1 lastname from globalcontact WHERE corecontactinfo.contactkey = globalcontact.globalcontactkey)')

IF NOT EXISTS (SELECT 1 FROM qse_searchresultscolumns WHERE searchtypecode=8 and searchitemcode=2 and usageclasscode=0 and columnnumber=13)
  INSERT INTO qse_searchresultscolumns (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
  VALUES (8, 2, 0, 13, 'Address', 'Address', 200, 'globalcontactaddress', 'fulladdress', 1, 0, 12, 12, 'left', '(SELECT TOP 1 dbo.qutl_get_address(address1, address2, address3, city, statecode, zipcode, NULL) AS fulladdress FROM globalcontactaddress gca WHERE corecontactinfo.contactkey = gca.globalcontactkey AND ISNULL(primaryind,0) = 1)')

IF NOT EXISTS (SELECT 1 FROM qse_searchresultscolumns WHERE searchtypecode=8 and searchitemcode=2 and usageclasscode=0 and columnnumber=14)
  INSERT INTO qse_searchresultscolumns (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
  VALUES (8, 2, 0, 14, 'Address 1', 'Address 1', NULL, 'globalcontactaddress', 'address1', 1, 0, 13, 13, 'left', '(SELECT TOP 1 address1 FROM globalcontactaddress gca WHERE corecontactinfo.contactkey = gca.globalcontactkey AND ISNULL(gca.primaryind,0) = 1)')

IF NOT EXISTS (SELECT 1 FROM qse_searchresultscolumns WHERE searchtypecode=8 and searchitemcode=2 and usageclasscode=0 and columnnumber=15)
  INSERT INTO qse_searchresultscolumns (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
  VALUES (8, 2, 0, 15, 'Address 2', 'Address 2', NULL, 'globalcontactaddress', 'address2', 1, 0, 14, 14, 'left', '(SELECT TOP 1 address2 FROM globalcontactaddress gca WHERE corecontactinfo.contactkey = gca.globalcontactkey AND ISNULL(gca.primaryind,0) = 1)')

IF NOT EXISTS (SELECT 1 FROM qse_searchresultscolumns WHERE searchtypecode=8 and searchitemcode=2 and usageclasscode=0 and columnnumber=16)
  INSERT INTO qse_searchresultscolumns (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
  VALUES (8, 2, 0, 16, 'Address 3', 'Address 3', NULL, 'globalcontactaddress', 'address3', 1, 0, 15, 15, 'left', '(SELECT TOP 1 address3 FROM globalcontactaddress gca WHERE corecontactinfo.contactkey = gca.globalcontactkey AND ISNULL(gca.primaryind,0) = 1)')

IF NOT EXISTS (SELECT 1 FROM qse_searchresultscolumns WHERE searchtypecode=8 and searchitemcode=2 and usageclasscode=0 and columnnumber=17)
  INSERT INTO qse_searchresultscolumns (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
  VALUES (8, 2, 0, 17, 'City', 'City', NULL, 'globalcontactaddress', 'city', 1, 0, 16, 16, 'left', '(SELECT TOP 1 city FROM globalcontactaddress gca WHERE corecontactinfo.contactkey = gca.globalcontactkey AND ISNULL(gca.primaryind,0) = 1)')

IF NOT EXISTS (SELECT 1 FROM qse_searchresultscolumns WHERE searchtypecode=8 and searchitemcode=2 and usageclasscode=0 and columnnumber=18)
  INSERT INTO qse_searchresultscolumns (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
  VALUES (8, 2, 0, 18, 'State', 'State', 20, 'globalcontactaddress', 'statecode', 1, 0, 17, 17, 'center', '(SELECT TOP 1 statecode FROM globalcontactaddress gca WHERE corecontactinfo.contactkey = gca.globalcontactkey AND ISNULL(gca.primaryind,0) = 1)')

IF NOT EXISTS (SELECT 1 FROM qse_searchresultscolumns WHERE searchtypecode=8 and searchitemcode=2 and usageclasscode=0 and columnnumber=19)
  INSERT INTO qse_searchresultscolumns (searchtypecode, searchitemcode, usageclasscode, columnnumber, objectname, columnlabel, defaultwidth, tablename, columnname, displayind, keycolumnind, defaultsortorder, websortorder, webhorizontalalign, columnvaluesql)
  VALUES (8, 2, 0, 19, 'Zip Code', 'Zip Code', NULL, 'globalcontactaddress', 'zipcode', 1, 0, 18, 18, 'left', '(SELECT TOP 1 zipcode FROM globalcontactaddress gca WHERE corecontactinfo.contactkey = gca.globalcontactkey AND ISNULL(gca.primaryind,0) = 1)')
