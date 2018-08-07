DECLARE
	@v_tableid INT,
	@v_qsicode	INT,
	@v_sortorder INT,
	@v_itemtype INT,
	@v_class INT,
	@o_datacode INT,
	@o_error_code INT,
	@o_error_desc varchar(2000)

--Create Printings from Title List--
SET @v_tableid = 543
SELECT @v_sortorder = MAX(COALESCE(sortorder, 0)) FROM gentables WHERE tableid = 543
SET @v_sortorder = COALESCE(@v_sortorder, 0) + 1
SET @v_qsicode = 21  --Create Printings from Title List

BEGIN TRAN JobTran
	SELECT @v_itemtype = datacode FROM gentables WHERE tableid = 550 AND qsicode = 13  --Job
	SELECT @v_class = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 35 --Title Job

	IF COALESCE(@v_itemtype, 0) <= 0 OR COALESCE(@v_class, 0) <= 0 BEGIN
	  SET @o_error_code = -1
	  PRINT @o_error_desc
	  ROLLBACK TRAN JobTran
	  RETURN
	END

	exec dbo.qutl_insert_gentable_value @v_tableid, 'QSIJOBTYPE', @v_qsicode, 'Create Printings from Title List', @v_sortorder, 1, @o_datacode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

	IF @o_error_code < 0 BEGIN
	  SET @o_error_code = -1
	  PRINT @o_error_desc
	  ROLLBACK TRAN JobTran
	  RETURN
	END
	
	UPDATE gentables SET gen1ind = 1 WHERE tableid = @v_tableid AND datacode = @o_datacode --Show Results in TMM
	
	UPDATE gentables_ext SET gentext1 = 'BOOK' WHERE tableid = @v_tableid AND datacode = @o_datacode  -- Show in the job window

	EXEC qutl_insert_gentablesitemtype @v_tableid, @o_datacode, 0, 0, @v_itemtype, @v_class, @o_error_code OUTPUT, @o_error_desc OUTPUT
	
	IF @o_error_code < 0 BEGIN
		SET @o_error_code = -1
		PRINT @o_error_desc
		ROLLBACK TRAN JobTran
		RETURN
	END	
	
	COMMIT TRAN JobTran
GO