SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BestPageCount]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BestPageCount]
GO




CREATE FUNCTION [dbo].[qweb_get_BestPageCount] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The qweb_get_BestPageCount function is used to retrieve the best page count from the printing
            table.  The function first checks the client options and determine where the actual page
            count is stored - either the pagecount colum or the tmmpagecount columns.  It returns the
	    actual pagecount, unless these columns are blank, 0,or NULL - it then will use the tentativepagecount. 

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @s_pagecount  SMALLINT   -- actual page count
DECLARE @i_options    INT           -- Variable to get where actual trim size is stored
DECLARE @RETURN       VARCHAR(23)

 
/*  Get Page Count Configuration Option: 0 set Actual Page count to pagecount column; 1 sets Actual Page Count to tmmactualpagecount column	*/
	SELECT @i_options = optionvalue
        FROM   clientoptions
        WHERE  optionid = 4

 

	IF @i_options = 0
		BEGIN
			SELECT @s_pagecount = pagecount
                	FROM   printing
                	WHERE  bookkey = @i_bookkey 
						AND printingkey = @i_printingkey
	        END

            ELSE
                BEGIN
                      SELECT @s_pagecount = tmmpagecount
                      FROM   printing
                      WHERE  bookkey = @i_bookkey 
					AND printingkey = @i_printingkey
                END
 		

	IF @s_pagecount is NULL or @s_pagecount = 0
                BEGIN
                	SELECT @s_pagecount = tentativepagecount
                        FROM   printing
                        WHERE	bookkey = @i_bookkey
                        		AND printingkey = @i_printingkey
                END


	IF @s_pagecount > 0 
	  BEGIN
		SELECT @RETURN = CAST(@s_pagecount AS VARCHAR(23))
	  END
	ELSE
	  BEGIN
		SELECT @RETURN = ''
	  END


       RETURN @RETURN

END






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

