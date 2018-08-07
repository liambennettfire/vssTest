DECLARE 
	@v_datacode_mktg_campaign_creation	INT,
	@v_processinstancekey				INT,
	@v_datacode_job						INT,
	@v_userid							VARCHAR(30),
	@o_error_code						integer ,
	@o_error_desc					    varchar(2000),
	@qsibatchkey						int,
	@qsijobkey							int,
	@v_count							int,
	@v_error							INT,
	@v_rowcount							INT
	
	
BEGIN

    set @v_userid = 'FB_CREATE_32859'
    
    SET @o_error_code = 0
	SET @o_error_desc = ''  
	
	set @qsibatchkey = null
	set @qsijobkey = null
	
	
	select @v_datacode_mktg_campaign_creation = datacode from gentables where tableid = 669 and datadesc = 'HMH Mktg Campaign Creation'
	
	select @v_datacode_job = datacode from gentables where tableid = 543 and datadesc = 'HMH Mktg Campaign Creation'
			
	exec get_next_key @v_userid, @v_processinstancekey output
	
	INSERT INTO tmwebprocessinstance (processinstancekey,processcode,lastuserid,lastmaintdate)
		VALUES(@v_processinstancekey,@v_datacode_mktg_campaign_creation,@v_userid,getdate())
		
		
	-- Spring 2016 General Interest
    INSERT INTO tmwebprocessinstanceitem (processinstancekey,key1,lastuserid,lastmaintdate)
		VALUES(@v_processinstancekey,24188668,@v_userid,getdate())
		
		
    INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544108882',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544129979',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544146679',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544192225',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544206700',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544242180',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544253247',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544263680',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544272880',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544276000',@v_userid,getdate())
		
		
	-----
	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544279117',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544300767',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544319516',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544325265',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544368057',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544373419',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544381056',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544387638',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544387645',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544387669',@v_userid,getdate())
		
		
	-----
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544416093',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544417854',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544443310',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544456235',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544464056',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544466319',@v_userid,getdate())
				
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544598201',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544598225',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544609709',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544617070',@v_userid,getdate())
		
		
		
	-----
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544628250',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544628267',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544628274',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544630055',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544630970',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544631021',@v_userid,getdate())
				
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544633360',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544633377',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544634244',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544634497',@v_userid,getdate())
			
	----
	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544639669',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544639683',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544648944',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544649651',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544649675',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544651081',@v_userid,getdate())
				
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544663329',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544663336',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544703049',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544703384',@v_userid,getdate())
			
	----
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544703711',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544704831',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544704848',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544704855',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705012',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705029',@v_userid,getdate())
				
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705050',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705159',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705166',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705180',@v_userid,getdate())
			
	----
	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705197',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705203',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705210',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705227',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705234',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705241',@v_userid,getdate())
				
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705258',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705265',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705272',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705289',@v_userid,getdate())
			
	----
	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705296',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705319',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705340',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705371',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544705395',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544706262',@v_userid,getdate())
				
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544709034',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544714441',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544715264',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544716193',@v_userid,getdate())
			
	----
	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544746527',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780547640983',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780547853185',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780547973180',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780618739950',@v_userid,getdate())
		
	
	SELECT * FROM HMHMktgCampaignISBNs where processinstancekey = @v_processinstancekey
		
		
	----CREATE PROC [dbo].[HMH_Create_Mktg_Campaigns] (@i_instancekey int, @i_jobkey int)
	exec dbo.HMH_Create_Mktg_Campaigns @v_processinstancekey, @qsijobkey
	 
END