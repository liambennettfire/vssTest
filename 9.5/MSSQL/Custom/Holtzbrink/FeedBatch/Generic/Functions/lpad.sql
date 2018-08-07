if exists (select * from dbo.sysobjects where id = object_id(N'lpad') and xtype in (N'FN', N'IF', N'TF'))
drop function lpad
GO
  CREATE 
    FUNCTION dbo.lpad
    (@string varchar(8000),
     @number int,
     @string_pad varchar(255))
    RETURNS varchar(8000)
    AS
BEGIN	
while len(@string) < @number
begin
   set @string =  @string_pad + @string 
end
return @string
END
go
grant execute on lpad  to public
go

