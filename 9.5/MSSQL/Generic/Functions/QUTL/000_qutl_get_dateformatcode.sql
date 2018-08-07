if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_dateformatcode') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qutl_get_dateformatcode
GO

CREATE FUNCTION qutl_get_dateformatcode
    (@i_userid as varchar(30)) 

RETURNS int

/******************************************************************************
**  File: 
**  Name: qutl_get_dateformatcode
**  Desc: This function returns the dateformatcode
**
**
**    Auth: Uday Khisty
**    Date: 05 February 2013
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @dateformatcode_var INT,
          @clientdefaultvalue INT

  SELECT @clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 0) 
		 FROM clientdefaults WHERE clientdefaultid = 77
		 
  IF @clientdefaultvalue = 0 BEGIN
	  SELECT @clientdefaultvalue = datacode 
			 FROM gentables WHERE tableid = 607 AND qsicode = 1		
  END		 
		 
  IF @i_userid IS NULL OR ltrim(rtrim(@i_userid)) = '' BEGIN
    RETURN @clientdefaultvalue
  END 
  
  SELECT @dateformatcode_var = COALESCE(dateformatcode, 0) 
	 FROM qsiusers WHERE userid = @i_userid
		 
  IF @dateformatcode_var = 0 OR NOT EXISTS(SELECT * FROM gentables WHERE tableid = 607 AND datacode = @dateformatcode_var) BEGIN
	 RETURN @clientdefaultvalue
  END
  
  RETURN @dateformatcode_var
END
GO

GRANT EXEC ON dbo.qutl_get_dateformatcode TO public
GO
