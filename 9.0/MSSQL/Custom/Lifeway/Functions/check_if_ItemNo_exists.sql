/****** Object:  UserDefinedFunction [dbo].[check_if_ItemNo_exists]    Script Date: 08/03/2015 12:40:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[check_if_ItemNo_exists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[check_if_ItemNo_exists]
GO
/****** Object:  UserDefinedFunction [dbo].[check_if_ItemNo_exists]    Script Date: 07/24/2015 09:12:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This returns 1 for yes, the ItemNo exists and 0 if it does not
CREATE FUNCTION [dbo].[check_if_ItemNo_exists](@v_check_ItemNo varCHAR(20))
RETURNS INT
AS
BEGIN
declare @ItemNo varchar(20)
declare @bool bit

select @ItemNo=LTRIM(rtrim(itemnumber)) from isbn where itemnumber = @v_check_ItemNo

if @ItemNo is not null and @ItemNo <> ''
	select @bool =1
else
	select @bool = 0

return @bool

END

GO


