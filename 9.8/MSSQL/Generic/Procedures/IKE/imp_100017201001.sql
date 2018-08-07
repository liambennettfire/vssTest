/******************************************************************************
**  Name: imp_100017201001
**  Desc: IKE Load converted BIC/BISAC
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100017201001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100017201001]
GO

CREATE PROCEDURE dbo.imp_100017201001
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

BEGIN 
/*    START SPROC    */
DECLARE    
  @v_errcode int,  
  @v_errlevel int,         
  @v_msg varchar(500),         
  @v_type int,
  @v_code varchar(40),
  @v_final_code varchar(40),
  @v_count int,
  @v_BISAC_code_1 varchar(20),
  @v_BISAC_desc_1 varchar(255),
  @v_BISAC_code_2 varchar(20),
  @v_BISAC_desc_2 varchar(255),
  @v_BISAC_code_3 varchar(20),
  @v_BISAC_desc_3 varchar(255)
      
BEGIN  
  set @v_errlevel=1     
  set @v_msg='Load converted BIC/BISAC to standard'  
  select @v_type=originalvalue
    from imp_batch_detail 
    where batchkey=@i_batchkey       
      and Row_id=@i_row 
      and elementkey=100017201     
      and elementseq=@i_elementseq   
  select @v_code=originalvalue
    from imp_batch_detail 
    where batchkey=@i_batchkey       
      and Row_id=@i_row 
      and elementkey=100017202     
      and elementseq=@i_elementseq   

  if @v_type=12
    begin -- BIC
      exec BIC_to_BISAC_conversion
        @v_code,
        @v_final_code output,
        @v_BISAC_desc_1 output,
        @v_BISAC_code_2 output,
        @v_BISAC_desc_2 output,
        @v_BISAC_code_3 output,
        @v_BISAC_desc_3 output
    end
  else
    begin  -- BISAC
      set @v_final_code=@v_code
    end

  if @v_final_code is not null
    begin 
      insert into imp_batch_detail         
        (batchkey,row_id,elementseq,elementkey,originalvalue,lobkey,lastuserid,lastmaintdate)
        values         
        (@i_batchkey,@i_row,@i_elementseq,100017001,@v_final_code,null,@i_userid,getdate())      
    end     
    
  IF @v_errlevel >= @i_level 
    begin
      exec imp_write_feedback @i_batchkey, @i_row, 100017201, @i_elementseq, @i_rulekey, @v_msg, @v_errlevel, 1
    end
    
END

/*     END SPROC     */
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100017201001] to PUBLIC 
GO
