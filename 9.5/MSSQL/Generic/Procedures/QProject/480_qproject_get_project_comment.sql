 if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_comment') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_comment
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_project_comment
 (@i_projectkey           integer,
  @i_commenttypecode      integer,
  @i_commenttypesubcode   integer, 
  @i_commentformattype    varchar(20),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS


/******************************************************************************
**  File: qproject_get_project_comment.sql
**  Name: qproject_get_project_comment
**  Desc: This stored procedure gets the project comment based on the
**        type of comment and based on the format requested.  If the 
**        HTML version is requested and it is not available then the
**        plain text version is sent instead.  
**
**
**    Auth: James Weber
**    Date: 13 May 2004
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @i_commentformattype = upper(@i_commentformattype)
  
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SET @error_var = 0
  SET @rowcount_var = 0
  
  DECLARE @l_commentkey int
  SET @l_commentkey = null
   
  SELECT @l_commentkey=commentkey 
    FROM taqprojectcomments 
    WHERE taqprojectkey = @i_projectkey and
          commenttypecode = @i_commenttypecode and
          commenttypesubcode = @i_commenttypesubcode 
    
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT

  if (@error_var != 0)
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error Getting values from taqprojectcomments'
    goto ExitHandler
  END
  
  if (@rowcount_var = 0)
  BEGIN
    goto ExitHandler
  END
  
  SET @rowcount_var = 0
  if (@i_commentformattype = 'HTML' and @l_commentkey is not null)
  BEGIN
    SELECT commentkey,commenttypecode,commenttypesubcode,parenttable,commenthtml commentbody
      FROM qsicomments 
     WHERE commentkey = @l_commentkey
     
    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  END

  if (@i_commentformattype = 'HTMLLITE' and @l_commentkey is not null)
  BEGIN
    SELECT commentkey,commenttypecode,commenttypesubcode,parenttable,commenthtmllite commentbody
      FROM qsicomments 
     WHERE commentkey = @l_commentkey
     
    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  END
  
  if (@i_commentformattype = 'TEXT' and @l_commentkey is not null)
  BEGIN
    SELECT commentkey,commenttypecode,commenttypesubcode,parenttable,commenttext commentbody
      FROM qsicomments 
     WHERE commentkey = @l_commentkey
 
    -- Save the @@ERROR and @@ROWCOUNT values in local 
    -- variables before they are cleared.
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  END

  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'error retrieving qsicomments (for qproject_get_project_comment - ' + @i_commentformattype + ').'   
  END
  IF @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: qsicomments (for qproject_get_project_comment).'   
  END


ExitHandler:

 

GO
GRANT EXEC ON qproject_get_project_comment TO PUBLIC
GO


