IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_windowviewlist]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qutl_get_windowviewlist]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_windowviewlist]
 (@i_orgentrykeylist    varchar(max),
  @i_windowid           integer,
  @i_userkey            integer,
  @i_itemtypecode       integer,
  @i_usageclasscode     integer,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_windowviewlist
**  Desc: This stored procedure returns a list of views from the qsiwindowview table.
**
**  Parameters:
**  @i_orgentrykeylist - list of all valid orgentries for the user 
**                       (comma seperated, no parentheses) - Not currently Used
**
**
**  Auth: Alan Katzen
**  Date: April 28, 2010
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var                   INT,
          @rowcount_var                INT,
          @sqlStmt		                 varchar(max),
          @v_default_windowviewkey     INT,
          @v_usageclass                INT,
          @v_configobjectid            varchar(100),
          @v_pagetitle                 varchar(100),
          @v_pagetitle_configobjectkey INT,
          @v_pagetitle_configdetailkey INT,
          @v_count                     INT,
          @v_quote                     char(1)
          
  SET @v_quote = CHAR(39)

  -- try to find the Page Title
  SET @v_pagetitle_configobjectkey = 0 
  SET @v_pagetitle_configdetailkey = 0 
  SET @v_pagetitle = ''
          
  IF @i_windowid > 0 and @i_itemtypecode > 0 BEGIN
    SET @v_configobjectid = ''
    
    SELECT @v_configobjectid = windowname
      FROM qsiwindows
     WHERE windowid = @i_windowid
   
    IF @v_configobjectid <> '' BEGIN 
      SET @v_count = 0
      IF @i_usageclasscode > 0 BEGIN
        SELECT @v_count = count(*)
          FROM qsiconfigobjects co, qsiconfigdetail cd  
         WHERE co.configobjectkey = cd.configobjectkey
           and co.windowid = @i_windowid       
           and lower(co.configobjectid) = lower(@v_configobjectid) 
           and co.itemtypecode = @i_itemtypecode
           and cd.usageclasscode = @i_usageclasscode   
      END

      IF @v_count > 0 BEGIN
        SELECT @v_pagetitle_configobjectkey = co.configobjectkey, 
               @v_pagetitle_configdetailkey = cd.configdetailkey, 
               @v_pagetitle = COALESCE(cd.labeldesc,co.defaultlabeldesc)
          FROM qsiconfigobjects co, qsiconfigdetail cd  
         WHERE co.configobjectkey = cd.configobjectkey
           and co.windowid = @i_windowid       
           and lower(co.configobjectid) = lower(@v_configobjectid) 
           and co.itemtypecode = @i_itemtypecode
           and cd.usageclasscode = @i_usageclasscode   
      END
      ELSE BEGIN
        SELECT @v_count = count(*)
          FROM qsiconfigobjects co  
         WHERE co.windowid = @i_windowid       
           and lower(co.configobjectid) = lower(@v_configobjectid)
           and co.itemtypecode = @i_itemtypecode
           
        IF @v_count > 0 BEGIN
          SELECT @v_pagetitle_configobjectkey = co.configobjectkey, 
                 @v_pagetitle_configdetailkey = 0, @v_pagetitle = co.defaultlabeldesc
            FROM qsiconfigobjects co  
           WHERE co.windowid = @i_windowid       
             and lower(co.configobjectid) = lower(@v_configobjectid)  
             and co.itemtypecode = @i_itemtypecode
        END
      END      
    END                          
  END
        
  --print '@v_pagetitle_configobjectkey: ' + cast(@v_pagetitle_configobjectkey as varchar)
  --print '@v_pagetitle_configdetailkey: ' + cast(@v_pagetitle_configdetailkey as varchar)
  --print '@v_pagetitle: ' + @v_pagetitle
  
  SET @v_default_windowviewkey = 0
  IF COALESCE(@i_userkey,-1) >= 0 AND COALESCE(@i_itemtypecode,0) > 0 BEGIN
    SET @v_usageclass = COALESCE(@i_usageclasscode,0)
    
    SELECT @v_default_windowviewkey = COALESCE(summarywindowviewkey,0)
      FROM qsiusersusageclass
     WHERE userkey = @i_userkey
       AND itemtypecode = @i_itemtypecode
       AND usageclasscode = @v_usageclass
  END
  SET @v_default_windowviewkey = COALESCE(@v_default_windowviewkey,0)
    
  select @sqlStmt = 
   'SELECT distinct co.windowid,COALESCE(wv.userkey,-1) userkey,COALESCE(wv.orgentrykey,0) orgentrykey,
           COALESCE(wv.itemtypecode,0) itemtypecode,COALESCE(wv.usageclasscode,0) usageclasscode,
           wv.qsiwindowviewname,wv.qsiwindowviewdesc,wv.qsiwindowviewkey,COALESCE(wv.defaultind,0) defaultind, ' + 
           'CASE
             WHEN wv.qsiwindowviewkey = ' + cast(@v_default_windowviewkey as varchar)  + ' THEN 1
             ELSE 0 
           END AS mydefaultind, ' + @v_quote + @v_pagetitle + @v_quote + ' pagetitle, 
           COALESCE(' + cast(@v_pagetitle_configobjectkey as varchar) + ',0) pagetitle_configobjectkey,
           COALESCE(' + cast(@v_pagetitle_configdetailkey as varchar) + ',0) pagetitle_configdetailkey
      FROM qsiwindowview wv, qsiconfigdetail cd, qsiconfigobjects co 
     WHERE wv.qsiwindowviewkey = cd.qsiwindowviewkey
       AND cd.configobjectkey = co.configobjectkey 
       AND co.windowid in (select windowid from qsiwindows where allowviewsind = 1) ' 

--  IF (@i_orgentrykeylist is not null AND datalength(@i_orgentrykeylist) > 0) BEGIN 
--    SET @sqlStmt = @sqlStmt + ' AND (COALESCE(wv.orgentrykey,0) = 0 OR wv.orgentrykey in (' + @i_orgentrykeylist + '))'
--  END
  
  IF (@i_windowid > 0) BEGIN
    SET @sqlStmt = @sqlStmt + ' AND co.windowid = ' + cast(@i_windowid as varchar)
  END
  
  IF (@i_userkey >= 0) BEGIN
    SET @sqlStmt = @sqlStmt + ' AND (COALESCE(wv.userkey,-1) = -1 OR wv.userkey = ' + cast(@i_userkey as varchar) + ' OR 
		        wv.userkey in (select accesstouserkey from qsiprivateuserlist where primaryuserkey = ' + cast(@i_userkey as varchar) + '))'	  
  END

  IF (@i_itemtypecode > 0) BEGIN
    SET @sqlStmt = @sqlStmt + ' AND wv.itemtypecode = ' + cast(@i_itemtypecode as varchar)

    IF (@i_usageclasscode > 0) BEGIN
      SET @sqlStmt = @sqlStmt + ' AND wv.usageclasscode = ' + cast(@i_usageclasscode as varchar)
    END
  END
  
  SET @sqlStmt = @sqlStmt + ' ORDER BY wv.qsiwindowviewname '

  --print @sqlStmt

  EXEC(@sqlStmt)

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qsiwindowview table from qutl_get_windowviewlist stored proc'  
  END 

GO

GRANT EXEC on qutl_get_windowviewlist TO PUBLIC
GO

