if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_cloudfolderadmin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_cloudfolderadmin
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qutl_get_cloudfolderadmin]
(@i_folderkey			int,
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	IF @i_folderkey > 0 BEGIN
	  SELECT * 
	    FROM cloudfolderadmin
	   WHERE folderkey = @i_folderkey
	END
	ELSE BEGIN
	  SELECT * 
	    FROM cloudfolderadmin
	END
	
	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to retrieve data from cloudfolderadmin table.'
		RETURN
	END
	
GO

GRANT EXEC ON qutl_get_cloudfolderadmin TO PUBLIC
GO

