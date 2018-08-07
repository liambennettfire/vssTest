IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.bookauthor_updateauthorbio_bookcomments') AND type = 'TR')
	DROP TRIGGER dbo.bookauthor_updateauthorbio_bookcomments
GO

CREATE TRIGGER bookauthor_updateauthorbio_bookcomments ON bookauthor
AFTER INSERT, UPDATE, DELETE AS

BEGIN
  DECLARE @v_insert_row_count INT, 
		  @v_delete_row_count INT,
		  @v_commentkey			INT,
		  @v_bookkey			INT,
		  @v_printingkey		INT,
		  @v_authorkey			INT,
		  @v_authortypecode		INT,
		  @v_commenttypecode	INT,
		  @v_commenttypesubcode INT,
		  @v_error_code         INT,
		  @v_error_desc         VARCHAR(2000)
		  
	SET @v_insert_row_count = 0
	SET @v_delete_row_count = 0
		  
	SELECT @v_insert_row_count=count(*) FROM inserted
	SELECT @v_delete_row_count=count(*) FROM deleted
	
	IF @v_insert_row_count + @v_delete_row_count = 0 
		RETURN 		  

	IF @v_insert_row_count > 0 AND (UPDATE (primaryind) OR UPDATE(sortorder)) BEGIN
		SELECT @v_bookkey = Inserted.bookkey,
			   @v_authorkey = Inserted.authorkey,
			   @v_authortypecode = Inserted.authortypecode
		FROM Inserted
    END
    ELSE IF @v_delete_row_count > 0 AND @v_insert_row_count = 0 BEGIN
		SELECT @v_bookkey = deleted.bookkey,
			   @v_authorkey = deleted.authorkey,
			   @v_authortypecode = deleted.authortypecode
		FROM deleted		
    END
    ELSE BEGIN
		RETURN
    END
    
    SET @v_printingkey = 1
    
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
	 	SET @v_error_desc = 'Could not insert regenerateauthorbio: bookkey = ' + CONVERT(INT, @v_bookkey) + ' printingkey = ' + CONVERT(INT, @v_printingkey)
	  END
	END	     		
END
GO