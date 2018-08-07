DECLARE
  @v_max_code INT,
  @v_count  INT,
  @v_usageclass INT,
  @v_newkey INT
  
BEGIN          
    -- 'Proforma Created' to 'Proforma Pending'
	UPDATE gentables 
	SET datadesc = 'Proforma Pending', datadescshort = 'Proforma Pending', lastuserid = 'QSIDBA', lastmaintdate = getdate()
	WHERE tableid = 522 AND qsicode = 6

    -- 'Final Created' to 'Final Pending'
	UPDATE gentables 
	SET datadesc = 'Final Pending', datadescshort = 'Final Pending', lastuserid = 'QSIDBA', lastmaintdate = getdate()
	WHERE tableid = 522 AND qsicode = 8

    -- 'Proforma Sent' to 'Proforma Sent to Vendor'
	UPDATE gentables 
	SET datadesc = 'Proforma Sent to Vendor', datadescshort = 'Proforma Sent to Ven', lastuserid = 'QSIDBA', lastmaintdate = getdate()
	WHERE tableid = 522 AND qsicode = 7

    -- 'Final Sent' to 'Final Sent to Vendor'
	UPDATE gentables 
	SET datadesc = 'Final Sent to Vendor', datadescshort = 'Final Sent to Vendor', lastuserid = 'QSIDBA', lastmaintdate = getdate()
	WHERE tableid = 522 AND qsicode = 9    
	
 --   -- 'Sent to Vendor' to 'Sent to Vendor'
	--UPDATE gentables 
	--SET datadesc = 'Sent to Vendor ', datadescshort = 'Sent to Vendor', lastuserid = 'QSIDBA', lastmaintdate = getdate()
	--WHERE tableid = 522 AND qsicode = 13 	
	
	
	-- 'Amended; PO Report Pending'
    SELECT @v_max_code = MAX(datacode)
    FROM gentables
    WHERE tableid = 522
    
    IF @v_max_code IS NULL
      SET @v_max_code = 0
      
    SELECT @v_count = COUNT(*)
    FROM gentables
    WHERE tableid = 522 AND LOWER(datadesc) = 'amended; po report pending'
    
    IF @v_count = 0
    BEGIN
      SET @v_max_code = @v_max_code + 1
      
      INSERT INTO gentables
        (tableid, datacode, datadesc, deletestatus, tablemnemonic, externalcode, datadescshort,
        lastuserid, lastmaintdate, lockbyqsiind, lockbyeloquenceind, qsicode, sortorder)
      VALUES
        (522, @v_max_code, 'Amended; PO Report Pending', 'N', 'ProjectStatus', NULL, 'Amended PO Rep Pendi',
        'QSIDBA', getdate(), 1, 0, 14, 4)
    END
	ELSE BEGIN
	   UPDATE gentables SET qsicode = 14, sortorder = 4, lastuserid = 'QSIDBA', lastmaintdate = getdate() WHERE tableid = 522 AND LOWER(datadesc) = 'amended; po report pending'
	END   
	
	UPDATE gentables SET sortorder = 2 WHERE tableid = 522 AND qsicode = 6 -- Proforma Pending
	UPDATE gentables SET sortorder = 3 WHERE tableid = 522 AND qsicode = 7 -- Proforma Sent to Vendor
	UPDATE gentables SET sortorder = 4 WHERE tableid = 522 AND qsicode = 14 -- Amended; PO Report Pending
	UPDATE gentables SET sortorder = 5 WHERE tableid = 522 AND qsicode = 8 -- Final Pending
	UPDATE gentables SET sortorder = 6 WHERE tableid = 522 AND qsicode = 9 -- Final Sent to Vendor
	UPDATE gentables SET sortorder = 7 WHERE tableid = 522 AND qsicode = 13 -- Sent to Vendor 
	UPDATE gentables SET sortorder = 8 WHERE tableid = 522 AND qsicode = 11 -- Amended
	UPDATE gentables SET sortorder = 9 WHERE tableid = 522 AND qsicode = 10 -- Void
	UPDATE gentables SET sortorder = 10 WHERE tableid = 522 AND qsicode = 12 -- Cancelled Before Sending		
		
END
GO