  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_participant_by_role') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_participant_by_role
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_project_participant_by_role
 (@i_userkey integer,
  @i_projectkey  integer,
  @i_datacode    integer,
  @i_itemtype    integer,
  @i_usageclass  integer,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_participant_by_role
**  Desc: This stored procedure gets the particpant by Role for the project.
**  @i_datacode = 6, for Participant by Role 1
**				= 7, for Participant By Role 2 
**				= 8, for Participant By Role 3
**
**  Auth: Uday A. Khisty
**  Date: 18 August 2014
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @v_error_var    INT,
		  @v_rowcount_var INT,
		  @v_itemtypecode_for_printing INT,
		  @v_usageclasscode_for_printing INT,
		  @v_bookkey INT,
		  @v_printingkey INT,
		  @v_datetypecode INT,
		  @v_relateddatacode INT,
		  @v_sortorder SMALLINT,
		  @v_vendor_datacode INT
		  
		  
  CREATE TABLE #participantcontactroleinfo (
    taqprojectkey int null,
    indicator1 tinyint null,     
	taqprojectcontactkey int null,
	datacode int null,
	keyind tinyint null,
	sortorder smallint null,
	globalcontactkey int null,
	addresskey int NULL ,
	participantnote varchar(2000) NULL ,
	displayname varchar(255) NULL ,
	email varchar(100) NULL ,
	phone varchar(100) NULL ,
	contactkey int NULL ,
	rolecode smallint NULL ,
	taqprojectcontactrolekey int NULL ,
	globalcontactrelationshipkey int NULL ,
	quantity int NULL ,
	shippingmethodcode INT NULL,
	indicator tinyint NULL,
	newsortorder smallint NULL)  
		  
  IF @i_datacode = 6 BEGIN
	 SET @v_relateddatacode = 1
  END	 
  ELSE IF @i_datacode = 7 BEGIN	
	 SET @v_relateddatacode = 2	  
  END	 
  ELSE IF @i_datacode = 8 BEGIN	
	 SET @v_relateddatacode = 3
  END		  
  
  SELECT @v_vendor_datacode = datacode 
  FROM gentables
  WHERE tableid = 285 AND qsicode = 15
  
  SELECT @v_itemtypecode_for_printing = datacode, @v_usageclasscode_for_printing = datasubcode 
  FROM subgentables 
  where tableid = 550 AND qsicode = 14
  	 	   
  SELECT @v_datetypecode = (SELECT top(1) relateddatacode 
											FROM gentablesitemtype 
											WHERE tableid = 636 
												AND datacode = @i_datacode 
												AND datasubcode = 11 
												AND itemtypecode = @i_itemtype 
												AND itemtypesubcode IN (0, @i_usageclass) ORDER BY itemtypesubcode desc)
  
  IF @i_itemtype = @v_itemtypecode_for_printing BEGIN
	SELECT @v_bookkey = bookkey, @v_printingkey = printingkey 
	FROM taqprojectprinting_view 
	WHERE taqprojectkey = @i_projectkey
  END

  SET @v_error_var = 0
  SET @v_rowcount_var = 0
  
  --get Project Participant by Role information for the Section
    
  INSERT INTO  #participantcontactroleinfo
  SELECT @i_projectkey as taqprojectkey, COALESCE (i.indicator1, 0) as indicator1, p.taqprojectcontactkey, g.datacode, p.keyind, p.sortorder, p.globalcontactkey, p.addresskey, p.participantnote, 
   		 COALESCE(c.displayname, '') as  displayname, c.email, c.phone, c.contactkey, 
	     r.rolecode, r.taqprojectcontactrolekey, r.globalcontactrelationshipkey, r.quantity, r.shippingmethodcode,COALESCE (r.indicator, 0) as indicator, p.sortorder as newsortorder 
	FROM  gentablesitemtype AS i INNER JOIN
		  gentables AS g ON i.tableid = g.tableid AND i.datacode = g.datacode LEFT OUTER JOIN
		  taqprojectcontact AS p INNER JOIN
		  corecontactinfo AS c ON p.globalcontactkey = c.contactkey AND (p.taqprojectkey = @i_projectkey) INNER JOIN
		  taqprojectcontactrole AS r ON p.taqprojectcontactkey = r.taqprojectcontactkey ON g.datacode = r.rolecode
	WHERE (g.tableid = 285) AND (i.itemtypecode = @i_itemtype) AND (i.itemtypesubcode IN (0, @i_usageclass)) AND (COALESCE (g.deletestatus, 'N') NOT IN ('Y', 'y')) AND
		  (COALESCE (i.relateddatacode , 0) = @v_relateddatacode)
	ORDER BY p.sortorder, c.displayname
	
  DELETE FROM #participantcontactroleinfo WHERE COALESCE(globalcontactkey, 0) = 0 AND indicator1 = 0
  SELECT @v_sortorder = MAX(COALESCE(newsortorder, 0)) FROM #participantcontactroleinfo
  
  UPDATE #participantcontactroleinfo
  SET @v_sortorder = newsortorder = @v_sortorder + 1     
  WHERE newsortorder IS  NULL AND COALESCE(globalcontactkey, 0) = 0
    
	SELECT 
	 @i_projectkey AS taqprojectkey,
	 t.taqprojectcontactkey,
	 t.taqprojectcontactrolekey, 
	 t.displayname,
	 t.indicator1,
	 t.datacode as rolecode, 
	 --CASE WHEN t.taqprojectcontactkey IS NULL THEN
		--	 CASE @v_relateddatacode
		--	   WHEN 1 THEN 1
		--	   ELSE 0
		--	 END
		-- ELSE 
		--	COALESCE (t.keyind, 0)
		-- END AS keyind,
	Case WHEN @i_datacode = 6 AND COALESCE(t.globalcontactkey, 0) = 0 AND @v_vendor_datacode = t.datacode THEN
		1
	ELSE 
		t.keyind
	END AS keyind, 		 
	COALESCE (t.newsortorder, 0) AS sortorder, 
	t.globalcontactkey, 
	t.addresskey, 
	t.globalcontactrelationshipkey,
	t.quantity, 
	t.email, 
	t.phone, 
	COALESCE (t.indicator, 0) AS indicator, 
	t.shippingmethodcode,	
	Case WHEN @v_itemtypecode_for_printing = @i_itemtype THEN
		(select top 1 activedate 
				from taqprojecttask 
				WHERE bookkey = @v_bookkey
						AND printingkey =  @v_printingkey
						AND globalcontactkey  = t.globalcontactkey 
						AND datetypecode = @v_datetypecode)		 
	ELSE
		(select top 1 activedate 
				from taqprojecttask 
				WHERE taqprojectkey = @i_projectkey 
						AND globalcontactkey  = t.globalcontactkey 
						AND datetypecode = @v_datetypecode) 
	 END AS activedate,
	Case WHEN @v_itemtypecode_for_printing = @i_itemtype THEN
		(select top 1 COALESCE(taqtaskkey, NULL) 
				from taqprojecttask 
				WHERE bookkey = @v_bookkey
						AND printingkey =  @v_printingkey
						AND globalcontactkey  = t.globalcontactkey 
						AND datetypecode = @v_datetypecode)		 
	ELSE
		(select top 1 COALESCE(taqtaskkey, NULL) 
				from taqprojecttask 
				WHERE taqprojectkey = @i_projectkey 
						AND globalcontactkey  = t.globalcontactkey 
						AND datetypecode = @v_datetypecode) 
	 END AS taqtaskkey,	 
	 --CASE WHEN LEN(t.participantnote) > 45 THEN 
		--   CAST(t.participantnote AS VARCHAR(45)) + '...' 
		--  ELSE 
		--	t.participantnote 
		--  END AS participantnote,
		t.participantnote, 
	 Case WHEN COALESCE(t.globalcontactrelationshipkey, 0) > 0 THEN
	      (SELECT top(1) v.relatedcontactkey 
											FROM globalcontactrelationshipview v
											WHERE v.globalcontactrelationshipkey = t.globalcontactrelationshipkey AND
												  v.globalcontactkey = t.globalcontactkey)
 		  ELSE 0 
 		  END as relatedcontactkey,		
	 Case WHEN COALESCE(t.globalcontactrelationshipkey, 0) >= 0 THEN
	      (SELECT top(1) COALESCE(v.relatedcontactname, '') 
					FROM globalcontactrelationshipview v
					WHERE v.globalcontactrelationshipkey = t.globalcontactrelationshipkey AND
						  v.globalcontactkey = t.globalcontactkey)
 		  ELSE '' 
 		  END as relateddisplayname,	 	
	dbo.qcontact_is_contact_private(t.contactkey, @i_userkey) AS isprivate		  
	FROM  #participantcontactroleinfo t
	ORDER BY t.newsortorder, t.displayname
    
  -- Save the @@v_eRROR and @@v_rOWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error_var = @@ERROR, @v_rowcount_var = @@ROWCOUNT
  IF @v_error_var <> 0 or @v_rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing taqprojectcontact: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)
  END 
  
  DROP TABLE #participantcontactroleinfo

GO

GRANT EXEC ON qproject_get_project_participant_by_role TO PUBLIC
GO


