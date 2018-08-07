SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_GentableFilterkey]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_GentableFilterkey]
GO



CREATE FUNCTION qweb_get_GentableFilterkey(@i_tableid	INT)

RETURNS INT

AS
BEGIN
	DECLARE @i_filterorglevelkey		INT

	SELECT @i_filterorglevelkey = filterorglevelkey
	FROM gentablesdesc
	WHERE tableid = @i_tableid


RETURN @i_filterorglevelkey

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

