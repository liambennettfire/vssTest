IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_qsiwindowview_sectiondetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qutl_get_qsiwindowview_sectiondetail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_qsiwindowview_sectiondetail]
 (@i_qsiwindowviewkey   integer,
  @i_windowid           integer,
  @i_itemtypecode       integer,
  @i_usageclasscode     integer,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_qsiwindowview_sectiondetail
**  Desc: This stored procedure returns all qsiconfigdetail and qsiconfigobject
**        info based on a selected qsiwindowview, or returns default info
**        based on a windowid.
**
**  Parameters:
**
**  Auth: Alan Katzen
**  Date: April 29, 2010
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  2/24/15 Jrobinson Update conditions to include only visible objects 
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT,
          @v_usageclasscode INT
                  
  SET @v_usageclasscode = COALESCE(@i_usageclasscode,0)
  
  SELECT cd.configdetailkey, cd.configobjectkey, cd.qsiwindowviewkey, cd.labeldesc, 
         COALESCE(cd.visibleind,co.defaultvisibleind,1) visibleind, 
         COALESCE(cd.minimizedind,co.defaultminimizedind,0) minimizedind, 
         COALESCE(cd.position,co.position) position, co.configobjectdesc, co.defaultlabeldesc,
         co.groupkey, co.configobjecttype,
         (select configobjectdesc from qsiconfigobjects where configobjectkey = co.groupkey) parentobjectdesc,
         CASE
          WHEN co.configobjecttype = 4 OR (co.configobjecttype = 3 AND co.configobjectkey <> co.groupkey) THEN 
           (select COALESCE(position,999) from qsiconfigobjects 
            where configobjectkey = co.groupkey and qsiwindowviewkey = @i_qsiwindowviewkey) 
          ELSE 
            COALESCE(cd.position,co.position)
         END AS groupposition,
         COALESCE(cd.position,co.position,999) sortposition, 1 allowupdates,
         COALESCE(cd.viewcolumnnum,co.defaultviewcolumnnum,0) viewcolumnnum,        
         CASE
          WHEN COALESCE(cd.viewcolumnnum,co.defaultviewcolumnnum,0) = 0 THEN 999
          ELSE 
            COALESCE(cd.viewcolumnnum,co.defaultviewcolumnnum,0)
         END AS sortviewcolumnnum,
         COALESCE(cd.initialeditmode, co.initialeditmode, 0) initialeditmode,
         COALESCE(cd.sectioncontrolname,co.sectioncontrolname) sectioncontrolname,
         COALESCE(cd.path, co.path) path,
         COALESCE(cd.editcontrolname,co.editcontrolname) editcontrolname,
         COALESCE(cd.viewcontrolname,co.viewcontrolname) viewcontrolname         
    FROM qsiconfigdetail cd, qsiconfigobjects co 
   WHERE cd.configobjectkey = co.configobjectkey
     AND cd.qsiwindowviewkey = @i_qsiwindowviewkey
     AND (co.configobjecttype in (3,4,5))
	 AND defaultvisibleind = 1     
  UNION
  SELECT configdetailkey, configobjectkey, qsiwindowviewkey, labeldesc, 
         visibleind, minimizedind, position, configobjectdesc, defaultlabeldesc,
         groupkey, configobjecttype, parentobjectdesc,groupposition,
         COALESCE(position,999) sortposition, 1 allowupdates, viewcolumnnum,        
         CASE
          WHEN COALESCE(viewcolumnnum,0) = 0 THEN 999
          ELSE 
            COALESCE(viewcolumnnum,0)
         END AS sortviewcolumnnum,
         COALESCE(initialeditmode, 0) initialeditmode,
         sectioncontrolname,
         path,
         editcontrolname,
         viewcontrolname             
    FROM qutl_get_default_windowviews(@i_windowid) 
   WHERE configobjecttype in (3,4,5)
     AND visibleind = 1
     AND itemtypecode = @i_itemtypecode
     AND COALESCE(usageclasscode,0) = @v_usageclasscode
     AND configobjectkey not in (SELECT cd2.configobjectkey FROM qsiconfigdetail cd2 WHERE cd2.qsiwindowviewkey = @i_qsiwindowviewkey)  
ORDER BY sortviewcolumnnum, groupposition, sortposition, co.defaultlabeldesc
             
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qsiconfigdetail/qsiconfigobjects table from qutl_get_qsiwindowview_sectiondetail stored proc'  +
                        '(qsiwindowviewkey = ' + cast(@i_qsiwindowviewkey as varchar) + ')'
  END 


GO

GRANT EXEC on qutl_get_qsiwindowview_sectiondetail TO PUBLIC
GO

