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

CREATE PROCEDURE dbo.imp_pl_sales_data
    @i_bookkey int,
    @i_batch int,
    @i_row int,
    @i_elementseq int,
    @i_dmlkey int,
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
  @v_accountingmonth datetime,
  @v_saleschannel int ,
  @v_subsaleschannel int,
  @v_saleschannelcode int ,
  @v_saleschannelsubcode int,
  @v_grosssalesunits int,
  @v_returnsalesunits  int,
  @v_compsalesunits  int,
  @v_grosssalesdollars  float,
  @v_returnsalesdollars  float,
  @v_costofgoodssold  float,
  @v_action int,
  @v_usageclass  int

BEGIN

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
  SELECT @v_accountingmonth =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027002
  SELECT @v_saleschannel =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027003
  SELECT @v_subsaleschannel =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027004
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
  SELECT @v_grosssalesdollars =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027014
  SELECT @v_returnsalesdollars =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027015
  SELECT @v_costofgoodssold =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027016
/*  -- fix later
  declare c_projecttitles cursor fast_forward for 
    select taqprojectkey,taqprojectfornatkey
      from taqprojecttitle
      where bookkey=@i_bookkey
        and usageclasscode=@v_usageclass
  open c_projecttitles
  fetch c_projecttitles into @v_taqprojectkey,@v_taqprojectformatkey
  set @v_taqprojectkey_org=@v_taqprojectkey
  set @v_exitloop=0
  while @@fetch_status=0 and @v_exitloop=0
    begin
      select @v_rowcnt=count(*) 
        from taqprojecttitle t,gentables g, subgentables s, taqplsales_actual sa
        where bookkey=@i_bookkey
          and t.taqprojectkey=sa.taqprojectkey
          and t.taqprojectformatkey=sa.taqprojectformatkey
          and taqprojectkey=@v_taqprojectkey
          and taqprojectformatkey=@v_taqprojectformatkey
          and accountingmonth=@v_accountingmonth
          and g.externalcode=@v_saleschannel
          and g.tableid=118
          and g.externalcode=@v_subsaleschannel
          and s.tableid=118
      if @v_rowcnt=0
        begin
          select @v_saleschannelcode=datacode
            from gentables
            where tableid=118
              and externalcode=@v_saleschannel 
          select @v_saleschannelsubcode=datacode
            from subgentables
            where tableid=118
              and externalcode=@v_subsaleschannel 
          insert into taqsales_actual
            (taqprojectkey,taqprojectformatkey,saleschannelcode,saleschannelsubcode,
             accountingmonth,bookkey,grosssalesunits,returnsalesunits,compsalesunits,
             grosssalesdollars,returnsalesdollars,costofgoodssold,lastuserid,lastmaintdate)
            values
            (@v_taqprojectkey,@v_taqprojectformatkey,@v_saleschannelcode,@v_saleschannelsubcode,
             @v_accountingmonth,@i_bookkey,@v_grosssalesunits,@v_returnsalesunits,@v_compsalesunits, 
             @v_grosssalesdollars,@v_returnsalesdollars,@v_costofgoodssold,@i_userid,getdate())
        end
      else
        begin
          select @v_saleschannelcode=datacode
            from gentables
            where tableid=118
              and externalcode=@v_saleschannel 
          select @v_saleschannelsubcode=datacode
            from subgentables
            where tableid=118
              and externalcode=@v_subsaleschannel
          update taqsales_actual
            set
              grosssalesunits=@v_grosssalesunits,
              returnsalesunits=@v_returnsalesunits,
              compsalesunits=@v_compsalesunits,
              grosssalesdollars=@v_grosssalesdollars,
              returnsalesdollars=@v_returnsalesdollars,
              costofgoodssold=@v_costofgoodssold,
              lastuserid=@i_userid,
              lastmaintdate=getdate()
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
*/
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_pl_sales_data TO PUBLIC 
GO

