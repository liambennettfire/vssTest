IF EXISTS (
	SELECT
		*
	FROM dbo.sysobjects
	WHERE id = OBJECT_ID('dbo.associatedtitles_trackertrigger')
	AND (type = 'P'
	OR type = 'TR'))
BEGIN
	PRINT 'DROP TRIGGER dbo.associatedtitles_trackertrigger'
	DROP TRIGGER dbo.associatedtitles_trackertrigger
	PRINT 'Creating TRIGGER dbo.associatedtitles_trackertrigger...'
END

GO

CREATE TRIGGER associatedtitles_trackertrigger
ON associatedtitles
FOR INSERT, UPDATE
AS

	DECLARE	@v_bookkey int,
			@v_lastuserid char(30),
			@v_lastmaintdate datetime,
			@v_insert_row_count int,
			@v_delete_row_count int,
			@v_TriggerActionID varchar(20),
			@v_tranacation_row_pointer int,
			@v_tranacation_row_total int,
			@v_TriggerID int,
			@v_TableID int,
			@v_TableName varchar(80)

	-- Get Table Name
	SET @v_TriggerID = @@procid

	SELECT @v_TableID = parent_id
	FROM sys.triggers
	WHERE object_id = @v_TriggerID

	SELECT @v_TableName = OBJECT_NAME(@v_TableID)

	SELECT @v_insert_row_count = COUNT(*)
	FROM INSERTED

	SELECT @v_delete_row_count = COUNT(*)
	FROM deleted

	-- get trigger action type
	IF @v_insert_row_count <> 0
		AND @v_delete_row_count = 0 --insert
	BEGIN
		SET @v_TriggerActionID = 'insert'
		SET @v_tranacation_row_total = @v_insert_row_count
	END
	IF @v_insert_row_count <> 0
		AND @v_delete_row_count <> 0 --update
	BEGIN
		SET @v_TriggerActionID = 'update'
		SET @v_tranacation_row_total = @v_insert_row_count
	END
	IF @v_insert_row_count = 0
		AND @v_delete_row_count <> 0 --delete
	BEGIN
		SET @v_TriggerActionID = 'delete'
		SET @v_tranacation_row_total = @v_delete_row_count
	END

	SET @v_tranacation_row_pointer = 1

	-- loop deals with multi row updates
	-- only one row at a time is handed to the stored procedure
	WHILE @v_tranacation_row_total >= @v_tranacation_row_pointer
	BEGIN

		SELECT	@v_bookkey = a.bookkey,
				@v_lastuserid = a.lastuserid,
				@v_lastmaintdate = a.lastmaintdate
		FROM (
			SELECT
				ROW_NUMBER() OVER (ORDER BY bookkey, lastmaintdate) AS transaction_rowid,
				*
			FROM INSERTED) AS a
		WHERE a.transaction_rowid = @v_tranacation_row_pointer

		-- Call the managing procedure for these triggers. 
		EXEC dbo.qutl_manage_book_triggers	@i_bookkey = @v_bookkey,
											@i_last_maint_date = @v_lastmaintdate,
											@i_lastUserId = @v_lastuserid

		SET @v_tranacation_row_pointer = @v_tranacation_row_pointer + 1
	END
GO