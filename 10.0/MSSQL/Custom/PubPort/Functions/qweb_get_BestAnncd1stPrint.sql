SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BestAnncd1stPrint]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BestAnncd1stPrint]
GO




CREATE FUNCTION [dbo].[qweb_get_BestAnncd1stPrint] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The qweb_get_BestAnncd1stPrint function is used to retrieve the best Announcded First Print Quantity from the printing
            table.  It returns the actual announced first print, unless these columns are blank
             or NULL, and will use the estimated announced first print. 

            The parameters are for the book key and printing key.  

*/

RETURNS INT

AS  

BEGIN 

DECLARE @i_actfirstprint	INT
DECLARE @i_estfirstprint	INT
DECLARE @RETURN			INT





	SELECT @i_actfirstprint = announcedfirstprint,
		@i_estfirstprint = estannouncedfirstprint
	FROM   printing
	WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

		
	IF @i_actfirstprint > 0  
                BEGIN
                      SELECT @RETURN = @i_actfirstprint
                END
 	ELSE
                BEGIN
                      SELECT @RETURN = @i_estfirstprint
                END



            RETURN @RETURN

END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

