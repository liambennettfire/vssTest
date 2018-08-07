IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qcontact_update_globalcontact')
  DROP procedure qcontact_update_globalcontact
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_update_globalcontact
 (@i_globalcontactkey INT,
  @o_error_code       INT OUTPUT,
  @o_error_desc       VARCHAR(2000) OUTPUT)
AS

/******************************************************************************
**  Name: qcontact_update_globalcontact
**  Desc: Update personnelind on globalcontact table.
**        Called when personnel role is found on the contact.
**
**  Auth: Kate W
**  Date: 7 November 2008
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_globalcontactkey IS NULL OR @i_globalcontactkey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update author table: globalcontactkey is empty.'
    RETURN
  END 

  UPDATE globalcontact
  SET personnelind = 1
  WHERE globalcontactkey = @i_globalcontactkey
  
  RETURN 
GO

GRANT EXEC ON qcontact_update_globalcontact TO PUBLIC
GO

