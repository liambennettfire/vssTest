

/****** Object:  StoredProcedure [dbo].[imp_300014096001]    Script Date: 4/2/2016 2:01:21 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[imp_300014096001]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[imp_300014096001]
GO

/****** Object:  StoredProcedure [dbo].[imp_300014096001]    Script Date: 4/2/2016 2:01:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[imp_300014096001] 
  @i_batch int, 
  @i_row int , 
  @i_dmlkey bigint, 
  @i_titlekeyset varchar(500),
  @i_contactkeyset varchar(500),
  @i_templatekey int,
  @i_elementseq int,
  @i_level int,
  @i_userid varchar(50),
  @i_newtitleind int,
  @i_newcontactind int,
  @o_writehistoryind int output
AS

BEGIN 
/* 
	*Territory IKE load*
	1000140960 This elementkey is technically the elementkey for the EXCLUSIVE rights. But this proc does the processing
				for all the Territory Elements with mnemonics of Territories_EXCLUSIVE, Territories_NONEXCLUSIVE, Territories_NOTFORSALE,
				and Teritories_Desc.
				This proc determines what needs to be deleted or added to the territoryrightcountries 
				table by querying the differences between that table and imp_territory.
	see also imp_100014096001- The imp_100014096001 proc takes the definitions in the source data and puts entries into imp_territory 
				table according to each title and how the rights should be set up in territoryrightcountries.
	 
	The assumptions made for this loader to work are:
	1) all three elementkeys are present in imp_template_detail, 100014096 (Territories_EXCLUSIVE), 100014097 (Territories_NONEXCLUSIVE),
		 100014098 (Territories_NOTFORSALE), 100014103 (Territories_DESC) even if they are blank in the source data
	2) The first three of above mentioned columns in the source data table have country codes (their BISAC codes, so two character codes, 
		GB for the UK) delimited by a space (if not a space, then put delemiter in addlqualifier in imp_template_detail)
	3) the 'WORLD' or 'ROW' appear only once in any of the columns. That means, no WORLD in one column and ROW in the other. No WORLD in 
		two columns. Just one of them can appear in one of the element values for a given title record.
	4) if elementkey 100014101,'TerritoriesTable_Desc', does not exist in the template or has no value, then there will be the default of 
		"Imported Countries" text displayed on the title summary page describing what this territory is like. 
		Example descriptors are 'World Exclusive' or 'IE and GB exc'

	THERE ARE 8 TOP LEVEL USE CASES: 
		1. Only exclusive countries are listed and there are blanks or no elements in the template for Non-exclusive or NotForSale
		2. Only exclusive and non-exclusive
		3. Only exclusive and notforsale
		4. exclusive, non_excl and notforsale
		5. only non-exclusive 
		6. only non_exclusive and notforsale
		7. only notforsale
		8. blanks in all columns (if there aren't any of these three elements in template, then this rule will never be called, but they 
			could all be blank)
		
	20160628 - JDOE - CREATED ORIGINAL

*/
DECLARE 
    @v_elementval VARCHAR(4000),
	@v_errcode	INT,
  	@v_errmsg 	VARCHAR(4000),
	@v_elementdesc	VARCHAR(4000),
	@v_elementkey	BIGINT,
	@v_bookkey 	INT,
	@v_printingkey  int,
	@v_batchkey int,
	@v_row_id int,
	@v_rowcount	INT,
	@v_count  INT,
	@v_territoryrightskey int, 
	@v_terrirtoryrightskey_template  int,
	@v_countrycode int,
	@v_exclusiveind int,
	@v_history_ind int,
	@v_itemtype  int,
	@v_itemtype_hold  int,
    @v_forsaleind  int,
    @v_contractexclusiveind  int,
    @v_nonexclusivesubrightsoldind  int,
    @v_currentexclusiveind  int,
    @v_exclusivesubrightsoldind  int,
	@v_CountryDesc  varchar(200),
	@v_ExclusiveCode int,
	@v_DeleteInd  int,
	@v_currentterritorycode int,
	@v_contractterritorycode int,
	@v_autoterritorydescind int,
	@v_singlecountrycode int,
	@v_singlecountrygroupcode int,
	@v_updatewithsubrightsind int,
	@v_note int,
	@v_forsalehistory int,
	@v_notforsalehistory int,
	@v_template_value varchar(200),
	@v_template_name varchar(200),
	@v_rightsdesc varchar(200),
	@v_prev_rightsdesc varchar(255),
	@v_cur_currentterritorycode int,
	@v_cur_contractterritorycode int,
	@v_cur_template_name varchar(200),
	@v_template_taqprojectkey int,
	@v_bokkey_taqprojectkey int,
	@v_debug int 
		declare @v_taqprojectkey int
	declare @v_rightskey int
BEGIN
  SET @v_debug = 0
  if @v_debug<>0 print 'imp_300014096001'

  SET @v_rowcount = 0
  SET @v_errcode = 1
  SET @v_errmsg = ''
  SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
  SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
  set @v_history_ind=0  -- handle history internally to the sp
  set @o_writehistoryind=0

  if @v_debug<>0 print '@v_bookkey '+cast(@v_bookkey as varchar)
  if @v_debug<>0 print '@i_batch '+cast(@i_batch as varchar)
  if @v_debug<>0 print '@i_row '+cast(@i_row as varchar)
  --if @v_debug<>0 select * from territoryrightcountries where bookkey=@v_bookkey


	SELECT @v_rightsdesc = originalvalue
	FROM imp_batch_detail ib
	left join imp_template_detail it on ib.elementkey=it.elementkey  and it.templatekey=@i_templatekey
	WHERE ib.batchkey = @i_batch
			and row_id = @i_row
			and elementseq = @i_elementseq
			and ib.elementkey = 100014103

	if isNull(@v_rightsdesc,'')='' set @v_rightsdesc='Imported Countries'

  select @v_territoryrightskey=territoryrightskey,@v_currentterritorycode=currentterritorycode,@v_prev_rightsdesc=[description] ,
	@v_contractterritorycode=contractterritorycode,@v_itemtype=itemtype,@v_autoterritorydescind=autoterritorydescind,@v_exclusivecode=exclusivecode,
	@v_updatewithsubrightsind=updatewithsubrightsind,@v_taqprojectkey=taqprojectkey,@v_rightskey=rightskey,
	@v_singlecountrycode=singlecountrycode,@v_singlecountrygroupcode=singlecountrygroupcode,@v_note=note,
	@v_notforsalehistory=notforsalehistory
  from  territoryrights where bookkey=@v_bookkey

  -- process deletes
  if @v_debug<>0 print 'starting..'
  --if @v_debug<>0 select * from imp_territory where batchkey=@i_batch and row_id=@i_row
  if @v_debug<>0 print 'process deletes'
  --if @v_debug<>0 select territoryrightskey,bookkey,countrycode from territoryrightcountries where bookkey=@v_bookkey and countrycode not in (select countrycode from imp_territory where batchkey=@i_batch and row_id=@i_row)
  --if @v_debug<>0 
	 -- select territoryrightskey,bookkey,countrycode 
  --    from territoryrightcountries trc 
  --    where bookkey=@v_bookkey 
  --      and countrycode not in (
	 --      select countrycode
		--     from imp_territory i 
		--	 where batchkey=1
		--	   and row_id=1
		--	   and i.countrycode=trc.countrycode
		--	   and coalesce(i.forsaleind,2)=coalesce(trc.forsaleind,2)
		--	   and coalesce(i.contractexclusiveind,2)=coalesce(trc.contractexclusiveind,2)
		--	   and coalesce(i.nonexclusivesubrightsoldind,2)=coalesce(trc.nonexclusivesubrightsoldind,2)
		--	   and coalesce(i.currentexclusiveind,2)=coalesce(trc.currentexclusiveind,2)
		--	   and coalesce(i.exclusivesubrightsoldind,2)=coalesce(trc.exclusivesubrightsoldind,2)	)
  declare territory_delete cursor fast_forward for
    select territoryrightskey,bookkey,countrycode 
      from territoryrightcountries trc 
      where bookkey=@v_bookkey 
        and countrycode not in (
	       select countrycode
		     from imp_territory i 
			 where batchkey=@i_batch
			   and row_id=@i_row
			   and i.countrycode=trc.countrycode
			   and coalesce(i.forsaleind,2)=coalesce(trc.forsaleind,2)
			   and coalesce(i.contractexclusiveind,2)=coalesce(trc.contractexclusiveind,2)
			   and coalesce(i.nonexclusivesubrightsoldind,0)=coalesce(trc.nonexclusivesubrightsoldind,2)
			   and coalesce(i.currentexclusiveind,0)=coalesce(trc.currentexclusiveind,2)
			   and coalesce(i.exclusivesubrightsoldind,2)=coalesce(trc.exclusivesubrightsoldind,2)	)
	
   -- select territoryrightskey,bookkey,countrycode 
   --   from territoryrightcountries 
	  --where bookkey=@v_bookkey 
	  --  and countrycode not in (select countrycode from imp_territory where batchkey=@i_batch and row_id=@i_row)
  open territory_delete
  fetch territory_delete into @v_territoryrightskey,@v_bookkey,@v_countrycode
  while @@fetch_status=0
    begin
  	  if @v_debug<>0 print 'delete'
  	  if @v_debug<>0 print ' @v_territoryrightskey '+coalesce(cast(@v_territoryrightskey as varchar),'n/a')
  	  if @v_debug<>0 print ' @v_countrycode '+coalesce(cast(@v_countrycode as varchar),'n/a')
  	  if @v_debug<>0 print ' @v_bookkey '+coalesce(cast(@v_bookkey as varchar),'n/a')
  	  
	  delete territoryrightcountries where territoryrightskey=@v_territoryrightskey and bookkey=@v_bookkey and countrycode=@v_countrycode
	  set @v_history_ind=1
      update imp_territory set deleteind=1 where batchkey=@i_batch and row_id=@i_row and countrycode=@v_countrycode

	  fetch territory_delete into @v_territoryrightskey,@v_bookkey,@v_countrycode
	end
  close territory_delete
  deallocate territory_delete
  
  select @v_territoryrightskey=territoryrightskey,@v_currentterritorycode=currentterritorycode,@v_prev_rightsdesc=[description] ,
	@v_contractterritorycode=contractterritorycode,@v_itemtype=itemtype,@v_autoterritorydescind=autoterritorydescind,@v_exclusivecode=exclusivecode,
	@v_updatewithsubrightsind=updatewithsubrightsind,@v_taqprojectkey=taqprojectkey,@v_rightskey=rightskey,
	@v_singlecountrycode=singlecountrycode,@v_singlecountrygroupcode=singlecountrygroupcode,@v_note=note,
	@v_notforsalehistory=notforsalehistory
  from  territoryrights where bookkey=@v_bookkey

  if @v_territoryrightskey is not null begin
	if @v_debug<>0 print 'Territoryrightskey for this bookkey already exists.'

	if ltrim(rtrim(isNull(@v_rightsdesc,''))) <> ltrim(rtrim(isNull(@v_prev_rightsdesc,''))) 
		or isNull(@v_currentterritorycode,-1)<>3
		or isNull(@v_itemtype,-1)<>1
		or isNull(@v_contractterritorycode,-1)<>3
		or isNull(@v_autoterritorydescind,-1)<>0
		or isNull(@v_exclusivecode,-1)<>3
		or isNull(@v_updatewithsubrightsind,-1)<>0
		or @v_taqprojectkey is not null
		or @v_rightskey is not null
		or @v_singlecountrycode is not null
		or @v_singlecountrygroupcode is not null
		or @v_note is not null
		or @v_notforsalehistory is not null
	begin
		update territoryrights set description=@v_rightsdesc,  itemtype=1, currentterritorycode=3,contractterritorycode=3,autoterritorydescind=0,exclusivecode=3,updatewithsubrightsind=0,
			taqprojectkey=null,rightskey=null,singlecountrycode=null,singlecountrygroupcode=null,note=null,forsalehistory=null,notforsalehistory=null,lastuserid=@i_userid,lastmaintdate=getdate()
		where territoryrightskey=@v_territoryrightskey
		set @v_history_ind=1
	end
	
  end
  else if exists (select 1 from imp_territory where batchkey=@i_batch and row_id=@i_row and coalesce(deleteind,0)<>1) begin
	if @v_debug<>0 print 'Creating territoryrightskey for this bookkey.'
	exec dbo.get_next_key @i_userid,@v_territoryrightskey output
	insert into territoryrights (territoryrightskey, itemtype, bookkey,currentterritorycode,contractterritorycode, description,
		autoterritorydescind,exclusivecode,updatewithsubrightsind,lastuserid,lastmaintdate)
	values (@v_territoryrightskey,1,@v_bookkey,3,3,@v_rightsdesc,0,3,0,@i_userid,getdate())
	set @v_history_ind=1
  end
  
  -- process adds
  if @v_debug<>0 print 'process adds'
  --if @v_debug<>0 select * from imp_territory where batchkey=@i_batch and row_id=@i_row  and countrycode not in (select countrycode from territoryrightcountries where bookkey=@v_bookkey)
  declare territory_adds cursor fast_forward for
    select batchkey,row_id,itemtype,forsaleind,contractexclusiveind,nonexclusivesubrightsoldind,currentexclusiveind,exclusivesubrightsoldind,
      CountryDesc,CountryCode,ExclusiveCode,DeleteInd 
      from imp_territory 
	  where batchkey=@i_batch and row_id=@i_row --and coalesce(deleteind,0)<>1
	    and countrycode not in (select countrycode from territoryrightcountries where bookkey=@v_bookkey)
  open territory_adds
  fetch territory_adds into 
    @v_batchkey,@v_row_id,@v_itemtype_hold,@v_forsaleind,@v_contractexclusiveind,
    @v_nonexclusivesubrightsoldind,@v_currentexclusiveind,@v_exclusivesubrightsoldind,
    @v_CountryDesc,@v_CountryCode,@v_ExclusiveCode,@v_DeleteInd
	/*
		select * from imp_territory
		select * from territoryrightcountries
	*/
  while @@fetch_status=0
    begin
		if @v_debug<>0 print 'add @v_territoryrightskey '+isNull(convert(varchar(25),@v_territoryrightskey),'')
		if @v_debug<>0 print '    @v_countrycode '+isNull(convert(varchar(25),@v_countrycode),'')
		if @v_debug<>0 print '    @v_currentexclusiveind '+isNull(convert(varchar(25),@v_currentexclusiveind),'')
		if @v_debug<>0 print '    @v_countrydesc '+isNUll(@v_countrydesc,'')
		if @v_debug<>0 print '    @v_forsaleind ' + convert(varchar(5),isNull(@v_forsaleind,''))
		if @v_debug<>0 print ' to bookkey = '+ convert(varchar(25),@v_bookkey)

		insert into  territoryrightcountries 
		(territoryrightskey,countrycode,itemtype,taqprojectkey,rightskey,bookkey,forsaleind,contractexclusiveind,nonexclusivesubrightsoldind,currentexclusiveind,exclusivesubrightsoldind,lastuserid,lastmaintdate)
		values
		(@v_territoryrightskey,@v_countrycode,@v_itemtype,null,null,@v_bookkey,@v_forsaleind,@v_contractexclusiveind,@v_nonexclusivesubrightsoldind,@v_currentexclusiveind,@v_exclusivesubrightsoldind,@i_userid,getdate())

		set @v_history_ind=1

		fetch territory_adds into 
			@v_batchkey,@v_row_id,@v_itemtype_hold,@v_forsaleind,@v_contractexclusiveind,
			@v_nonexclusivesubrightsoldind,@v_currentexclusiveind,@v_exclusivesubrightsoldind,
			@v_CountryDesc,@v_CountryCode,@v_ExclusiveCode,@v_DeleteInd
	end
  close territory_adds
  deallocate territory_adds

  --clean up 
--  delete imp_territory where batchkey=@i_batch and row_id=@i_row

  -- update history
  --UpdateHistory:
  if @v_history_ind=1
    begin 
      insert into titlehistory
        (bookkey,printingkey,columnkey,stringvalue,currentstringvalue,fielddesc,history_order,lastmaintdate,lastuserid)
        values
        (@v_bookkey,@v_printingkey,272,'Title affected by Territory Rights change - imported','Title affected by Territory Rights change - imported','Title Territory Updated',0,getdate(),@i_userid)
	  EXECUTE imp_write_feedback @i_batch, @i_row, @v_elementkey, @i_elementseq ,@i_dmlkey , 'Territories update', @i_level, 3 
	end

END

end


GO

grant execute on  [dbo].imp_300014096001  to public
