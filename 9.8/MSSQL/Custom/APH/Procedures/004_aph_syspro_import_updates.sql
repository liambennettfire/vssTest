IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aph_syspro_import_updates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[aph_syspro_import_updates]
/****** Object:  StoredProcedure [dbo].[aph_syspro_import_updates]    Script Date: 08/11/2008 11:06:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






create PROCEDURE [dbo].[aph_syspro_import_updates] AS

declare		@error_var		int,
			@rowcount_var	int,
			@misckey		int,
			@minkey			int,
			@numrows		int,
			@counter		int,
			@itemnumber		varchar(30),
			@bookkey		int,
			@error_code		int,
			@newuom			varchar(500),
			@newweb			varchar(500),
			@newwarehouse	varchar(500),
			@newobsolete	varchar(500),
			@newfq			varchar(500),
			@newdateadded	varchar(500),
			@newtitle		varchar(500),
			@existingvalue		varchar(500),
			@existingshorttitle		varchar(500),
			@existingdate	datetime,
			@error_desc		varchar(255),
			@datacode	int, 
			@qsibatchkey	int,
			@qsijobkey		int,
			@field			varchar(100),
			@fieldfull		varchar(100)


BEGIN 

set @qsibatchkey = null
set @qsijobkey = null

exec write_qsijobmessage @qsibatchkey output, @qsijobkey output, 3,1,null,null,'QSIADMIN',0,0,0,1,'job started','started',@error_code output, @error_desc output

select @minkey = min(id_num), @numrows = count(*)
from aph_syspro_import a
join isbn i
on a.stockcode = i.itemnumber
where (uom is not null
and uom <> '')
or (web is not null
and web <> '')
or (dateitemadded is not null
and dateitemadded <> '')
or (obsolete is not null
and obsolete <> '')
or (warehouse is not null
and warehouse <> '')
or (fq is not null
and fq <> '')
or (description is not null
and description <> '')

set @counter = 1

while @counter <= @numrows
begin
	set @newuom = ''
	set @newweb = ''
	set @newwarehouse = ''
	set @newobsolete = ''
	set @newfq = ''
	set @newdateadded = ''
	set @newtitle = ''

	select @itemnumber = stockcode, @bookkey = i.bookkey, @newuom = uom,
			@newweb = web, @newwarehouse = warehouse, @newobsolete = obsolete,
			@newdateadded = dateitemadded, @newfq = fq, @newtitle = description
	from aph_syspro_import a
	join isbn i
	on a.stockcode = i.itemnumber
	where id_num = @minkey

	if @newuom is not null and @newuom <> ''	
	begin
		set @datacode = 3
		set @misckey = 10
		set @field = 'UOM'
		set @fieldfull = 'Unit of Measure Code'

		exec aph_syspro_import_misc @misckey, @itemnumber, @bookkey, @newuom, @datacode,
			@qsibatchkey, @qsijobkey, @field, @fieldfull, @error_code OUTPUT, @error_desc OUTPUT
		if @error_code = -1
		begin
			return
		end
	end

	if @newobsolete is not null and @newobsolete <> ''
	begin
		set @datacode = 5
		set @misckey = 13
		set @field = 'Obsolete'
		set @fieldfull = 'Obsolete'
		exec aph_syspro_import_misc @misckey, @itemnumber, @bookkey, @newobsolete, @datacode,
			@qsibatchkey, @qsijobkey, @field, @fieldfull, @error_code OUTPUT, @error_desc OUTPUT
		if @error_code = -1
		begin
			return
		end
	end

	if @newwarehouse is not null and @newwarehouse <> ''
	begin
		set @datacode = 4
		set @misckey = 12
		set @field = 'Warehouse'
		set @fieldfull = 'Warehouse'
		exec aph_syspro_import_misc @misckey, @itemnumber, @bookkey, @newwarehouse, @datacode,
			@qsibatchkey, @qsijobkey, @field, @fieldfull, @error_code OUTPUT, @error_desc OUTPUT
		if @error_code = -1
		begin
			return
		end
	end

	if @newweb is not null and @newweb <> ''
	begin
		set @datacode = 0
		set @misckey = 2
		set @field = 'Web'
		set @fieldfull = 'Web'
		exec aph_syspro_import_misc @misckey, @itemnumber, @bookkey, @newweb, @datacode,
			@qsibatchkey, @qsijobkey, @field, @fieldfull, @error_code OUTPUT, @error_desc OUTPUT
		if @error_code = -1
		begin
			return
		end
	end

	if @newfq is not null and @newfq <> ''
	begin
		set @datacode = 0
		set @misckey = 11
		set @field = 'FQ'
		set @fieldfull = 'Federal Quota'
		exec aph_syspro_import_misc @misckey, @itemnumber, @bookkey, @newfq, @datacode,
			@qsibatchkey, @qsijobkey, @field, @fieldfull, @error_code OUTPUT, @error_desc OUTPUT
		if @error_code = -1
		begin
			return
		end
	end

	if @newdateadded is not null and @newdateadded <> ''
	begin
		select @existingdate = creationdate
		from book
		where bookkey = @bookkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
			SET @error_code = -1
			SET @error_desc = 'Unable to select from book table.  Error #' + cast(@error_var as varchar(20))
			exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
			RETURN
		END 
	
		if isnull(@existingdate,'') <> isnull(cast (@newdateadded as datetime),'')
		begin
			update book
			set creationdate = cast (@newdateadded as datetime),
				lastuserid = 'QSIADMIN',
				lastmaintdate = getdate()
			where bookkey = @bookkey

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
				SET @error_code = -1
				SET @error_desc = 'Unable to update book table.  Error #' + cast(@error_var as varchar(20))
				exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
				RETURN
			END 
		end
	end
		
	if @newtitle is not null and @newtitle <> ''
	begin
		select @existingvalue = title, @existingshorttitle = shorttitle
		from book
		where bookkey = @bookkey

		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @error_var <> 0 BEGIN
			SET @error_code = -1
			SET @error_desc = 'Unable to select from book table.  Error #' + cast(@error_var as varchar(20))
			exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
			RETURN
		END 
	
		if isnull(@existingvalue,'') = ''	--title is blank and newtitle is not
		begin
			update book
			set title = @newtitle,
				lastuserid = 'QSIADMIN',
				lastmaintdate = getdate()
			where bookkey = @bookkey

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
				SET @error_code = -1
				SET @error_desc = 'Unable to update book table.  Error #' + cast(@error_var as varchar(20))
				exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
				RETURN
			END 
		end

		if isnull(@existingshorttitle,'') = ''	--shorttitle is blank and newtitle is not
		begin
			update book
			set shorttitle = @newtitle,
				lastuserid = 'QSIADMIN',
				lastmaintdate = getdate()
			where bookkey = @bookkey

			SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			IF @error_var <> 0 BEGIN
				SET @error_code = -1
				SET @error_desc = 'Unable to update book table.  Error #' + cast(@error_var as varchar(20))
				exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',0,0,0,5,@error_desc,null,@error_code output, @error_desc output
				RETURN
			END 
		end
	end

	set @counter = @counter + 1

	select @minkey = min(id_num)
	from aph_syspro_import a
	join isbn i
	on a.stockcode = i.itemnumber
	where uom is not null
	and uom <> ''
	and id_num > @minkey

end

exec write_qsijobmessage @qsibatchkey, @qsijobkey, 3,1,null,null,'QSIADMIN',0,0,0,6,'job completed','completed',@error_code output, @error_desc output

end
