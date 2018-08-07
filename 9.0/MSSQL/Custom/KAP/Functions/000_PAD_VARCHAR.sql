if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PAD_varchar]') and xtype in (N'FN', N'IF', N'TF'))
  drop function [dbo].[PAD_varchar]
GO

CREATE FUNCTION dbo.PAD_varchar
(
  @Switch TinyInt = 1, -- 1 - LPAD, 2 - RPAD
  @left as varchar(8000), 
  @n as int, 
  @pad as varchar(8000) = ' '
)
returns varchar(8000)

/* 4/16/07 - KW - Created for Kaplan based on the SQL Server 2005 Migration Assistant Extention Pack function:
                  SYSDB.SSMA.PAD_varchar */
                  
begin

    declare @retval as varchar(8000), @TempPad Varchar(8000), @LenLeft Integer, @LenPad Integer

    Set @LenLeft = datalength(@left)
    Set @LenPad = datalength(@pad)

    If @LenLeft = 0 Or @LenPad = 0 Or IsNull(@n, 0) = 0
      Begin
        Set @retval = null
        return @retval
      End;

    If @LenLeft >= @n
      Begin
        Set @retval = Left(@left, @n)
        return @retval
      End

    Set @TempPad = Replicate(@pad, Ceiling((@n - @LenLeft) / @LenPad))

    If @Switch = 2
      Set @retval = @left + Left(@TempPad, @n - @LenLeft)
    Else
      Set @retval = Left(@TempPad, @n - @LenLeft) + @left

    return @retval
end
