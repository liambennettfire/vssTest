if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qutl_get_default_windowviews') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].qutl_get_default_windowviews
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE FUNCTION qutl_get_default_windowviews(@i_windowid as integer)
RETURNS @defaultwindowviewinfo TABLE(
	configdetailkey int,
	configobjectkey int,
	qsiwindowviewkey int,
	itemtypecode int,
	usageclasscode int,
	configobjectid varchar(100),
	labeldesc varchar(100),
	visibleind tinyint,
	defaultvisibleind tinyint,
	minimizedind tinyint,
	position int,
	configobjectdesc varchar(100),
	defaultlabeldesc varchar(100),
	groupkey int,
	configobjecttype int,
	parentobjectdesc varchar(100),
	groupposition int,
	sectioncontrolname varchar(4000),
	path varchar(2000),
	viewcontrolname varchar(2000),
	editcontrolname varchar(2000),
	miscsectionind tinyint,
	viewcolumnnum int,
	initialeditmode int
)
AS
BEGIN
  DECLARE @v_qsiwindowviewkey integer,
          @v_itemtypecode integer,
          @v_usageclasscode integer,
          @v_count integer,
          @v_temp int

--  SELECT @v_itemtypecode = itemtypecode
--    FROM qsiwindows
--   WHERE windowid = @i_windowid

  INSERT INTO @defaultwindowviewinfo (configdetailkey,configobjectkey,qsiwindowviewkey,itemtypecode,
         usageclasscode,labeldesc,configobjectid,visibleind,defaultvisibleind,minimizedind,position,configobjectdesc,
         defaultlabeldesc,groupkey,configobjecttype,parentobjectdesc,groupposition,sectioncontrolname,path,editcontrolname,
         viewcontrolname,miscsectionind,viewcolumnnum,initialeditmode)
  SELECT cd.configdetailkey,cd.configobjectkey,cd.qsiwindowviewkey,wv.itemtypecode,COALESCE(wv.usageclasscode,0),
         cd.labeldesc,co.configobjectid,
         COALESCE(cd.visibleind,1) visibleind,
         COALESCE(co.defaultvisibleind,1) defaultvisibleind,
         COALESCE(cd.minimizedind,co.defaultminimizedind,0) minimizedind,
         COALESCE(cd.position,co.position) position, co.configobjectdesc, co.defaultlabeldesc,
         co.groupkey, co.configobjecttype,
         (select configobjectdesc from qsiconfigobjects where configobjectkey = co.groupkey) parentobjectdesc,
         (select COALESCE(position,999) from qsiconfigobjects 
          where qsiconfigobjects.configobjectkey = co.groupkey and qsiconfigobjects.windowid = @i_windowid) groupposition,
         COALESCE(cd.sectioncontrolname,co.sectioncontrolname) sectioncontrolname,
         COALESCE(cd.path, co.path) path,
         COALESCE(cd.editcontrolname,co.editcontrolname) editcontrolname,
         COALESCE(cd.viewcontrolname,co.viewcontrolname) viewcontrolname,
         COALESCE(co.miscsectionind,0) miscsectionind,
         COALESCE(cd.viewcolumnnum,co.defaultviewcolumnnum,0) viewcolumnnum,
         COALESCE(cd.initialeditmode, co.initialeditmode, 0) initialeditmode         
    FROM qsiconfigobjects co, qsiconfigdetail cd, qsiwindowview wv
   WHERE co.configobjectkey = cd.configobjectkey
     AND cd.qsiwindowviewkey = wv.qsiwindowviewkey
     AND wv.defaultind = 1
     AND wv.userkey = -1
     AND co.windowid = @i_windowid
  
  SELECT @v_count = count(*)
    FROM @defaultwindowviewinfo

SET @v_temp = 0
  -- get default rows
  IF @v_count > 0 BEGIN  
    DECLARE temp_cur CURSOR fast_forward FOR
      SELECT DISTINCT wv.itemtypecode, COALESCE(wv.usageclasscode,0)
        FROM qsiconfigobjects co, qsiconfigdetail cd, qsiwindowview wv
       WHERE co.configobjectkey = cd.configobjectkey
         AND cd.qsiwindowviewkey = wv.qsiwindowviewkey
         AND wv.defaultind = 1
         AND wv.userkey = -1
         AND co.windowid = @i_windowid

    OPEN temp_cur

    FETCH from temp_cur INTO @v_itemtypecode, @v_usageclasscode

    WHILE @@fetch_status = 0 BEGIN
      INSERT INTO @defaultwindowviewinfo (configdetailkey,configobjectkey,qsiwindowviewkey,itemtypecode,
             usageclasscode,labeldesc,configobjectid,visibleind,defaultvisibleind,minimizedind,position,configobjectdesc,
             defaultlabeldesc,groupkey,configobjecttype,parentobjectdesc,groupposition,sectioncontrolname,path,editcontrolname,
             viewcontrolname,miscsectionind,viewcolumnnum,initialeditmode)
      SELECT 0 configdetailkey,co.configobjectkey,-1 qsiwindowviewkey,@v_itemtypecode,@v_usageclasscode,
             co.defaultlabeldesc as labeldesc,co.configobjectid,
             COALESCE(co.defaultvisibleind,1) visibleind,
             COALESCE(co.defaultvisibleind,1) defaultvisibleind,
             COALESCE(co.defaultminimizedind,0) minimizedind,
             co.position, co.configobjectdesc, co.defaultlabeldesc,
             co.groupkey, co.configobjecttype,
             (select configobjectdesc from qsiconfigobjects where configobjectkey = co.groupkey) parentobjectdesc,
             (select COALESCE(position,999) from qsiconfigobjects where configobjectkey = co.groupkey) groupposition,
             co.sectioncontrolname,co.path,co.editcontrolname,co.viewcontrolname,
             COALESCE(co.miscsectionind,0) miscsectionind,        
             COALESCE(co.defaultviewcolumnnum,0) viewcolumnnum,
             COALESCE(co.initialeditmode, 0) initialeditmode         
        FROM qsiconfigobjects co
       WHERE co.windowid = @i_windowid
         AND co.configobjectkey not in (SELECT configobjectkey FROM @defaultwindowviewinfo 
                                         WHERE itemtypecode = @v_itemtypecode 
                                           AND COALESCE(usageclasscode,0) = @v_usageclasscode)
    
      FETCH from temp_cur INTO @v_itemtypecode, @v_usageclasscode
    END
    
    CLOSE temp_cur
    DEALLOCATE temp_cur
  END
  ELSE BEGIN
    INSERT INTO @defaultwindowviewinfo (configdetailkey,configobjectkey,qsiwindowviewkey,itemtypecode,
           usageclasscode,labeldesc,configobjectid,visibleind,defaultvisibleind,minimizedind,position,configobjectdesc,
           defaultlabeldesc,groupkey,configobjecttype,parentobjectdesc,groupposition,sectioncontrolname,path,editcontrolname,
           viewcontrolname,miscsectionind,viewcolumnnum,initialeditmode)
    SELECT 0 configdetailkey,co.configobjectkey,-1 qsiwindowviewkey,@v_itemtypecode,0 usageclasscode,
           co.defaultlabeldesc as labeldesc,co.configobjectid,
           COALESCE(co.defaultvisibleind,1) visibleind,
           COALESCE(co.defaultvisibleind,1) defaultvisibleind,
           COALESCE(co.defaultminimizedind,0) minimizedind,
           co.position, co.configobjectdesc, co.defaultlabeldesc,
           co.groupkey, co.configobjecttype,
           (select configobjectdesc from qsiconfigobjects where configobjectkey = co.groupkey) parentobjectdesc,
           (select COALESCE(position,999) from qsiconfigobjects where configobjectkey = co.groupkey) groupposition,
           co.sectioncontrolname,co.path,co.editcontrolname,co.viewcontrolname,
           COALESCE(co.miscsectionind,0) miscsectionind,         
           COALESCE(co.defaultviewcolumnnum,0) viewcolumnnum,
           COALESCE(co.initialeditmode, 0) initialeditmode         
      FROM qsiconfigobjects co
     WHERE co.windowid = @i_windowid
       AND co.configobjectkey not in (SELECT configobjectkey FROM @defaultwindowviewinfo)
  END
  
  RETURN
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

