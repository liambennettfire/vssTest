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
		
		
	-- Spring 2016 Culinary
    INSERT INTO tmwebprocessinstanceitem (processinstancekey,key1,lastuserid,lastmaintdate)
		VALUES(@v_processinstancekey,24188670,@v_userid,getdate())
		
		
    INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544557192',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780470928660',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544439696',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544714465',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544325289',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544176485',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544546462',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544715271',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544230750',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544715677',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544190696',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544715295',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544715554',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544714458',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544557246',@v_userid,getdate())
			
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544663305',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544018457',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544534315',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544018464',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544715288',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544611627',@v_userid,getdate())
		
	
	SELECT * FROM HMHMktgCampaignISBNs where processinstancekey = @v_processinstancekey
		
		
	 
	--CREATE PROC [dbo].[HMH_Create_Mktg_Campaigns] (@i_instancekey int, @i_jobkey int)
	exec dbo.HMH_Create_Mktg_Campaigns @v_processinstancekey, @qsijobkey
END