/******* Users Usage Class Setup for Purchase Orders for Users with All Access *******/
BEGIN
DECLARE
  @v_itemtypecode INT,
  @v_usageclass INT
  
    -- Purchase Orders Type code:
  SELECT @v_itemtypecode = datacode
  FROM gentables
  WHERE tableid = 550 AND qsicode = 15  --Purchase Orders
  
  -- Purchase Orders:
  SELECT @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND datacode = @v_itemtypecode
  
  -- Purchase Orders
  INSERT into qsiusersusageclass (userkey,itemtypecode,usageclasscode,primaryind,lastuserid,lastmaintdate)
  SELECT u.userkey,g.datacode,coalesce(datasubcode,0),0,'QSIADMIN',getdate()
  FROM gentables g, subgentables s, qsiusers u
  WHERE g.tableid = s.tableid
  AND    g.datacode = s.datacode 
  AND    s.datacode = @v_itemtypecode
  AND    s.datasubcode = 1
  AND    g.tableid = 550 
  AND    u.securitygroupkey IN (SELECT securitygroupkey FROM securitygroup 
    WHERE lower(securitygroupname) = 'all access')
    
  -- Proforma PO Report
  INSERT into qsiusersusageclass (userkey,itemtypecode,usageclasscode,primaryind,lastuserid,lastmaintdate)
  SELECT u.userkey,g.datacode,coalesce(datasubcode,0),0,'QSIADMIN',getdate()
  FROM gentables g, subgentables s, qsiusers u
  WHERE g.tableid = s.tableid
  AND    g.datacode = s.datacode 
  AND    s.datacode = @v_itemtypecode
  AND    s.datasubcode = 2
  AND    g.tableid = 550 
  AND    u.securitygroupkey IN (SELECT securitygroupkey FROM securitygroup 
    WHERE lower(securitygroupname) = 'all access')
    
 -- Final PO Report
 INSERT into qsiusersusageclass (userkey,itemtypecode,usageclasscode,primaryind,lastuserid,lastmaintdate)
  SELECT u.userkey,g.datacode,coalesce(datasubcode,0),0,'QSIADMIN',getdate()
  FROM gentables g, subgentables s, qsiusers u
  WHERE g.tableid = s.tableid
  AND    g.datacode = s.datacode 
  AND    s.datacode = @v_itemtypecode
  AND    s.datasubcode = 3
  AND    g.tableid = 550 
  AND    u.securitygroupkey IN (SELECT securitygroupkey FROM securitygroup 
    WHERE lower(securitygroupname) = 'all access')
END
go





