-- Add banking details Misc Fields to Bookmiscitems
-- Add banking details misc fields to Client information misc section located on contact summary

DECLARE
  @v_misckey INT,
  @v_datacode INT,
  @i_configobjectkey INT,
  @i_itemtypecode INT,
  @i_usageclasscode INT,
  @i_columnnumber INT,
  @i_itemposition INT,
  @i_updateind INT,
  @i_bankname INT,
  @i_qsicode INT

SELECT @i_configobjectkey = (SELECT configobjectkey FROM qsiconfigobjects WHERE configobjectid='shClientInformation') 
SELECT @i_itemtypecode = 2 -- contact
SELECT @i_usageclasscode = 0
SELECT @i_columnnumber = 1
SELECT @i_itemposition = 2
SELECT @i_updateind = 1

BEGIN
  SELECT @i_bankname = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate)
  VALUES
    (@i_bankname, 'Bank Name', 'Bank Name', 3, 1, 'QSIDBA', getdate())
END

IF NOT EXISTS (SELECT 1 FROM miscitemsection WHERE configobjectkey = @i_configobjectkey AND misckey = @i_bankname) 
BEGIN
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  VALUES 
    (@i_bankname, @i_configobjectkey, @i_usageclasscode, @i_itemtypecode, @i_columnnumber, @i_itemposition, @i_updateind, 'QSIDBA', GETDATE())
END 
  
GO

DECLARE
  @v_misckey INT,
  @v_datacode INT,
  @i_configobjectkey INT,
  @i_itemtypecode INT,
  @i_usageclasscode INT,
  @i_columnnumber INT,
  @i_itemposition INT,
  @i_updateind INT,
  @i_bankaddress INT,
  @i_qsicode INT

SELECT @i_configobjectkey = (SELECT configobjectkey FROM qsiconfigobjects WHERE configobjectid='shClientInformation') 
SELECT @i_itemtypecode = 2 -- contact
SELECT @i_usageclasscode = 0
SELECT @i_columnnumber = 1
SELECT @i_itemposition = 3
SELECT @i_updateind = 1

BEGIN
  SELECT @i_bankaddress = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate)
  VALUES
    (@i_bankaddress, 'Bank Address', 'Bank Address', 3, 1, 'QSIDBA', getdate())
END

IF NOT EXISTS (SELECT 1 FROM miscitemsection WHERE configobjectkey = @i_configobjectkey AND misckey = @i_bankaddress) 
BEGIN
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  VALUES 
    (@i_bankaddress, @i_configobjectkey, @i_usageclasscode, @i_itemtypecode, @i_columnnumber, @i_itemposition, @i_updateind, 'QSIDBA', GETDATE())
END 
  
GO

DECLARE
  @v_misckey INT,
  @v_datacode INT,
  @i_configobjectkey INT,
  @i_itemtypecode INT,
  @i_usageclasscode INT,
  @i_columnnumber INT,
  @i_itemposition INT,
  @i_updateind INT,
  @i_sortcode INT,
  @i_qsicode INT

SELECT @i_configobjectkey = (SELECT configobjectkey FROM qsiconfigobjects WHERE configobjectid='shClientInformation') 
SELECT @i_itemtypecode = 2 -- contact
SELECT @i_usageclasscode = 0
SELECT @i_columnnumber = 2
SELECT @i_itemposition = 2
SELECT @i_updateind = 1

BEGIN
  SELECT @i_sortcode = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate)
  VALUES
    (@i_sortcode, 'Sort Code', 'Sort Code', 1, 1, 'QSIDBA', getdate())
END

IF NOT EXISTS (SELECT 1 FROM miscitemsection WHERE configobjectkey = @i_configobjectkey AND misckey = @i_sortcode) 
BEGIN
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  VALUES 
    (@i_sortcode, @i_configobjectkey, @i_usageclasscode, @i_itemtypecode, @i_columnnumber, @i_itemposition, @i_updateind, 'QSIDBA', GETDATE())
END 
  
GO

DECLARE
  @v_misckey INT,
  @v_datacode INT,
  @i_configobjectkey INT,
  @i_itemtypecode INT,
  @i_usageclasscode INT,
  @i_columnnumber INT,
  @i_itemposition INT,
  @i_updateind INT,
  @i_accountname INT,
  @i_qsicode INT

SELECT @i_configobjectkey = (SELECT configobjectkey FROM qsiconfigobjects WHERE configobjectid='shClientInformation') 
SELECT @i_itemtypecode = 2 -- contact
SELECT @i_usageclasscode = 0
SELECT @i_columnnumber = 2
SELECT @i_itemposition = 3
SELECT @i_updateind = 1

BEGIN
  SELECT @i_accountname = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate)
  VALUES
    (@i_accountname, 'Account Name', 'Account Name', 3, 1, 'QSIDBA', getdate())
END

IF NOT EXISTS (SELECT 1 FROM miscitemsection WHERE configobjectkey = @i_configobjectkey AND misckey = @i_accountname) 
BEGIN
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  VALUES 
    (@i_accountname, @i_configobjectkey, @i_usageclasscode, @i_itemtypecode, @i_columnnumber, @i_itemposition, @i_updateind, 'QSIDBA', GETDATE())
END 
  
GO

DECLARE
  @v_misckey INT,
  @v_datacode INT,
  @i_configobjectkey INT,
  @i_itemtypecode INT,
  @i_usageclasscode INT,
  @i_columnnumber INT,
  @i_itemposition INT,
  @i_updateind INT,
  @i_iban INT,
  @i_qsicode INT

SELECT @i_configobjectkey = (SELECT configobjectkey FROM qsiconfigobjects WHERE configobjectid='shClientInformation') 
SELECT @i_itemtypecode = 2 -- contact
SELECT @i_usageclasscode = 0
SELECT @i_columnnumber = 2
SELECT @i_itemposition = 4
SELECT @i_updateind = 1

BEGIN
  SELECT @i_iban = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate)
  VALUES
    (@i_iban, 'IBAN', 'IBAN', 1, 1, 'QSIDBA', getdate())
END

IF NOT EXISTS (SELECT 1 FROM miscitemsection WHERE configobjectkey = @i_configobjectkey AND misckey = @i_iban) 
BEGIN
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  VALUES 
    (@i_iban, @i_configobjectkey, @i_usageclasscode, @i_itemtypecode, @i_columnnumber, @i_itemposition, @i_updateind, 'QSIDBA', GETDATE())
END 
  
GO

DECLARE
  @v_misckey INT,
  @v_datacode INT,
  @i_configobjectkey INT,
  @i_itemtypecode INT,
  @i_usageclasscode INT,
  @i_columnnumber INT,
  @i_itemposition INT,
  @i_updateind INT,
  @i_acctnumber INT,
  @i_qsicode INT

SELECT @i_configobjectkey = (SELECT configobjectkey FROM qsiconfigobjects WHERE configobjectid='shClientInformation') 
SELECT @i_itemtypecode = 2 -- contact
SELECT @i_usageclasscode = 0
SELECT @i_columnnumber = 3
SELECT @i_itemposition = 2
SELECT @i_updateind = 1

BEGIN
  SELECT @i_acctnumber = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate)
  VALUES
    (@i_acctnumber, 'Account Number', 'Account Number', 1, 1, 'QSIDBA', getdate())
END

IF NOT EXISTS (SELECT 1 FROM miscitemsection WHERE configobjectkey = @i_configobjectkey AND misckey = @i_acctnumber) 
BEGIN
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  VALUES 
    (@i_acctnumber, @i_configobjectkey, @i_usageclasscode, @i_itemtypecode, @i_columnnumber, @i_itemposition, @i_updateind, 'QSIDBA', GETDATE())
END 
  
GO

DECLARE
  @v_misckey INT,
  @v_datacode INT,
  @i_configobjectkey INT,
  @i_itemtypecode INT,
  @i_usageclasscode INT,
  @i_columnnumber INT,
  @i_itemposition INT,
  @i_updateind INT,
  @i_swiftcode INT,
  @i_qsicode INT

SELECT @i_configobjectkey = (SELECT configobjectkey FROM qsiconfigobjects WHERE configobjectid='shClientInformation') 
SELECT @i_itemtypecode = 2 -- contact
SELECT @i_usageclasscode = 0
SELECT @i_columnnumber = 3
SELECT @i_itemposition = 3
SELECT @i_updateind = 1

BEGIN
  SELECT @i_swiftcode = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
  INSERT INTO bookmiscitems
    (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate)
  VALUES
    (@i_swiftcode, 'Swift Code', 'Swift Code', 3, 1, 'QSIDBA', getdate())
END

IF NOT EXISTS (SELECT 1 FROM miscitemsection WHERE configobjectkey = @i_configobjectkey AND misckey = @i_swiftcode) 
BEGIN
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  VALUES 
    (@i_swiftcode, @i_configobjectkey, @i_usageclasscode, @i_itemtypecode, @i_columnnumber, @i_itemposition, @i_updateind, 'QSIDBA', GETDATE())
END 
  
GO