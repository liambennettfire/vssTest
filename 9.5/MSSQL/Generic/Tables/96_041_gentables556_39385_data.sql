DECLARE
	@v_Eloquence_Verification_Sortorder INT,
	@v_First_Pass_Verification_Sortorder INT
	
	SET @v_Eloquence_Verification_Sortorder = NULL
	SET @v_First_Pass_Verification_Sortorder = NULL
	
	SELECT @v_Eloquence_Verification_Sortorder = sortorder 
	FROM gentables 
	WHERE tableid = 556 AND qsicode = 3

	SELECT @v_First_Pass_Verification_Sortorder = sortorder 
	FROM gentables 
	WHERE tableid = 556 AND qsicode = 4	
	
	IF COALESCE(@v_Eloquence_Verification_Sortorder, 999) < COALESCE(@v_First_Pass_Verification_Sortorder, 999) BEGIN
		UPDATE gentables SET sortorder = @v_First_Pass_Verification_Sortorder WHERE tableid = 556 and qsicode = 3 -- Eloquence Verification
		UPDATE gentables SET sortorder = @v_Eloquence_Verification_Sortorder WHERE tableid = 556 and qsicode = 4  -- First Pass Verification		
	END
	
GO	