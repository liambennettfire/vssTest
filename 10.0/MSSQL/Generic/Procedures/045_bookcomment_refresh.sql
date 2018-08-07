drop procedure dbo.bookcomment_refresh
GO
CREATE PROCEDURE dbo.bookcomment_refresh
  @i_upd_text int,
  @i_upd_htmllite int
as
begin
  declare
    @v_bookkey int,
    @v_printingkey int,
    @v_commenttypecode int,
    @v_commenttypesubcode int,
    @v_errcode int,
    @v_errmsg varchar(2000)
  declare c_comments cursor for
    select bookkey,printingkey,commenttypecode,commenttypesubcode 
      from bookcomments
  OPEN c_comments
  FETCH c_comments INTO @v_bookkey,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode
  while (@@FETCH_STATUS = 0) 
    begin 
      begin transaction
      if @i_upd_text = 1
        begin
          exec html_to_text_from_row @v_bookkey,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,'BOOKCOMMENTS',@v_errcode,@v_errmsg 
        end
      if @i_upd_htmllite = 1
        begin
          exec html_to_lite_from_row @v_bookkey,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,'BOOKCOMMENTS',@v_errcode,@v_errmsg 
        end
      commit
      FETCH c_comments INTO @v_bookkey,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode
    end
  CLOSE c_comments
  DEALLOCATE c_comments
END
go
