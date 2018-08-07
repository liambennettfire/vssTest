
IF OBJECT_ID('dbo.UpdFld_ActiveDate') IS NOT NULL DROP PROCEDURE dbo.UpdFld_ActiveDate
GO

CREATE PROCEDURE dbo.UpdFld_ActiveDate
@bookkey       int,
@datetypecode  int,
@record_buffer varchar(2000),
@offset        int,
@length        int,
@userid        varchar(30),
@o_error_code  int output,
@o_error_desc  varchar(2000) output
AS
BEGIN

declare @newvalue varchar(256)  -- textual representation of new value extracted from record/field buffer
set @newvalue = ltrim(rtrim(substring(@record_buffer, @offset, @length)))

declare @new_datevalue datetime
declare @old_datevalue datetime

declare @codedesc varchar(40)  -- to fetch datadesc field in datetype table corresponding to @datatypecode
declare @transaction_type varchar(10)

declare @is_nullable int
select	@is_nullable = (case upper(is_nullable) when 'NO' then 0 else 1 end)
from	information_schema.columns
where	table_name = 'bookdates' and column_name = 'activedate'

if len(@newvalue) = 0 and @is_nullable = 1
	set @new_datevalue = null
else
	set @new_datevalue = convert(datetime, @newvalue)


IF NOT EXISTS (select * from bookdates where bookkey = @bookkey and datetypecode = @datetypecode and printingkey = 1)
BEGIN
	set @transaction_type = 'insert'  -- parameter to dbo.qtitle_update_titlehistory

	insert into bookdates (bookkey, printingkey, datetypecode, activedate, actualind, sortorder, lastuserid, lastmaintdate)
	values (@bookkey, 1, @datetypecode, @new_datevalue, 0, 1, @userid, getdate())
END
ELSE
BEGIN
	select	@old_datevalue = activedate
	from	bookdates
	where	bookkey = @bookkey
			and datetypecode = @datetypecode
			and printingkey = 1

	if @new_datevalue = @old_datevalue OR (@new_datevalue is null AND @old_datevalue is null) begin
		set @o_error_code = 0
		set @o_error_desc = null
		RETURN
	end

	set @transaction_type = 'update'  -- parameter to dbo.qtitle_update_titlehistory

	update	bookdates
	set		activedate = @new_datevalue,
			lastuserid = @userid,
			lastmaintdate = getdate()
	where	bookkey = @bookkey
			and datetypecode = @datetypecode
			and printingkey = 1
END

if (@@ERROR < 0) begin
	set @o_error_code = @@ERROR - 100  -- -100 to distinguish from other error codes in UpdFld_XXXX
	set @o_error_desc = 'System Error: @@ERROR value (' + convert(varchar,@@ERROR) + ') during ' + @transaction_type + ' by dbo.UpdFld_ActiveDate.'
end
else begin
	-- Get description corresponding to @datetypecode for distinguishing in titlehistory text representation

	select	@codedesc = [description]
	from	datetype
	where	datetypecode = @datetypecode

	if @new_datevalue is null begin
		set @newvalue = ''  -- dbo.qtitle_update_titlehistory doesn't always handle NULL value well
		if @transaction_type = 'update'
			set @transaction_type = 'delete'
	end

	declare @columnname   varchar(30)
	set     @columnname = 'activedate'

	EXEC dbo.qtitle_update_titlehistory 'bookdates', @columnname, @bookkey, 1, @datetypecode, @newvalue,
		@transaction_type, @userid, 1, @codedesc, @o_error_code output, @o_error_desc output
end

END
GO
