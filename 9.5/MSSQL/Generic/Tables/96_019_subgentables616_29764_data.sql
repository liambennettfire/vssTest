/******************************************************************************
**  Name: 96_019_subgentables616_29764_data
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  08/22/2016   UK          Case 29764 - Task 002
*******************************************************************************/

DECLARE
  @v_count INT,
  @v_datacode INT,
  @v_datasubcode INT
  
BEGIN

  -- LOCK spec items with qsicode
  UPDATE subgentables
  SET lockbyqsiind = 1
  WHERE tableid = 616 AND qsicode > 0

  -- Set qsicode on Bind component's spec item: Spine Size 
  IF EXISTS(SELECT * FROM gentables WHERE tableid = 616 AND datadesc = 'Bind') BEGIN
	SELECT @v_datacode = datacode 
	FROM gentables 
	WHERE tableid = 616 AND datadesc = 'Bind'
  END
  ELSE IF EXISTS(SELECT * FROM gentables WHERE tableid = 616 AND datadesc = 'Binding') BEGIN
	SELECT TOP(1) @v_datacode = datacode 
	FROM gentables 
	WHERE tableid = 616 AND datadesc = 'Binding'	
  END
  ELSE BEGIN
	PRINT 'Unable to find Bind Componenet'
	RETURN
  END

  SELECT @v_count = COUNT(*)
  FROM subgentables
  WHERE tableid = 616 AND datacode = @v_datacode AND datadesc = 'Spine Size'
  
  IF @v_count > 0
  BEGIN
	SELECT @v_datasubcode = datasubcode
	FROM subgentables
	WHERE tableid = 616 AND datacode = @v_datacode AND datadesc = 'Spine Size'
	
	UPDATE subgentables
	SET qsicode = 7
	WHERE tableid = 616 AND datacode = @v_datacode AND datasubcode = @v_datasubcode	
  END
  ELSE
  BEGIN
    SELECT @v_datasubcode = COALESCE(MAX(datasubcode),0) + 1
    FROM subgentables
    WHERE tableid = 616 AND datacode = @v_datacode
    
    INSERT INTO subgentables
      (tableid, datacode, datasubcode, datadesc, deletestatus, tablemnemonic, lastuserid, lastmaintdate,
      acceptedbyeloquenceind, exporteloquenceind, lockbyqsiind, lockbyeloquenceind, qsicode, subgen3ind, subgen4ind)
    VALUES
      (616, @v_datacode, @v_datasubcode, 'Spine Size', 'N', 'SPECS', 'FIREBRAND', GETDATE(),
      0, 0, 1, 0, 7, 1, 1)
  END
  
END
go
