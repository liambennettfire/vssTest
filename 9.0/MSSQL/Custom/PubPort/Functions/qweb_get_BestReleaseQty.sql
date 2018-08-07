SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BestReleaseQty]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BestReleaseQty]
GO




CREATE FUNCTION [dbo].[qweb_get_BestReleaseQty] 
            (@i_bookkey INT)
		

 
/*          The qweb_get_BestReleaseQty looks to the printing table and gets either the FirstPrintQuantity(actual release qty) or the 
		tentative release quantity (estimated) whichever is 'best'

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @i_actreleaseqty      INT   -- actual release quantity
DECLARE @i_estreleaseqty      INT   -- estimated release quantity
DECLARE @RETURN       VARCHAR(23)

 

       	SELECT @i_estreleaseqty = tentativeqty, @i_actreleaseqty = firstprintingqty
                FROM   printing
                WHERE  bookkey = @i_bookkey and printingkey = 1

		
            IF @i_actreleaseqty > 0
                BEGIN
 			SELECT @RETURN = CAST(@i_actreleaseqty as varchar (23)) 
                END
	    ELSE IF @i_estreleaseqty > 0
		BEGIN
			SELECT @RETURN = CAST(@i_estreleaseqty as varchar (23))
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

