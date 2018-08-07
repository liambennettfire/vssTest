if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_project_all_participant_names_by_role') and OBJECTPROPERTY(id, N'IsScalarFunction') = 1)
drop function dbo.rpt_get_project_all_participant_names_by_role 
GO
CREATE FUNCTION dbo.rpt_get_project_all_participant_names_by_role
    ( @taqprojectkey as int,
	  @i_rolecode as integer,
	  @separator char(1)

    ) 
    
RETURNS varchar(4000)

/*

Select dbo.rpt_get_project_all_participant_names_by_role(taqprojectkey, 18, '/')
FROM taqprojecttitle 
where projectrolecode = 4 -- Work

*/


BEGIN 
		DECLARE @RETURN varchar(8000)
		SET @RETURN = ''

		declare @concat varchar(8000) set @concat = ''

		Select @concat = @concat + gc.displayname + ' ' + @separator + ' '
		FROM taqprojectcontact c
		JOIN globalcontact gc 
		on c.globalcontactkey = gc.globalcontactkey 
		JOIN taqprojectcontactrole r 
		ON c.taqprojectcontactkey = r.taqprojectcontactkey
		--JOIN gentables g 
		--ON r.rolecode = g.datacode 
		where c.taqprojectkey = @taqprojectkey 
		and r.rolecode = @i_rolecode
		--and g.tableid = 285
		ORDER BY c.keyind DESC, c.sortorder 



		IF ISNULL(@concat, '') = ''
			SET @Return = ''
		ELSE
			SET @Return = RTRIM(LEFT(@concat, LEN(@concat)-2))
		

   
RETURN @RETURN

END
GO
GRANT EXECUTE ON dbo.rpt_get_project_all_participant_names_by_role TO PUBLIC
GO