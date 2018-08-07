if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_get_taskview_all') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qproject_get_taskview_all
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qproject_get_taskview_all
 (@i_taskgroupind   integer,
  @i_userkey		integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/******************************************************************************
**  Name: qproject_get_taskview_all
**  Desc: This stored procedure returns all taskview information.
**
**    Auth: Alan Katzen
**    Date: 9/24/04
**
**  8/3/05 - KW - get only what's needed - these values are saved in viewstate.
**  8/1/08 - Lisa - filtering the returned data by userkey, see case # 05427
**					for DUP development.
**  11/5/08 - Lisa - added qsicode for app to filter out template taskviews
**                   with qsicodes = 4 & 5 (reader & contract information) case #05565
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_taskgroupind IS NOT NULL
    SELECT taskviewkey, taskviewdesc, elementtypecode, rolecode, 
           qsicode, COALESCE(alldatetypesind,0) alldatetypesind,
           COALESCE(minimizeselectionsectionind,0) minimizeselectionsection, printingnumber
      FROM taskview
     WHERE taskgroupind = @i_taskgroupind
    -- Filtering Task View returned based on current user
	     AND ( userkey is null OR userkey = -1 OR userkey = @i_userkey OR 
		        userkey in ( select accesstouserkey from qsiprivateuserlist where primaryuserkey = @i_userkey ) ) 		  
    ORDER BY alldatetypesind desc, taskviewdesc, taskviewkey
  ELSE
    SELECT taskviewkey, taskviewdesc, elementtypecode, rolecode, 
           qsicode, COALESCE(alldatetypesind,0) alldatetypesind,
           COALESCE(minimizeselectionsectionind,0) minimizeselectionsection, printingnumber
      FROM taskview
    -- Filtering Task View returned based on current user
	   WHERE taskgroupind <> 1 AND
		     ( userkey is null OR userkey = -1 OR userkey = @i_userkey OR 
		       userkey in ( select accesstouserkey from qsiprivateuserlist where primaryuserkey = @i_userkey ) ) 		  
    ORDER BY alldatetypesind desc, taskviewdesc, taskviewkey  

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 or @rowcount_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: taskview table empty.'
  END 

GO

GRANT EXEC ON qproject_get_taskview_all TO PUBLIC
GO
