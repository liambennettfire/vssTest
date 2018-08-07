/******************************************************************************
**  Name: imp_300014042001
**  Desc: IKE Total run time cassettes
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_300014042001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_300014042001]
GO

CREATE PROCEDURE dbo.imp_300014042001 
  
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

/* Total run time cassettes */

BEGIN 

DECLARE @v_elementval    VARCHAR(4000),
  @v_errcode    INT,
  @v_errmsg     VARCHAR(4000),
  @v_elementdesc    VARCHAR(4000),
  @v_elementkey    BIGINT,
  @v_totalruntime     VARCHAR(40),
  @v_totalruntime_org     VARCHAR(40),
  @v_hit     INT,
  @v_volumenumber     INT,
  @v_volume     INT,
  @v_bookkey     INT,
  @v_printingkey     INT,
  @v_count      INT
  
BEGIN
  SET @v_hit = 0
  SET @v_volumenumber = 0
  SET @v_volume = 0
  SET @o_writehistoryind = 0
  SET @v_errcode = 1
  SET @v_errmsg = 'Total run time of cassettes'

  SELECT 
      @v_elementval =  LTRIM(RTRIM(originalvalue)),
      @v_elementkey = b.elementkey
    FROM imp_batch_detail b , imp_DML_elements d
    WHERE b.batchkey = @i_batch
      AND b.row_id = @i_row
      AND b.elementseq = @i_elementseq
      AND d.dmlkey = @i_dmlkey
      AND d.elementkey = b.elementkey
    SET @v_bookkey = dbo.resolve_keyset(@i_titlekeyset,1)
    SET @v_printingkey = dbo.resolve_keyset(@i_titlekeyset,2)
    set @v_totalruntime=@v_elementval
    SELECT @v_count = count(*)
      FROM audiocassettespecs
      WHERE bookkey=@v_bookkey 
        and printingkey=@v_printingkey
    if @v_count=0
      begin
        insert into audiocassettespecs
          (bookkey,printingkey,totalruntime,lastuserid,lastmaintdate)
          values
          (@v_bookkey,@v_printingkey,@v_elementval,@i_userid,getdate())
        SET @o_writehistoryind = 1
        SET @v_errmsg = 'Total run time of cassettes updated (new)'
        EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq ,@i_dmlkey,@v_errmsg,@i_level,3 
      end
    else
      begin
        select @v_totalruntime_org=totalruntime
          from audiocassettespecs
          where bookkey=@v_bookkey
            and printingkey=@v_printingkey
        if coalesce(@v_totalruntime_org,'')<>coalesce(@v_totalruntime,'')
          begin
            update audiocassettespecs
              set totalruntime=@v_totalruntime,
                lastuserid=@i_userid,
                lastmaintdate=getdate()
              where bookkey=@v_bookkey
                and printingkey=@v_printingkey
            SET @o_writehistoryind = 1
            SET @v_errmsg = 'Total run time of cassettes updated'
            EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq ,@i_dmlkey,@v_errmsg,@i_level,3 
          end
        else
          begin
            SET @v_errmsg = 'Total run time of cassettes unchanged'
            EXECUTE imp_write_feedback @i_batch,@i_row,@v_elementkey,@i_elementseq ,@i_dmlkey,@v_errmsg,@i_level,3 
          end
      end
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_300014042001] to PUBLIC 
GO
