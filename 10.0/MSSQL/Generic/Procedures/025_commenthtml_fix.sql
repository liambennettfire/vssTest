DROP  Procedure dbo.commenthtml_fix
GO

CREATE PROCEDURE dbo.commenthtml_fix
  @i_tablename varchar(50),
  @i_key int,
  @i_printingkey int,
  @i_commenttypecode int,
  @i_commenttypesubcode int
AS

BEGIN 
  DECLARE 
    @v_ptrval binary(16),
    @v_newline varchar(20),
    @v_tab varchar(20),
    @v_errcode int,
    @v_errmsg varchar(500)

 --Init variables
  set @v_newline = char(13)+char(10)
  set @v_tab = char(9)

  if @i_tablename ='BOOKCOMMENTS'
    begin
      exec bookcommenthtml_replace @i_key,@i_printingkey,@i_commenttypecode,@i_commenttypesubcode,@v_newline,'<br>'
      exec bookcommenthtml_replace @i_key,@i_printingkey,@i_commenttypecode,@i_commenttypesubcode,@v_tab,'   '
      exec bookcommenthtml_replace @i_key,@i_printingkey,@i_commenttypecode,@i_commenttypesubcode,'<','&lt;'
      exec bookcommenthtml_replace @i_key,@i_printingkey,@i_commenttypecode,@i_commenttypesubcode,'>','&gt;'
      exec bookcommenthtml_replace @i_key,@i_printingkey,@i_commenttypecode,@i_commenttypesubcode,'&','&amp;'
      -- add div tags
      SELECT @v_ptrval = TEXTPTR(commenthtml) 
        FROM bookcomments
        WHERE bookkey=@i_key
          and printingkey=@i_printingkey
          and commenttypecode=@i_commenttypecode
          and commenttypesubcode=@i_commenttypesubcode
      UPDATETEXT bookcomments.commenthtml @v_ptrval 0 0 '<div>'
      SELECT @v_ptrval = TEXTPTR(commenthtml) 
        FROM bookcomments
        WHERE bookkey=@i_key
          and printingkey=@i_printingkey
          and commenttypecode=@i_commenttypecode
          and commenttypesubcode=@i_commenttypesubcode
      UPDATETEXT bookcomments.commenthtml @v_ptrval null 0 '</div>'
    end

  if @i_tablename ='QSICOMMENTS'
    begin
      exec qsicommenthtml_replace @i_key,@i_commenttypecode,@i_commenttypesubcode,@v_newline,'<br>'
      exec qsicommenthtml_replace @i_key,@i_commenttypecode,@i_commenttypesubcode,@v_tab,'   '
      exec qsicommenthtml_replace @i_key,@i_commenttypecode,@i_commenttypesubcode,'<','&lt;'
      exec qsicommenthtml_replace @i_key,@i_commenttypecode,@i_commenttypesubcode,'>','&gt;'
      exec qsicommenthtml_replace @i_key,@i_commenttypecode,@i_commenttypesubcode,'&','&amp;'
      -- add div tags
      SELECT @v_ptrval = TEXTPTR(commenthtml) 
        FROM qsicomments
        WHERE commentkey=@i_key
          and commenttypecode=@i_commenttypecode
          and commenttypesubcode=@i_commenttypesubcode
      UPDATETEXT qsicomments.commenthtml @v_ptrval 0 0 '<div>'
      UPDATETEXT qsicomments.commenthtml @v_ptrval null 0 '</div>'
    end

  exec html_to_text_from_row @i_key,@i_printingkey,@i_commenttypecode,@i_commenttypesubcode,@i_tablename ,@v_errcode,@v_errmsg 
  exec html_to_lite_from_row @i_key,@i_printingkey,@i_commenttypecode,@i_commenttypesubcode,@i_tablename ,@v_errcode,@v_errmsg 

                        
end
GO
GRANT EXEC ON commenthtml_fix TO PUBLIC
GO

