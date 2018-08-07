if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_participant_name_by_role') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qtitle_get_participant_name_by_role
GO

CREATE FUNCTION dbo.qtitle_get_participant_name_by_role
(
  @i_bookkey as integer,
  @i_printingkey as integer,
  @i_rolecode as integer
) 
RETURNS VARCHAR(255)

/*******************************************************************************************************
**  Name: qtitle_get_participant_name_by_role
**  Desc: This function returns project participant name for the given RoleCode.
**        (Cloned from qproject_get_participant_name_by_role)
**  Auth: Alan Katzen
**  Date: September 29 2008
*******************************************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_displayname  VARCHAR(255)
    
  /* First check if participant of the passed Role exists */
  SELECT @v_count = COUNT(*)
  FROM bookcontact c, bookcontactrole r, globalcontact gc
  WHERE c.bookcontactkey = r.bookcontactkey AND 
      c.globalcontactkey = gc.globalcontactkey AND
      c.bookkey = @i_bookkey AND
      c.printingkey = @i_printingkey AND
      r.rolecode = @i_rolecode
  
  IF @v_count = 0
    RETURN NULL   /* this role doesn't exist - return NULL */
  
  /* Get all participants of this Role, sorted */
  DECLARE participants_cur CURSOR FOR 
    SELECT gc.displayname
    FROM bookcontact c, bookcontactrole r, globalcontact gc
    WHERE c.bookcontactkey = r.bookcontactkey AND 
        c.globalcontactkey = gc.globalcontactkey AND
        c.bookkey = @i_bookkey AND
        c.printingkey = @i_printingkey AND
        r.rolecode = @i_rolecode
    ORDER by c.sortorder ASC, gc.displayname ASC

  OPEN participants_cur
  
  /* Fetch and return the first participant of this role */
  FETCH participants_cur INTO @v_displayname

  CLOSE participants_cur 
  DEALLOCATE participants_cur    
  
  RETURN @v_displayname

END
GO

GRANT EXEC ON dbo.qtitle_get_participant_name_by_role TO public
GO
