DECLARE
  @v_datacode INT,
  @v_count  INT,
  @v_newkey	INT

BEGIN
 -- Create Project Relationships for Printings tab on PO Reports
   SELECT @v_datacode = COALESCE(MAX(datacode),0) + 1
  FROM gentables
  WHERE tableid = 582

  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 582 AND qsicode = 29 -- Printings (for PO Reports)
  
  IF @v_count = 0
  BEGIN

   INSERT INTO gentables
    (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, alternatedesc1, qsicode)
  VALUES
    (582, @v_datacode, 'Printing (for PO Reports)', 'N', 'ProjectRelationship', 'Printing (PO RPT)', 'QSIDBA', getdate(),
    0, 0, 1, 0, 'Printings', 29)
   SET @v_datacode = @v_datacode + 1
   END

  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 582 AND qsicode = 30 -- PO Reports (for Printings)

  IF @v_count = 0
  BEGIN
    INSERT INTO gentables
    (tableid, datacode, datadesc, deletestatus, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
    acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, alternatedesc1, qsicode)
    VALUES
    (582, @v_datacode, 'PO Reports (for Printings)', 'N', 'ProjectRelationship', 'PO RPT (Printings)', 'QSIDBA', getdate(),
    0, 0, 1, 0, 'PO Reports', 30)
    SET @v_datacode = @v_datacode + 1
   END
  --Change the existing PO Reports realtoinship to be specific for Purchase Orders
  UPDATE gentables set datadesc = 'PO Reports (for Purchase Orders)',datadescshort = 'PO Reports (PO)', alternatedesc1 = 'PO Reports' where tableid = 582 and qsicode = 28 -- PO Reports (for Purchase Orders)
  
  --Change the existing relationships from conversion to the new ones 
  UPDATE taqprojectrelationship 
  SET relationshipcode1 = (SELECT datacode FROM gentables WHERE (tableid = 582) AND (qsicode = 29)), 
      relationshipcode2 = (SELECT datacode FROM gentables WHERE (tableid = 582) AND (qsicode = 30))
  WHERE  relationshipcode1 = (SELECT datacode FROM gentables WHERE (tableid = 582) AND (qsicode = 25)) 
    AND  relationshipcode2 = (SELECT datacode FROM gentables WHERE (tableid = 582) AND (qsicode = 28))

END
go
