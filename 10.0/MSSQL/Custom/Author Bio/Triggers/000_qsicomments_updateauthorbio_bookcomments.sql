IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.qsicomments_updateauthorbio_bookcomments') AND type = 'TR')
	DROP TRIGGER dbo.qsicomments_updateauthorbio_bookcomments
GO

CREATE TRIGGER qsicomments_updateauthorbio_bookcomments ON qsicomments
AFTER INSERT, UPDATE, DELETE AS

BEGIN
  DECLARE @v_insert_row_count INT, 
		  @v_delete_row_count INT,
		  @v_commentkey			INT,
		  @v_bookkey			INT,
		  @v_printingkey		INT,
		  @v_commenttypecode	INT,
		  @v_commenttypesubcode INT,
		  @v_error_code         INT,
		  @v_error_desc         VARCHAR(2000),
		  @v_datacode_authorbio	INT
		  
	SET @v_insert_row_count = 0
	SET @v_delete_row_count = 0
		  
	SELECT @v_insert_row_count=count(*) FROM inserted
	SELECT @v_delete_row_count=count(*) FROM deleted
	
	IF @v_insert_row_count + @v_delete_row_count = 0 
		RETURN 		  

	IF @v_insert_row_count > 0 AND UPDATE (commenthtml)  BEGIN
		SELECT @v_commentkey = Inserted.commentkey,
			   @v_commenttypecode = Inserted.commenttypecode,
			   @v_commenttypesubcode = Inserted.commenttypesubcode
		FROM Inserted
    END
    ELSE IF @v_delete_row_count > 0 AND @v_insert_row_count = 0 BEGIN
		SELECT @v_commentkey = deleted.commentkey,
			   @v_commenttypecode = deleted.commenttypecode,
			   @v_commenttypesubcode = deleted.commenttypesubcode
		FROM deleted		
    END
    ELSE BEGIN
		RETURN
    END
    
    SELECT @v_datacode_authorbio = datacode FROM gentables WHERE tableid = 528 AND qsicode = 2
    
    IF @v_commenttypecode <> @v_datacode_authorbio 
		RETURN
    
	DECLARE crRelatedTitles CURSOR FOR
	SELECT distinct c.bookkey, c.printingkey
	FROM coretitleinfo c, bookauthor ba, bookdetail bd
	 WHERE ba.authorkey = @v_commentkey and
		   c.bookkey = ba.bookkey and
		   c.bookkey = bd.bookkey and 
		   c.printingkey  = 1 and 
		   ba.primaryind = 1 and
		   EXISTS(SELECT * FROM bookauthor WHERE bookkey = c.bookkey AND authorkey = @v_commentkey AND primaryind = 1)

	OPEN crRelatedTitles 

	FETCH NEXT FROM crRelatedTitles INTO @v_bookkey, @v_printingkey

	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
	
	 IF EXISTS (SELECT * FROM regenerateauthorbio WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey) BEGIN
		UPDATE regenerateauthorbio SET updated = getdate(), lastmaintdate = getdate(), lastuserid = 'TMM_Update_AuthorBio' WHERE bookkey = @v_bookkey AND printingkey = @v_printingkey
	 END
	 ELSE BEGIN	
		INSERT
			INTO regenerateauthorbio
				(
				id,
				bookkey,
				printingkey,
				created,
				updated,
				lastmaintdate,
				lastuserid
				)
			VALUES
				(
				newid(), -- id
				@v_bookkey, -- bookkey
				@v_printingkey, -- printingkey
				getdate(), -- created
				getdate(), -- updated
				getdate(), -- lastmaintdate
				'TMM_Update_AuthorBio' -- lastuserid
				)

		SELECT @v_error_code = @@ERROR, @v_error_desc = @@ROWCOUNT
		IF @v_error_code <> 0 BEGIN
			SET @v_error_code = -1
			SET @v_error_desc = 'Could not insert regenerateauthorbio: BookKey' + CONVERT(INT, @v_bookkey) 
		 END	
	  END				
		
	  FETCH NEXT FROM crRelatedTitles INTO @v_bookkey, @v_printingkey
	END /* WHILE FECTHING */

	CLOSE crRelatedTitles 
	DEALLOCATE crRelatedTitles	
END
GO