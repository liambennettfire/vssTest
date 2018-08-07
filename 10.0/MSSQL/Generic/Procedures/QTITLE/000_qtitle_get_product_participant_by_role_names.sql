if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qtitle_get_product_participant_by_role_names') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qtitle_get_product_participant_by_role_names
GO

CREATE PROCEDURE qtitle_get_product_participant_by_role_names
 (@i_rolecode     integer,
  @i_countonly    integer,
  @i_searchterm   varchar(2000),
  @o_error_code   integer output,
  @o_error_desc   varchar(2000) output)
AS

/*********************************************************************************
**  Name: qtitle_get_product_participant_by_role_names
**  Desc: Gets all the Names for the role in Product Participant by Role Section
**
**  Auth: Alan Katzen
**  Date: July 28, 2017
**********************************************************************************/
  
DECLARE
  @v_error			INT

BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  IF coalesce(@i_searchterm, '') <> '' BEGIN
    SELECT DISTINCT TOP 25 g.globalcontactkey, g.displayname, c.email, c.relatedcontactname1, c.relatedcontactname2 
      FROM globalcontact g, globalcontactrole r, corecontactinfo c  
     WHERE g.globalcontactkey = c.contactkey 
       AND g.globalcontactkey = r.globalcontactkey 
       AND g.activeind = 1 
       AND c.searchfield LIKE @i_searchterm
       AND r.rolecode = @i_rolecode 
     ORDER BY displayname ASC
  END
  ELSE BEGIN
    IF @i_countonly = 1 BEGIN
      SELECT count(DISTINCT g.globalcontactkey) contactcount
        FROM globalcontact g, globalcontactrole r 
       WHERE g.globalcontactkey = r.globalcontactkey 
         AND g.activeind = 1 
         AND r.rolecode = @i_rolecode 
    END
    ELSE BEGIN
      SELECT DISTINCT g.globalcontactkey, g.displayname 
        FROM globalcontact g, globalcontactrole r 
       WHERE g.globalcontactkey = r.globalcontactkey 
         AND g.activeind = 1 
         AND r.rolecode = @i_rolecode 
       ORDER BY displayname ASC
    END
  END
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access globalcontact/globalcontactrole table (qtitle_get_product_participant_by_role_names).'
  END  
END
go

GRANT EXEC ON qtitle_get_product_participant_by_role_names TO PUBLIC
go
