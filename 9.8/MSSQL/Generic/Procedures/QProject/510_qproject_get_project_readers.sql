if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_readers') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_project_readers
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_project_readers
 (@i_userkey        integer,
  @i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************
**  Name: qproject_get_project_readers
**  Desc: This stored procedure returns reader information for the latest iteration.
**
**  Auth: Kate
**  Date: 5/30/04
*************************************************************************************/

  DECLARE @max_iteration  INT
  DECLARE @taqelementkey  INT
  DECLARE @error_var      INT
  DECLARE @rowcount_var   INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
 
  /** Get the latest iteration number for the manuscript **/
  /** (Element Type gentable 287, qsicode 1 - Manuscript) **/
  SELECT @max_iteration = MAX(e.taqelementnumber) 
  FROM taqprojectelement e, gentables g
  WHERE e.taqelementtypecode = g.datacode AND
    g.tableid = 287 AND 
    g.qsicode = 1 AND
    e.taqprojectkey = @i_projectkey
  
  /** Get the elementkey for the max iteration **/
  IF @max_iteration > 0
   BEGIN
    SELECT @taqelementkey = taqelementkey
    FROM taqprojectelement e, gentables g
    WHERE e.taqelementtypecode = g.datacode AND
      g.tableid = 287 AND 
      g.qsicode = 1 AND
      taqprojectkey = @i_projectkey AND 
      taqelementnumber = @max_iteration
   END
  ELSE
   BEGIN
    SET @taqelementkey = 0
   END

  /** Get the project reader information (for the latest iteration) **/
  SELECT c.contactkey, c.displayname, c.email, pr.taqprojectcontactrolekey, ri.taqelementkey,
    CONVERT(datetime,NULL, 101) 'date1', CONVERT(datetime,NULL, 101) 'originaldate1', 0 'actualind1', NULL 'taskkey1',
    CONVERT(datetime,NULL, 101) 'date2', CONVERT(datetime,NULL, 101) 'originaldate2', 0 'actualind2', NULL 'taskkey2',
    CONVERT(datetime,NULL, 101) 'date3', CONVERT(datetime,NULL, 101) 'originaldate3', 0 'actualind3', NULL 'taskkey3',
    CONVERT(datetime,NULL, 101) 'date4', CONVERT(datetime,NULL, 101) 'originaldate4', 0 'actualind4', NULL 'taskkey4', dbo.qcontact_is_contact_private(c.contactkey, @i_userkey) AS isprivate
  FROM taqprojectreaderiteration ri, taqprojectcontactrole pr, taqprojectcontact pc, corecontactinfo c
  WHERE ri.taqprojectkey = pr.taqprojectkey AND
    ri.taqprojectcontactrolekey = pr.taqprojectcontactrolekey AND
    pr.taqprojectkey = pc.taqprojectkey AND
    pr.taqprojectcontactkey = pc.taqprojectcontactkey AND
    pc.globalcontactkey = c.contactkey AND
    ri.taqprojectkey = @i_projectkey  AND
    ri.taqelementkey = @taqelementkey

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END
GO

GRANT EXEC ON qproject_get_project_readers TO PUBLIC
GO


