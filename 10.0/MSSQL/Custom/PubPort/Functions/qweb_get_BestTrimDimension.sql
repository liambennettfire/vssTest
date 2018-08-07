SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_BestTrimDimension]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_BestTrimDimension]
GO




CREATE FUNCTION [dbo].[qweb_get_BestTrimDimension] 
           (@i_bookkey INT,
            @i_printingkey INT,
		@v_dimension varchar(1)) 

		

 
/*          The qweb_get_BestTrimDimension function is used to retrieve the best trim Length or Width from the printing
            table.  The function first checks the client options and determine where the actual trim
            size is stored - either the trim width/length colums or the tmm actual width/length 
            columns.  It returns the  the actual trim, unless these columns are blank
             or NULL, and will use the estimated trim. 

            The parameters are for the book key and printing key and dimension where the valid values are:
		'W' - Width
		'L' - Height or length
		'S' - Spine Size

*/

RETURNS VARCHAR(23)

AS  

BEGIN 

DECLARE @v_width      VARCHAR(10)   --  trim width
DECLARE @v_length     VARCHAR(10)   --  trim length
DECLARE @v_spine      VARCHAR(15)   -- spine size
DECLARE @i_options    INT           -- Variable to get where actual trim size is stored
DECLARE @RETURN       VARCHAR(23)


 	SET @v_width = ''
	SET @v_length=''
	SET @v_spine=''

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
 		

         IF (@v_width= '')or (@v_width is null) OR (@v_length='') or (@v_length is null) -- get estimated columns
             BEGIN
               	SELECT @v_width = ltrim(rtrim(esttrimsizewidth)),
                             	@v_length = ltrim(rtrim(esttrimsizelength))
                FROM   printing
                WHERE	bookkey = @i_bookkey
                        		AND printingkey = @i_printingkey
             END



        IF @v_dimension = 'W'
		BEGIN
			SELECT @RETURN = @v_width 
		END
	ELSE IF @v_dimension = 'L'
		BEGIN
			SELECT @RETURN = @v_length 
		END
	ELSE IF @v_dimension = 'S'
		BEGIN
 
 	               	SELECT @v_spine = ltrim(rtrim(spinesize))
		                        FROM   printing
 		                       WHERE	bookkey = @i_bookkey
 		                       		AND printingkey = @i_printingkey
			SELECT @RETURN = @v_spine 
		END
	ELSE
		BEGIN
			SELECT @RETURN = 'invalid parameter' 
		END
 
            RETURN @RETURN


END













GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

