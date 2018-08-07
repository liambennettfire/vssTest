
IF OBJECT_ID('dbo.UpdFld_FinalPrice') IS NOT NULL DROP PROCEDURE dbo.UpdFld_FinalPrice
GO

CREATE PROCEDURE dbo.UpdFld_FinalPrice
@bookkey       int,
@pricecode     int,
@currencycode  int,
@activeind     int,
@effectivedate datetime,
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

declare @new_floatvalue float
declare @old_floatvalue float

declare @pricedesc    varchar(40)  -- to fetch datadescshort field in gentables corresponding to @pricecode
declare @currencydesc varchar(40)  -- to fetch datadescshort field in gentables corresponding to @currencycode
declare @history_order int

declare @transaction_type varchar(10)
declare @pricekey int


declare @is_nullable int
select	@is_nullable = (case upper(is_nullable) when 'NO' then 0 else 1 end)
from	information_schema.columns
where	table_name = 'bookprice' and column_name = 'finalprice'

if len(@newvalue) = 0 and @is_nullable = 1
	set @new_floatvalue = null
else
	set @new_floatvalue = convert(float, @newvalue)


IF NOT EXISTS (select * from bookprice where bookkey = @bookkey and currencytypecode = @currencycode and pricetypecode = @pricecode and activeind = @activeind)
BEGIN
	EXEC get_next_key @userid, @pricekey output

	--set @history_order = isnull( (select max(isnull(history_order,0)) from bookprice where bookkey = @bookkey), 0 ) + 1
	EXEC qtitle_get_next_history_order @bookkey, 0, 'bookprice', @userid, @history_order output, @o_error_code output, @o_error_desc output
	if (@o_error_code < 0)
		RETURN

	set @transaction_type = 'insert'  -- parameter to dbo.qtitle_update_titlehistory

	insert into bookprice (pricekey, bookkey, pricetypecode, currencytypecode, activeind, finalprice, effectivedate, lastuserid, lastmaintdate, sortorder, history_order)
	values (@pricekey, @bookkey, @pricecode, @currencycode, @activeind, @new_floatvalue, @effectivedate, @userid, getdate(), 1, @history_order)

	-- Re-order the TM pricelist after having inserted new price
	EXEC dbo.UpdFld_FinalPrice_ResortPriceList @bookkey, @userid
END
ELSE
BEGIN
	select	top 1
			@pricekey = pricekey,
			@old_floatvalue = finalprice,
			@history_order = history_order   -- remember for titlehistory update below
	from	bookprice
	where	bookkey = @bookkey
			and pricetypecode = @pricecode
			and currencytypecode = @currencycode
			and activeind = @activeind
	order by effectivedate desc   -- if it's an inactive price we're updating, then it's the one farthest into future or else most recent

	if @new_floatvalue = @old_floatvalue OR (@new_floatvalue is null AND @old_floatvalue is null) begin
		set @o_error_code = 0
		set @o_error_desc = null
		RETURN
	end

	set @transaction_type = 'update'  -- parameter to dbo.qtitle_update_titlehistory

	update	bookprice
	set		finalprice = @new_floatvalue,
			lastuserid = @userid,
			lastmaintdate = getdate()
	where	pricekey = @pricekey
END

if (@@ERROR < 0) begin
	set @o_error_code = @@ERROR - 100  -- -100 to distinguish from other error codes in UpdFld_XXXX
	set @o_error_desc = 'System Error: @@ERROR value (' + convert(varchar,@@ERROR) + ') during ' + @transaction_type + ' by dbo.UpdFld_FinalPrice.'
end
else begin
	-- Get descriptions corresponding to codes for distinguishing in titlehistory text representation

	select	@pricedesc = datadescshort
	from	gentables
	where	tableid = 306
			and datacode = @pricecode

	select	@currencydesc = datadescshort
	from	gentables
	where	tableid = 122
			and datacode = @currencycode

	if @new_floatvalue is null begin
		set @newvalue = ''  -- dbo.qtitle_update_titlehistory doesn't always handle NULL value well
		if @transaction_type = 'update'
			set @transaction_type = 'delete'
	end
	else begin
		set @newvalue = @newvalue + ' ' + @currencydesc  -- append e.g. USDL to text representation of value
	end

	declare @columnname   varchar(30)
	set     @columnname = 'finalprice'

	EXEC dbo.qtitle_update_titlehistory 'bookprice', @columnname, @bookkey, 1, 0, @newvalue,
		@transaction_type, @userid, @history_order, @pricedesc, @o_error_code output, @o_error_desc output
end

END
GO
