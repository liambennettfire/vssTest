IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qse_get_searchresultsviewslist]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qse_get_searchresultsviewslist]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qse_get_searchresultsviewslist]
 (@i_searchtypecode     integer,
  @i_userkey            integer,
  @i_itemtypecode       integer,
  @i_usageclasscode     integer,
  @o_error_code					integer output,
  @o_error_desc					varchar(2000) output)
AS

/******************************************************************************
**  Name: qse_get_searchresultsviewslist
**  Desc: This stored procedure returns a list of results views from the 
**        qse_searchresultsview table.
**
**  Auth: Alan Katzen
**  Date: May 7, 2012
*******************************************************************************/

DECLARE @error_var                   INT,
        @rowcount_var                INT,
        @sqlStmt		                 varchar(max),
        @v_count                     INT,
        @v_quote                     char(1)
          
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_quote = CHAR(39)

  SET @sqlStmt = 
   'SELECT DISTINCT srv.resultsviewkey, srv.resultsviewname, srv.resultsviewdesc, srv.searchtypecode,
      srv.userkey, srv.itemtypecode, srv.usageclasscode, srv.defaultind, 
      CASE srv.usageclasscode
        WHEN 0 THEN
          CASE
           WHEN srv.resultsviewkey = 
             (SELECT searchresultsviewkey FROM qsiusersitemtype 
              WHERE userkey=' + cast(@i_userkey as varchar) + ' AND itemtypecode=srv.itemtypecode) THEN 1
           ELSE 0
          END
        ELSE
          CASE
            WHEN srv.resultsviewkey = 
             (SELECT searchresultsviewkey FROM qsiusersusageclass 
              WHERE userkey=' + cast(@i_userkey as varchar) + ' AND itemtypecode=srv.itemtypecode AND usageclasscode=srv.usageclasscode) THEN 1
            ELSE 0
          END
      END AS mydefaultind,
      CASE srv.usageclasscode
        WHEN 0 THEN
          CASE
           WHEN srv.resultsviewkey = 
             (SELECT searchpopupresultsviewkey FROM qsiusersitemtype 
              WHERE userkey=' + cast(@i_userkey as varchar) + ' AND itemtypecode=srv.itemtypecode) THEN 1
           ELSE 0
          END
        ELSE
          CASE
            WHEN srv.resultsviewkey = 
             (SELECT searchpopupresultsviewkey FROM qsiusersusageclass 
              WHERE userkey=' + cast(@i_userkey as varchar) + ' AND itemtypecode=srv.itemtypecode AND usageclasscode=srv.usageclasscode) THEN 1
            ELSE 0
          END
      END AS mypopupdefaultind        
    FROM qse_searchresultsview srv 
    WHERE srv.searchtypecode = ' + cast(@i_searchtypecode as varchar) + 
    ' AND srv.itemtypecode = ' + cast(@i_itemtypecode as varchar) 
  
  IF (@i_userkey >= 0) BEGIN
    SET @sqlStmt = @sqlStmt + ' AND (COALESCE(srv.userkey,-1) = -1 OR srv.userkey = ' + cast(@i_userkey as varchar) + ' OR 
		        srv.userkey IN (SELECT accesstouserkey FROM qsiprivateuserlist WHERE primaryuserkey = ' + cast(@i_userkey as varchar) + '))'	  
  END

  IF (@i_usageclasscode > 0) BEGIN
    SET @sqlStmt = @sqlStmt + ' AND srv.usageclasscode IN (0,' + cast(@i_usageclasscode as varchar) + ')'
  END
  ELSE BEGIN
    SET @sqlStmt = @sqlStmt + ' AND COALESCE(srv.usageclasscode,0) = 0'
  END
  
  SET @sqlStmt = @sqlStmt + ' ORDER BY srv.resultsviewname '

  PRINT 'SQL:'
  print @sqlStmt

  EXEC(@sqlStmt)

  -- Save the @@ERROR and @@ROWCOUNT values in local 
  -- variables before they are cleared.
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Error accessing qse_searchresultsview table from qse_get_searchresultsviewslist stored proc'  
  END 

END
GO

GRANT EXEC on qse_get_searchresultsviewslist TO PUBLIC
GO

