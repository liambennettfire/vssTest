
IF OBJECT_ID('dbo.UpdFld_XVQ_Validate_RefTableItem_Exists') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Validate_RefTableItem_Exists
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_Validate_RefTableItem_Exists  -- field is is a gentables value -> make sure it exists in gentables (or subgentables)
@bookkey        int,
@columnname     varchar(50),
@tableid        int,                 -- 0 if the column is not a gentables code
@codeform       int,                 -- 0 if the column is not a gentables code, otherwise 1=code#, 2=externalcode, 3=datadesc
@parentcode     int,                 -- only matters if @codeform is non-zero - data is a SUBgentables code under @parentcode
@fld_buffer     varchar(100),
@o_result_code  int output,          -- must be one of UpdFld_XVQ effect codes
@o_result_desc  varchar(2000) output -- warning, info, system error msg, invalid, etc
AS
BEGIN


if @codeform = 0 or len(ltrim(rtrim(@fld_buffer))) = 0 begin   -- the data item is NOT represented as a code value -> no issue
	set @o_result_code = 7
	set @o_result_desc = null
end
else
begin
	declare @count     int
	declare @intvalue int

	if @codeform = 1                                -- need to do this here because db engine "pre-evaluates" expression and 
		set @intvalue = convert(int, @fld_buffer)   -- otherwise will get an error in WHERE clause below even when @codeform <> 1

	if @parentcode = 0   -- the column is a gentables value rather than a SUBgentables value
	begin
		select	@count = count(*)
		from	gentables
		where	tableid = @tableid
				and
				deletestatus = 'N'
				and
				(
				  --(@codeform = 1 and datacode = convert(int, @fld_buffer))     -- buffer holds datacode number as text
					(@codeform = 1 and datacode = @intvalue)                     -- buffer holds datacode number as text
					or
					(@codeform = 2 and upper(externalcode) = upper(@fld_buffer)) -- buffer holds external-code corresponding to datacode
					or
					(@codeform = 3 and upper(datadesc) = upper(@fld_buffer))     -- buffer holds datadesc/display-label corresponding to datacode
				)
	end
	else   -- the column is a SUBgentables value rather than a gentables value
	begin
		select	@count = count(*)
		from	subgentables
		where	tableid = @tableid
				and
				datacode = @parentcode
				and
				deletestatus = 'N'
				and
				(
				  --(@codeform = 1 and datasubcode = convert(int, @fld_buffer))  -- buffer holds datacode number as text
					(@codeform = 1 and datasubcode = @intvalue)                  -- buffer holds datacode number as text
					or
					(@codeform = 2 and upper(externalcode) = upper(@fld_buffer)) -- buffer holds external-code corresponding to datacode
					or
					(@codeform = 3 and upper(datadesc) = upper(@fld_buffer))     -- buffer holds datadesc/display-label corresponding to datacode
				)
	end


	if @count = 1 begin
		set @o_result_code = 7    -- success
		set @o_result_desc = null
	end
	else if @count > 1 begin
		set @o_result_code = 4    -- ambiguous value
		set @o_result_desc = 'Ambiguous value - more than one matching occurance in reference table.'
	end
	else begin -- @count = 0
		set @o_result_code = 4    -- invalid value
		set @o_result_desc = 'Reference table item does not exist.'
	end
end


END
GO
