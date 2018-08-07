if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taqprojecttitleorgentry') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taqprojecttitleorgentry
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_taqprojecttitleorgentry
 (@i_taqprojectformatkey  integer,
  @i_orglevelkey    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/************************************************************************************
**  Name: qproject_get_taqprojecttitleorgentry
**  Desc: If no orglevelkey passed, this stored procedure returns all organizational 
**        levels for a project format, regardless if they are filled in or not.
**
**    Auth: Alan Katzen
**    Date: 4 April 2011
*************************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_orglevelkey > 0
    SELECT e.orgentrydesc, o.*, po.*
    FROM orglevel o 
      LEFT OUTER JOIN taqprojecttitleorgentry po ON o.orglevelkey = po.orglevelkey AND po.taqprojectformatkey = @i_taqprojectformatkey
      LEFT OUTER JOIN orgentry e ON po.orgentrykey = e.orgentrykey
    WHERE o.orglevelkey = @i_orglevelkey
  ELSE
    SELECT e.orgentrydesc, o.*, po.*
    FROM orglevel o 
      LEFT OUTER JOIN taqprojecttitleorgentry po ON o.orglevelkey = po.orglevelkey AND po.taqprojectformatkey = @i_taqprojectformatkey
      LEFT OUTER JOIN orgentry e ON po.orgentrykey = e.orgentrykey
    ORDER BY o.orglevelkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taqprojectformatkey = ' + cast(@i_taqprojectformatkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qproject_get_taqprojecttitleorgentry TO PUBLIC
GO
