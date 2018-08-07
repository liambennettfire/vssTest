/******************************************************************************
**  Name: qutl_remove_special_characters
**  Desc: 
**  Auth: Dustin Miller
**  Date: March 17, 2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  
*******************************************************************************/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_remove_special_characters]') AND type in (N'FN'))
	DROP FUNCTION [dbo].[qutl_remove_special_characters]
GO

CREATE FUNCTION [dbo].[qutl_remove_special_characters](@text VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
  DECLARE @textposition int,
          @excludeposition int,
          @excludedchar tinyint,
          @excludelist varchar(24),
          @buffer varchar(max)
          
  SET @excludelist = ''
  SET @excludelist = @excludelist + CHAR(9)
  SET @excludelist = @excludelist + CHAR(10)
  SET @excludelist = @excludelist + CHAR(11)
  SET @excludelist = @excludelist + CHAR(12)
  SET @excludelist = @excludelist + CHAR(13)
  SET @excludelist = @excludelist + CHAR(37)
  SET @excludelist = @excludelist + CHAR(40)
  SET @excludelist = @excludelist + CHAR(41)
  SET @excludelist = @excludelist + CHAR(42)
  SET @excludelist = @excludelist + CHAR(43)
  SET @excludelist = @excludelist + CHAR(47)
  SET @excludelist = @excludelist + CHAR(60)
  SET @excludelist = @excludelist + CHAR(61)
  SET @excludelist = @excludelist + CHAR(62)
  SET @excludelist = @excludelist + CHAR(91)
  SET @excludelist = @excludelist + CHAR(92)
  SET @excludelist = @excludelist + CHAR(93)
  SET @excludelist = @excludelist + CHAR(94)
  SET @excludelist = @excludelist + CHAR(95)
  SET @excludelist = @excludelist + CHAR(123)
  SET @excludelist = @excludelist + CHAR(124)
  SET @excludelist = @excludelist + CHAR(125)
  SET @excludelist = @excludelist + CHAR(126)
  SET @excludelist = @excludelist + CHAR(255)

  SET @textposition = 1
  SET @buffer = ''

  WHILE @textposition <= DATALENGTH(@text)  
  BEGIN
    SET @excludedchar = 0
    SET @excludeposition = 1
    
    WHILE @excludeposition <= DATALENGTH(@excludelist)  
    BEGIN
      IF ASCII(SUBSTRING(@text, @textposition, 1)) = ASCII(SUBSTRING(@excludelist, @excludeposition, 1))
      BEGIN
        SET @excludedchar = 1
        BREAK
      END
      SET @excludeposition = @excludeposition + 1  
    END
    IF @excludedchar = 0
      SET @buffer = @buffer + SUBSTRING(@text, @textposition, 1)
      
    SET @textposition = @textposition + 1  
  END
  
  RETURN @buffer
END
GO

GRANT EXEC ON qutl_remove_special_characters TO PUBLIC
GO