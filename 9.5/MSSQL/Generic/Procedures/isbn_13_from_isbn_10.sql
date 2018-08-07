PRINT 'STORED PROCEDURE : isbn_13_from_isbn_10'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'isbn_13_from_isbn_10')
	BEGIN
		PRINT 'Dropping Procedure isbn_13_from_isbn_10'
		DROP  Procedure  isbn_13_from_isbn_10
	END

GO

PRINT 'Creating Procedure isbn_13_from_isbn_10'
GO
CREATE Procedure isbn_13_from_isbn_10
(
	@i_isbn10             varchar(10),
	@o_isbn13             varchar(13) output,
    @o_error_code         int         output,
    @o_error_desc         char(200)   output 
)
AS

/******************************************************************************
**		File: isbn_13_from_isbn_10.sql
**		Name: isbn_13_from_isbn_10
**		Desc: This stored procedure is designed to create the 
**            isbn with the dashes (13 digit) from the 10 digit
**            form using the algorithm that is based on the
**            information provided by the isbn.org website.
**
**		This template can be customized:
**              
**		Return values:
** 
**		Called by:   
**              
**		Parameters:
**		Input							Output
**     ----------							-----------
**
**		Auth: 
**		Date: 
*******************************************************************************
**		Change History
*******************************************************************************
**		Date:		Author:				Description:
**      --------    --------            -------------------------------------------
**      10 Jun 2003 Jim Weber           Initial Creation
*******************************************************************************/

BEGIN

  SET IMPLICIT_TRANSACTIONS OFF
 
  DECLARE @varcharGroupIdentifier  varchar(1);
  DECLARE @varcharCheckSum         varchar(1);
  DECLARE @intErr                  int;
  DECLARE @intPartialISBN          int; -- Used to find separation point.
  DECLARE @intMiddleHyphen         int;
  
  -- When debugging look at the initial value.
  --print '@i_isbn10:               = ' + @i_isbn10
  
  set @varcharGroupIdentifier = SUBSTRING(@i_isbn10, 1, 1);
  set @varcharCheckSum        = SUBSTRING(@i_isbn10, 10, 1);
  set @o_error_code = 0;
  set @o_error_desc = '';
  set @intMiddleHyphen = 0;
  set @intErr = 0;
  
  -- Look at the extracted values
  --print '@varcharGroupIdentifier: = ' + @varcharGroupIdentifier
  --print '@varcharCheckSum:        = ' + @varcharCheckSum

  -- The algorithm for group 0 and group 1 is much different.
  if (@varcharGroupIdentifier = '0')
  begin
--    print 'Group 0'
    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 2)) 
    if @intPartialISBN <= 19
    BEGIN
	SET @intMiddleHyphen = 3;
    END

    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 3)) 
    if @intPartialISBN <= 699 AND @intMiddleHyphen = 0
    BEGIN
      SET @intMiddleHyphen = 4;
    END
  
    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 4)) 
    if @intPartialISBN <= 8499 AND @intMiddleHyphen = 0
    BEGIN
      SET @intMiddleHyphen = 5;
    END

     Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 5)) 
    if @intPartialISBN <= 89999 AND @intMiddleHyphen = 0
    BEGIN
      SET @intMiddleHyphen = 6;
    END
 
    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 6)) 
    if @intPartialISBN <= 949999 AND @intMiddleHyphen = 0
    BEGIN
      SET @intMiddleHyphen = 7;
    END

    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 7)) 
    if @intPartialISBN <= 9999999 AND @intMiddleHyphen = 0
    BEGIN
      SET @intMiddleHyphen = 8;
    END

  end
  
  if (@varcharGroupIdentifier = '1')
  begin
--    print 'Group 1'
    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 2)) 
    if @intPartialISBN <= 9
    BEGIN
	SET @intMiddleHyphen = 3;
    END

    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 3)) 
    if @intPartialISBN <= 399 AND @intMiddleHyphen = 0
    BEGIN
      SET @intMiddleHyphen = 4;
    END
  
    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 4)) 
    if @intPartialISBN <= 5499 AND @intMiddleHyphen = 0
    BEGIN
      SET @intMiddleHyphen = 5;
    END

    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 5)) 
    if @intPartialISBN <= 86979 AND @intMiddleHyphen = 0
    BEGIN
      SET @intMiddleHyphen = 6;
    END
 
    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 6)) 
    if @intPartialISBN <= 998999 AND @intMiddleHyphen = 0
    BEGIN
      SET @intMiddleHyphen = 7;
    END

    Set @intPartialISBN = CONVERT(int, SUBSTRING(@i_isbn10, 2, 7)) 
    if @intPartialISBN <= 9999999 AND @intMiddleHyphen = 0
    BEGIN
      SET @intMiddleHyphen = 8;
    END

  end

  SELECT  @o_isbn13 = @varcharGroupIdentifier + '-'+ SUBSTRING(@i_isbn10, 2, @intMiddleHyphen-1) + '-'+ SUBSTRING(@i_isbn10, @intMiddleHyphen+1, 9-@intMiddleHyphen) + '-' + @varcharCheckSum

  
  SET @intErr = @@ERROR
  IF @intErr <> 0 BEGIN
    SET @intErr = 1
    GOTO ExitHandler
  END


ExitHandler:

  RETURN @intErr;

END

GO

GRANT EXEC ON isbn_13_from_isbn_10 TO PUBLIC
GO

PRINT 'STORED PROCEDURE : isbn_13_from_isbn_10 complete'
GO

 