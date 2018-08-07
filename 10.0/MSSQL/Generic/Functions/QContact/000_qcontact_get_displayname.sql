if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_displayname') and xtype in (N'FN', N'IF', N'TF'))
  drop function dbo.qcontact_get_displayname
GO

CREATE FUNCTION dbo.qcontact_get_displayname
(
  @i_contactkey as integer
) 
RETURNS VARCHAR(255)

/******************************************************************************
**  Name: qcontact_get_displayname
**  Desc: This function returns the displayname for a specific contact
**
**  Auth: Alan Katzen
**  Date: 1 April 2008
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
    
  SELECT @v_displayname = ltrim(rtrim(COALESCE(displayname,'')))
    FROM corecontactinfo
   WHERE contactkey = @i_contactkey
  
  RETURN @v_displayname
END
GO

GRANT EXEC ON dbo.qcontact_get_displayname TO public
GO
