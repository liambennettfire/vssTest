if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_jobmessages_by_bookkey') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_jobmessages_by_bookkey
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qutl_get_jobmessages_by_bookkey]
(@i_bookkey				int,
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
	SELECT v.*, j.jobdescshort, g.datadesc as jobtypedesc, t.printingkey, p.taqprojecttitle,
		e.elementname, c.displayname
	FROM jobmessages_view v
	LEFT JOIN coretitleinfo t ON (v.bookkey = t.bookkey AND v.printingkey = t.printingkey)
	LEFT JOIN taqproject p ON (v.projectkey = p.taqprojectkey)
	LEFT JOIN element e ON (v.elementkey = e.elementkey)
	LEFT JOIN globalcontact c ON (v.contactkey = c.globalcontactkey)
	LEFT JOIN qsijob j ON (v.jobkey = j.qsijobkey)
	LEFT JOIN gentables g ON (g.tableid = 543 AND v.jobtypecode = g.datacode)
	WHERE v.bookkey = @i_bookkey
		AND g.gen1ind = 1
	
	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to retrieve data from jobsummary view.'
		RETURN
	END
	
GO

GRANT EXEC ON qutl_get_jobmessages_by_bookkey TO PUBLIC
GO

