IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trgr_UpdateBookEDIStatusForCitationCopyChange]'))
DROP TRIGGER [dbo].[trgr_UpdateBookEDIStatusForCitationCopyChange]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		marcus
-- Create date: 4.23.2014
-- Description:	Trigger to Update BookEDIStatus
-- =============================================
CREATE TRIGGER [dbo].[trgr_UpdateBookEDIStatusForCitationCopyChange] 
   ON  [dbo].[qsicomments] 
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_bookkey integer
	DECLARE @v_printingkey integer
	DECLARE @v_userid varchar(30)
	DECLARE @v_error_code integer
	DECLARE @v_error_desc varchar(2000) 
	
	SET @v_printingkey=1
	SET @v_userid ='sysCitationTrigger'

	DECLARE UpsertCursor CURSOR FOR 
	SELECT citation.BookKey
	FROM inserted
	INNER JOIN citation on citation.citationkey=inserted.commentkey
	WHERE citation.releasetoeloquenceind=1

	OPEN UpsertCursor

	FETCH NEXT FROM UpsertCursor 
	INTO @v_bookkey

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC dbo.qtitle_update_bookedistatus 
			@v_bookkey 
			,@v_printingkey 
			,@v_userid 
			,@v_error_code output
			,@v_error_desc output
	
		FETCH NEXT FROM UpsertCursor 
		INTO @v_bookkey
	END 
	CLOSE UpsertCursor;
	DEALLOCATE UpsertCursor;
END

GO


