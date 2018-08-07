/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_insert_association]    Script Date: 02/25/2009 14:08:04 ******/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_insert_association]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_insert_association]SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create PROCEDURE [dbo].[hmco_import_from_SAP_insert_association] 
	@bookkey int, 
	@i_userid   varchar(30),
	@associatedbookkey	int,
	@associationtypecode	int,
	@associationtypesubcode	int,
	@releasetoelo	int,
	@associationdesc	varchar(200),
	@associationsubdesc	varchar(200),
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare @count	int,
@sort	int,
@associsbn	varchar(20),
@v_error	varchar(2000),
@v_rowcount	int

select @count = count(*)
from associatedtitles
where bookkey = @bookkey
and associationtypecode = @associationtypecode
and associationtypesubcode = @associationtypesubcode
and associatetitlebookkey = @associatedbookkey

if isnull(@count,0) > 0
	return 

select @sort = max(sortorder) + 1
from associatedtitles
where bookkey = @bookkey
and associationtypecode = @associationtypecode
and associationtypesubcode = @associationtypesubcode

select @associsbn = dbo.rpt_get_isbn(@associatedbookkey, 16)

if @sort is null
	set @sort = 1

insert into associatedtitles
(bookkey, associationtypecode, associationtypesubcode, associatetitlebookkey, sortorder, isbn, productidtype, releasetoeloquenceind, lastuserid, lastmaintdate)
values (@bookkey, @associationtypecode, @associationtypesubcode, @associatedbookkey, @sort, @associsbn, 2, @releasetoelo, @i_userid, getdate())

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'Unable to insert into associatedtitles table.   Error #' + cast(@v_error as varchar(20))
	RETURN
END 

if @associationsubdesc is null
	exec qtitle_update_titlehistory 'associatedtitles', 'isbn' , @bookkey, 1, 0, @associsbn, 'Insert', @i_userid, 
		null, @associationdesc, @o_error_code output, @o_error_desc output
else
	exec qtitle_update_titlehistory 'associatedtitles', 'isbn' , @bookkey, 1, 0, @associsbn, 'Insert', @i_userid, 
		null, @associationsubdesc, @o_error_code output, @o_error_desc output


end