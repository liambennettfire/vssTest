
IF OBJECT_ID('dbo.UpdFld_XVQ_Validate_Price_NonExistentIgnoreZero') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Validate_Price_NonExistentIgnoreZero
GO

-- UpdFld_XXXX encapsulates data-field insert, update, and titlehistory functions.  Sitting on top of that,
-- UpdFld_XVQ_XXXX provides a layer of transformation, validation, integrated QsiJob reporting, and flow-control.

CREATE PROCEDURE dbo.UpdFld_XVQ_Validate_Price_NonExistentIgnoreZero
@bookkey        int,
@pricecode      int,
@currencycode   int,
@fld_buffer     varchar(100),
@o_result_code  int output,          -- must be one of UpdFld_XVQ effect codes, or system error code (< 0)
@o_result_desc  varchar(2000) output -- warning, info, system error msg, invalid, etc
AS
BEGIN

EXEC dbo.UpdFld_XVQ_Validate_Price_IgnoreZero @bookkey, @pricecode, @currencycode, @fld_buffer, @o_result_code output, @o_result_desc output
if @o_result_code = 8 AND EXISTS (select * from bookprice where bookkey = @bookkey and pricetypecode = @pricecode and currencytypecode = @currencycode and activeind = 1)
begin
	set @o_result_code = 4
	set @o_result_desc = 'Invalid price'
end

END
GO
