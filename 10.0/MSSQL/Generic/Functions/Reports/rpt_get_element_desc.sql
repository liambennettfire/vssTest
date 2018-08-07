
/****** Object:  UserDefinedFunction [dbo].[rpt_get_element_desc]    Script Date: 03/24/2009 13:06:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_element_desc') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_element_desc
GO
create FUNCTION [dbo].[rpt_get_element_desc](
	@i_elementkey	INT
)
RETURNS VARCHAR(80)
AS
/*  	Parameter Options
		@i_elementkey

Returns Element Desc

												*/

BEGIN

	DECLARE @RETURN			VARCHAR(80)
	DECLARE @v_desc			VARCHAR(80)


	SELECT @v_desc = RTRIM(LTRIM(taqelementdesc))
	FROM taqprojectelement
	WHERE taqelementkey = @i_elementkey




	IF LEN(@v_desc)> 0
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
Grant All on dbo.rpt_get_element_desc to Public
go
