SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_assoctitle_export]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[get_assoctitle_export]
GO

CREATE PROCEDURE get_assoctitle_export(@bookkey	INT,
				  @o_errorcode	INT OUTPUT,
				  @o_errormsg	VARCHAR(1000) OUTPUT)

AS

DECLARE @assoctype			VARCHAR(40)
DECLARE @associsbn			VARCHAR(20)
DECLARE @assoctitle			VARCHAR(255)
DECLARE @assocauthor			VARCHAR(80)
DECLARE @assocpubdate			VARCHAR(20)
DECLARE @assocprice			VARCHAR(20)
DECLARE @assocformat			VARCHAR(40)
DECLARE @assocsalesunitsnet		VARCHAR(20)
DECLARE @assocsalesunitsgross		VARCHAR(20)
DECLARE @assocbisacstatus		VARCHAR(40)
DECLARE @assocorigpub			VARCHAR(40)
DECLARE @assocedition			VARCHAR(40)
DECLARE @media				INT
DECLARE @format				INT
DECLARE @bisaccode			INT 
DECLARE @origpubcode 			INT
DECLARE @editioncode			INT
DECLARE @assoctypecode			INT
DECLARE @status				INT
DECLARE @sortorder			INT
DECLARE @rowcount			INT

BEGIN
	SET @o_errorcode = 0
	SET @o_errormsg = ''
	SET @rowcount = 0
	SET @sortorder = 0
	SET @assoctypecode = 0

	DECLARE c_title INSENSITIVE CURSOR FOR
		SELECT associationtypecode,sortorder
		FROM associatedtitles
		WHERE bookkey = @bookkey
		ORDER by associationtypecode,sortorder

	OPEN c_title

	FETCH NEXT fROM c_title 
	INTO @assoctypecode,@sortorder

	SELECT @status = @@FETCH_STATUS

	WHILE @status<>-1
		BEGIN
			IF @status<>-2
				BEGIN

					SELECT @bisaccode = bisacstatus,
						@origpubcode = origpubhousecode,
						@media = mediatypecode,
						@format = mediatypesubcode,
						@assocsalesunitsgross = COALESCE(CONVERT(VARCHAR(20),salesunitgross),''),
						@assocsalesunitsnet = COALESCE(CONVERT(VARCHAR(20),salesunitnet),''),
						@editioncode = editioncode
					FROM associatedtitles
					WHERE bookkey = @bookkey
							AND associationtypecode = @assoctypecode
							AND sortorder = @sortorder

					SET @associsbn = COALESCE(dbo.get_AssocTitleISBN(@bookkey,@sortorder,@assoctypecode),'')
					SET @assoctitle = COALESCE(dbo.get_AssocTitleTitle(@bookkey,@sortorder,@assoctypecode),'')
					SET @assocauthor = COALESCE(dbo.get_AssocTitleAuthor(@bookkey,@sortorder,@assoctypecode),'')
					SET @assocpubdate = COALESCE(dbo.get_AssocTitlePubDate(@bookkey,@sortorder,@assoctypecode),'')
					SET @assocprice =COALESCE(dbo.get_AssocTitlePrice(@bookkey,@sortorder,@assoctypecode),'')

					SELECT @assoctype = datadesc
					FROM gentables
					WHERE tableid = 440 AND datacode = @assoctypecode

					SELECT @assocformat = datadesc
					FROM subgentables
					WHERE tableid = 312 and datacode = @media and datasubcode = @format

					SELECT @assocbisacstatus = datadesc
					FROM gentables
					WHERE tableid = 314 AND datacode = @bisaccode


					SELECT @assocorigpub = datadesc
					FROM gentables
					WHERE tableid = 126 AND datacode = @origpubcode				

					SELECT @assocedition = datadesc
					FROM gentables
					WHERE tableid = 200 AND datacode = @editioncode					



					INSERT INTO export_assoctitle(bookkey,assoctype,associsbn,assoctitle,assocauthor,assocpubdate,assocprice,assocformat,assocsaleunitsnet,assocsalesunitsgross,assocbisacstatus,assocorigpub,assocedition)
					VALUES (@bookkey,@assoctype,@associsbn,@assoctitle,@assocauthor,@assocpubdate,@assocprice,@assocformat,@assocsalesunitsnet,@assocsalesunitsgross,@assocbisacstatus,@assocorigpub,@assocedition)

				END

			FETCH NEXT fROM c_title 
			INTO @assoctypecode,@sortorder

			SELECT @status = @@FETCH_STATUS				
		END

CLOSE c_title
DEALLOCATE c_title

	SELECT @o_errorcode = @@ERROR, @rowcount = @@ROWCOUNT

	IF @o_errorcode <> 0 
		BEGIN
        		SET @o_errorcode = 1
        		SET @o_errormsg = 'Unable insert ('+@bookkey+') into the export_associatedtitle table'
		END 


END


	







GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

