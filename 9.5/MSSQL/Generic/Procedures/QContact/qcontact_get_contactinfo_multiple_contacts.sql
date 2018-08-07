if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_contactinfo_multiple_contacts') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_get_contactinfo_multiple_contacts
GO
if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_contactinfo_multiple') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_get_contactinfo_multiple
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_get_contactinfo_multiple
 (@i_contactkeylist varchar(2000),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcontact_get_contactinfo_multiple
**  Desc: This stored procedure returns all contact info
**        for a list of global contacts. 
**
**              
**
**    Auth: Alan Katzen
**    Date: 24 May 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

BEGIN
  DECLARE 
	@error_var			INT,
	@SQLString			NVARCHAR(4000),
        @rowcount_var                   INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SET NOCOUNT ON

  -- Build and EXECUTE the dynamic SELECT statement
  SET @SQLString = N'SELECT gc.*,cc.*
    FROM globalcontact gc,corecontactinfo cc
    WHERE gc.globalcontactkey = cc.contactkey and
          gc.globalcontactkey IN (' + @i_contactkeylist + ')'

  EXECUTE sp_executesql @SQLString

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing globalcontact (' + cast(@error_var AS VARCHAR) + ').'   
  END 

END


GO
GRANT EXEC ON qcontact_get_contactinfo_multiple TO PUBLIC
GO


