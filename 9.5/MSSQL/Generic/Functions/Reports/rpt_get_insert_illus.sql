
/****** Object:  UserDefinedFunction [dbo].[rpt_get_insert_illus]    Script Date: 03/24/2009 13:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_insert_illus') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_insert_illus
GO


CREATE FUNCTION [dbo].[rpt_get_insert_illus] 
            (@i_bookkey INT,
            @i_printingkey INT,
			@c_EstActBest char (1))
		

 
/*          The rpt_get_insert_illus function is used to retrieve 
the InsertIllus from the printing table.  It returns the est, actual or 
best based on the parameter, unless these columns are blank
             or NULL. 

The parameters are:
bookkey
printing key
@c_EstActBest: 'E' = Est, 'A'=Actual, 'B'=Best  

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

if @c_EstActBest = 'B'
Begin		
	IF len(@v_actInsertIllus) > 0  
                BEGIN
                      SELECT @RETURN = @v_actInsertIllus
                END
 	ELSE
                BEGIN
                      SELECT @RETURN = @v_estInsertIllus
                END
End

if @c_EstActBest = 'E'
Begin
	SELECT @RETURN = @v_estInsertIllus		
End

if @c_EstActBest = 'A'
Begin
	SELECT @RETURN = @v_actInsertIllus		
End

RETURN @RETURN

END
go
Grant All on dbo.rpt_get_insert_illus to Public
go