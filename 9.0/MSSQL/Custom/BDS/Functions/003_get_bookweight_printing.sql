SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***********************************************************************************************************************/
/*		Author:		Kusum Basra                                                                                                                                                                                                 */
/*	 	Date created : 03/31/10                                                                                                                                                                                                   */
/*                                                                                                                                                                                                                                           */
/***********************************************************************************************************************/

CREATE FUNCTION [dbo].[get_bookweight_printing] 
            (@i_bookkey INT,
              @i_printingkey INT)
 
/*          The get_bookweight function is used to retrieve the bookweight from the printing  table.   

            The parameters are for the bookkey and printingkey.  */

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @i_bookweight  	float
DECLARE @RETURN		VARCHAR(23)

	
	SELECT @i_bookweight = bookweight
	FROM   printing
	WHERE  bookkey = @i_bookkey
          AND printingkey = @i_printingkey

		
	IF @i_bookweight > 0  
                BEGIN
                      SELECT @RETURN = CAST(@i_bookweight AS VARCHAR(23))
                END
 	ELSE
                BEGIN
                      SELECT @RETURN = ''
                END



            RETURN @RETURN

END








