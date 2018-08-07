if exists (select * from dbo.sysobjects where id = Object_id('dbo.comment_refresh') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.comment_refresh 
end
GO
CREATE PROCEDURE dbo.comment_refresh
  @i_upd_text int,
  @i_upd_htmllite int,
  @v_table_name varchar(50)
as
begin
  declare
    @v_key int,
    @v_printingkey int,
    @v_commenttypecode int,
    @v_commenttypesubcode int,
    @v_errcode int,
    @v_errmsg varchar(2000),
    @v_dynamic_cur varchar(2000)


IF Upper(@v_table_name) = 'BOOKCOMMENTS' BEGIN
     --clean orphan rows
     delete bookcomments where commenthtml is null
	set @v_dynamic_cur = '
	DECLARE c_comments CURSOR FOR
	select bookkey,printingkey,commenttypecode,commenttypesubcode 
        from bookcomments'
END
IF Upper(@v_table_name) = 'QSICOMMENTS' BEGIN
    --clean orphan rows
    delete qsicomments where commenthtml is null
	SET @v_dynamic_cur = '
	DECLARE c_comments CURSOR FOR
	select commentkey, 0, commenttypecode, commenttypesubcode 
	from qsicomments '
END


EXEC (@v_dynamic_cur)

  OPEN c_comments
  FETCH c_comments INTO @v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode
  while (@@FETCH_STATUS = 0) 
    begin 
      begin transaction
      if @i_upd_text = 1
        begin
          exec html_to_text_from_row_new @v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,@v_table_name,@v_errcode,@v_errmsg 
        end
      if @i_upd_htmllite = 1
        begin
          exec html_to_lite_from_row_new @v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,@v_table_name,0,@v_errcode,@v_errmsg 
        end
      commit
      FETCH c_comments INTO @v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode
    end
  CLOSE c_comments
  DEALLOCATE c_comments
END
go

GRANT EXEC ON dbo.comment_refresh TO PUBLIC
GO

