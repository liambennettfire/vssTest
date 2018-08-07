SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/******************************************************************************
**  Name: imp_dml_lob_comments
**  Desc: IKE load expliicit xml routine
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[imp_dml_lob_comments]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[imp_dml_lob_comments]
GO

CREATE PROCEDURE dbo.imp_dml_lob_comments 
  @i_batch int,
  @i_row int,
  @i_elementkey bigint,
  @i_elementseq int,
  @i_keyset varchar(500),
  @i_userid varchar(50),
  @v_errcode int output ,
  @v_errmsg varchar(500) output
AS

BEGIN 
  DECLARE 
    @v_scr_ptr binary(16),
    @v_dst_ptr binary(16),
    @v_count int,
    @v_key int,
    @v_printingkey int,
    @v_commenttypecode int,
    @v_commenttypesubcode int,
    @v_lobkey int,
    @v_tablename varchar(50)

-- get keys
  set @v_key = dbo.resolve_keyset(@i_keyset,1)
  set @v_printingkey = dbo.resolve_keyset(@i_keyset,2)
  select @v_commenttypecode = datacode, @v_commenttypesubcode = datasubcode, @v_tablename = destinationtable
    from imp_element_defs
    where elementkey = @i_elementkey
  select @v_lobkey = lobkey
    from imp_batch_detail
    where batchkey = @i_batch
      and row_id = @i_row
      and elementkey = @i_elementkey
      and elementseq = @i_elementseq
  select @v_scr_ptr = textptr(textvalue)
    from imp_batch_lobs
    where lobkey=@v_lobkey 
  if @v_tablename = 'bookcomments'
    begin
      select @v_count = count(*)
        from bookcomments
        where bookkey = @v_key
          and printingkey = @v_printingkey
          and commenttypecode = @v_commenttypecode
          and commenttypesubcode = @v_commenttypesubcode
      if @v_count = 0
        begin
          insert into bookcomments
            (bookkey,printingkey,commenttypecode,commenttypesubcode,commenttext,commenthtml,commenthtmllite)
            values
            (@v_key,@v_printingkey,@v_commenttypecode,@V_commenttypesubcode,'x','x','x')
        end
      select @v_dst_ptr = textptr(commenthtml)
        from bookcomments
        where bookkey = @v_key
          and printingkey = @v_printingkey
          and commenttypecode = @v_commenttypecode
          and commenttypesubcode = @v_commenttypesubcode
      updatetext bookcomments.commenthtml @v_dst_ptr 0 null  imp_batch_lobs.textvalue @v_scr_ptr
      update bookcomments
        set lastuserid = @i_userid , lastmaintdate = getdate()
        where bookkey = @v_key
          and printingkey = @v_printingkey
          and commenttypecode = @v_commenttypecode
          and commenttypesubcode = @v_commenttypesubcode
      -- update history
    end
  if @v_tablename = 'qsicomments'
    begin
      select @v_count = count(*)
        from qsicomments
        where commentkey = @v_key
          and commenttypecode = @v_commenttypecode
          and commenttypesubcode = @v_commenttypesubcode
      if @v_count = 0
        begin
          insert into qsicomments
            (commentkey,commenttypecode,commenttypesubcode,parenttable,commenttext,commenthtml,commenthtmllite)
            values
            (@v_key,@v_commenttypecode,@v_commenttypesubcode,@v_tablename,'x','x','x')
        end
      select @v_dst_ptr = textptr(commenthtml)
        from qicomments
        where commentkey = @v_key
          and commenttypecode = @v_commenttypecode
          and commenttypesubcode = @v_commenttypesubcode
      updatetext qsicomments.commenthtml @v_dst_ptr 0 null  imp_batch_lobs.textvalue @v_scr_ptr
      update qsicomments
        set lastuserid = @i_userid , lastmaintdate = getdate()
        where commentkey = @v_key
          and commenttypecode = @v_commenttypecode
          and commenttypesubcode = @v_commenttypesubcode
      -- update history
    end

  exec html_to_lite_from_row @v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,@v_tablename,@v_errcode,@v_errmsg 
  exec html_to_text_from_row @v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,@v_tablename,@v_errcode,@v_errmsg 
          
end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.imp_dml_lob_comments TO PUBLIC 
GO



