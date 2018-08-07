
IF OBJECT_ID('dbo.UpdFld_Table_isbn') IS NOT NULL DROP PROCEDURE dbo.UpdFld_Table_isbn
GO

CREATE PROCEDURE dbo.UpdFld_Table_isbn
@bookkey       int,
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

declare @column_datatype varchar(30)
declare @is_nullable     int

select  @column_datatype = lower(data_type),
		@is_nullable     = (case upper(is_nullable) when 'NO' then 0 else 1 end)
from	information_schema.columns
where	table_name = 'isbn' and column_name = @columnname

-- YOU MAY NEED TO TWEAK/ADD HERE FOR LESS COMMON DATA TYPES AND SITUATIONS, BUT WE CAN CONSOLIDATE THESE
-- TYPES BECAUSE THE CONVERSION/COMPARISON BETWEEN THEM IS GENERALLY STRAIGHTFORWARD AND INCONSEQUENTIAL.
if @column_datatype in ('int', 'tinyint', 'smallint')
	set @column_datatype = 'int'
else if @column_datatype in ('varchar', 'char')
	set @column_datatype = 'varchar'


declare @newvalue varchar(256)  -- textual representation of new value extracted from record/field buffer
set @newvalue = ltrim(rtrim(substring(@record_buffer, @offset, @length)))

-- DECLARE THE NEW/OLD PAIRS OF DATATYPES YOU NEED.  THE NAMES MUST CONFORM TO THE PATTERN YOU SEE DECLARED FOR
-- THE TYPES BELOW BECAUSE THE GenerateColumnText.sql SCRIPT USES THIS PATTERN IN THE AUTO-GENERATED OUTPUT.

declare @new_intvalue int
declare @old_intvalue int

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
	set @new_varcharvalue = null

	if @column_datatype not in ( 'int', 'varchar' ) begin
		set @o_error_code = -1  -- not set up to handle this type (at least currently)
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_isbn is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
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
	else if @column_datatype = 'varchar'
		set @new_varcharvalue = @newvalue
	else begin
		set @o_error_code = -1  -- not set up to handle this type (at least currently)
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_isbn is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
		RETURN
	end
end  -- check for non-empty (i.e. non-null) value



IF NOT EXISTS (select * from isbn where bookkey = @bookkey)
BEGIN
	set @transaction_type = 'insert'  -- parameter to dbo.qtitle_update_titlehistory

	-- FILL IN HERE (i.e. COPY/PASTE) WITH THE text_insert COLUMN DATA GENERATED BY THE GenerateConditionalText.sql SCRIPT.
	-- YOU DON'T NECESSARILY NEED TO INCLUDE ALL THE TABLE'S COLUMNS, BUT MAYBE EASIEST TO ADD ALL COLUMNS INITIALLY AND
	-- THEN COMMENT OUT THE COLUMNS YOU DON'T NEED WHICH CAN BE UNCOMMENTED LATER WHEN/IF BECOMES NECESSARY FOR OTHER CALLERS.

	if @columnname = 'eanprefixcode' insert isbn (bookkey, lastuserid, lastmaintdate, eanprefixcode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	--else if @columnname = 'isbnkey' insert isbn (bookkey, lastuserid, lastmaintdate, isbnkey) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'isbnprefixcode' insert isbn (bookkey, lastuserid, lastmaintdate, isbnprefixcode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'cloudproductid' insert isbn (bookkey, lastuserid, lastmaintdate, cloudproductid) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'dsmarc' insert isbn (bookkey, lastuserid, lastmaintdate, dsmarc) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'ean' insert isbn (bookkey, lastuserid, lastmaintdate, ean) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'ean13' insert isbn (bookkey, lastuserid, lastmaintdate, ean13) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'gtin' insert isbn (bookkey, lastuserid, lastmaintdate, gtin) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'gtin14' insert isbn (bookkey, lastuserid, lastmaintdate, gtin14) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'isbn' insert isbn (bookkey, lastuserid, lastmaintdate, isbn) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'isbn10' insert isbn (bookkey, lastuserid, lastmaintdate, isbn10) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'itemnumber' insert isbn (bookkey, lastuserid, lastmaintdate, itemnumber) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'lccn' insert isbn (bookkey, lastuserid, lastmaintdate, lccn) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'ttlcd' insert isbn (bookkey, lastuserid, lastmaintdate, ttlcd) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'upc' insert isbn (bookkey, lastuserid, lastmaintdate, upc) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)	
END
ELSE
BEGIN
	-- Bookkey already exists in the table, get its old value for the column for comparison to new value

	declare @changed int
	set     @changed = 1  -- begin by assuming changed, then check for no difference in appropriate value type

	-- FILL IN HERE (i.e. COPY/PASTE) WITH THE text_when COLUMN DATA GENERATED BY THE GenerateConditionalText.sql SCRIPT.
	-- YOU DON'T NECESSARILY NEED TO INCLUDE ALL THE TABLE'S COLUMNS, BUT MAYBE EASIEST TO ADD ALL COLUMNS INITIALLY AND
	-- THEN COMMENT OUT THE COLUMNS YOU DON'T NEED WHICH CAN BE UNCOMMENTED LATER WHEN/IF BECOMES NECESSARY FOR OTHER CALLERS.
	-- NOTE THAT ANY COLUMNS ADDED NEED TO BE PLACED IN THE APPROPRIATE "select @old_XXXXvalue =" BLOCK CORRESPONDING TO
	-- THAT COLUMN'S DATA_TYPE.

	if @column_datatype = 'int'
	begin
		select @old_intvalue =
				case @columnname
					when 'eanprefixcode' then eanprefixcode
					--when 'isbnkey' then isbnkey
					when 'isbnprefixcode' then isbnprefixcode
					else null
				end
		from	isbn
		where	bookkey = @bookkey

		if @new_intvalue = @old_intvalue OR (@new_intvalue is null AND @old_intvalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'varchar'
	begin
		select @old_varcharvalue =
				case @columnname
					when 'cloudproductid' then cloudproductid
					when 'dsmarc' then dsmarc
					when 'ean' then ean
					when 'ean13' then ean13
					when 'gtin' then gtin
					when 'gtin14' then gtin14
					when 'isbn' then isbn
					when 'isbn10' then isbn10
					when 'itemnumber' then itemnumber
					when 'lastuserid' then lastuserid
					when 'lccn' then lccn
					when 'ttlcd' then ttlcd
					when 'upc' then upc
					else null
				end
		from	isbn
		where	bookkey = @bookkey

		if @new_varcharvalue = @old_varcharvalue OR (@new_varcharvalue is null AND @old_varcharvalue is null)
			set @changed = 0
	end

	if @changed = 0 begin
		set @o_error_code = 0
		set @o_error_desc = null
		RETURN  -- no change, no error
	end

	-- The new value for this bookkey is different than the old value, so update it in the table

	set @transaction_type = 'update'  -- parameter to dbo.qtitle_update_titlehistory

	-- FILL IN HERE (i.e. COPY/PASTE) WITH THE text_update COLUMN DATA GENERATED BY THE GenerateConditionalText.sql SCRIPT.
	-- YOU DON'T NECESSARILY NEED TO INCLUDE ALL THE TABLE'S COLUMNS, BUT MAYBE EASIEST TO ADD ALL COLUMNS INITIALLY AND
	-- THEN COMMENT OUT THE COLUMNS YOU DON'T NEED WHICH CAN BE UNCOMMENTED LATER WHEN/IF BECOMES NECESSARY FOR OTHER CALLERS.

	if @columnname = 'eanprefixcode' update isbn set eanprefixcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	--else if @columnname = 'isbnkey' update isbn set isbnkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'isbnprefixcode' update isbn set isbnprefixcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'cloudproductid' update isbn set cloudproductid=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'dsmarc' update isbn set dsmarc=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'ean' update isbn set ean=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'ean13' update isbn set ean13=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'gtin' update isbn set gtin=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'gtin14' update isbn set gtin14=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'isbn' update isbn set isbn=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'isbn10' update isbn set isbn10=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'itemnumber' update isbn set itemnumber=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'lccn' update isbn set lccn=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'ttlcd' update isbn set ttlcd=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'upc' update isbn set upc=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
END



if (@@ERROR < 0) begin
	set @o_error_code = @@ERROR - 100  -- -100 to distinguish from other error codes in UpdFld_XXXX
	set @o_error_desc = 'System Error: @@ERROR value (' + convert(varchar,@@ERROR) + ') during ' + @transaction_type + ' by dbo.UpdFld_Table_isbn.'
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
	declare @i_fielddesc_detail varchar(120)
	set     @i_fielddesc_detail = null

	EXEC dbo.qtitle_update_titlehistory 'isbn', @columnname, @bookkey, 1, 0, @newvalue,
		@transaction_type, @lastuserid, 1, @i_fielddesc_detail, @o_error_code output, @o_error_desc output
end

END
GO
