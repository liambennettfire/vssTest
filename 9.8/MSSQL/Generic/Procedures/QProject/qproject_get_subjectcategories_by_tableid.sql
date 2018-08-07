if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_subjectcategories_by_tableid') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_subjectcategories_by_tableid
GO

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_subjectcats_by_tableid') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_subjectcats_by_tableid
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_subjectcats_by_tableid
 (@i_projectkey     integer,
  @i_tableid        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: qproject_get_subjectcats_by_tableid
**  Desc: This stored procedure returns subject information
**        from the taqprojectsubjectcategory table for a tableid. 
**
**    Auth: Alan Katzen
**    Date: 1 June 2004
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
    FROM taqprojectsubjectcategory s
   WHERE s.categorytableid = @i_tableid and
         s.taqprojectkey = @i_projectkey 
ORDER BY s.sortorder

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR) + ' / tableid = ' + cast(@i_tableid AS VARCHAR)
  END 

GO
GRANT EXEC ON qproject_get_subjectcats_by_tableid TO PUBLIC
GO


