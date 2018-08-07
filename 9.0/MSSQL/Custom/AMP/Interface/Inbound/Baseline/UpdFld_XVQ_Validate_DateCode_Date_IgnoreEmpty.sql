
IF OBJECT_ID('dbo.UpdFld_XVQ_Validate_DateCode_Date_IgnoreEmpty') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Validate_DateCode_Date_IgnoreEmpty
GO

-- UpdFld_XXXX encapsulates data-field insert, update, and titlehistory functions.  Sitting on top of that,
-- UpdFld_XVQ_XXXX provides a layer of transformation, validation, integrated QsiJob reporting, and flow-control.

CREATE PROCEDURE dbo.UpdFld_XVQ_Validate_DateCode_Date_IgnoreEmpty
@bookkey        int,
@datetypecode   int,
@fld_buffer     varchar(100),
@o_result_code  int output,          -- must be one of UpdFld_XVQ effect codes, or system error code (< 0)
@o_result_desc  varchar(2000) output -- warning, info, system error msg, invalid, etc
AS
BEGIN


declare @count int

select	@count = count(*)
from	datetype
where	datetypecode = @datetypecode

if @count = 0 begin
	set @o_result_code = 4
	set @o_result_desc = 'Invalid date type code'
end
else if @count > 1 begin
	set @o_result_code = 4
	set @o_result_desc = 'Ambiguous date type value - more than one matching entry in reference table.'
end
if @count = 1 begin
	if isdate(@fld_buffer) = 1 begin
		set @o_result_code = 7    -- success
		set @o_result_desc = null
	end
	else if len(ltrim(@fld_buffer)) = 0 begin
		set @o_result_code = 8    -- ignore
		set @o_result_desc = null
	end
	else begin
		set @o_result_code = 4
		set @o_result_desc = 'Invalid date'
	end
end


END
GO
