
/****** Object:  UserDefinedFunction [dbo].[rpt_get_sub_title]    Script Date: 03/24/2009 13:16:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_sub_title') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_sub_title
GO

CREATE FUNCTION [dbo].[rpt_get_sub_title] (
		@i_bookkey	INT)
	
RETURNS VARCHAR(255)

	
AS
BEGIN
	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_subtitle 			VARCHAR(255)
		

	SELECT @v_subtitle = ltrim(rtrim(subtitle))
	FROM book
	WHERE bookkey = @i_bookkey
	
	IF LEN(@v_subtitle) > 0
		BEGIN	
			SELECT @RETURN = @v_subtitle
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END

  RETURN @RETURN
END
go
Grant All on dbo.rpt_get_sub_title to Public
go