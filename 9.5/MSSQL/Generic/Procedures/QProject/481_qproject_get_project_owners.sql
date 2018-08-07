if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_owners') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_project_owners
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_project_owners
 (@i_userkey  integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_owners
**  Desc: This stored procedure returns project owners (system users) from
**        qsiusers table based on PRIVATE TEAM for the current user.
**
**  Auth: Kate
**  Date: 10/15/04
*******************************************************************************/

  DECLARE
    @error_var  INT,
    @rowcount_var INT

  SET @o_error_code = 0
  SET @o_error_desc = ''
   
  SELECT DISTINCT u.userkey,
    CASE
      WHEN u.lastname IS NULL OR u.lastname='' THEN
        CASE
          WHEN u.firstname IS NULL OR u.firstname='' THEN u.userid
          ELSE u.firstname
        END
      WHEN u.firstname IS NULL OR u.firstname='' THEN u.lastname
      ELSE LTRIM(u.firstname + ' ' + u.lastname)
    END AS username 
  FROM qsiusers u
  WHERE u.userkey = @i_userkey OR u.userkey IN 
    (SELECT accesstouserkey 
     FROM qsiprivateuserlist 
     WHERE primaryuserkey = @i_userkey)
    
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Could not retrieve rows from qsiusers table'
  END  

GO

GRANT EXEC ON qproject_get_project_owners TO PUBLIC
GO
