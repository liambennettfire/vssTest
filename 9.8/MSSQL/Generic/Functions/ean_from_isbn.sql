 PRINT 'USER FUNCTION   : ean_from_isbn'
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ean_from_isbn]') and xtype in (N'FN', N'IF', N'TF'))
BEGIN
		PRINT 'Dropping Function ean_from_isbn'
        drop function [dbo].[ean_from_isbn]
END
GO


/******************************************************************************
**		File: ean_from_isbn.sql 
**		Name: ean_from_isbn
**		Desc: This function returns a date when given a date field in ONIX format.
**
**		Return values: Date value.
** 
**		Parameters:
**		Input                      Description   
**      ----------                 -----------
**      @i_isbn                    A string with the following format
**                                 '01234565789' or '0-1234-5678-9
**
**
**		Auth: James P. Weber
**		Date: 14 Oct 2003
**
*******************************************************************************
**		Change History
*******************************************************************************
**	Date:          Author:                  Description:
**	-----------    --------------------     -------------------------------------------
**  14 Oct 2003    Jim Weber                Inital Creation
*******************************************************************************/


PRINT 'Creating Function ean_from_isbn'
GO

CREATE FUNCTION ean_from_isbn
    ( @i_isbn as varchar(13)  -- Accept an ISBN with Dashes 
    ) 
    
RETURNS varchar(17)

-- The string returned will have the orginal dashes if they exist, or all dashes
-- will be stripped out if the ISBN is not valid.  If the input is not 10 or 13 
-- characters, the function will return null to indicate an error.

BEGIN 
  DECLARE @v_isbn10  varchar(10);
  DECLARE @v_isbn_main  varchar(9);
  DECLARE @v_ean_main varchar(12);
  DECLARE @v_ean_final varchar(17);
  DECLARE @v_position int;
  DECLARE @v_current_character varchar(1);
  DECLARE @v_current_number int;
  DECLARE @v_current_checksum int;
  DECLARE @v_check_digit int;
  
  if (len(@i_isbn) = 10)
  BEGIN
    SET @v_isbn10 = @i_isbn;
    SET @v_ean_final = '978' + @i_isbn;
  END
  else
  BEGIN
    SET @v_isbn10 = replace(@i_isbn, '-', '');
    SET @v_ean_final = '978-' + SUBSTRING(@i_isbn, 1, 12);
  END
  
  SET @v_ean_main = '978' + SUBSTRING(@v_isbn10, 1, 9);
  SET @v_position = 1;
  SET @v_current_checksum = 0;
  
  
  WHILE (@v_position < 13)
  BEGIN
    SET @v_current_character = SUBSTRING(@v_ean_main, @v_position, 1); 
    SET @v_current_number    = CONVERT(int, @v_current_character); 
    if (@v_position %2 = 0)
    BEGIN
      SET @v_current_checksum = @v_current_checksum + ( 3 * @v_current_number);
    END
    ELSE
    BEGIN
      SET @v_current_checksum = @v_current_checksum + @v_current_number;
    END
    -- PRINT @v_current_character;
    SET @v_position = @v_position + 1;
  END

  SET @v_check_digit = 10 - @v_current_checksum % 10;

  RETURN @v_ean_final + CONVERT(varchar, @v_check_digit);

END
GO

SET QUOTED_IDENTIFIER OFF 
GO

SET ANSI_NULLS ON 
GO

GRANT EXEC ON ean_from_isbn TO PUBLIC
GO

PRINT 'USER FUNCTION   : ean_from_isbn complete'
GO


