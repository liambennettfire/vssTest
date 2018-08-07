DECLARE
  @v_count  INT,
  @v_misckey INT
  
BEGIN

  SELECT @v_count = COUNT(*)
  FROM bookmiscitems
  WHERE miscname = 'P&L Input Currency'
  
  IF @v_count > 0
  BEGIN
    SELECT @v_misckey = misckey 
    FROM bookmiscitems
    WHERE miscname = 'P&L Input Currency'
    
    INSERT INTO miscitemsection
      (misckey, configobjectkey, usageclasscode, itemtypecode, 
      columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, configobjectkey, (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 1), 3,
      2, 1, 0, 'QSIDBA', getdate()
    FROM qsiconfigobjects 
    WHERE itemtypecode = 3 AND configobjectid LIKE '%projectdetails%' 
    
    INSERT INTO miscitemsection
      (misckey, configobjectkey, usageclasscode, itemtypecode, 
      columnnumber, itemposition, updateind, lastuserid, lastmaintdate)
    SELECT
      @v_misckey, configobjectkey, (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 39), 3,
      2, 1, 0, 'QSIDBA', getdate()
    FROM qsiconfigobjects 
    WHERE itemtypecode = 3 AND configobjectid LIKE '%projectdetails%'
    
  END
  
END
go
