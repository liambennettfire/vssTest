if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qutl_get_overdue_project_tasks') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qutl_get_overdue_project_tasks
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
declare @err int
declare @dsc varchar(2000)
exec qutl_get_overdue_project_tasks 0, 6, 1, 3, @err, @dsc
*/

CREATE PROCEDURE [dbo].[qutl_get_overdue_project_tasks]
 (@i_userkey        integer,
  @i_numDaysfilter	integer,  -- 6 (see gentables)
  @i_userOrGroup	integer,  --"0" = "My User ID" and "1" = "My User Group"
  @i_GlobalRoleAs	integer,  --"0" = Project Owner, "1" = Contact 1, "2" = Contact 2, "3" = All
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS


/******************************************************************************
**  File: qutl_get_overdue_project_tasks.sql
**  Name: qutl_get_overdue_project_tasks
**
**  Desc: This stored procedure returns all project tasks with a 
**        date earlier than today and an actualind set to 0.
**              
**    Auth: Alan Katzen
**    Date: 28 May 2004
**
**	MODIFIED:
**  04/1/2008 - LISA - Added new parameters to make this work for the Task Tickler
**				feature.  Added select criteria (dropdowns) to the panel
**				(OverdueProjectTasks.ascx).  When selected, limits the ovedue tasks
**				returned by # of days, user or group, and project contact type.
**				See DUP Dev case #5195.
**
**  10/27/2008 - LISA - had to make this work with Titles/Books.  Modified it to
**              return a combined list which is then displayed in OverdueProjectTasks.ascx.
**              If the task has BOTH project and book keys, the project title is dislayed
**              on one line and the title on a second line. Case # 05664
**   
**  10/30/2008 - LISA - making changes requested by QA for case 05664 
**              
** 2.  In the 'For:' dropdown, the selection 'My User Group' should display titles 
**     as well as projects.
** 
** 3.  In the 'As:' dropdown, when I select Contact1 or Contact2, it is returning my 
**     project even though the tasks in the project do not have a Contact 
**
**  2/08/2011 - Kusum -  CAse 14376 -Modified to add a sort (date asc, project/title, task)
**  04/28/2016 - Uday -  CAse 37340 -Modified to get readonly orglevel security for a titles tasks
*******************************************************************************/

  DECLARE @error_var    INT
  DECLARE @rowcount_var INT
  DECLARE @CurrDate		datetime
  DECLARE @sqlCmd		varchar(max)
  DECLARE @finalSQLCmd	varchar(max)
  DECLARE @forSQL		varchar(max)
  DECLARE @asSQL		varchar(max)
  DECLARE @FromDate		varchar(30)
  DECLARE @ToDate		varchar(30)
  DECLARE @tempDate		datetime
  DECLARE @ToDays		int
  DECLARE @KeyList      varchar(max) -- output list of globalcontactkeys valid when "My User Group" was selected
  DECLARE @Numkeys      int
  DECLARE @RowCount     int
  DECLARE @v_quote      VARCHAR(2)

  SET @v_quote = ''''

  SET @o_error_code = 0
  SET @o_error_desc = ''

  -- Deal with the date range
  -- Get a default, this should never happen, the user should always select a number of days filter
  if ( @i_numDaysfilter is null ) select @i_numDaysfilter = ( select datacode from gentables where tableid = 589 and datadesc = 'Overdue' )

  select @CurrDate = getDate()
  select @FromDate = (SELECT DATEADD(day, (select numericdesc1 from gentables where tableid = 589 and datacode = @i_numDaysfilter), getdate())  )
  select @ToDays = (select numericdesc2 from gentables where tableid = 589 and datacode = @i_numDaysfilter)
  select @ToDate = (SELECT DATEADD(day, @ToDays, getdate())  )

  -- swap dates for 'between' usage below
  if ( @ToDays <= 0 )
  begin
	select @tempDate = @FromDate
	select @FromDate = @ToDate
	select @ToDate = @tempDate
  end

  select @FromDate =  (select Convert(varchar(3), Datepart(mm, @FromDate)) + '/' +
							Convert(varchar(3), DatePart(dd, @FromDate)) + '/' +
							Convert(varchar(4), Datepart(yyyy, @FromDate)) + ' 00:00')

  select @ToDate = (select Convert(varchar(3), Datepart(mm, @ToDate)) + '/' +
							Convert(varchar(3), DatePart(dd, @ToDate)) + '/' +
							Convert(varchar(4), Datepart(yyyy, @ToDate)) + ' 12:59')

--print 'FromDate = ' + @FromDate
--print 'ToDate = ' + @ToDate

  -- Determine the "For:" dropdown selection using @forSql
  -- The following values 0 = "My User ID" and 1 = "My User Group" are hard-coded in the HTML drop down lis
  -- This is the list of globalcontactkey(2) linked to the incoming userkey (login user)
  -- or in the accesstouser list of this userkey 
  create table #accessList (  RowID int IDENTITY(1, 1), globalcontactkey varchar(20) )

  -- For: "My User ID"
  insert into #accessList 
    select distinct globalcontactkey from globalcontact where userid = @i_userkey

  -- need a default if nothing is set up
  insert into #accessList ( globalcontactkey ) values ( -2 )
  
  
  -- For: "My User Group"
  if (@i_userOrGroup > 0) 
  BEGIN
    insert into #accessList 
      select distinct globalcontactkey from globalcontact where userid in
        ( select accesstouserkey from qsiprivateuserlist where primaryuserkey = @i_userkey )
  END
  
  -- Get the number of records in the temporary table
  SET @Numkeys = ( select count(*) from #accesslist )
 
 --print 'Number of globalcontact keys = ' + convert(varchar(20), @Numkeys)
 
  SET @RowCount = 1
  SET @KeyList = ''
   
  -- loop through all records in the temporary table to build list of globalcontactkeys 
  WHILE @RowCount <= @Numkeys
  BEGIN
    IF ( LEN(@KeyList) > 0 )
      select @KeyList = @KeyList + ', ' + ( select globalcontactkey from #accesslist where RowID = @RowCount )
    ELSE
      select @KeyList = ( select globalcontactkey from #accesslist where RowID = @RowCount )

    SET @RowCount = @RowCount + 1
  END

  -- drop the temporary table
  DROP TABLE #accessList
  
  if (@o_error_code <> 0) GOTO ExitHandler
  
  -- Create the basic select statement
  select @sqlCmd = '	SELECT t.taqtaskkey, t.globalcontactkey, t.taqprojectkey as projectkey, t.bookkey, t.printingkey, t.keyind,
                        COALESCE(d.datelabel, d.description) AS datelabel, 
                        COALESCE(d.usedexclusivelybycsind,0) usedexclusivelybycsind,
                        CASE 
                          WHEN t.bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(' + cast(@i_userkey as varchar) + ','+ @v_quote + 'tasktracking'+ @v_quote + ',323,t.datetypecode,t.bookkey,t.printingkey,0)
                          ELSE 2
                        END accesscode,
					    CASE 
						 WHEN t.bookkey > 0 THEN dbo.qutl_get_user_orgsecurity(' + cast(@i_userkey as varchar) + ', (SELECT TOP(1) b.orgentrykey
						   FROM orglevel o 
						   LEFT OUTER JOIN bookorgentry b ON o.orglevelkey = b.orglevelkey AND b.bookkey = t.bookkey 
						   ORDER BY o.orglevelkey))
					    END userorgaccesscode,                        
                        COALESCE(t.activedate,t.originaldate) AS bestdate, 
                        c2.projecttitle as ProjectTitle, c.title as BookTitle,
                        isnull(t.actualind,0) as actualind, c2.searchitemcode as projectitemcode,
                        CASE WHEN t.taqprojectkey > 0 and t.bookkey > 0
                          THEN rtrim(ltrim(c2.projecttitle)) + ''<br>'' + rtrim(ltrim(c.title))
                          ELSE   
                            CASE WHEN t.taqprojectkey > 0 
                              THEN rtrim(ltrim(c2.projecttitle))
                              ELSE rtrim(ltrim(c.title))
                            END
                        END AS FullTitleDesc,
                        t.taqprojectkey, 
                        d.triggerdateind,                        
                        t.datetypecode,
                        COALESCE(t.activedate,t.originaldate) AS activedate,
                        COALESCE(t.activedate,t.originaldate) AS origactivedate,
                        c2.projecttitle as projectname, 
                        c.title,
                        t.sortorder                          
						FROM taqprojecttask t 
						JOIN datetype d on t.datetypecode = d.datetypecode
						LEFT JOIN coretitleinfo c on t.bookkey = c.bookkey AND t.printingkey = c.printingkey 
						JOIN coreprojectinfo c2 on t.taqprojectkey = c2.projectkey
						WHERE (t.actualind = 0 OR t.actualind IS NULL) 
							AND (c.standardind = ''N'' OR c.standardind IS NULL)  
							AND (c2.templateind = 0 OR c2.templateind IS NULL)
              AND (c2.projectstatus <> (select datacode from gentables where tableid = 522 and qsicode = 1))'
  
  -- Add the "Due:" dropdown day range selection
  select @sqlCmd = @sqlCmd + ' AND COALESCE(t.activedate,t.originaldate) between '
  select @sqlCmd = @sqlCmd + ' convert(datetime, ''' + @FromDate + ''', 101) and convert(datetime, ''' + @ToDate + ''', 101)'

  -- Determine the "As:" dropdown selection using @asSQL, it will drive where the "For:" selections pull from
  -- The following values are also hard-coded in the HTML drop down list of OverdueProjectTasks.ascx.
  -- "0" = Project Owner, "1" = Contact 1, "2" = Contact 2, "3" = All
  --
  if (@i_GlobalRoleAs = 0) -- Project Owner
  begin
    if (@i_userOrGroup = 0) -- UserID only NOT group
    begin
	    select @asSQL = ' AND ( c2.projectownerkey = ' + convert(varchar(8), @i_userkey) + ' ) '
	end
	else
	begin
	    select @asSQL = ' AND ( c2.projectownerkey = ' + convert(varchar(8), @i_userkey) + ' or c2.projectownerkey in ( select accesstouserkey from qsiprivateuserlist where primaryuserkey = ' + convert(varchar(8), @i_userkey) + ' ) ) '
	end
  end 
  else if (@i_GlobalRoleAs = 1) -- Contact 1
  begin
	select @asSQL = ' AND t.globalcontactkey in ( ' + @KeyList + ' )'
  end
  else if (@i_GlobalRoleAs = 2) -- Contact 2
  begin
	select @asSQL = ' AND t.globalcontactkey2 in ( ' + @KeyList + ' )'
  end
  else if (@i_GlobalRoleAs = 3) -- Project Owner OR Contact 1 OR Contact 2  (ALL)
  begin
    select @asSQL = ' AND ( c2.projectownerkey = ' + convert(varchar(8), @i_userkey)
	select @asSQL = ' AND ( t.taqprojectkey in ( select distinct taqprojectkey from taqproject where taqprojectownerkey = ' + convert(varchar(8), @i_userkey) + ' ) '
	select @asSQL = @asSQL + ' OR t.globalcontactkey in ( ' + @KeyList + ' ) '
	select @asSQL = @asSQL + ' OR t.globalcontactkey2 in ( ' + @KeyList + ' ) )'
  end

  -- This is for PROJECTS
  select @finalSQLCmd = @sqlCmd + @asSQL

  -- Now build the 2nd select for Titles

  -- Create the basic select statement
  select @sqlCmd = '	SELECT t.taqtaskkey, t.globalcontactkey, t.taqprojectkey as projectkey, t.bookkey, t.printingkey, t.keyind,
                        COALESCE(d.datelabel, d.description) AS datelabel, 
                        COALESCE(d.usedexclusivelybycsind,0) usedexclusivelybycsind,
                        CASE 
                          WHEN t.bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(' + cast(@i_userkey as varchar) + ','+ @v_quote + 'tasktracking'+ @v_quote + ',323,t.datetypecode,t.bookkey,t.printingkey,0)
                          ELSE 2
                        END accesscode,
					    CASE 
						 WHEN t.bookkey > 0 THEN dbo.qutl_get_user_orgsecurity(' + cast(@i_userkey as varchar) + ', (SELECT TOP(1) b.orgentrykey
						   FROM orglevel o 
						   LEFT OUTER JOIN bookorgentry b ON o.orglevelkey = b.orglevelkey AND b.bookkey = t.bookkey 
						   ORDER BY o.orglevelkey))
					    END userorgaccesscode,                          
                        COALESCE(t.activedate,t.originaldate) AS bestdate, 
                        c2.projecttitle as ProjectTitle, c.title as BookTitle,
                        isnull(t.actualind,0) as actualind, coalesce(c2.searchitemcode,0) as projectitemcode,
                        CASE WHEN t.taqprojectkey > 0 and t.bookkey > 0
                          THEN rtrim(ltrim(c2.projecttitle)) + ''<br>'' + rtrim(ltrim(c.title))
                          ELSE   
                            CASE WHEN t.taqprojectkey > 0 
                              THEN rtrim(ltrim(c2.projecttitle))
                              ELSE rtrim(ltrim(c.title))
                            END
                        END AS FullTitleDesc,
                        t.taqprojectkey, 
                        d.triggerdateind,                        
                        t.datetypecode,
                        COALESCE(t.activedate,t.originaldate) AS activedate,
                        COALESCE(t.activedate,t.originaldate) AS origactivedate,
                        c2.projecttitle as projectname, 
                        c.title,
                        t.sortorder                                                   
						FROM taqprojecttask t 
						JOIN datetype d on t.datetypecode = d.datetypecode
						JOIN coretitleinfo c on t.bookkey = c.bookkey AND t.printingkey = c.printingkey
						LEFT JOIN coreprojectinfo c2 on t.taqprojectkey = c2.projectkey
						WHERE isnull(t.taqprojectkey,0) = 0 AND (t.actualind = 0 OR t.actualind IS NULL) 
							AND (c.standardind = ''N'' OR c.standardind IS NULL)  
							AND (c2.templateind = 0 OR c2.templateind IS NULL)
              AND (c2.projectstatus <> (select datacode from gentables where tableid = 522 and qsicode = 1) OR c2.projectstatus IS NULL)'

  
  -- Add the "Due:" dropdown day range selection
  select @sqlCmd = @sqlCmd + ' AND COALESCE(t.activedate,t.originaldate) between '
  select @sqlCmd = @sqlCmd + ' convert(datetime, ''' + @FromDate + ''', 101) and convert(datetime, ''' + @ToDate + ''', 101)'

  -- "option 0, 'Project Owner' Lisa 10/27/08 not used for titles, we don't have an owner key on coretitleinfo
  if (@i_GlobalRoleAs = 1) -- Contact 1
  begin
	select @asSQL = ' AND t.globalcontactkey in ( ' + @KeyList + ' )'
  end
  else if (@i_GlobalRoleAs = 2) -- Contact 2
  begin
	select @asSQL = ' AND t.globalcontactkey2 in ( ' + @KeyList + ' )'
  end
  else if (@i_GlobalRoleAs = 3) -- Contact 1 OR Contact 2  (ALL)
  begin
	select @asSQL = ' AND ( t.globalcontactkey in ( ' + @KeyList + ' ) '
	select @asSQL = @asSQL + ' OR t.globalcontactkey2 in ( ' + @KeyList + ' ) )'
  end
  
  -- If globalroleas is 0 "project contact", don't return and titles.  We don't have an owner for a title
  if ( @i_GlobalRoleAs > 0 ) 
  begin
    select @sqlCmd = @sqlCmd + @asSQL
    select @finalSQLCmd = @finalSQLCmd + ' UNION ' + @sqlCmd
     select @finalSQLCmd = @finalSQLCmd + ' order by bestdate asc, projecttitle asc, booktitle asc, datelabel asc'
  end
  
--print @finalSQLCmd
  exec (@finalSQLCmd)
  
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Error looking for overdue project tasks: userkey = ' + cast(@i_userkey AS VARCHAR) 
  END 

ExitHandler:
  IF ( @o_error_code <> 0 )
  BEGIN
    print 'Error returned: ' + @o_error_desc
  END
  
GO
GRANT EXEC ON qutl_get_overdue_project_tasks TO PUBLIC
GO


