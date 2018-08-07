if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_participant_name_by_role') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qproject_get_participant_name_by_role
GO

CREATE FUNCTION dbo.qproject_get_participant_name_by_role
(
  @i_projectkey as integer,
  @i_rolecode as integer
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: qproject_get_participant_name_by_role
**  Desc: This function returns project participant name for the given RoleCode.
**
**  Auth: Kate Wiewiora
**  Date: April 1 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_displayname  VARCHAR(255)
    
  /* First check if participant of the passed Role exists */
  SELECT @v_count = COUNT(*)
  FROM taqprojectcontact c, taqprojectcontactrole r, globalcontact gc
  WHERE c.taqprojectcontactkey = r.taqprojectcontactkey AND 
      c.globalcontactkey = gc.globalcontactkey AND
      c.taqprojectkey = @i_projectkey AND
      r.rolecode = @i_rolecode
  
  IF @v_count = 0
    RETURN NULL   /* this role doesn't exist - return NULL */
  
  /* Get all participants of this Role, sorted */
  DECLARE prodchargecodes_cur CURSOR FOR 
    SELECT gc.displayname
    FROM taqprojectcontact c, taqprojectcontactrole r, globalcontact gc
    WHERE c.taqprojectcontactkey = r.taqprojectcontactkey AND 
        c.globalcontactkey = gc.globalcontactkey AND
        c.taqprojectkey = @i_projectkey AND
        r.rolecode = @i_rolecode
    ORDER by c.sortorder ASC, gc.displayname ASC

  OPEN prodchargecodes_cur
  
  /* Fetch and return the first participant of this role */
  FETCH prodchargecodes_cur INTO @v_displayname

  CLOSE prodchargecodes_cur 
  DEALLOCATE prodchargecodes_cur    
  
  RETURN @v_displayname

END
GO

GRANT EXEC ON dbo.qproject_get_participant_name_by_role TO public
GO
