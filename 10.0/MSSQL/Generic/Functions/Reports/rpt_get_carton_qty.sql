
/****** Object:  UserDefinedFunction [dbo].[rpt_get_carton_qty]    Script Date: 03/24/2009 13:04:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_carton_qty') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_carton_qty
GO
CREATE FUNCTION [dbo].[rpt_get_carton_qty] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The rpt_get_carton_qty function is used to retrieve the Carton Quantity from the Binding Specs
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

go
Grant All on dbo.rpt_get_carton_qty  to Public
go
