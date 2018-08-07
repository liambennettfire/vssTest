DECLARE @v_datacode		INT,
	    @v_datasubcode	INT


  DECLARE conv_cursor CURSOR FOR
	SELECT s.datacode, s.datasubcode
	FROM subgentables s INNER JOIN taqspecadmin t
	ON s.datacode = t.itemcategorycode AND s.datasubcode = t.itemcode 
	WHERE s.tableid = 616
	
	OPEN conv_cursor
	
	FETCH conv_cursor
	INTO @v_datacode, @v_datasubcode
  
  WHILE (@@FETCH_STATUS = 0)
  BEGIN
		--IF EXISTS(SELECT * FROM taqscaleadminspecitem WHERE COALESCE(messagetypecode, 0) = 0 AND itemcode = @v_datacode AND itemcategorycode = @v_datasubcode) BEGIN
		--	UPDATE subgentables SET subgen3ind = 1, subgen4ind = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate() WHERE datacode = @v_datacode AND datasubcode = @v_datasubcode AND tableid = 616
		--END
		--ELSE 
		
		IF NOT EXISTS(SELECT * FROM taqprojectscaledetails WHERE itemcode = @v_datacode AND itemcategorycode = @v_datasubcode) AND NOT EXISTS(SELECT * FROM taqprojectscaleparameters  WHERE itemcode = @v_datacode AND itemcategorycode = @v_datasubcode) BEGIN
			UPDATE subgentables SET subgen3ind = 0, subgen4ind = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate()  WHERE datacode = @v_datacode AND datasubcode = @v_datasubcode AND tableid = 616
		END
		ELSE IF EXISTS(SELECT * FROM taqprojectscaledetails WHERE autoapplyind = 1  AND itemcode = @v_datacode AND itemcategorycode = @v_datasubcode) BEGIN
			UPDATE subgentables SET subgen3ind = 1, subgen4ind = 0, lastuserid = 'QSIDBA', lastmaintdate = getdate()  WHERE datacode = @v_datacode AND datasubcode = @v_datasubcode AND tableid = 616
		END
		ELSE BEGIN
			UPDATE subgentables SET subgen3ind = 1, subgen4ind = 1, lastuserid = 'QSIDBA', lastmaintdate = getdate()  WHERE datacode = @v_datacode AND datasubcode = @v_datasubcode AND tableid = 616
		END		
  
  		FETCH conv_cursor
		INTO @v_datacode, @v_datasubcode
  END
  
  CLOSE conv_cursor
DEALLOCATE conv_cursor