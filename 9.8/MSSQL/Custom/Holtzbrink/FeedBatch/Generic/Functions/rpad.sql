if exists (select * from dbo.sysobjects where id = object_id(N'rpad') and xtype in (N'FN', N'IF', N'TF'))
drop function rpad
GO
  CREATE 
    FUNCTION dbo.rpad
    (@string varchar(8000),
     @number int,
     @string_pad varchar(255))
    RETURNS varchar(8000)
    AS
BEGIN	
while len(@string) < @number
begin
   set @string = @string + @string_pad
end
return @string
END
go
grant execute on rpad  to public
go

