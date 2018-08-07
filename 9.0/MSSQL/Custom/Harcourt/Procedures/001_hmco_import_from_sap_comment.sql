/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_comment]    Script Date: 12/10/2009 16:54:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_comment]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_comment]

/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_comment]    */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jennifer Hurd
-- Create date: 12/10/09
-- =============================================
CREATE PROCEDURE [dbo].[hmco_import_from_SAP_comment] 
	@i_bookkey int = 0, 
	@i_printingkey	int,
	@i_update_mode	char(1),
	@i_userid   varchar(30),
	@i_rowid	int,
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output


AS
BEGIN

declare @commenttypecode	int,
@commenttypesubcode	int,
@commentstub	varchar(255),
@commenttype	varchar(50),
@commentsendtoeloquenceind	int,
@commentsubtype	varchar(50),
@bookkey	int,
@commentsendtoeloquenceind2	int,
@v_error	int,
@v_rowcount	int,
@fielddesc	varchar(50),
@beforedate	datetime,
@v_table_name	varchar(20),
@i_historyorder	int

set @v_table_name = 'BOOKCOMMENTS'

--get datacode from gentables for filetype
--check if that datacode exists on filelocation for this bookkey/printing, get filelocationkey if exists
--if exists, check update mode
--	if update mode = A, update existing row with path & elo ind & write history
--	do nothing if mode = B
--if doesn't exist
--	count how many rows exist for that bookkey printing, across all types
--	increment that by 1 for sort order
--	generate new filelocationkey
--	insert new row, for A or B mode
--

set @beforedate = getdate()

select @commenttypecode = isnull(commenttypecode,0),
@commenttypesubcode = isnull(commenttypesubcode,0),
@commentstub = isnull(substring(comment,1,255),''),
@commentsendtoeloquenceind = commentsendtoeloquenceind
from hmco_import_into_pss
where row_id = @i_rowid
and bookkey = @i_bookkey
and (is_processed = 'N'
or is_processed is null)

if @commentstub = ''	--no comment to process, return successfully
begin
	set @o_error_code = 0
	return
end

if @commentstub <> '' and (@commenttypecode < 1 or @commenttypesubcode < 1)	--comment to process, types aren't populated, fail title
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update bookcomments table.  Comment type & subtype values must both be populated.'
	RETURN
end	

if lower(substring(@commentstub,1,5)) <> '<div>' and lower(substring(@commentstub,1,3)) <> '<p>'
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update bookcomments table.  Comment must be in html format.'
	RETURN
end	

select @commenttype = g.datadesc,
@commentsubtype = s.datadesc
from subgentables s
join gentables g
on s.tableid = g.tableid
and g.datacode = s.datacode
where s.tableid = 284
and s.deletestatus = 'N'
and s.datacode = @commenttypecode
and s.datasubcode = @commenttypesubcode

if @commenttype is null or @commentsubtype is null
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update bookcomments table.  Comment type & subtype code values of '+convert(varchar(5),@commenttypecode)+', '+convert(varchar(5),@commenttypesubcode)+' not found.'
	RETURN
end

IF substring(@commenttype,1,1) = 'M' BEGIN
	-- Marketing
	SET @i_historyorder = 1
END 
ELSE IF substring(@commenttype,1,1) = 'E' BEGIN
	-- Editorial
	SET @i_historyorder = 3
END 
ELSE IF substring(@commenttype,1,1) = 'T' BEGIN
	-- Title Notes
	SET @i_historyorder = 4
END 
ELSE IF substring(@commenttype,1,1) = 'P' BEGIN
	-- Publicity
	SET @i_historyorder = 5
END 

select @fielddesc = '(' + substring(@commenttype,1,1) + ') ' + @commentsubtype

select @bookkey = bookkey,
@commentsendtoeloquenceind2 = isnull(releasetoeloquenceind,0)
from bookcomments c
where bookkey = @i_bookkey
and printingkey = @i_printingkey
and commenttypecode = @commenttypecode
and commenttypesubcode = @commenttypesubcode

if @bookkey is not null and @i_update_mode = 'A'		--record exists and we want to overwrite it
begin
	update bookcomments
	set commenthtml = h.comment, 
		invalidhtmlind = 1,
		releasetoeloquenceind = h.commentsendtoeloquenceind,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
	from hmco_import_into_pss h
	join bookcomments b
	on h.bookkey = b.bookkey
	and b.commenttypecode = h.commenttypecode
	and b.commenttypesubcode = h.commenttypesubcode
	where h.row_id = @i_rowid
	and (h.is_processed = 'N'
	or h.is_processed is null)
	and b.bookkey = @i_bookkey
	and b.printingkey = @i_printingkey

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to update bookcomments table.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 

	exec qtitle_update_titlehistory 'bookcomments', 'commentString' , @i_bookkey, @i_printingkey, 0, @commentstub, 'Update', @i_userid, 
			@i_historyorder, @fielddesc, @o_error_code output, @o_error_desc output

	if @commentsendtoeloquenceind <> @commentsendtoeloquenceind2
		exec qtitle_update_titlehistory 'bookcomments', 'releasetoeloquenceind' , @i_bookkey, @i_printingkey, 0, @commentsendtoeloquenceind, 'Update', @i_userid, 
				@i_historyorder, @fielddesc, @o_error_code output, @o_error_desc output

	exec html_to_text_from_row_new @i_bookkey,@i_printingkey,@commenttypecode,@commenttypesubcode,@v_table_name,@o_error_code,@o_error_desc 
	exec html_to_lite_from_row_new @i_bookkey,@i_printingkey,@commenttypecode,@commenttypesubcode,@v_table_name,0,@o_error_code,@o_error_desc 

end
else if @bookkey is null		--record doesn't exist, so write a new row
begin
	insert into bookcomments
	(bookkey, printingkey, commenttypecode, commenttypesubcode, lastuserid, lastmaintdate, releasetoeloquenceind, commenthtml, invalidhtmlind)
	select i.bookkey, @i_printingkey, i.commenttypecode, i.commenttypesubcode, @i_userid, getdate(), i.commentsendtoeloquenceind, i.comment, 1
	from hmco_import_into_pss i
	where i.bookkey = @i_bookkey
	and i.row_id = @i_rowid
	and (i.is_processed = 'N'
	or i.is_processed is null)
	
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to insert into bookcomments table.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 

	exec qtitle_update_titlehistory 'bookcomments', 'commentstring' , @i_bookkey, @i_printingkey, 0, @commentstub, 'Insert', @i_userid, 
			@i_historyorder, @fielddesc, @o_error_code output, @o_error_desc output

	exec qtitle_update_titlehistory 'bookcomments', 'releasetoeloquenceind' , @i_bookkey, @i_printingkey, 0, @commentsendtoeloquenceind, 'Insert', @i_userid, 
			@i_historyorder, @fielddesc, @o_error_code output, @o_error_desc output

	exec html_to_text_from_row_new @i_bookkey,@i_printingkey,@commenttypecode,@commenttypesubcode,@v_table_name,@o_error_code,@o_error_desc 
	exec html_to_lite_from_row_new @i_bookkey,@i_printingkey,@commenttypecode,@commenttypesubcode,@v_table_name,0,@o_error_code,@o_error_desc 
end

----this titlehistory procedure writes out 4 rows for the commenttext, columnkey 70 is what is written by the app so delete the other 3
--delete
--from titlehistory
--where bookkey = @i_bookkey
--and printingkey = @i_printingkey
--and lastuserid = @i_userid
--and columnkey in (261, 262, 260)		
--and lastmaintdate >= @beforedate

set nocount off

end
