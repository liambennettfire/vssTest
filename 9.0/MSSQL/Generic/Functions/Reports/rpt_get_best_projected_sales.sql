
/****** Object:  UserDefinedFunction [dbo].[rpt_get_best_projected_sales]    Script Date: 03/24/2009 12:50:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_best_projected_sales') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_best_projected_sales
GO
CREATE FUNCTION [dbo].[rpt_get_best_projected_sales] 
            	(@i_bookkey 	INT,
@i_printingkey int)
		

 
/*      This function will return the projectedsales or estprojectedsale for 
the bookkey and printingkey passed 

The parameters are:
book key, 
printingkey
*/

RETURNS INT

AS  

BEGIN 

DECLARE @i_estprojectedsales int
DECLARE @i_actprojectedsales int
DECLARE @RETURN       		INT

 

SELECT @i_estprojectedsales = estprojectedsales,
	@i_actprojectedsales = projectedsales
FROM printing
WHERE bookkey = @i_bookkey 
	AND printingkey = @i_printingkey


	if coalesce (@i_actprojectedsales,0) > 0
	begin
		select @RETURN = @i_actprojectedsales
	end
	else if coalesce (@i_estprojectedsales,0) > 0 /*Act doesn't exist */
	begin
		select @RETURN = @i_estprojectedsales
	end
 	ELSE -- IF both est and act are null
		BEGIN
			SELECT @RETURN = NULL
		END	

RETURN @RETURN

END
go
Grant All on dbo.rpt_get_best_projected_sales to Public
go