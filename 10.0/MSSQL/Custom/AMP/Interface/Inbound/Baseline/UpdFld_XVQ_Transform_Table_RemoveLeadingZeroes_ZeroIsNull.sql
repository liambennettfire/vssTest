
IF OBJECT_ID('dbo.UpdFld_XVQ_Transform_Table_RemoveLeadingZeroes_ZeroIsNull') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Transform_Table_RemoveLeadingZeroes_ZeroIsNull
GO

-- Remove leading zeroes (for numeric-field input data that is left-padded with zeroes like PGI for example).
-- But if value is zero, then convert it to empty string so will be treated as NULL value instead of explicit 0. (For fields which
-- explicit 0 is not really a valid value, e.g. title dimensions such as length, width, weight, carton-quantity.)

CREATE PROCEDURE dbo.UpdFld_XVQ_Transform_Table_RemoveLeadingZeroes_ZeroIsNull  -- for removing leading zeroes from numeric (text) input fields
@pre1_post2     int,   -- pre-process = 1, post-process = 2
@columnname     varchar(100),
@tableid        int,                 -- 0 if the column is not a gentables code
@codeform       int,                 -- 0 if the column is not a gentables code, otherwise 1=code#, 2=externalcode, 3=datadesc
@parentcode     int,                 -- only matters if @codeform is non-zero - data is a SUBgentables code under @parentcode
@o_data_buffer  varchar(100) output,
@o_length       int output,
@bookkey        int
AS
BEGIN

if @pre1_post2 = 1 begin   -- just do once, and before validation
	if convert(float,@o_data_buffer) = 0
		set @o_data_buffer = ''
	else
		-- This is really only necessary for the benefit of the number's text representation in the title history record
		EXEC dbo.UpdFld_XVQ_Transform_Common_RemoveLeadingZeroes @o_data_buffer output

	set @o_length = len(@o_data_buffer)
end

END
GO
