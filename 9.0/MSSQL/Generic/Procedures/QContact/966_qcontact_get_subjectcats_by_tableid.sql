if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_subjectcats_by_tableid') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qcontact_get_subjectcats_by_tableid
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qcontact_get_subjectcats_by_tableid
 (@i_contactkey     integer,
  @i_tableid        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qcontact_get_subjectcats_by_tableid
**  Desc: This stored procedure returns subject information
**        from the globalcontactcategory table for a tableid. 
**
**    Auth: Alan Katzen
**    Date: 15 August 2006
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

  SELECT s.* 
    FROM globalcontactcategory s
   WHERE s.tableid = @i_tableid and
         s.globalcontactkey = @i_contactkey 
ORDER BY s.sortorder

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: contactkey = ' + cast(@i_contactkey AS VARCHAR) + ' / tableid = ' + cast(@i_tableid AS VARCHAR)
  END 

GO
GRANT EXEC ON qcontact_get_subjectcats_by_tableid TO PUBLIC
GO


