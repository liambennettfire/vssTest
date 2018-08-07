/******************************************************************************
**  Name: imp_300010026001
**  Desc: IKE Add/Replace Replaces ISBN
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_300010026001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_300010026001]
GO

CREATE PROCEDURE dbo.imp_300010026001 @i_batch INT
	,@i_row INT
	,@i_dmlkey BIGINT
	,@i_titlekeyset VARCHAR(500)
	,@i_contactkeyset VARCHAR(500)
	,@i_templatekey INT
	,@i_elementseq INT
	,@i_level INT
	,@i_userid VARCHAR(50)
	,@i_newtitleind INT
	,@i_newcontactind INT
	,@o_writehistoryind INT OUTPUT 
	
AS

/* Add/Replace Replaces ISBN */
BEGIN
	DECLARE @v_isbn VARCHAR(4000)
		,@v_isbn_org VARCHAR(4000)
		,@v_count INT
		,@v_errcode INT
		,@v_errmsg VARCHAR(4000)
		,@v_elementdesc VARCHAR(4000)
		,@v_elementkey BIGINT
		,@v_associationtypecode INT
		,@v_associationtypesubcode INT
		,@v_bookkey INT
		,@v_assoc_bookkey INT
		,@v_addlqualifier VARCHAR(4000)
		,@v_value1 VARCHAR(4000)
		,@v_value2 VARCHAR(4000)
		,@v_ReciprocalDataSubCode INT
		,@v_ReciprocalEAN13 VARCHAR(13)
		,@v_NewTitle VARCHAR(max)
		,@v_NewTitleWarning VARCHAR(max)
		,@v_NewAuthor VARCHAR(max)
		,@v_NewBisac VARCHAR(max)
		,@v_NewBisacWarning VARCHAR(max)
		,@v_NewBisacCode INT
		,@v_NewMedia VARCHAR(max)
		,@v_NewMediaWarning VARCHAR(max)
		,@v_NewMediaCode INT
		,@v_NewFormat VARCHAR(max)
		,@v_NewFormatWarning VARCHAR(max)
		,@v_NewFormatCode INT
		,@v_NewPrice FLOAT
		,@v_NewPriceWarning VARCHAR(max)
		,@v_OrigTitle VARCHAR(max)
		,@v_OrigAuthor VARCHAR(max)
		,@v_OrigBisacCode INT
		,@v_OrigMediaCode INT
		,@v_OrigFormatCode INT
		,@v_OrigPrice FLOAT
		,@v_SortOrder INT
		,@DEBUG INT

	BEGIN
		SET @o_writehistoryind = 0
		SET @v_errcode = 1
		SET @v_errmsg = 'n/a'
		SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset, 1)
		SET @DEBUG=0

		--Get the Assoc. Book ISBN ... this comes from the batchdetail
		SELECT	@v_isbn = LTRIM(RTRIM(b.originalvalue))
				,@v_elementkey = b.elementkey
				,@v_elementdesc = elementdesc
				,@v_addlqualifier = td.addlqualifier
		FROM	imp_batch_detail b
				,imp_DML_elements d
				,imp_element_defs e
				,imp_template_detail td
		WHERE	b.batchkey = @i_batch
				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND d.dmlkey = @i_dmlkey
				AND d.elementkey = b.elementkey
				AND td.templatekey = @i_templatekey
				AND b.elementkey = td.elementkey

		--Get the Assoc. Book Title (if  present)
		SELECT	@v_NewTitle = LTRIM(RTRIM(b.originalvalue))
		FROM	imp_batch_detail b
		WHERE	b.batchkey = @i_batch
				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND b.elementkey = @v_elementkey + 200

		--Get the Assoc. Book Author (if  present)
		SELECT	@v_NewAuthor = LTRIM(RTRIM(b.originalvalue))
		FROM	imp_batch_detail b
		WHERE	b.batchkey = @i_batch
				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND b.elementkey = @v_elementkey + 300
			
		--Get the Assoc. Book BisacStatus (if  present)
		SELECT	@v_NewBisac = LTRIM(RTRIM(b.originalvalue))
				,@v_NewBisacCode = COALESCE(gt1.datacode,COALESCE(gt2.datacode,gt3.datacode))
		FROM	imp_batch_detail b
				LEFT JOIN gentables gt1 ON gt1.datadesc=b.originalvalue 
					AND gt1.tableid=314
				LEFT JOIN gentables gt2 ON gt2.eloquencefieldtag=b.originalvalue 
					AND gt2.tableid=314	
				LEFT JOIN gentables gt3 ON gt3.externalcode=b.originalvalue 
					AND gt3.tableid=314	
		WHERE	b.batchkey = @i_batch
				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND b.elementkey = @v_elementkey + 400
			
		--Get the Assoc. Book Media (if  present)
		SELECT	@v_NewMedia = LTRIM(RTRIM(b.originalvalue))
				,@v_NewMediaCode = COALESCE(gt1.datacode,COALESCE(gt2.datacode,gt3.datacode))
		FROM	imp_batch_detail b
				LEFT JOIN gentables gt1 ON gt1.datadesc=b.originalvalue 
					AND gt1.tableid=312
				LEFT JOIN gentables gt2 ON gt2.eloquencefieldtag=b.originalvalue 
					AND gt2.tableid=312	
				LEFT JOIN gentables gt3 ON gt3.externalcode=b.originalvalue 
					AND gt2.tableid=312	
		WHERE	b.batchkey = @i_batch
				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND b.elementkey = @v_elementkey + 500

		--Get the Assoc. Book Format (if  present)
		SELECT	@v_NewFormat = LTRIM(RTRIM(b.originalvalue))
				,@v_NewFormatCode = COALESCE(gt1.datacode,COALESCE(gt2.datacode,gt3.datacode))
		FROM	imp_batch_detail b
				LEFT JOIN subgentables gt1 ON gt1.datadesc=b.originalvalue 
					AND gt1.tableid=312 AND gt1.DATACODE = @v_NewMedia
				LEFT JOIN subgentables gt2 ON gt2.eloquencefieldtag=b.originalvalue 
					AND gt2.tableid=312 AND gt2.DATACODE = @v_NewMedia	
				LEFT JOIN subgentables gt3 ON gt3.externalcode=b.originalvalue 
					AND gt3.tableid=312 AND gt3.DATACODE = @v_NewMedia	
		WHERE	b.batchkey = @i_batch
				AND b.row_id = @i_row
				AND b.elementseq = @i_elementseq
				AND b.elementkey = @v_elementkey + 600
				
		--Get the Assoc. Book Price (if  present)
		SELECT @v_NewPrice = LTRIM(RTRIM(b.originalvalue))
		FROM imp_batch_detail b
		WHERE b.batchkey = @i_batch
			AND b.row_id = @i_row
			AND b.elementseq = @i_elementseq
			AND b.elementkey = @v_elementkey + 700						

		
		IF @DEBUG <> 0 PRINT  '@v_elementkey  =  ' + coalesce(cast(@v_elementkey as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT  '@v_isbn  =  ' + coalesce(cast(@v_isbn as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT  '@v_NewTitle  =  ' + coalesce(cast(@v_NewTitle as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT  '@v_NewAuthor  =  ' + coalesce(cast(@v_NewAuthor as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT  '@v_NewBisac  =  ' + coalesce(cast(@v_NewBisac as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT  '@v_NewMedia  =  ' + coalesce(cast(@v_NewMedia as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT  '@v_NewFormat  =  ' + coalesce(cast(@v_NewFormat as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT  '@v_NewPrice  =  ' + coalesce(cast(@v_NewPrice as varchar(max)),'*NULL*') 

		IF @DEBUG <> 0 PRINT  '@v_NewMediaCode  =  ' + coalesce(cast(@v_NewMediaCode as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT  '@v_NewFormatCode  =  ' + coalesce(cast(@v_NewFormatCode as varchar(max)),'*NULL*') 
		IF @DEBUG <> 0 PRINT  '@v_NewBisacCode  =  ' + coalesce(cast(@v_NewBisacCode as varchar(max)),'*NULL*') 
		
		IF @v_NewPrice IS NULL SET @v_NewPriceWarning = 'Associated Title Price was not sent ... this field will not be updated'
		IF @v_NewFormatCode IS NULL SET @v_NewFormatWarning = 'Associated Title Format was not sent or does not correspond to a gentable value ... this field will not be updated'
		IF @v_NewMediaCode IS NULL SET @v_NewMediaWarning = 'Associated Title Media was not sent or does not correspond to a gentable value ... this field will not be updated'
		IF @v_NewBisacCode IS NULL SET @v_NewBisacWarning = 'Associated Title Bisac was not sent or does not correspond to a gentable value ... this field will not be updated'
		
		--Get the asociation codes ... this come from the additional qulaifier in the template
		SET @v_associationtypecode = dbo.resolve_keyset(@v_addlqualifier, 1)
		SET @v_associationtypesubcode = dbo.resolve_keyset(@v_addlqualifier, 2)

		--Get the Descriptive names for the asociation code
		SELECT @v_value1 = datadesc
		FROM gentables
		WHERE tableid = 440
			AND datacode = @v_associationtypecode

		--Get the Descriptive names for the asociation subcode
		SELECT @v_value2 = datadesc
		FROM subgentables
		WHERE tableid = 440
			AND datacode = @v_associationtypecode
			AND datasubcode = @v_associationtypesubcode

		SET @v_errmsg = 'Association: association type=' + coalesce(@v_value1, '*NULL*') + ' and association subtype=' + coalesce(@v_value2, '*NULL*')

		--See if the associated book is in the system already ... if it is get its bookkey
		SELECT @v_assoc_bookkey = bookkey
		FROM isbn
		WHERE ean13 = replace(@v_isbn, '-', '')

		--If not found then search again using the ISBN10 field instead of EAN13
		IF @v_assoc_bookkey IS NULL
			SELECT @v_assoc_bookkey = bookkey
			FROM ISBN
			WHERE ISBN10 = replace(@v_isbn, '-', '')

		--If still not found then this title does not exist in our system
		IF @v_assoc_bookkey IS NULL 
			BEGIN
				SET @v_assoc_bookkey = 0
			END ELSE BEGIN
				IF @DEBUG > 0 PRINT 'If this is NOT an external title then don''t insert denormalizd info'
				SET @v_NewTitle = null
				SET @v_NewAuthor = null
				SET @v_NewPrice = null
				SET @v_NewFormatCode = null
				SET @v_NewMediaCode = null
				SET @v_NewBisacCode = null		
			END 

		--Now see if the main title (@v_bookkey) is already linked to an associated title with the same isbn and same codes ... if found then return
		SELECT @v_count = count(*)
		FROM associatedtitles
		WHERE bookkey = @v_bookkey
			AND associationtypecode = @v_associationtypecode
			AND associationtypesubcode = @v_associationtypesubcode				
			AND ((isbn=@v_isbn and @v_assoc_bookkey=0) OR (associatetitlebookkey = @v_assoc_bookkey and @v_assoc_bookkey<>0))
		
		IF @DEBUG > 0 PRINT char(13)+char(10)
		IF @DEBUG > 0 PRINT '@v_errmsg = ' + coalesce(cast(@v_errmsg as varchar(max)),'*NULL*')
		IF @DEBUG > 0 PRINT '@v_bookkey = ' + coalesce(cast(@v_bookkey as varchar(max)),'*NULL*')
		IF @DEBUG > 0 PRINT '@v_assoc_bookkey = ' + coalesce(cast(@v_assoc_bookkey as varchar(max)),'*NULL*')
		IF @DEBUG > 0 PRINT '@v_isbn = ' + coalesce(cast(@v_isbn as varchar(max)),'*NULL*')
		IF @DEBUG > 0 PRINT '@v_count = ' + coalesce(cast(@v_count as varchar(max)),'*NULL*')
		IF @DEBUG > 0 PRINT '@v_associationtypecode = ' + coalesce(cast(@v_associationtypecode as varchar(max)),'*NULL*')
		IF @DEBUG > 0 PRINT '@v_associationtypesubcode = ' + coalesce(cast(@v_associationtypesubcode as varchar(max)),'*NULL*')
		
		IF @v_count > 0
		BEGIN
			--This combination of @v_bookkey + @v_assoc_bookkey + @v_associationtypecode & @v_associationtypesubcode exists ...
			IF @v_assoc_bookkey>0
			BEGIN
				-- ... if this is an internal assoced title then we're all set and can return
				SET @v_errmsg = @v_errmsg + ' unchanged'
				IF @DEBUG > 0 PRINT @v_errmsg
				RETURN
				
			END ELSE BEGIN
				-- ... if this is an external assoced title then we may need to update additional info fields
				SELECT	@v_OrigTitle=title
						,@v_OrigAuthor=authorname
						,@v_OrigPrice=price
						,@v_OrigFormatCode=mediatypesubcode
						,@v_OrigMediaCode=mediatypecode
						,@v_OrigBisacCode=bisacstatus
				FROM	associatedtitles
				WHERE	bookkey = @v_bookkey
						AND associationtypecode = @v_associationtypecode
						AND associationtypesubcode = @v_associationtypesubcode				
						AND isbn=@v_isbn 
					
				BEGIN
					IF @DEBUG > 0 PRINT 'START UPDATE'

					UPDATE associatedtitles
					SET title=coalesce(@v_NewTitle,@v_OrigTitle)
						,authorname=coalesce(@v_NewAuthor,@v_OrigAuthor)
						,bisacstatus=coalesce(@v_NewBisacCode,@v_OrigBisacCode)
						,mediatypecode=coalesce(@v_NewMediaCode,@v_OrigMediaCode)
						,mediatypesubcode=coalesce(@v_NewFormatCode,@v_OrigFormatCode)
						,price=coalesce(@v_NewPrice,@v_OrigPrice)
						,lastuserid = @i_userid
						,lastmaintdate = getdate()
						,releasetoeloquenceind=1
					WHERE bookkey = @v_bookkey
						AND associationtypecode = @v_associationtypecode
						AND associationtypesubcode = @v_associationtypesubcode				
						AND isbn=@v_isbn 

					IF @DEBUG > 0 PRINT 'END UPDATE'
					SET @o_writehistoryind = 1
					SET @v_errmsg = @v_errmsg + ' updated'						
				END
				EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_errmsg,@i_level,3
				IF @v_NewPriceWarning IS NOT NULL EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_NewPriceWarning,2,3
				IF @v_NewFormatWarning IS NOT NULL EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_NewFormatWarning,2,3
				IF @v_NewMediaWarning IS NOT NULL EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_NewMediaWarning,2,3
				IF @v_NewBisacWarning IS NOT NULL EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_NewBisacWarning,2,3
				RETURN		
			END
		END

		--There is no association between this main title (@v_bookkey) and @v_assoc_bookkey with the codes @v_associationtypecode & @v_associationtypesubcode
		-- ... Now look to see if there is an association between this main title (@v_bookkey) and any other title with the codes @v_associationtypecode & @v_associationtypesubcode
		SELECT @v_count = count(*), @v_SortOrder=max(sortorder)+1
		FROM associatedtitles
		WHERE bookkey = @v_bookkey
			AND associationtypecode = @v_associationtypecode
			AND associationtypesubcode = @v_associationtypesubcode		
		
		if @v_SortOrder is null SET @v_SortOrder=1
		--If there is an existing similar (codes) relationship between the main title and another title then the sort order needs be incremented as not not break the inde	

		--1	ISBN-10
		--2	ISBN-13/EAN    
		IF @DEBUG > 0 PRINT 'START INSERT'
		INSERT INTO associatedtitles (
			bookkey
			,releasetoeloquenceind
			,associationtypecode
			,associationtypesubcode
			,associatetitlebookkey
			,sortorder
			,isbn
			,lastuserid
			,lastmaintdate
			,title
			,authorname
			,bisacstatus
			,mediatypecode
			,mediatypesubcode
			,price
			,productidtype
			)
		VALUES (
			@v_bookkey
			,1
			,coalesce(@v_associationtypecode,0)
			,coalesce(@v_associationtypesubcode,0)
			,@v_assoc_bookkey
			,@v_SortOrder
			,@v_isbn
			,@i_userid
			,getdate()
			,@v_NewTitle
			,@v_NewAuthor
			,@v_NewBisacCode
			,@v_NewMediaCode
			,@v_NewFormatCode
			,@v_NewPrice
			, CASE 
					WHEN (LEN(@v_isbn) = 10 AND charindex('-', @v_isbn) = 0) THEN 2
					WHEN (LEN(@v_isbn) = 13 AND charindex('-', @v_isbn) = 0) THEN 2
					WHEN (LEN(@v_isbn) = 13 AND charindex('-', @v_isbn) <> 0) THEN 1
					WHEN (LEN(@v_isbn) = 17 AND charindex('-', @v_isbn) <> 0) THEN 2
					ELSE 0 END
			)

		SET @o_writehistoryind = 1
		SET @v_errmsg = @v_errmsg + ' added'
		IF @DEBUG > 0 PRINT 'END INSERT'

		-- See if there needs to be a reciprocal insert
		IF @v_assoc_bookkey <> 0
		BEGIN
			SELECT @v_ReciprocalDataSubCode = sgt2.datasubcode
			FROM subgentables AS sgt1
			INNER JOIN subgentables AS sgt2 ON sgt1.numericdesc1 = sgt2.bisacdatacode
			WHERE sgt1.tableid = 440
				AND sgt2.tableid = 440
				AND sgt1.datacode = @v_associationtypecode
				AND sgt1.datasubcode = @v_associationtypesubcode

			SELECT @v_count = count(*)
			FROM associatedtitles
			WHERE bookkey = @v_assoc_bookkey
				AND associationtypecode = 4
				AND associationtypesubcode = @v_ReciprocalDataSubCode

			SELECT @v_ReciprocalEAN13 = ean13
			FROM isbn
			WHERE bookkey = @v_assoc_bookkey

			IF @v_count = 1
			BEGIN
				UPDATE associatedtitles
				SET isbn = @v_ReciprocalEAN13
					,associatetitlebookkey = @v_bookkey
					,lastuserid = @i_userid
					,lastmaintdate = getdate()
				WHERE bookkey = @v_assoc_bookkey
					AND associationtypecode = @v_associationtypecode
					AND associationtypesubcode = @v_ReciprocalDataSubCode
			END
			ELSE
			BEGIN
				INSERT INTO associatedtitles (
					bookkey
					,releasetoeloquenceind
					,associationtypecode
					,associationtypesubcode
					,associatetitlebookkey
					,sortorder
					,isbn
					,lastuserid
					,lastmaintdate
					,productidtype
					)
				VALUES (
					@v_assoc_bookkey
					,1
					,4
					,@v_ReciprocalDataSubCode
					,@v_bookkey
					,1
					,@v_ReciprocalEAN13
					,@i_userid
					,getdate()
					,2
					)
			END
		END

		IF @v_errcode < 2
		BEGIN
			EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_errmsg,@i_level,3
		END
		IF @v_NewPriceWarning IS NOT NULL EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_NewPriceWarning,2,3
		IF @v_NewFormatWarning IS NOT NULL EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_NewFormatWarning,2,3
		IF @v_NewMediaWarning IS NOT NULL EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_NewMediaWarning,2,3
		IF @v_NewBisacWarning IS NOT NULL EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq,@i_dmlkey,@v_NewBisacWarning,2,3		
	END
END
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_300010026001]
	TO PUBLIC
GO