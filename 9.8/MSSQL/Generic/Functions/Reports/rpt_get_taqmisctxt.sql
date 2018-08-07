
/****** Object:  UserDefinedFunction [dbo].[rpt_get_taqmisctxt]    Script Date: 03/24/2009 13:18:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_taqmisctxt') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_taqmisctxt
GO
CREATE FUNCTION [dbo].[rpt_get_taqmisctxt]
			(@i_taqprojectkey	INT, 
			@v_misckey	INT)
RETURNS VARCHAR(255) 
/*	The purpose of the rpt_get_taqmisctxt function is to return text values from the taqprojectmisc table

*/
AS
BEGIN
	DECLARE @RETURN				VARCHAR(255)
	DECLARE @v_longvalue		VARCHAR(255)
	
	SELECT @v_longvalue = longvalue
	FROM	taqprojectmisc (nolock) 
				
	WHERE	taqprojectkey = @i_taqprojectkey and misckey = @v_misckey
			IF datalength(@v_longvalue) > 0
				BEGIN
					SELECT @RETURN = @v_longvalue
				END
			ELSE
				BEGIN
					SELECT @RETURN = ''
				END
RETURN @RETURN
END

go
Grant All on dbo.rpt_get_taqmisctxt to Public
go