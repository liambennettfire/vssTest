IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_page_section_info]') AND type in (N'P', N'PC'))   
DROP PROCEDURE [dbo].[qutl_get_page_section_info]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_page_section_info]
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
**  Name: qutl_get_page_section_info
**  Desc: This stored procedure returns a list of views from the qsiwindowview table.
**
**  Parameters:
**    windowname - Name of Page
**    userkey - userkey for userid accessing page
**    orgentrykey - orgentrykey at level for sections on page - Pass 0 if not applicable
**    itemtypecode - itemtype for page - Pass 0 if not applicable
**    usageclasscode - usageclass page - Pass 0 if not applicable
**
**  Auth: Alan Katzen
**  Date: May 6, 2010
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var         INT,
          @rowcount_var      INT,
          @v_count           INT,
          @v_windowviewkey   INT,
  --        @v_default_windowviewkey INT,
          @v_windowid        INT,
          @v_usageclasscode  INT

  
  SET @v_usageclasscode = COALESCE(@i_usageclasscode,0)
  
  IF @i_windowviewkey > 0 BEGIN
    SET @v_windowviewkey = @i_windowviewkey
  END
  ELSE BEGIN
    -- Find windowviewkey
    exec qutl_get_windowviewkey @i_windowname,@i_userkey,@i_orgentrykey,@i_itemtypecode,@i_usageclasscode,
                                @v_windowviewkey output,@o_error_code output,@o_error_desc output
                                
    IF @o_error_code < 0 BEGIN
      RETURN
    END 
  END
  
 --- SELECT @v_default_windowviewkey = qsiwindowviewkey
---    FROM qsiwindowview wv
 --  WHERE wv.defaultind = 1
 ---    AND wv.itemtypecode = @i_itemtypecode
 ---    AND COALESCE(wv.usageclasscode,0) = @v_usageclasscode

---  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
---  IF @error_var < 0 OR @rowcount_var = 0 BEGIN
---    SET @o_error_code = -1
--    SET @o_error_desc = 'Unable to load sections for page: Database Error finding default window view (' + cast(@error_var AS VARCHAR) + ').'
--    RETURN
--  END 

  SELECT @v_windowid = windowid
    FROM qsiwindows
   WHERE windowname = @i_windowname
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var < 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to load sections for page: Database Error accessing qsiwindows table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END 

  IF @v_windowviewkey > 0 BEGIN
    SELECT cd.configdetailkey, cd.configobjectkey, cd.qsiwindowviewkey, co.miscsectionind,cd.usageclasscode, 
           COALESCE(cd.labeldesc,co.defaultlabeldesc,'TBD') labeldesc, co.configobjectid,
           CASE
             WHEN co.configobjecttype in (3,4) THEN 
               dbo.qutl_get_section_visibility(cd.configobjectkey,@v_windowviewkey,co.configobjecttype,co.groupkey,@i_itemtypecode,@v_usageclasscode) 
             ELSE COALESCE(cd.visibleind,co.defaultvisibleind,1) 
           END AS visibleind,
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
           END AS sortviewcolumnnum           
      FROM qsiconfigdetail cd, qsiconfigobjects co 
     WHERE cd.configobjectkey = co.configobjectkey
       AND cd.qsiwindowviewkey = @v_windowviewkey
       AND co.configobjecttype in (3,4,5)
       AND visibleind = 1
    UNION
    SELECT configdetailkey, configobjectkey, qsiwindowviewkey, miscsectionind, usageclasscode,
           labeldesc, configobjectid,
           CASE
             WHEN configobjecttype in (3,4) THEN 
               dbo.qutl_get_section_visibility(configobjectkey,@v_windowviewkey,configobjecttype,groupkey,@i_itemtypecode,@v_usageclasscode) 
             ELSE COALESCE(visibleind,1) 
           END AS visibleind,
           minimizedind, 
           position, configobjectdesc,
           sectioncontrolname,
           path,
           editcontrolname,
           viewcontrolname,
           miscsectionind,
           COALESCE(position,999) sortposition,
           viewcolumnnum,
           CASE
            WHEN COALESCE(viewcolumnnum,0) = 0 THEN 999
            ELSE 
              COALESCE(viewcolumnnum,0)
           END AS sortviewcolumnnum                    
      FROM qutl_get_default_windowviews(@v_windowid) 
     WHERE configobjecttype in (3,4,5)
       AND visibleind = 1
       AND itemtypecode = @i_itemtypecode
       AND COALESCE(usageclasscode,0) = @v_usageclasscode
       AND configobjectkey not in (SELECT cd2.configobjectkey FROM qsiconfigdetail cd2 WHERE cd2.qsiwindowviewkey = @v_windowviewkey)  
 ORDER BY sortviewcolumnnum, sortposition, labeldesc  
END       
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var < 0 OR @rowcount_var = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to load sections for page: Database Error accessing qsiwindowview table for ' + @i_windowname + ' (' + cast(@error_var AS VARCHAR) + ').'
    RETURN
  END     
 
GO

GRANT EXEC on qutl_get_page_section_info TO PUBLIC
GO
