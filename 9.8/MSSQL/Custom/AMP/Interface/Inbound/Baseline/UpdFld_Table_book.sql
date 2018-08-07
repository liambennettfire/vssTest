
IF OBJECT_ID('dbo.UpdFld_Table_book') IS NOT NULL DROP PROCEDURE dbo.UpdFld_Table_book
GO

CREATE PROCEDURE dbo.UpdFld_Table_book
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
where	table_name = 'book' and column_name = @columnname

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

declare @new_datetimevalue datetime
declare @old_datetimevalue datetime

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
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_book is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
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
		set @new_datetimevalue = convert(datetime, @newvalue)  -- error checking here? validation should be done beforehand
	else if @column_datatype = 'varchar'
		set @new_varcharvalue = @newvalue
	else begin
		set @o_error_code = -1  -- not set up to handle this type (at least currently)
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_book is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
		RETURN
	end
end  -- check for non-empty (i.e. non-null) value



IF NOT EXISTS (select * from book where bookkey = @bookkey)
BEGIN
	set @transaction_type = 'insert'  -- parameter to dbo.qtitle_update_titlehistory

	-- FILL IN HERE (i.e. COPY/PASTE) WITH THE text_insert COLUMN DATA GENERATED BY THE GenerateConditionalText.sql SCRIPT.
	-- YOU DON'T NECESSARILY NEED TO INCLUDE ALL THE TABLE'S COLUMNS, BUT MAYBE EASIEST TO ADD ALL COLUMNS INITIALLY AND
	-- THEN COMMENT OUT THE COLUMNS YOU DON'T NEED WHICH CAN BE UNCOMMENTED LATER WHEN/IF BECOMES NECESSARY FOR OTHER CALLERS.

	if @columnname = 'nolaterthanmonth' insert book (bookkey, lastuserid, lastmaintdate, nolaterthanmonth) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'nosoonerthanmonth' insert book (bookkey, lastuserid, lastmaintdate, nosoonerthanmonth) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'specsrecind' insert book (bookkey, lastuserid, lastmaintdate, specsrecind) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'standardind' insert book (bookkey, lastuserid, lastmaintdate, standardind) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'creationdate' insert book (bookkey, lastuserid, lastmaintdate, creationdate) values (@bookkey, @lastuserid, @dtstamp, @new_datetimevalue)
	else if @columnname = 'cycle' insert book (bookkey, lastuserid, lastmaintdate, cycle) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'elocustomerkey' insert book (bookkey, lastuserid, lastmaintdate, elocustomerkey) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'nextjobnbr' insert book (bookkey, lastuserid, lastmaintdate, nextjobnbr) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'primarycontractkey' insert book (bookkey, lastuserid, lastmaintdate, primarycontractkey) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'propagatefrombookkey' insert book (bookkey, lastuserid, lastmaintdate, propagatefrombookkey) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'ratecategorycode' insert book (bookkey, lastuserid, lastmaintdate, ratecategorycode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'scaleorgentrykey' insert book (bookkey, lastuserid, lastmaintdate, scaleorgentrykey) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'sendtoeloind' insert book (bookkey, lastuserid, lastmaintdate, sendtoeloind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'templatetypecode' insert book (bookkey, lastuserid, lastmaintdate, templatetypecode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'territoriescode' insert book (bookkey, lastuserid, lastmaintdate, territoriescode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'titlesourcecode' insert book (bookkey, lastuserid, lastmaintdate, titlesourcecode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'titlestatuscode' insert book (bookkey, lastuserid, lastmaintdate, titlestatuscode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'titletypecode' insert book (bookkey, lastuserid, lastmaintdate, titletypecode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'usageclasscode' insert book (bookkey, lastuserid, lastmaintdate, usageclasscode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'workkey' insert book (bookkey, lastuserid, lastmaintdate, workkey) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'nextprintingnbr' insert book (bookkey, lastuserid, lastmaintdate, nextprintingnbr) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'origpubhousecode' insert book (bookkey, lastuserid, lastmaintdate, origpubhousecode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'linklevelcode' insert book (bookkey, lastuserid, lastmaintdate, linklevelcode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'propagatefromprimarycode' insert book (bookkey, lastuserid, lastmaintdate, propagatefromprimarycode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'reuseisbnind' insert book (bookkey, lastuserid, lastmaintdate, reuseisbnind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'tmmwebtemplateind' insert book (bookkey, lastuserid, lastmaintdate, tmmwebtemplateind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'shorttitle' insert book (bookkey, lastuserid, lastmaintdate, shorttitle) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'sku' insert book (bookkey, lastuserid, lastmaintdate, sku) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'subtitle' insert book (bookkey, lastuserid, lastmaintdate, subtitle) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'title' insert book (bookkey, lastuserid, lastmaintdate, title) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
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
					when 'cycle' then cycle
					when 'elocustomerkey' then elocustomerkey
					when 'nextjobnbr' then nextjobnbr
					when 'primarycontractkey' then primarycontractkey
					when 'propagatefrombookkey' then propagatefrombookkey
					when 'ratecategorycode' then ratecategorycode
					when 'scaleorgentrykey' then scaleorgentrykey
					when 'sendtoeloind' then sendtoeloind
					when 'templatetypecode' then templatetypecode
					when 'territoriescode' then territoriescode
					when 'titlesourcecode' then titlesourcecode
					when 'titlestatuscode' then titlestatuscode
					when 'titletypecode' then titletypecode
					when 'usageclasscode' then usageclasscode
					when 'workkey' then workkey
					when 'nextprintingnbr' then nextprintingnbr
					when 'origpubhousecode' then origpubhousecode
					when 'linklevelcode' then linklevelcode
					when 'propagatefromprimarycode' then propagatefromprimarycode
					when 'reuseisbnind' then reuseisbnind
					when 'tmmwebtemplateind' then tmmwebtemplateind
					else null
				end
		from	book
		where	bookkey = @bookkey

		if @new_intvalue = @old_intvalue OR (@new_intvalue is null AND @old_intvalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'datetime'
	begin
		select @old_datetimevalue =
				case @columnname
					when 'creationdate' then creationdate
					else null
				end
		from	book
		where	bookkey = @bookkey

		if @new_datetimevalue = @old_datetimevalue OR (@new_datetimevalue is null AND @old_datetimevalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'varchar'
	begin
		select @old_varcharvalue =
				case @columnname
					when 'shorttitle' then shorttitle
					when 'sku' then sku
					when 'subtitle' then subtitle
					when 'title' then title

					when 'nolaterthanmonth' then nolaterthanmonth
					when 'nosoonerthanmonth' then nosoonerthanmonth
					when 'specsrecind' then specsrecind
					when 'standardind' then standardind
					else null
				end
		from	book
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

	if @columnname = 'nolaterthanmonth' update book set nolaterthanmonth=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'nosoonerthanmonth' update book set nosoonerthanmonth=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'specsrecind' update book set specsrecind=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'standardind' update book set standardind=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'creationdate' update book set creationdate=@new_datetimevalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'cycle' update book set cycle=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'elocustomerkey' update book set elocustomerkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'nextjobnbr' update book set nextjobnbr=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'primarycontractkey' update book set primarycontractkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'propagatefrombookkey' update book set propagatefrombookkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'ratecategorycode' update book set ratecategorycode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'scaleorgentrykey' update book set scaleorgentrykey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'sendtoeloind' update book set sendtoeloind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'templatetypecode' update book set templatetypecode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'territoriescode' update book set territoriescode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'titlesourcecode' update book set titlesourcecode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'titlestatuscode' update book set titlestatuscode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'titletypecode' update book set titletypecode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'usageclasscode' update book set usageclasscode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'workkey' update book set workkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'nextprintingnbr' update book set nextprintingnbr=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'origpubhousecode' update book set origpubhousecode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'linklevelcode' update book set linklevelcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'propagatefromprimarycode' update book set propagatefromprimarycode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'reuseisbnind' update book set reuseisbnind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'tmmwebtemplateind' update book set tmmwebtemplateind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'shorttitle' update book set shorttitle=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'sku' update book set sku=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'subtitle' update book set subtitle=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'title' update book set title=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
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
	declare @i_fielddesc_detail varchar(120)
	set     @i_fielddesc_detail = null

	EXEC dbo.qtitle_update_titlehistory 'book', @columnname, @bookkey, 1, 0, @newvalue,
		@transaction_type, @lastuserid, 1, @i_fielddesc_detail, @o_error_code output, @o_error_desc output
end

END
GO
