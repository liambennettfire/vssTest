drop FUNCTION DBO.resolve_date
go

CREATE FUNCTION DBO.resolve_date
  (@i_date_str varchar(8000))
   RETURNS datetime

BEGIN

  declare 
    @v_date datetime,
    @v_valid_date int,
    @v_date_str varchar(50)

  set @v_valid_date = 0
  set @v_date = null

  if isdate(@i_date_str)=1
    begin
      set @v_valid_date = 1
      set @v_date = cast(@i_date_str as datetime)
    end
  --try mm-dd-yy(yy) an yy-mm-dd masks
  if @v_valid_date = 0 and datalength(@i_date_str)>=6
    begin
      set @v_date_str = substring(@i_date_str,1,2)+'-'+substring(@i_date_str,3,2)+'-'+substring(@i_date_str,5,len(@i_date_str)-5+1)
      if isdate(@v_date_str)=1
        begin
          set @v_valid_date = 1
          set @v_date = cast(@v_date_str as datetime)
        end
    end
  --try yyyy-mm-dd mask
  if @v_valid_date = 0 and datalength(@i_date_str)>=8
    begin
      set @v_date_str = substring(@i_date_str,1,4)+'-'+substring(@i_date_str,5,2)+'-'+substring(@i_date_str,7,len(@i_date_str)-7+1)
      if isdate(@v_date_str)=1
        begin
          set @v_valid_date = 1
          set @v_date = cast(@v_date_str as datetime)
        end
    end

  RETURN @v_date 
END 
go



