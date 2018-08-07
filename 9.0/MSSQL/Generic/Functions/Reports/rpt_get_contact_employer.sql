IF exists (select * from dbo.sysobjects where id = object_id(N'dbo.rpt_get_contact_employer') )
DROP FUNCTION dbo.rpt_get_contact_employer
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.rpt_get_contact_employer(
	@i_globalcontactkey	INT
)
RETURNS VARCHAR(80)
AS
/*  	
Returns the displayname for globalcontactkey from globalcontactrelationship for
globalcontactkey passed - Author's Employer
 
Parameter Options
		@i_globalcontactkey
*/

BEGIN

	DECLARE @RETURN			VARCHAR(80)
	DECLARE @v_desc			VARCHAR(255)
	DECLARE @v_count		INT
  DECLARE @v_globalcontactkey2 INT
	

  SELECT @v_count = COUNT(*)
    FROM globalcontactrelationship g, globalcontactrole r 
   WHERE g.globalcontactkey1 = @i_globalcontactkey
     AND g.globalcontactkey1 = r.globalcontactkey 
--     AND r.rolecode = (SELECT datacode FROM gentables WHERE tableid = 285 and qsicode = 4) 
     AND contactrelationshipcode1 = (SELECT datacode FROM gentables WHERE tableid = 519 AND datadesc = 'Employer')

  IF @v_count > 0 BEGIN 
   DECLARE employers_cursor CURSOR FOR
     SELECT  globalcontactkey2
        FROM globalcontactrelationship g, globalcontactrole r 
       WHERE g.globalcontactkey1 = @i_globalcontactkey
         AND g.globalcontactkey1 = r.globalcontactkey 
         --AND r.rolecode = (SELECT datacode FROM gentables WHERE tableid = 285 and qsicode = 4) 
         AND contactrelationshipcode1 = (SELECT datacode FROM gentables WHERE tableid = 519 AND datadesc = 'Employer')  
   
    OPEN employers_cursor

    -- Perform the first fetch.
    FETCH NEXT FROM employers_cursor INTO @v_globalcontactkey2

    IF @@FETCH_STATUS = 0
    BEGIN
      SELECT @v_desc = dbo.rpt_get_contact_name (@v_globalcontactkey2,'D')
      FETCH NEXT FROM employers_cursor INTO @v_globalcontactkey2
    END

    WHILE @@FETCH_STATUS = 0
    BEGIN
      SELECT @v_desc = @v_desc + ', ' + dbo.rpt_get_contact_name (@v_globalcontactkey2,'D')
      FETCH NEXT FROM employers_cursor INTO @v_globalcontactkey2
    END

    CLOSE employers_cursor
    DEALLOCATE employers_cursor
  END 
  ELSE BEGIN
    SELECT @v_desc = ''
  END 

	
	IF LEN(@v_desc)> 0
		BEGIN
			SELECT @RETURN = @v_desc
		END
	ELSE
		BEGIN
			SELECT @RETURN = ''
		END


RETURN @RETURN


END
GO


grant all on dbo.rpt_get_contact_employer to public
go


