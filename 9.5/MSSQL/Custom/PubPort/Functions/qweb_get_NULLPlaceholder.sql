SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_NULLPlaceholder]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_NULLPlaceholder]
GO




CREATE FUNCTION dbo.qweb_get_NULLPlaceholder()
		

RETURNS VARCHAR(23)

/*	The purpose of the qweb_get_NULLPlaceholder function is to simply return a NULL value so that when picking a list of fields, you can include 
		a placeholder
*/	

AS

BEGIN

DECLARE @RETURN			VARCHAR(23)
SELECT @RETURN = ''

RETURN @RETURN


END










GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

