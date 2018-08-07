if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_oup_get_max_project_task]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rpt_oup_get_max_project_task]


GO
/****** Object:  UserDefinedFunction [dbo].[rpt_oup_get_max_project_task]    Script Date: 2/27/2017 11:22:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




Create FUNCTION [dbo].[rpt_oup_get_max_project_task] 
            	(@i_taqtaskkey 	INT, @v_datetype varchar(2))
		

 /** Returns the date for the passed taqtaskkey, selecting the column
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
WHERE taqtaskkey = @i_taqtaskkey 
	

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


