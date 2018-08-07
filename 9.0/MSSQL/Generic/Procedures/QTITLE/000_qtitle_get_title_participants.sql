  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_title_participants') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qtitle_get_title_participants
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qtitle_get_title_participants
 (@i_userkey integer,
  @i_bookkey  integer,
  @i_printingkey  integer,
  @i_keyonly  bit,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS


/******************************************************************************
**  Name: qtitle_get_title_participants
**  Desc: This stored procedure gets the particpants for the project.
**
**  Auth: James Weber
**  Date: 17 May 2004
**
**  9/25/08 - Lisa - Cloned from qproject_get_project_participants and 
**                   modified to use new bookcontact tables.  See Case 05533.
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @v_clientdefaultvalue64 FLOAT
  DECLARE @v_clientdefaultsubvalue64 INT  
  DECLARE @v_clientdefaultvalue65 FLOAT
  DECLARE @v_clientdefaultsubvalue65 INT      
  
  SET @v_clientdefaultvalue64 = NULL
  SET @v_clientdefaultsubvalue64 = NULL
  SET @v_clientdefaultvalue65 = NULL
  SET @v_clientdefaultsubvalue65 = NULL
    
  SELECT @v_clientdefaultvalue64 = COALESCE(clientdefaultvalue, NULL) ,@v_clientdefaultsubvalue64 = COALESCE(clientdefaultsubvalue, NULL) FROM clientdefaults WHERE clientdefaultid = 64
  SELECT @v_clientdefaultvalue65 = COALESCE(clientdefaultvalue, NULL) ,@v_clientdefaultsubvalue65 = COALESCE(clientdefaultsubvalue, NULL) FROM clientdefaults WHERE clientdefaultid = 65       

  SET @error_var = 0
  SET @rowcount_var = 0
  
  IF @i_keyonly IS NULL OR @i_keyonly = 0
    BEGIN
      SELECT b.bookkey, b.bookcontactkey, b.globalcontactkey, 
        participantroles = dbo.qtitle_participant_role_summary(@i_bookkey, b.bookcontactkey),
        cast(COALESCE(b.keyind,0) as tinyint) keyind, COALESCE(b.sortorder,0) sortorder, c.displayname, c.email, c.phone,
        CASE WHEN LEN(b.participantnote) > 45 THEN
          CAST(b.participantnote AS VARCHAR(45)) + '...'
          ELSE b.participantnote
        END AS participantnote, dbo.qcontact_is_contact_private(c.contactkey, @i_userkey) AS isprivate,
	    CASE
		  WHEN COALESCE(c.relatedcontactname1, NULL) IS NULL AND (@v_clientdefaultvalue64 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NULL)
		  THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
			  AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = b.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue64)		  
		  WHEN COALESCE(c.relatedcontactname1, NULL) IS NULL AND (@v_clientdefaultvalue64 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NOT NULL)
		  THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
			  AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = b.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue64 AND g.contactrelationshipcode2 = @v_clientdefaultsubvalue64)						  
	    ELSE c.relatedcontactname1
	    END AS relatedcontactname1,
	    CASE
		  WHEN COALESCE(c.relatedcontactname2, NULL) IS NULL AND (@v_clientdefaultvalue65 IS NOT NULL AND @v_clientdefaultsubvalue65 IS NULL)
		  THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
			  AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = b.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue65)		  
		  WHEN COALESCE(c.relatedcontactname2, NULL) IS NULL AND (@v_clientdefaultvalue65 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NOT NULL)
		  THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
			  AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = b.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue65 AND g.contactrelationshipcode2 = @v_clientdefaultsubvalue65)						  
	    ELSE c.relatedcontactname2
	    END AS relatedcontactname2
      FROM bookcontact b, corecontactinfo c
      WHERE b.bookkey = @i_bookkey AND
        b.printingkey = @i_printingkey AND
        b.globalcontactkey = c.contactkey
      ORDER BY b.sortorder, c.displayname
    END
  ELSE
    BEGIN
      SELECT b.bookkey, b.bookcontactkey, b.globalcontactkey, 
        participantroles = dbo.qtitle_participant_role_summary(@i_bookkey, b.bookcontactkey),
        cast(COALESCE(b.keyind,0) as tinyint) keyind, COALESCE(b.sortorder,0) sortorder, c.displayname, c.email, c.phone,
        CASE WHEN LEN(b.participantnote) > 45 THEN
          CAST(b.participantnote AS VARCHAR(45)) + '...'
          ELSE b.participantnote
        END AS participantnote, dbo.qcontact_is_contact_private(c.contactkey, @i_userkey) AS isprivate,
	    CASE
		  WHEN COALESCE(c.relatedcontactname1, NULL) IS NULL AND (@v_clientdefaultvalue64 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NULL)
		  THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
			  AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = b.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue64)		  
		  WHEN COALESCE(c.relatedcontactname1, NULL) IS NULL AND (@v_clientdefaultvalue64 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NOT NULL)
		  THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
			  AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = b.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue64 AND g.contactrelationshipcode2 = @v_clientdefaultsubvalue64)						  
	    ELSE c.relatedcontactname1
	    END AS relatedcontactname1,
	    CASE
		  WHEN COALESCE(c.relatedcontactname2, NULL) IS NULL AND (@v_clientdefaultvalue65 IS NOT NULL AND @v_clientdefaultsubvalue65 IS NULL)
		  THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
			  AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = b.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue65)		  
		  WHEN COALESCE(c.relatedcontactname2, NULL) IS NULL AND (@v_clientdefaultvalue65 IS NOT NULL AND @v_clientdefaultsubvalue64 IS NOT NULL)
		  THEN (SELECT TOP(1) globalcontactname2 FROM globalcontactrelationship g INNER JOIN globalcontact gc ON g.globalcontactkey1 = gc.globalcontactkey
			  AND g.globalcontactkey2 =0 AND g.globalcontactkey1 = b.globalcontactkey AND g.contactrelationshipcode1 = @v_clientdefaultvalue65 AND g.contactrelationshipcode2 = @v_clientdefaultsubvalue65)						  
	    ELSE c.relatedcontactname2
	    END AS relatedcontactname2
      FROM bookcontact b, corecontactinfo c
      WHERE b.bookkey = @i_bookkey AND
        b.printingkey = @i_printingkey AND
        b.keyind = 1 AND
        b.globalcontactkey = c.contactkey
      ORDER BY b.sortorder, c.displayname
    END
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing bookcontact: bookkey = ' + cast(@i_bookkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qtitle_get_title_participants TO PUBLIC
GO


