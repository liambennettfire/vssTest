if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_cloudfolderassetadmin') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_cloudfolderassetadmin
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qutl_get_cloudfolderassetadmin]
(@i_folderkey			int,
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	SELECT *
	  FROM cloudfolderassetadmin
	 WHERE folderkey = @i_folderkey
	
	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to retrieve data from cloudfolderassetadmin view.'
		RETURN
	END
	
GO

GRANT EXEC ON qutl_get_cloudfolderassetadmin TO PUBLIC
GO

