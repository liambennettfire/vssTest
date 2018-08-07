
/****** Object:  StoredProcedure [dbo].[qutl_generate_windowview_sql]    Script Date: 01/13/2015 15:38:35 ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_generate_windowview_sql' ) 
     DROP PROCEDURE qutl_generate_windowview_sql 
GO

CREATE PROC [dbo].[qutl_generate_windowview_sql]
  @i_itemtype     INT,
  @i_usageclass   INT,
  @i_windowname   VARCHAR(40),
  @o_error_code   INT OUTPUT,
  @o_error_desc   VARCHAR(2000) OUTPUT
AS
/******************************************************************************************
**  Name: qutl_generate_windowview_sql  
**  Desc: This stored procedure will create the insert sql necessary to create a default
**        window view based on the database it is run on.  It will creae sql that will only 
**        work if the default view does not exist    
**    Auth: Alan
**    Date: 
********************************************************************************************
**    Change History
********************************************************************************************
**    Date:    Author:        Description:
**    --------  --------        --------------------------------------------------------
**    1/13/15	SLB				Modified to add logic to be able to correctly identify 
**                              Misc section since configobjectid can differ from database to
**                              database for Misc Items. 
********************************************************************************************/

DECLARE
  @v_usageclassdesc varchar(255),
  @v_usageclass_qsicode int,
  @v_quote char(1),
  @v_qsiwindowviewkey int,
  @v_qsiwindowviewname varchar(255),
  @v_qsiwindowviewdesc varchar(2000),
  @v_labeldesc varchar(100),
  @v_visibleind tinyint,
  @v_minimizedind tinyint,
  @v_position smallint,
  @v_path varchar(2000),
  @v_viewcontrolname varchar(2000),
  @v_editcontrolname varchar(2000),
  @v_sectioncontrolname varchar(4000),
  @v_configobjectid varchar(100),
  @v_defaultlabeldesc varchar(100)
  
BEGIN
  SELECT @v_usageclassdesc = datadesc,
         @v_usageclass_qsicode = qsicode
    FROM subgentables
   WHERE tableid = 550
     and datacode = @i_itemtype
     and datasubcode = @i_usageclass

  IF @v_usageclassdesc is null OR @v_usageclass_qsicode is null OR @v_usageclass_qsicode <= 0 BEGIN
    print 'Could not find itemtype/usageclasscode on subgentables (tableid 550)'
    return
  END
  
  SELECT @v_qsiwindowviewkey = qsiwindowviewkey,
         @v_qsiwindowviewname = qsiwindowviewname,
         @v_qsiwindowviewdesc = qsiwindowviewdesc
    FROM qsiwindowview
   WHERE itemtypecode = @i_itemtype
     AND usageclasscode = @i_usageclass
     AND userkey = -1
     AND defaultind = 1
    
  IF @v_qsiwindowviewkey is null OR @v_qsiwindowviewkey <= 0 BEGIN
    print 'Could not find qsiwindowviewkey on qsiwindowview'
    return
  END

  SET @v_quote = CHAR(39)

  print 'DECLARE'
  print '  @v_new_qsiwindowviewkey int,'
  print '  @v_new_configdetailkey int,'
  print '  @v_configobjectkey int,'
  print '  @v_usageclasscode int,'
  print '  @v_windowid int,'
  print '  @v_count int'
  print ' '
  print 'BEGIN'   
  print ' '
  print '  SELECT @v_usageclasscode = datasubcode FROM subgentables '
  print '   WHERE tableid = 550 and datacode = ' + cast(@i_itemtype as varchar) 
  print '     and qsicode = ' + cast(@v_usageclass_qsicode as varchar)
  print ' '   
  print '  IF @v_usageclasscode is null OR @v_usageclasscode <= 0 BEGIN'   
  print '    print ' + @v_quote + 'Could not find usageclasscode for qsicode ' + cast(@v_usageclass_qsicode as varchar) + @v_quote
  print '    return'   
  print '  END'   
  print ' '   
  print ' SELECT @v_count = count(*) '
  print '   FROM qsiwindowview '
  print '  WHERE itemtypecode = ' + cast(@i_itemtype as varchar)
  print '    AND usageclasscode = @v_usageclasscode '
  print '    AND defaultind = 1 '
  print '    AND userkey = -1 ' 
  print ' '   
  print '  IF @v_count > 0 BEGIN'   
  print '    print ' + @v_quote + 'A default windowview already exists for itemtype ' + cast(@i_itemtype as varchar)+  ' and usageclass ' +  @v_quote + ' + cast(@v_usageclasscode as varchar)'
  print '    return'   
  print '  END'   
  print ' '     
  print '  exec get_next_key ' + @v_quote + 'qsidba' + @v_quote + ', @v_new_qsiwindowviewkey output'
  print ' '   
  print '  -- create default view'
  print '  INSERT INTO qsiwindowview (qsiwindowviewkey, qsiwindowviewname, qsiwindowviewdesc, '
  print '                             itemtypecode, usageclasscode, defaultind, userkey, ' 
  print '                             lastuserid, lastmaintdate ) '
  print '  VALUES (@v_new_qsiwindowviewkey, ' + @v_quote + @v_qsiwindowviewname + @v_quote + ',' + @v_quote + @v_qsiwindowviewdesc + @v_quote + ',' 
  print '          ' + cast(@i_itemtype as varchar) + ', @v_usageclasscode, 1, -1, ' + @v_quote + 'Firebrand' + @v_quote + ', getdate())'
  print ' '   
  print '  -- get windowid of window'
  print '  SELECT @v_windowid = windowid '
  print '    FROM qsiwindows '
  print '   WHERE lower(windowname) = lower(' + @v_quote + @i_windowname + @v_quote + ')'
  print ' '   
  print '  -- insert qsiconfigdetail rows'

  DECLARE cur CURSOR FOR 
   SELECT labeldesc,visibleind,minimizedind,position,COALESCE(@v_quote + [path] + @v_quote,'null'),
          COALESCE(@v_quote + viewcontrolname + @v_quote,'null'),COALESCE(@v_quote + editcontrolname + @v_quote,'null'),
          COALESCE(@v_quote + sectioncontrolname + @v_quote,'null'),
          (select configobjectid from qsiconfigobjects where configobjectkey = d.configobjectkey) configobjectid,
          (select defaultlabeldesc from qsiconfigobjects where configobjectkey = d.configobjectkey) defaultlabeldesc
     FROM qsiconfigdetail d 
    WHERE qsiwindowviewkey = @v_qsiwindowviewkey
  
  OPEN cur

  FETCH NEXT FROM cur INTO @v_labeldesc,@v_visibleind,@v_minimizedind,@v_position,@v_path,
                           @v_viewcontrolname,@v_editcontrolname,@v_sectioncontrolname,
                           @v_configobjectid, @v_defaultlabeldesc

  WHILE @@FETCH_STATUS = 0 BEGIN        
	print '  SET @v_configobjectkey = 0'
	
	IF  @v_configobjectid like '%Misc%'
	BEGIN
		print '  SELECT @v_configobjectkey = configobjectkey '
		print '    FROM qsiconfigobjects '
		print '   WHERE lower(defaultlabeldesc) = lower(' + @v_quote + @v_defaultlabeldesc + @v_quote + ') '
		print '     and windowid = @v_windowid '
		print ' '  
	END 
    ELSE
    BEGIN
    print '  SELECT @v_configobjectkey = configobjectkey '
		print '    FROM qsiconfigobjects '
		print '   WHERE lower(configobjectid) = lower(' + @v_quote + @v_configobjectid + @v_quote + ') '
		print '     and windowid = @v_windowid '
		print ' '  
    END
    print '  IF @v_configobjectkey <> 0 BEGIN'
    print '    exec get_next_key ' + @v_quote + 'qsidba' + @v_quote + ', @v_new_configdetailkey output'
    print ' '   
    print '    INSERT INTO qsiconfigdetail (configdetailkey,configobjectkey,usageclasscode,labeldesc,visibleind,minimizedind, '
    print '                               lastuserid,lastmaintdate,position,path,viewcontrolname,editcontrolname, '
    print '                               qsiwindowviewkey,sectioncontrolname) '
    print '    VALUES (@v_new_configdetailkey,@v_configobjectkey,@v_usageclasscode,' + @v_quote + @v_labeldesc + @v_quote + ','
    print '         ' + COALESCE(cast(@v_visibleind as varchar),'null') + ',' + COALESCE(cast(@v_minimizedind as varchar),'null') + ',' + @v_quote + 'Firebrand' + @v_quote + ',getdate(),' + COALESCE(cast(@v_position as varchar),'null') + ','
    print '         ' + @v_path + ',' + @v_viewcontrolname + ',' + @v_editcontrolname + ',@v_new_qsiwindowviewkey,'
    print '         ' + @v_sectioncontrolname + ')'  
    print '  END'  
    print '  ELSE  BEGIN'
    print '      print ''Section not found on this database: ' + @v_defaultlabeldesc + "'" 
    print '  END'  
    print ' '  
     
    FETCH NEXT FROM cur INTO @v_labeldesc,@v_visibleind,@v_minimizedind,@v_position,@v_path,
                             @v_viewcontrolname,@v_editcontrolname,@v_sectioncontrolname,
                             @v_configobjectid, @v_defaultlabeldesc
  END 
  CLOSE cur
  DEALLOCATE cur
  
  print 'END'   
  print 'go'  
END

GO


