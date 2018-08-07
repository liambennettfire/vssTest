IF exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[SWAG_UpdateTaskDate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[SWAG_UpdateTaskDate]
GO

CREATE PROCEDURE [dbo].[SWAG_UpdateTaskDate] 
  @i_request nvarchar(max),
  @o_return nvarchar(max) output
AS

DECLARE 
   @v_count   int,
   @v_errcode   int,
   @v_debug   int,
   @v_datacode   int,
   @v_alternatedesc2 varchar(200),
   @v_errmsg    varchar(max),
   @v_userid    varchar(30),
   @v_userkey   int,
   @v_tag       varchar(50),
   @v_tag_datacode int,
   @v_producttype	varchar(50),
   @v_reviseddate   datetime,
   @v_content   nvarchar(max),
   @v_return    nvarchar(max),
   @v_return_work    nvarchar(max),
   @v_errcode2   int,
   @v_errmsg2   varchar(max),
   @v_lowpri_errcode   int,
   @v_lowpri_errmsg   varchar(max)

DECLARE
   @v_ean13  varchar(50),
   @v_isbn10	varchar(50),
   @v_bookkey	varchar(50),
   @v_upc		varchar(50),
   @v_itemnumber	varchar(20),
   @v_externaltask	varchar(50),
   @v_externalelement	varchar(50),
   @v_new_actualInd	varchar(1),
   @v_new_date	varchar(50),
   @u_bookkey	int,
   @u_taskcode	int,
   @u_elementcode	int,
   @u_elementsubcode	int,
   @u_elementkey	int,
   @u_new_actualInd bit,
   @u_new_date	datetime
   
BEGIN
	SET @v_errcode = 0
	SET @v_errcode2 = 0
	SET @v_lowpri_errcode = 0
	SET @v_errmsg = ''
	SET @v_errmsg2 = ''
	SET @v_lowpri_errmsg = ''
	SET @v_debug = 0
	SET @v_reviseddate = NULL
	SET @v_count = 0
	SET @u_bookkey = 0
	SET @u_elementcode = 0
	SET @u_elementsubcode = 0
	SET @u_elementkey = NULL
	SET @u_new_actualInd = NULL
	SET @u_new_date = NULL
	SET @v_producttype = NULL
	
	BEGIN TRY
		--extract XML values
		EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/User','UserID[1]',@v_userid  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/User','AuthenticationKey[1]',@v_userkey  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','Tag[1]',@v_tag  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','ProductIDType[1]',@v_producttype  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		SET @v_producttype = LOWER(RTRIM(LTRIM(COALESCE(@v_producttype, ''))))
		IF @v_producttype = 'ean13' OR @v_producttype = 'ean'
		BEGIN
			EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','ProductID[1]',@v_ean13  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		END
		ELSE IF @v_producttype = 'isbn' OR @v_producttype = 'isbn10'
		BEGIN
			EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','ProductID[1]',@v_isbn10  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		END
		ELSE IF @v_producttype = 'bookkey'
		BEGIN
			EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','ProductID[1]',@v_bookkey  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		END
		ELSE IF @v_producttype = 'upc'
		BEGIN
			EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','ProductID[1]',@v_upc  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		END
		ELSE IF @v_producttype = 'itemnumber'
		BEGIN
			EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','ProductID[1]',@v_itemnumber  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		END
		ELSE IF @v_producttype IS NULL OR @v_producttype = ''
		BEGIN
			EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','ProductID[1]',@v_isbn10  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		END
		EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','ExternalTask[1]',@v_externaltask  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','ExternalElement[1]',@v_externalelement  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','NewActualInd[1]',@v_new_actualInd  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT
		EXEC sp_xmlGetNodeValue null,@i_request,null,'//Firebrand/Feed','NewDate[1]',@v_new_date  OUTPUT,@v_lowpri_errmsg  OUTPUT,@v_lowpri_errcode  OUTPUT

		IF @v_bookkey IS NOT NULL AND @v_bookkey <> ''
		BEGIN
			SET @u_bookkey = CONVERT(int, @v_bookkey)
		END
		IF @v_new_actualInd IS NOT NULL AND @v_new_actualInd <> ''
		BEGIN
			SET @u_new_actualInd = CONVERT(bit, @v_new_actualInd)
		END
		IF @v_new_date IS NOT NULL AND @v_new_date <> ''
		BEGIN
			SET @u_new_date = CONVERT(datetime, @v_new_date)
		END

		IF @u_bookkey IS NULL OR @u_bookkey <= 0
		BEGIN
			IF @v_isbn10 IS NOT NULL AND @v_isbn10 <> ''
			BEGIN
				SELECT @u_bookkey = bookkey
				FROM isbn
				WHERE isbn10 = @v_isbn10
			END
			ELSE IF @v_ean13 IS NOT NULL AND @v_ean13 <> ''
			BEGIN
				SELECT @u_bookkey = bookkey
				FROM isbn
				WHERE ean13 = @v_ean13
			END
			ELSE IF @v_upc IS NOT NULL AND @v_upc <> ''
			BEGIN
				SELECT @u_bookkey = bookkey
				FROM isbn
				WHERE upc = @v_upc
			END
			ELSE IF @v_itemnumber IS NOT NULL AND @v_itemnumber <> ''
			BEGIN
				SELECT @u_bookkey = bookkey
				FROM isbn
				WHERE itemnumber = @v_itemnumber
			END
		END

		IF @u_bookkey IS NULL OR @u_bookkey <= 0
		BEGIN
			SET @v_errmsg2 = 'No bookkey was found for the provided ProductID of ProductIDType: ''' + @v_producttype + ''''
			SET @v_errcode2 = 1
			IF @v_debug = 1
			BEGIN
				PRINT @v_errmsg2
			END
		END

		SELECT @u_taskcode = datetypecode
		FROM datetype
		WHERE externalcode = @v_externaltask

		IF @u_taskcode IS NULL
		BEGIN
			SET @v_errmsg2 = 'No taskcode was found for ExternalTask: ' + @v_externaltask
			SET @v_errcode2 = 1
			IF @v_debug = 1
			BEGIN
				PRINT @v_errmsg2
			END
		END

		IF @v_externalelement IS NOT NULL AND @v_externalelement <> ''
		BEGIN
			SELECT @u_elementcode = datacode
			FROM gentables_ext
			WHERE tableid = 287
				AND externalcode2 = @v_externalelement

			IF @u_elementcode > 0
			BEGIN
				SELECT @u_elementsubcode = datasubcode
				FROM subgentables
				WHERE tableid = 287
					AND datacode = @u_elementcode

				IF @u_elementsubcode > 0
				BEGIN
					SELECT @u_elementkey = taqelementkey
					FROM taqprojectelement
					WHERE bookkey = @u_bookkey
						AND taqelementtypecode = @u_elementcode
						AND taqelementtypesubcode = @u_elementsubcode
				END
			END
		END
	END TRY
	BEGIN CATCH
		SET @v_errmsg2 = ERROR_MESSAGE()
		SET @v_errcode2 = ERROR_NUMBER()
		IF @v_debug = 1
		BEGIN
			print @v_errmsg2
		END
	END CATCH

	SET @v_return_work =
	'<?xml version="1.0" encoding="UTF-8"?>
	<Firebrand>
		<Informationals>
			<Code>$$errorcode$$</Code>
			<Message>$$errormessage$$</Message>
		</Informationals>
		<Content>$$content$$</Content>
	</Firebrand>'

	IF @v_errcode2 = 0
	BEGIN
		IF @v_debug=1
		BEGIN
		  PRINT 'XML input values'
		  PRINT '  userid ['+@v_userid+']'
		  PRINT '  authenticationkey ['+cast(@v_userkey as varchar)+']'
		  PRINT '  tag ['+@v_tag+']'
		  PRINT '  BookKey ['+@v_bookkey+']'
		  PRINT '  Taskcode ['+@v_externaltask+']'
		  PRINT '  Elementcode ['+@v_externalelement+']'
		  PRINT '  NewActualInd ['+@v_new_actualInd+']'
		  PRINT '  NewDate ['+@v_new_date+']'
		END

		--get datacode for tag
		SELECT @v_tag_datacode = datacode FROM gentables WHERE tableid = 660 AND alternatedesc1 = @v_tag

		--get content
		IF @v_debug = 1 PRINT 'data collection timing:'
		IF @v_debug = 1 PRINT sysdatetime()

		SELECT @v_count = COUNT(*)
		FROM taqprojecttask tpt
		WHERE tpt.bookkey = @u_bookkey
			AND tpt.datetypecode = @u_taskcode
			AND (tpt.taqelementkey = COALESCE(@u_elementkey, tpt.taqelementkey) OR tpt.taqelementkey IS NULL)
		
		IF @v_count = 1
		BEGIN
			SET @v_reviseddate = CONVERT(datetime, CONVERT(date, GETDATE()))
			--do the update
			UPDATE tpt
			SET tpt.actualind = COALESCE(@u_new_actualInd, tpt.actualind),
				tpt.activedate = COALESCE(@u_new_date, tpt.activedate),
				tpt.lastmaintdate = GETDATE(),
				tpt.reviseddate = CASE
									WHEN COALESCE(@u_new_actualInd, tpt.actualind) = 0 THEN @v_reviseddate
									ELSE tpt.reviseddate
								  END,
				tpt.lastuserid = COALESCE(@v_userid, 'SWAG')
			FROM taqprojecttask tpt
			WHERE tpt.bookkey = @u_bookkey
				AND tpt.datetypecode = @u_taskcode
				AND (tpt.taqelementkey = COALESCE(@u_elementkey, tpt.taqelementkey) OR tpt.taqelementkey IS NULL)
		END
		ELSE BEGIN
			IF @v_count = 0
			BEGIN
				SET @v_errmsg2 = 'No taqprojecttask rows match the criteria provided (bookkey=' + CONVERT(varchar,@u_bookkey) + ', datetypecode=' + CONVERT(varchar,@u_taskcode) + ', elementkey=' + CONVERT(varchar,COALESCE(@u_elementkey,'0')) + '). No update was performed'
			END
			ELSE BEGIN
				SET @v_errmsg2 = 'More than 1 taqprojecttask row matches the criteria provided. No update was performed.'
				SET @v_count = 0
			END
			SET @v_errcode2 = 1
			IF @v_debug = 1
			BEGIN
				print @v_errmsg2
			END
		END

		IF @v_debug = 1 PRINT sysdatetime()
		IF @v_debug = 1 PRINT 'replace timing:'
		IF @v_debug = 1 PRINT sysdatetime()
		SET @v_content=replace(replace(replace(replace(replace(replace(@v_content,'&gt;','>'),'&lt;','<'),'&amp;','&'),'& ','&amp; '),'&#160;',' '),'&nbsp;',' ')
		IF @v_debug = 1 PRINT sysdatetime()

	END
	IF @v_errcode2 <> 0 OR @v_errmsg2 <> ''
	BEGIN
		SET @v_errcode = @v_errcode2
		SET @v_errmsg = @v_errmsg2
	END
	ELSE BEGIN
		set @v_errmsg='total titles updated: '+coalesce(cast(@v_count as varchar),'')
	END
	--create return XML
	SET @v_return_work=REPLACE(@v_return_work,'$$errorcode$$',coalesce(@v_errcode,''))
	SET @v_return_work=REPLACE(@v_return_work,'$$errormessage$$',coalesce(@v_errmsg,''))
	SET @v_return_work=REPLACE(@v_return_work,'$$content$$',coalesce(@v_content,''))
	SET @o_Return=@v_return_work

END
GO

GRANT EXECUTE ON [dbo].[SWAG_UpdateTaskDate] TO PUBLIC
GO