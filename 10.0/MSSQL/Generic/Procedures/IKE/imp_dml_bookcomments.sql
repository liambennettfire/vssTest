SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_dml_bookcomments
**  Desc: IKE bookcomment update routine
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_dml_bookcomments]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_dml_bookcomments]
GO

CREATE PROCEDURE dbo.imp_dml_bookcomments 
  @i_batch int,
  @i_row int,
  @i_dmlkey bigint,
  @i_elementseq int,
  @v_errcode int output ,
  @v_errmsg varchar(200) output
AS

BEGIN 
  DECLARE 
    @v_scr_ptr binary(16),
    @v_dst_ptr binary(16),
    @v_count int,
    @v_bookkey int,
    @v_printingkey int,
    @v_commenttypecode int,
    @v_commenttypesubcode int,
    @v_lobkey int,
    @v_elementkey bigint,
    @v_elementval varchar(8000)

-- get keys
   set @v_printingkey =1
   select @v_elementkey = d.elementkey
     from imp_element_defs e, imp_dml_elements d
     where d.dmlkey = @i_dmlkey
       and d.elementkey = e.elementkey
       and e.tableid = 284
   select @v_commenttypecode = datacode, @v_commenttypesubcode = datasubcode
     from imp_element_defs
     where elementkey = @v_elementkey
   select @v_lobkey = lobkey
     from imp_batch_detail
     where batchkey = @i_batch
       and row_id = @i_row
       and elementkey = @v_elementkey
       and elementseq = @i_elementseq
  declare element_cur cursor FAST_FORWARD for 
    select distinct elementkey
      from imp_dml_elements
      where dmlkey = @i_dmlkey
  open element_cur 
  fetch element_cur into @v_elementkey
  while @@fetch_status = 0 and @v_bookkey is null
    begin
      select @v_elementval = originalvalue
        from imp_batch_detail
        where batchkey = @i_batch
          and row_id = @i_row
          and elementseq = @i_elementseq
          and elementkey = @v_elementkey
      exec imp_tool_getbookkey @v_elementkey, @v_elementval, @v_bookkey output,@v_errcode output, @v_errmsg output
      fetch element_cur into @v_elementkey
    end
  close element_cur
  deallocate element_cur

  if @v_bookkey is not null -- check all keys for null
    begin
      select @v_count = count(*)
        from bookcomments
        where bookkey = @v_bookkey
          AND printingkey = @v_printingkey
          AND commenttypecode = @v_commenttypecode
          AND commenttypesubcode = @v_commenttypesubcode  
      if @v_count = 0
        begin
          insert into bookcomments
            (bookkey,printingkey,commenttypecode,commenttypesubcode,commenttext,commenthtml,commenthtmllite,lastuserid,lastmaintdate)
            values
            ( @v_bookkey,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,'ins','ins','ins','IKE import',getdate())
        end
      else
        begin
          update bookcomments
            set commenttext = 'upd',commenthtml='upd',commenthtmllite='upd'
            where bookkey = @v_bookkey
              AND printingkey = @v_printingkey
              AND commenttypecode = @v_commenttypecode
              AND commenttypesubcode = @v_commenttypesubcode  
        end
      SELECT @v_scr_ptr = TEXTPTR(textvalue) 
        FROM imp_batch_lobs
        where lobkey = @v_lobkey
      SELECT @v_dst_ptr = TEXTPTR(commenthtml) 
        FROM bookcomments
        where bookkey = @v_bookkey
          AND printingkey = @v_printingkey
          AND commenttypecode = @v_commenttypecode
          AND commenttypesubcode = @v_commenttypesubcode  
      updatetext bookcomments.commenthtml @v_dst_ptr 0 null  imp_batch_lobs.textvalue @v_scr_ptr
      exec html_to_lite_from_row @v_bookkey,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,'BOOKCOMMENTS',@v_errcode,@v_errmsg 
      exec html_to_text_from_row @v_bookkey,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,'BOOKCOMMENTS',@v_errcode,@v_errmsg 
    end
          
end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_dml_bookcomments  TO PUBLIC 
GO


