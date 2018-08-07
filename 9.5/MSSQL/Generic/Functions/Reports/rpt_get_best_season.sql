
/****** Object:  UserDefinedFunction [dbo].[rpt_get_best_season]    Script Date: 03/24/2009 12:52:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_best_season') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_best_season
GO
CREATE FUNCTION [dbo].[rpt_get_best_season] 
            (@i_bookkey 	INT,
             @i_printingkey 	INT,
		     @v_column		CHAR(1))
		

 
/*        
            The parameters are for the book key and printing key.  

	Parameter Options -
		@v_column
			D = Season Description
			S = Season Short Description

*/

RETURNS VARCHAR(40)

AS  

BEGIN 

DECLARE @i_seasonkey		INT
DECLARE @i_estseasonkey		INT
DECLARE @v_season		VARCHAR(40)
DECLARE @RETURN       		VARCHAR(40)

 

	SELECT @i_seasonkey = seasonkey,
		@i_estseasonkey = estseasonkey
	FROM printing
	WHERE bookkey = @i_bookkey
			AND printingkey = @i_printingkey


	IF UPPER(@v_column) = 'D'
		BEGIN
			IF COALESCE(@i_seasonkey,0) > 0
				BEGIN
					SELECT @v_season = seasondesc
					FROM season
					WHERE seasonkey = @i_seasonkey
				END
			ELSE
				BEGIN
					SELECT @v_season = seasondesc
					FROM season
					WHERE seasonkey = @i_estseasonkey 
				END
		END

	IF UPPER(@v_column) = 'S'
		BEGIN
			IF COALESCE(@i_seasonkey,0) > 0
				BEGIN
					SELECT @v_season = seasonshortdesc
					FROM season
					WHERE seasonkey = @i_seasonkey
				END
			ELSE
				BEGIN
					SELECT @v_season = seasonshortdesc
					FROM season
					WHERE seasonkey = @i_estseasonkey 
				END
		END

SELECT @RETURN = COALESCE(@v_season,'')

	

            RETURN @RETURN

END
go
Grant All on dbo.rpt_get_best_season to Public
go