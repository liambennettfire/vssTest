/******************************************************************************
**  Name: imp_300014091001
**  Desc: IKE Territory Rights
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014091001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014091001]
GO

CREATE PROCEDURE dbo.imp_300014091001 

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

/* Territory Rights  */

BEGIN 

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
	@v_taqprojectkey int,
	@v_rightskey int,
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
	@v_cur_currentterritorycode int,
	@v_cur_contractterritorycode int,
	@v_cur_template_name varchar(200),
	@v_template_taqprojectkey int,
	@v_bokkey_taqprojectkey int,
	@v_debug int 
	
BEGIN
  SET @v_debug = 0
  if @v_debug<>0 print 'imp_300014091001'

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
  if @v_debug<>0 select * from imp_territory where batchkey=@i_batch and row_id=@i_row
  if @v_debug<>0 select * from territoryrightcountries where bookkey=@v_bookkey
  
  select @v_template_value=originalvalue
    from imp_batch_detail
    where batchkey=@i_batch
      and row_id=@i_row
      and elementseq=@i_elementseq
      and elementkey=100014092
  if @v_debug<>0 print 'externalcode = '+coalesce(@v_template_value, 'n/a')
  if @v_template_value is not null
    select
 	  @v_taqprojectkey=taqprojectkey,
	  @v_template_name=taqprojecttitle
	  from taqproject 
	  where externalcode=@v_template_value 
  else
    select @v_template_name='Imported country list'

  if @v_debug<>0 print 'taqprojectkey = '+coalesce(cast(@v_taqprojectkey as varchar), 'n/a')
  if @v_debug<>0 print 'taqprojecttitle(template name) = '+coalesce(@v_template_name, 'n/a')

  select 
    @v_terrirtoryrightskey_template=territoryrightskey,
	@v_itemtype=itemtype,
	@v_currentterritorycode=currentterritorycode,
	@v_contractterritorycode=contractterritorycode,
	@v_autoterritorydescind=autoterritorydescind,
	@v_exclusivecode=exclusivecode,
	@v_singlecountrycode=singlecountrycode,
	@v_singlecountrygroupcode=singlecountrygroupcode,
	@v_updatewithsubrightsind=updatewithsubrightsind,
	@v_forsalehistory=forsalehistory,
	@v_notforsalehistory=notforsalehistory,
	@v_rightsdesc=[description]
  from territoryrights
  where taqprojectkey=@v_taqprojectkey

  select @v_count=COUNT(*) from territoryrights where bookkey=@v_bookkey
  if @v_count=0
    begin
	  update keys set generickey=generickey+1
      select @v_territoryrightskey=generickey from keys
	  update keys set generickey=generickey+1
      select @v_rightskey=@v_rightskey from keys
      if @v_rightsdesc is null
	    begin
    	  set @v_itemtype=1  --?
		  set @v_currentterritorycode=3  --?
		  set @v_contractterritorycode=3  --?
		  set @v_autoterritorydescind=1  --?
		  set @v_exclusivecode=3  --?
		  set @v_singlecountrycode=null  --?
		  set @v_singlecountrygroupcode=null  --?
		  set @v_updatewithsubrightsind=0  --?
		  set @v_forsalehistory=null  --?
		  set @v_notforsalehistory=null  --?
		  set @v_rightsdesc='selected countries'
		end
      insert into territoryrights
       (territoryrightskey,itemtype,taqprojectkey,rightskey,bookkey,currentterritorycode,contractterritorycode,
         [description],autoterritorydescind,exclusivecode,singlecountrycode,singlecountrygroupcode,updatewithsubrightsind,
         note,forsalehistory,notforsalehistory,lastuserid,lastmaintdate)
	    values
	     (@v_territoryrightskey,@v_itemtype,null,null,@v_bookkey,@v_currentterritorycode,@v_contractterritorycode,
          @v_rightsdesc,@v_autoterritorydescind,@v_exclusivecode,@v_singlecountrycode,@v_singlecountrygroupcode,@v_updatewithsubrightsind,
          @v_note,@v_forsalehistory,@v_notforsalehistory,@i_userid,getdate())
	  set @v_history_ind=1
	  if @v_debug<>0 print 'new territoryrights row'
	end
  else
    begin
	   select 
	  	    @v_currentterritorycode=currentterritorycode,
	        @v_contractterritorycode=contractterritorycode,
	        @v_template_name=[description],
			@v_template_taqprojectkey=taqprojectkey
		  from territoryrights
		  where taqprojectkey=@v_taqprojectkey
	  Select  
			@v_cur_currentterritorycode=currentterritorycode,
			@v_cur_contractterritorycode=contractterritorycode,
			@v_cur_template_name=[description],
			@v_bokkey_taqprojectkey=taqprojectkey
		from  territoryrights
		where bookkey=@v_bookkey

      if @v_cur_currentterritorycode<>@v_currentterritorycode
		or	@v_cur_contractterritorycode<>@v_contractterritorycode
		or	@v_cur_template_name<>@v_template_name
	  --if @v_template_taqprojectkey<>@v_bokkey_taqprojectkey
	  begin
	    select @v_territoryrightskey=territoryrightskey from territoryrights where bookkey=@v_bookkey
		delete territoryrights where bookkey=@v_bookkey
  	    insert into territoryrights
	     (territoryrightskey,itemtype,taqprojectkey,rightskey,bookkey,currentterritorycode,contractterritorycode,
         [description],autoterritorydescind,exclusivecode,singlecountrycode,singlecountrygroupcode,updatewithsubrightsind,
         note,forsalehistory,notforsalehistory,lastuserid,lastmaintdate)
	    values
	      (@v_territoryrightskey,@v_itemtype,null,null,@v_bookkey,@v_currentterritorycode,@v_contractterritorycode,
           @v_rightsdesc,@v_autoterritorydescind,@v_exclusivecode,@v_singlecountrycode,@v_singlecountrygroupcode,@v_updatewithsubrightsind,
           @v_note,@v_forsalehistory,@v_notforsalehistory,@i_userid,getdate())
		set @v_history_ind=1
	    if @v_debug<>0 print 'updated territoryrights row'
	  end
	end

  select @v_territoryrightskey=territoryrightskey,@v_currentterritorycode=currentterritorycode from  territoryrights where bookkey=@v_bookkey
  --if @v_currentterritorycode<>3
  --  goto UpdateHistory

  -- process deletes
  if @v_debug<>0 print 'starting..'
  if @v_debug<>0 select * from imp_territory where batchkey=@i_batch and row_id=@i_row
  if @v_debug<>0 print 'process deletes'
  --if @v_debug<>0 select territoryrightskey,bookkey,countrycode from territoryrightcountries where bookkey=@v_bookkey and countrycode not in (select countrycode from imp_territory where batchkey=@i_batch and row_id=@i_row)
  if @v_debug<>0 select territoryrightskey,bookkey,countrycode 
      from territoryrightcountries trc 
      where bookkey=7518840 
        and countrycode not in (
	       select countrycode
		     from imp_territory i 
			 where batchkey=1
			   and row_id=1
			   and i.countrycode=trc.countrycode
			   and coalesce(i.forsaleind,2)=coalesce(trc.forsaleind,2)
			   and coalesce(i.contractexclusiveind,2)=coalesce(trc.contractexclusiveind,2)
			   and coalesce(i.nonexclusivesubrightsoldind,2)=coalesce(trc.nonexclusivesubrightsoldind,2)
			   and coalesce(i.currentexclusiveind,2)=coalesce(trc.currentexclusiveind,2)
			   and coalesce(i.exclusivesubrightsoldind,2)=coalesce(trc.exclusivesubrightsoldind,2)	)
  declare territory_delete cursor fast_forward for
    select territoryrightskey,bookkey,countrycode 
      from territoryrightcountries trc 
      where bookkey=7518840 
        and countrycode not in (
	       select countrycode
		     from imp_territory i 
			 where batchkey=1
			   and row_id=1
			   and i.countrycode=trc.countrycode
			   and coalesce(i.forsaleind,2)=coalesce(trc.forsaleind,2)
			   and coalesce(i.contractexclusiveind,2)=coalesce(trc.contractexclusiveind,2)
			   and coalesce(i.nonexclusivesubrightsoldind,2)=coalesce(trc.nonexclusivesubrightsoldind,2)
			   and coalesce(i.currentexclusiveind,2)=coalesce(trc.currentexclusiveind,2)
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

  -- remove existsing
  if @v_debug<>0 print 'remove non-deltas'
  if @v_debug<>0 select * from imp_territory where batchkey=@i_batch and row_id=@i_row and CountryCode in (select countrycode from territoryrightcountries where bookkey=@v_bookkey)
  delete imp_territory where batchkey=@i_batch and row_id=@i_row and CountryCode in (select countrycode from territoryrightcountries where bookkey=@v_bookkey)

  -- proces adds
  if @v_debug<>0 print 'process adds'
  if @v_debug<>0 select * from imp_territory where batchkey=@i_batch and row_id=@i_row  and countrycode not in (select countrycode from territoryrightcountries where bookkey=@v_bookkey)
  declare territory_adds cursor fast_forward for
    select batchkey,row_id,itemtype,forsaleind,contractexclusiveind,nonexclusivesubrightsoldind,currentexclusiveind,exclusivesubrightsoldind,
      CountryDesc,CountryCode,ExclusiveCode,DeleteInd 
      from imp_territory 
	  where batchkey=@i_batch and row_id=@i_row and coalesce(deleteind,0)<>1
	    and countrycode not in (select countrycode from territoryrightcountries where bookkey=@v_bookkey)
  open territory_adds
  fetch territory_adds into 
    @v_batchkey,@v_row_id,@v_itemtype_hold,@v_forsaleind,@v_contractexclusiveind,
    @v_nonexclusivesubrightsoldind,@v_currentexclusiveind,@v_exclusivesubrightsoldind,
    @v_CountryDesc,@v_CountryCode,@v_ExclusiveCode,@v_DeleteInd
  while @@fetch_status=0
    begin
  	  if @v_debug<>0 print 'add'
  	  if @v_debug<>0 print ' @v_territoryrightskey '+coalesce(cast(@v_territoryrightskey as varchar),'n/a')
  	  if @v_debug<>0 print ' @v_countrycode '+coalesce(cast(@v_countrycode as varchar),'n/a')
  	  if @v_debug<>0 print ' @v_exclusiveind '+coalesce(cast(@v_exclusiveind as varchar),'n/a')
  	  if @v_debug<>0 print ' @v_taqprojectkey '+coalesce(cast(@v_taqprojectkey as varchar),'n/a')
  	  if @v_debug<>0 print ' @v_rightskey '+coalesce(cast(@v_rightskey as varchar),'n/a')
  	  
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
  UpdateHistory:
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300014091001] to PUBLIC 
GO
