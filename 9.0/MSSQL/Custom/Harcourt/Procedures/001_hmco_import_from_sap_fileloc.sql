/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_fileloc]    Script Date: 12/10/2009 16:54:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_fileloc]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_fileloc]

/****** Object:  StoredProcedure [dbo].[hmco_import_from_SAP_fileloc]    */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jennifer Hurd
-- Create date: 12/10/09
-- =============================================
CREATE PROCEDURE [dbo].[hmco_import_from_SAP_fileloc] 
	@i_bookkey int = 0, 
	@i_printingkey	int,
	@i_update_mode	char(1),
	@i_userid   varchar(30),
	@i_filetypecode	int,
	@pathname	varchar(255),
	@filesendtoeloquenceind	int,
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output


AS
BEGIN

declare @v_error			int,
@v_rowcount			int,
@count				int,
@filetypecode		int,
@filetype			varchar(40),
@filelocationkey	int,
@pathname2			varchar(255),
@filesendtoeloquenceind2	int,
@filelocationgeneratedkey	int




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

select @filetypecode = datacode,
@filetype = datadesc
from gentables
where tableid = 354
and deletestatus = 'N'
and datacode = @i_filetypecode

if @filetypecode is null
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update filelocation table.  Filetypecode value of '+convert(varchar(5),@i_filetypecode)+' not found.'
	RETURN
end

select @filelocationkey = filelocationkey,
@pathname2 = isnull(pathname,''),
@filesendtoeloquenceind2 = isnull(sendtoeloquenceind,''),
@count = sortorder
from filelocation
where bookkey = @i_bookkey
and printingkey = @i_printingkey
and filetypecode = @filetypecode

if @pathname = @pathname2 and @filesendtoeloquenceind = @filesendtoeloquenceind2
begin
	set @o_error_code = 0
	return
end

if @filelocationkey is not null and @i_update_mode = 'A'		--record exists and we want to overwrite it
begin
	update filelocation
	set pathname = @pathname,
		sendtoeloquenceind = @filesendtoeloquenceind,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
	where bookkey = @i_bookkey
	and printingkey = @i_printingkey
	and filetypecode = @filetypecode
	and filelocationkey = @filelocationkey

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to update filelocation table.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 

	if @pathname <> @pathname2
		exec qtitle_update_titlehistory 'filelocation', 'pathname' , @i_bookkey, @i_printingkey, 0, @pathname, 'Update', @i_userid, 
				@count, 'File and Path Name', @o_error_code output, @o_error_desc output

	if @filesendtoeloquenceind <> @filesendtoeloquenceind2
		exec qtitle_update_titlehistory 'filelocation', 'sendtoeloquenceind' , @i_bookkey, @i_printingkey, 0, @filesendtoeloquenceind, 'Insert', @i_userid, 
				@count, 'Send Image to Eloquence', @o_error_code output, @o_error_desc output

end
else if @filelocationkey is null		--record doesn't exist, so write a new row
begin
	select @count = max(isnull(sortorder,0))
	from filelocation
	where bookkey = @i_bookkey
	and printingkey	= @i_printingkey

	select @count = isnull(@count,0) + 1

	exec get_next_key @i_userid, @filelocationkey output
	exec get_next_key @i_userid, @filelocationgeneratedkey output
	
	insert into filelocation
	(bookkey, printingkey, filetypecode, filelocationkey, filestatuscode, pathname, lastuserid, lastmaintdate, sendtoeloquenceind, sortorder, filelocationgeneratedkey)
	values (@i_bookkey, @i_printingkey, @filetypecode, @filelocationkey, 1, @pathname, @i_userid, getdate(), @filesendtoeloquenceind, @count, @filelocationgeneratedkey)

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to insert into filelocation table.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 

	exec qtitle_update_titlehistory 'filelocation', 'pathname' , @i_bookkey, @i_printingkey, 0, @pathname, 'Insert', @i_userid, 
			@count, 'File and Path Name', @o_error_code output, @o_error_desc output

	exec qtitle_update_titlehistory 'filelocation', 'sendtoeloquenceind' , @i_bookkey, @i_printingkey, 0, @filesendtoeloquenceind, 'Insert', @i_userid, 
			@count, 'Send Image to Eloquence', @o_error_code output, @o_error_desc output

	exec qtitle_update_titlehistory 'filelocation', 'filetypecode' , @i_bookkey, @i_printingkey, 0, @filetype, 'Insert', @i_userid, 
			@count, 'File Type', @o_error_code output, @o_error_desc output

end

set nocount off

end
