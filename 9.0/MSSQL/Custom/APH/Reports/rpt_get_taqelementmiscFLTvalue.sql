/****** Object:  UserDefinedFunction [dbo].[rpt_get_taqelementmiscFLTvalue]    Script Date: 07/28/2015 14:42:52 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_taqelementmiscFLTvalue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].rpt_get_taqelementmiscFLTvalue
GO
/****** Object:  UserDefinedFunction [dbo].[rpt_get_taqelementmiscFLTvalue]    Script Date: 07/28/2015 14:19:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 --   exec dbo.rpt_get_taqelementmiscFLTvalue 34330904,108

Create FUNCTION [dbo].[rpt_get_taqelementmiscFLTvalue]
			(@i_taqelementkey	INT, 
			@v_misckey	INT)
RETURNS VARCHAR(255) 
/*	The purpose of this function is to return FLOAT values from the taqelementmisc table

*/
AS
BEGIN
	DECLARE @RETURN				VARCHAR(255)
	DECLARE @f_value			float
	
	SELECT @f_value = floatvalue
	FROM	taqelementmisc (nolock) 
				
	WHERE	taqelementkey = @i_taqelementkey and misckey = @v_misckey
			IF datalength(@f_value) > 0
				BEGIN
					SELECT @RETURN = @f_value
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
RETURN @RETURN
END

GO