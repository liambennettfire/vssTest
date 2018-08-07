/****** Object:  UserDefinedFunction [dbo].[rpt_get_copyright_year]    Script Date: 05/02/2011 13:07:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_copyright_year') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_copyright_year
GO

CREATE FUNCTION [dbo].[rpt_get_copyright_year]
		(@i_bookkey	INT)

RETURNS VARCHAR(255)

/*	
Created by Ben Todd 2011/05/02

The purpose of the rpt_get_copyright_year function is to return copyright year

*/	

AS

BEGIN

	DECLARE @RETURN			VARCHAR(255)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @i_copyrightyear		INT
	
	SELECT @i_copyrightyear = copyrightyear
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey

	SELECT @v_desc = @i_copyrightyear

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
go


GRANT ALL ON rpt_get_copyright_year TO PUBLIC
Go
