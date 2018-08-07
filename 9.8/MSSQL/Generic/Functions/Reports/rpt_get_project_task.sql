
/****** Object:  UserDefinedFunction [dbo].[rpt_get_project_task]    Script Date: 03/24/2009 13:14:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_project_task') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_project_task
GO



CREATE FUNCTION [dbo].[rpt_get_project_task] 
            	(@i_taqprojectkey 	INT,
            	@i_datetypecode int,
				@v_datetype varchar)
		

 /** Returns the date for the passed projectkey and datetypecode, selecting the column
specified in 3rd parameter @v_datetype. This function is for Version 7 and 
retrieves date from new scheduling table taqprojecttask, rather than the original
task table  **/

				-- v_datetype = 'O' = original
				-- v_datetype = 'A' = active
				-- v_datetype = 'B' = best

RETURNS datetime

AS  



BEGIN 


DECLARE @d_date as datetime
DECLARE @RETURN as datetime

Select @d_date = 
	case 
	when @v_datetype = 'O' THEN originaldate
	when @v_datetype = 'A' THEN activedate
	when @v_datetype = 'B' and originaldate is not null and activedate is not null THEN activedate
	when @v_datetype = 'B' and originaldate is null and activedate is not null THEN activedate
	when @v_datetype = 'B' and originaldate is not null and activedate is null THEN originaldate
	end
FROM taqprojecttask
WHERE taqprojectkey = @i_taqprojectkey 
	AND datetypecode = @i_datetypecode
	

If @v_datetype is null
		BEGIN
			SELECT @RETURN = ''
		END	
Else 
		BEGIN
			SELECT @RETURN = @d_date
		END
		

RETURN @RETURN

END

go
Grant All on dbo.rpt_get_project_task to Public
go