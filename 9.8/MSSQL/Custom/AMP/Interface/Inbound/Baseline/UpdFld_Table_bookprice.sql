

IF OBJECT_ID('dbo.UpdFld_Table_bookprice') IS NOT NULL DROP PROCEDURE dbo.UpdFld_Table_bookprice
GO

CREATE PROCEDURE dbo.UpdFld_Table_bookprice
@pricekey      int,             -- WARNING: make sure you pass pricekey here instead of bookkey or could cause trouble
@columnname    varchar(100),
@tableid       int,             -- 0 if the column is not a gentables code
@codeform      int,             -- 0 if the column is not a gentables code, otherwise 1=code#, 2=externalcode, 3=datadesc
@parentcode    int,             -- only matters if @codeform is non-zero - data is a SUBgentables code under @parentcode
@record_buffer varchar(2000),
@offset        int,             -- base=1 (like substring())
@length        int,
@lastuserid    varchar(30),
@o_error_code  int output,
@o_error_desc  varchar(2000) output
AS
BEGIN

declare @column_datatype varchar(20)
declare @is_nullable     int

select  @column_datatype = lower(data_type),
		@is_nullable     = (case upper(is_nullable) when 'NO' then 0 else 1 end)
from	information_schema.columns
where	table_name = 'bookprice' AND column_name = @columnname

-- YOU MAY NEED TO TWEAK/ADD HERE FOR LESS COMMON DATA TYPES AND SITUATIONS, BUT WE CAN CONSOLIDATE THESE
-- TYPES BECAUSE THE CONVERSION/COMPARISON BETWEEN THEM IS GENERALLY STRAIGHTFORWARD AND INCONSEQUENTIAL.
if @column_datatype in ('int', 'tinyint', 'smallint')
	set @column_datatype = 'int'
else if @column_datatype in ('float', 'decimal', 'numeric', 'money')
	set @column_datatype = 'float'
else if @column_datatype in ('varchar', 'char')
	set @column_datatype = 'varchar'


declare @newvalue varchar(256)  -- textual representation of new value extracted from record/field buffer
set @newvalue = ltrim(rtrim(substring(@record_buffer, @offset, @length)))

-- DECLARE THE NEW/OLD PAIRS OF DATATYPES YOU NEED.  THE NAMES MUST CONFORM TO THE PATTERN YOU SEE DECLARED FOR
-- THE TYPES BELOW BECAUSE THE UpdFld_Table_AutoGenerateColumnText.sql SCRIPT USES THIS PATTERN IN THE AUTO-GENERATED OUTPUT.

declare @new_intvalue int
declare @old_intvalue int

declare @new_datetimevalue datetime
declare @old_datetimevalue datetime

declare @new_floatvalue float
declare @old_floatvalue float

declare @new_varcharvalue varchar(2000)
declare @old_varcharvalue varchar(2000)


declare @codedesc varchar(120)  -- to fetch datadesc field in gentables corresponding to the datacode
declare @transaction_type varchar(10)
declare @dtstamp datetime
set @dtstamp = getdate()


if len(@newvalue) = 0 and @is_nullable = 1 begin
	set @newvalue = null
	-- Easier to just set them all to null rather than check for the column's individual type
	-- Truth is, they're already initialized to null by default
	set @new_intvalue = null
	set @new_datetimevalue = null
	set @new_varcharvalue = null

	if @column_datatype not in ( 'int', 'datetime', 'varchar' ) begin
		set @o_error_code = -1  -- not set up to handle this type (at least currently)
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_bookprice is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
		RETURN
	end
end
else
begin
	if @codeform <> 0   -- the data item is represented as a code value
	begin
		if @codeform = 1                                -- need to do this here because db engine "pre-evaluates" expression and 
			set @new_intvalue = convert(int, @newvalue) -- otherwise will get an error in where clause below even when @codeform <> 1

		if @parentcode = 0   -- the column is a gentables value rather than a SUBgentables value
		begin
			select	@new_intvalue = datacode,
					@codedesc = datadesc
			from	gentables
			where	tableid = @tableid
					and
					deletestatus = 'N'
					and
					(
					  --(@codeform = 1 and datacode = convert(int, @newvalue))     -- buffer holds datacode number as text
						(@codeform = 1 and datacode = @new_intvalue)               -- buffer holds datacode number as text
						or
						(@codeform = 2 and upper(externalcode) = upper(@newvalue)) -- buffer holds external-code corresponding to datacode
						or
						(@codeform = 3 and upper(datadesc) = upper(@newvalue))     -- buffer holds datadesc/display-label corresponding to datacode
					)
		end
		else   -- the column is a SUBgentables value rather than a gentables value
		begin
			select	@new_intvalue = datasubcode,
					@codedesc = datadesc
			from	subgentables
			where	tableid = @tableid
					and
					datacode = @parentcode
					and
					deletestatus = 'N'
					and
					(
					  --(@codeform = 1 and datasubcode = convert(int, @newvalue))  -- buffer holds datacode number as text
						(@codeform = 1 and datasubcode = @new_intvalue)            -- buffer holds datacode number as text
						or
						(@codeform = 2 and upper(externalcode) = upper(@newvalue)) -- buffer holds external-code corresponding to datacode
						or
						(@codeform = 3 and upper(datadesc) = upper(@newvalue))     -- buffer holds datadesc/display-label corresponding to datacode
					)
		end
	end
	else if @column_datatype = 'int'
		set @new_intvalue = convert(int, @newvalue)
	else if @column_datatype = 'datetime'
		set @new_datetimevalue = convert(datetime, @newvalue)  -- validation should be done beforehand
	else if @column_datatype = 'float'
		set @new_floatvalue = convert(float, @newvalue)
	else if @column_datatype = 'varchar'
		set @new_varcharvalue = @newvalue
	else begin
		set @o_error_code = -1  -- not set up to handle this type (at least currently)
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_bookprice is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
		RETURN
	end
end  -- check for non-empty (i.e. non-null) value



IF NOT EXISTS (select * from bookprice where pricekey = @pricekey)
BEGIN
	-- This should probably generate an error - it's not really intended to be used this way (i.e. create a bookprice
	-- record without simultaneously specifying a bookkey, pricecode, currencycode, and activeind), but if used properly
	-- you could assemble a legitimate/appropriate record by rigorously building it one field at a time.

	set @transaction_type = 'insert'  -- parameter to dbo.qtitle_update_titlehistory

	-- FILL IN HERE (i.e. COPY/PASTE) WITH THE text_insert COLUMN DATA GENERATED BY THE UpdFld_Table_AutoGenerateConditionalText.sql
	-- SCRIPT.  YOU DON'T NECESSARILY NEED TO INCLUDE ALL THE TABLE'S COLUMNS, BUT MAYBE EASIEST TO ADD ALL COLUMNS INITIALLY AND
	-- THEN COMMENT OUT THE COLUMNS YOU DON'T NEED WHICH CAN BE UNCOMMENTED LATER WHEN/IF BECOMES NECESSARY FOR OTHER CALLERS.

	if @columnname = 'effectivedate' insert bookprice (pricekey, lastuserid, lastmaintdate, effectivedate) values (@pricekey, @lastuserid, @dtstamp, @new_datetimevalue)
	else if @columnname = 'expirationdate' insert bookprice (pricekey, lastuserid, lastmaintdate, expirationdate) values (@pricekey, @lastuserid, @dtstamp, @new_datetimevalue)
	else if @columnname = 'budgetprice' insert bookprice (pricekey, lastuserid, lastmaintdate, budgetprice) values (@pricekey, @lastuserid, @dtstamp, @new_floatvalue)
	else if @columnname = 'finalprice' insert bookprice (pricekey, lastuserid, lastmaintdate, finalprice) values (@pricekey, @lastuserid, @dtstamp, @new_floatvalue)
	else if @columnname = 'overrideprice' insert bookprice (pricekey, lastuserid, lastmaintdate, overrideprice) values (@pricekey, @lastuserid, @dtstamp, @new_floatvalue)
	else if @columnname = 'bookkey' insert bookprice (pricekey, lastuserid, lastmaintdate, bookkey) values (@pricekey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'history_order' insert bookprice (pricekey, lastuserid, lastmaintdate, history_order) values (@pricekey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'overrideprintingkey' insert bookprice (pricekey, lastuserid, lastmaintdate, overrideprintingkey) values (@pricekey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'sortorder' insert bookprice (pricekey, lastuserid, lastmaintdate, sortorder) values (@pricekey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'currencytypecode' insert bookprice (pricekey, lastuserid, lastmaintdate, currencytypecode) values (@pricekey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'pricetypecode' insert bookprice (pricekey, lastuserid, lastmaintdate, pricetypecode) values (@pricekey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'activeind' insert bookprice (pricekey, lastuserid, lastmaintdate, activeind) values (@pricekey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'applysetdiscountind' insert bookprice (pricekey, lastuserid, lastmaintdate, applysetdiscountind) values (@pricekey, @lastuserid, @dtstamp, @new_intvalue)
END
ELSE
BEGIN
	-- Pricekey already exists in the table, get its old value for the column for comparison to new value

	declare @changed int
	set     @changed = 1  -- begin by assuming changed, then check for no difference in appropriate value type

	-- FILL IN HERE (i.e. COPY/PASTE) WITH THE text_when COLUMN DATA GENERATED BY THE UpdFld_Table_AutoGenerateConditionalText.sql
	-- SCRIPT.  YOU DON'T NECESSARILY NEED TO INCLUDE ALL THE TABLE'S COLUMNS, BUT MAYBE EASIEST TO ADD ALL COLUMNS INITIALLY AND
	-- THEN COMMENT OUT THE COLUMNS YOU DON'T NEED WHICH CAN BE UNCOMMENTED LATER WHEN/IF BECOMES NECESSARY FOR OTHER CALLERS.
	-- NOTE THAT ANY COLUMNS ADDED NEED TO BE PLACED IN THE APPROPRIATE "select @old_XXXXvalue =" BLOCK CORRESPONDING TO
	-- THAT COLUMN'S DATA_TYPE.

	if @column_datatype = 'int'
	begin
		select @old_intvalue =
				case @columnname
					when 'bookkey' then bookkey
					when 'history_order' then history_order
					when 'overrideprintingkey' then overrideprintingkey
					when 'sortorder' then sortorder
					when 'currencytypecode' then currencytypecode
					when 'pricetypecode' then pricetypecode
					when 'activeind' then activeind
					when 'applysetdiscountind' then applysetdiscountind
					else null
				end
		from	bookprice
		where	pricekey = @pricekey

		if @new_intvalue = @old_intvalue OR (@new_intvalue is null AND @old_intvalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'datetime'
	begin
		select @old_datetimevalue =
				case @columnname
					when 'effectivedate' then effectivedate
					when 'expirationdate' then expirationdate
					else null
				end
		from	bookprice
		where	pricekey = @pricekey

		if @new_datetimevalue = @old_datetimevalue OR (@new_datetimevalue is null AND @old_datetimevalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'float'
	begin
		select @old_floatvalue =
				case @columnname
					when 'budgetprice' then budgetprice
					when 'finalprice' then finalprice
					when 'overrideprice' then overrideprice
					else null
				end
		from	bookprice
		where	pricekey = @pricekey

		if @new_floatvalue = @old_floatvalue OR (@new_floatvalue is null AND @old_floatvalue is null)
			set @changed = 0
	end

	if @changed = 0 begin
		set @o_error_code = 0
		set @o_error_desc = null
		RETURN  -- no change, no error
	end

	-- The new value for this pricekey is different than the old value, so update it in the table

	set @transaction_type = 'update'  -- parameter to dbo.qtitle_update_titlehistory

	-- FILL IN HERE (i.e. COPY/PASTE) WITH THE text_update COLUMN DATA GENERATED BY THE UpdFld_Table_AutoGenerateConditionalText.sql
	-- SCRIPT.  YOU DON'T NECESSARILY NEED TO INCLUDE ALL THE TABLE'S COLUMNS, BUT MAYBE EASIEST TO ADD ALL COLUMNS INITIALLY AND
	-- THEN COMMENT OUT THE COLUMNS YOU DON'T NEED WHICH CAN BE UNCOMMENTED LATER WHEN/IF BECOMES NECESSARY FOR OTHER CALLERS.

	if @columnname = 'effectivedate' update bookprice set effectivedate=@new_datetimevalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'expirationdate' update bookprice set expirationdate=@new_datetimevalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'budgetprice' update bookprice set budgetprice=@new_floatvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'finalprice' update bookprice set finalprice=@new_floatvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'overrideprice' update bookprice set overrideprice=@new_floatvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'bookkey' update bookprice set bookkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'history_order' update bookprice set history_order=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'overrideprintingkey' update bookprice set overrideprintingkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'sortorder' update bookprice set sortorder=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'currencytypecode' update bookprice set currencytypecode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'pricetypecode' update bookprice set pricetypecode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'activeind' update bookprice set activeind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
	else if @columnname = 'applysetdiscountind' update bookprice set applysetdiscountind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where pricekey=@pricekey
END



if (@@ERROR < 0) begin
	set @o_error_code = @@ERROR - 100  -- -100 to distinguish from other error codes in UpdFld_XXXX
	set @o_error_desc = 'System Error: @@ERROR value (' + convert(varchar,@@ERROR) + ') during ' + @transaction_type + ' by dbo.UpdFld_Table_book.'
end
else begin
	if @newvalue is null begin
		set @newvalue = ''  -- dbo.qtitle_update_titlehistory doesn't always handle NULL value well
		if @transaction_type = 'update'
			set @transaction_type = 'delete'
	end
	else begin
		if @codeform <> 0
			set @newvalue = @codedesc
	end

	-- IF A COLUMN(S) REQUIRES SPECIAL HANDLING OF DESCRIPTIVE TEXT FOR CALL TO qtitle_update_titlehistory, THEN DO THAT HERE.
	-- THE SPECIAL HANDLING IS MOSTLY FOR DATES AND PRICES, BUT MOST OF THOSE ARE HANDLED IN DEDICATED SPROC'S OF SIMILAR NATURE.
	declare @fielddesc_detail varchar(120)
	set     @fielddesc_detail = null

	declare @bookkey int
	set     @bookkey = (select bookkey from bookprice where pricekey = @pricekey)

/*** Should do this kind of thing where we set fielddesc_detail, etc for finalprice, etc, but users really should
	 use UpdFld_FinalPrice instead of this sproc to update finalprice.
	 If want to implement this, then can get price and currency codes via pricekey in same step to get bookkey above.

	-- Get descriptions corresponding to codes for distinguishing in titlehistory text representation

	select	@pricedesc = datadesc
	from	gentables
	where	tableid = 306
			and datacode = @pricecode

	select	@currencydesc = datadesc
	from	gentables
	where	tableid = 122
			and datacode = @currencycode
***/

	EXEC dbo.qtitle_update_titlehistory 'bookprice', @columnname, @bookkey, 1, 0, @newvalue,
		@transaction_type, @lastuserid, 1, @fielddesc_detail, @o_error_code output, @o_error_desc output
end

END
GO
