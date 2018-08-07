SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_pl_production_data
**  Desc: IKE P&L production
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_pl_production_data]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_pl_production_data]
GO

CREATE PROCEDURE dbo.imp_pl_production_data
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
  @v_Printingnumber         Int,
  @v_Printingkey            Int,
  @v_Productiondate         Datetime,
  @v_Productionquantity     Integer,
  @v_usageclass int

BEGIN

  SELECT @v_usageclass =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027001
  SELECT @v_Productiondate =  originalvalue
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027031
  SELECT @v_Productionquantity =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027032
  SELECT @v_Printingnumber =  COALESCE(originalvalue,0)
    FROM imp_batch_detail b 
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq=@i_elementseq
      AND b.elementkey = 100027033

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
      select @v_rowcnt=count(*) 
        from taqplproduction_actual 
        where taqprojectkey=@v_taqprojectkey
          and taqprojectformatkey=@v_taqprojectformatkey
          and printingnumber=@v_Printingnumber
      select @v_printingkey=printingkey
        from printing
        where bookkey=@i_bookkey
          and printingnum=@v_printingnumber
      if @v_rowcnt=0
        begin
          insert into taqplproduction_actual
            (taqprojectkey,taqprojectformatkey,
             bookkey,printingkey,
             printingnumber,productiondate,productionqty,
             lastuserid,lastmaintdate)
            values
            (@v_taqprojectkey,@v_taqprojectformatkey,
             @i_bookkey,@v_printingkey,
             @v_printingnumber,@v_productiondate,@v_productionquantity, 
             @i_userid,getdate())
        end
      else
        begin
          update taqplproduction_actual
            set
              --printingnumber=@v_printingnumber,
              productiondate=@v_productiondate,
              productionqty=@v_productionquantity,
              lastuserid=@i_userid,
              lastmaintdate=getdate()
            where taqprojectkey=@v_taqprojectkey
              and taqprojectformatkey=@v_taqprojectformatkey
              and printingnumber=@v_Printingnumber
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

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_pl_production_data TO PUBLIC 
GO

