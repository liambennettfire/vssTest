if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NumberSpelledOutEnglish]') and xtype in (N'FN', N'IF', N'TF'))
  drop function [dbo].[NumberSpelledOutEnglish]
GO

CREATE FUNCTION dbo.NumberSpelledOutEnglish
(
  @Value Integer, 
  @IsOrdinal tinyint = 0
)
Returns nvarchar(4000)

/* 4/16/07 - KW - Created for Kaplan based on the SQL Server 2005 Migration Assistant Extention Pack function:
                  SSMA.NumberSpelledOutEnglish */

Begin
  Declare @retval nvarchar(4000), @TriadaValue SmallInt, @TriadaNumber TinyInt
  If @Value = 0 
    If @IsOrdinal = 1 Return 'Zeroeth'
    Else Return 'Zero'

  Set @retval = ''
  
  Set @TriadaNumber = 1  
  Set @TriadaValue = (@Value / Power(1000, (@TriadaNumber - 1))) % 1000
  While @Value > Power(1000, (@TriadaNumber - 1)) 
  Begin
    If @TriadaNumber > 1 and @TriadaValue > 0
      Set @retval = Case @TriadaNumber
                    When 2 Then 'Thousand '
                    When 3 Then 'Million '
                    End + @retval
    
    If (@TriadaValue % 100) between 10 and 19
      Begin
        If @TriadaNumber = 1 and @IsOrdinal = 1
          Set @retval = case (@TriadaValue % 100)
                        When 10 Then 'Tenth'
                        When 11 Then 'Eleventh'
                        When 12 Then 'Twelfth'
                        When 13 Then 'Thirteenth'
                        When 14 Then 'Fourteenth'
                        When 15 Then 'Fifteenth'
                        When 16 Then 'Sixteenth'
                        When 17 Then 'Seventeenth'
                        When 18 Then 'Eighteenth'
                        When 19 Then 'Nineteenth'
                        end
        Else
          Set @retval = case (@TriadaValue % 100)
                        When 10 Then 'Ten'
                        When 11 Then 'Eleven'
                        When 12 Then 'Twelve'
                        When 13 Then 'Thirteen'
                        When 14 Then 'Fourteen'
                        When 15 Then 'Fifteen'
                        When 16 Then 'Sixteen'
                        When 17 Then 'Seventeen'
                        When 18 Then 'Eighteen'
                        When 19 Then 'Nineteen'
                        end + ' ' + @retval
      End
    Else
      Begin
        If @TriadaValue % 10 > 0
          If @TriadaNumber = 1 and @IsOrdinal = 1
            Set @retval = case (@TriadaValue % 10)
                          When 1 Then 'First'
                          When 2 Then 'Second'
                          When 3 Then 'Third'
                          When 4 Then 'Fourth'
                          When 5 Then 'Fifth'
                          When 6 Then 'Sixth'
                          When 7 Then 'Seventh'
                          When 8 Then 'Eighth'
                          When 9 Then 'Ninth'
                          end
          Else
            Set @retval = case (@TriadaValue % 10)
                          When 1 Then 'One'
                          When 2 Then 'Two'
                          When 3 Then 'Three'
                          When 4 Then 'Four'
                          When 5 Then 'Five'
                          When 6 Then 'Six'
                          When 7 Then 'Seven'
                          When 8 Then 'Eight'
                          When 9 Then 'Nine'
                          end + ' ' + @retval
                          
      
        If (@TriadaValue / 10) % 10 > 1
          If @TriadaNumber = 1 and @IsOrdinal = 1 and @TriadaValue % 10 = 0
            Set @retval = case ((@TriadaValue / 10) % 10)
                          When 2 Then 'Twentieth'
                          When 3 Then 'Thirtieth'
                          When 4 Then 'Fortieth'
                          When 5 Then 'Fiftieth'
                          When 6 Then 'Sixtieth'
                          When 7 Then 'Seventieth'
                          When 8 Then 'Eightieth'
                          When 9 Then 'Ninetieth'
                          end
          Else
            Set @retval = case ((@TriadaValue / 10) % 10)
                          When 2 Then 'Twenty'
                          When 3 Then 'Thirty'
                          When 4 Then 'Forty'
                          When 5 Then 'Fifty'
                          When 6 Then 'Sixty'
                          When 7 Then 'Seventy'
                          When 8 Then 'Eighty'
                          When 9 Then 'Ninety'
                          end +
                          Case When @TriadaValue % 10 > 0 Then '-' Else ' ' End + @retval
        End

      If (@TriadaValue / 100) % 10 > 0
        Set @retval = case ((@TriadaValue / 100) % 10)
                          When 1 Then 'One'
                          When 2 Then 'Two'
                          When 3 Then 'Three'
                          When 4 Then 'Four'
                          When 5 Then 'Five'
                          When 6 Then 'Six'
                          When 7 Then 'Seven'
                          When 8 Then 'Eight'
                          When 9 Then 'Nine'
                      end + ' Hundred ' + @retval
     
    Set @TriadaNumber = @TriadaNumber + 1
    Set @TriadaValue = (@Value / Power(1000, (@TriadaNumber - 1))) % 1000
  End  
  If @IsOrdinal = 1 and @Value % 100 = 0 Set @retval = RTRIM(@retval) + 'th'

  Return @retval
End
