-- Set up the misc sections
DECLARE
  @v_configobjectkey  INT
  
BEGIN

  SELECT @v_configobjectkey = configobjectkey FROM qsiconfigobjects WHERE configobjectid = 'shHomeMisc1'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 1, 1, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Titles in Outbox'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 1, 2, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Distributions in Outbox'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 1, 3, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Titles Publishing in next 30 days'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 2, 1, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Titles Sent in last 30 days'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 2, 2, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Distributions in last 30 days'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 2, 3, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Assets Uploaded in last 30 days'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 3, 1, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Jobs with Errors in last 7 days'  
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 3, 2, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Distribution Failures in last 7 days'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 3, 3, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Cloud Approved Titles failing Verification'  
  
  SELECT @v_configobjectkey = configobjectkey FROM qsiconfigobjects WHERE configobjectid = 'shHomeMisc2'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 1, 1, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Idea Phase Acquisitions'
    
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 1, 2, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Acquisitions Currently Active'

  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 1, 3, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Acquisitions Approved in last 30 days'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 2, 1, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Contracts Signed in last 30 days'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 2, 2, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Contracts Pending'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 2, 3, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Transmittal P&L Approved in last 30 days'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 3, 1, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Active Titles'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 3, 2, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Titles Publishing in next 30 days'
  
  INSERT INTO miscitemsection 
    (misckey, configobjectkey, usageclasscode, itemtypecode, columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
  SELECT 
    misckey, @v_configobjectkey, 0, 0, 3, 3, 0, 'QSIADMIN', getdate()
  FROM bookmiscitems
  WHERE miscname = 'Total Gross Margin for Transmittals/last 30 days'  
  
END
go