/****** Object:  StoredProcedure [dbo].[pers_verifytitle]    Script Date: 02/09/2009 10:04:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pers_verifytitle]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[pers_verifytitle]

/****** Object:  StoredProcedure [dbo].[pers_verifytitle]    Script Date: 02/09/2009 10:04:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pers_verifytitle]
(@v_build	VARCHAR (2)
)
AS
DECLARE @i_bookkey		INT
DECLARE @v_isbn			VARCHAR(20)
DECLARE @i_row_passfail		INT
DECLARE @v_pass_desc		VARCHAR(20)
DECLARE @v_fail_desc		VARCHAR(20)
DECLARE @v_title_message	VARCHAR(2000)
DECLARE @i_currentstatus	INT
DECLARE @v_comment		VARCHAR(2000)
declare @rowcount_var		int
declare	@count2			int
declare	@count3			int
declare @count4			int

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
DECLARE @errorcode		INT
DECLARE @errordesc		VARCHAR(2000)
DECLARE @feed_last_processdate	DATETIME
DECLARE @feed_system_date 	DATETIME
DECLARE @feedkey_old		INT

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

SELECT @feed_system_date = getdate()

SELECT @feedkey_old = max(feedkey) 
FROM	feedout

SELECT @feed_last_processdate = 
dateprocessed
FROM	feedout
WHERE	feedkey = @feedkey_old

/*  Process Log Info		*/
SELECT @d_processstartdate = getdate()

INSERT INTO cispub_feeds(feedkey,type,processstartdate,totalrows)
VALUES (@i_feedkey,@v_feedtype,@d_processstartdate,@i_total_rows)

IF @v_build='F'
	DECLARE c_book INSENSITIVE CURSOR FOR
		SELECT	b.bookkey, i.isbn10
		FROM	book b 
		LEFT OUTER JOIN isbn i 
		ON b.bookkey = i.bookkey 
		WHERE	b.standardind = 'N' 
		ORDER BY i.isbn10
	FOR READ ONLY
ELSE 
	DECLARE c_book INSENSITIVE CURSOR FOR
		SELECT	b.bookkey, i.isbn10
		FROM	book b 
		LEFT OUTER JOIN isbn i 
		ON b.bookkey = i.bookkey 
		join titlehistory t
		on b.bookkey = t.bookkey
		WHERE	b.standardind = 'N'
		and t.lastmaintdate > @feed_last_processdate
		AND t.lastuserid <> 'CISPUB-2-TMM UPDATES'
		group by b.bookkey, i.isbn10 
		UNION
		SELECT	b.bookkey, i.isbn10
		FROM	book b 
		LEFT OUTER JOIN isbn i 
		ON b.bookkey = i.bookkey 
		join datehistory t
		on b.bookkey = t.bookkey
		WHERE	b.standardind = 'N'
		and t.datetypecode in (8, 32, 47, 399)			--pub date, release date, warehouse date, return by date
		and t.lastmaintdate > @feed_last_processdate
		AND t.lastuserid <> 'CISPUB-2-TMM UPDATES'
		group by b.bookkey, i.isbn10 
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
		and verificationtypecode=1

		SELECT @rowcount_var = @@ROWCOUNT
		
		if @rowcount_var = 0
		begin
			insert into bookverification
				(bookkey, verificationtypecode, titleverifystatuscode, lastuserid, lastmaintdate)
			values(@i_bookkey, 1,8,'cispubfeed',getdate())

			set @i_currentstatus = 8	/*not sent*/

--must insert other 3 records if missing
			select @count2 = sum(case when verificationtypecode = 2 then 1 else 0 end), 
			@count3 = sum(case when verificationtypecode = 3 then 1 else 0 end),
			@count4 = sum(case when verificationtypecode = 4 then 1 else 0 end)
			from bookverification
			where verificationtypecode in (2, 3, 4)
			and bookkey = @i_bookkey
			group by bookkey

			if @count2 is null or @count2 = 0 begin
				insert into bookverification
					(bookkey, verificationtypecode, titleverifystatuscode, lastuserid, lastmaintdate)
				values(@i_bookkey, 2,0,'cispubfeed',getdate())
			end

			if @count3 is null or @count3 = 0 begin
				insert into bookverification
					(bookkey, verificationtypecode, titleverifystatuscode, lastuserid, lastmaintdate)
				values(@i_bookkey, 3,0,'cispubfeed',getdate())
			end

			if @count4 is null or @count4 = 0 begin
				insert into bookverification
					(bookkey, verificationtypecode, titleverifystatuscode, lastuserid, lastmaintdate)
				values(@i_bookkey, 4,0,'cispubfeed',getdate())
			end
		end

		IF COALESCE(@i_currentstatus,0) = 0 /* turn null to zero*/
		BEGIN
			SELECT @i_currentstatus = 8 /*not sent*/
		END

		EXECUTE va_check_titles @i_bookkey, @i_row_passfail OUTPUT, @v_title_message OUTPUT

		IF @i_row_passfail = 1 -- Success
		BEGIN
			IF @i_currentstatus <> 7 
			BEGIN
				SELECT @i_verify_rows = @i_verify_rows+1

				UPDATE bookverification
				SET 	titleverifystatuscode = 7,	/* STATUS = 'Title Sent to Pers' */
						lastmaintdate = getdate(),
						lastuserid = @v_lastuserid
				WHERE	bookkey = @i_bookkey
				and verificationtypecode=1
				and coalesce(titleverifystatuscode,0) not in (9,10) /*always send, or never send*/

				DELETE FROM bookcomments	--deletes comments inserted in last run
				WHERE bookkey = @i_bookkey
						AND commenttypecode = 4
						AND commenttypesubcode = 27
			END

			EXEC qtitle_update_titlehistory 'bookverification','titleverifystatuscode',@i_bookkey,1,NULL,
				@v_pass_desc,'UPDATE',@v_lastuserid,0,NULL,@errorcode output,@errordesc output		
		END
		ELSE		 -- @i_row_passfail = 0 = Failure
		BEGIN
			SELECT @i_error_rows = @i_error_rows+1

			DELETE FROM bookcomments
			WHERE bookkey = @i_bookkey
					AND commenttypecode = 4
					AND commenttypesubcode = 27

			SELECT @v_comment = dbo.plaintext_to_html(@v_title_message)

			INSERT INTO bookcomments (bookkey,printingkey,commenttypecode,commenttypesubcode,commenttext,
							commenthtml,commenthtmllite,lastuserid,lastmaintdate,releasetoeloquenceind)
			VALUES (@i_bookkey,1,4,27,@v_title_message,@v_comment,@v_comment,@v_lastuserid,@d_lastmaintdate,0)

			UPDATE bookverification
			SET 	titleverifystatuscode = 8, 	/* STATUS = 'Title NOT Sent to Pers' */
					lastmaintdate = getdate(),
					lastuserid = @v_lastuserid
			WHERE	bookkey = @i_bookkey
			and verificationtypecode=1
			and coalesce(titleverifystatuscode,0) not in (9,10) /*always send, never send*/

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








