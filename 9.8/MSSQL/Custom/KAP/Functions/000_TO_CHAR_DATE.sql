if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[TO_CHAR_DATE]') and xtype in (N'FN', N'IF', N'TF'))
  drop function [dbo].[TO_CHAR_DATE]
GO

CREATE FUNCTION dbo.TO_CHAR_DATE
( @date_t as DATETIME, 
  @format as nvarchar(4000)
)
returns nvarchar(4000)

/* 4/16/07 - KW - Created for Kaplan based on the SQL Server 2005 Migration Assistant Extention Pack function:
                  SYSDB.SSMA.TO_CHAR_DATE */

begin
  If @date_t is null Or IsNull(@format, '') is null
    Return null

  Declare @retval nvarchar(4000), @ind Integer, @ind1 Integer, @flag Tinyint, @StrLen Integer, @StrLen1 Integer
  Set @retval = @format

  Declare @Midnight DateTime, @MonthName nVarchar(100), @DayName nVarchar(100), @Year Varchar(4),
          @Century Varchar(2), @Hour12 Varchar(2), @Hour24 Varchar(2), 
          @SecondDigits TinyInt, @Millisecond Varchar(9), @FirstYearDay Integer,
          @ISOWeek Integer, @ISOYear Varchar(4), @ISODeltaDay Integer, @YearSign varchar(1),
          @FMPos Integer, @BlankSymbol Varchar(1), @Rest Integer, @THexp Varchar(2),
          @TZH Integer, @TZM Integer, @NameTemp nVarchar(4000)

  Set @YearSign = ' '
  Set @BlankSymbol = '0'

  If Right(Year(@date_t), 2) = '00' 
    Set @Century = Left(Convert(nvarchar(4), Year(@date_t)), 2)
  Else
    Set @Century = Convert(nvarchar(2), Cast(Left(Convert(nvarchar(4), Year(@date_t)), 2) As Integer) + 1)

  Set @Midnight = Convert(datetime, Cast(Day(@date_t) as nvarchar) + '/' + Cast(Month(@date_t) as nvarchar) + '/' + Cast(Year(@date_t) as nvarchar), 103)
  Set @MonthName = DateName(month, @date_t) + Space(9 - LEN(DateName(month, @date_t)))
  Set @DayName = DateName(dw, @date_t) + Space(9 - LEN(DateName(dw, @date_t)))
  Set @Year = Convert(nvarchar(4), Year(@date_t))
  Set @Hour24 = Convert(nvarchar(2), DatePart(hour, @date_t))
  Set @Hour12 = Convert(nvarchar(2), Case When DatePart(hour, @date_t) > 12 Then DatePart(hour, @date_t) - 12
                                          When DatePart(hour, @date_t) = 0 Then DatePart(hour, @date_t) + 12
                                          Else DatePart(hour, @date_t) End )
  Set @FirstYearDay = IsNull(NullIf((@@dateFirst + datePart(dw, convert(datetime, '01/01/' + Cast(Year(@date_t) as nvarchar))) - 1) % 7, 0), 7)
  Set @ISODeltaDay = IsNull(NullIf(8 - @FirstYearDay, 7), 0)
  Set @ISOWeek = (Datepart(dayofyear, @date_t) + @ISODeltaDay) / 7 + @ISODeltaDay / 4 + (1 - Sign(@ISODeltaDay / Datepart(dayofyear, @date_t)))
  Set @ISOYear = Convert(nvarchar(4), Year(@date_t))
  If @ISOWeek = 0
    Begin
      Set @FirstYearDay = IsNull(NullIf((@@dateFirst + datePart(dw, convert(datetime, '01/01/' + Cast(Year(@date_t) - 1 as nvarchar))) - 1) % 7, 0), 7)
      Set @ISODeltaDay = IsNull(NullIf(8 - @FirstYearDay, 7), 0)
      Set @ISOWeek = Datediff(day, convert(datetime, Cast(@ISODeltaDay + 1 as nvarchar) + '/01/' + Cast(Year(@date_t) - 1 as nvarchar), 103), @date_t) / 7 + 1 + @ISODeltaDay / 4
      Set @ISOYear = Convert(nvarchar(4), Year(@date_t) - 1)
    End

  If @date_t >= convert(datetime, '29/12/' + Cast(Year(@date_t) as nvarchar), 103)
    Begin
      Set @ISODeltaDay = IsNull(NullIf((@@dateFirst + datePart(dw, @date_t)) % 7 - 1, 0), 7)
      If 3 - (31 - day(@date_t)) >= @ISODeltaDay
        Begin
          Set @ISOWeek = 1    
          Set @ISOYear = Convert(nvarchar(4), Year(@date_t) + 1)
        End
    End

  
  If Left(CAST(SERVERPROPERTY('productversion') AS VARCHAR), 1) = '8'
    Select @TZH = TimeDiff / 60, @TZM = TimeDiff % 60 From v_BuiltInFunctions
  Else
    Select @TZH = null, @TZM = null


  Set @FMPos = CharIndex('FM', @retval)
-- Check for "..."
  Set @ind = CharIndex('"', @retval)
  If @FMPos > 0
    While @ind > 0
      If @FMPos > @ind
        Begin
          Set @ind = CharIndex('"', @retval, @ind + 1)
          If @FMPos < @ind
            Begin
              Set @FMPos = CharIndex('FM', @retval, @ind)
              Set @ind = CharIndex('"', @retval, @ind + 1)
              Continue
            End
        End
      Else Break

  Set @retval = Replace(@retval, 'FM', '')

  Set @retval = Replace(@retval, 'FX', '') -- doesn't affect this conversion
  Set @ind = CharIndex('TZD', @retval)
  Set @ind1 = CharIndex('"', @retval)
  If @ind > 0
    While @ind1 > 0
      If @ind > @ind1
        Begin
          Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
          If @ind < @ind1
            Begin
              Set @ind = CharIndex('TZD', @retval, @ind1)
              Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
              Continue
            End
        End

  If @ind > 0
    Begin
--      Date format not recognized
      Return null
    End

  If @TZH is null
  Begin
  Set @ind = CharIndex('TZH', @retval)
  Set @ind1 = CharIndex('"', @retval)
  If @ind > 0
    While @ind1 > 0
      If @ind > @ind1
        Begin
          Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
          If @ind < @ind1
            Begin
              Set @ind = CharIndex('TZH', @retval, @ind1)
              Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
              Continue
            End
        End

  If @ind > 0
    Begin
--      Date format not recognized
      Return null
    End
  End

  If @TZH is null
  Begin
  Set @ind = CharIndex('TZM', @retval)
  Set @ind1 = CharIndex('"', @retval)
  If @ind > 0
    While @ind1 > 0
      If @ind > @ind1
        Begin
          Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
          If @ind < @ind1
            Begin
              Set @ind = CharIndex('TZM', @retval, @ind1)
              Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
              Continue
            End
        End

  If @ind > 0
    Begin
--      Date format not recognized
      Return null
    End
  End

  If (@TZH is null) Or (@TZM is null)
  Begin
  Set @ind = CharIndex('TZR', @retval)
  Set @ind1 = CharIndex('"', @retval)
  If @ind > 0
    While @ind1 > 0
      If @ind > @ind1
        Begin
          Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
          If @ind < @ind1
            Begin
              Set @ind = CharIndex('TZR', @retval, @ind1)
              Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
              Continue
            End
        End

  If @ind > 0
    Begin
--      Date format not recognized
      Return null
    End
  End
  
  Set @ind = CharIndex('DL', @retval)
  Set @ind1 = CharIndex('"', @retval)
  If @ind > 0
    While @ind1 > 0
      If @ind > @ind1
        Begin
          Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
          If @ind < @ind1
            Begin
              Set @ind = CharIndex('DL', @retval, @ind1)
              Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
              Continue
            End
        End
      Else Break

  If @ind > 0
    Begin
--      Date format not recognized
      Return null
    End

  Set @ind = CharIndex('DS', @retval)
  Set @ind1 = CharIndex('"', @retval)
  If @ind > 0
    While @ind1 > 0
      If @ind > @ind1
        Begin
          Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
          If @ind < @ind1
            Begin
              Set @ind = CharIndex('DS', @retval, @ind1)
              Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
              Continue
            End
        End
      Else Break

  If @ind > 0
    If (SubString(@retval, @ind, 3) <> 'DSP') 
      Begin
--        Date format not recognized
        Return null
      End

  Set @ind = CharIndex('TS', @retval)
  Set @ind1 = CharIndex('"', @retval)
  If @ind > 0
    While @ind1 > 0
      If @ind > @ind1
        Begin
          Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
          If @ind < @ind1
            Begin
              Set @ind = CharIndex('TS', @retval, @ind1)
              Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
              Continue
            End
        End
      Else Break

  If @ind > 0
    Begin
--      Date format not recognized
      Return null
    End

  Set @ind = CharIndex('EE', @retval)
  Set @ind1 = CharIndex('"', @retval)
  If @ind > 0
    While @ind1 > 0
      If @ind > @ind1
        Begin
          Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
          If @ind < @ind1
            Begin
              Set @ind = CharIndex('EE', @retval, @ind1)
              Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
              Continue
            End
        End
      Else Break

  If @ind > 0
    Begin
--      Date format not recognized
      Return null
    End

  Set @ind = CharIndex('E', @retval)
  Set @ind1 = CharIndex('"', @retval)
  If @ind > 0
    While @ind1 > 0
      If @ind > @ind1
        Begin
          Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
          If @ind < @ind1
            Begin
              Set @ind = CharIndex('E', @retval, @ind1)
              Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
              Continue
            End
        End
      Else Break

  If @ind > 0
    Begin
      If (SubString(@retval, @ind - 1, 4) <> 'YEAR')
        Begin
--          Date format not recognized
          Return null
        End
    End

  Set @ind = CharIndex('TZ', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind, 3) = 'TZH'
        If SubString(@retval, @ind + 3, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 3, 2) = 'SP'
          Set @retval = STUFF(@retval, @ind, 3, Char(124) + Case Sign(@TZH) When -1 Then '-' When 1 Then '+' Else '' End + Right(@BlankSymbol + Cast(@TZH as nvarchar), 2))
        Else
          Set @retval = STUFF(@retval, @ind, 3, Case Sign(@TZH) When -1 Then '-' When 1 Then '+' Else '' End + Right(@BlankSymbol + Cast(@TZH as nvarchar), 2))
      Else
      If SubString(@retval, @ind, 3) = 'TZM'
        If SubString(@retval, @ind + 3, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 3, 2) = 'SP'
          Set @retval = STUFF(@retval, @ind, 3, Char(124) + Right(@BlankSymbol + Cast(@TZM as nvarchar), 2))
        Else
          Set @retval = STUFF(@retval, @ind, 3, Right(@BlankSymbol + Cast(@TZM as nvarchar), 2))
      Else
      If SubString(@retval, @ind, 3) = 'TZR'
        Set @retval = STUFF(@retval, @ind, 3, Case Sign(@TZH) When -1 Then '-' When 1 Then '+' Else '' End + Right('0' + Cast(@TZH as nvarchar), 2) + ':' + Right('0' + Cast(@TZM as nvarchar), 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, '')

      Set @ind = CharIndex('TZ', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('CC', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + @Century)
      Else
        Set @retval = STUFF(@retval, @ind, 2, @Century)

      If SubString(@retval, @ind - 1, 1) = 'S'
        Set @retval = STUFF(@retval, @ind - 1, 1, @YearSign)

      Set @ind = CharIndex('CC', @retval, @ind + 1)
    End

  Set @ind = CharIndex('YYYY', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 4, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 4, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 4, Char(124) + @Year)
      Else
        Set @retval = STUFF(@retval, @ind, 4, @Year)

      If SubString(@retval, @ind - 1, 1) = 'S'
        Set @retval = STUFF(@retval, @ind - 1, 1, @YearSign)

      Set @ind = CharIndex('YYYY', @retval, @ind + 1)
    End

  Set @ind = CharIndex('RRRR', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 4, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 4, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 4, Char(124) + @Year)
      Else
        Set @retval = STUFF(@retval, @ind, 4, @Year)

      Set @ind = CharIndex('RRRR', @retval, @ind + 1)
    End

  Set @ind = CharIndex('Y,YYY', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 5, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 5, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 5, Char(124) + Left(@Year, 1) + ',' + Right(@Year, 3))
      Else
        Set @retval = STUFF(@retval, @ind, 5, Left(@Year, 1) + ',' + Right(@Year, 3))

      Set @ind = CharIndex('Y,YYY', @retval, @ind + 1)
    End

  Set @ind = CharIndex('IYYY', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 4, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 4, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 4, Char(124) + @ISOYear)
      Else
        Set @retval = STUFF(@retval, @ind, 4, @ISOYear)

      Set @ind = CharIndex('IYYY', @retval, @ind + 1)
    End

  Set @ind = CharIndex('YYY', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 3, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 3, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 3, Char(124) + Right(@Year, 3))
      Else
        Set @retval = STUFF(@retval, @ind, 3, Right(@Year, 3))

      Set @ind = CharIndex('YYY', @retval, @ind + 1)
    End

  Set @ind = CharIndex('IYY', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 3, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 3, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 3, Char(124) + Right(@ISOYear, 3))
      Else
        Set @retval = STUFF(@retval, @ind, 3, Right(@ISOYear, 3))

      Set @ind = CharIndex('IYY', @retval, @ind + 1)
    End

  Set @ind = CharIndex('YY', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right(@Year, 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right(@Year, 2))

      Set @ind = CharIndex('YY', @retval, @ind + 1)
    End

  Set @ind = CharIndex('RR', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right(@Year, 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right(@Year, 2))

      Set @ind = CharIndex('RR', @retval, @ind + 1)
    End

  Set @ind = CharIndex('IY', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right(@ISOYear, 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right(@ISOYear, 2))

      Set @ind = CharIndex('IY', @retval, @ind + 1)
    End

  Set @ind = CharIndex('Y', @retval)
  While @ind > 0
    Begin
      If (SubString(@retval, @ind - 1, 2) <> 'DY') and (SubString(@retval, @ind - 2, 3) <> 'DAY') and (SubString(@retval, @ind, 4) <> 'YEAR')
        If SubString(@retval, @ind + 1, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 1, 2) = 'SP'
          Set @retval = STUFF(@retval, @ind, 1, Char(124) + Right(@Year, 1))
        Else
          Set @retval = STUFF(@retval, @ind, 1, Right(@Year, 1))

      Set @ind = CharIndex('Y', @retval, @ind + 1)
    End

  Set @ind = CharIndex('Q', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 1, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 1, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 1, Char(124) + Cast(DatePart(q, @date_t) as nvarchar))
      Else
        Set @retval = STUFF(@retval, @ind, 1, Cast(DatePart(q, @date_t) as nvarchar))

      Set @ind = CharIndex('Q', @retval, @ind + 1)
    End

  Set @ind = CharIndex('MM', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right(@BlankSymbol + Cast(Month(@date_t) as nvarchar), 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right(@BlankSymbol + Cast(Month(@date_t) as nvarchar), 2))

      Set @ind = CharIndex('MM', @retval, @ind)
    End
  Set @BlankSymbol = '0'


  Set @ind = CharIndex('DDD', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 3, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 3, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 3, Char(124) + Right(Replicate(@BlankSymbol, 2) + Cast(DatePart(dy, @date_t) as nvarchar), 3))
      Else
        Set @retval = STUFF(@retval, @ind, 3, Right(Replicate(@BlankSymbol, 2) + Cast(DatePart(dy, @date_t) as nvarchar), 3))

      Set @ind = CharIndex('DDD', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('DD', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right(@BlankSymbol + Cast(DatePart(dd, @date_t) as nvarchar), 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right(@BlankSymbol + Cast(DatePart(dd, @date_t) as nvarchar), 2))

      Set @ind = CharIndex('DD', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('D', @retval)
  While @ind > 0
    Begin
      If (SubString(@retval, @ind, 2) <> 'DY') and (SubString(@retval, @ind, 3) <> 'DAY')
        If SubString(@retval, @ind + 1, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 1, 2) = 'SP'
          Set @retval = STUFF(@retval, @ind, 1, Char(124) + Cast(DatePart(dw, @date_t) as nvarchar))
        Else
          Set @retval = STUFF(@retval, @ind, 1, Cast(DatePart(dw, @date_t) as nvarchar))

      Set @ind = CharIndex('D', @retval, @ind + 1)
    End

  Set @ind = CharIndex('WW', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right(@BlankSymbol + Cast(DatePart(dy, @date_t) / 7 + 1 as nvarchar), 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right(@BlankSymbol + Cast(DatePart(dy, @date_t) / 7 + 1 as nvarchar), 2))

      Set @ind = CharIndex('WW', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('IW', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right(@BlankSymbol + Cast(@ISOWeek as nvarchar), 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right(@BlankSymbol + Cast(@ISOWeek as nvarchar), 2))

      Set @ind = CharIndex('IW', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('W', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 1, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 1, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 1, Char(124) + Cast(Day(@date_t) / 7 + 1 as nvarchar))
      Else
        Set @retval = STUFF(@retval, @ind, 1, Cast(Day(@date_t) / 7 + 1 as nvarchar))

      Set @ind = CharIndex('W', @retval, @ind + 1)
    End

  Set @ind = CharIndex('HH24', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 4, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 4, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 4, Char(124) + Right(@BlankSymbol + @Hour24, 2))
      Else
        Set @retval = STUFF(@retval, @ind, 4, Right(@BlankSymbol + @Hour24, 2))
      If @ind < @FMPos Set @FMPos = @FMPos - 2

      Set @ind = CharIndex('HH24', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('HH12', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 4, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 4, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 4, Char(124) + Right(@BlankSymbol + @Hour12, 2))
      Else
        Set @retval = STUFF(@retval, @ind, 4, Right(@BlankSymbol + @Hour12, 2))
      If @ind < @FMPos Set @FMPos = @FMPos - 2

      Set @ind = CharIndex('HH12', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('HH', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right(@BlankSymbol + @Hour12, 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right(@BlankSymbol + @Hour12, 2))

      Set @ind = CharIndex('HH', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('MI', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right(@BlankSymbol + Cast(Datepart(minute, @date_t) As nvarchar), 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right(@BlankSymbol + Cast(Datepart(minute, @date_t) As nvarchar), 2))

      Set @ind = CharIndex('MI', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('SSSSS', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 5, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 5, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 5, Char(124) + Right(Replicate(@BlankSymbol, 4) + Cast(DateDiff(second, @date_t, @Midnight) as nvarchar), 5))
      Else
        Set @retval = STUFF(@retval, @ind, 5, Right(Replicate(@BlankSymbol, 4) + Cast(DateDiff(second, @date_t, @Midnight) as nvarchar), 5))

      Set @ind = CharIndex('SSSSS', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('SS', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = ''
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right(@BlankSymbol + Cast(DatePart(second, @date_t) as nvarchar), 2))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right(@BlankSymbol + Cast(DatePart(second, @date_t) as nvarchar), 2))

      Set @ind = CharIndex('SS', @retval, @ind)
    End
  Set @BlankSymbol = '0'

  Set @ind = CharIndex('I', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 1, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 1, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 1, Char(124) + Right(@ISOYear, 1))
      Else
        Set @retval = STUFF(@retval, @ind, 1, Right(@ISOYear, 1))

      Set @ind = CharIndex('I', @retval, @ind + 1)
    End

  Set @ind = PatIndex('%FF[1-9]%', @retval)
  While @ind > 0
    Begin
      Set @SecondDigits = Cast(Substring(@retval, @ind + 2, 1) As tinyint)
      Set @Millisecond = Right('00' + Cast(DatePart(millisecond, @date_t) as nvarchar), 3)
      
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 3, Char(124) + Left(@Millisecond + '00000', @SecondDigits))
      Else
        Set @retval = STUFF(@retval, @ind, 3, Left(@Millisecond + '00000', @SecondDigits))
      Set @ind = PatIndex('%FF[1-9]%', @retval)
    End

  Set @retval = Replace(@retval, 'X', '.')

  Set @ind = CharIndex('FF', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 2, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 2, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 2, Char(124) + Right('00' + Cast(DatePart(millisecond, @date_t) as nvarchar), 3))
      Else
        Set @retval = STUFF(@retval, @ind, 2, Right('00' + Cast(DatePart(millisecond, @date_t) as nvarchar), 3))

      Set @ind = CharIndex('FF', @retval, @ind)
    End
  
  Set @retval = Replace(@retval, 'AM', Case When DatePart(hour, @date_t) > 11 Then 'PM' Else 'AM' end)
  Set @retval = Replace(@retval, 'A.M.', Case When DatePart(hour, @date_t) > 11 Then 'P.M.' Else 'A.M.' end)
  Set @retval = Replace(@retval, 'PM', Case When DatePart(hour, @date_t) > 11 Then 'PM' Else 'AM' end)
  Set @retval = Replace(@retval, 'P.M.', Case When DatePart(hour, @date_t) > 11 Then 'P.M.' Else 'A.M.' end)


  Set @ind = CharIndex('J', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind + 1, 4) in ('SPTH', 'THSP') Or SubString(@retval, @ind + 1, 2) = 'SP'
        Set @retval = STUFF(@retval, @ind, 1, Char(124) + Cast(2361331 + DateDiff(day, Convert(datetime, '01/01/1753', 103), @date_t) as nvarchar))
      Else
        Set @retval = STUFF(@retval, @ind, 1, Cast(2361331 + DateDiff(day, Convert(datetime, '01/01/1753', 103), @date_t) as nvarchar))

      Set @ind = CharIndex('J', @retval, @ind + 1)
    End

  Set @ind = CharIndex('TH', @retval)
  While @ind > 0
    Begin
      If IsNumeric(Substring(@retval, @ind - 1, 1)) = 1 and SubString(@retval, @ind, 4) <> 'THSP'
        Begin
          Set @THexp = Case Cast(Substring(@retval, @ind - 1, 1) as Integer)
                       When 1 Then 'ST'
                       When 2 Then 'ND'
                       When 3 Then 'RD'
                       Else 'TH'
                       end
          If ASCII(SubString(@retval, @ind, 1)) = ASCII('t')
            Set @THexp = lower(@THexp)

          Set @retval = STUFF(@retval, @ind, 2, @THexp)
        End
      Else
        If SubString(@retval, @ind - 3, 5) <> 'MONTH' and 
           SubString(@retval, @ind, 4) <> 'THSP' and
           SubString(@retval, @ind - 2, 4) <> 'SPTH'
         Begin
           Set @ind1 = CharIndex('"', @retval)
           While @ind1 > 0
             If @ind > @ind1
               Begin
                 Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
                 If @ind < @ind1 Break
                 Else Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
               End
             Else
               Begin
--           Date format not recognized
                 Return null
               end
             If @ind > 0
               Begin
--                 Date format not recognized
                 Return null
               end
         end

      Set @ind = CharIndex('TH', @retval, @ind + 1)
    End

  Set @ind = CharIndex('SP', @retval)
  While @ind > 0
    Begin
      If SubString(@retval, @ind - 2, 4) = 'THSP' And SubString(@retval, @ind - 5, 7) <> 'MONTHSP'
        Set @ind = @ind - 2

      Set @ind1 = CharIndex(Char(124), @retval, @ind - 8)
      Set @NameTemp = ''
      If @ind1 > 0 And @ind1 < @ind
        Begin
          Set @StrLen = CharIndex(Char(124), @retval, @ind1 + 1)
          If @StrLen > 0 and @StrLen < @ind
            Set @ind1 = @StrLen

          If IsNumeric(Replace(SubString(@retval, @ind1 + 1, @ind - @ind1 - 1), ',', '')) = 1
            Begin
              If SubString(@retval, @ind, 4) in ('SPTH', 'THSP') Set @flag = 1
              Else Set @flag = 0
              Set @NameTemp = RTRIM(UPPER(dbo.NumberSpelledOutEnglish(Cast(Replace(SubString(@retval, @ind1 + 1, @ind - @ind1 - 1), ',', '') As Integer), @flag)))

              If SubString(@retval, @ind, 4) in ('SPTH', 'THSP') 
                Set @retval = STUFF(@retval, @ind1, @ind - @ind1 + 4, @NameTemp)
              Else
                Set @retval = STUFF(@retval, @ind1, @ind - @ind1 + 2, @NameTemp)
            End 
          Else
            Begin
              Set @ind1 = CharIndex('"', @retval)
              While @ind1 > 0
                If @ind > @ind1
                  Begin
                    Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
                    If @ind < @ind1 Break
                    Else Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
                  End
                Else
                  Begin
--                    Date format not recognized
                    Return null
                  end
             If @ind > 0
               Begin
--                 Date format not recognized
                 Return null
               end
            End
        End
      Else
        Begin
          Set @ind1 = CharIndex('"', @retval)
            While @ind1 > 0
              If @ind > @ind1
                Begin
                  Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
                  If @ind < @ind1 Break
                  Else Set @ind1 = CharIndex('"', @retval, @ind1 + 1)
                End
              Else
                Begin
--                  Date format not recognized
                  Return null
                end
             If @ind > 0
               Begin
--                 Date format not recognized
                 Return null
               end
        End

      Set @ind = CharIndex('SP', @retval, @ind1 + Len(@NameTemp))
    End

  Set @ind = CharIndex('MONTH', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 
        Begin
          Set @NameTemp = RTrim(@MonthName)
        End
      Else
        Begin
          Set @NameTemp = @MonthName
          If @FMPos > 0 Set @FMPos = @FMPos + Len(Replace(@MonthName, ' ', '.')) - 5
        End

      If SubString(@retval COLLATE Latin1_General_BIN, @ind, 2) = 'MO' COLLATE Latin1_General_BIN
        Set @retval = STUFF(@retval, @ind, 5, UPPER(@NameTemp))
      Else If SubString(@retval COLLATE Latin1_General_BIN, @ind, 2) = 'Mo' COLLATE Latin1_General_BIN
             Set @retval = STUFF(@retval, @ind, 5, @NameTemp) 
           Else
             Set @retval = STUFF(@retval, @ind, 5, Lower(@NameTemp))
      If @ind + len(@MonthName) < len(@retval)
        Set @ind = CharIndex('MONTH', @retval, @ind + len(@MonthName))
      Else
        Set @ind = 0
    End

  Set @ind = CharIndex('MON', @retval)
  While @ind > 0
    Begin
      If (SubString(@retval COLLATE Latin1_General_BIN, @ind, 2) = 'MO' COLLATE Latin1_General_BIN)
        Set @retval = STUFF(@retval, @ind, 3, UPPER(Left(@MonthName, 3)))
      Else If (SubString(@retval COLLATE Latin1_General_BIN, @ind, 2) = 'Mo' COLLATE Latin1_General_BIN)
             Set @retval = STUFF(@retval, @ind, 3, Left(@MonthName, 3))
           Else
             Set @retval = STUFF(@retval, @ind, 3, Lower(Left(@MonthName, 3)))
      Set @ind = CharIndex('MON', @retval, @ind + 3)
    End

  Set @ind = CharIndex('RM', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 Set @BlankSymbol = '' Else Set @BlankSymbol = ' '
      Set @retval = STUFF(@retval, @ind, 2, Left((Case Month(@date_t) When 1 Then  'I'
                                                           When 2 Then  'II'
                                                           When 3 Then  'III'
                                                           When 4 Then  'IV'
                                                           When 5 Then  'V'
                                                           When 6 Then  'VI'
                                                           When 7 Then  'VII'
                                                           When 8 Then  'VIII'
                                                           When 9 Then  'IX'
                                                           When 10 Then 'X'
                                                           When 11 Then 'XI'
                                                           When 12 Then 'XII' end) + Replicate(@BlankSymbol, 3), 4))
      Set @ind = CharIndex('RM', @retval, @ind)
    End

  Set @ind = CharIndex('DAY', @retval)
  While @ind > 0
    Begin
      If @ind >= @FMPos and @FMPos > 0 
        Begin
          Set @NameTemp = RTrim(@DayName)
        End
      Else
        Begin
          Set @NameTemp = @DayName
          If @FMPos > 0 Set @FMPos = @FMPos + Len(Replace(@DayName, ' ', '.')) - 5
        End

      If (SubString(@retval COLLATE Latin1_General_BIN, @ind, 2) = 'DA' COLLATE Latin1_General_BIN)
        Set @retval = STUFF(@retval, @ind, 3, UPPER(@NameTemp))
      Else If (SubString(@retval COLLATE Latin1_General_BIN, @ind, 2) = 'Da' COLLATE Latin1_General_BIN)
             Set @retval = STUFF(@retval, @ind, 3, @NameTemp) 
           Else
             Set @retval = STUFF(@retval, @ind, 3, Lower(@NameTemp)) 

      If @ind + len(@DayName) < len(@retval)
        Set @ind = CharIndex('DAY', @retval, @ind + len(@DayName))
      Else
        Set @ind = 0
    End

  Set @ind = CharIndex('DY', @retval)
  While @ind > 0
    Begin
      If @ind < @FMPos and @FMPos > 0 
        Set @FMPos = @FMPos + 1

      If (SubString(@retval COLLATE Latin1_General_BIN, @ind, 2) = 'DY' COLLATE Latin1_General_BIN)
        Set @retval = STUFF(@retval, @ind, 2, UPPER(Left(@DayName, 3)))
      Else If (SubString(@retval COLLATE Latin1_General_BIN, @ind, 2) = 'Dy' COLLATE Latin1_General_BIN)
             Set @retval = STUFF(@retval, @ind, 2, Left(@DayName, 3)) 
           Else
             Set @retval = STUFF(@retval, @ind, 2, Lower(Left(@DayName, 3)))
      Set @ind = CharIndex('DY', @retval, @ind + 3)
    End

  Set @ind = CharIndex('YEAR', @retval)
  While @ind > 0
    Begin
      Set @retval = STUFF(@retval, @ind, 4, UPPER(dbo.NumberSpelledOutEnglish(@Year, 0)))
      If SubString(@retval, @ind - 1, 1) = 'S'
        Set @retval = STUFF(@retval, @ind - 1, 1, @YearSign)
      Set @ind = CharIndex('YEAR', @retval)
    End

-- Check for "..."
  Set @ind = CharIndex('"', @retval)
  Set @StrLen1 = 0
  Set @ind1 = 0
  While @ind > 0
    Begin
      Set @ind1 = CharIndex('"', @format, @ind1 + @StrLen1)
      If @ind1 > 0
        Begin
          Set @StrLen = CharIndex('"', @retval, @ind + 1) - @ind + 1
          Set @StrLen1 = CharIndex('"', @format, @ind1 + 1) - @ind1 + 1
          Set @retval = STUFF(@retval, @ind, @StrLen, SubString(@format, @ind1 + 1, @StrLen1 - 2))
          Set @ind = CharIndex('"', @retval, @ind + @StrLen)
        End
      Else Break
    End
  Return @retval
end
