PRINT 'USER FUNCTION   : date_from_onix_datestring'
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[date_from_onix_datestring]') and xtype in (N'FN', N'IF', N'TF'))
BEGIN
		PRINT 'Dropping Function date_from_onix_datestring'
        drop function [dbo].[date_from_onix_datestring]
END
GO


/******************************************************************************
**		File: date_from_onix_datestring.sql 
**		Name: date_from_onix_datestring
**		Desc: This function returns a date when given a date field in ONIX format.
**
**		Return values: Date value.
** 
**		Parameters:
**		Input                      Description   
**      ----------                 -----------
**      @i_onix_date_string        A string with the following format
**                                 'YYYYMMDD'
**
**
**		Auth: James P. Weber
**		Date: 24 July 2003
**
*******************************************************************************
**		Change History
*******************************************************************************
**	Date:          Author:                  Description:
**	-----------    --------------------     -------------------------------------------
**  24 JUL 2003    Jim Weber                Inital Creation
*******************************************************************************/


PRINT 'Creating Function date_from_onix_datestring'
GO

CREATE FUNCTION date_from_onix_datestring
    ( @i_onix_date_string as varchar(30) ) 

RETURNS datetime

BEGIN 
  DECLARE @o_date datetime;
  DECLARE @Year  varchar(4);
  DECLARE @Month varchar(2);
  DECLARE @Day   varchar(2);
  
  SET @o_date = null;
  
  if (@i_onix_date_string is not null)
  BEGIN
    SET @Year  =  LTRIM(SUBSTRING(@i_onix_date_string, 1, 4));
    SET @Month =  LTRIM(SUBSTRING(@i_onix_date_string, 5, 2));
    SET @Day   =  LTRIM(SUBSTRING(@i_onix_date_string, 7, 2));
    
    if (@Year = '') SET @Year = null;

    if @Year is not null 
    BEGIN

      if @Month is null or @Month = '' SET @Month = '01';
      if @Day is null or @Day = '' SET @Day = '01';
   
      SET @o_date = @Month + '/' + @Day + '/' + @Year;

    END
  END  


  RETURN @o_date
END
GO

SET QUOTED_IDENTIFIER OFF 
GO

SET ANSI_NULLS ON 
GO

GRANT EXEC ON date_from_onix_datestring TO PUBLIC
GO

PRINT 'USER FUNCTION   : date_from_onix_datestring complete'
GO


