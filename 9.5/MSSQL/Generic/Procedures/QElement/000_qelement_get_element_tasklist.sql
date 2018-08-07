if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qelement_get_element_tasklist') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qelement_get_element_tasklist
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
 declare @err int
 declare @dsc varchar(2000)

 exec qelement_get_element_tasklist 640789, 604451, 0, 0, 0, 639625, 0, @err, @dsc
 exec qelement_get_element_tasklist 640786, 604451, 0, 0, 0, 639625, 0, @err, @dsc

*/

CREATE PROCEDURE [dbo].[qelement_get_element_tasklist]
 (@i_elementkey     integer,
  @i_taskviewkey    integer, 
  @i_rolecode       integer,
  @i_contactkey		integer,
  @i_projectkey		integer,
  @i_bookkey	    integer,
  @i_stagekey		integer,
  @i_userkey        integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qelement_get_element_tasklist
**  Desc: This stored procedure returns all tasks for a given element
**        and taskviewkey (task group) from the taqprojecttask table.
**        Dataset returned is further filtered by Contact, Bookkey, 
**        and role codes.
**
**    Auth: Lisa
**    Date: 6/10/S08
*******************************************************************************/

  DECLARE
    @v_sqlselect  VARCHAR(4000),
    @v_sqlfrom    VARCHAR(2000),
    @v_sqlwhere   VARCHAR(max),
    @v_sqlorderby VARCHAR(100),
    @v_sqlstring  NVARCHAR(max),
    @v_quote      VARCHAR(2),
    @error_var    INT,
    @rowcount_var INT,
    @v_alldatetypesind INT

  SET @v_quote = ''''

  -- Build the basic query

  select @v_sqlselect = 'select tpt.taqtaskkey, tpt.stagecode, gt.datadesc, tpt.actualind, dt.sortorder,
    CASE 
      WHEN dt.datelabel IS NULL OR LTRIM(RTRIM(dt.datelabel))=' + @v_quote + @v_quote + ' THEN dt.description
      ELSE dt.datelabel 
    END description,
    COALESCE(tpt.activedate,tpt.originaldate) as bestdate,
    COALESCE(dt.usedexclusivelybycsind,0) usedexclusivelybycsind,
    CASE 
      WHEN tpt.bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(' + cast(@i_userkey as varchar) + ','+ @v_quote + 'tasktracking'+ @v_quote + ',323,tpt.datetypecode,tpt.bookkey,tpt.printingkey,0)
      ELSE 2
    END accesscode,
    case when tpt.globalcontactkey is not null then tpt.globalcontactkey else tpt.globalcontactkey2 end as contactkey,
    tpt.activedate, tpt.originaldate, tpt.taqtasknote, gc1.displayname, gc2.displayname, tpt.taqelementkey, tpt.taskelementkey,
    dbo.qproject_taskoverride_exists_for_element(tpt.taqtaskkey,tpt.taqelementkey) taskoverrideexistsforelement, 
    dbo.qproject_taskoverride_exists_for_task(tpt.taqtaskkey) taskoverrideexistsfortask,
    COALESCE(tpt.sortorder, dt.sortorder, 999) taskoverridesortorder, tpt.keyind, dt.triggerdateind, tpt.bookkey, tpt.printingkey, tpt.taqprojectkey, tpt.datetypecode, dt.datelabel, tpt.activedate as origactivedate, cp.projecttitle projectname,ct.title   '

  select @v_sqlfrom = ' from taqprojecttaskelement_view tpt
					    join datetype dt on tpt.datetypecode = dt.datetypecode
					    join taqprojectelement tpe on tpt.taqelementkey = tpe.taqelementkey '
					
  if (isNull(@i_projectkey,0) > 0)
  begin
     select @v_sqlfrom = @v_sqlfrom + ' and tpt.taqprojectkey = tpe.taqprojectkey '
  end
  
  if (isNull(@i_bookkey,0) > 0)
  begin
     select @v_sqlfrom = @v_sqlfrom + ' and tpt.bookkey = tpe.bookkey and tpt.printingkey = tpe.printingkey '
  end
  
  select @v_sqlfrom = @v_sqlfrom + ' left join gentables gt on ( gt.tableid = 587 and gt.datacode = tpt.stagecode )
					                 left join globalcontact gc1 on tpt.globalcontactkey = gc1.globalcontactkey 
						             left join globalcontact gc2 on tpt.globalcontactkey2 = gc2.globalcontactkey
						             LEFT OUTER JOIN coreprojectinfo cp ON tpt.taqprojectkey = cp.projectkey 
								     LEFT OUTER JOIN coretitleinfo ct ON tpt.bookkey = ct.bookkey AND tpt.printingkey = ct.printingkey 
									 LEFT OUTER JOIN printing p ON tpt.bookkey = p.bookkey AND tpt.printingkey = p.printingkey '

  select @v_sqlwhere =	' where tpt.taqElementKey = ' + convert(varchar(10), @i_elementkey)

  -- Add on the filters if they were there

  if (isNull(@i_TaskViewKey,0) > 0)
  begin
    select @v_alldatetypesind = COALESCE(alldatetypesind,0)
      from taskview
     where taskviewkey = @i_taskviewkey
     
    if @v_alldatetypesind = 1 
    begin
	    select @v_sqlselect = @v_sqlselect + ', -1 as taskviewkey, -1 as taskgroupind, 0 as taskview_sort '
    end
    else begin
	    select @v_sqlselect = @v_sqlselect + ', tv.taskviewkey, tv.taskgroupind, tvdt.sortorder taskview_sort '
	    select @v_sqlfrom = @v_sqlfrom + ' join TaskViewDateType tvdt '
	                          + ' on tpt.datetypecode = tvdt.datetypecode and tvdt.taskviewkey = ' + convert(varchar(10), @i_taskviewkey) 
                            + ' join TaskView tv on tv.TaskViewKey = ' + convert(varchar(10), @i_taskviewkey)
	  end

  end
  else
  begin
	select @v_sqlselect = @v_sqlselect + ', -1 as taskviewkey, -1 as taskgroupind, 0 as taskview_sort '
  end

  if ( isNull(@i_projectKey,0) > 0 )
  begin
	select @v_sqlwhere = @v_sqlwhere + ' and tpt.taqprojectkey = ' + convert(varchar(10), @i_projectKey)
  end

  if ( isNull(@i_bookkey, 0) > 0 )
  begin
	select @v_sqlwhere = @v_sqlwhere + ' and tpt.bookkey = ' + convert(varchar(10), @i_bookkey)
  end

  if ( isNull(@i_stagekey, 0) > 0 )
  begin
	select @v_sqlwhere = @v_sqlwhere + ' and tpt.stagecode = ' + convert(varchar(10), @i_stagekey)
  end

  if ( isNull(@i_contactkey, 0) > 0 )
  begin
	select @v_sqlwhere = @v_sqlwhere +	' and ( tpt.globalcontactkey = ' + convert(varchar(10), @i_contactkey) +
										' or tpt.globalcontactkey2 = ' + convert(varchar(10), @i_contactkey) + ')'
  end

  if ( isNull(@i_rolecode, 0) > 0 )
  begin
	select @v_sqlwhere = @v_sqlwhere +	' and ( tpt.rolecode = ' + convert(varchar(10), @i_rolecode) +
										' or tpt.rolecode2 = ' + convert(varchar(10), @i_rolecode)
  end

   
  SET @v_sqlorderby = ' order by tpt.stagecode '

  -- Set and execute the full sqlstring
  SET @v_sqlstring = @v_sqlselect + @v_sqlfrom + @v_sqlwhere + @v_sqlorderby

print '=============================='
print @v_sqlstring
print '=============================='
      
  EXECUTE sp_executesql @v_sqlstring

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error finding tasks: taskviewkey=' + CAST(@i_taskviewkey AS VARCHAR)
  END 

GO
GRANT EXEC ON qelement_get_element_tasklist TO PUBLIC
GO



