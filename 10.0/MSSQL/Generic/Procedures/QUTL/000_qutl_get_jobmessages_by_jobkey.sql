if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_jobmessages_by_jobkey') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_jobmessages_by_jobkey
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qutl_get_jobmessages_by_jobkey]
(@i_jobkey				int,
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	SELECT v.*, t.title, t.ean, t.printingkey, t.formatname, p.taqprojecttitle as projectdesc, cp.usageclasscodedesc as projectclass,
		e.elementname, c.displayname, f.foldername
	FROM jobmessages_view v
	LEFT JOIN coretitleinfo t ON (v.bookkey = t.bookkey AND v.printingkey = t.printingkey)
	LEFT JOIN taqproject p ON (v.projectkey = p.taqprojectkey)
	LEFT JOIN coreprojectinfo cp ON (v.projectkey = cp.projectkey)
	LEFT JOIN element e ON (v.elementkey = e.elementkey)
	LEFT JOIN globalcontact c ON (v.contactkey = c.globalcontactkey)
	LEFT JOIN cloudfolderadmin f ON (v.cloudfolderkey = f.folderkey)
	WHERE v.jobkey = @i_jobkey
	
	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to retrieve data from jobsummary view.'
		RETURN
	END
	
GO

GRANT EXEC ON qutl_get_jobmessages_by_jobkey TO PUBLIC
GO

