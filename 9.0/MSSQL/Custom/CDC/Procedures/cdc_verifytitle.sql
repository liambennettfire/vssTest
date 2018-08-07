USE [CDC]
GO
/****** Object:  StoredProcedure [dbo].[cdc_verifytitle]    Script Date: 04/01/2008 09:25:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--drop PROCEDURE cdc_verifytitle
CREATE PROCEDURE [dbo].[cdc_verifytitle]
AS
DECLARE @i_bookkey		INT
DECLARE @v_isbn			VARCHAR(20)
DECLARE @i_row_passfail		INT
DECLARE @v_pass_desc		VARCHAR(20)
DECLARE @v_fail_desc		VARCHAR(20)
DECLARE @v_title_message	VARCHAR(2000)
DECLARE @i_currentstatus	INT
DECLARE @v_comment		VARCHAR(2000)

DECLARE @d_lastmaintdate	DATETIME
DECLARE @v_lastuserid		VARCHAR(30)

DECLARE @i_feedkey		INT
DECLARE @v_feedtype		VARCHAR(20)
DECLARE @i_total_rows		INT
DECLARE @i_row_count		INT
DECLARE @i_verify_rows		INT
DECLARE @i_error_rows		INT
DECLARE @d_processstartdate	DATETIME
DECLARE @d_processenddate	DATETIME

DECLARE @cstatus		INT
DECLARE @status_5_status	INT
DECLARE @errorcode		INT
DECLARE @errordesc		VARCHAR(2000)


SELECT @i_feedkey = MAX(feedkey)+1
FROM cispub_feeds

SELECT @d_lastmaintdate = getdate()
SELECT @v_lastuserid = 'Verification Process'
SELECT @v_feedtype = 'Verification Agent'

SELECT @i_total_rows = 0
SELECT @i_row_count = 0	
SELECT @i_error_rows = 0
SELECT @i_verify_rows = 0
SELECT @v_pass_desc = 'Sent to CIS.PUB'		
SELECT @v_fail_desc = 'Not Sent to CIS.PUB'		

SELECT @i_total_rows = COUNT(*)
FROM book
WHERE standardind = 'N'

/*  Process Log Info		*/
	SELECT @d_processstartdate = getdate()
	INSERT INTO cispub_feeds(feedkey,type,processstartdate,totalrows)
	VALUES (@i_feedkey,@v_feedtype,@d_processstartdate,@i_total_rows)

/* The next three steps are to change the 'Send to eloquence' flag if the user has
   sent a title that is 'NYP - Unscheduled'.  According to Don, we should not allow any titles with 
   this status to be sent to eloquence' */

	DECLARE status_5_book INSENSITIVE CURSOR FOR
		SELECT	bd.bookkey from bookdetail bd, book b 
		where bd.bisacstatuscode=12
		and b.bookkey=bd.bookkey
		and b.sendtoeloind=1
	FOR READ ONLY
	

	OPEN status_5_book

	FETCH NEXT FROM status_5_book
	INTO @i_bookkey 

	SELECT @status_5_status = @@FETCH_STATUS 
	
	
	WHILE (@status_5_status <> -1)
		BEGIN

			IF (@status_5_status <> -2)
				BEGIN	

				-- step 1, change the status to do not send

				update bookedistatus set edistatuscode = 7 where bookkey = @i_bookkey


				-- step 2 shut off the send to eloquence indicator on book

				update book set sendtoeloind=null where bookkey = @i_bookkey

				-- step 3 update title history

				EXEC qtitle_update_titlehistory 'book','sendtoeloind',@i_bookkey,1,NULL,
				'Elo Ind turned off','UPDATE',@v_lastuserid,0,NULL,@errorcode output,@errordesc output	

				END

			FETCH NEXT FROM status_5_book
			INTO @i_bookkey

			SELECT @status_5_status = @@FETCH_STATUS 

		END



	CLOSE status_5_book
	DEALLOCATE status_5_book

/* end of status 5 process */

	DECLARE c_book INSENSITIVE CURSOR FOR
		SELECT	b.bookkey, i.isbn10
		FROM	book b LEFT OUTER JOIN isbn i ON b.bookkey = i.bookkey 
		WHERE	b.standardind = 'N' 
		ORDER BY i.isbn10
	FOR READ ONLY
	

	OPEN c_book

	FETCH NEXT FROM c_book
	INTO @i_bookkey,@v_isbn 

	SELECT @cstatus = @@FETCH_STATUS 
	
	
	WHILE (@cstatus <> -1)
		BEGIN

			IF (@cstatus <> -2)
				BEGIN	

					SELECT @errorcode = 0
					SELECT @errordesc = ''

					SELECT @i_currentstatus = titleverifystatuscode
					FROM bookverification
					WHERE bookkey = @i_bookkey

					IF COALESCE(@i_currentstatus,0) = 0
						BEGIN
							SELECT @i_currentstatus = 2
						END
		

					EXECUTE va_check_titles @i_bookkey, @i_row_passfail OUTPUT, @v_title_message OUTPUT

					IF @i_row_passfail = 1 -- Success
						BEGIN
							IF @i_currentstatus <> 1
								BEGIN
									SELECT @i_verify_rows = @i_verify_rows+1

									UPDATE bookverification
									SET 	titleverifystatuscode = 1	/* STATUS = 'Title Sent to CDC' */
									WHERE	bookkey = @i_bookkey
											and verificationtypecode = 1

									DELETE FROM bookcomments
									WHERE bookkey = @i_bookkey
											AND commenttypecode = 4
											AND commenttypesubcode = 9


									EXEC qtitle_update_titlehistory 'bookverification','titleverifystatuscode',@i_bookkey,1,NULL,
									@v_pass_desc,'UPDATE',@v_lastuserid,0,NULL,@errorcode output,@errordesc output	

								END
						END

					ELSE		-- @i_row_passfail = 0 = Failure
						BEGIN

							SELECT @i_error_rows = @i_error_rows+1

							DELETE FROM bookcomments
							WHERE bookkey = @i_bookkey
									AND commenttypecode = 4
									AND commenttypesubcode = 9

							SELECT @v_comment = dbo.plaintext_to_html(@v_title_message)
      	
							INSERT INTO bookcomments(bookkey,printingkey,commenttypecode,commenttypesubcode,commenttext,
											commenthtml,commenthtmllite,lastuserid,lastmaintdate,releasetoeloquenceind)
							VALUES (@i_bookkey,1,4,9,@v_title_message,@v_comment,@v_comment,@v_lastuserid,@d_lastmaintdate,0)

						
							UPDATE bookverification
									SET 	titleverifystatuscode = 2	/* STATUS = 'Title NOT Sent to CDC' */
									WHERE	bookkey = @i_bookkey
											and verificationtypecode = 1

							IF @i_currentstatus <> 2
								BEGIN
									EXEC qtitle_update_titlehistory 'bookverification','titleverifystatuscode',@i_bookkey,1,NULL,
									@v_fail_desc,'UPDATE',@v_lastuserid,0,NULL,@errorcode output,@errordesc output	

								END

						END

				IF @errorcode > 0
					BEGIN
						EXEC cispub_messages @i_feedkey,1,@d_lastmaintdate,@v_isbn,'Error inserting or updating Verification Status into Title History'
					END


				SELECT @i_row_count = @i_row_count+1

				END

			FETCH NEXT FROM c_book
			INTO @i_bookkey,@v_isbn 

			SELECT @cstatus = @@FETCH_STATUS 

		END

	SELECT @d_processenddate = getdate()

	UPDATE cispub_feeds
	SET titlecount = @i_row_count,
		errorcount = @i_error_rows,
		rowsverified = @i_verify_rows,
		processenddate = @d_processenddate
	WHERE feedkey = @i_feedkey


CLOSE c_book
DEALLOCATE c_book

