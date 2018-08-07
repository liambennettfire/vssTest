if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskview_dates_remaining') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taskview_dates_remaining
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_taskview_dates_remaining
 (@i_taskviewkey    integer,
  @i_taskgroupkey	integer,
  @i_datetypekey	integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  Name: qproject_get_taskview_dates_remaining
**  Desc: This stored procedure returns tasks for given taskviewgroup
**        from the taskviewdates table except ones that already have been added to the
**		  provided taskviewkey
**
**    Auth: Jon Hess
**    Date: 9/02/09
**    Modifications:  
**
** ---test---------------------------------------------------------------------
** exec dbo.qproject_get_taskview_dates_remaining 571834, 101, 0, 0, 0
*******************************************************************************/

  DECLARE @error_var      INT
  DECLARE @rowcount_var   INT
  DECLARE @sqlStmt		  varchar(5000)

  SET @o_error_code = 0
  SET @o_error_desc = ''

  select @sqlStmt = 
	'SELECT v.taskviewkey, v.datetypecode, v.sortorder, v.lastuserid, v.lastmaintdate, v.scheduleind, v.duration, v.defaultdate, v.rolecode, v.rolecode2, v.defaultqty, 
	  v.paymentamt, v.keyind, v.defaultnote, v.decisioncode, v.stagecode, tv.elementtypecode, tv.taqprojecttypecode, COALESCE (tv.alldatetypesind, 0) 
	  AS alldatetypesind,
			CASE
			  WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) = '''' THEN d.description
			  ELSE d.datelabel
			END datelabel,
			dbo.qproject_is_sent_to_tmm(N''date'',0,d.datetypecode,0) sendtotmm,
			''true'' as selectind,
			CASE
			  WHEN d.description IS NULL OR LTRIM(RTRIM(d.description)) = '''' THEN d.datelabel
			  ELSE d.description
			END as description,
	  v.sortorder AS origsortorder
	FROM taskview AS tv INNER JOIN taskviewdatetype AS v ON tv.taskviewkey = v.taskviewkey INNER JOIN datetype AS d ON v.datetypecode = d.datetypecode
	WHERE (v.taskviewkey = ' + convert(varchar(20), @i_taskgroupkey) + ') 
	AND (0 = (SELECT COUNT(*) AS countDatetypeCode FROM taskviewdatetype WHERE (taskviewkey = ' + convert(varchar(20), @i_taskviewkey) + ') AND (datetypecode = v.datetypecode)))
	ORDER BY v.sortorder '

  EXEC(@sqlStmt)

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taskviewkey = ' + cast(@i_taskviewkey AS VARCHAR)   
  END 

GO

GRANT EXEC ON qproject_get_taskview_dates_remaining TO PUBLIC
GO
