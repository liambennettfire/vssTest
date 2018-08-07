/******************************************************************************
**  Name: imp_100022915001
**  Desc: IKE Onix Bookcomment datacode assignment
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_100022915001]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_100022915001]
GO

CREATE PROCEDURE dbo.imp_100022915001
  
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
  @v_texttype varchar(4000),   
  @v_textformat varchar(4000), 
  @v_text varchar(max),       
  @v_onixsubcode int,
  @v_elementmnemonic varchar(50),         
  @v_commenttypecode int,         
  @v_commenttypesubcode int,         
  @v_lobkey int,   
  @v_count int     
BEGIN  
  set @v_errlevel=1     
  set @v_msg='Onix Bookcomment datacode assignment'  

  select @v_onixsubcode=originalvalue
    from imp_batch_detail 
    where batchkey=@i_batchkey       
      and Row_id=@i_row 
      and elementkey=100022915      
      and elementseq=@i_elementseq   

  select 
      @v_commenttypecode=sg.datacode,
      @v_commenttypesubcode=sg.datasubcode
    from subgentables sg, subgentables_ext sgx
      where sg.tableid=284
        and onixsubcode=@v_onixsubcode
        and sg.tableid=sgx.tableid
        and sg.datacode=sgx.datacode
        and sg.datasubcode=sgx.datasubcode
        
  if @v_commenttypecode is not null and @v_commenttypesubcode is not null
    begin 
      set @v_texttype=cast(@v_commenttypecode as varchar)+','+cast(@v_commenttypesubcode as varchar)
      insert into imp_batch_detail         
        (batchkey,row_id,elementseq,elementkey,originalvalue,lobkey,lastuserid,lastmaintdate)
        values         
        (@i_batchkey,@i_row,@i_elementseq,100022911,@v_texttype,null,@i_userid,getdate())      
    end     
  else
    begin      
      set @v_errlevel=2
      set @v_msg='unassigned bookcomment' 
    end
    
  IF @v_errlevel >= @i_level 
    begin
      exec imp_write_feedback @i_batchkey, @i_row, 100022915, @i_elementseq, @i_rulekey, @v_msg, @v_errlevel, 1
    end
    
END

/*     END SPROC     */
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.[imp_100022915001] to PUBLIC 
GO
