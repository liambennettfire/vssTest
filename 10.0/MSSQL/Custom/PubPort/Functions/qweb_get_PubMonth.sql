SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_PubMonth]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_PubMonth]
GO




CREATE FUNCTION [dbo].[qweb_get_PubMonth] 
            (@i_bookkey INT,
            @i_printingkey INT,
		@v_datepart varchar(1))
		

 
/*          The qweb_get_PubMonth function is used to retrieve the either the Pub Month or Year depending on the datepart specified.
		This function does not pull from the pub date but is the rough equivalent to the Pub Month & Year found in TMM 

            The parameters are for the book key and printing key and datepart where the valid values are:
		'M' - Month
		'Y' - Year

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @i_pubmonthcode    	INT   
DECLARE	@d_pubmonth		DATETIME     
DECLARE @RETURN       		VARCHAR(23)

 

       	SELECT @i_pubmonthcode = pubmonthcode,
		@d_pubmonth=pubmonth
        FROM   printing
        WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

	IF @v_datepart = 'M' -- get pubmonth
		BEGIN
			IF @i_pubmonthcode = 1
				BEGIN
					SELECT @RETURN = 'January'
				END
			ELSE IF @i_pubmonthcode = 2	
				BEGIN
					SELECT @RETURN = 'February'
				END
			ELSE IF @i_pubmonthcode = 3	
				BEGIN
					SELECT @RETURN = 'March'
				END
			ELSE IF @i_pubmonthcode = 4	
				BEGIN
					SELECT @RETURN = 'April'
				END
			ELSE IF @i_pubmonthcode = 5	
				BEGIN
					SELECT @RETURN = 'May'
				END
			ELSE IF @i_pubmonthcode = 6	
				BEGIN
					SELECT @RETURN = 'June'
				END
			ELSE IF @i_pubmonthcode = 7	
				BEGIN
					SELECT @RETURN = 'July'
				END
			ELSE IF @i_pubmonthcode = 8	
				BEGIN
					SELECT @RETURN = 'August'
				END
			ELSE IF @i_pubmonthcode = 9	
				BEGIN
					SELECT @RETURN = 'September'
				END
			ELSE IF @i_pubmonthcode = 10	
				BEGIN
					SELECT @RETURN = 'October'
				END
			ELSE IF @i_pubmonthcode = 11	
				BEGIN
					SELECT @RETURN = 'November'
				END
			ELSE IF @i_pubmonthcode = 12	
				BEGIN
					SELECT @RETURN = 'December'
				END
			ELSE 	
				BEGIN
					SELECT @RETURN = ''
				END
            	END

	ELSE IF @v_datepart = 'Y' -- get pubyear
                BEGIN
                      SELECT @RETURN = CAST(YEAR(@d_pubmonth) as varchar (4))
                END
	ELSE 
                BEGIN
                      SELECT @RETURN = 'invalid parameter'
                END

	IF @RETURN is NULL
	  BEGIN
	         SELECT @RETURN=''
	  END

	RETURN @RETURN

END










GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

