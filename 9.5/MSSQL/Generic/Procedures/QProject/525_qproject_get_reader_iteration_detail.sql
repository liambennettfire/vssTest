if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_reader_iteration') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_reader_iteration
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_reader_iteration
 (@i_projectkey     integer,
  @i_contactrolekey integer,
  @i_taqelementkey  integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  File: 
**  Name: qproject_get_reader_iteration
**  Desc: This stored procedure returns Reader Iteration Details
**        from taqprojectreaderiteration table.         
**
**    Auth: Kate
**    Date: 18 August 2004
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  SELECT e.taqelementdesc manuscriptiterationdesc, r.*
  FROM taqprojectreaderiteration r, taqprojectelement e, gentables g
  WHERE r.taqelementkey = e.taqelementkey AND
      e.taqelementtypecode = g.datacode AND
      g.tableid = 287 AND 
      g.qsicode = 1 AND --Manuscript
      r.taqprojectkey = @i_projectkey AND
      r.taqprojectcontactrolekey = @i_contactrolekey AND
      r.taqelementkey = @i_taqelementkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'error accessing taqprojectreaderiteration: taqprojectkey=' + cast(@i_projectkey AS VARCHAR) + ', taqprojectcontactrolekey=' + cast(@i_contactrolekey AS VARCHAR) + ', taqelementkey=' + cast(@i_taqelementkey AS VARCHAR)
  END 

GO
GRANT EXEC ON qproject_get_reader_iteration TO PUBLIC
GO


