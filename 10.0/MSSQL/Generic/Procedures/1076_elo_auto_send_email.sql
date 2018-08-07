IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.elo_auto_send_email') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.elo_auto_send_email
END
GO

CREATE PROCEDURE elo_auto_send_email @v_profile_name varchar(100),
							@v_recipients varchar(500),
							@v_subject varchar(500),
							@v_body varchar(4000)
				

 AS
BEGIN

DECLARE
@v_externalcode int

EXEC msdb.dbo.sp_send_dbmail @profile_name = @v_profile_name,
							 @recipients = @v_recipients,
							 @subject = @v_subject,
							 @body = @v_body
END
GO
GRANT EXECUTE ON dbo.elo_auto_send_email TO PUBLIC
GO

GRANT EXECUTE ON dbo.elo_auto_send_email to public







