if exists (select * from dbo.sysobjects where id = object_id(N'rpt_get_related_work_participant_by_role') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_related_work_participant_by_role
GO
CREATE FUNCTION [dbo].[rpt_get_related_work_participant_by_role]
(
  @i_bookkey as integer,
  @i_rolecode as integer
) 
RETURNS VARCHAR(500)

/*******************************************************************************************************
**  Name: rpt_get_related_work_participant_by_role
**  Desc: This function returns project participant name for the given RoleCode based off of bookkey

											
**  Auth: Josh Blanchette
**  Date: July 3rd 2018
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_desc  VARCHAR(255),
    @RETURN  VARCHAR(255),
	@i_workprojectkey int
    
  /* First grab the taqprojectkey for the work */
  SELECT @i_workprojectkey = taqprojectkey
  FROM taqprojecttitle
  where @i_bookkey = bookkey AND
		projectrolecode = 4 AND  --Work
		titlerolecode = 1


  /* Use taqprojectkey from above and use it in the function below */
  select @RETURN = dbo.rpt_get_project_all_participant_names_by_role(@i_workprojectkey, @i_rolecode, ',')


RETURN @RETURN


END

GO
GRANT EXECUTE ON dbo.rpt_get_related_work_participant_by_role TO PUBLIC
GO