drop procedure dbo.name_parse
GO
CREATE PROCEDURE dbo.name_parse
  @i_name_full varchar(200),
  @o_name_last varchar(200) output,
  @o_name_first varchar(200) output,
  @o_name_middle varchar(200) output
as
begin
  declare
    @v_slash_ptr int,
    @v_first_ptr int

  set @o_name_last = null
  set @o_name_first = null
  set @o_name_middle = null

  set @v_slash_ptr = patindex('%\%',@i_name_full)
  if @v_slash_ptr = 0
    begin
      set @o_name_last = @i_name_full 
    end
  else
    begin
      set @o_name_last = substring(@i_name_full, @v_slash_ptr+1, len(@i_name_full))
      set @v_first_ptr = patindex('% %',@i_name_full)
      set @o_name_first = substring(@i_name_full,1,@v_first_ptr)
      set @o_name_middle = substring(@i_name_full,@v_first_ptr,@v_slash_ptr-@v_first_ptr)
      set @o_name_middle = replace(@o_name_middle,'\','')
      set @o_name_middle = replace(@o_name_middle,'.','')
      set @o_name_middle = replace(@o_name_middle,' ','')
    end

END
go

GRANT EXECUTE ON dbo.name_parse to PUBLIC 
GO
