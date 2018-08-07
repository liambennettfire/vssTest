
IF OBJECT_ID('dbo.UpdFld_Table_bindingspecs') IS NOT NULL DROP PROCEDURE dbo.UpdFld_Table_bindingspecs
GO

CREATE PROCEDURE dbo.UpdFld_Table_bindingspecs
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
where	table_name = 'bindingspecs' and column_name = @columnname

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
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_bindingspecs is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
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
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_bindingspecs is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
		RETURN
	end
end  -- check for non-empty (i.e. non-null) value




IF NOT EXISTS (select * from bindingspecs where bookkey = @bookkey)
BEGIN
	set @transaction_type = 'insert'  -- parameter to dbo.qtitle_update_titlehistory

	-- FILL IN HERE (i.e. COPY/PASTE) WITH THE text_insert COLUMN DATA GENERATED BY THE GenerateConditionalText.sql SCRIPT.
	-- YOU DON'T NECESSARILY NEED TO INCLUDE ALL THE TABLE'S COLUMNS, BUT MAYBE EASIEST TO ADD ALL COLUMNS INITIALLY AND
	-- THEN COMMENT OUT THE COLUMNS YOU DON'T NEED WHICH CAN BE UNCOMMENTED LATER WHEN/IF BECOMES NECESSARY FOR OTHER CALLERS.

	if @columnname = 'diecutind' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, diecutind) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'endpapertype' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, endpapertype) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'gatefoldind' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, gatefoldind) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'oblongind' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, oblongind) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'prepackind' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, prepackind) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'topstainind' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, topstainind) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'backingcode' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, backingcode) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'cartonqty1' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, cartonqty1) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'printingkey' insert bindingspecs (bookkey, lastuserid, lastmaintdate, printingkey) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'vendorkey' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, vendorkey) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'bindingmethod' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, bindingmethod) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'booktrim' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, booktrim) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'covertype' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, covertype) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'endpapermatl' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, endpapermatl) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'insert16page' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert16page) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'insert24page' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert24page) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'insert2page' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert2page) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'insert32page' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert32page) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'insert4page' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert4page) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'insert8page' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert8page) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'reinforcements' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, reinforcements) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'cartontype' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, cartontype) values (@bookkey, 1, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'bindingdie' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, bindingdie) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'bindsignatures' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, bindsignatures) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'diecutcomments' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, diecutcomments) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'endpapercolor' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, endpapercolor) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'gatefoldcomments' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, gatefoldcomments) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'insert16pgtext' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert16pgtext) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'insert24pgtext' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert24pgtext) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'insert2pgtext' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert2pgtext) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'insert32pgtext' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert32pgtext) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'insert4pgtext' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert4pgtext) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'insert8pgtext' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, insert8pgtext) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'topstaincolor' insert bindingspecs (bookkey, printingkey, lastuserid, lastmaintdate, topstaincolor) values (@bookkey, 1, @lastuserid, @dtstamp, @new_varcharvalue)
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
					when 'backingcode' then backingcode
					when 'cartonqty1' then cartonqty1
					when 'printingkey' then printingkey
					when 'vendorkey' then vendorkey
					when 'bindingmethod' then bindingmethod
					when 'booktrim' then booktrim
					when 'covertype' then covertype
					when 'endpapermatl' then endpapermatl
					when 'insert16page' then insert16page
					when 'insert24page' then insert24page
					when 'insert2page' then insert2page
					when 'insert32page' then insert32page
					when 'insert4page' then insert4page
					when 'insert8page' then insert8page
					when 'reinforcements' then reinforcements
					when 'cartontype' then cartontype
					else null
				end
		from	bindingspecs
		where	bookkey = @bookkey

		if @new_intvalue = @old_intvalue OR (@new_intvalue is null AND @old_intvalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'varchar'
	begin
		select @old_varcharvalue =
				case @columnname
					when 'bindingdie' then bindingdie
					when 'bindsignatures' then bindsignatures
					when 'diecutcomments' then diecutcomments
					when 'endpapercolor' then endpapercolor
					when 'gatefoldcomments' then gatefoldcomments
					when 'insert16pgtext' then insert16pgtext
					when 'insert24pgtext' then insert24pgtext
					when 'insert2pgtext' then insert2pgtext
					when 'insert32pgtext' then insert32pgtext
					when 'insert4pgtext' then insert4pgtext
					when 'insert8pgtext' then insert8pgtext
					when 'topstaincolor' then topstaincolor
					-- the following columns are of type char but the varchar conversion/comparison is straighforward in both directions
					when 'diecutind' then diecutind
					when 'endpapertype' then endpapertype
					when 'gatefoldind' then gatefoldind
					when 'oblongind' then oblongind
					when 'prepackind' then prepackind
					when 'topstainind' then topstainind
					else null
				end
		from	bindingspecs
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

	if @columnname = 'diecutind' update bindingspecs set diecutind=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'endpapertype' update bindingspecs set endpapertype=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'gatefoldind' update bindingspecs set gatefoldind=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'oblongind' update bindingspecs set oblongind=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'prepackind' update bindingspecs set prepackind=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'topstainind' update bindingspecs set topstainind=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'backingcode' update bindingspecs set backingcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'cartonqty1' update bindingspecs set cartonqty1=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'printingkey' update bindingspecs set printingkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'vendorkey' update bindingspecs set vendorkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'bindingmethod' update bindingspecs set bindingmethod=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'booktrim' update bindingspecs set booktrim=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'covertype' update bindingspecs set covertype=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'endpapermatl' update bindingspecs set endpapermatl=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert16page' update bindingspecs set insert16page=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert24page' update bindingspecs set insert24page=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert2page' update bindingspecs set insert2page=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert32page' update bindingspecs set insert32page=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert4page' update bindingspecs set insert4page=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert8page' update bindingspecs set insert8page=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'reinforcements' update bindingspecs set reinforcements=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'cartontype' update bindingspecs set cartontype=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'bindingdie' update bindingspecs set bindingdie=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'bindsignatures' update bindingspecs set bindsignatures=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'diecutcomments' update bindingspecs set diecutcomments=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'endpapercolor' update bindingspecs set endpapercolor=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'gatefoldcomments' update bindingspecs set gatefoldcomments=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert16pgtext' update bindingspecs set insert16pgtext=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert24pgtext' update bindingspecs set insert24pgtext=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert2pgtext' update bindingspecs set insert2pgtext=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert32pgtext' update bindingspecs set insert32pgtext=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert4pgtext' update bindingspecs set insert4pgtext=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'insert8pgtext' update bindingspecs set insert8pgtext=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'topstaincolor' update bindingspecs set topstaincolor=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
END



if (@@ERROR < 0) begin
	set @o_error_code = @@ERROR - 100  -- -100 to distinguish from other error codes in UpdFld_XXXX
	set @o_error_desc = 'System Error: @@ERROR value (' + convert(varchar,@@ERROR) + ') during ' + @transaction_type + ' by dbo.UpdFld_Table_bindingspecs.'
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

	EXEC dbo.qtitle_update_titlehistory 'bindingspecs', @columnname, @bookkey, 1, 0, @newvalue,
		@transaction_type, @lastuserid, 1, @i_fielddesc_detail, @o_error_code output, @o_error_desc output
end

END
GO
