DROP FUNCTION Remove_plural
go
CREATE FUNCTION Remove_plural
    ( @i_string as varchar(2000), @i_val as float ) 

RETURNS varchar(2000)

BEGIN 
   DECLARE @o_string varchar(2000)
   DECLARE @v_string varchar(2000)
   DECLARE @v_s varchar(20)

   set @v_string = LOWER(@i_string)
   set @o_string = @i_string
   set @v_s = 's'

   if @i_string is not null and len(@i_string) > 1 and @i_val = 1
      if substring(@i_string,len(@i_string),len(@v_s)) = @v_s 
        set @o_string = substring(@i_string,1,len(@i_string)-len(@v_s))

  RETURN @o_string
END

