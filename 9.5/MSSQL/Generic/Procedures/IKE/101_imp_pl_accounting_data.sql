SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


/******************************************************************************
**  Name: imp_pl_accounting_data
**  Desc: IKE P&L 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_pl_accounting_data]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_pl_accounting_data]
GO

CREATE PROCEDURE dbo.imp_pl_accounting_data
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
  @v_accountingcode int,
  @v_amount  float,
  @v_process varchar(50),
  @v_action int,
  @v_placctgcategorycode int,
  @v_gen1ind int,
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
  SELECT @v_amount =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027021
  SELECT @v_accountingcode =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027022


/*  - fix later
  select @v_placctgcategorycode=placctgcategorycode
    from cdlist cd , taqplacctgactuals_import taq
    where cd.externalcode=taq.accountingcode
  select @v_gen1ind
    from gentables 
    where tableid=571
      and datacode=@v_placctgcategorycode
  if @v_gen1ind=1
    set @v_process='income'
  else
    set @v_process='expense'
    
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
      if @v_process='income'
        begin
          select @v_rowcnt=count(*) 
            from taqprojecttitle t,taqplincome_actual i, cdlist cd
            where bookkey=@i_bookkey
              and taqprojectkey=@v_taqprojectkey
              and taqprojectformatkey=@v_taqprojectformatkey
              and accountingmonth=@v_accountingmonth
              and i.acctgcode=cd.internalcode
          if @v_rowcnt=0
            begin
              insert into taqplincome_actual
                (taqprojectkey,taqprojectformatkey,
                 accountingmonth,bookkey,
                 accntgcode,amount,
                 lastuserid,lastmaintdate)
                values
                (@v_taqprojectkey,@v_taqprojectformatkey,
                 @v_accountingmonth,@i_bookkey,
                 @v_accountingcode,@v_amount,
                 @i_userid,getdate())
            end
          else
            begin
              update taqplincome_actual
                set
                  amount=@v_amount,
                  lastuserid=@i_userid,
                  lastmaintdate=getdate()
                where taqprojectkey=@v_taqprojectkey
                  and taqprojectformatkey=@v_taqprojectformatkey
                  and accountingmonth=@v_accountingmonth
                  and bookkey=@i_bookkey
            end
        end
      if @v_process='expense'
        begin
          select @v_rowcnt=count(*) 
            from taqprojecttitle t,taqplcosts_actual i, cdlist cd
            where bookkey=@i_bookkey
              and taqprojectkey=@v_taqprojectkey
              and taqprojectformatkey=@v_taqprojectformatkey
              and accountingmonth=@v_accountingmonth
              and i.accountingcode=cd.internalcode
          if @v_rowcnt=0
            begin
              insert into taqplincome_actual
                (taqprojectkey,taqprojectformatkey,
                 accountingmonth,bookkey,
                 acctgcode,amount,
                 lastuserid,lastmaintdate)
                values
                (@v_taqprojectkey,@v_taqprojectformatkey,
                 @v_accountingmonth,@i_bookkey,
                 @v_accountingcode,@v_amount,
                 @i_userid,getdate())
            end
          else
            begin
              update taqplincome_actual
                set
                  amount=@v_amount,
                  lastuserid=@i_userid,
                  lastmaintdate=getdate()
                where taqprojectkey=@v_taqprojectkey
                  and taqprojectformatkey=@v_taqprojectformatkey
                  and accountingmonth=@v_accountingmonth
                  and bookkey=@i_bookkey
            end
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

GRANT EXECUTE ON dbo.imp_pl_accounting_data TO PUBLIC 
GO

