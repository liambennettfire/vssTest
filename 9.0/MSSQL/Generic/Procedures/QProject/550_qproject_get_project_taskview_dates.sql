if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_project_taskview_dates') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_project_taskview_dates
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
DECLARE @err int,
@dsc varchar(2000)

--exec qutl_get_default_taskview 0, 1, 0, @err, @dsc
exec qproject_get_project_taskview_dates '', '', '601495', 604451, 0,0,0,0,0,0,1,0, @err, @dsc
*/

CREATE PROCEDURE qproject_get_project_taskview_dates
 (@i_projectkeylist varchar(max),
  @i_contactkeylist varchar(max),
  @i_bookkeylist    varchar(max),
  @i_taskviewkey    integer,
  @i_elementtype    integer,
  @i_elementsubtype integer,
  @i_contactkey     integer,
  @i_rolecode       integer,
  @i_printingnum    integer,
  @i_taqelementkey  integer,
  @i_datetypecode   integer,
  @i_keyind         bit,
  @i_dropdownuse    bit,
  @i_userkey        integer,
  @i_startdate      datetime = null,
  @i_enddate        datetime = null,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_project_taskview_dates
**  Desc: This stored procedure returns all dates for a given project
**        and taskviewkey (task group) from the taqprojecttask table.
**        If non-zero Element Type/Subtype, Participant, Elementkey, or KeyInd
**        is passed, data is further filtered.
**
**    Auth: Kate
**    Date: 5/30/04
**
**------- Changes ------------------------------------------------------------
** 01/08/09 - Lisa - added a column for origactivedate to allow us to pass the
**                   value through as original date if the user has blanked
**                   the original date then subsequently changes the active date
**                   as well. see case 5831.
**                   
*******************************************************************************/

  DECLARE
    @v_quote    VARCHAR(2),
    @v_sqlselect1  VARCHAR(4000),
    @v_sqlselect2  VARCHAR(4000),
    @v_sqlfrom1    VARCHAR(2000),
    @v_sqlfrom2    VARCHAR(2000),
    @v_sqlwhere1   VARCHAR(max),
    @v_sqlwhere2   VARCHAR(max),
    @v_sqlwhere_keys  VARCHAR(max),
    @v_sqlstring  NVARCHAR(max),
    @v_tasksourcetable  VARCHAR(100),
    @error_var  INT,
    @rowcount_var INT,
    @v_alldatetypesind INT

  SET @v_quote = ''''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  -- must have at least one list of keys
  IF (@i_projectkeylist is null OR ltrim(rtrim(@i_projectkeylist)) = '') AND
     (@i_contactkeylist is null OR ltrim(rtrim(@i_contactkeylist)) = '') AND
     (@i_bookkeylist is null OR ltrim(rtrim(@i_bookkeylist)) = '') BEGIN
    return
  END
  -- ***** Build the dynamic SQL which will be used to retrieve tasks ***** --
  IF @i_dropdownuse = 1
    BEGIN
      -- For drop-downs, get distict dates existing on this project/title
      SET @v_sqlselect1 = 'SELECT DISTINCT d.datetypecode,COALESCE(d.usedexclusivelybycsind,0) usedexclusivelybycsind,
         CASE 
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel))=' + @v_quote + @v_quote + ' THEN d.description
          ELSE d.datelabel
         END datelabel,
         CASE 
          WHEN t.bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(' + cast(@i_userkey as varchar) + ','+ @v_quote + 'tasktracking'+ @v_quote + ',323,t.datetypecode,t.bookkey,t.printingkey,0)
          ELSE 2
         END accesscode '
      
      SET @v_sqlfrom1 = ' FROM taqprojecttask t,datetype d'

      SET @v_sqlwhere1 = ' WHERE t.datetypecode = d.datetypecode '      
    END
  ELSE  
    BEGIN
      -- If not drop-down, by default get all values needed for Task Tracking views
      -- UNION SQL: Element tasks + non-Element tasks
      
      -- Element tasks
      SET @v_sqlselect1 = 'SELECT CASE
        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel))=' + @v_quote + @v_quote + ' THEN d.description
        ELSE d.datelabel
       END datelabel,
       CASE 
        WHEN t.bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(' + cast(@i_userkey as varchar) + ','+ @v_quote + 'tasktracking'+ @v_quote + ',323,t.datetypecode,t.bookkey,t.printingkey,0)
        ELSE 2
       END accesscode,
      d.datetypecode,COALESCE(d.usedexclusivelybycsind,0) usedexclusivelybycsind,COALESCE(d.milestoneind, 0) milestoneind,t.taqprojectkey,t.taqtaskkey,
      t.taqelementkey,t.activedate,t.actualind,t.originaldate,COALESCE(t.activedate,t.originaldate) bestdate,
      t.decisioncode,t.paymentamt,t.taqtaskqty,COALESCE(t.taqprojectformatkey,0) taqprojectformatkey,t.keyind,
      e.taqelementtypecode,e.taqelementtypesubcode,e.taqelementnumber,t.transactionkey,
      e.taqelementdesc elementdesc,t.globalcontactkey,t.rolecode,t.globalcontactkey2,t.rolecode2,
      dbo.qcontact_get_displayname(t.globalcontactkey) contactname1,
      dbo.qcontact_get_displayname(t.globalcontactkey2) contactname2,
      ltrim(rtrim(COALESCE(gc1.lastname, ' + @v_quote + @v_quote + '))) lastname1,
      ltrim(rtrim(COALESCE(gc2.lastname,' + @v_quote + @v_quote + '))) lastname2,      
      t.scheduleind,t.lag,
      t.stagecode,t.duration,t.lockind,t.bookkey,t.printingkey,p.printingnum,t.taqtasknote, 
      cp.projecttitle projectname,ct.title,
      CASE WHEN LEN(taqtasknote) > 6 THEN
       CAST(t.taqtasknote AS VARCHAR(6)) + ' + @v_quote + '...' + @v_quote +
      ' ELSE t.taqtasknote END AS note, t.activedate as origactivedate, t.originaldate as origorigdate,
      CASE WHEN e.taqelementtypesubcode > 0 THEN 
      ltrim(rtrim(COALESCE(dbo.get_gentables_desc(287,e.taqelementtypecode,null),'' '')))+''/''+  
      ltrim(rtrim(COALESCE(dbo.get_subgentables_desc(287,e.taqelementtypecode,e.taqelementtypesubcode,null),'' ''))) 
      ELSE ltrim(rtrim(COALESCE(dbo.get_gentables_desc(287,e.taqelementtypecode,null),'' ''))) END AS elementtypedesc,
      ct.formatname as titleformat, ct.productnumber as productnumber, t.reviseddate, t.startdate, t.startdateactualind, 
      dbo.qproject_taskoverride_exists_for_element(t.taqtaskkey,t.taqelementkey) taskoverrideexistsforelement, 
      dbo.qproject_taskoverride_exists_for_task(t.taqtaskkey) taskoverrideexistsfortask '
              
      SET @v_tasksourcetable = 'taqprojecttask t '
      IF (@i_taqelementkey > 0) OR (@i_taqelementkey = 0 AND @i_elementtype > 0)
        SET @v_tasksourcetable = 'taqprojecttaskelement_view t '
        
	    SET @v_sqlfrom1 = ' FROM datetype d, ' + @v_tasksourcetable +
        'LEFT OUTER JOIN taqprojectelement e ON t.taqelementkey = e.taqelementkey ' +
        'LEFT OUTER JOIN coreprojectinfo cp ON t.taqprojectkey = cp.projectkey ' +
        'LEFT OUTER JOIN coretitleinfo ct ON t.bookkey = ct.bookkey AND t.printingkey = ct.printingkey '  +
        'LEFT OUTER JOIN printing p ON t.bookkey = p.bookkey AND t.printingkey = p.printingkey ' +
		'LEFT OUTER JOIN (select distinct taqtaskkey from taqprojecttaskoverride) AS tok ON tok.taqtaskkey = t.taqtaskkey ' +
		'LEFT OUTER JOIN (select distinct globalcontactkey, lastname from globalcontact) AS gc1 ON gc1.globalcontactkey = t.globalcontactkey ' +	 	
		'LEFT OUTER JOIN (select distinct globalcontactkey, lastname from globalcontact) AS gc2 ON gc2.globalcontactkey = t.globalcontactkey2'				

      SET @v_sqlwhere1 = ' WHERE t.datetypecode = d.datetypecode'

      IF COALESCE(@i_taqelementkey,0) = 0 BEGIN
        SET @v_sqlwhere1 = @v_sqlwhere1 + ' AND (t.taqelementkey > 0 OR tok.taqtaskkey IS NOT NULL) '
      END
      
      -- Non-Element tasks
      SET @v_sqlselect2 = 'SELECT CASE
        WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel))=' + @v_quote + @v_quote + ' THEN d.description
        ELSE d.datelabel
       END datelabel,
       CASE 
        WHEN t.bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(' + cast(@i_userkey as varchar) + ','+ @v_quote + 'tasktracking'+ @v_quote + ',323,t.datetypecode,t.bookkey,t.printingkey,0)
        ELSE 2
       END accesscode,
      d.datetypecode,COALESCE(d.usedexclusivelybycsind,0) usedexclusivelybycsind,COALESCE(d.milestoneind, 0) milestoneind,t.taqprojectkey,t.taqtaskkey,
      t.taqelementkey,t.activedate,t.actualind,t.originaldate,COALESCE(t.activedate,t.originaldate) bestdate,
      t.decisioncode,t.paymentamt,t.taqtaskqty,COALESCE(t.taqprojectformatkey,0) taqprojectformatkey,t.keyind,
      NULL,NULL,NULL,t.transactionkey,
      NULL elementdesc,t.globalcontactkey,t.rolecode,t.globalcontactkey2,t.rolecode2,
      dbo.qcontact_get_displayname(t.globalcontactkey) contactname1,
      dbo.qcontact_get_displayname(t.globalcontactkey2) contactname2,
      ltrim(rtrim(COALESCE(gc1.lastname,' + @v_quote + @v_quote + '))) lastname1,
      ltrim(rtrim(COALESCE(gc2.lastname,' + @v_quote + @v_quote + '))) lastname2,      
      t.scheduleind,t.lag,t.stagecode,t.duration,t.lockind,t.bookkey,t.printingkey,p.printingnum,t.taqtasknote, 
      cp.projecttitle projectname,ct.title,
      CASE WHEN LEN(taqtasknote) > 6 THEN
       CAST(t.taqtasknote AS VARCHAR(6)) + ' + @v_quote + '...' + @v_quote +
      ' ELSE t.taqtasknote END AS note, t.activedate as origactivedate, t.originaldate as origorigdate,
      null elementtypedesc, ct.formatname as titleformat, ct.productnumber as productnumber, t.reviseddate, t.startdate, t.startdateactualind,
      0 taskoverrideexistsforelement, 
      0 taskoverrideexistsfortask '      

	    SET @v_sqlfrom2 = ' FROM datetype d, taqprojecttask t ' +
      'LEFT OUTER JOIN coreprojectinfo cp ON t.taqprojectkey = cp.projectkey ' +
      'LEFT OUTER JOIN coretitleinfo ct ON t.bookkey = ct.bookkey AND t.printingkey = ct.printingkey '  +
      'LEFT OUTER JOIN printing p ON t.bookkey = p.bookkey AND t.printingkey = p.printingkey ' +
	  'LEFT OUTER JOIN (select distinct taqtaskkey from taqprojecttaskoverride) AS tok ON tok.taqtaskkey = t.taqtaskkey ' +
	  'LEFT OUTER JOIN (select distinct globalcontactkey, lastname from globalcontact) AS gc1 ON gc1.globalcontactkey = t.globalcontactkey ' +		
	  'LEFT OUTER JOIN (select distinct globalcontactkey, lastname from globalcontact) AS gc2 ON gc2.globalcontactkey = t.globalcontactkey2'		   

      SET @v_sqlwhere2 = ' WHERE t.datetypecode = d.datetypecode AND t.taqelementkey IS NULL AND tok.taqtaskkey IS NULL '
        
      -- ******* Add additional filters (only when not drop-down) ******* --
      -- *** Element Type/Description ***
      IF @i_elementtype > 0 OR @i_taqelementkey > 0
      BEGIN        
        -- When element type was passed, must filter by Element Type
        IF @i_elementtype > 0
        BEGIN
          SET @v_sqlwhere1 = @v_sqlwhere1 +
            ' AND e.taqelementtypecode = ' + CAST(@i_elementtype AS VARCHAR)
        END
        
        -- When element subtype was passed, must also filter by Element Subtype
        IF @i_elementsubtype > 0
        BEGIN
          SET @v_sqlwhere1 = @v_sqlwhere1 + 
            ' AND e.taqelementtypesubcode = ' + CAST(@i_elementsubtype AS VARCHAR)
        END
      
        -- When taqelementkey was passed, must also filter by it
        IF @i_taqelementkey > 0
        BEGIN
          SET @v_sqlwhere1 = @v_sqlwhere1 + 
            ' AND t.taqelementkey = ' + CAST(@i_taqelementkey AS VARCHAR)
        END
      END
            
      -- *** Participant ***
      IF @i_contactkey > 0
      BEGIN
        SET @v_sqlwhere1 = @v_sqlwhere1 + 
          ' AND (t.globalcontactkey=' + CAST(@i_contactkey AS VARCHAR) +
          ' OR t.globalcontactkey2=' + CAST(@i_contactkey AS VARCHAR) + ')'
          
        SET @v_sqlwhere2 = @v_sqlwhere2 + 
          ' AND (t.globalcontactkey=' + CAST(@i_contactkey AS VARCHAR) +
          ' OR t.globalcontactkey2=' + CAST(@i_contactkey AS VARCHAR) + ')'          
      END

      -- *** Role ***
      IF @i_rolecode > 0
      BEGIN
        SET @v_sqlwhere1 = @v_sqlwhere1 + 
          ' AND (t.rolecode=' + CAST(@i_rolecode AS VARCHAR) +
          ' OR t.rolecode2=' + CAST(@i_rolecode AS VARCHAR) + ')'
          
        SET @v_sqlwhere2 = @v_sqlwhere2 + 
          ' AND (t.rolecode=' + CAST(@i_rolecode AS VARCHAR) +
          ' OR t.rolecode2=' + CAST(@i_rolecode AS VARCHAR) + ')'          
      END
      
      -- *** Printing Number ***
      IF @i_printingnum > 0
      BEGIN
        IF @i_printingnum = 9999  -- max printing
        BEGIN
          SET @v_sqlwhere1 = @v_sqlwhere1 + 
            ' AND (p.printingnum in (select max(printingnum) from printing x where x.bookkey = t.bookkey)) '

          SET @v_sqlwhere2 = @v_sqlwhere2 + 
            ' AND (p.printingnum in (select max(printingnum) from printing x where x.bookkey = t.bookkey)) '
        END
        ELSE BEGIN
          SET @v_sqlwhere1 = @v_sqlwhere1 + 
            ' AND (p.printingnum=' + CAST(@i_printingnum AS VARCHAR) + ')'
            
          SET @v_sqlwhere2 = @v_sqlwhere2 + 
            ' AND (p.printingnum=' + CAST(@i_printingnum AS VARCHAR) + ')'          
        END
      END
            
      -- *** Task/Date Type ***
      IF @i_datetypecode > 0
      BEGIN
        SET @v_sqlwhere1 = @v_sqlwhere1 + 
          ' AND d.datetypecode=' + CAST(@i_datetypecode AS VARCHAR)
          
        SET @v_sqlwhere2 = @v_sqlwhere2 + 
          ' AND d.datetypecode=' + CAST(@i_datetypecode AS VARCHAR)
      END
      
      -- *** Key indicator ***
      IF @i_keyind > 0
      BEGIN
        SET @v_sqlwhere1 = @v_sqlwhere1 + ' AND t.keyind=1'
        
        SET @v_sqlwhere2 = @v_sqlwhere2 + ' AND t.keyind=1'
      END        

      -- *** Date Range ***
      IF @i_startdate is not null OR @i_enddate is not null
      BEGIN
      
      --CONVERT(datetime,CONVERT(varchar,'Jan  1 2009 12:00AM', 101),101)
      
      
        IF @i_startdate is not null AND @i_enddate is not null
        BEGIN
          SET @v_sqlwhere1 = @v_sqlwhere1 + ' AND t.activedate BETWEEN ' + @v_quote + CONVERT(varchar,@i_startdate) + @v_quote + ' AND ' + @v_quote + CONVERT(varchar,@i_enddate) + @v_quote
          
          SET @v_sqlwhere2 = @v_sqlwhere2 + ' AND t.activedate BETWEEN ' + @v_quote + CONVERT(varchar,@i_startdate) + @v_quote + ' AND ' + @v_quote + CONVERT(varchar,@i_enddate) + @v_quote
        END
        ELSE IF @i_startdate is not null 
        BEGIN
          SET @v_sqlwhere1 = @v_sqlwhere1 + ' AND t.activedate >= ' + @v_quote + CONVERT(varchar,@i_startdate) + @v_quote
          
          SET @v_sqlwhere2 = @v_sqlwhere2 + ' AND t.activedate >= ' + @v_quote + CONVERT(varchar,@i_startdate) + @v_quote
        END
        ELSE IF @i_enddate is not null
        BEGIN
          SET @v_sqlwhere1 = @v_sqlwhere1 + ' AND t.activedate <= ' + @v_quote + CONVERT(varchar,@i_enddate) + @v_quote
          
          SET @v_sqlwhere2 = @v_sqlwhere2 + ' AND t.activedate <= ' + @v_quote + CONVERT(varchar,@i_enddate) + @v_quote
        END
      END        
    END

  -- add in keylists
  SET @v_sqlwhere_keys = '('
  IF (@i_projectkeylist is not null AND ltrim(rtrim(@i_projectkeylist)) <> '') BEGIN
    IF @v_sqlwhere_keys = '(' BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' (t.taqprojectkey in (' + @i_projectkeylist + '))'
    END
    ELSE BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' OR (t.taqprojectkey in (' + @i_projectkeylist + '))'
    END
  END

  IF (@i_contactkeylist is not null AND ltrim(rtrim(@i_contactkeylist)) <> '') BEGIN
    IF @v_sqlwhere_keys = '(' BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' (t.globalcontactkey in (' + @i_contactkeylist + ') OR '
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' t.globalcontactkey2 in (' + @i_contactkeylist + '))'
    END
    ELSE BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' OR (t.globalcontactkey in (' + @i_contactkeylist + ') OR '
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' t.globalcontactkey2 in (' + @i_contactkeylist + '))'
    END
  END

  IF (@i_bookkeylist is not null AND ltrim(rtrim(@i_bookkeylist)) <> '') BEGIN
    IF @v_sqlwhere_keys = '(' BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' (t.bookkey in (' + @i_bookkeylist + '))'
    END
    ELSE BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' OR (t.bookkey in (' + @i_bookkeylist + '))'
    END
  END      
  SET @v_sqlwhere_keys = @v_sqlwhere_keys + ')'
  
  SET @v_sqlwhere1 = @v_sqlwhere1 + ' AND ' + @v_sqlwhere_keys
  SET @v_sqlwhere2 = @v_sqlwhere2 + ' AND ' + @v_sqlwhere_keys
            
  -- When taskviewkey was passed, must limit results to only this view's tasks  
  IF (@i_taskviewkey > 0)
  BEGIN
    SELECT @v_alldatetypesind = COALESCE(alldatetypesind,0)
      FROM taskview
     WHERE taskviewkey = @i_taskviewkey
     
    IF @v_alldatetypesind = 1 BEGIN
      -- For 'All Tasks' view (alldatetypesind=1), order dates by datetype's sortorder
      SET @v_sqlselect1 = @v_sqlselect1 + ',COALESCE(d.sortorder, 999) AS sortorder '
      SET @v_sqlselect2 = @v_sqlselect2 + ',COALESCE(d.sortorder, 999) AS sortorder '

      IF COALESCE(@i_dropdownuse,0) = 0 BEGIN
        SET @v_sqlselect1 = @v_sqlselect1 + ',COALESCE(t.sortorder, d.sortorder, 999) taskoverridesortorder '
        SET @v_sqlselect2 = @v_sqlselect2 + ',999 taskoverridesortorder '
      END
    END
    ELSE BEGIN
      -- For any task view other than 'All Tasks' (alldatetypesind <> 1), order dates 
      -- by view's sortorder
      SET @v_sqlselect1 = @v_sqlselect1 + ',v.sortorder'
      SET @v_sqlfrom1 = @v_sqlfrom1 + ',taskviewdatetype v'    
      SET @v_sqlwhere1 = @v_sqlwhere1 + ' AND t.datetypecode = v.datetypecode AND' +
      ' v.taskviewkey = ' + CAST (@i_taskviewkey AS VARCHAR)
      
      SET @v_sqlselect2 = @v_sqlselect2 + ',v.sortorder'
      SET @v_sqlfrom2 = @v_sqlfrom2 + ',taskviewdatetype v'    
      SET @v_sqlwhere2 = @v_sqlwhere2 + ' AND t.datetypecode = v.datetypecode AND' +
      ' v.taskviewkey = ' + CAST (@i_taskviewkey AS VARCHAR)            

      IF COALESCE(@i_dropdownuse,0) = 0 BEGIN
        SET @v_sqlselect1 = @v_sqlselect1 + ',COALESCE(t.sortorder, 999) taskoverridesortorder '
        SET @v_sqlselect2 = @v_sqlselect2 + ',999 taskoverridesortorder '
      END

    END
  END
  ELSE
  BEGIN
    -- For 'All Tasks' view (alldatetypesind=1), order dates by datetype's sortorder
    SET @v_sqlselect1 = @v_sqlselect1 + ',COALESCE(d.sortorder, 999) AS sortorder '
    SET @v_sqlselect2 = @v_sqlselect2 + ',COALESCE(d.sortorder, 999) AS sortorder '
    
    IF COALESCE(@i_dropdownuse,0) = 0 BEGIN
      SET @v_sqlselect1 = @v_sqlselect1 + ',COALESCE(t.sortorder, d.sortorder, 999) taskoverridesortorder '
      SET @v_sqlselect2 = @v_sqlselect2 + ',999 taskoverridesortorder '
    END
  END
  
  -- Set and execute the full sqlstring
  IF @i_dropdownuse = 1 OR (@i_elementtype > 0 OR @i_taqelementkey > 0)
    SET @v_sqlstring = @v_sqlselect1 + @v_sqlfrom1 + @v_sqlwhere1
  ELSE
    SET @v_sqlstring = @v_sqlselect1 + @v_sqlfrom1 + @v_sqlwhere1 +
      ' UNION ' + @v_sqlselect2 + @v_sqlfrom2 + @v_sqlwhere2      
      
  EXECUTE sp_executesql @v_sqlstring

  PRINT @v_sqlselect1
  PRINT @v_sqlfrom1
  PRINT @v_sqlwhere1
  PRINT ' UNION'
  PRINT @v_sqlselect2
  PRINT @v_sqlfrom2
  PRINT @v_sqlwhere2

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no tasks found: taskviewkey=' + CAST(@i_taskviewkey AS VARCHAR)
  END 

GO

GRANT EXEC ON qproject_get_project_taskview_dates TO PUBLIC
GO

