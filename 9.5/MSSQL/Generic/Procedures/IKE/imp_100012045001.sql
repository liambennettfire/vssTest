/******************************************************************************
**  Name: imp_100012045001
**  Desc: IKE ONIX Measurement translation
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100012045001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100012045001]
GO

CREATE PROCEDURE dbo.imp_100012045001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* ONIX Measurement translation */

BEGIN 

DECLARE  
  @v_errcode int,
  @v_new_value varchar(4000),
  @v_errlevel int,
  @v_msg varchar(500),
  @v_measure_type varchar(4000),
  @v_measure_value varchar(4000),
  @v_elementkey int,
  @v_count int
BEGIN
  set @v_errlevel=1
  set @v_msg='measurement data resolved'
  --
  select @v_count=count(*)
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100012045
      and elementseq=@i_elementseq
  if @v_count=1 
    begin
      select @v_measure_type=originalvalue
        from imp_batch_detail
        where batchkey=@i_batchkey
          and row_id=@i_row
          and elementkey=100012045
          and elementseq=@i_elementseq
    end
  else
    begin
      set @v_msg ='missing type '+cast(@i_batchkey as varchar)+','+cast(@i_row as varchar)+',100010008,'+cast(@i_elementseq as varchar)
      exec imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey, @v_msg , @v_errlevel, 1
    end
  select @v_count=count(*)
    from imp_batch_detail
    where batchkey=@i_batchkey  
      and row_id=@i_row  
      and elementseq=@i_elementseq  
      and elementkey=100012046 
  if @v_count=1 
    begin
      select @v_measure_value=originalvalue
        from imp_batch_detail
        where batchkey=@i_batchkey  
          and row_id=@i_row  
          and elementseq=@i_elementseq  
          and elementkey=100012046 
    end
  else
    begin
      set @v_msg ='missing value '+cast(@i_batchkey as varchar)+','+cast(@i_row as varchar)+',100010009,'+cast(@i_elementseq as varchar)
      exec imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey, @v_msg , @v_errlevel, 1
    end

  select @v_elementkey=
    CASE 
      WHEN @v_measure_type='01' THEN 100012049
      WHEN @v_measure_type='02' THEN 100012048
      WHEN @v_measure_type='03' THEN 100012025
      WHEN @v_measure_type='04' THEN 100012049
      WHEN @v_measure_type='05' THEN 100012048
      WHEN @v_measure_type='08' THEN 100012062  
--    WHEN @v_measure_type='09' THEN 1000xxxxx  -- globe dia.
      else null
    END 
  if @v_elementkey is null and @v_measure_type is not null
    begin
      set @v_errlevel=2
      set @v_msg='Can not identify the Mearurement Type '+coalesce(@v_measure_type,'n/a') 
    end

  if @v_errlevel=1 and @v_elementkey is not null 
    begin
      delete from imp_batch_detail
        where batchkey=@i_batchkey  
          and row_id=@i_row  
          and elementseq=@i_elementseq  
          and elementkey=110001206 
      delete from imp_batch_detail
        where batchkey=@i_batchkey  
          and row_id=@i_row  
          and elementseq=@i_elementseq  
          and elementkey=100012066
      insert into imp_batch_detail
        (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
        values
        (@i_batchkey,@i_row,@i_elementseq,@v_elementkey ,@v_measure_value ,@i_userid,getdate()) 
    end
  --
  IF @v_errlevel >= @i_level 
    begin
      exec imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey, @v_msg, @v_errlevel, 1
    end
  --
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100012045001] to PUBLIC 
GO
