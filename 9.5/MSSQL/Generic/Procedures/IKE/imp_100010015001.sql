/******************************************************************************
**  Name: imp_100010015001
**  Desc: IKE Product Number from ProductID Types and Value
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100010015001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100010015001]
GO

CREATE PROCEDURE dbo.imp_100010015001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Product Number from ProductID Types and Value */

BEGIN 

DECLARE  
  @v_errcode int,
  @v_new_value varchar(4000),
  @v_errlevel int,
  @v_msg varchar(500),
  @v_productId_type varchar(4000),
  @v_productId_value varchar(4000),
  @v_elementkey bigint,
  @v_count int
BEGIN
  set @v_errlevel=1
  set @v_msg='product number resolved'

  select @v_count=count(*)
    from imp_batch_detail
    where batchkey=@i_batchkey
      and row_id=@i_row
      and elementkey=100010014
      and elementseq=@i_elementseq
  if @v_count=1 
    begin
      select @v_productId_type=originalvalue
        from imp_batch_detail
        where batchkey=@i_batchkey
          and row_id=@i_row
          and elementkey=100010014
          and elementseq=@i_elementseq
    end
  else
    begin
      set @v_msg ='missing id '+cast(@i_batchkey as varchar)+','+cast(@i_row as varchar)+',100010008,'+cast(@i_elementseq as varchar)
      exec imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey, @v_msg , @v_errlevel, 1
    end
  select @v_count=count(*)
    from imp_batch_detail
    where batchkey=@i_batchkey  
      and row_id=@i_row  
      and elementseq=@i_elementseq  
      and elementkey=100010015 
  if @v_count=1 
    begin
      select @v_productId_value=originalvalue
        from imp_batch_detail
        where batchkey=@i_batchkey  
          and row_id=@i_row  
          and elementseq=@i_elementseq  
          and elementkey=100010015 
    end
  else
    begin
      set @v_msg ='missing val '+cast(@i_batchkey as varchar)+','+cast(@i_row as varchar)+',100010009,'+cast(@i_elementseq as varchar)
      exec imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey, @v_msg , @v_errlevel, 1
    end

  select @v_elementkey =
    CASE 
      WHEN @v_productId_type='02' THEN  100010001
      WHEN @v_productId_type='03' THEN  100010003
      WHEN @v_productId_type='04' THEN  100010004
--      WHEN @v_productId_type='05' THEN  10001000x  --ISMN
--      WHEN @v_productId_type='06' THEN  10001000x  --DOI
--      WHEN @v_productId_type='13' THEN  100010003  -- Library of Congress num
      WHEN @v_productId_type='14' THEN  100010005
      WHEN @v_productId_type='15' THEN  100010003
    end
  if @v_elementkey is null
    begin
      set @v_errlevel=2
      set @v_msg='Can not identify the ProductIDType '+@v_productId_type
    end

  if @v_errlevel=1 
    begin
      delete from imp_batch_detail
        where batchkey=@i_batchkey  
          and row_id=@i_row  
          and elementseq=@i_elementseq  
          and elementkey=100010014 
      delete from imp_batch_detail
        where batchkey=@i_batchkey  
          and row_id=@i_row  
          and elementseq=@i_elementseq  
          and elementkey=100010015
      insert into imp_batch_detail
        (batchkey,row_id,elementseq,elementkey,originalvalue,lastuserid,lastmaintdate)
        values
        (@i_batchkey,@i_row,@i_elementseq,@v_elementkey ,@v_productId_value,@i_userid,getdate()) 
    end

END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100010015001] to PUBLIC 
GO
