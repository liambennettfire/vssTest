if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_element_type') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_element_type
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_project_element_type
 (@i_projectkey	    integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_element_type
**  Desc: This stored procedure returns all elements on a project
**
**    Auth: Kate Wiewiora
**    Date: 11/19/04
*******************************************************************************/

  DECLARE @error_var INT,
    @rowcount_var INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''

  SELECT DISTINCT e.taqelementtypecode elementtypecode, g.datadesc elementtypedesc, g.sortorder
  FROM taqprojectelement e, gentables g
  WHERE e.taqelementtypecode = g.datacode AND
      g.tableid = 287 AND
      e.taqprojectkey = @i_projectkey
  ORDER BY g.sortorder

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectkey=' + cast(@i_projectkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qproject_get_project_element_type TO PUBLIC
GO

