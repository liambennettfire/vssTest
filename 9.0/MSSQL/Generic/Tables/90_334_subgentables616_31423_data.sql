DECLARE
	@v_datacode INT,
	@v_datasubcode INT

	SELECT @v_datacode = datacode, @v_datasubcode= datasubcode 
	FROM subgentables  
	WHERE tableid = 616 AND qsicode = 6

   -- On the web - Specification and Scale Item Administration, Component/Process 'Summary', Item 'Production Qty' check 'Use in Scales' and uncheck 'Show in Specs'.
	UPDATE subgentables 
	SET subgen3ind = 1, subgen4ind = 0 
	WHERE tableid = 616 AND qsicode = 6
		
  -- User Tables (gentables 616) Specification and Scale Items, Summary, Production Qty - remove all item type filtering.
	DELETE FROM gentablesitemtype 
	WHERE tableid = 616 AND datacode = @v_datacode AND datasubcode = @v_datasubcode
	
GO	