if exists (select * from dbo.sysobjects where id = Object_id('dbo.commenthtml_fix_all') and (type = 'P' or type = 'RF'))
  begin
    drop proc dbo.commenthtml_fix_all 
  end

GO

CREATE  proc dbo.commenthtml_fix_all @i_tablename varchar(50)
AS 

declare
  @v_key int,
  @v_printingkey int,
  @v_commenttypecode int,
  @v_commenttypesubcode int,
  @v_errcode int,
  @v_errmsg varchar(2000)
  declare c_bookcomments cursor for 
    select bookkey,printingkey,commenttypecode,commenttypesubcode 
      FROM bookcomments
      where invalidhtmlind = 1
  declare c_qsicomments cursor for 
    select commentkey,commenttypecode,commenttypesubcode 
      FROM qsicomments
      where invalidhtmlind = 1

begin
               
  if upper(@i_tablename) = 'BOOKCOMMENTS' 
    begin
      OPEN c_bookcomments
      FETCH c_bookcomments INTO @v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode
      while (@@FETCH_STATUS = 0) 
        begin
          exec commenthtml_fix 'BOOKCOMMENTS',@v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode
          exec html_to_text_from_row @v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,'BOOKCOMMENTS',@v_errcode,@v_errmsg 
          exec html_to_lite_from_row @v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode,'BOOKCOMMENTS',@v_errcode,@v_errmsg 
          FETCH c_bookcomments INTO @v_key,@v_printingkey,@v_commenttypecode,@v_commenttypesubcode
        end
      CLOSE c_bookcomments
    end
                  
  if upper(@i_tablename) = 'QSICOMMENTS'
    begin
      OPEN c_qsicomments
      FETCH c_qsicomments INTO @v_key,@v_commenttypecode,@v_commenttypesubcode
      while (@@FETCH_STATUS = 0) 
        begin
          exec commenthtml_fix 'QSICOMMENTS',@v_key,null,@v_commenttypecode,@v_commenttypesubcode
          exec html_to_text_from_row @v_key,null,@v_commenttypecode,@v_commenttypesubcode,'QSICOMMENTS',@v_errcode,@v_errmsg 
          exec html_to_lite_from_row @v_key,null,@v_commenttypecode,@v_commenttypesubcode,'QSICOMMENTS',@v_errcode,@v_errmsg 
          FETCH c_qsicomments INTO @v_key,@v_commenttypecode,@v_commenttypesubcode
        end
      CLOSE c_qsicomments
    end 
         
  DEALLOCATE c_bookcomments
  DEALLOCATE c_qsicomments
          
end


