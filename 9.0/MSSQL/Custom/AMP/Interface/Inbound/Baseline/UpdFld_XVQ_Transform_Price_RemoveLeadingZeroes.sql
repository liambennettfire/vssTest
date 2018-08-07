
IF OBJECT_ID('dbo.UpdFld_XVQ_Transform_Price_RemoveLeadingZeroes') IS NOT NULL DROP PROCEDURE dbo.UpdFld_XVQ_Transform_Price_RemoveLeadingZeroes
GO

CREATE PROCEDURE dbo.UpdFld_XVQ_Transform_Price_RemoveLeadingZeroes  -- for removing leading zeroes from numeric (text) input fields
@pre1_post2     int,   -- pre-process = 1, post-process = 2
@pricecode      int,
@currencycode   int,
@effectivedate  datetime,
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
