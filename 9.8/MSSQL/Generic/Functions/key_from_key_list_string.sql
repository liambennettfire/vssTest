PRINT 'USER FUNCTION   : key_from_key_list_string'
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[key_from_key_list_string]') and xtype in (N'FN', N'IF', N'TF'))
BEGIN
		PRINT 'Dropping Function key_from_key_list_string'
        drop function [dbo].[key_from_key_list_string]
END
GO


/******************************************************************************
**		File: key_from_key_list_string.sql 
**		Name: key_from_key_list_string
**		Desc: This extracts a key a list of strings that are in a string.
**    
**     The format : "bookkey,334432,elphkey,334224,authorkey,344223,"
**
** Notice that the string is formed to be easy to create and easy to parse. The
** string has a comma at the end so that the new items can be added 
** consistently from the beginning.  No spaces are added to save space and
** to save on trimming them.   
**
**		Return values: int (zero indicates that a key was not found).
** 
**		Parameters:
**		Input                      Description   
**    ----------                 -----------
**    @i_key_list_string         See above
**
**
**		Auth: James P. Weber
**		Date: 07 May 2004
**
*******************************************************************************
**		Change History
*******************************************************************************
**	Date:          Author:                  Description:
**	-----------    --------------------     -------------------------------------------
**  06 May 2004    Jim Weber                Inital Creation
*******************************************************************************/


PRINT 'Creating Function key_from_key_list_string'
GO

CREATE FUNCTION key_from_key_list_string
    ( @i_key_list_string as varchar(MAX),
      @i_key_name as varchar(256) ) 

RETURNS int

BEGIN 
  DECLARE @KeyAsString  varchar(100)
  DECLARE @Key          int
  DECLARE @KeyNameIndex int  -- Reused as the start index for the key.
  DECLARE @ENDKeyIndex  int

  SET @Key = 0
  
  SET @KeyNameIndex = CHARINDEX(@i_key_name, @i_key_list_string)
  IF @KeyNameIndex is not null and  @KeyNameIndex <> 0
  BEGIN
    SET @KeyNameIndex = @KeyNameIndex + LEN(@i_key_name) + 1
    SET @ENDKeyIndex = CHARINDEX(',', @i_key_list_string, @KeyNameIndex)
    SET @KeyAsString = SUBSTRING(@i_key_list_string, @KeyNameIndex, @ENDKeyIndex - @KeyNameIndex)
    SET @Key = CONVERT(int, @KeyAsString)
  END
  
  RETURN @Key
END
GO

SET QUOTED_IDENTIFIER OFF 
GO

SET ANSI_NULLS ON 
GO

GRANT EXEC ON key_from_key_list_string TO PUBLIC
GO

PRINT 'USER FUNCTION   : key_from_key_list_string complete'
GO


 