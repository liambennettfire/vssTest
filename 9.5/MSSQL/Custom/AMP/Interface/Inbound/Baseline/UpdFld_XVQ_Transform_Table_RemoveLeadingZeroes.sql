
IF OBJECT_ID('dbo.UpdFld_XVQ_Transform_Table_RemoveLeadingZeroes') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Transform_Table_RemoveLeadingZeroes
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_Transform_Table_RemoveLeadingZeroes  -- for removing leading zeroes from numeric (text) input fields
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
	EXEC dbo.UpdFld_XVQ_Transform_Common_RemoveLeadingZeroes @o_data_buffer output

END
GO
