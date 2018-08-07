
/****** Object:  UserDefinedFunction [dbo].[rpt_get_best_announced_1st_print]    Script Date: 03/24/2009 11:53:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_best_announced_1st_print') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_best_announced_1st_print
GO
CREATE FUNCTION [dbo].[rpt_get_best_announced_1st_print] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The rpt_get_best_announced_1st_print function is used to retrieve the best Announcded First Print Quantity from the printing
            table.  It returns the actual announced first print, unless these columns are blank
             or NULL, and will use the estimated announced first print. 

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(20)

AS  

BEGIN 

DECLARE @i_actfirstprint	INT
DECLARE @i_estfirstprint	INT
DECLARE @RETURN		VARCHAR(20)





	SELECT @i_actfirstprint = announcedfirstprint,
		@i_estfirstprint = estannouncedfirstprint
	FROM   printing
	WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

		
	IF @i_actfirstprint > 0  
                BEGIN
                      SELECT @RETURN = COALESCE(CONVERT(VARCHAR(20),@i_actfirstprint),'')
                END
 	ELSE
                BEGIN
                      SELECT @RETURN = COALESCE(CONVERT(VARCHAR(20),@i_estfirstprint),'')
                END



            RETURN @RETURN

END
go
Grant All on dbo.rpt_get_best_announced_1st_print to Public
go