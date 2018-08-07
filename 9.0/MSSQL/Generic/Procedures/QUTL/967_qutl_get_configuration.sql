IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qutl_get_configuration')
  BEGIN
    PRINT 'Dropping Procedure qutl_get_configuration'
    DROP  Procedure  qutl_get_configuration
  END
GO

PRINT 'Creating Procedure qutl_get_configuration'
GO

CREATE PROCEDURE qutl_get_configuration
 (@i_windowname varchar(100),
  @i_configobjectid varchar(100),
  @i_itemtypecode integer,
  @i_usageclasscode integer,
  @i_userkey  integer,
  @i_orgentrykey  integer,
  @i_qsiwindowviewkey integer = 0,
  @o_error_code  integer output,
  @o_error_desc  varchar(2000) output)
AS

/************************************************************************************************
**  Name: qutl_get_configuration
**              
**    Parameters:
**    -----------
**    windowname - Name of Page to get configuration - required
**    configobjectid - Name of Object on the Page (ex. section header id) -
**                     Passing nothing will return configurations for all objects on the page
**    usageclasscode - Usasge Class of Configuration -  
**                     Passing 0 will return configurations for all usage classes
**    userkey - userkey of Configuration - Pass -1 if not used
**    orgentrykey - used for windowviewkey selection - Pass 0 if not used
**    
**    Auth: Alan Katzen
**    Date: 8/22/06
*************************************************************************************************
**    Change History
*************************************************************************************************
**    Date:     Author:         Description:
**    --------  --------        -------------------------------------------
**    2/12/08   AK              Added itemtypecode parameter - required
**	  9/2/15    JR				Added helpURL and windowtitle to query
*************************************************************************************************/

  DECLARE @error_var    INT,
          @rowcount_var INT,
          @securitygroupkey_var INT,
          @userid_var VARCHAR(30),
          @v_count  INT,
          --@v_windowid INT,
          @v_helpurl VARCHAR(4000),
          @v_miscsectionind TINYINT,
          @v_miscsectionnumstr  CHAR(1),
          @v_quote      VARCHAR(2),
          @v_sqlselect1  VARCHAR(2000),
          @v_sqlfrom1  VARCHAR(2000),
          @v_sqlwhere1   VARCHAR(2000),
          @v_sqlselect2  VARCHAR(2000),
          @v_sqlfrom2  VARCHAR(2000),
          @v_sqlwhere2   VARCHAR(2000),
          @v_sqlselect3  VARCHAR(2000),
          @v_sqlfrom3  VARCHAR(2000),
          @v_sqlwhere3   VARCHAR(2000),
          @v_sqlstring  NVARCHAR(4000),
          @v_pos INT,
          @v_configobjecttype INT,
          @v_windowviewkey INT,
          @v_usageclasscode INT,
          @v_default_windowviewkey INT
  
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_quote = ''''      

  SET @v_default_windowviewkey = 0
  
  IF @i_windowname IS NULL OR rtrim(ltrim(@i_windowname)) = '' BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get configurations: Windowname is empty.'
    RETURN
  END 

  SET @v_usageclasscode = COALESCE(@i_usageclasscode,0)
  
--    SELECT @v_windowid = windowid
--      FROM qsiwindows
--     WHERE windowname = @i_windowname
--     
--    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
--    IF @error_var < 0 OR @rowcount_var = 0 BEGIN
--      SET @o_error_code = -1
--      SET @o_error_desc = 'Unable to get configurations: Database Error accessing qsiwindows table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
--      RETURN
--    END 
  
  SET @v_sqlselect1 = 'SELECT COALESCE(d.path, o.path) path, 
      COALESCE(d.viewcontrolname, o.viewcontrolname) viewcontrolname, 
      COALESCE(d.editcontrolname, o.editcontrolname) editcontrolname,
      COALESCE(d.labeldesc, o.defaultlabeldesc) labeldesc, 
      COALESCE(d.visibleind, o.defaultvisibleind) visibleind,
      COALESCE(d.minimizedind, o.defaultminimizedind) minimizedind,
      COALESCE(d.position, o.position, 0) position,
      COALESCE(d.initialeditmode, o.initialeditmode, 0) initialeditmode,
      COALESCE(w.helpURL, w.helpURL) helpURL,
      COALESCE(w.windowtitle, w.windowtitle) windowtitle,
      COALESCE(w.windowname, w.windowname) windowname,
      o.configobjectid, o.miscsectionind,
      2 configdetailrow '
  SET @v_sqlfrom1 = 'FROM qsiwindows w, qsiconfigobjects o, qsiconfigdetail d '                 
  SET @v_sqlwhere1 = 'WHERE w.windowid = o.windowid AND
      o.configobjectkey = d.configobjectkey AND
      w.windowname = ' + @v_quote + @i_windowname + @v_quote

  SET @v_sqlselect2 = 'SELECT COALESCE(d.path, o.path) path, 
      COALESCE(d.viewcontrolname, o.viewcontrolname) viewcontrolname, 
      COALESCE(d.editcontrolname, o.editcontrolname) editcontrolname,
      COALESCE(d.labeldesc, o.defaultlabeldesc) labeldesc, 
      COALESCE(d.visibleind, o.defaultvisibleind) visibleind,
      COALESCE(d.minimizedind, o.defaultminimizedind) minimizedind,
      COALESCE(d.position, o.position, 0) position,
      COALESCE(d.initialeditmode, o.initialeditmode, 0) initialeditmode,
      COALESCE(w.helpURL, w.helpURL) helpURL,
      COALESCE(w.windowtitle, w.windowtitle) windowtitle,
      COALESCE(w.windowname, w.windowname) windowname,
      o.configobjectid, o.miscsectionind,
      1 configdetailrow '
  SET @v_sqlfrom2 = @v_sqlfrom1
  SET @v_sqlwhere2 = @v_sqlwhere1
  
  SET @v_sqlselect3 = 'SELECT o.path, o.viewcontrolname, o.editcontrolname,
      COALESCE(o.defaultlabeldesc,' + @v_quote + @v_quote + ') labeldesc,
      o.defaultvisibleind visibleind,
      o.defaultminimizedind minimizedind,
      COALESCE(o.position, 0),
      COALESCE(o.initialeditmode, 0) initialeditmode,
      COALESCE(w.helpURL, w.helpURL) helpURL,
      COALESCE(w.windowtitle, w.windowtitle) windowtitle,
      COALESCE(w.windowname, w.windowname) windowname,
      o.configobjectid, o.miscsectionind, 0 usageclasscode,
      0 configdetailrow '
  SET @v_sqlfrom3 = 'FROM qsiwindows w, qsiconfigobjects o '                     
  SET @v_sqlwhere3 = 'WHERE w.windowid = o.windowid AND
      w.windowname = ' + @v_quote + @i_windowname + @v_quote

  -- add in configobjectid
  IF @i_configobjectid IS NOT NULL AND rtrim(ltrim(@i_configobjectid )) <> '' BEGIN
    -- Check if passed configobjectid is a miscellaneous section
    SELECT @v_count = COUNT(*)
    FROM qsiconfigobjects, qsiwindows
    WHERE qsiconfigobjects.windowid = qsiwindows.windowid AND
        qsiwindows.windowname = @i_windowname AND 
        qsiconfigobjects.configobjectid = @i_configobjectid
    
    SET @v_miscsectionind = 0
    SET @v_windowviewkey = 0
    SET @v_configobjecttype = 0
    IF @v_count > 0 BEGIN
      SELECT @v_configobjecttype = COALESCE(configobjecttype,0), @v_helpurl = qsiwindows.helpURL,
             @v_miscsectionind = miscsectionind
      FROM qsiconfigobjects, qsiwindows
      WHERE qsiconfigobjects.windowid = qsiwindows.windowid AND
          qsiwindows.windowname = @i_windowname AND 
          qsiconfigobjects.configobjectid = @i_configobjectid
    END
    
    -- For configobjecttype = 3 (section header), 4 (section group), 5 (tabs) may need a windowviewkey
    -- to select the correct configuration
    IF @v_configobjecttype IN (3,4,5) BEGIN
      SET @v_sqlwhere1 = @v_sqlwhere1 +  ' AND d.qsiwindowviewkey = wv.qsiwindowviewkey '
      SET @v_sqlfrom1 = @v_sqlfrom1 + ', qsiwindowview wv ' 
      SET @v_sqlselect1 = @v_sqlselect1 + ', wv.usageclasscode '
      
      SET @v_sqlwhere2 = @v_sqlwhere2 + ' AND d.qsiwindowviewkey = wv.qsiwindowviewkey '
      SET @v_sqlfrom2 = @v_sqlfrom2 + ', qsiwindowview wv ' 
      SET @v_sqlselect2 = @v_sqlselect2 + ', wv.usageclasscode '

      IF @i_qsiwindowviewkey > 0 BEGIN
        SET @v_windowviewkey = @i_qsiwindowviewkey
      END
      ELSE BEGIN
        -- Find windowviewkey
        exec qutl_get_windowviewkey @i_windowname,@i_userkey,@i_orgentrykey,@i_itemtypecode,@v_usageclasscode,
                                    @v_windowviewkey output,@o_error_code output,@o_error_desc output
                                    
        IF @o_error_code < 0 BEGIN
          RETURN
        END 
      END
                                    
      IF @v_windowviewkey > 0 BEGIN
        SET @v_sqlwhere1 = @v_sqlwhere1 + 
          ' AND d.qsiwindowviewkey=' + cast(@v_windowviewkey as varchar)
      END
      
      SELECT @v_default_windowviewkey = qsiwindowviewkey
        FROM qsiwindowview wv
       WHERE wv.defaultind = 1
         AND wv.itemtypecode = @i_itemtypecode
         AND COALESCE(wv.usageclasscode,0) = @v_usageclasscode
         
      IF @v_default_windowviewkey > 0 BEGIN
        SET @v_sqlwhere2 = @v_sqlwhere2 + 
          ' AND d.qsiwindowviewkey=' + cast(@v_default_windowviewkey as varchar)
      END      
    END
    ELSE BEGIN
      SET @v_sqlselect1 = @v_sqlselect1 + ', d.usageclasscode '
      SET @v_sqlselect2 = @v_sqlselect2 + ', d.usageclasscode '
    END
    
    SET @v_sqlwhere1 = @v_sqlwhere1 + 
      ' AND o.configobjectid=' + @v_quote + @i_configobjectid + @v_quote
      
    IF @v_default_windowviewkey > 0 BEGIN
      SET @v_sqlwhere2 = @v_sqlwhere2 + 
        ' AND o.configobjectid=' + @v_quote + @i_configobjectid + @v_quote
    END
              
    SET @v_sqlwhere3 = @v_sqlwhere3 + 
      ' AND o.configobjectid=' + @v_quote + @i_configobjectid + @v_quote
  END
  ELSE BEGIN
    SET @v_sqlselect1 = @v_sqlselect1 + ', d.usageclasscode '
    SET @v_sqlselect2 = @v_sqlselect2 + ', d.usageclasscode '
  END

  -- add in itemtypecode
  IF @i_itemtypecode > 0 BEGIN
    SET @v_sqlwhere1 = @v_sqlwhere1 + 
        ' AND COALESCE(o.itemtypecode,0) = COALESCE(' + CAST(@i_itemtypecode AS VARCHAR) + ',0)'

    IF @v_default_windowviewkey > 0 BEGIN
      SET @v_sqlwhere2 = @v_sqlwhere2 + 
          ' AND COALESCE(o.itemtypecode,0) = COALESCE(' + CAST(@i_itemtypecode AS VARCHAR) + ',0)'
    END
    
    SET @v_sqlwhere3 = @v_sqlwhere3 + 
        ' AND COALESCE(o.itemtypecode,0) = COALESCE(' + CAST(@i_itemtypecode AS VARCHAR) + ',0)'

    -- add in usage class
    IF @v_usageclasscode is not null BEGIN
      IF @v_configobjecttype IN (3,4,5) BEGIN
        SET @v_sqlwhere1 = @v_sqlwhere1 + 
            ' AND COALESCE(wv.usageclasscode,0) = ' + CAST(@v_usageclasscode AS VARCHAR)
          
        IF @v_default_windowviewkey > 0 BEGIN
          SET @v_sqlwhere2 = @v_sqlwhere2 + 
              ' AND COALESCE(wv.usageclasscode,0) = COALESCE(' + CAST(@v_usageclasscode AS VARCHAR) + ',0)'
        END
      END
      ELSE BEGIN
        SET @v_sqlwhere1 = @v_sqlwhere1 + 
            ' AND COALESCE(d.usageclasscode,0) = ' + CAST(@v_usageclasscode AS VARCHAR)
          
        IF @v_default_windowviewkey > 0 BEGIN
          SET @v_sqlwhere2 = @v_sqlwhere2 + 
              ' AND COALESCE(d.usageclasscode,0) = COALESCE(' + CAST(@v_usageclasscode AS VARCHAR) + ',0)'
        END
      END        
    END
  END

  
  -- Set and execute the full sqlstring
  -- Sort so the override row2 appears first
  SET @v_sqlstring = @v_sqlselect1 + @v_sqlfrom1 + @v_sqlwhere1

  IF @v_default_windowviewkey > 0 BEGIN
    SET @v_sqlstring = @v_sqlstring  + 
      ' UNION ' +  @v_sqlselect2 + @v_sqlfrom2 + @v_sqlwhere2
  END
  
  SET @v_sqlstring = @v_sqlstring  + 
    ' UNION ' +  @v_sqlselect3 + @v_sqlfrom3 + @v_sqlwhere3 +
    ' ORDER BY configdetailrow DESC'
  
print @v_sqlstring

  EXECUTE sp_executesql @v_sqlstring

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to get configurations: Database Error (' + @i_windowname + ').'
    RETURN
  END 
  IF @rowcount_var = 0 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = 'No Configurations setup for ' + @i_windowname + '.'
    RETURN
  END 
GO

GRANT EXEC ON qutl_get_configuration TO PUBLIC
GO
