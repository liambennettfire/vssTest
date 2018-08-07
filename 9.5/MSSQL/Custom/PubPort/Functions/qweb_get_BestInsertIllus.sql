SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BestInsertIllus]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BestInsertIllus]
GO




CREATE FUNCTION [dbo].[qweb_get_BestInsertIllus] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The qweb_get_BestInsertIllus function is used to retrieve the best Announcded First Print Quantity from the printing
            table.  It returns the actual insert/illus, unless these columns are blank
             or NULL, and will use the estimated insert/illus. 

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(255)

AS  

BEGIN 

DECLARE @v_actInsertIllus	VARCHAR(255)
DECLARE @v_estInsertIllus	VARCHAR(255)
DECLARE @RETURN			VARCHAR(255)





	SELECT @v_actInsertIllus = actualinsertillus,
		@v_estInsertIllus = estimatedinsertillus
	FROM   printing
	WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

		
	IF len(@v_actInsertIllus) > 0  
                BEGIN
                      SELECT @RETURN = @v_actInsertIllus
                END
 	ELSE
                BEGIN
                      SELECT @RETURN = @v_estInsertIllus
                END



            RETURN @RETURN

END




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

