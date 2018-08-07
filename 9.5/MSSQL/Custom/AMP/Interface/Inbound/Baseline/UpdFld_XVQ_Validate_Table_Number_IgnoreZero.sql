
IF OBJECT_ID('dbo.UpdFld_XVQ_Validate_Table_Number_IgnoreZero') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Validate_Table_Number_IgnoreZero
GO

-- UpdFld_XXXX encapsulates data-field insert, update, and titlehistory functions.  Sitting on top of that,
-- UpdFld_XVQ_XXXX provides a layer of transformation, validation, integrated QsiJob reporting, and flow-control.

CREATE PROCEDURE dbo.UpdFld_XVQ_Validate_Table_Number_IgnoreZero
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

if len(ltrim(@fld_buffer)) = 0 OR convert(float,@fld_buffer) = 0 begin
	set @o_result_code = 8    -- ignore
	set @o_result_desc = null
end
else if isnumeric(@fld_buffer) = 1 begin
	set @o_result_code = 7    -- success
	set @o_result_desc = null
end
else begin
	set @o_result_code = 4
	set @o_result_desc = 'Invalid number'
end


END
GO
