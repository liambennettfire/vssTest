IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.send_email') AND (type = 'P' OR type = 'RF'))
BEGIN
  DROP PROC dbo.send_email
END
GO

CREATE PROCEDURE send_email @v_profile_name varchar(100),
							@v_recipients varchar(500),	
							@v_copy_recipients varchar(500), 
							@v_blind_copy_recipients varchar(500), 
							@v_subject varchar(500),
							@v_body text,
							@v_file_attachments varchar(4000),	
							@o_error_code INT OUTPUT,
							@o_error_desc VARCHAR(2000) OUTPUT
				

 AS
BEGIN

DECLARE
@v_externalcode int

EXEC msdb.dbo.sp_send_dbmail @profile_name = @v_profile_name,
							 @recipients = @v_recipients,
							 @copy_recipients = @v_copy_recipients,
							 @blind_copy_recipients = @v_blind_copy_recipients,
							 @subject = @v_subject,
							 @body = @v_body,
							 @file_attachments = @v_file_attachments,
							 @body_format = 'HTML'
END
GO
GRANT EXECUTE ON dbo.send_email TO PUBLIC
GO







