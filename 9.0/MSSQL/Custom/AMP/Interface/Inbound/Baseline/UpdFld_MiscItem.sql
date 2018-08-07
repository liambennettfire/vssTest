
IF OBJECT_ID('dbo.UpdFld_MiscItem') IS NOT NULL DROP PROCEDURE dbo.UpdFld_MiscItem
GO

CREATE PROCEDURE dbo.UpdFld_MiscItem
@bookkey       int,
@misckey       int,
@codeform      int, -- 0 if misckey's misctype<>5 (not a gentables code), otherwise 1=code#, 2=externalcode, 3=datadesc
@record_buffer varchar(2000),
@offset        int,
@length        int,
@userid        varchar(30),
@o_error_code  int output,
@o_error_desc  varchar(2000) output
AS
BEGIN

declare @miscname varchar(40)
declare @misctype int
declare @misctype5_datacode int
declare @sendtoeloind int
declare @itemtype int
declare @th_col_key int
declare @transaction_type varchar(10)

declare @longvalue int
declare @floatvalue float
declare @textvalue varchar(2000)

declare @old_longvalue int
declare @old_floatvalue float
declare @old_textvalue varchar(2000)


declare @newvalue varchar(2000)  -- textual representation of new value extracted from record/field buffer
set @newvalue = ltrim(rtrim(substring(@record_buffer, @offset, @length)))

select	@miscname = miscname,
		@misctype = misctype,
		@misctype5_datacode = datacode,
		@sendtoeloind = sendtoeloquenceind
from	bookmiscitems
where	misckey = @misckey

-- Initialize all 3 possible data types to null so only the correct corresponding one will change when we update table
-- (We know/assume all of these are nullable table values, and write null in place of "empty" values)
set @longvalue = null
set @floatvalue = null
set @textvalue = null

if @misctype = 1 begin
	set @itemtype = 1
	set @th_col_key = 225
	if len(@newvalue) > 0  -- null otherwise
		set @longvalue = convert(int, @newvalue)
end
if @misctype = 2 begin
	set @itemtype = 2
	set @th_col_key = 226
	if len(@newvalue) > 0  -- null otherwise
		set @floatvalue = convert(float, @newvalue)
end
if @misctype = 3 begin
	set @itemtype = 3
	set @th_col_key = 227
	if len(@newvalue) > 0  -- null otherwise
		set @textvalue = @newvalue
end
if @misctype = 4 begin  -- 4=checkbox
	set @itemtype = 1
	set @th_col_key = 247
	if len(@newvalue) > 0 begin  -- null otherwise
		if @newvalue = 'N' OR @newvalue = '0'
			set @longvalue = 0
		else
			set @longvalue = 1
		/*
		-- Convert to friendly/descriptive format for titlehistory
		if @longvalue = 1 set @newvalue = 'Y'
		if @longvalue = 0 set @newvalue = 'N'
		*/
		if @longvalue = 1 set @newvalue = '1'  -- dbo.qtitle_update_titlehistory only pays attention to whether value is '1' or NOT '1'
		/*
		if @newvalue <> '1'  -- dbo.qtitle_update_titlehistory only pays attention to whether value is '1' or NOT '1'
			set @longvalue = 0
		else
			set @longvalue = 1
		*/
	end
end
if @misctype = 5 begin  -- 5=gentables
	set @itemtype = 1
	set @th_col_key = 248

	-- Convert value from datasubcode to its corresponding descriptive value (or vice versa)

	if len(@newvalue) > 0  -- null otherwise
	begin
		if @codeform = 1                             -- need to do this out here because db engine "pre-evaluates" expression and 
			set @longvalue = convert(int, @newvalue) -- otherwise will get an error in where clause below, even when @codeform <> 1

		select	@longvalue = datasubcode,
				@newvalue = datadesc
		from	subgentables
		where	tableid = 525  -- 525 = misctable id
				and
				datacode = @misctype5_datacode
				and
				deletestatus = 'N'
				and
				(
				  --(@codeform = 1 and datasubcode = convert(int, @newvalue))  -- buffer holds datasubcode number as text
					(@codeform = 1 and datasubcode = @longvalue)               -- buffer holds datasubcode number as text
					or
					(@codeform = 2 and upper(externalcode) = upper(@newvalue)) -- buffer holds external-code corresponding to datasubcode
					or
					(@codeform = 3 and upper(datadesc) = upper(@newvalue))     -- buffer holds datadesc/display-label corresponding to datasubcode
				)
	end
end



IF NOT EXISTS (select * from bookmisc where bookkey = @bookkey and misckey = @misckey)
BEGIN
	set @transaction_type = 'insert'  -- parameter to dbo.qtitle_update_titlehistory

	if @longvalue is null AND @floatvalue is null AND @textvalue is null begin
		set @o_error_code = 0
		set @o_error_desc = null
		RETURN   -- no need to insert a brand new bookmisc record for a null value, would just create pointless clutter
	end

	insert into bookmisc (bookkey, misckey, longvalue, floatvalue, textvalue, lastuserid, lastmaintdate, sendtoeloquenceind)
	values (@bookkey, @misckey, @longvalue, @floatvalue, @textvalue, @userid, getdate(), @sendtoeloind)
END
ELSE
BEGIN
	select	@old_longvalue = longvalue,
			@old_floatvalue = floatvalue,
			@old_textvalue = textvalue
	from	bookmisc
	where	bookkey = @bookkey and misckey = @misckey

	declare @changed int
	set @changed = 1  -- begin by assuming changed, then check for no difference in appropriate value type

	if @itemtype = 1 begin
		if @longvalue = @old_longvalue OR (@longvalue is null AND @old_longvalue is null)
			set @changed = 0
	end
	if @itemtype = 2 begin
		if @floatvalue = @old_floatvalue OR (@floatvalue is null AND @old_floatvalue is null)
			set @changed = 0
	end
	if @itemtype = 3 begin
		if @textvalue = @old_textvalue OR (@textvalue is null AND @old_textvalue is null)
			set @changed = 0
	end

	-- If there's no actual change, then should we do the update anyway since the value won't change but
	-- the lastmaintdate field will?  Updating anyway would show that the value has been "reaffirmed" more
	-- recently as opposed to possibility that value hasn't been updated in long time and may be out of date.
	-- Would still need to know if actually changed for purpose of updating titlehistory table.

	if @changed = 0 begin
		set @o_error_code = 0
		set @o_error_desc = null
		RETURN
	end

	set @transaction_type = 'update'  -- parameter to dbo.qtitle_update_titlehistory

	-- We can assign all 3 value types here, the 2 unused value types for this key won't change from null
	update	bookmisc
	set		longvalue = @longvalue,
			floatvalue = @floatvalue,
			textvalue = @textvalue,
			lastuserid = @userid,
			lastmaintdate = getdate()
	where	bookkey = @bookkey
			and misckey = @misckey
END

if (@@ERROR < 0) begin
	set @o_error_code = @@ERROR - 100  -- -100 to distinguish from other error codes in UpdFld_XXXX
	set @o_error_desc = 'System Error: @@ERROR value (' + convert(varchar,@@ERROR) + ') during ' + @transaction_type + ' by dbo.UpdFld_MiscItem.'
end
else begin

	if @longvalue is null AND @floatvalue is null AND @textvalue is null begin
		set @newvalue = ''  -- dbo.qtitle_update_titlehistory doesn't always handle NULL value well
		if @transaction_type = 'update'
			set @transaction_type = 'delete'
	end

	declare @columnname   varchar(30)
	select  @columnname = columnname from titlehistorycolumns where tablename = 'bookmisc' and columnkey = @th_col_key

	EXEC dbo.qtitle_update_titlehistory 'bookmisc', @columnname, @bookkey, 1, 0, @newvalue,
		@transaction_type, @userid, 1, @miscname, @o_error_code output, @o_error_desc output
end

END
GO
