
IF OBJECT_ID('dbo.UpdFld_XVQ_Validate_DateCode') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Validate_DateCode
GO

-- UpdFld_XXXX encapsulates data-field insert, update, and titlehistory functions.  Sitting on top of that,
-- UpdFld_XVQ_XXXX provides a layer of transformation, validation, integrated QsiJob reporting, and flow-control.

CREATE PROCEDURE dbo.UpdFld_XVQ_Validate_DateCode
@bookkey        int,
@datetypecode   int,
@fld_buffer     varchar(100),
@o_result_code  int output,          -- must be one od UpdFld_XVQ effect code
@o_result_desc  varchar(2000) output -- warning, info, system error msg, invalid, etc
AS
BEGIN

declare @count int

select	@count = count(*)
from	datetype
where	datetypecode = @datetypecode

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
	set @o_result_desc = 'Invalid date type code.'
end


END
GO
