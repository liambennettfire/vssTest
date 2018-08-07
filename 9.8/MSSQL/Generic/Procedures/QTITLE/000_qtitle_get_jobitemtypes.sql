if exists (select * from dbo.sysobjects where id = object_id(N'dbo.[qtitle_get_jobitemtypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.[qtitle_get_jobitemtypes]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qtitle_get_jobitemtypes]
(@o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	DECLARE @v_jobitemtypecode INT
					
	SELECT @v_jobitemtypecode = datacode FROM gentables WHERE tableid=550 AND qsicode=13
	
	SELECT i.*, s.datadesc
	FROM gentablesitemtype i
	JOIN subgentables s ON (s.tableid=i.tableid AND s.datacode=i.datacode AND s.datasubcode=i.datasubcode)
	WHERE i.tableid=636
		AND i.datacode=3
		AND i.itemtypecode=@v_jobitemtypecode
	
	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to retrieve itemtype data from [qtitle_get_jobitemtypes].'
		RETURN
	END
	
GO

GRANT EXEC ON [qtitle_get_jobitemtypes] TO PUBLIC
GO

