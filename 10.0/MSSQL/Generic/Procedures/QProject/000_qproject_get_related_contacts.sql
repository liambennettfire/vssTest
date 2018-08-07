  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_related_contacts') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_related_contacts
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_related_contacts
 (@i_rolecode integer,
  @i_contactkey  integer,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/***********************************************************************************
**  Name: qproject_get_related_contacts
**  Desc: This stored procedure gets the related contacts for given contact and role.
**
**  Auth: Uday A. Khisty
**  Date: 18 August 2014
**
*************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT     
  
  -- Removing Inactive Contacts (Note it was commented because it filtered out related contact names that don't have a full globalcontactkey).
  
 -- --get related contacts for given contact and role 
 -- IF EXISTS(select code2 from gentablesrelationshipdetail where gentablesrelationshipkey = 29 AND code1 = @i_rolecode) BEGIN
	--SELECT v.globalcontactrelationshipkey, v.relatedcontactname as "contactname2"
	--FROM globalcontactrelationshipview v
	--WHERE v.relationshipcode IN (select code2 from gentablesrelationshipdetail where gentablesrelationshipkey = 29)
	--AND v.relatedcontactkey NOT IN (SELECT globalcontactkey from globalcontact where COALESCE(activeind, 0) = 0)
	--AND v.globalcontactkey = @i_contactkey
	--ORDER BY v.relatedcontactname  
 -- END 
 -- ELSE BEGIN	  
	--SELECT v.globalcontactrelationshipkey, v.relatedcontactname as "contactname2"
	--FROM globalcontactrelationshipview v
	--WHERE v.relatedcontactkey NOT IN (SELECT globalcontactkey from globalcontact where COALESCE(activeind, 0) = 0)
	--AND v.globalcontactkey = @i_contactkey	
	--ORDER BY v.relatedcontactname
 -- END	  
  
  --get related contacts for given contact and role (brings in inactive contacts)
  IF EXISTS(select code2 from gentablesrelationshipdetail where gentablesrelationshipkey = 29 AND code1 = @i_rolecode) BEGIN
	  SELECT globalcontactrelationshipkey, relatedcontactname as "contactname2", relatedcontactkey
	  FROM globalcontactrelationshipview 
	  WHERE relationshipcode IN (select code2 from gentablesrelationshipdetail where gentablesrelationshipkey = 29)
	  AND globalcontactkey = @i_contactkey
	  ORDER BY relatedcontactname  
  END 
  ELSE BEGIN	  
	  SELECT globalcontactrelationshipkey, relatedcontactname as "contactname2", relatedcontactkey
	  FROM globalcontactrelationshipview 
	  WHERE globalcontactkey = @i_contactkey
	  ORDER BY relatedcontactname
  END	
    
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing gentablesrelationshipdetail: code1 = ' + cast(@i_rolecode AS VARCHAR)
  END 

GO

GRANT EXEC ON qproject_get_related_contacts TO PUBLIC
GO


