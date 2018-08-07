IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.core_bookauthor_delete') AND type = 'TR')
	DROP TRIGGER dbo.core_bookauthor_delete
GO

CREATE TRIGGER core_bookauthor_delete ON bookauthor
FOR DELETE AS

DECLARE @v_bookkey 			INT,
	@v_printingkey			INT,
	@v_authorkey 			INT,
	@v_authorname			VARCHAR(150),
	@v_illustratorname		VARCHAR(150)

DECLARE bookauthor_cur CURSOR FOR
SELECT d.authorkey,
       d.bookkey
FROM deleted d

OPEN bookauthor_cur

FETCH NEXT FROM bookauthor_cur 
INTO @v_authorkey,
	@v_bookkey

WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN

	/*** Check if row exists on coretitleinfo for this bookkey, printingkey 0 ***/
	/*EXECUTE CoreTitleInfo_Verify_Row @v_bookkey, 0, 1*/

	/*** Get author and illustrator names ***/
	EXEC CoreTitleInfo_get_author_illus_name @v_bookkey, @v_authorname OUTPUT, @v_illustratorname OUTPUT

	/*** update coretitleinfo ***/
	UPDATE coretitleinfo
	SET authorname=@v_authorname,
	    illustratorname=@v_illustratorname
	WHERE bookkey = @v_bookkey

	FETCH NEXT FROM bookauthor_cur 
	INTO @v_authorkey,
		@v_bookkey

END

CLOSE bookauthor_cur
DEALLOCATE bookauthor_cur

GO


