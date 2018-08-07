  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_participants') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_participants
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_project_participants
 (@i_userkey integer,
  @i_projectkey  integer,
  @i_keyonly  bit,
  @i_includeall  bit,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_participants
**  Desc: This stored procedure gets the particpants for the project.
**
**  Auth: James Weber
**  Date: 17 May 2004
**
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:         Author:        Description:
**    ----------    --------       -------------------------------------------
**    3/15/05       KW             Modified to get only needed column values and to fix notes.
**    9/29/16       CO             Case 40665: Added flag to include participants by roles
**    11/08/16      CO             Case 40665: Participant section does not display participant by role contacts
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
  
  IF @i_includeall IS NULL
    SET @i_includeall = 0
  
  IF @i_keyonly = 1 --get top 2 key participants for the summary
    SELECT TOP 2 p.taqprojectkey, p.taqprojectcontactkey, p.globalcontactkey, 
      participantroles = dbo.qproject_global_participant_roles(@i_projectkey, p.globalcontactkey, @i_includeall),
      cast(COALESCE(p.keyind,0) as tinyint) keyind, COALESCE(p.sortorder,0) sortorder, c.displayname, c.email, c.phone,
      CASE WHEN LEN(p.participantnote) > 45 THEN
        CAST(p.participantnote AS VARCHAR(45)) + '...'
        ELSE p.participantnote
      END AS participantnote, dbo.qcontact_is_contact_private(c.contactkey, @i_userkey) AS isprivate,
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
    FROM taqprojectcontact p, corecontactinfo c
    WHERE p.taqprojectkey = @i_projectkey AND
      p.keyind = 1 AND
      p.globalcontactkey = c.contactkey AND
      p.taqprojectcontactkey IN (SELECT r.taqprojectcontactkey FROM taqprojectcontactrole r WHERE p.taqprojectcontactkey = r.taqprojectcontactkey AND
      r.rolecode IN (SELECT DISTINCT g.datacode FROM gentables g, gentablesitemtype i WHERE g.tableid = i.tableid AND g.datacode = i.datacode AND g.tableid = 285 AND i.itemtypecode = @itemtypecode 
      AND i.itemtypesubcode IN (SELECT TOP(1) i2.itemtypesubcode 
							 FROM gentablesitemtype i2 
							 WHERE g.tableid = i2.tableid AND 
							       g.datacode = i2.datacode AND 
							       g.tableid = 285 AND 
							       i2.itemtypecode = @itemtypecode AND 
							       i2.itemtypesubcode IN (0, @usageclasscode) ORDER BY itemtypesubcode DESC)
      AND (@i_includeall = 1 OR COALESCE(i.relateddatacode ,0) = 0) AND COALESCE(g.deletestatus, 'N') NOT IN ('Y', 'y')))      
    ORDER BY sortorder, c.displayname

  ELSE  --get all participants on project
    SELECT p.taqprojectkey, p.taqprojectcontactkey, p.globalcontactkey, 
      participantroles = dbo.qproject_global_participant_roles(@i_projectkey, p.globalcontactkey, @i_includeall),
      cast(COALESCE(p.keyind,0) as tinyint) keyind, COALESCE(p.sortorder,0) sortorder, c.displayname, c.email, c.phone,
      CASE WHEN LEN(p.participantnote) > 45 THEN
        CAST(p.participantnote AS VARCHAR(45)) + '...'
        ELSE p.participantnote
      END AS participantnote, dbo.qcontact_is_contact_private(c.contactkey, @i_userkey) AS isprivate,
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
      END AS relatedcontactname2, 
      CAST(0 as tinyint) selectedind
    FROM taqprojectcontact p, corecontactinfo c
    WHERE p.taqprojectkey = @i_projectkey AND
      p.globalcontactkey = c.contactkey AND
      p.taqprojectcontactkey IN (SELECT r.taqprojectcontactkey FROM taqprojectcontactrole r WHERE p.taqprojectcontactkey = r.taqprojectcontactkey AND
      r.rolecode IN (SELECT DISTINCT g.datacode FROM gentables g, gentablesitemtype i WHERE g.tableid = i.tableid AND g.datacode = i.datacode AND g.tableid = 285 AND i.itemtypecode = @itemtypecode 
      AND i.itemtypesubcode IN (SELECT TOP(1) i2.itemtypesubcode 
							 FROM gentablesitemtype i2 
							 WHERE g.tableid = i2.tableid AND 
							       g.datacode = i2.datacode AND 
							       g.tableid = 285 AND 
							       i2.itemtypecode = @itemtypecode AND 
							       i2.itemtypesubcode IN (0, @usageclasscode) ORDER BY itemtypesubcode DESC)
      AND (@i_includeall = 1 OR COALESCE(i.relateddatacode ,0) = 0) AND COALESCE(g.deletestatus, 'N') NOT IN ('Y', 'y')))      
    ORDER BY sortorder, c.displayname
    
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing taqprojectcontact: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qproject_get_project_participants TO PUBLIC
GO


