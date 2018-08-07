if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qcontact_get_person_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qcontact_get_person_info
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qcontact_get_person_info
 (@i_contributorkey integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qcontact_get_person_info
**  Desc: This stored procedure returns necessary info from the person table
**        to default globalcontact table fields.
**
**  Auth: Kate Wiewiora
**  Date: 26 May 2005
*******************************************************************************/

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT firstname, lastname, middlename, displayname, defaultroletypecode
  FROM person
  WHERE contributorkey = @i_contributorkey 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on person table (' + cast(@error_var AS VARCHAR) + '): contributorkey = ' + cast(@i_contributorkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qcontact_get_person_info TO PUBLIC
GO


