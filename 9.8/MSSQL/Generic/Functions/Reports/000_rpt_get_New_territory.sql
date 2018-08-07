IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_New_territory') and xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION dbo.rpt_get_New_territory
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_New_territory]    Script Date: 04/07/2014 15:06:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[rpt_get_New_territory] (
		@i_bookkey	INT)
	
	RETURNS VARCHAR(2000)
	
/* returns the New Territory description from territoryrights */

AS
BEGIN
	DECLARE @RETURN	VARCHAR(2000)
	DECLARE @v_desc	VARCHAR(2000)
		
	SELECT @v_desc = ltrim(rtrim(description))
	FROM territoryrights
	WHERE bookkey = @i_bookkey
	
	
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

Grant all on dbo.rpt_get_New_territory to public
go
