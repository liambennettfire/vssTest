if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_jobitemtypes') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_jobitemtypes
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qutl_get_jobitemtypes]
(@i_jobkey				int,
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	DECLARE @v_jobitemtypecode INT,
					@v_usageclasscode INT
					
	SELECT @v_jobitemtypecode = datacode FROM gentables WHERE tableid=550 AND qsicode=13
	
	SELECT @v_usageclasscode = COALESCE(i.itemtypesubcode, s.datasubcode)
	FROM qsijob j
	OUTER APPLY (select top 1 itemtypesubcode from gentablesitemtype it where it.tableid=543 AND it.itemtypecode = @v_jobitemtypecode AND it.datacode = j.jobtypecode) i
	LEFT JOIN subgentables s ON (s.tableid=550 AND s.qsicode=34)
	WHERE j.qsijobkey = @i_jobkey
	
	SELECT i.*, s.datadesc
	FROM gentablesitemtype i
	JOIN subgentables s ON (s.tableid=i.tableid AND s.datacode=i.datacode AND s.datasubcode=i.datasubcode)
	WHERE i.tableid=636
		AND i.datacode=2
		AND i.itemtypecode=@v_jobitemtypecode
		AND i.itemtypesubcode=@v_usageclasscode
	order by s.datasubcode
	
	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to retrieve itemtype data from qutl_get_jobitemtypes.'
		RETURN
	END
	
GO

GRANT EXEC ON qutl_get_jobitemtypes TO PUBLIC
GO

