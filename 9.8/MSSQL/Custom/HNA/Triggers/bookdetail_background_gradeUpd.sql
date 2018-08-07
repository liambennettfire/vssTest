IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.bookdetail_background_gradeUpd') AND type = 'TR')
	DROP TRIGGER dbo.bookdetail_background_gradeUpd
GO

CREATE TRIGGER [dbo].[bookdetail_background_gradeUpd] ON [dbo].[bookdetail]
FOR UPDATE AS 

DECLARE 
	@v_bookkey INT,
    @v_userid  VARCHAR(100),
    @v_error_desc VARCHAR(2000),
    @v_error_code INT,
	@v_newKey INT,
	@v_jobTypeCode INT,
	@v_lastUserID VARCHAR(30)

SET NOCOUNT ON;

IF (UPDATE(agelow) OR UPDATE(agehigh) OR UPDATE(agelowupind) OR UPDATE(agehighupind))
BEGIN
  /*  Get the bookkey that is being inserted or updated. */
	SELECT 
		@v_bookkey = inserted.bookkey, 
		@v_userid = lastuserid 
	FROM 
		inserted

	SET @v_jobTypeCode = (SELECT gen.dataCode FROM gentables gen WHERE gen.tableID = 543 AND gen.datadesc = 'Grade range update')
	SET @v_lastUserID = 'GradeRangeProcess'

	EXEC dbo.next_generic_key @v_userid, @v_newKey OUTPUT, @v_error_desc OUTPUT, @v_error_code OUTPUT
	IF @v_error_code = -1 
		BEGIN
			print @v_error_desc
			return
		END 

    BEGIN
		INSERT INTO backgroundprocess(backgroundprocesskey,jobtypecode,storedprocname,key1,reqforgetprodind,lastUserID,lastMaintDate)
		VALUES(@v_newKey,@v_jobTypeCode,'dbo.hna_gradeRangeUpdate',@v_bookkey,1,@v_userid,GETDATE())


    IF @v_error_code = -1 
	BEGIN
        print @v_error_desc
        return
    END 
    END
END
