DECLARE @v_copygroup_datacode INT

SET @v_copygroup_datacode = NULL

SELECT @v_copygroup_datacode = datacode FROM gentables WHERE tableid=592 AND qsicode=14

IF EXISTS (SELECT * FROM gentablesitemtype WHERE tableid =  592 AND datacode = @v_copygroup_datacode AND itemtypecode = 1)
BEGIN
	DELETE FROM gentablesitemtype
         WHERE tableid = 592 
          AND datacode = @v_copygroup_datacode
          AND itemtypecode = 1
END





