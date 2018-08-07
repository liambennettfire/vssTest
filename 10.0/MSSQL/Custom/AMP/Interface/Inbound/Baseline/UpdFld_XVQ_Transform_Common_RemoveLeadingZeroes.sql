
IF OBJECT_ID('dbo.UpdFld_XVQ_Transform_Common_RemoveLeadingZeroes') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Transform_Common_RemoveLeadingZeroes
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_Transform_Common_RemoveLeadingZeroes  -- for removing leading zeroes from numeric (text) input fields
@o_data_buffer  varchar(100) output
AS
BEGIN

declare @len_data int
declare @base_pos int
declare @zero_pos int

set @len_data = len(@o_data_buffer)
if  @len_data > 0 begin

	set @base_pos = 0
	set @zero_pos = 0

	while @zero_pos = @base_pos /*and @base_pos-1 <= @len_data*/ begin
		set @base_pos = @base_pos + 1
		set @zero_pos = charindex('0', @o_data_buffer, @base_pos)
	end

	if @base_pos > 1 and (@base_pos > @len_data OR charindex('.', @o_data_buffer) = @base_pos)
		set @base_pos = @base_pos - 1  -- leave one leading 0

	set @o_data_buffer = substring(@o_data_buffer, @base_pos, @len_data-@base_pos+1)
end

END
GO
