
/****** Object:  UserDefinedFunction [dbo].[rpt_get_pub_month]    Script Date: 03/24/2009 13:14:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_pub_month') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_pub_month
GO
CREATE FUNCTION [dbo].[rpt_get_pub_month] 
            (@i_bookkey INT,
            @i_printingkey INT,
		@v_datepart varchar(1))
		

 
/*          The rpt_get_pub_month function is used to retrieve the either the Pub Month or Year depending on the datepart specified.
		This function does not pull from the pub date but is the rough equivalent to the Pub Month & Year found in TMM 

            The parameters are for the book key and printing key and datepart where the valid values are:
		'M' - Month
		'S' - Short Pub Month
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
	ELSE IF @v_datepart = 'S' -- get Short pubmonth
		BEGIN
			IF @i_pubmonthcode = 1
				BEGIN
					SELECT @RETURN = 'Jan'
				END
			ELSE IF @i_pubmonthcode = 2	
				BEGIN
					SELECT @RETURN = 'Feb'
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
					SELECT @RETURN = 'Aug'
				END
			ELSE IF @i_pubmonthcode = 9	
				BEGIN
					SELECT @RETURN = 'Sep'
				END
			ELSE IF @i_pubmonthcode = 10	
				BEGIN
					SELECT @RETURN = 'Oct'
				END
			ELSE IF @i_pubmonthcode = 11	
				BEGIN
					SELECT @RETURN = 'Nov'
				END
			ELSE IF @i_pubmonthcode = 12	
				BEGIN
					SELECT @RETURN = 'Dec'
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
go
Grant All on dbo.rpt_get_pub_month to Public
go