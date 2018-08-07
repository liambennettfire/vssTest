if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_contactrelationship') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_contactrelationship
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_get_contactrelationship
 (@i_contactkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_contactrelationship
**  Desc: This stored procedure returns all relationships
**        for a global contact. 
**
**    Auth: Alan Katzen
**    Date: 18 May 2004
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  -- need to retrieve relationships in both directions
  SELECT 1 contactnumber,
      globalcontactkey1 thiscontactkey, 
      globalcontactkey2 othercontactkey, 
      contactrelationshipcode1 thiscontactrelationshipcode, 
      contactrelationshipcode2 othercontactrelationshipcode, 
      COALESCE(globalcontact.displayname,globalcontactrelationship.globalcontactname2) othercontactdisplayname,  
      globalcontactrelationship.globalcontactrelationshipkey, globalcontactrelationship.contactrelationshipaddtldesc, globalcontactrelationship.keyind
  FROM globalcontactrelationship LEFT OUTER JOIN globalcontact ON globalcontactrelationship.globalcontactkey2 = globalcontact.globalcontactkey   
    where   globalcontactrelationship.globalcontactkey1 = @i_contactkey 
  UNION
  SELECT 2 contactnumber, 
      globalcontactkey2 thiscontactkey, 
      globalcontactkey1 othercontactkey, 
      contactrelationshipcode2 thiscontactrelationshipcode, 
      contactrelationshipcode1 othercontactrelationshipcode, 
      globalcontact.displayname othercontactdisplayname,
      globalcontactrelationship.globalcontactrelationshipkey, globalcontactrelationship.contactrelationshipaddtldesc, globalcontactrelationship.keyind
  FROM globalcontactrelationship , globalcontact 
  WHERE globalcontactrelationship.globalcontactkey1 = globalcontact.globalcontactkey AND
      globalcontactrelationship.globalcontactkey2 > 0 AND
      globalcontactrelationship.globalcontactkey2 = @i_contactkey
  ORDER BY globalcontactrelationship.keyind DESC, thiscontactrelationshipcode ASC, othercontactdisplayname ASC

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on globalcontactrelationship (' + cast(@error_var AS VARCHAR) + '): globalcontactkey = ' + cast(@i_contactkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qcontact_get_contactrelationship TO PUBLIC
GO

