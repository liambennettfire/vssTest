
IF OBJECT_ID('dbo.UpdFld_XVQ_Validate_MiscItemType5_Exists') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Validate_MiscItemType5_Exists
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_Validate_MiscItemType5_Exists  -- miscitem type 5 is a gentables value -> make sure it exists in gentables
@bookkey        int,
@misckey        int,
@codeform       int,                 -- 0 if misckey's misctype<>5 (not a gentables code), otherwise 1=code#, 2=externalcode, 3=datadesc
@fld_buffer     varchar(100),
@o_result_code  int output,          -- must be one od UpdFld_XVQ effect code
@o_result_desc  varchar(2000) output -- warning, info, system error msg, invalid, etc
AS
BEGIN

declare @misctype           int
declare @misctype5_datacode int


select	@misctype = misctype,
		@misctype5_datacode = datacode
from	bookmiscitems
where	misckey = @misckey


if @misctype <> 5 or len(ltrim(rtrim(@fld_buffer))) = 0 begin
	set @o_result_code = 7    -- no issue - not a type 5 miscitem
	set @o_result_desc = null
end
else
begin
	declare @count     int
	declare @longvalue int

	if @codeform = 1                               -- need to do this out here because db engine "pre-evaluates" expression and 
		set @longvalue = convert(int, @fld_buffer) -- otherwise will get an error in WHERE clause below, even when @codeform <> 1

	select	@count = count(*)
	from	subgentables
	where	tableid = 525  -- 525 = misctable id
			and
			datacode = @misctype5_datacode
			and
			deletestatus = 'N'
			and
			(
			  --(@codeform = 1 and datasubcode = convert(int, @fld_buffer))  -- buffer holds datasubcode number as text
				(@codeform = 1 and datasubcode = @longvalue)                 -- buffer holds datasubcode number as text
				or
				(@codeform = 2 and upper(externalcode) = upper(@fld_buffer)) -- buffer holds external-code corresponding to datasubcode
				or
				(@codeform = 3 and upper(datadesc) = upper(@fld_buffer))     -- buffer holds datadesc/display-label corresponding to datasubcode
				or
				(@codeform = 4 and upper(@fld_buffer) = upper(bisacdatacode))
				or
				(@codeform = 5 and upper(@fld_buffer) = upper(datadescshort))
			)

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
