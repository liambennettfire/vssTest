/****** Object:  UserDefinedFunction [dbo].[check_if_upc_exists]    Script Date: 08/03/2015 12:40:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[check_if_upc_exists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[check_if_upc_exists]
GO
/****** Object:  UserDefinedFunction [dbo].[check_if_upc_exists]    Script Date: 07/24/2015 09:12:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- This returns 1 for yes, the upc exists and 0 if it does not
CREATE FUNCTION [dbo].[check_if_upc_exists](@v_check_upc varCHAR(20))
RETURNS INT
AS
BEGIN
declare @upc varchar(20)
declare @bool bit

select @upc=LTRIM(rtrim(upc)) from isbn where upc = @v_check_upc

if @upc is not null and @upc <> ''
	select @bool =1
else
	select @bool = 0

return @bool

END

GO


