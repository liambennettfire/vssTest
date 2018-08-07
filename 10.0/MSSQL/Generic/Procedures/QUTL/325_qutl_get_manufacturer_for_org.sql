  if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_manufacturer_for_org') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_manufacturer_for_org
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qutl_get_manufacturer_for_org
 (@i_orgentrykey         integer,
  @o_error_code          integer output,
  @o_error_desc          varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qutl_get_manufacturer_for_org
**  Desc: This utility stored procedure finds the manufacturer code that
**        is associated with this organization.  
**
**              
**
**    Auth: James Weber
**    Date: 31 Jan 2005.
**
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:          Author:         Description:
**    -----------    --------        -------------------------------------------
**    21 Jan 2005    JPW             Initial Creation.
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

 SELECT * FROM orgentrymanufacturer where orgentrykey = @i_orgentrykey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: orgentrymanufacturer or orgentrykey = ' + CONVERT(varchar, @i_orgentrykey)
  END 

GO

GRANT EXEC ON qutl_get_manufacturer_for_org TO PUBLIC
GO


