SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_CartonQty]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_CartonQty]
GO





CREATE FUNCTION [dbo].[qweb_get_CartonQty] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The qweb_get_CartonQty function is used to retrieve the Carton Quantity from the Binding Specs
            table.   

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @i_cartonqty  	INT
DECLARE @RETURN		VARCHAR(23)




	
	SELECT @i_cartonqty = cartonqty1
	FROM   bindingspecs
	WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

		
	IF @i_cartonqty > 0  
                BEGIN
                      SELECT @RETURN = CAST(@i_cartonqty AS VARCHAR(23))
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

