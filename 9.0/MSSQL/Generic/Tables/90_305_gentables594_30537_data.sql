DECLARE
	 @v_datacode INT
	 
SELECT @v_datacode = datacode FROM gentables WHERE tableid = 594 AND qsicode = 13 	 	

UPDATE gentables_ext SET gen3ind = 0 WHERE tableid = 594 AND datacode <> @v_datacode
UPDATE gentables_ext SET gen3ind = 1 WHERE tableid = 594 AND datacode = @v_datacode

GO