/****** Object:  UserDefinedFunction [dbo].[rpt_get_title_task_date_by_Elementkey]    Script Date: 01/07/2015 13:45:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_title_task_date_by_Elementkey]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[rpt_get_title_task_date_by_Elementkey]
GO

/****** Object:  UserDefinedFunction [dbo].[rpt_get_title_task_date_by_Elementkey]    Script Date: 01/07/2015 13:45:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE FUNCTION [dbo].[rpt_get_title_task_date_by_Elementkey] (
	@i_bookkey INT
	,@i_datetypecode INT
	,@v_datetype VARCHAR
	,@v_dateversion VARCHAR
	)
	/* Returns the date for the passed bookkey and datetypecode selecting the column    
	specified in 3rd and 4th parameters @v_datetype,@v_dateversion. This function is for Version 7 and     
	retrieves date from new scheduling table taqprojecttask, rather than the original    
	task table  */

	--example: exec dbo.rpt_get_title_task_by_Elementkey(4890898,450,'A','F', 7018784)
	
	-- v_datetype = 'O' = original    
	-- v_datetype = 'A' = active    
	-- v_datetype = 'B' = best    
	
	-- v_dateversion = 'R' = the most recent element
	-- v_dateversion = 'I' =  the initial date of element
	
	
RETURNS DATETIME
AS
BEGIN
	DECLARE @d_date AS DATETIME
	DECLARE @RETURN AS DATETIME

	IF @v_dateversion = 'R'
	BEGIN
		SELECT TOP(1)@d_date = CASE 
				WHEN @v_datetype = 'O'
					THEN originaldate
				WHEN @v_datetype = 'A'
					THEN activedate
				WHEN @v_datetype = 'B' AND originaldate IS NOT NULL AND activedate IS NOT NULL
					THEN activedate
				WHEN @v_datetype = 'B' AND originaldate IS NULL AND activedate IS NOT NULL
					THEN activedate
				WHEN @v_datetype = 'B' AND originaldate IS NOT NULL AND activedate IS NULL
					THEN originaldate
				END
		FROM taqprojecttaskelement_view
		WHERE bookkey = @i_bookkey AND datetypecode = @i_datetypecode ORDER BY activedate DESC
	END

	IF @v_dateversion = 'I'
	BEGIN
		SELECT TOP(1)@d_date = CASE 
				WHEN @v_datetype = 'O'
					THEN originaldate
				WHEN @v_datetype = 'A'
					THEN activedate
				WHEN @v_datetype = 'B' AND originaldate IS NOT NULL AND activedate IS NOT NULL
					THEN activedate
				WHEN @v_datetype = 'B' AND originaldate IS NULL AND activedate IS NOT NULL
					THEN activedate
				WHEN @v_datetype = 'B' AND originaldate IS NOT NULL AND activedate IS NULL
					THEN originaldate
				END
		FROM taqprojecttaskelement_view
		WHERE bookkey = @i_bookkey AND datetypecode = @i_datetypecode ORDER BY activedate
	END
	

	IF @v_datetype IS NULL
	BEGIN
		SELECT @RETURN = ''
	END
	ELSE
	BEGIN
		SELECT @RETURN = @d_date
	END

	RETURN @RETURN
END


GO



GRANT ALL ON [dbo].[rpt_get_title_task_date_by_Elementkey] TO PUBLIC
GO