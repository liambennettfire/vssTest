drop FUNCTION DBO.valid_orgkeyset
go

CREATE FUNCTION DBO.valid_orgkeyset
  (@i_orgkeyset varchar(8000))
   RETURNS int

BEGIN

  declare 
    @v_level int,
    @v_orgentrykey int,
    @v_parentkey int,
    @v_valid_set int

  select @v_level = max(orglevelnumber)
    from orglevel
  set @v_parentkey = null
  if @i_orgkeyset is null
    set @v_valid_set = 0
  else
    set @v_valid_set = 1

  while @v_valid_set = 1 and @v_level > 0 
    begin
      set @v_orgentrykey = dbo.resolve_keyset(@i_orgkeyset,@v_level)
      if @v_parentkey is not null 
        begin
          if @v_parentkey <> @v_orgentrykey 
            begin
              set @v_valid_set = 0
            end
        end
      if @v_orgentrykey is not null
        begin
          select @v_parentkey = orgentryparentkey
            from orgentry
            where orgentrykey = @v_orgentrykey 
              and deletestatus='Y'
          if @v_parentkey is null 
            begin
              set @v_valid_set = 0
            end
        end
      else
        begin
          set @v_valid_set = 0
        end     
      set @v_level = @v_level - 1
    end

  RETURN @v_valid_set 
END 
go



