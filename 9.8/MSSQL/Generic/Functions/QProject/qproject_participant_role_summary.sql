  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_participant_role_summary') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qproject_participant_role_summary
GO

CREATE FUNCTION qproject_participant_role_summary
    ( @i_taqprojectkey as integer,
      @i_taqprojectcontactkey as integer) 

RETURNS varchar(256)

/******************************************************************************
**  File: qproject_participant_role_summary.sql
**  Name: qproject_participant_role_summary
**  Desc: This returns a string which gives a summary of the roles which
**        the participant has in the project. 
**
**
**    Auth: James Weber
**    Date: 31 May 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @i_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @finalValue varchar(256)
  DECLARE @currentRole varchar(200)

  SET @finalValue = ''
  
  DECLARE participants_cursor CURSOR FOR
   SELECT g.datadesc  FROM taqprojectcontact c, taqprojectcontactrole r, gentables g
   WHERE c.taqprojectkey = @i_taqprojectkey and c.taqprojectcontactkey = @i_taqprojectcontactkey  and c.taqprojectkey = r.taqprojectkey and c.taqprojectcontactkey = r.taqprojectcontactkey and g.tableid = 285 and g.datacode = r.rolecode


  OPEN participants_cursor

  -- Perform the first fetch.
  FETCH NEXT FROM participants_cursor INTO 
    @currentRole
    
  IF @@FETCH_STATUS = 0
  BEGIN
    SET @finalValue = @currentRole
    FETCH NEXT FROM participants_cursor INTO 
      @currentRole
  END
    
  -- Check @@FETCH_STATUS to see if there are any more rows to fetch.
  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @finalValue = @finalValue + ', ' + @currentRole
    -- This is executed as long as the previous fetch succeeds.
  FETCH NEXT FROM participants_cursor INTO 
    @currentRole
  END

  CLOSE participants_cursor
  DEALLOCATE participants_cursor

return @finalValue

END
GO

GRANT EXEC ON dbo.qproject_participant_role_summary TO public
GO
