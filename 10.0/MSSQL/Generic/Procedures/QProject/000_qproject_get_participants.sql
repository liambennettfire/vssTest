  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_participants') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_participants
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
Declare @err int,
@dsc varchar(2000)
exec qproject_get_participants 3169200, 0, @err, @dsc

*/

CREATE PROCEDURE qproject_get_participants
 (
  @i_userkey integer,
  @i_projectkey  integer,
  @i_keyonly  bit,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_participants
**  Desc: This stored procedure gets the particpants for the project.
**
**  Auth: Lisa Cormier
**  Date: 28 May 2009
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
  DECLARE @v_clientdefaultvalue64 FLOAT
  DECLARE @v_clientdefaultsubvalue64 INT  
  DECLARE @v_clientdefaultvalue65 FLOAT
  DECLARE @v_clientdefaultsubvalue65 INT      
  DECLARE @itemtypecode INT
  DECLARE @usageclasscode INT
  
  SET @v_clientdefaultvalue64 = NULL
  SET @v_clientdefaultsubvalue64 = NULL
  SET @v_clientdefaultvalue65 = NULL
  SET @v_clientdefaultsubvalue65 = NULL
    
  SELECT @v_clientdefaultvalue64 = COALESCE(clientdefaultvalue, NULL) ,@v_clientdefaultsubvalue64 = COALESCE(clientdefaultsubvalue, NULL) FROM clientdefaults WHERE clientdefaultid = 64
  SELECT @v_clientdefaultvalue65 = COALESCE(clientdefaultvalue, NULL) ,@v_clientdefaultsubvalue65 = COALESCE(clientdefaultsubvalue, NULL) FROM clientdefaults WHERE clientdefaultid = 65         
  
  SELECT @itemtypecode = searchitemcode, @usageclasscode = usageclasscode FROM coreprojectinfo WHERE projectkey = @i_projectkey

  SET @error_var = 0
  SET @rowcount_var = 0
  
  IF @i_keyonly = 1 --get only key participants for the summary
    SELECT distinct p.globalcontactkey, cast(COALESCE(p.keyind,0) as tinyint) keyind, c.displayname, c.email, c.phone,
      participantroles = dbo.qproject_global_participant_roles(@i_projectkey, p.globalcontactkey, 0),
      COALESCE(p.sortorder, 0) sortorder, dbo.qcontact_is_contact_private(c.contactkey, @i_userkey) AS isprivate,
      CASE
	    WHEN COALESCE(c.relatedcontactname1, NULL) IS NULL AND (@v_clientdefaultvalue64 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NULL)
	    THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
		    AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = p.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue64)		  
	    WHEN COALESCE(c.relatedcontactname1, NULL) IS NULL AND (@v_clientdefaultvalue64 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NOT NULL)
	    THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
		    AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = p.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue64 AND g.contactrelationshipcode2 = @v_clientdefaultsubvalue64)						  
      ELSE c.relatedcontactname1
      END AS relatedcontactname1,
      CASE
	    WHEN COALESCE(c.relatedcontactname2, NULL) IS NULL AND (@v_clientdefaultvalue65 IS NOT NULL AND @v_clientdefaultsubvalue65 IS NULL)
	    THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
		    AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = p.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue65)		  
	    WHEN COALESCE(c.relatedcontactname2, NULL) IS NULL AND (@v_clientdefaultvalue65 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NOT NULL)
	    THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
		    AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = p.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue65 AND g.contactrelationshipcode2 = @v_clientdefaultsubvalue65)						  
      ELSE c.relatedcontactname2
      END AS relatedcontactname2
    FROM taqprojectcontact p
    JOIN corecontactinfo c on p.globalcontactkey = c.contactkey AND
      p.taqprojectcontactkey IN (SELECT r.taqprojectcontactkey FROM taqprojectcontactrole r WHERE p.taqprojectcontactkey = r.taqprojectcontactkey AND
      r.rolecode IN (SELECT DISTINCT g.datacode FROM gentables g, gentablesitemtype i WHERE g.tableid = i.tableid AND g.datacode = i.datacode AND g.tableid = 285 AND i.itemtypecode = @itemtypecode 
		  AND i.itemtypesubcode IN (SELECT TOP(1) i2.itemtypesubcode 
								 FROM gentablesitemtype i2 
								 WHERE g.tableid = i2.tableid AND 
									   g.datacode = i2.datacode AND 
									   g.tableid = 285 AND 
									   i2.itemtypecode = @itemtypecode AND 
									   i2.itemtypesubcode IN (0, @usageclasscode) ORDER BY itemtypesubcode DESC)     
      AND COALESCE(i.relateddatacode ,0) = 0 AND COALESCE(g.deletestatus, 'N') NOT IN ('Y', 'y')))      
    WHERE p.taqprojectkey = @i_projectkey AND p.keyind = 1
      
  ELSE  --get all participants on project
    SELECT distinct p.globalcontactkey, isNull(X.keyind,0) as keyind, c.displayname, c.email, c.phone, 
      participantroles = dbo.qproject_global_participant_roles(@i_projectkey, p.globalcontactkey, 0),
      COALESCE(p.sortorder, 0) sortorder, dbo.qcontact_is_contact_private(c.contactkey, @i_userkey) AS isprivate,
      CASE
	    WHEN COALESCE(c.relatedcontactname1, NULL) IS NULL AND (@v_clientdefaultvalue64 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NULL)
	    THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
		    AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = p.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue64)		  
	    WHEN COALESCE(c.relatedcontactname1, NULL) IS NULL AND (@v_clientdefaultvalue64 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NOT NULL)
	    THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
		    AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = p.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue64 AND g.contactrelationshipcode2 = @v_clientdefaultsubvalue64)						  
      ELSE c.relatedcontactname1
      END AS relatedcontactname1,
      CASE
	    WHEN COALESCE(c.relatedcontactname2, NULL) IS NULL AND (@v_clientdefaultvalue65 IS NOT NULL AND @v_clientdefaultsubvalue65 IS NULL)
	    THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
		    AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = p.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue65)		  
	    WHEN COALESCE(c.relatedcontactname2, NULL) IS NULL AND (@v_clientdefaultvalue65 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NOT NULL)
	    THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
		    AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = p.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue65 AND g.contactrelationshipcode2 = @v_clientdefaultsubvalue65)						  
      ELSE c.relatedcontactname2
      END AS relatedcontactname2
    FROM taqprojectcontact p 
    JOIN corecontactinfo c on p.globalcontactkey = c.contactkey AND
      p.taqprojectcontactkey IN (SELECT r.taqprojectcontactkey FROM taqprojectcontactrole r WHERE p.taqprojectcontactkey = r.taqprojectcontactkey AND
      r.rolecode IN (SELECT DISTINCT g.datacode FROM gentables g, gentablesitemtype i WHERE g.tableid = i.tableid AND g.datacode = i.datacode AND g.tableid = 285 AND i.itemtypecode = @itemtypecode 
		  AND i.itemtypesubcode IN (SELECT TOP(1) i2.itemtypesubcode 
								 FROM gentablesitemtype i2 
								 WHERE g.tableid = i2.tableid AND 
									   g.datacode = i2.datacode AND 
									   g.tableid = 285 AND 
									   i2.itemtypecode = @itemtypecode AND 
									   i2.itemtypesubcode IN (0, @usageclasscode) ORDER BY itemtypesubcode DESC)     
		AND COALESCE(i.relateddatacode ,0) = 0 AND COALESCE(g.deletestatus, 'N') NOT IN ('Y', 'y')))             
    LEFT JOIN ( select distinct globalcontactkey, keyind from taqprojectcontact
                where taqprojectkey = @i_projectkey and keyind = 1 ) as X
           ON x.globalcontactkey = p.globalcontactkey       
    WHERE p.taqprojectkey = @i_projectkey 
    
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing taqprojectcontact: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qproject_get_participants TO PUBLIC
GO

