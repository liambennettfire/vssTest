if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_corecontactinfo') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_get_corecontactinfo
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_get_corecontactinfo
 (@i_contactkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qcontact_get_corecontactinfo
**  Desc: This stored procedure returns all corecontactinfo data
**        for a global contact. 
**
**              
**
**    Auth: Alan Katzen
**    Date: 31 May 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

SELECT c.*
  FROM corecontactinfo c 
 WHERE c.contactkey = @i_contactkey 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on corecontactinfo (' + cast(@error_var AS VARCHAR) + '): globalcontactkey = ' + cast(@i_contactkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qcontact_get_corecontactinfo TO PUBLIC
GO


