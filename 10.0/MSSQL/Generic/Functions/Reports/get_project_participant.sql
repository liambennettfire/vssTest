
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_project_participant_by_role') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.rpt_get_project_participant_by_role
GO

CREATE FUNCTION [dbo].[rpt_get_project_participant_by_role]
(
  @i_projectkey as integer,
  @i_rolecode as integer,
  @v_column	VARCHAR(1)
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: rpt_get_participant_name_by_role
**  Desc: This function returns project participant name for the given RoleCode. Name type
**  depends on v_column
		@v_column
			D = returns the display name
			F = returns the first name
			L = returns the middle name
			T = returns the title
			S = returns the short name
			E = returns the external code
											
**  Auth: Doug Lessing
**  Date: April 27 2009
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_desc  VARCHAR(255),
    @RETURN  VARCHAR(255),
	@i_globalcontactkey int
    
  /* First check if participant of the passed Role exists */
  SELECT @v_count = COUNT(*)
  FROM taqprojectcontact c, taqprojectcontactrole r, globalcontact gc
  WHERE c.taqprojectcontactkey = r.taqprojectcontactkey AND 
      c.globalcontactkey = gc.globalcontactkey AND
      c.taqprojectkey = @i_projectkey AND
      r.rolecode = @i_rolecode
  
  IF @v_count = 0
    RETURN ''   /* this role doesn't exist - return empty */
  
  /* Get all participants of this Role, sorted */
  DECLARE participants_cur CURSOR FOR 
    SELECT gc.globalcontactkey
    FROM taqprojectcontact c, taqprojectcontactrole r, globalcontact gc
    WHERE c.taqprojectcontactkey = r.taqprojectcontactkey AND 
        c.globalcontactkey = gc.globalcontactkey AND
        c.taqprojectkey = @i_projectkey AND
        r.rolecode = @i_rolecode
    ORDER by c.sortorder ASC, gc.displayname ASC

  OPEN participants_cur
  
  /* Fetch the globalcontactkey to then select the requested name */
  FETCH participants_cur INTO @i_globalcontactkey

  CLOSE participants_cur 
  DEALLOCATE participants_cur   
  
	IF @v_column = 'D'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(displayname))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

	IF @v_column = 'F'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(firstname))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

	IF @v_column = 'L'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(lastname))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

	IF @v_column = 'M'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(middlename))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END


	IF @v_column = 'S'
		BEGIN
			SELECT @v_desc = RTRIM(LTRIM(shortname))
			FROM globalcontact
			WHERE globalcontactkey = @i_globalcontactkey
		END

	IF LEN(@v_desc)> 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END

