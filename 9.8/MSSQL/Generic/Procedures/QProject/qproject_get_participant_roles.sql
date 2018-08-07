if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_participant_roles') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_participant_roles
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_participant_roles
 (@i_projectkey        integer,
  @i_projectcontactkey integer,
  @i_allrolesind       bit,
  @o_error_code        integer output,
  @o_error_desc        varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qproject_get_participant_roles
**  Desc: This stored procedure returns all roles for a participant
**        from the taqprojectcontactrole table. 
**
**              
**
**    Auth: Alan Katzen
**    Date: 31 May 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:         Author:        Description:
**    ----------    --------       -------------------------------------------
**    11/08/2016    Colman         40665 Participant section does not display participant by role contacts
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @itemtypecode INT
  DECLARE @usageclasscode INT

  SELECT @itemtypecode = searchitemcode, @usageclasscode = usageclasscode 
  FROM coreprojectinfo 
  WHERE projectkey = @i_projectkey
  
  SELECT r.*, c.globalcontactkey
    FROM taqprojectcontactrole r 
    join taqprojectcontact c on r.taqprojectcontactkey = c.taqprojectcontactkey
   WHERE r.taqprojectkey = @i_projectkey and
         r.taqprojectcontactkey = @i_projectcontactkey and
         r.rolecode IN (SELECT DISTINCT g.datacode 
						FROM gentables g, gentablesitemtype i 
						WHERE g.tableid = i.tableid AND 
							  g.datacode = i.datacode AND 
							  g.tableid = 285 AND 
							  i.itemtypecode = @itemtypecode AND 
							  i.itemtypesubcode IN (SELECT TOP(1) i2.itemtypesubcode 
													 FROM gentablesitemtype i2 
													 WHERE g.tableid = i2.tableid AND 
														   g.datacode = i2.datacode AND 
														   g.tableid = 285 AND 
														   i2.itemtypecode = @itemtypecode AND 
														   i2.itemtypesubcode IN (0, @usageclasscode) ORDER BY itemtypesubcode DESC) AND 
							  (@i_allrolesind = 1 OR COALESCE(i.relateddatacode, 0) = 0)
							  AND COALESCE(g.deletestatus, 'N') NOT IN ('Y', 'y')) 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing taqprojectcontactrole: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)+ ' taqprojectcontactkey = ' + cast(@i_projectcontactkey AS VARCHAR)  
  END 

GO
GRANT EXEC ON qproject_get_participant_roles TO PUBLIC
GO


