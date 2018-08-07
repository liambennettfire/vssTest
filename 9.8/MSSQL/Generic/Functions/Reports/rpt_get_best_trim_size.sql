
/****** Object:  UserDefinedFunction [dbo].[rpt_get_best_trim_size]    Script Date: 03/24/2009 13:00:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_best_trim_size') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_best_trim_size
GO
CREATE FUNCTION [dbo].[rpt_get_best_trim_size] 
            (@i_bookkey INT,
            @i_printingkey INT)
		

 
/*          The rpt_get_best_trim_size function is used to retrieve the best trim size from the printing
            table.  The function first checks the client options and determine where the actual trim
            size is stored - either the trim width/length colums or the tmm actual width/length 
            columns.  It returns the  the actual trim, unless these columns are blank
             or NULL, and will use the estimated trim. 

            The parameters are for the book key and printing key.  

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @v_width      VARCHAR(10)   -- actual trim width
DECLARE @v_length     VARCHAR(10)   -- actual trim length
DECLARE @v_x          VARCHAR(3)    -- Constant ' x ' for concatenating width and length
DECLARE @i_options    INT           -- Variable to get where actual trim size is stored
DECLARE @RETURN       VARCHAR(23)

 

	SELECT @v_x = ' x '

	SELECT @i_options = optionvalue
        FROM   clientoptions
        WHERE  optionid = 7

 

	IF @i_options = 0
            BEGIN
            	SELECT @v_width = ltrim(rtrim(trimsizewidth)),
			@v_length = ltrim(rtrim(trimsizelength))
                FROM   printing
                WHERE  bookkey = @i_bookkey and printingkey = @i_printingkey

		
            END

            ELSE
                BEGIN
                      SELECT @v_width = ltrim(rtrim(tmmactualtrimwidth)),
                             @v_length = ltrim(rtrim(tmmactualtrimlength))
                      FROM   printing
                      WHERE  bookkey = @i_bookkey 
					AND printingkey = @i_printingkey
                END
 		

            IF @v_width<> '' OR @v_length<>''
                BEGIN
                	SELECT @RETURN = @v_width + ' x ' +@v_length
                END

            ELSE
                BEGIN
                	SELECT @RETURN = ltrim(rtrim(esttrimsizewidth))+ @v_x + ltrim(rtrim(esttrimsizelength))
                        FROM   printing
                        WHERE	bookkey = @i_bookkey
                        		AND printingkey = @i_printingkey
                END

            RETURN @RETURN

END

go
Grant All on dbo.rpt_get_best_trim_size to Public
go