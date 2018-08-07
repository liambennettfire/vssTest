if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[resolve_keyset]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[resolve_keyset]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE FUNCTION DBO.resolve_keyset
  (@i_orgkeyset varchar(8000),
   @i_occurance int)
   RETURNS int

BEGIN

  declare
    @v_keyset varchar(8000),
    @v_keystring varchar(8000),
    @v_key int,
    @v_keyfound int,
    @v_char char(1),
    @v_pointer int,
    @v_count int
  
  set @v_keyset=replace(@i_orgkeyset,'(','')
  set @v_keyset=replace(@v_keyset,')','')
  set @v_keyset=replace(@v_keyset,' ','')
  set @v_keyset=@v_keyset+'x'

  set @v_pointer = 0
  set @v_count = 0
  set @v_keyfound = 0
  set @v_keystring = ''

  while @v_pointer < datalength(@v_keyset) and @v_keyfound = 0
    begin
      set @v_pointer = @v_pointer + 1
      set @v_char = substring(@v_keyset,@v_pointer,1)
      if @v_char >= '0' and @v_char <= '9'
        begin
          set @v_keystring=@v_keystring+@v_char
        end
      else
        begin
          set @v_count = @v_count + 1 
          if @i_occurance = @v_count
            begin
              set @v_keyfound = 1
              if isnumeric(@v_keystring)=1
                begin
                  set @v_key=@v_keystring
                end
            end
          set @v_keystring = ''
        end
    end

  RETURN @v_key 
END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

