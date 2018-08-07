if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskviewtrigger_related_tasks') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_get_taskviewtrigger_related_tasks
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_get_taskviewtrigger_related_tasks
 (@i_taskviewtriggerkey INT,
  @i_bookkey INT,
  @i_printingkey INT,
  @i_projectkey INT,
  @i_action VARCHAR(30),
  @i_exists_activedate INT,
  @i_userkey INT,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/**********************************************************************************************
**  Name: qproject_get_taskviewtrigger_related_tasks
**  Desc: This stored procedure returns all dates for a given project
**        that is associated to tasks on taskviewdatetypes for that taskviewtriggerkey. 
**
**    Auth: Uday A. Khisty
**    Date: 6/23/15
***********************************************************************************************/

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
    @error_var  INT,
    @rowcount_var INT,
    @v_alldatetypesind INT

  SET @v_quote = ''''
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
      -- For drop-downs, get distict dates existing on this project/title
      SET @v_sqlselect1 = 'SELECT DISTINCT t.bookkey,t.printingkey, t.taqprojectkey,t.taqtaskkey,	
         CASE 
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel))=' + @v_quote + @v_quote + ' THEN d.description
          ELSE d.datelabel
         END datelabel,
         CASE 
          WHEN t.bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(' + cast(@i_userkey as varchar) + ','+ @v_quote + 'tasktracking'+ @v_quote + ',323,t.datetypecode,t.bookkey,t.printingkey,0)
          ELSE 2
         END accesscode,
         d.datetypecode,COALESCE(d.usedexclusivelybycsind,0) usedexclusivelybycsind,      
         t.activedate as currentdate,t.actualind, 
         CASE  
          WHEN ' + @v_quote + @i_action+ @v_quote + '=' + @v_quote + 'Delete'+ @v_quote + ' AND ' + cast(@i_exists_activedate AS varchar) +'=1 THEN NULL
          ELSE tvd.defaultdate
         END as changeto,
        e.taqelementdesc elementdesc '
      
      SET @v_sqlfrom1 = ' FROM datetype d INNER JOIN taqprojecttask t ON   t.datetypecode = d.datetypecode
      INNER JOIN taskviewdatetype tvd ON tvd.datetypecode = t.datetypecode AND tvd.taskviewtriggerkey = ' + cast(@i_taskviewtriggerkey as varchar) + '
      LEFT OUTER JOIN coreprojectinfo cp ON t.taqprojectkey = cp.projectkey 
      LEFT OUTER JOIN coretitleinfo ct ON t.bookkey = ct.bookkey AND t.printingkey = ct.printingkey 
      LEFT OUTER JOIN taqprojectelement e ON t.taqelementkey = e.taqelementkey 
      LEFT OUTER JOIN printing p ON t.bookkey = p.bookkey AND t.printingkey = p.printingkey 
      LEFT OUTER JOIN (select distinct taqtaskkey from taqprojecttaskoverride) AS tok ON tok.taqtaskkey = t.taqtaskkey 
      LEFT OUTER JOIN (select distinct globalcontactkey, lastname from globalcontact) AS gc1 ON gc1.globalcontactkey = t.globalcontactkey 
      LEFT OUTER JOIN (select distinct globalcontactkey, lastname from globalcontact) AS gc2 ON gc2.globalcontactkey = t.globalcontactkey2 '

      SET @v_sqlwhere1 = ' WHERE   (t.taqelementkey > 0 OR tok.taqtaskkey IS NOT NULL) '     
      
      SET @v_sqlselect2 = 'SELECT DISTINCT t.bookkey,t.printingkey, t.taqprojectkey,t.taqtaskkey,	
         CASE 
          WHEN d.datelabel IS NULL OR LTRIM(RTRIM(d.datelabel))=' + @v_quote + @v_quote + ' THEN d.description
          ELSE d.datelabel
         END datelabel,
         CASE 
          WHEN t.bookkey > 0 THEN dbo.qutl_check_gentable_value_security_by_status(' + cast(@i_userkey as varchar) + ','+ @v_quote + 'tasktracking'+ @v_quote + ',323,t.datetypecode,t.bookkey,t.printingkey,0)
          ELSE 2
         END accesscode,
         d.datetypecode,COALESCE(d.usedexclusivelybycsind,0) usedexclusivelybycsind,      
         t.activedate as currentdate,t.actualind, 
         CASE 
          WHEN ' + @v_quote + @i_action+ @v_quote + '=' + @v_quote + 'Delete'+ @v_quote + ' AND ' +  cast(@i_exists_activedate AS varchar) +'=1 THEN NULL
          ELSE tvd.defaultdate
         END as changeto,
         NULL elementdesc '    
         
     SET @v_sqlfrom2 = ' FROM datetype d INNER JOIN taqprojecttask t ON  t.datetypecode = d.datetypecode
      INNER JOIN taskviewdatetype tvd ON tvd.datetypecode = t.datetypecode AND tvd.taskviewtriggerkey  = ' + cast(@i_taskviewtriggerkey as varchar) + '
      LEFT OUTER JOIN coreprojectinfo cp ON t.taqprojectkey = cp.projectkey 
      LEFT OUTER JOIN coretitleinfo ct ON t.bookkey = ct.bookkey AND t.printingkey = ct.printingkey 
      LEFT OUTER JOIN printing p ON t.bookkey = p.bookkey AND t.printingkey = p.printingkey 
      LEFT OUTER JOIN (select distinct taqtaskkey from taqprojecttaskoverride) AS tok ON tok.taqtaskkey = t.taqtaskkey 
      LEFT OUTER JOIN (select distinct globalcontactkey, lastname from globalcontact) AS gc1 ON gc1.globalcontactkey = t.globalcontactkey 
      LEFT OUTER JOIN (select distinct globalcontactkey, lastname from globalcontact) AS gc2 ON gc2.globalcontactkey = t.globalcontactkey2 '         
  
	 SET @v_sqlwhere2 = ' WHERE t.taqelementkey IS NULL AND tok.taqtaskkey IS NULL '   
	 
	 
  -- add in keylists
  SET @v_sqlwhere_keys = '('
  IF (@i_projectkey is not null AND @i_projectkey > 0) BEGIN
    IF @v_sqlwhere_keys = '(' BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' (t.taqprojectkey =' + cast(@i_projectkey as varchar) + ')'
    END
    ELSE BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' OR (t.taqprojectkey =' + cast(@i_projectkey as varchar) + ')'
    END
  END


  IF (@i_bookkey is not null AND @i_bookkey > 0) BEGIN
    IF @v_sqlwhere_keys = '(' BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' (t.bookkey =' + cast(@i_bookkey as varchar) + ')'
    END
    ELSE BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' OR (t.bookkey =' + cast(@i_bookkey as varchar) + ')'
    END
    
  IF (@i_printingkey is not null AND @i_printingkey > 0) BEGIN
    IF @v_sqlwhere_keys = '(' BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' (t.printingkey =' + cast(@i_printingkey as varchar) + ')'
    END
    ELSE BEGIN
      SET @v_sqlwhere_keys = @v_sqlwhere_keys + ' AND (t.printingkey =' + cast(@i_printingkey as varchar) + ')'
    END
  END     
  END       
    
  SET @v_sqlwhere_keys = @v_sqlwhere_keys + ')'	
  
  SET @v_sqlwhere1 = @v_sqlwhere1 + ' AND ' + @v_sqlwhere_keys
  SET @v_sqlwhere2 = @v_sqlwhere2 + ' AND ' + @v_sqlwhere_keys  
  
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
    SET @o_error_desc = 'no tasks found: taskviewtriggerkey=' + CAST(@i_taskviewtriggerkey AS VARCHAR)
  END    

GO

GRANT EXEC ON qproject_get_taskviewtrigger_related_tasks TO PUBLIC
GO

  