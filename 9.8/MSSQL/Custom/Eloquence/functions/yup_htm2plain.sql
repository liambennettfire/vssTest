DROP FUNCTION yup_htm2plain
go
CREATE FUNCTION yup_htm2plain
    ( @i_string as text)

RETURNS varchar(8000)

BEGIN 
   DECLARE @o_string varchar(8000)
   DECLARE @v_newline varchar(10)

   set @v_newline = char(13)+char(10)

   set @o_string = cast(@i_string as varchar(8000))
   set @o_string = replace(@o_string,CHAR(13),@v_newline)
   set @o_string = replace(@o_string,CHAR(149),'')

   RETURN @o_string
END

