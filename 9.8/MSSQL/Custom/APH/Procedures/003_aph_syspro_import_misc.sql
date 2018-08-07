
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_syspro_import_misc]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[aph_syspro_import_misc]
/****** Object:  StoredProcedure [dbo].[aph_syspro_import_misc]    Script Date: 08/11/2008 14:40:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[aph_syspro_import_misc] 
			@misckey		int,
			@itemnumber		varchar(30),
			@bookkey		int,
			@newvalue		varchar(30),
			@datacode		int, 
			@qsibatchkey	int,
			@qsijobkey		int,
			@field			varchar(100),
			@fieldfull		varchar(100),
			@error_code		int OUTPUT,
			@error_desc		varchar(255) OUTPUT
AS

DECLARE		@existing		varchar(30),
			@action			varchar(30),
			@existingint	int,
			@gencount		int,
			@datasubcode	int, 
			@rowcount_var	int,
			@error_var		int
			

BEGIN 

set @existing = ''

if @field in ('UOM', 'Obsolete','Warehouse')	--misc fields based on gentables
begin
	select @existing = externalcode
	from bookmisc bm
	join subgentables sg
	on bm.longvalue = sg.datasubcode
	and sg.tableid = 525
	and sg.datacode = @datacode
	where bm.bookkey = @bookkey
	and bm.misckey = @misckey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @error_code = -1
		SET @error_desc = 'Unable to select from bookmisc table.  Error #' + cast(@error_var as varchar(20))
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
		RETURN
	END 

	if @rowcount_var = 1
	begin
		set @action = 'update'
	end
	else if @rowcount_var = 0 or @rowcount_var is null 
	begin
		set @action = 'insert'
	end

	if (isnull(@existing,'') <> isnull(@newvalue,'')) 
	begin
		select @datasubcode = datasubcode
		from subgentables sg
		where sg.tableid = 525
		and sg.datacode = @datacode
		and sg.externalcode = @newvalue

		set @gencount = @@ROWCOUNT

		if @gencount = 0 or @gencount is null
		begin
			SET @error_code = 1
			SET @error_desc = 'Missing '+@fieldfull+': ' + @newvalue + '.  Misc record not written for ' + @itemnumber + '.'
			exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',@bookkey,0,0,2,@error_desc,null,@error_code output, @error_desc output
			return
		end
	end
	else Return
end
else if @field in ('Web','FQ')	--0/1 - False/True misc fields
begin
	select @existingint = longvalue
	from bookmisc bm
	where bm.bookkey = @bookkey
	and bm.misckey = @misckey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @error_code = -1
		SET @error_desc = 'Unable to select from bookmisc table.  Error #' + cast(@error_var as varchar(20))
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
		RETURN
	END 

	if @rowcount_var = 1
	begin
		set @action = 'update'
	end
	else if @rowcount_var = 0 or @rowcount_var is null 
	begin
		set @action = 'insert'
	end

	if @newvalue = 'true'
	begin
		set @datasubcode = 1
	end
	else if @newvalue = 'false'
	begin
		set @datasubcode = 0
	end
	else
	begin
		SET @error_code = 1
		SET @error_desc = 'Unknown value for '+@fieldfull+': ' + @newvalue + '.  Misc record not written for ' + @itemnumber + '.'
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',@bookkey,0,0,2,@error_desc,null,@error_code output, @error_desc output
		return
	end
	
	if @existingint = @datasubcode
	begin
		RETURN
	end
end

if @action = 'update' 
begin
	update bookmisc
	set longvalue = @datasubcode,
		lastuserid = 'QSIADMIN',
		lastmaintdate = getdate()
	where bookmisc.bookkey = @bookkey
	and bookmisc.misckey = @misckey

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @error_code = -1
		SET @error_desc = 'Unable to update bookmisc for '+@field+'.  Error #' + cast(@error_var as varchar(20))
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',@bookkey,0,0,5,@error_desc,null,@error_code output, @error_desc output
		RETURN
	END 
end
else if @action = 'insert' 
begin
	insert into bookmisc
		(bookkey, misckey, longvalue, floatvalue, textvalue, lastuserid, lastmaintdate, sendtoeloquenceind)
	values
		(@bookkey, @misckey, @datasubcode, null, null, 'QSIADMIN', getdate(), 0)

	SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	IF @error_var <> 0 BEGIN
		SET @error_code = -1
		SET @error_desc = 'Unable to insert into bookmisc for '+@field+'.  Error #' + cast(@error_var as varchar(20))
		exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',@bookkey,0,0,5,@error_desc,null,@error_code output, @error_desc output
		RETURN
	END 
end

end
