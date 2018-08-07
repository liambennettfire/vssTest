
IF OBJECT_ID('dbo.UpdFld_XVQ_Transform_Table_RemoveAllLeadingZeroes') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Transform_Table_RemoveAllLeadingZeroes
GO

-- This Remove-ALL-Leading-Zeroes is different from the other Remove-Leading-Zeroes version in that if there are no non-zero digits,
-- then it does not leave one zero in output (e.g. '0000' is transformed to '' rather than '0').  This allows passing of NULL value,
-- rather than zero for numeric-field input data that is left-padded with zeroes (like PGI for example), but for which 0 is not a valid
-- value (e.g. title dimensions such as length, width, weight, carton-quantity).

CREATE PROCEDURE dbo.UpdFld_XVQ_Transform_Table_RemoveAllLeadingZeroes  -- for removing leading zeroes from numeric (text) input fields
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

-- This is really only necessary for the benefit of the number's text representation in the title history record

if @pre1_post2 = 1   -- just do once
	EXEC dbo.UpdFld_XVQ_Transform_Common_RemoveAllLeadingZeroes @o_data_buffer output

END
GO
