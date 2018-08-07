
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcontact_get_corecontactinfo_searchfield]') AND type in (N'P', N'PC'))
  DROP PROCEDURE [dbo].[qcontact_get_corecontactinfo_searchfield]
GO

/******************************************************************************
**  Name: qcontact_get_corecontactinfo_searchfield
**  Desc: 
**  Auth: Alan Katzen
**  Date: 04/06/2018
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
*******************************************************************************/

CREATE PROCEDURE [dbo].[qcontact_get_corecontactinfo_searchfield] (
	@i_contactkey INT,
	@o_searchfield VARCHAR(2000) OUTPUT)
AS
BEGIN
	DECLARE @v_firstname VARCHAR(75),
			@v_lastname VARCHAR(75),
			@v_groupname VARCHAR(255),
			@v_displayname VARCHAR(255)
    
	SET @o_searchfield = ''
	
  IF @i_contactkey > 0 BEGIN
	  SELECT @v_firstname = firstname,
		     @v_lastname = lastname,
         @v_groupname = groupname,
         @v_displayname = displayname
	  FROM globalcontact
	  WHERE globalcontactkey = @i_contactkey

	  SET @o_searchfield = COALESCE(@v_firstname, '')
		  + '|' + COALESCE(@v_lastname, '')
		  + '|' + COALESCE(@v_groupname, '')
		  + '|' + COALESCE(@v_displayname, '')
  END
END
GO

GRANT EXEC ON [dbo].[qcontact_get_corecontactinfo_searchfield] TO PUBLIC
GO

