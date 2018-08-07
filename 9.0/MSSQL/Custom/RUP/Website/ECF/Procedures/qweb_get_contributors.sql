USE [RUP]
GO

/****** Object:  UserDefinedFunction [dbo].[qweb_get_Contributors]    Script Date: 11/26/2012 13:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[qweb_get_Contributors] 
            	(@i_bookkey 	INT)
		

 
/*      The qweb_get_Contributors function is used (created for RUP) to obtain a comma seperated list of all
			contributors for a specific bookkey
*/

RETURNS VARCHAR(8000)

AS  

BEGIN 
	
	DECLARE @RETURN       		VARCHAR(8000),
					@FIRSTNAME				VARCHAR(75),
					@LASTNAME					VARCHAR(75)
	
	SET @RETURN = ''
	
	DECLARE author_cursor CURSOR FAST_FORWARD FOR
	SELECT a.firstname, a.lastname
	FROM author a
	JOIN bookauthor b
	ON (a.authorkey = b.authorkey)
	WHERE b.bookkey = @i_bookkey
		AND b.authortypecode = 21
		
	OPEN author_cursor
	
	FETCH NEXT FROM author_cursor 
	INTO @FIRSTNAME, @LASTNAME
	
	WHILE @@FETCH_STATUS = 0
  BEGIN
		IF @FIRSTNAME IS NOT NULL AND LEN(@FIRSTNAME) > 0
		BEGIN
			IF LEN(@RETURN) > 0
			BEGIN
				SET @RETURN = @RETURN + ', '
			END
			SET @RETURN = @RETURN + @FIRSTNAME
			
			IF @LASTNAME IS NOT NULL AND LEN(@LASTNAME) > 0
			BEGIN
				SET @RETURN = @RETURN + ' ' + @LASTNAME
			END
		END
		
		FETCH NEXT FROM author_cursor 
		INTO @FIRSTNAME, @LASTNAME
  END
  
  CLOSE author_cursor
  DEALLOCATE author_cursor

	RETURN @RETURN

END

GO