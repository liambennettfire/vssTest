
IF OBJECT_ID('dbo.UpdFld_XVQ_Transform_Common_RemoveAllLeadingZeroes') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Transform_Common_RemoveAllLeadingZeroes
GO

-- This Remove-ALL-Leading-Zeroes is different from the other Remove-Leading-Zeroes version in that if there are no non-zero digits,
-- then it does not leave one zero in output (e.g. '0000' is transformed to '' rather than '0').  This allows passing of NULL value,
-- rather than zero for numeric-field input data that is left-padded with zeroes (like PGI for example), but for which 0 is not a valid
-- value (e.g. title dimensions such as length, width, weight, carton-quantity).

CREATE PROCEDURE dbo.UpdFld_XVQ_Transform_Common_RemoveAllLeadingZeroes  -- for removing leading zeroes from numeric (text) input fields
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
