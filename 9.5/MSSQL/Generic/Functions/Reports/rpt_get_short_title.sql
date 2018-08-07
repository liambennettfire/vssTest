
/****** Object:  UserDefinedFunction [dbo].[rpt_get_short_title]    Script Date: 03/24/2009 13:15:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_short_title') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_short_title
GO

CREATE FUNCTION [dbo].[rpt_get_short_title] (
		@i_bookkey	INT)
	
	RETURNS VARCHAR(50)
	
/* returns the Short Title from book table */

AS
BEGIN
	DECLARE @RETURN			VARCHAR(50)
		

	SELECT @RETURN = ltrim(rtrim(shorttitle))
	FROM book
	WHERE bookkey = @i_bookkey


  RETURN @RETURN
END

go
Grant All on dbo.rpt_get_short_title to Public
go
