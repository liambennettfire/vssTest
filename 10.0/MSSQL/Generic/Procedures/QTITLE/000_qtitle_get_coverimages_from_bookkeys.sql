IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qtitle_get_coverimages_from_bookkeys]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qtitle_get_coverimages_from_bookkeys]
GO

/******************************************************************************
**  Name: qtitle_get_coverimages_from_bookkeys
**  Desc: 
**  Auth: Dustin Miller
**  Date: July 21, 2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  10/28/2016	 DM			 Case 38777
**	12/20/2016	 DM			 Case 38777
*******************************************************************************/

CREATE PROCEDURE [dbo].[qtitle_get_coverimages_from_bookkeys] (
	@i_bookkeys VARCHAR(MAX),
	@o_error_code INTEGER OUTPUT,
	@o_error_desc VARCHAR(2000) OUTPUT)
AS
BEGIN
	DECLARE @bookkeys VARCHAR(MAX)
	DECLARE @bookkey VARCHAR(MAX)
	DECLARE @bookkeyval INT
	DECLARE @coverimagepathbase VARCHAR(4000)
	DECLARE @coverimagepath VARCHAR(4000)
	DECLARE @usewebfilelocations INT
	DECLARE @ean13 VARCHAR(13)
	DECLARE @elocustomerkey INT
	DECLARE @elocustomerid VARCHAR(6)
	DECLARE @error_var INT
    SET @o_error_code = 0
	SET @o_error_desc = ''

	DECLARE @coverImageTable TABLE
	(
		bookkey INT,
		coverimagepath VARCHAR(4000)
	)

	SELECT @usewebfilelocations = optionvalue
    FROM clientoptions
	WHERE optionid = 77

	IF @usewebfilelocations = 1
	BEGIN
		SET @bookkeys = @i_bookkeys
		SET @bookkey = null
		SET @bookkeyval = null
		WHILE LEN(@bookkeys) > 0
		BEGIN
			IF PATINDEX('%,%',@bookkeys) > 0
			BEGIN
				SET @bookkey = SUBSTRING(@bookkeys, 0, PATINDEX('%,%', @bookkeys))
				SET @bookkeys = SUBSTRING(@bookkeys, LEN(@bookkey + ',') + 1, LEN(@bookkeys))
			END
			ELSE BEGIN
				SET @bookkey = @bookkeys
				SET @bookkeys = NULL
			END

			SET @bookkeyval = CAST(@bookkey AS INT)

			SET @coverimagepath = NULL
			SELECT TOP 1 @coverimagepath = CASE WHEN fl.filelocationkey > 0 THEN
				'~\' + dbo.qutl_get_filelocation_rootpath(fl.filelocationkey,'logical') + '\' + pathname
				ELSE pathname END  
			 FROM filelocation fl, gentables g
			WHERE bookkey = @bookkeyval AND
			  --printingkey = 1 AND
			  fl.filetypecode = g.datacode AND
			  g.tableid = 354 AND
			  g.gen1ind = 1

			INSERT INTO @coverImageTable
			(bookkey, coverimagepath)
			VALUES
			(@bookkeyval, @coverimagepath)
		END
	END
	ELSE IF @usewebfilelocations = 2 BEGIN
		SELECT TOP 1 @coverimagepathbase = apiurl
		FROM cloudaccess

		--SET @coverimagepathbase = 'http://cloud.firebrandtech.com/api/v2' --DEBUG!

		IF LEN(COALESCE(@coverimagepathbase, '')) > 0
		BEGIN
			IF RIGHT(@coverimagepathbase, 1) <> '/'
			BEGIN
				SET @coverimagepathbase = @coverimagepathbase + '/'
			END

			SET @bookkeys = @i_bookkeys
			SET @bookkey = null
			SET @bookkeyval = null
			WHILE LEN(@bookkeys) > 0
			BEGIN
				IF PATINDEX('%,%',@bookkeys) > 0
				BEGIN
					SET @bookkey = SUBSTRING(@bookkeys, 0, PATINDEX('%,%', @bookkeys))
					SET @bookkeys = SUBSTRING(@bookkeys, LEN(@bookkey + ',') + 1, LEN(@bookkeys))
				END
				ELSE BEGIN
					SET @bookkey = @bookkeys
					SET @bookkeys = NULL
				END

				SET @bookkeyval = CAST(@bookkey AS INT)

				SET @coverimagepath = @coverimagepathbase

				IF LEN(COALESCE(@coverimagepath, '')) > 0
				BEGIN
					SET @ean13 = ''
					SELECT @ean13 = ean13 FROM isbn where bookkey = @bookkey

					SET @elocustomerkey = 0
					SELECT @elocustomerkey = elocustomerkey
					FROM book
					WHERE bookkey = @bookkey

					SET @elocustomerid = NULL
					SELECT @elocustomerid = eloqcustomerid
					FROM customer
					WHERE customerkey = @elocustomerkey

					IF LEN(COALESCE(@ean13, '')) > 0 AND LEN(COALESCE(@elocustomerid, '')) > 0
					BEGIN
						WHILE LEFT(@elocustomerid, 1) = '0'
						BEGIN
							SET @elocustomerid = SUBSTRING(@elocustomerid, 2, 6)
						END

						SET @coverimagepath = @coverimagepath + 'img/' + CAST(@elocustomerid AS VARCHAR) + '/' + @ean13 + '/s'
					END
					ELSE BEGIN
						SET @coverimagepath = NULL
					END

					INSERT INTO @coverImageTable
					(bookkey, coverimagepath)
					VALUES
					(@bookkeyval, @coverimagepath)
				END
			END
		END
	END

	SELECT DISTINCT bookkey, coverimagepath
	FROM @coverImageTable

	SELECT @error_var = @@ERROR
	IF @error_var <> 0
	BEGIN
		SET @o_error_code = 1
		SET @o_error_desc = 'error finding coverimages from bookkeys: ' + @i_bookkeys
		RETURN
	END

END
GO

GRANT EXEC ON [dbo].[qtitle_get_coverimages_from_bookkeys] TO PUBLIC
GO