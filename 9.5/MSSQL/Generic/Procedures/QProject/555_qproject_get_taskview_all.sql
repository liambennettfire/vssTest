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
  @i_itemtype       integer,
  @i_usageclass     integer,
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
**  6/23/15 - Colman - filter by item type/usage class case # 33111
**  8/16/16 - Colman - Case 37781
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @i_itemtype = COALESCE(@i_itemtype, 0)
  SET @i_usageclass = COALESCE(@i_usageclass, 0)
  
  DECLARE @error_var    INT,
		  @rowcount_var INT,
		  @v_sqlselect1  VARCHAR(4000),
		  @v_sqlselect2  VARCHAR(4000),
		  @v_sqlselect3  VARCHAR(4000),		  		  		  
		  @v_sqlfrom1    VARCHAR(2000),
		  @v_sqlfrom2    VARCHAR(2000),
		  @v_sqlfrom3    VARCHAR(2000),
		  @v_sqlwhere1   VARCHAR(max),    
		  @v_sqlwhere2   VARCHAR(max), 
		  @v_sqlwhere3   VARCHAR(max),     		  
		  @v_sqlstring   NVARCHAR(max),
		  @v_itemtype    INT,
		  @v_usageclass  INT,
		  @v_datacode_title INT,
		  @v_datacode_printing INT,
		  @v_IsPrintingOrTitle INT
		    
  SET @v_IsPrintingOrTitle = 0
  SET @v_itemtype = COALESCE(@i_itemtype, 0)
  SET @v_usageclass = COALESCE(@i_usageclass, 0)
  
  SELECT @v_datacode_title = datacode FROM gentables WHERE tableid = 550 and qsicode = 1
  SELECT @v_datacode_printing = datacode FROM gentables WHERE tableid = 550 and qsicode = 14
  
  IF @i_itemtype = @v_datacode_title OR @i_itemtype = @v_datacode_printing BEGIN
	 SET @v_IsPrintingOrTitle = 1
  END
		  
    SET @v_sqlselect1 = 'SELECT taskviewkey, taskviewdesc, elementtypecode, rolecode, 
           qsicode, COALESCE(alldatetypesind,0) alldatetypesind,
           COALESCE(minimizeselectionsectionind,0) minimizeselectionsection, 
           COALESCE(duedatevalidcode,1) duedatevalidcode, printingnumber, showinlistsubmenuind '
           
    SET @v_sqlfrom1 = ' FROM taskview '
    SET @v_sqlwhere1 = ' WHERE '  
   
    IF @i_taskgroupind IS NOT NULL BEGIN
	  SET @v_sqlwhere1 = @v_sqlwhere1 + ' taskgroupind = ' + cast(@i_taskgroupind as varchar) 
    END
    ELSE  BEGIN
	  SET @v_sqlwhere1 = @v_sqlwhere1 + ' taskgroupind <> 1 '	
    END
    
    SET @v_sqlwhere1 =   @v_sqlwhere1 + ' AND 
	     (userkey is null OR userkey = -1 OR userkey = ' + cast(@i_userkey as varchar) + ' OR 
		  userkey in (select accesstouserkey from qsiprivateuserlist where primaryuserkey = ' + cast(@i_userkey as varchar) + ')) '
		  
	IF @v_itemtype > 0 AND @v_usageclass > 0 BEGIN
	  SET @v_sqlwhere1 =   @v_sqlwhere1 + ' AND itemtypecode =' + cast(@v_itemtype as varchar) + ' AND usageclasscode IN (COALESCE(' + cast(@v_usageclass as varchar) + ', 0), 0) ' 	 
	END
	ELSE IF @v_itemtype > 0 AND @v_usageclass = 0 BEGIN
	  SET @v_sqlwhere1 =   @v_sqlwhere1 + ' AND itemtypecode =' + cast(@v_itemtype as varchar)
	END
		  
    SET @v_sqlselect2 = ' SELECT taskviewkey, taskviewdesc, elementtypecode, rolecode, 
           qsicode, COALESCE(alldatetypesind,0) alldatetypesind,
           COALESCE(minimizeselectionsectionind,0) minimizeselectionsection, 
           COALESCE(duedatevalidcode,1) duedatevalidcode, printingnumber, showinlistsubmenuind '
           
    SET @v_sqlfrom2 = ' FROM taskview '
    SET @v_sqlwhere2 = ' WHERE '          
    
    IF @i_taskgroupind IS NOT NULL BEGIN
	  SET @v_sqlwhere2 = @v_sqlwhere2 + ' taskgroupind = ' + cast(@i_taskgroupind as varchar) 
    END
    ELSE  BEGIN
	  SET @v_sqlwhere2 = @v_sqlwhere2 + ' taskgroupind <> 1 '	
    END       
    
    SET @v_sqlwhere2 =   @v_sqlwhere2 + ' AND 
	     (userkey is null OR userkey = -1 OR userkey = ' + cast(@i_userkey as varchar) + ' OR 
		  userkey in (select accesstouserkey from qsiprivateuserlist where primaryuserkey = ' + cast(@i_userkey as varchar) + ')) AND 
		  COALESCE(itemtypecode, 0) = 0 AND
		  COALESCE(usageclasscode, 0) = 0 ' 
		  
		  
	IF @v_IsPrintingOrTitle = 1 BEGIN
	    SET @v_itemtype = 0
	    SET @v_usageclass = 0
	    
	    IF @v_itemtype = @v_datacode_title BEGIN
	       SET @v_itemtype = @v_datacode_printing
	    END	   
	    ELSE BEGIN
		    SET @v_itemtype = @v_datacode_title
	    END
	   
		SET @v_sqlselect3 = 'SELECT taskviewkey, taskviewdesc, elementtypecode, rolecode, 
			   qsicode, COALESCE(alldatetypesind,0) alldatetypesind,
			   COALESCE(minimizeselectionsectionind,0) minimizeselectionsection, 
         COALESCE(duedatevalidcode,1) duedatevalidcode, printingnumber, showinlistsubmenuind '
	           
		SET @v_sqlfrom3 = ' FROM taskview '
		SET @v_sqlwhere3 = ' WHERE '  
	   
		IF @i_taskgroupind IS NOT NULL BEGIN
		  SET @v_sqlwhere3 = @v_sqlwhere3 + ' taskgroupind = ' + cast(@i_taskgroupind as varchar) 
		END
		ELSE  BEGIN
		  SET @v_sqlwhere3 = @v_sqlwhere3 + ' taskgroupind <> 1 '	
		END
	    
		SET @v_sqlwhere3 =   @v_sqlwhere3 + ' AND 
			 (userkey is null OR userkey = -1 OR userkey = ' + cast(@i_userkey as varchar) + ' OR 
			  userkey in (select accesstouserkey from qsiprivateuserlist where primaryuserkey = ' + cast(@i_userkey as varchar) + ')) '
			  
		IF @v_itemtype > 0 AND @v_usageclass > 0 BEGIN
		  SET @v_sqlwhere3 =   @v_sqlwhere3 + ' AND itemtypecode =' + cast(@v_itemtype as varchar) + ' AND usageclasscode IN (COALESCE(' + cast(@v_usageclass as varchar) + ', 0), 0) ' 	 
		END
		ELSE IF @v_itemtype > 0 AND @v_usageclass = 0 BEGIN
		  SET @v_sqlwhere3 =   @v_sqlwhere3 + ' AND itemtypecode =' + cast(@v_itemtype as varchar)
		END			
	END	  
        
    SET @v_sqlstring = @v_sqlselect1 + @v_sqlfrom1 + @v_sqlwhere1 +
      ' UNION ' + @v_sqlselect2 + @v_sqlfrom2 + @v_sqlwhere2 
      
    IF @v_IsPrintingOrTitle = 1 BEGIN
		SET @v_sqlstring = @v_sqlstring +  ' UNION ' + @v_sqlselect3 + @v_sqlfrom3 + @v_sqlwhere3 		
    END  
    
    SET @v_sqlstring = @v_sqlstring +  ' ORDER BY alldatetypesind desc, taskviewdesc, taskviewkey '        
               
	EXECUTE sp_executesql @v_sqlstring  
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
