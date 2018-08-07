if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_getProductId') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.WK_getProductId
GO

CREATE FUNCTION dbo.WK_getProductId(@bookkey int) 
RETURNS int
AS
BEGIN
DECLARE @RETURN int
SET @Return = NULL
Select @Return = (CASE WHEN [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') IS NULL 
OR [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') = '' THEN @bookkey
ELSE [dbo].[rpt_get_misc_value](@bookkey, 1, 'long') END)

RETURN @Return

END