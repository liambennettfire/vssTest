if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_culturecode') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.qutl_get_culturecode
GO

CREATE FUNCTION qutl_get_culturecode
    (@i_userid as varchar(30)) 

RETURNS int

/******************************************************************************
**  File: 
**  Name: qutl_get_culturecode
**  Desc: This function returns the culturecode
**
**
**    Auth: Kusum Basra
**    Date: 24 July 2014
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN 
  DECLARE @culturecode_var INT,
          @clientdefaultvalue INT

  SELECT @clientdefaultvalue = COALESCE(CAST(clientdefaultvalue AS INT), 0) 
		 FROM clientdefaults WHERE clientdefaultid = 78
		 
  --IF @clientdefaultvalue = 0 BEGIN
	 -- SELECT @clientdefaultvalue = datacode 
		--	 FROM gentables WHERE tableid = 318 AND LTRIM(RTRIM(UPPER(eloquencefieldtag))) = 'EN'
  --END		 
		 
  IF @i_userid IS NULL OR ltrim(rtrim(@i_userid)) = '' BEGIN
    RETURN @clientdefaultvalue
  END 
  
  SELECT @culturecode_var = COALESCE(culturecode, 0) 
	 FROM qsiusers WHERE userid = @i_userid
		 
  IF @culturecode_var = 0 BEGIN
	 RETURN @clientdefaultvalue
  END
  
  RETURN @culturecode_var
END
GO

GRANT EXEC ON dbo.qutl_get_culturecode TO public
GO
