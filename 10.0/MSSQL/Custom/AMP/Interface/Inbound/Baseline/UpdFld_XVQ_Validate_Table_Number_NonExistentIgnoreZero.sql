
IF OBJECT_ID('dbo.UpdFld_XVQ_Validate_Table_NonExistentIgnoreZero') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Validate_Table_NonExistentIgnoreZero
GO

-- UpdFld_XXXX encapsulates data-field insert, update, and titlehistory functions.  Sitting on top of that,
-- UpdFld_XVQ_XXXX provides a layer of transformation, validation, integrated QsiJob reporting, and flow-control.

CREATE PROCEDURE dbo.UpdFld_XVQ_Validate_Table_NonExistentIgnoreZero
@bookkey        int,
@tablename      varchar(100),
@columnname     varchar(100),
@tableid        int,                 -- 0 if the column is not a gentables code
@codeform       int,                 -- 0 if the column is not a gentables code, otherwise 1=code#, 2=externalcode, 3=datadesc
@parentcode     int,                 -- only matters if @codeform is non-zero - data is a SUBgentables code under @parentcode
@fld_buffer     varchar(2000),
@o_result_code  int output,          -- must be one of UpdFld_XVQ effect codes, or system error code (< 0)
@o_result_desc  varchar(2000) output -- warning, info, system error msg, invalid, etc
AS
BEGIN

EXEC dbo.UpdFld_XVQ_Validate_Table_IgnoreZero @bookkey, @columnname, @tableid, @codeform, @parentcode, @fld_buffer, @o_result_code output, @o_result_desc output
if @o_result_code = 8 AND EXISTS (select * from bookprice where bookkey = @bookkey and pricetypecode = @pricecode and currencytypecode = @currencycode and activeind = 1)
begin
declare @sql_cmd varchar(1000)
set @sql_cmd = 'select ' + @columnname + ' from ' + @tablename + ' where bookkey = ' + convert(varchar,@bookkey)

set @sql_cmd = 'case when EXISTS (select ' + @columnname + ' from ' + @tablename + ' where bookkey = ' + convert(varchar,@bookkey) + ') then 1 else 0 end'
exec sp_sqlexec @sql_cmd

	set @o_result_code = 4
	set @o_result_desc = 'Invalid number'
end

END
GO
