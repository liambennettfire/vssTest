if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_task_template_info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_task_template_info
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_task_template_info
 (@i_projectkey       integer,
  @i_taskviewkeylist  varchar(max),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS


/******************************************************************************
**  Name: qproject_get_task_template_info
**  Desc: This stored procedure returns info for given taskviewkeys
**        from the taskviewdatetype and taskview tables. 
**
**        NOTE: @i_taskviewkeylist needs to be in the form key1,key2,key3
**
**    Auth: Alan Katzen
**    Date: 6/19/08
******************************************************************************
* 9/9/10 - KW - Default rolecode from taskview.rolecode.
*               For taskviews where roleautoind=1, must automatically retrieve
*               tasks for each contact of the given role.
*******************************************************************************/

  DECLARE @error_var  INT,
      @rowcount_var   INT,
      @v_quote    CHAR(1),
      @v_SQL  NVARCHAR(max),
      @v_rolecode INT,
      @v_roleautoind  TINYINT

  SET @v_quote = CHAR(39)
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET NOCOUNT ON
 
  SET @v_sql = N'SELECT @p_rolecode = COALESCE(rolecode,0), @p_roleautoind = COALESCE(roleautoind,0)
  FROM taskview
  WHERE taskviewkey IN (' + @i_taskviewkeylist + ')'
        
  EXECUTE sp_executesql @v_sql, N'@p_rolecode INT OUTPUT, @p_roleautoind TINYINT OUTPUT', @v_rolecode OUTPUT, @v_roleautoind OUTPUT
  
  IF @v_rolecode > 0 AND @v_roleautoind = 1
  BEGIN
    SET @v_sql = N'SELECT tvd.taskviewkey, tvd.datetypecode, tvd.sortorder, tvd.scheduleind, 
	  CASE
		  WHEN COALESCE(tvd.duration, 0) = 0 THEN 
		    d.defaultduration
		  ELSE tvd.duration
	  END duration,       
      tvd.lag, tvd.startdate, tvd.defaultdate, 
      tv.rolecode, tvd.rolecode2,
      tvd.defaultqty, tvd.paymentamt, tvd.keyind, tvd.defaultnote, tvd.decisioncode, tvd.stagecode, 
      tv.elementtypecode, 1 selectedind, 0 projectkey, 0 bookkey, 0 printingkey,
      c.globalcontactkey contactkey1, 0 contactkey2, 0 taqelementkey, 0 elementtypesubcode,
      0 taqprojectformatkey, d.milestoneind,
      CASE
        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) =' +  @v_quote + @v_quote + ' THEN d.description
        ELSE d.datelabel
      END datelabel
    FROM taskviewdatetype tvd, datetype d, taskview tv, taqprojectcontactrole cr, taqprojectcontact c
    WHERE tvd.taskviewkey = tv.taskviewkey AND
      tvd.datetypecode = d.datetypecode AND
      tvd.taskviewkey IN (' + @i_taskviewkeylist + ') AND
      cr.taqprojectkey = ' + CONVERT(VARCHAR, @i_projectkey) + ' AND 
      cr.rolecode = tv.rolecode AND
      cr.activeind = 1 AND
      cr.taqprojectcontactkey = c.taqprojectcontactkey
    ORDER BY tvd.sortorder, d.description, c.sortorder'
  END
  ELSE
  BEGIN
    SET @v_SQL = N'SELECT tvd.taskviewkey, tvd.datetypecode, tvd.sortorder, tvd.scheduleind, 
	  CASE
		  WHEN COALESCE(tvd.duration, 0) = 0 THEN 
		    d.defaultduration
		  ELSE tvd.duration
	  END duration,       
      tvd.lag, tvd.startdate, tvd.defaultdate, 
      COALESCE(tv.rolecode,tvd.rolecode) rolecode, tvd.rolecode2,
      tvd.defaultqty, tvd.paymentamt, tvd.keyind, tvd.defaultnote, tvd.decisioncode, tvd.stagecode, 
      tv.elementtypecode, 1 selectedind, 0 projectkey, 0 bookkey, 0 printingkey,
      0 contactkey1, 0 contactkey2, 0 taqelementkey, 0 elementtypesubcode,
      0 taqprojectformatkey, d.milestoneind,
      CASE
        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel)) =' +  @v_quote + @v_quote + ' THEN d.description
        ELSE d.datelabel
      END datelabel
    FROM taskviewdatetype tvd, datetype d, taskview tv
      WHERE tvd.taskviewkey = tv.taskviewkey AND
      tvd.datetypecode = d.datetypecode AND
      tvd.taskviewkey IN (' + @i_taskviewkeylist + ')
    ORDER BY tvd.sortorder, d.description'
  END

  --PRINT @v_SQL   

  EXECUTE sp_executesql @v_SQL 

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found on taskviewdatetype: taskviewkeys = ' + @i_taskviewkeylist   
  END 

GO

GRANT EXEC ON qproject_get_task_template_info TO PUBLIC
GO
