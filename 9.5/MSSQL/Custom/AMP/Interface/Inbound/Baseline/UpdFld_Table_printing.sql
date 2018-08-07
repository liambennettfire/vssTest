
IF OBJECT_ID('dbo.UpdFld_Table_printing') IS NOT NULL DROP PROCEDURE dbo.UpdFld_Table_printing
GO

CREATE PROCEDURE dbo.UpdFld_Table_printing
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

declare @printingkey int
set     @printingkey = 1  -- non-null column in table, must default it to something when inserting - will pass in as param in future version, but for now...

declare @column_datatype varchar(30)
declare @is_nullable     int

select  @column_datatype = lower(data_type),
		@is_nullable     = (case upper(is_nullable) when 'NO' then 0 else 1 end)
from	information_schema.columns
where	table_name = 'printing' and column_name = @columnname

-- YOU MAY NEED TO TWEAK/ADD HERE FOR LESS COMMON DATA TYPES AND SITUATIONS, BUT WE CAN CONSOLIDATE THESE
-- TYPES BECAUSE THE CONVERSION/COMPARISON BETWEEN THEM IS GENERALLY STRAIGHTFORWARD AND INCONSEQUENTIAL.
if @column_datatype in ('int', 'tinyint', 'smallint')
	set @column_datatype = 'int'
else if @column_datatype in ('float', 'decimal', 'numeric', 'money')
	set @column_datatype = 'float'
else if @column_datatype in ('varchar', 'char')
	set @column_datatype = 'varchar'


declare @newvalue varchar(2000)  -- textual representation of new value extracted from record/field buffer
set @newvalue = ltrim(rtrim(substring(@record_buffer, @offset, @length)))

-- DECLARE THE NEW/OLD PAIRS OF DATATYPES YOU NEED.  THE NAMES MUST CONFORM TO THE PATTERN YOU SEE DECLARED FOR
-- THE TYPES BELOW BECAUSE THE GenerateColumnText.sql SCRIPT USES THIS PATTERN IN THE AUTO-GENERATED OUTPUT.

declare @new_intvalue int
declare @old_intvalue int

declare @new_bigintvalue bigint
declare @old_bigintvalue bigint

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
	set @new_bigintvalue = null
	set @new_floatvalue = null
	set @new_varcharvalue = null

	if @column_datatype not in ( 'int', 'bigint', 'float', 'varchar' ) begin
		set @o_error_code = -1  -- not set up to handle this type (at least currently)
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_printing is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
		RETURN
	end
end
else
begin
	if @codeform <> 0   -- the data item is represented as a code value
	begin
		if @codeform = 1                                -- need to do this here because db engine "pre-evaluates" expression and 
			set @new_intvalue = convert(int, @newvalue) -- otherwise will get an error in WHERE clause below even when @codeform <> 1

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
	else if @column_datatype = 'bigint'
		set @new_bigintvalue = convert(bigint, @newvalue)
	else if @column_datatype = 'float'
		set @new_floatvalue = convert(float, @newvalue)
	else if @column_datatype = 'varchar'
		set @new_varcharvalue = @newvalue
	else begin
		set @o_error_code = -1  -- not set up to handle this type (at least currently)
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_printing is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
		RETURN
	end
end  -- check for non-empty (i.e. non-null) value



IF NOT EXISTS (select * from printing where bookkey = @bookkey /*and printingkey = @printingkey*/)
BEGIN
	set @transaction_type = 'insert'  -- parameter to dbo.qtitle_update_titlehistory

	-- FILL IN HERE (i.e. COPY/PASTE) WITH THE text_insert COLUMN DATA GENERATED BY THE GenerateConditionalText.sql SCRIPT.
	-- YOU DON'T NECESSARILY NEED TO INCLUDE ALL THE TABLE'S COLUMNS, BUT MAYBE EASIEST TO ADD ALL COLUMNS INITIALLY AND
	-- THEN COMMENT OUT THE COLUMNS YOU DON'T NEED WHICH CAN BE UNCOMMENTED LATER WHEN/IF BECOMES NECESSARY FOR OTHER CALLERS.

	if @columnname = 'estseasonkey'					insert printing (bookkey, printingkey, lastuserid, lastmaintdate, estseasonkey)				values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'seasonkey'				insert printing (bookkey, printingkey, lastuserid, lastmaintdate, seasonkey)				values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'tentativepagecount'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, tentativepagecount)		values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'pagecount'				insert printing (bookkey, printingkey, lastuserid, lastmaintdate, [pagecount])				values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'tentativeqty'			insert printing (bookkey, printingkey, lastuserid, lastmaintdate, tentativeqty)				values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'firstprintingqty'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, firstprintingqty)			values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'esttrimsizewidth'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, esttrimsizewidth)			values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'esttrimsizelength'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, esttrimsizelength)		values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'trimsizewidth'			insert printing (bookkey, printingkey, lastuserid, lastmaintdate, trimsizewidth)			values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'trimsizelength'			insert printing (bookkey, printingkey, lastuserid, lastmaintdate, trimsizelength)			values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'pubmonthcode'			insert printing (bookkey, printingkey, lastuserid, lastmaintdate, pubmonthcode)				values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'estprojectedsales'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, estprojectedsales)		values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'projectedsales'			insert printing (bookkey, printingkey, lastuserid, lastmaintdate, projectedsales)			values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'estannouncedfirstprint'	insert printing (bookkey, printingkey, lastuserid, lastmaintdate, estannouncedfirstprint)	values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'announcedfirstprint'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, announcedfirstprint)		values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'estimatedinsertillus'	insert printing (bookkey, printingkey, lastuserid, lastmaintdate, estimatedinsertillus)		values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'actualinsertillus'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, actualinsertillus)		values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'tmmactualtrimwidth'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, tmmactualtrimwidth)		values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'tmmactualtrimlength'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, tmmactualtrimlength)		values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'tmmpagecount'			insert printing (bookkey, printingkey, lastuserid, lastmaintdate, tmmpagecount)				values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'bookweight'				insert printing (bookkey, printingkey, lastuserid, lastmaintdate, bookweight)				values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_floatvalue)
	else if @columnname = 'spinesize'				insert printing (bookkey, printingkey, lastuserid, lastmaintdate, spinesize)				values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'slotcode'				insert printing (bookkey, printingkey, lastuserid, lastmaintdate, slotcode)					values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'boardtrimsizewidth'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, boardtrimsizewidth)		values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'boardtrimsizelength'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, boardtrimsizelength)		values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'barcodeid1'				insert printing (bookkey, printingkey, lastuserid, lastmaintdate, barcodeid1)				values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_bigintvalue)
	else if @columnname = 'barcodeposition1'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, barcodeposition1)			values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_bigintvalue)
	else if @columnname = 'barcodeid2'				insert printing (bookkey, printingkey, lastuserid, lastmaintdate, barcodeid2)				values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_bigintvalue)
	else if @columnname = 'barcodeposition2'		insert printing (bookkey, printingkey, lastuserid, lastmaintdate, barcodeposition2)			values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_bigintvalue)
	else if @columnname = 'trimsizeunitofmeasure'	insert printing (bookkey, printingkey, lastuserid, lastmaintdate, trimsizeunitofmeasure)	values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'spinesizeunitofmeasure'	insert printing (bookkey, printingkey, lastuserid, lastmaintdate, spinesizeunitofmeasure)	values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'bookweightunitofmeasure'	insert printing (bookkey, printingkey, lastuserid, lastmaintdate, bookweightunitofmeasure)	values (@bookkey, @printingkey, @lastuserid, @dtstamp, @new_intvalue)
END
ELSE
BEGIN
	-- Bookkey already exists in the table, get its old value for the column

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
					when 'estseasonkey'  then estseasonkey
					when 'seasonkey'  then seasonkey
					when 'tentativepagecount'  then tentativepagecount
					when 'pagecount'  then [pagecount]
					when 'tentativeqty'  then tentativeqty
					when 'firstprintingqty'  then firstprintingqty
					when 'pubmonthcode'  then pubmonthcode
					when 'estprojectedsales'  then estprojectedsales
					when 'projectedsales'  then projectedsales
					when 'estannouncedfirstprint'  then estannouncedfirstprint
					when 'announcedfirstprint'  then announcedfirstprint
					when 'tmmpagecount'  then tmmpagecount
					when 'slotcode'  then slotcode
					when 'trimsizeunitofmeasure'  then trimsizeunitofmeasure
					when 'spinesizeunitofmeasure'  then spinesizeunitofmeasure
					when 'bookweightunitofmeasure'  then bookweightunitofmeasure
					else null
				end
		from	printing
		where	bookkey = @bookkey

		if @new_intvalue = @old_intvalue OR (@new_intvalue is null AND @old_intvalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'bigint'
	begin
		select @old_bigintvalue =
				case @columnname
					when 'barcodeid1'  then barcodeid1
					when 'barcodeposition1'  then barcodeposition1
					when 'barcodeid2'  then barcodeid2
					when 'barcodeposition2'  then barcodeposition2
					else null
				end
		from	printing
		where	bookkey = @bookkey

		if @new_bigintvalue = @old_bigintvalue OR (@new_bigintvalue is null AND @old_bigintvalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'float'
	begin
		select @old_floatvalue =
				case @columnname
					when 'bookweight'  then bookweight
					else null
				end
		from	printing
		where	bookkey = @bookkey

		if @new_floatvalue = @old_floatvalue OR (@new_floatvalue is null AND @old_floatvalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'varchar'
	begin
		select @old_varcharvalue =
				case @columnname
					when 'esttrimsizewidth'  then esttrimsizewidth
					when 'esttrimsizelength'  then esttrimsizelength
					when 'trimsizewidth'  then trimsizewidth
					when 'trimsizelength'  then trimsizelength
					when 'estimatedinsertillus'  then estimatedinsertillus
					when 'actualinsertillus'  then actualinsertillus
					when 'tmmactualtrimwidth'  then tmmactualtrimwidth
					when 'tmmactualtrimlength'  then tmmactualtrimlength
					when 'spinesize'  then spinesize
					when 'boardtrimsizewidth'  then boardtrimsizewidth
					when 'boardtrimsizelength'  then boardtrimsizelength
					else null
				end
		from	printing
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

	if @columnname = 'estseasonkey'  update printing set estseasonkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'seasonkey'  update printing set seasonkey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'tentativepagecount'  update printing set tentativepagecount=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'pagecount'  update printing set [pagecount]=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'tentativeqty'  update printing set tentativeqty=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'firstprintingqty'  update printing set firstprintingqty=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'esttrimsizewidth'  update printing set esttrimsizewidth=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'esttrimsizelength'  update printing set esttrimsizelength=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'trimsizewidth'  update printing set trimsizewidth=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'trimsizelength'  update printing set trimsizelength=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'pubmonthcode'  update printing set pubmonthcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'estprojectedsales'  update printing set estprojectedsales=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'projectedsales'  update printing set projectedsales=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'estannouncedfirstprint'  update printing set estannouncedfirstprint=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'announcedfirstprint'  update printing set announcedfirstprint=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'estimatedinsertillus'  update printing set estimatedinsertillus=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'actualinsertillus'  update printing set actualinsertillus=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'tmmactualtrimwidth'  update printing set tmmactualtrimwidth=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'tmmactualtrimlength'  update printing set tmmactualtrimlength=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'tmmpagecount'  update printing set tmmpagecount=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'bookweight'  update printing set bookweight=@new_floatvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'spinesize'  update printing set spinesize=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'slotcode'  update printing set slotcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'boardtrimsizewidth'  update printing set boardtrimsizewidth=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'boardtrimsizelength'  update printing set boardtrimsizelength=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'barcodeid1'  update printing set barcodeid1=@new_bigintvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'barcodeposition1'  update printing set barcodeposition1=@new_bigintvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'barcodeid2'  update printing set barcodeid2=@new_bigintvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'barcodeposition2'  update printing set barcodeposition2=@new_bigintvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'trimsizeunitofmeasure'  update printing set trimsizeunitofmeasure=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'spinesizeunitofmeasure'  update printing set spinesizeunitofmeasure=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'bookweightunitofmeasure'  update printing set bookweightunitofmeasure=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
END



if (@@ERROR < 0) begin
	set @o_error_code = @@ERROR - 100  -- -100 to distinguish from other error codes in UpdFld_XXXX
	set @o_error_desc = 'System Error: @@ERROR value (' + convert(varchar,@@ERROR) + ') during ' + @transaction_type + ' by dbo.UpdFld_Table_printing.'
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

	EXEC dbo.qtitle_update_titlehistory 'printing', @columnname, @bookkey, 1, 0, @newvalue,
		@transaction_type, @lastuserid, 1, @i_fielddesc_detail, @o_error_code output, @o_error_desc output
end

END
GO
