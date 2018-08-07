if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_related_work_task_actual_ind') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_related_work_task_actual_ind
GO
CREATE FUNCTION [dbo].[rpt_get_related_work_task_actual_ind]
(
  @i_bookkey as integer,
  @i_datetypecode as integer
) 
RETURNS VARCHAR(500)

/*******************************************************************************************************
**  Name: rpt_get_related_work_task_actual_ind
**  Desc: This function returns the actual ind (1 or 0) depending on the datetypecode passed

											
**  Auth: Josh Blanchette
**  Date: July 3rd 2018
*******************************************************************************************************/

BEGIN 
  DECLARE
    @RETURN  VARCHAR(255),
	@i_workprojectkey int
    
  /* First grab the taqprojectkey for the work */
  SELECT @i_workprojectkey = taqprojectkey
  FROM taqprojecttitle
  where @i_bookkey = bookkey AND
		projectrolecode = 4 AND  --Work
		titlerolecode = 1


  /* Use taqprojectkey from above and use it in the function below */
  select @RETURN = dbo.rpt_get_Actual_Ind_project_key(@i_workprojectkey, @i_datetypecode)


RETURN @RETURN


END

GO
GRANT EXECUTE ON dbo.rpt_get_related_work_task_actual_ind TO PUBLIC
GO