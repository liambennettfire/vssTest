if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskview_dates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taskview_dates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_taskview_dates
 (@i_taskviewkey    integer,
  @i_datetypekey	integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  Name: qproject_get_taskview_dates
**  Desc: This stored procedure returns all tasks for given taskviewkey
**        from the taskviewdates table. 
**
**    Auth: Kate
**    Date: 9/15/04
**    Modifications:  06/2008 Lisa returned more items and allowed the 
**					  datetype key to be passed if a single row is needed
**					  which allows for editing of a single task in a group.
**
**					  09/08/08 Lisa see case 05456.  Brock has requested
**						that datetype.Description be displayed on TaskView Admin.
**						not DateLabel.
**
*******************************************************************************/

  DECLARE @error_var      INT
  DECLARE @rowcount_var   INT
  DECLARE @sqlStmt		  varchar(5000)

  SET @o_error_code = 0
  SET @o_error_desc = ''

  /** get all dates/tasks for this task group/view key **/

  select @sqlStmt = 
   'SELECT v.*, tv.elementtypecode, tv.taqprojecttypecode, COALESCE(tv.alldatetypesind,0) alldatetypesind, d.milestoneind,
        CASE
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '''' THEN d.description
          ELSE d.datelabel
        END datelabel,
        dbo.qproject_is_sent_to_tmm(N''date'',0,d.datetypecode,0) sendtotmm,
		''true'' as selectind,
        CASE
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '''' THEN d.description
          ELSE d.datelabel
        END as description,
        v.sortorder as origsortorder		
  FROM taskview tv, taskviewdatetype v, datetype d
  WHERE v.taskviewkey = tv.taskviewkey AND
		v.datetypecode = d.datetypecode AND 
        v.taskviewkey = ' + convert(varchar(20), @i_taskviewkey)

  if ( Coalesce(@i_datetypekey,0) > 0 )
  begin
	select @sqlStmt = @sqlStmt + ' AND v.datetypecode = ' + convert(varchar(20), @i_datetypekey)
  end

  select @sqlStmt = @sqlStmt + ' ORDER BY v.sortorder, d.description '

  --print @sqlStmt

  EXEC(@sqlStmt)

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taskviewkey = ' + cast(@i_taskviewkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qproject_get_taskview_dates TO PUBLIC
GO
