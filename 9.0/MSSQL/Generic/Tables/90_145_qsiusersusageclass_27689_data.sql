/******* Users Usage Class Setup for Specification Template for Users with All Access *******/
BEGIN
DECLARE
  @v_itemtypecode INT,
  @v_usageclass INT
  
  -- Specification Template:
  SELECT @v_itemtypecode = datacode, @v_usageclass = datasubcode
  FROM subgentables
  WHERE tableid = 550 AND qsicode = 44
  
  INSERT into qsiusersusageclass (userkey,itemtypecode,usageclasscode,primaryind,lastuserid,lastmaintdate)
  SELECT u.userkey,g.datacode,coalesce(datasubcode,0),0,'QSIADMIN',getdate()
  FROM gentables g, subgentables s, qsiusers u
  WHERE g.tableid = s.tableid
  AND    g.datacode = s.datacode 
  AND    s.datacode = @v_itemtypecode
  AND    s.datasubcode = @v_usageclass
  AND    g.tableid = 550 
  AND    u.securitygroupkey IN (SELECT securitygroupkey FROM securitygroup 
    WHERE lower(securitygroupname) = 'all access')
END
go


