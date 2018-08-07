SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_pl_sales_data
**  Desc: IKE P&L sales
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_pl_sales_data]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_pl_sales_data]
GO



CREATE PROCEDURE [dbo].[imp_pl_sales_data]
    @i_bookkey int,
    @i_batch int,
    @i_row int,
    @i_elementseq int,
    @i_dmlkey bigint,
    @i_userid varchar(50),
    @o_errcode int output,
    @o_errmsg varchar(500) output
AS
DECLARE
  @v_taqprojectkey int,
  @v_taqprojectkey_org int,
  @v_taqprojectformatkey int,
  @v_exitloop int,
  @v_errcode int,
  @v_errmsg varchar(500),
  @v_rowcnt int,
  @v_accountingmonthtext varchar(50),
  @v_accountingmonth datetime,
  @v_saleschannel VARCHAR(5),
  @v_subsaleschannel VARCHAR(5),
  @v_saleschannelcode int ,
  @v_saleschannelsubcode int,
  @v_grosssalesunits int,
  @v_returnsalesunits  int,
  @v_compsalesunits  int,
  @v_grosssalesdollars  float,
  @v_returnsalesdollars  float,
  @v_costofgoodssold  float,
  @v_action int,
  @v_usageclass  int,
  @v_grosssalesunits_org int,
  @v_returnsalesunits_org int,
  @v_compsalesunits_org int,
  @v_grosssalesdollars_org float,
  @v_returnsalesdollars_org float,
  @v_costofgoodssold_org float

BEGIN
--print 'START:imp_pl_sales_data'
  SELECT @v_action =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027000
  SELECT @v_usageclass =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027001
  SELECT @v_accountingmonthtext =  originalvalue
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027002
  if datalength(@v_accountingmonthtext)=6
    begin
      set @v_accountingmonthtext = substring(@v_accountingmonthtext,1,2)+'/01/'+substring(@v_accountingmonthtext,3,4)
      set @v_accountingmonth = @v_accountingmonthtext
    end
  
  else
    
	begin
      set @v_accountingmonth = @v_accountingmonthtext
    end

  SELECT @v_saleschannel =  COALESCE(originalvalue,'000')
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027003
  SELECT @v_subsaleschannel =  COALESCE(originalvalue,'000')
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027004
	  --print 'PRE::@v_saleschannel='+@v_saleschannel
	  --print 'PRE::@v_subsaleschannel='+@v_subsaleschannel
	set @v_saleschannel=replace(@v_saleschannel,'''','')
	set @v_subsaleschannel=replace(@v_saleschannel,'''','')
	  --print 'POST::@v_saleschannel='+@v_saleschannel
	  --print 'POST::@v_subsaleschannel='+@v_subsaleschannel

  SELECT @v_grosssalesunits =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027011
  SELECT @v_returnsalesunits =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027012
  SELECT @v_compsalesunits =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027013
  SELECT @v_grosssalesdollars =  COALESCE(cast(originalvalue as float),0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027014

  SELECT @v_returnsalesdollars =  COALESCE(cast(originalvalue as float),0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027015
  SELECT @v_costofgoodssold =  COALESCE(cast(originalvalue as float),0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027016
    
  declare c_projecttitles cursor fast_forward for 
    select taqprojectkey,taqprojectformatkey
      from taqprojecttitle
      where bookkey=@i_bookkey
--    select taqprojectkey,taqprojectfornatkey
--      from taqprojecttitle
--      where bookkey=@i_bookkey
--        and usageclasscode=@v_usageclass
  open c_projecttitles
  fetch c_projecttitles into @v_taqprojectkey,@v_taqprojectformatkey
  set @v_taqprojectkey_org=@v_taqprojectkey
  set @v_exitloop=0
  while @@fetch_status=0 and @v_exitloop=0
    begin
	--print 'Cursor::@i_bookkey='+cast(@i_bookkey as varchar(max))
--      select @v_rowcnt=count(*) 
--        from taqprojecttitle t,gentables g, subgentables s, taqplsales_actual sa
--        where t.bookkey=@i_bookkey
--          and t.taqprojectkey=sa.taqprojectkey
--          and t.taqprojectformatkey=sa.taqprojectformatkey
--          and t.taqprojectkey=@v_taqprojectkey
--          and t.taqprojectformatkey=@v_taqprojectformatkey
--          and accountingmonth=@v_accountingmonth
--          and g.externalcode=@v_saleschannel
--          and g.tableid=118
--          and g.externalcode=@v_subsaleschannel
--          and s.tableid=118
      select @v_saleschannelcode=datacode
        from gentables
        where tableid=118
          and externalcode=@v_saleschannel 

      select @v_saleschannelsubcode=datacode
        from subgentables
        where tableid=118
          and externalcode=@v_subsaleschannel 

      if @v_saleschannelsubcode is null
        set @v_saleschannelsubcode=0



--if @v_taqprojectkey is null or
--@v_taqprojectformatkey is null or
--@v_saleschannelcode is null or
--@v_saleschannelsubcode is null or
--@v_accountingmonth is null 
--  begin
--  print 'null key values'
--  print @v_taqprojectkey
--  print @v_taqprojectformatkey
--  print @v_saleschannelcode
--  print @v_saleschannelsubcode
--  print @v_accountingmonth
--  end

      select @v_rowcnt=count(*) 
        from taqplsales_actual 
        where taqprojectkey=@v_taqprojectkey
          and taqprojectformatkey=@v_taqprojectformatkey
          and saleschannelcode=@v_saleschannelcode
          and saleschannelsubcode=@v_saleschannelsubcode
          and accountingmonth=@v_accountingmonth
--print 'row count '+cast(@v_rowcnt as varchar)
      
	  if @v_rowcnt=0
        begin
          if @v_saleschannelcode is not null
            begin
			/*
			print 'do insert'
			print '*************************************'
			print '@v_taqprojectkey='+coalesce(cast(@v_taqprojectkey as varchar(max)),'*NULL*')
			print '@v_taqprojectkey_org='+coalesce(cast(@v_taqprojectkey_org as varchar(max)),'*NULL*')
			print '@v_taqprojectformatkey='+coalesce(cast(@v_taqprojectformatkey as varchar(max)),'*NULL*')
			print '@v_exitloop='+coalesce(cast(@v_exitloop as varchar(max)),'*NULL*')
			print '@v_errcode='+coalesce(cast(@v_errcode as varchar(max)),'*NULL*')
			print '@v_errmsg='+coalesce(cast(@v_errmsg as varchar(max)),'*NULL*')
			print '@v_rowcnt='+coalesce(cast(@v_rowcnt as varchar(max)),'*NULL*')
			print '@v_accountingmonthtext='+coalesce(cast(@v_accountingmonthtext as varchar(max)),'*NULL*')
			print '@v_accountingmonth='+coalesce(cast(@v_accountingmonth as varchar(max)),'*NULL*')
			print '@v_saleschannel='+coalesce(cast(@v_saleschannel as varchar(max)),'*NULL*')
			print '@v_subsaleschannel='+coalesce(cast(@v_subsaleschannel as varchar(max)),'*NULL*')
			print '@v_saleschannelcode ='+coalesce(cast(@v_saleschannelcode  as varchar(max)),'*NULL*')
			print '@v_saleschannelsubcode='+coalesce(cast(@v_saleschannelsubcode as varchar(max)),'*NULL*')
			print '@v_grosssalesunits='+coalesce(cast(@v_grosssalesunits as varchar(max)),'*NULL*')
			print '@v_returnsalesunits ='+coalesce(cast(@v_returnsalesunits  as varchar(max)),'*NULL*')
			print '@v_compsalesunits ='+coalesce(cast(@v_compsalesunits  as varchar(max)),'*NULL*')
			print '@v_grosssalesdollars ='+coalesce(cast(@v_grosssalesdollars  as varchar(max)),'*NULL*')
			print '@v_returnsalesdollars ='+coalesce(cast(@v_returnsalesdollars  as varchar(max)),'*NULL*')
			print '@v_costofgoodssold ='+coalesce(cast(@v_costofgoodssold  as varchar(max)),'*NULL*')
			print '@v_action='+coalesce(cast(@v_action as varchar(max)),'*NULL*')
			print '@v_usageclass ='+coalesce(cast(@v_usageclass  as varchar(max)),'*NULL*')
			print '@v_grosssalesunits_org='+coalesce(cast(@v_grosssalesunits_org as varchar(max)),'*NULL*')
			print '@v_returnsalesunits_org='+coalesce(cast(@v_returnsalesunits_org as varchar(max)),'*NULL*')
			print '@v_compsalesunits_org='+coalesce(cast(@v_compsalesunits_org as varchar(max)),'*NULL*')
			print '@v_grosssalesdollars_org='+coalesce(cast(@v_grosssalesdollars_org as varchar(max)),'*NULL*')
			print '@v_returnsalesdollars_org='+coalesce(cast(@v_returnsalesdollars_org as varchar(max)),'*NULL*')
			print '@v_costofgoodssold_org='+coalesce(cast(@v_costofgoodssold_org as varchar(max)),'*NULL*')
			print '*************************************'
			*/

              insert into taqplsales_actual
                (taqprojectkey,taqprojectformatkey,saleschannelcode,saleschannelsubcode,
                 accountingmonth,bookkey,grosssalesunits,returnsalesunits,compsalesunits,
                 grosssalesdollars,Returnsalesdollars,costofgoodssold,lastuserid,lastmaintdate)
              values
                (@v_taqprojectkey,@v_taqprojectformatkey,@v_saleschannelcode,@v_saleschannelsubcode,
                 @v_accountingmonth,@i_bookkey,@v_grosssalesunits,@v_returnsalesunits,@v_compsalesunits, 
                 @v_grosssalesdollars,@v_returnsalesdollars,@v_costofgoodssold,@i_userid,getdate())
            end
			--print 'done insert'
        end
      else

        begin
          if @v_action=1
            begin
              select 
                @v_grosssalesunits_org=coalesce(grosssalesunits,0),
                @v_returnsalesunits_org=coalesce(returnsalesunits,0),
                @v_compsalesunits_org=coalesce(compsalesunits,0),
                @v_grosssalesdollars_org=coalesce(grosssalesdollars,0),
                @v_returnsalesdollars_org=coalesce(returnsalesdollars,0)
                from taqplsales_actual
                where taqprojectkey=@v_taqprojectkey
                  and taqprojectformatkey=@v_taqprojectformatkey
                  and saleschannelcode=@v_saleschannelcode
                  and saleschannelsubcode=@v_saleschannelsubcode
                  and accountingmonth=@v_accountingmonth
              set @v_grosssalesunits=@v_grosssalesunits+@v_grosssalesunits_org
              set @v_returnsalesunits=@v_returnsalesunits+@v_returnsalesunits_org
              set @v_compsalesunits=@v_compsalesunits+@v_compsalesunits_org
              set @v_grosssalesdollars=@v_grosssalesdollars+@v_grosssalesdollars_org
              set @v_returnsalesdollars=@v_returnsalesdollars+@v_returnsalesdollars_org

--print @v_grosssalesunits_org
--print @v_returnsalesunits_org
--print @v_compsalesunits_org
--print @v_grosssalesdollars_org
--print @v_returnsalesdollars_org
--print 'appending'

            end

--print 'update'

          update taqplsales_actual
            set
              grosssalesunits=@v_grosssalesunits,
              returnsalesunits=@v_returnsalesunits,
              compsalesunits=@v_compsalesunits,
              grosssalesdollars=@v_grosssalesdollars,
              returnsalesdollars=@v_returnsalesdollars,
              costofgoodssold=@v_costofgoodssold,
              lastuserid=@i_userid,
              lastmaintdate=getdate()

            where taqprojectkey=@v_taqprojectkey
              and taqprojectformatkey=@v_taqprojectformatkey
              and saleschannelcode=@v_saleschannelcode
              and saleschannelsubcode=@v_saleschannelsubcode
              and accountingmonth=@v_accountingmonth
        end

      fetch c_projecttitles into @v_taqprojectkey,@v_taqprojectformatkey
      if @v_taqprojectkey=@v_taqprojectkey_org and @@fetch_status=0
        begin
          set @v_exitloop=1
        end

      if @v_taqprojectkey<>@v_taqprojectkey_org and @@fetch_status=0
        begin
          set @v_errcode=2
          set @v_errmsg='Processing multiple projects for bookkey '+cast(@i_bookkey as varchar)
          exec imp_write_feedback @i_batch,@i_row,null,@i_elementseq ,@i_dmlkey,@v_errmsg,1,2

        end

    end

  close c_projecttitles
  deallocate c_projecttitles

  --print 'END:imp_pl_sales_data'
  
END

GO

GRANT EXECUTE ON dbo.imp_pl_sales_data TO PUBLIC 
GO

