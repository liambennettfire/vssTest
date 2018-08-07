IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_jumpto_page_section_info]') AND type in (N'P', N'PC'))   
DROP PROCEDURE [dbo].[qutl_get_jumpto_page_section_info]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_jumpto_page_section_info]
 (@i_windowname         varchar(100),
  @i_userkey            integer,
  @i_orgentrykey        integer,
  @i_itemtypecode       integer,
  @i_usageclasscode     integer,
  @i_windowviewkey      integer = 0,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_jumpto_page_section_info
**  Desc: This stored procedure returns all sections for a window view.
**
**  Parameters:
**    windowname - Name of Page
**    userkey - userkey for userid accessing page
**    orgentrykey - orgentrykey at level for sections on page - Pass 0 if not applicable
**    itemtypecode - itemtype for page - Pass 0 if not applicable
**    usageclasscode - usageclass page - Pass 0 if not applicable
**
**  Auth: Alan Katzen
**  Date: August 23, 2016
*******************************************************************************
**  Date     Who    Change
**  -------  ---    -----------------------------------------------------------
**  2/1/18   Alan   Check default windowview for class and current windowview
**
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var         INT,
          @rowcount_var      INT,
          @v_count           INT,
          @v_windowviewkey   INT,
          @v_default_windowviewkey INT,
          @v_windowid        INT,
          @v_usageclasscode  INT

  
  SET @v_usageclasscode = COALESCE(@i_usageclasscode,0)
  
  SET @v_windowviewkey = 0
  IF @i_windowviewkey > 0 BEGIN
    SET @v_windowviewkey = @i_windowviewkey
  END

  -- Find default windowviewkey for window
  exec qutl_get_windowviewkey @i_windowname,-1,@i_orgentrykey,@i_itemtypecode,@i_usageclasscode,
                              @v_default_windowviewkey output,@o_error_code output,@o_error_desc output
                                
  IF @o_error_code < 0 BEGIN
    RETURN
  END 

  SELECT @v_windowid = windowid
    FROM qsiwindows
   WHERE windowname = @i_windowname
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var < 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to load sections for page: Database Error accessing qsiwindows table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END
  IF @rowcount_var = 0 BEGIN
    -- nothing more we can do
    RETURN
  END

  IF @v_default_windowviewkey > 0 BEGIN
    SELECT cd.configdetailkey, cd.configobjectkey, cd.qsiwindowviewkey, cd.usageclasscode, 
           COALESCE(cd.labeldesc,co.defaultlabeldesc,'TBD') labeldesc, co.configobjectid,
           COALESCE(cd.visibleind,co.defaultvisibleind,1) visibleind,
           COALESCE(cd.minimizedind,co.defaultminimizedind,0) minimizedind, 
           COALESCE(cd.position,co.position) position, co.configobjectdesc,
           COALESCE(cd.sectioncontrolname,co.sectioncontrolname) sectioncontrolname,
           COALESCE(cd.path, co.path) path,
           COALESCE(cd.editcontrolname,co.editcontrolname) editcontrolname,
           COALESCE(cd.viewcontrolname,co.viewcontrolname) viewcontrolname,
           COALESCE(co.miscsectionind,0) miscsectionind,
           COALESCE(cd.position,co.position,999) sortposition,         
           COALESCE(cd.viewcolumnnum,co.defaultviewcolumnnum,0) viewcolumnnum,
           CASE
            WHEN COALESCE(cd.viewcolumnnum,co.defaultviewcolumnnum,0) = 0 THEN 999
            ELSE 
              COALESCE(cd.viewcolumnnum,co.defaultviewcolumnnum,0)
           END AS sortviewcolumnnum, co.configobjecttype
      INTO #jumptoitem                       
      FROM qsiconfigdetail cd, qsiconfigobjects co 
     WHERE cd.configobjectkey = co.configobjectkey
       AND cd.qsiwindowviewkey = @v_default_windowviewkey
       AND co.configobjecttype in (3,4,5)
       AND COALESCE(cd.visibleind,co.defaultvisibleind,1) = 1

    SELECT @error_var = @@ERROR
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to load sections for page: Database Error accessing qsiwindowview table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END     

    INSERT INTO #jumptoitem
    SELECT 0 configdetailkey, configobjectkey, -1 qsiwindowviewkey, 0 usageclasscode,
           defaultlabeldesc labeldesc, configobjectid,
           COALESCE(defaultvisibleind,1) visibleind,
           defaultminimizedind minimizedind, 
           position, configobjectdesc,
           sectioncontrolname,
           path,
           editcontrolname,
           viewcontrolname,
           COALESCE(miscsectionind,0) miscsectionind,
           COALESCE(position,999) sortposition,
           defaultviewcolumnnum viewcolumnnum,
           CASE
            WHEN COALESCE(defaultviewcolumnnum,0) = 0 THEN 999
            ELSE 
              COALESCE(defaultviewcolumnnum,0)
           END AS sortviewcolumnnum, configobjecttype                    
      FROM qsiconfigobjects 
     WHERE configobjecttype in (3,4,5)
       AND defaultvisibleind = 1
       AND itemtypecode = @i_itemtypecode
       AND windowid = @v_windowid
       AND configobjectkey not in (SELECT cd2.configobjectkey FROM qsiconfigdetail cd2 WHERE cd2.qsiwindowviewkey = @v_default_windowviewkey)  

    SELECT @error_var = @@ERROR
    IF @error_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to load sections for page: Database Error accessing qsiwindowview table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END    

    IF @v_windowviewkey > 0 BEGIN
      -- add any visible sections from the current windowview
      INSERT INTO #jumptoitem
      SELECT cd.configdetailkey, cd.configobjectkey, cd.qsiwindowviewkey, cd.usageclasscode, 
             COALESCE(cd.labeldesc,co.defaultlabeldesc,'TBD') labeldesc, co.configobjectid,
             cd.visibleind,
             COALESCE(cd.minimizedind,co.defaultminimizedind,0) minimizedind, 
             COALESCE(cd.position,co.position) position, co.configobjectdesc,
             COALESCE(cd.sectioncontrolname,co.sectioncontrolname) sectioncontrolname,
             COALESCE(cd.path, co.path) path,
             COALESCE(cd.editcontrolname,co.editcontrolname) editcontrolname,
             COALESCE(cd.viewcontrolname,co.viewcontrolname) viewcontrolname,
             COALESCE(co.miscsectionind,0) miscsectionind,
             COALESCE(cd.position,co.position,999) sortposition,         
             COALESCE(cd.viewcolumnnum,co.defaultviewcolumnnum,0) viewcolumnnum,
             CASE
              WHEN COALESCE(cd.viewcolumnnum,co.defaultviewcolumnnum,0) = 0 THEN 999
              ELSE 
                COALESCE(cd.viewcolumnnum,co.defaultviewcolumnnum,0)
             END AS sortviewcolumnnum, co.configobjecttype
        FROM qsiconfigdetail cd, qsiconfigobjects co 
       WHERE cd.configobjectkey = co.configobjectkey
         AND cd.qsiwindowviewkey = @v_windowviewkey
         AND co.configobjecttype in (3,4,5)
         AND cd.visibleind = 1
         AND cd.configobjectkey not in (SELECT configobjectkey FROM #jumptoitem)  

      SELECT @error_var = @@ERROR
      IF @error_var < 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to load sections for page: Database Error accessing qsiwindowview table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END    
    END

    SELECT * FROM  #jumptoitem
    ORDER BY sortviewcolumnnum, sortposition, labeldesc  

    DROP TABLE #jumptoitem
  END       
   
GO

GRANT EXEC on qutl_get_jumpto_page_section_info TO PUBLIC
GO
