IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qutl_get_default_qsiwindowview_sectiondetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qutl_get_default_qsiwindowview_sectiondetail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qutl_get_default_qsiwindowview_sectiondetail]
 (@i_qsiwindowviewkey   integer,
  @i_windowid           integer,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qutl_get_default_qsiwindowview_sectiondetail
**  Desc: This stored procedure returns the default qsiconfigdetail and 
**        qsiconfigobject info based on a selected qsiwindowview and windowid
**
**  Parameters:
**
**  Auth: Alan Katzen
**  Date: May 21, 2010
*******************************************************************************
**  Date    Who Change
**  ------- --- -------------------------------------------
**  08/23/16	Dustin Miller
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT,
          @rowcount_var INT

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
         co.configobjectid,
		 co.tabgroupsectionind,
		 co.allowedviewtype,
		 CASE
		  WHEN cd.viewtype IS NOT NULL THEN
		   cd.viewtype - 1
		  ELSE
		   CASE
		    WHEN (co.allowedviewtype = 1 OR co.allowedviewtype = 2) THEN
		     co.allowedviewtype - 1
			ELSE
			 0
			END
		  END AS viewtypeind
    FROM qsiconfigdetail cd, qsiconfigobjects co 
   WHERE cd.configobjectkey = co.configobjectkey
     AND cd.qsiwindowviewkey = @i_qsiwindowviewkey
     AND (co.configobjecttype in (3,4,5))       
  UNION
  SELECT 0 configdetailkey, co.configobjectkey, -1 qsiwindowviewkey, co.defaultlabeldesc as labeldesc, 
         COALESCE(co.defaultvisibleind,1) visibleind, 
         COALESCE(co.defaultminimizedind,0) minimizedind, 
         co.position, co.configobjectdesc, co.defaultlabeldesc, co.groupkey, co.configobjecttype,
         (select configobjectdesc from qsiconfigobjects where configobjectkey = co.groupkey) parentobjectdesc,
         (select COALESCE(position,999) from qsiconfigobjects where configobjectkey = co.groupkey) groupposition,
         COALESCE(co.position,999) sortposition, 1 allowupdates,
         COALESCE(co.defaultviewcolumnnum,0) viewcolumnnum,        
         CASE
          WHEN COALESCE(co.defaultviewcolumnnum,0) = 0 THEN 999
          ELSE 
            COALESCE(co.defaultviewcolumnnum,0)            
         END AS sortviewcolumnnum,
         COALESCE(co.initialeditmode, 0) initialeditmode,
         co.configobjectid,
		 tabgroupsectionind,
		 allowedviewtype,
		 CASE
		  WHEN (allowedviewtype = 1 OR allowedviewtype = 2) THEN
		   allowedviewtype - 1
		  ELSE
		   0
		  END AS viewtypeind
    FROM qsiconfigobjects co 
   WHERE co.windowid = @i_windowid
     AND (co.configobjecttype in (3,4,5))    
     AND co.configobjectkey not in (SELECT cd.configobjectkey FROM qsiconfigdetail cd WHERE cd.qsiwindowviewkey = @i_qsiwindowviewkey)  
ORDER BY sortviewcolumnnum, groupposition, sortposition, co.defaultlabeldesc
            
  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qsiconfigdetail/qsiconfigobjects table from qutl_get_default_qsiwindowview_sectiondetail stored proc'  +
                        '(qsiwindowviewkey = ' + cast(@i_qsiwindowviewkey as varchar) + ')'
  END 

GO

GRANT EXEC on qutl_get_default_qsiwindowview_sectiondetail TO PUBLIC
GO


