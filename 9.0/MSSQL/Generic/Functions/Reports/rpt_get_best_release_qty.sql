
/****** Object:  UserDefinedFunction [dbo].[rpt_get_best_release_qty]    Script Date: 03/24/2009 12:52:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_best_release_qty') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_best_release_qty
GO
CREATE FUNCTION [dbo].[rpt_get_best_release_qty] 
            (@i_bookkey INT)
		

 
/*          The rpt_get_best_release_qty looks to the printing table and gets either the FirstPrintQuantity(actual release qty) or the 
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

go
Grant All on dbo.rpt_get_best_release_qty to Public
go