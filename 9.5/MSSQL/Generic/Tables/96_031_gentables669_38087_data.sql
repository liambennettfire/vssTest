DECLARE
	@v_tableid INT,
	@v_qsicode	INT,
	@v_sortorder INT,
	@o_datacode INT,
	@o_datasubcode INT,
	@o_error_code INT,
	@o_error_desc varchar(2000)

--Create Printings from Title List Web Process--
SET @v_tableid = 669
SELECT @v_sortorder = MAX(COALESCE(sortorder, 0)) FROM gentables WHERE tableid = 669
SET @v_sortorder = COALESCE(@v_sortorder, 0) + 1
SET @v_qsicode = 1  --Create Printings from Title List

BEGIN TRAN JobTran

	exec dbo.qutl_insert_gentable_value @v_tableid, 'TMWPROC', @v_qsicode, 'Create Printings from Title List', @v_sortorder, 1, @o_datacode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

	IF @o_error_code < 0 BEGIN
	  SET @o_error_code = -1
	  PRINT @o_error_desc
	  ROLLBACK TRAN JobTran
	  RETURN
	END
	
	UPDATE gentables SET gen1ind = 1 WHERE tableid = @v_tableid AND datacode = @o_datacode --Show Results in TMM
	
	UPDATE gentables_ext SET gentext2 = 'qutl_create_printings_webprocess_from_titlelist' WHERE tableid = @v_tableid AND datacode = @o_datacode  -- Show in the job window
	
	IF @o_error_code < 0 BEGIN
		SET @o_error_code = -1
		PRINT @o_error_desc
		ROLLBACK TRAN JobTran
		RETURN
	END

	exec dbo.qutl_insert_subgentable_value @v_tableid, @o_datacode, 'TMWPROC', NULL, 'qsijobkey', NULL, 1, @o_datasubcode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
	IF @o_error_code < 0 BEGIN
		SET @o_error_code = -1
		PRINT @o_error_desc
		ROLLBACK TRAN JobTran
		RETURN
	END
	exec dbo.qutl_insert_subgentable_value @v_tableid, @o_datacode, 'TMWPROC', NULL, 'qsibatchkey', NULL, 1, @o_datasubcode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
	IF @o_error_code < 0 BEGIN
		SET @o_error_code = -1
		PRINT @o_error_desc
		ROLLBACK TRAN JobTran
		RETURN
	END
	exec dbo.qutl_insert_subgentable_value @v_tableid, @o_datacode, 'TMWPROC', NULL, 'bookkey', NULL, 1, @o_datasubcode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
	IF @o_error_code < 0 BEGIN
		SET @o_error_code = -1
		PRINT @o_error_desc
		ROLLBACK TRAN JobTran
		RETURN
	END
	exec dbo.qutl_insert_subgentable_value @v_tableid, @o_datacode, 'TMWPROC', NULL, 'userkey', NULL, 1, @o_datasubcode OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT
	IF @o_error_code < 0 BEGIN
		SET @o_error_code = -1
		PRINT @o_error_desc
		ROLLBACK TRAN JobTran
		RETURN
	END

	COMMIT TRAN JobTran
GO