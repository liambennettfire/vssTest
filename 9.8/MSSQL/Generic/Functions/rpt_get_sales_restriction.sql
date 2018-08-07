
/****** Object:  UserDefinedFunction [dbo].[rpt_get_Sales_restriction]    Script Date: 02/05/2013 16:28:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_Sales_restriction]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_Sales_restriction]
GO


GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_Sales_restriction]    Script Date: 02/05/2013 16:28:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rpt_get_Sales_restriction]
		(@i_bookkey	INT)

RETURNS VARCHAR(255)

/*	The purpose of the rpt_get_Sales_restriction function is return from gentables the Sales restriction description
*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_Salesrestrictioncode		INT

	SELECT @v_desc = ''
	
	SELECT @i_Salesrestrictioncode = canadianrestrictioncode
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey
	

IF @i_Salesrestrictioncode > 0
	BEGIN
		SELECT @v_desc = LTRIM(RTRIM(datadesc))
			FROM	gentables  
			WHERE  tableid = 428
					AND datacode = @i_Salesrestrictioncode
	end

	



	IF LEN(@v_desc) > 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END


GO


Grant all on [rpt_get_Sales_restriction] to public