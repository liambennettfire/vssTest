/****** Object:  UserDefinedFunction [dbo].[rpt_get_postyle]    Script Date: 01/14/2015 11:48:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_postyle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[rpt_get_postyle]
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_postyle]    Script Date: 01/14/2015 11:48:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[rpt_get_postyle] (@i_gpokey	INT)

RETURNS	varchar(255)

AS

BEGIN

	DECLARE @v_RETURN varchar(255),
	@i_taqprojecttypecode int,
	@i_convertedpotypecode int

	select @i_convertedpotypecode = datacode from gentables where tableid=521 and qsicode=9
	select @i_taqprojecttypecode = taqprojectstatuscode from taqproject where taqprojectkey = @i_gpokey
	
	IF coalesce(@i_taqprojecttypecode,0)=@i_convertedpotypecode
		select @v_RETURN = 'OLD'
	ELSE 
		select @v_RETURN = 'NEW'	

RETURN @v_RETURN

END
GO

GRANT EXEC ON [dbo].[rpt_get_postyle] to PUBLIC
GO

