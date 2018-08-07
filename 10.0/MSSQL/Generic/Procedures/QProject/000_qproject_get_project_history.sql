if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_history') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_history
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_project_history
 (@i_projectkey     integer,
  @i_columnkey      integer,
  @o_error_code     integer       output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_history
**  Desc: This gets project history information for the Project.
**
**    Auth: Kusum Basra
**    Date: 17 February 2011
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_columnkey > 0 BEGIN
    select c.taqprojectkey, d.historylabel, c.beforevalue, c.aftervalue, c.lastuserid, c.lastmaintdate
    from historytablecolumndefs d
         INNER JOIN historychanges c 
         ON d.columnkey = c.columnkey 
    where c.taqprojectkey = @i_projectkey
      and c.columnkey = @i_columnkey
 order by historykey
  END
  ELSE BEGIN
    select c.taqprojectkey, d.historylabel, c.beforevalue, c.aftervalue, c.lastuserid, c.lastmaintdate
    from historytablecolumndefs d
         INNER JOIN historygrouping g 
         ON d.columnkey = g.columnkey 
         LEFT OUTER JOIN historychanges c 
         ON d.columnkey = c.columnkey 
    where g.itemtypecode=3
      and g.usageclass=0
      and c.taqprojectkey = @i_projectkey
 order by historykey
  END

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taqprojectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END 

GO
GRANT EXEC ON qproject_get_project_history TO PUBLIC
GO



