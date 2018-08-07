if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcs_titlelistautosend') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcs_titlelistautosend
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE [dbo].[qcs_titlelistautosend]
(@i_listkey				int,
 @i_templatekey			int,
 @i_userid          varchar(30),
 @o_error_code		int output,
 @o_error_desc		varchar(2000) output)
AS
	SET @o_error_code = 0
	SET @o_error_desc = ''
	
BEGIN
    BEGIN TRANSACTION
	DECLARE @v_startedmessagetypecode INT,
			@v_abortedmessagetypecode INT,
			@v_titlelistautosendjobtypecode INT,
			@v_readytoautomaticallyprocesstypecode INT,
			@v_templatename VARCHAR(255),
			@v_qsibatchkey  INT ,
			@v_qsijobkey    INT,
			@v_listcount	INT,
			@v_listkey		INT,
			@v_bookkey		INT,
			@v_printingkey	INT,
			@v_jobdesc      VARCHAR(2000),
			@v_jobdescshort VARCHAR(255),
			@v_messagelongdesc  VARCHAR(4000),
			@v_messageshortdesc VARCHAR(255),
		    @v_clientdefaultvalue INT,
		    @v_dateformat_value VARCHAR(40),
		    @v_dateformat_conversionvalue INT,
		    @v_curdatetime VARCHAR(255),
			@v_datacode INT,
			@v_startpos INT 		    			
					
	SELECT @v_startedmessagetypecode = datacode FROM gentables WHERE tableid=539 AND qsicode=1
	SELECT @v_abortedmessagetypecode = datacode FROM gentables WHERE tableid=539 AND qsicode=5
	SELECT @v_titlelistautosendjobtypecode = datacode FROM gentables WHERE tableid=543 AND qsicode=8
	SELECT @v_readytoautomaticallyprocesstypecode = datacode FROM gentables WHERE tableid=652 AND qsicode=1
	
	SELECT @v_clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 1) FROM clientdefaults WHERE clientdefaultid = 80		
	SELECT @v_dateformat_value = LTRIM(RTRIM(UPPER(datadesc))), @v_datacode = datacode FROM gentables WHERE tableid = 607 AND qsicode = @v_clientdefaultvalue
    SELECT @v_dateformat_conversionvalue = CAST(COALESCE(gentext2, '101') AS INT) FROM gentables_ext WHERE tableid = 607 AND datacode = @v_datacode	 
    SELECT @v_startpos = CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), -1) + 1
    SELECT @v_curdatetime = REPLACE(STUFF(CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), CHARINDEX(':', CONVERT(VARCHAR(25),CONVERT(VARCHAR(25), GETDATE(), @v_dateformat_conversionvalue) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), CURRENT_TIMESTAMP, 22), 11))), @v_startpos), 3, ''), '  ', ' ')	

    SELECT @v_templatename = templatename FROM csdistributiontemplate WHERE templatekey = @i_templatekey
	SET @v_jobdesc = 'Title List Auto Send using the ' + @v_templatename + ' distribution template. ' + @v_curdatetime
	SET @v_jobdescshort = 'Title List Auto Send ' + @v_curdatetime
	SET @v_messagelongdesc = 'Job Started ' + @v_curdatetime
	SET @v_messageshortdesc = 'Job Started'
	SET @v_qsibatchkey = NULL
	SET @v_qsijobkey   = NULL

    exec dbo.qutl_update_job @v_qsibatchkey output, @v_qsijobkey output, @v_titlelistautosendjobtypecode, NULL, @v_jobdesc,
		@v_jobdescshort, @i_userid, 0, 0, 0, @v_startedmessagetypecode, @v_messagelongdesc, @v_messageshortdesc, NULL, 1,
       @o_error_code output, @o_error_desc output
    IF @o_error_code < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to execute qutl_update_job: ' + @o_error_desc
	  ROLLBACK TRANSACTION
      RETURN
    END

	SELECT @v_listcount = COUNT(*) from qse_searchresults WHERE listkey = @i_listkey	
	UPDATE qsijob SET qtyprocessed = @v_listcount WHERE qsijobkey = @v_qsijobkey

	DECLARE c_processtitle CURSOR FOR
		SELECT listkey,key1,key2
		FROM qse_searchresults WHERE listkey = @i_listkey
	OPEN c_processtitle
	FETCH NEXT FROM c_processtitle INTO @v_listkey, @v_bookkey, @v_printingkey
			  
	WHILE (@@FETCH_STATUS = 0) 
		BEGIN 
			INSERT INTO cloudsendstaging (jobkey, bookkey, elementkey, csdisttemplatekey, jobstartind, jobendind, lastuserid, lastmaintdate, partnercontactkey, processstatuscode) 
			VALUES(@v_qsijobkey, @v_bookkey, NULL, @i_templatekey, NULL, NULL, @i_userid, getdate(), NULL, @v_readytoautomaticallyprocesstypecode)
		FETCH NEXT FROM c_processtitle INTO @v_listkey, @v_bookkey, @v_printingkey
		END
	CLOSE c_processtitle
	DEALLOCATE c_processtitle

	INSERT INTO cloudsendstaging (jobkey, bookkey, elementkey, csdisttemplatekey, jobstartind, jobendind, lastuserid, lastmaintdate, partnercontactkey, processstatuscode) 
	VALUES(@v_qsijobkey, NULL, NULL, @i_templatekey, NULL, 1, @i_userid, getdate(), NULL, @v_readytoautomaticallyprocesstypecode)

	IF @@ERROR <> 0
	BEGIN
		SET @o_error_code = -1
		SET @o_error_desc = 'Failed to do title list auto send.'
		ROLLBACK TRANSACTION
		RETURN
	END

COMMIT TRANSACTION
END	
GO

GRANT EXEC ON qcs_titlelistautosend TO PUBLIC
GO
