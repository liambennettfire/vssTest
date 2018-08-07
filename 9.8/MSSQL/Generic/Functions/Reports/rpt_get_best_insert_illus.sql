
/****** Object:  UserDefinedFunction [dbo].[rpt_get_best_insert_illus]    Script Date: 03/24/2009 12:49:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_best_insert_illus') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_best_insert_illus
GO
CREATE FUNCTION [dbo].[rpt_get_best_insert_illus] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The rpt_get_best_insert_illus function is used to retrieve the best Announcded First Print Quantity from the printing
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

go
Grant All on dbo.rpt_get_best_insert_illus to Public
go