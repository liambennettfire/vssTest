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
		
		
	-- Spring 2016 Young Readers
    INSERT INTO tmwebprocessinstanceitem (processinstancekey,key1,lastuserid,lastmaintdate)
		VALUES(@v_processinstancekey,24188669,@v_userid,getdate())
		
		
    INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668270',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544506725',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544586567',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668386',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668584',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668577',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668331',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544096677',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544633889',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668409',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544674547',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668379',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544651227',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544390997',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544596313',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668362',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544598140',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544570986',@v_userid,getdate())
	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544639706',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544277397',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668461',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544619937',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668515',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544517936',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544518278',@v_userid,getdate())
	------	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668690',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780547906928',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544541214',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544512641',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544370302',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544582590',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544416192',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544651630',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544651647',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544652224',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544652255',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544652231',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544547667',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544551091',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544611078',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544551077',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544671744',@v_userid,getdate())
	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544709515',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544586178',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544582606',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668508',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544708976',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668300',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544602274',@v_userid,getdate())
		
	------	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668447',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544546653',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668393',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544630901',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668591',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544534339',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544656475',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668539',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544706330',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544301801',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544352988',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780547907086',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544451711',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544641020',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544671720',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544750500',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544319615',@v_userid,getdate())
	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544699564',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668317',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544540064',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544586543',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544641013',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544602007',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668546',@v_userid,getdate())	
		
		
	------	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544582491',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544612310',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544652262',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668430',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668294',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544656482',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544611634',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544671713',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780547330129',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668287',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544708990',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544671706',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544671683',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544225299',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544641075',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544671737',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544640412',@v_userid,getdate())
	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544357693',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668683',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544650312',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544517905',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544699618',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544319608',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668348',@v_userid,getdate())
		
		
	------	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544512658',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544640542',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668324',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544280052',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668522',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544148925',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668560',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544671652',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544640535',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780547338057',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668706',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544494121',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544318861',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544319592',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544596320',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668416',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668355',@v_userid,getdate())
	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544641051',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544318175',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544433007',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544671690',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544472709',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544699601',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544641068',@v_userid,getdate())	
		
		
	------	
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668676',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544633155',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544223790',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544598171',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544671676',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544535350',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668423',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668485',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544391017',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668492',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544671751',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668782',@v_userid,getdate())
		
	INSERT INTO HMHMktgCampaignISBNs (processinstancekey,isbn,lastuserid,lastmaintdate)
		VALUES (@v_processinstancekey,'9780544668553',@v_userid,getdate())
		
	
	SELECT * FROM HMHMktgCampaignISBNs where processinstancekey = @v_processinstancekey
		
		
	--CREATE PROC [dbo].[HMH_Create_Mktg_Campaigns] (@i_instancekey int, @i_jobkey int)
	exec dbo.HMH_Create_Mktg_Campaigns @v_processinstancekey, @qsijobkey
END