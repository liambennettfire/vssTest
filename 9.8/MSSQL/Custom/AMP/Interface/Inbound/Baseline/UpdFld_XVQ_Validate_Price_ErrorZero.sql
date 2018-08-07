
IF OBJECT_ID('dbo.UpdFld_XVQ_Validate_Price_ErrorZero') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Validate_Price_ErrorZero
GO

-- UpdFld_XXXX encapsulates data-field insert, update, and titlehistory functions.  Sitting on top of that,
-- UpdFld_XVQ_XXXX provides a layer of transformation, validation, integrated QsiJob reporting, and flow-control.

CREATE PROCEDURE dbo.UpdFld_XVQ_Validate_Price_ErrorZero
@bookkey        int,
@pricecode      int,
@currencycode   int,
@fld_buffer     varchar(100),
@o_result_code  int output,          -- must be one of UpdFld_XVQ effect codes, or system error code (< 0)
@o_result_desc  varchar(2000) output -- warning, info, system error msg, invalid, etc
AS
BEGIN

declare @count1 int
declare @count2 int

select	@count1 = count(*)
from	gentables
where	tableid = 306
		and datacode = @pricecode

select	@count2 = count(*)
from	gentables
where	tableid = 122
		and datacode = @currencycode

if @count1 = 0 begin
	set @o_result_code = 4
	set @o_result_desc = 'Invalid price type code'
end
else if @count2 = 0 begin
	set @o_result_code = 4
	set @o_result_desc = 'Invalid currency type code'
end
else if @count1 > 1 or @count2 > 1 begin
	set @o_result_code = 4
	set @o_result_desc = 'Ambiguous price type code value - more than one matching entry in the reference table.'
end
else if @count1 = 1 and @count2 = 1 begin
	if isnumeric(@fld_buffer) = 1 AND convert(money,@fld_buffer) <> 0.00 begin
		set @o_result_code = 7    -- success
		set @o_result_desc = null
	end
	else begin
		set @o_result_code = 4
		set @o_result_desc = 'Invalid price'
	end
end


END
GO
