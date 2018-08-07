DROP FUNCTION plaintext_to_html
go

CREATE FUNCTION plaintext_to_html
    ( @i_string as varchar(8000) ) 

RETURNS varchar(8000)

BEGIN 

  DECLARE @o_string varchar(8000)
  DECLARE @v_string varchar(8000)
  DECLARE @v_newline varchar(10)
  DECLARE @v_tab varchar(10)

  set @v_newline = char(13)+char(10)
  set @v_tab = char(8)

  set @v_string = replace(@i_string,@v_newline,'</br>')
  set @v_string = replace(@v_string,@v_tab,'   ')

  set @o_string = '<DIV>'+@v_string+'</DIV>'


  RETURN @o_string
END 
go
