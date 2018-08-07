if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_related_contact_displayname') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qcontact_get_related_contact_displayname
GO

CREATE FUNCTION dbo.qcontact_get_related_contact_displayname
(
  @i_contactkey as integer,
  @i_contactrelationshipcode as integer
) 
RETURNS VARCHAR(255)

/******************************************************************************
**  Name: qcontact_get_related_contact_displayname
**  Desc: This function returns the displayname for a specific related contact
**
**  Auth: Alan Katzen
**  Date: 28 May 2013
*******************************************************************************/

BEGIN 
  DECLARE
    @v_count  INT,
    @v_displayname  VARCHAR(255)
    
  SELECT @v_count = COUNT(*)
    FROM corecontactinfo
   WHERE contactkey = @i_contactkey
  
  IF @v_count = 0
    RETURN null
      
  SELECT TOP 1 @v_displayname = ltrim(rtrim(COALESCE(c.displayname,'')))
    FROM globalcontactrelationship r, globalcontact c
   WHERE r.globalcontactkey2 = c.globalcontactkey AND
         r.contactrelationshipcode1 = @i_contactrelationshipcode AND
         r.globalcontactkey1 = @i_contactkey 
ORDER BY r.keyind DESC, r.sortorder ASC
  
  IF @v_displayname = '' BEGIN
    SELECT TOP 1 @v_displayname = ltrim(rtrim(COALESCE(c.displayname,'')))
      FROM globalcontactrelationship r, globalcontact c
     WHERE r.globalcontactkey1 = c.globalcontactkey AND 
           r.contactrelationshipcode2 = @i_contactrelationshipcode AND
           r.globalcontactkey2 = @i_contactkey 
  ORDER BY r.keyind DESC, r.sortorder ASC
  END
  
  RETURN @v_displayname
   
END
GO

GRANT EXEC ON dbo.qcontact_get_related_contact_displayname TO public
GO
