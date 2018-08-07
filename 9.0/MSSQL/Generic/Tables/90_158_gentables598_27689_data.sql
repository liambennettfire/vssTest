DECLARE
  @v_max_code INT,
  @v_max_sortorder INT,  
  @v_count  INT

BEGIN

  SELECT @v_max_code = MAX(datacode)
  FROM gentables
  WHERE tableid = 598
  
  SELECT @v_max_sortorder = MAX(sortorder)
  FROM gentables
  WHERE tableid = 598  
  
  SELECT @v_count = COUNT(*)
  FROM gentables
  WHERE tableid = 598 AND qsicode = 25
  
  IF @v_count = 0
  BEGIN  
    SET @v_max_code = @v_max_code + 1
    SET @v_max_sortorder = @v_max_sortorder + 1  
      
	INSERT INTO gentables
	  (tableid, datacode, datadesc, deletestatus, sortorder, tablemnemonic, datadescshort, lastuserid, lastmaintdate,
	  gen1ind, gen2ind, acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, alternatedesc1, qsicode)
	VALUES
	  (598, @v_max_code, 'Production Specification', 'N', @v_max_sortorder, 'CopyProjectDataGroups', 'Production Spec', 'QSIDBA', getdate(),
	  0, 1, 0, 0, 1, 0, 'Copy the Specifications.', 25)
  END
END
go