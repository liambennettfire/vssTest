/******************************************************************************
**  Name: imp_100022300001
**  Desc: IKE Comment mapping
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100022300001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100022300001]
GO

CREATE PROCEDURE dbo.imp_100022300001 
  
  @i_batchkey int,
  @i_row int,
--  @i_elementkey int,
  @i_elementseq int,
  @i_templatekey int,
  @i_rulekey bigint,
  @i_level int,
  @i_userid varchar(50)
AS

/* Comment mapping */

BEGIN 

DECLARE    
  @v_errcode int,  
  @v_errlevel int,         
  @v_msg varchar(500),         
  @v_texttype varchar(4000),   
  @v_textformat varchar(4000), 
  @v_text varchar(max),       
  @v_elementkey int,         
  @v_lobkey int,   
  @v_count int     
BEGIN  
  set @v_errlevel=1     
  set @v_msg='Onix Bookcomment assignment'  
  --       
  select @v_count=count(*)    
    from imp_batch_detail      
    where batchkey=@i_batchkey  
      and row_id=@i_row      
      and elementkey=100022902 
      and elementseq=@i_elementseq       
  if @v_count=1 
    begin  
      select @v_texttype=originalvalue       
        from imp_batch_detail    
        where batchkey=@i_batchkey
        and row_id=@i_row    
        and elementkey=100022902         
        and elementseq=@i_elementseq     
    end  
  select @v_count=count(*)    
    from imp_batch_detail      
    where batchkey=@i_batchkey  
      and row_id=@i_row      
      and elementkey=100022903 
      and elementseq=@i_elementseq       
  if @v_count=1 
    begin  
      select @v_textformat=originalvalue       
        from imp_batch_detail    
        where batchkey=@i_batchkey
          and row_id=@i_row    
          and elementkey=100022903         
          and elementseq=@i_elementseq     
    end  
  set @v_count=0
  select @v_count=count(*)    
    from imp_batch_detail      
    where batchkey=@i_batchkey  
      and row_id=@i_row      
      and elementkey=100022904 
      and elementseq=@i_elementseq       
  if @v_count=1 
    begin  
      select @v_text=textvalue 
        from imp_batch_detail bd, imp_batch_lobs bl  
        where bd.batchkey=@i_batchkey       
          and bd.row_id=@i_row 
          and bd.elementkey=100022904      
          and bd.elementseq=@i_elementseq   
          and bd.lobkey=bl.lobkey         
    end  
  --    
  set @v_elementkey=null
  if @v_texttype='23' and @v_textformat='02' 
    begin    
      set @v_elementkey=100022101  
    end  
  if @v_texttype='01' and @v_textformat='02'  
    begin   
      set @v_elementkey=100022209  
    end  
  if @v_texttype='04' and @v_textformat='02'  
    begin   
      set @v_elementkey=100022234  
    end  
  if @v_texttype='08' and @v_textformat='02'
    begin    
      set @v_elementkey=100022103  
    end 
  if @v_texttype='09' and @v_textformat='02'  
    begin   
      set @v_elementkey=100022241  
    end  
  if @v_texttype='13' and @v_textformat='02'  
    begin   
      set @v_elementkey=100022233  
    end  
  if @v_texttype='31' and @v_textformat='02'  
    begin   
      set @v_elementkey=100022219  
    end  

  if @v_elementkey is not null 
    begin  
      update keys set generickey=generickey+1     
      select @v_lobkey=generickey from keys      
      insert into imp_batch_detail         
        (batchkey,row_id,elementseq,elementkey,originalvalue,lobkey,lastuserid,lastmaintdate)
        values         
        (@i_batchkey,@i_row,@i_elementseq,@v_elementkey,null,@v_lobkey,@i_userid,getdate())      
      insert into imp_batch_lobs 
        (batchkey,lobkey,textvalue)        
        values         
        (@i_batchkey,@v_lobkey,@v_text) 
    end     
  else
    begin      
      set @v_errlevel=2
      set @v_msg='unassigned bookcomment' 
    end
  IF @v_errlevel >= @i_level 
    begin
      exec imp_write_feedback @i_batchkey, @i_row, @v_elementkey, @i_elementseq, @i_rulekey, @v_msg, @v_errlevel, 1
    end
END

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100022300001] to PUBLIC 
GO
