
IF OBJECT_ID('dbo.UpdFld_Table_bookdetail') IS NOT NULL DROP PROCEDURE dbo.UpdFld_Table_bookdetail
GO

CREATE PROCEDURE dbo.UpdFld_Table_bookdetail
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
where	table_name = 'bookdetail' and column_name = @columnname

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

declare @new_floatvalue float
declare @old_floatvalue float

declare @new_varcharvalue varchar(2000)
declare @old_varcharvalue varchar(2000)


declare @codedesc varchar(120)  -- to fetch datadesc field in gentables corresponding to the external code
declare @transaction_type varchar(10)
declare @dtstamp datetime
set @dtstamp = getdate()


if len(@newvalue) = 0 and @is_nullable = 1 begin
	set @newvalue = null
	-- Easier to just set them all to null rather than check for the column's individual type
	-- Truth is, they're already initialized to null by default
	set @new_intvalue = null
	set @new_floatvalue = null
	set @new_varcharvalue = null

	if @column_datatype not in ( 'int', 'float', 'varchar' ) begin
		set @o_error_code = -1  -- not set up to handle this type (at least currently)
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_bookdetail is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
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
	else if @column_datatype = 'float'
		set @new_floatvalue = convert(float, @newvalue)
	else if @column_datatype = 'varchar'
		set @new_varcharvalue = @newvalue
	else begin
		set @o_error_code = -1  -- not set up to handle this type (at least currently)
		set @o_error_desc = 'ERROR: Stored procedure UpdFld_Table_bookdetail is unable to handle data type (' + @column_datatype + ') for column (' + @columnname + ').'
		RETURN
	end
end  -- check for non-empty (i.e. non-null) value



IF NOT EXISTS (select * from bookdetail where bookkey = @bookkey)
BEGIN
	set @transaction_type = 'insert'  -- parameter to dbo.qtitle_update_titlehistory

	-- FILL IN HERE (i.e. COPY/PASTE) WITH THE text_insert COLUMN DATA GENERATED BY THE GenerateConditionalText.sql SCRIPT.
	-- YOU DON'T NECESSARILY NEED TO INCLUDE ALL THE TABLE'S COLUMNS, BUT MAYBE EASIEST TO ADD ALL COLUMNS INITIALLY AND
	-- THEN COMMENT OUT THE COLUMNS YOU DON'T NEED WHICH CAN BE UNCOMMENTED LATER WHEN/IF BECOMES NECESSARY FOR OTHER CALLERS.

	if @columnname = 'agehigh' insert bookdetail (bookkey, lastuserid, lastmaintdate, agehigh) values (@bookkey, @lastuserid, @dtstamp, @new_floatvalue)
	else if @columnname = 'agelow' insert bookdetail (bookkey, lastuserid, lastmaintdate, agelow) values (@bookkey, @lastuserid, @dtstamp, @new_floatvalue)
	else if @columnname = 'canadianrestrictioncode' insert bookdetail (bookkey, lastuserid, lastmaintdate, canadianrestrictioncode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'csapprovalcode' insert bookdetail (bookkey, lastuserid, lastmaintdate, csapprovalcode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'discountcode' insert bookdetail (bookkey, lastuserid, lastmaintdate, discountcode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'editioncode' insert bookdetail (bookkey, lastuserid, lastmaintdate, editioncode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'editionnumber' insert bookdetail (bookkey, lastuserid, lastmaintdate, editionnumber) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'embargoind' insert bookdetail (bookkey, lastuserid, lastmaintdate, embargoind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'fullauthordisplaykey' insert bookdetail (bookkey, lastuserid, lastmaintdate, fullauthordisplaykey) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'languagecode' insert bookdetail (bookkey, lastuserid, lastmaintdate, languagecode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'languagecode2' insert bookdetail (bookkey, lastuserid, lastmaintdate, languagecode2) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'laydownind' insert bookdetail (bookkey, lastuserid, lastmaintdate, laydownind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'newtitleheading' insert bookdetail (bookkey, lastuserid, lastmaintdate, newtitleheading) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'origincode' insert bookdetail (bookkey, lastuserid, lastmaintdate, origincode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'platformcode' insert bookdetail (bookkey, lastuserid, lastmaintdate, platformcode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'prodavailability' insert bookdetail (bookkey, lastuserid, lastmaintdate, prodavailability) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'publishtowebind' insert bookdetail (bookkey, lastuserid, lastmaintdate, publishtowebind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'restrictioncode' insert bookdetail (bookkey, lastuserid, lastmaintdate, restrictioncode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'returncode' insert bookdetail (bookkey, lastuserid, lastmaintdate, returncode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'salesdivisioncode' insert bookdetail (bookkey, lastuserid, lastmaintdate, salesdivisioncode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'seriescode' insert bookdetail (bookkey, lastuserid, lastmaintdate, seriescode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'userlevelcode' insert bookdetail (bookkey, lastuserid, lastmaintdate, userlevelcode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'volumenumber' insert bookdetail (bookkey, lastuserid, lastmaintdate, volumenumber) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'bisacstatuscode' insert bookdetail (bookkey, lastuserid, lastmaintdate, bisacstatuscode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'copyrightyear' insert bookdetail (bookkey, lastuserid, lastmaintdate, copyrightyear) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'mediatypecode' insert bookdetail (bookkey, lastuserid, lastmaintdate, mediatypecode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'mediatypesubcode' insert bookdetail (bookkey, lastuserid, lastmaintdate, mediatypesubcode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'titleverifycode' insert bookdetail (bookkey, lastuserid, lastmaintdate, titleverifycode) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'agehighupind' insert bookdetail (bookkey, lastuserid, lastmaintdate, agehighupind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'agelowupind' insert bookdetail (bookkey, lastuserid, lastmaintdate, agelowupind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'allagesind' insert bookdetail (bookkey, lastuserid, lastmaintdate, allagesind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'gradehighupind' insert bookdetail (bookkey, lastuserid, lastmaintdate, gradehighupind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'gradelowupind' insert bookdetail (bookkey, lastuserid, lastmaintdate, gradelowupind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'simulpubind' insert bookdetail (bookkey, lastuserid, lastmaintdate, simulpubind) values (@bookkey, @lastuserid, @dtstamp, @new_intvalue)
	else if @columnname = 'additionaleditinfo' insert bookdetail (bookkey, lastuserid, lastmaintdate, additionaleditinfo) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'alternateprojectisbn' insert bookdetail (bookkey, lastuserid, lastmaintdate, alternateprojectisbn) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'editiondescription' insert bookdetail (bookkey, lastuserid, lastmaintdate, editiondescription) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'fullauthordisplayname' insert bookdetail (bookkey, lastuserid, lastmaintdate, fullauthordisplayname) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'gradehigh' insert bookdetail (bookkey, lastuserid, lastmaintdate, gradehigh) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'gradelow' insert bookdetail (bookkey, lastuserid, lastmaintdate, gradelow) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'nexteditionisbn' insert bookdetail (bookkey, lastuserid, lastmaintdate, nexteditionisbn) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'nextisbn' insert bookdetail (bookkey, lastuserid, lastmaintdate, nextisbn) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'preveditionisbn' insert bookdetail (bookkey, lastuserid, lastmaintdate, preveditionisbn) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'titleprefix' insert bookdetail (bookkey, lastuserid, lastmaintdate, titleprefix) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'vistacategorycode' insert bookdetail (bookkey, lastuserid, lastmaintdate, vistacategorycode) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
	else if @columnname = 'vistaprojectnumber' insert bookdetail (bookkey, lastuserid, lastmaintdate, vistaprojectnumber) values (@bookkey, @lastuserid, @dtstamp, @new_varcharvalue)
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
					when 'canadianrestrictioncode' then canadianrestrictioncode
					when 'csapprovalcode' then csapprovalcode
					when 'discountcode' then discountcode
					when 'editioncode' then editioncode
					when 'editionnumber' then editionnumber
					when 'embargoind' then embargoind
					when 'fullauthordisplaykey' then fullauthordisplaykey
					when 'languagecode' then languagecode
					when 'languagecode2' then languagecode2
					when 'laydownind' then laydownind
					when 'newtitleheading' then newtitleheading
					when 'origincode' then origincode
					when 'platformcode' then platformcode
					when 'prodavailability' then prodavailability
					when 'publishtowebind' then publishtowebind
					when 'restrictioncode' then restrictioncode
					when 'returncode' then returncode
					when 'salesdivisioncode' then salesdivisioncode
					when 'seriescode' then seriescode
					when 'userlevelcode' then userlevelcode
					when 'volumenumber' then volumenumber
					when 'bisacstatuscode' then bisacstatuscode
					when 'copyrightyear' then copyrightyear
					when 'mediatypecode' then mediatypecode
					when 'mediatypesubcode' then mediatypesubcode
					when 'titleverifycode' then titleverifycode
					when 'agehighupind' then agehighupind
					when 'agelowupind' then agelowupind
					when 'allagesind' then allagesind
					when 'gradehighupind' then gradehighupind
					when 'gradelowupind' then gradelowupind
					when 'simulpubind' then simulpubind
					else null
				end
		from	bookdetail
		where	bookkey = @bookkey

		if @new_intvalue = @old_intvalue OR (@new_intvalue is null AND @old_intvalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'float'
	begin
		select @old_floatvalue =
				case @columnname
					when 'agehigh' then agehigh
					when 'agelow' then agelow
					else null
				end
		from	bookdetail
		where	bookkey = @bookkey

		if @new_floatvalue = @old_floatvalue OR (@new_floatvalue is null AND @old_floatvalue is null)
			set @changed = 0
	end
	else if @column_datatype = 'varchar'
	begin
		select @old_varcharvalue =
				case @columnname
					when 'additionaleditinfo' then additionaleditinfo
					when 'alternateprojectisbn' then alternateprojectisbn
					when 'editiondescription' then editiondescription
					when 'fullauthordisplayname' then fullauthordisplayname
					when 'gradehigh' then gradehigh
					when 'gradelow' then gradelow
					when 'nexteditionisbn' then nexteditionisbn
					when 'nextisbn' then nextisbn
					when 'preveditionisbn' then preveditionisbn
					when 'titleprefix' then titleprefix
					when 'vistacategorycode' then vistacategorycode
					when 'vistaprojectnumber' then vistaprojectnumber
					else null
				end
		from	bookdetail
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

	if @columnname = 'agehigh' update bookdetail set agehigh=@new_floatvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'agelow' update bookdetail set agelow=@new_floatvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'canadianrestrictioncode' update bookdetail set canadianrestrictioncode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'csapprovalcode' update bookdetail set csapprovalcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'discountcode' update bookdetail set discountcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'editioncode' update bookdetail set editioncode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'editionnumber' update bookdetail set editionnumber=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'embargoind' update bookdetail set embargoind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'fullauthordisplaykey' update bookdetail set fullauthordisplaykey=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'languagecode' update bookdetail set languagecode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'languagecode2' update bookdetail set languagecode2=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'laydownind' update bookdetail set laydownind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'newtitleheading' update bookdetail set newtitleheading=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'origincode' update bookdetail set origincode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'platformcode' update bookdetail set platformcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'prodavailability' update bookdetail set prodavailability=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'publishtowebind' update bookdetail set publishtowebind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'restrictioncode' update bookdetail set restrictioncode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'returncode' update bookdetail set returncode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'salesdivisioncode' update bookdetail set salesdivisioncode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'seriescode' update bookdetail set seriescode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'userlevelcode' update bookdetail set userlevelcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'volumenumber' update bookdetail set volumenumber=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'bisacstatuscode' update bookdetail set bisacstatuscode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'copyrightyear' update bookdetail set copyrightyear=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'mediatypecode' update bookdetail set mediatypecode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'mediatypesubcode' update bookdetail set mediatypesubcode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'titleverifycode' update bookdetail set titleverifycode=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'agehighupind' update bookdetail set agehighupind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'agelowupind' update bookdetail set agelowupind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'allagesind' update bookdetail set allagesind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'gradehighupind' update bookdetail set gradehighupind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'gradelowupind' update bookdetail set gradelowupind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'simulpubind' update bookdetail set simulpubind=@new_intvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'additionaleditinfo' update bookdetail set additionaleditinfo=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'alternateprojectisbn' update bookdetail set alternateprojectisbn=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'editiondescription' update bookdetail set editiondescription=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'fullauthordisplayname' update bookdetail set fullauthordisplayname=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'gradehigh' update bookdetail set gradehigh=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'gradelow' update bookdetail set gradelow=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'nexteditionisbn' update bookdetail set nexteditionisbn=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'nextisbn' update bookdetail set nextisbn=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'preveditionisbn' update bookdetail set preveditionisbn=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'titleprefix' update bookdetail set titleprefix=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'vistacategorycode' update bookdetail set vistacategorycode=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
	else if @columnname = 'vistaprojectnumber' update bookdetail set vistaprojectnumber=@new_varcharvalue, lastuserid=@lastuserid, lastmaintdate=@dtstamp where bookkey=@bookkey
END



if (@@ERROR < 0) begin
	set @o_error_code = @@ERROR - 100  -- -100 to distinguish from other error codes in UpdFld_XXXX
	set @o_error_desc = 'System Error: @@ERROR value (' + convert(varchar,@@ERROR) + ') during ' + @transaction_type + ' by dbo.UpdFld_Table_bookdetail.'
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

	EXEC dbo.qtitle_update_titlehistory 'bookdetail', @columnname, @bookkey, 1, 0, @newvalue,
		@transaction_type, @lastuserid, 1, @i_fielddesc_detail, @o_error_code output, @o_error_desc output
end

END
GO
