
/****** Object:  UserDefinedFunction [dbo].[rpt_get_full_author_display_name]    Script Date: 03/24/2009 13:07:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_full_author_display_name') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_full_author_display_name
GO

CREATE FUNCTION [dbo].[rpt_get_full_author_display_name]
		(@i_bookkey	INT)

RETURNS VARCHAR(255)

/*	The purpose of the rpt_get_full_author_display_name function is to return a the author display name on bookdetail

*/	

AS

BEGIN

	DECLARE @RETURN				VARCHAR(255)
	DECLARE @v_desc				VARCHAR(255)
	
	SELECT @v_desc = ltrim(rtrim(fullauthordisplayname))
	FROM	bookdetail
	WHERE	bookkey = @i_bookkey 


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
Grant All on dbo.rpt_get_full_author_display_name to Public
go