if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_categories') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_get_categories
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcontact_get_categories
 (@i_globalcontactkey     integer,
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qcontact_get_categories
**  Desc: This stored procedure returns subject information
**        from the globalcontactcategory table. 
**
**    Auth: Alan Katzen
**    Date: 8/14/06
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

  SELECT g.tabledesclong, s.*
    FROM globalcontactcategory s, gentablesdesc g
   WHERE s.tableid = g.tableid and
         s.globalcontactkey = @i_globalcontactkey 
ORDER BY g.tabledesclong,s.sortorder,s.tableid,s.contactcategorycode,s.contactcategorysubcode,s.contactcategorysub2code

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: contactkey = ' + cast(@i_globalcontactkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qcontact_get_categories TO PUBLIC
GO


