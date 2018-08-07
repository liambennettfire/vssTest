if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_readerinfo_tasks') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_readerinfo_tasks
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_readerinfo_tasks
 (@i_projectkey     integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************
**  Name: qproject_get_readerinfo_tasks
**  Desc: This stored procedure returns reader information for the latest iteration.
**
**  Auth: Kate
**  Date: 8/30/07
**
*************************************************************************************
**  08/26/08 Lisa	See case 05322 removed taqprojectcontactrolekey column from 
**					taqprojecttask table.  Results are returned by joining to 
**					taqprojectcontact using globalcontact now.
**
*************************************************************************************/

  DECLARE
    @max_iteration INT,
    @taqelementkey INT,
    @v_error  INT,
    @v_rowcount INT,
    @v_readerinfoTK INT
  
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
    SELECT @taqelementkey = taqelementkey
    FROM taqprojectelement e, gentables g
    WHERE e.taqelementtypecode = g.datacode AND
      g.tableid = 287 AND 
      g.qsicode = 1 AND
      taqprojectkey = @i_projectkey AND 
      taqelementnumber = @max_iteration
  ELSE
    SET @taqelementkey = 0

  /** 11/4/08 Lisa - there should now only ever be one taskview record with qsicode = 4 (Reader Information Tasks) **/
  select @v_readerinfoTK = ( select taskviewkey from taskview where qsicode = 4 ) 
  
  /** 08/26/08 Lisa - new select statement with taqprojectcontactrolekey removed **/
  SELECT ri.taqprojectcontactrolekey, tvdt.sortorder, pt.activedate as 'date', pt.originaldate as 'originaldate', 
         COALESCE(pt.actualind,0) as 'actualind', COALESCE(pt.taqtaskkey,0) as 'taskkey', pt.datetypecode
  FROM taqprojectreaderiteration ri
  join taqprojectcontactrole cr on ri.taqprojectkey = cr.taqprojectkey 
							   and ri.taqprojectcontactrolekey = cr.taqprojectcontactrolekey
  join taqprojectcontact pc on cr.taqprojectcontactkey = pc.taqprojectcontactkey
  join taqprojecttask pt on pt.taqprojectkey = ri.taqprojectkey and 
							pt.taqelementkey = ri.taqelementkey and
						    pt.globalcontactkey = pc.globalcontactkey
  join taskviewdatetype tvdt on tvdt.datetypecode = pt.datetypecode
									and tvdt.taskviewkey = @v_readerinfoTK
  join datetype dt on tvdt.datetypecode = dt.datetypecode
  WHERE ri.taqprojectkey = @i_projectkey and ri.taqelementkey = @taqelementkey
  ORDER BY ri.taqprojectcontactrolekey, tvdt.sortorder

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 or @v_rowcount = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: projectkey = ' + cast(@i_projectkey AS VARCHAR)   
  END
  
GO

GRANT EXEC ON qproject_get_readerinfo_tasks TO PUBLIC
GO


