  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_global_participant_roles') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qproject_global_participant_roles
GO

CREATE FUNCTION qproject_global_participant_roles
    ( @i_taqprojectkey as integer,
      @i_globalcontactkey as integer,
      @i_includeall as bit ) 

RETURNS varchar(256)

/******************************************************************************
**  File: qproject_global_participant_roles.sql
**  Name: qproject_global_participant_roles
**  Desc: This returns a string which gives a summary of the roles which
**        the participant has in the project using the globalcontactkey
**        to concatenate a list of role descriptions. 
**
**
**    Auth: Lisa Cormier
**    Date: 26 May 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:         Author:        Description:
**    ----------    --------       -------------------------------------------
**    11/08/2016    Colman         40665 Participant section does not display participant by role contacts
*******************************************************************************/

BEGIN 
  DECLARE @i_count      INT
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @finalValue varchar(256)
  DECLARE @currentRole varchar(200)
  DECLARE @itemtypecode INT
  DECLARE @usageclasscode INT

  SET @finalValue = ''
  
  SELECT @itemtypecode = searchitemcode, @usageclasscode = usageclasscode 
  FROM coreprojectinfo 
  WHERE projectkey = @i_taqprojectkey  
  
  DECLARE participants_cursor CURSOR FOR
   SELECT g.datadesc  FROM taqprojectcontact c, taqprojectcontactrole r, gentables g
   WHERE c.taqprojectkey = @i_taqprojectkey 
   and c.globalcontactkey = @i_globalcontactkey  
   and c.taqprojectkey = r.taqprojectkey 
   and c.taqprojectcontactkey = r.taqprojectcontactkey 
   and g.tableid = 285 and g.datacode = r.rolecode
   and r.rolecode IN (SELECT DISTINCT g.datacode 
					FROM gentables g, gentablesitemtype i 
					WHERE g.tableid = i.tableid AND 
						  g.datacode = i.datacode AND 
						  g.tableid = 285 AND 
						  i.itemtypecode = @itemtypecode AND 
						  i.itemtypesubcode IN (@usageclasscode, 0) AND 
						  (@i_includeall = 1 OR COALESCE(i.relateddatacode, 0) = 0)
						  AND COALESCE(g.deletestatus, 'N') NOT IN ('Y', 'y'))    

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

GRANT EXEC ON dbo.qproject_global_participant_roles TO public
GO
