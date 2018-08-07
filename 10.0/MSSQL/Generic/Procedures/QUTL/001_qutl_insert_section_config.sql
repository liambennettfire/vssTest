SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_section_config' ) 
     DROP PROCEDURE qutl_insert_section_config 
go

CREATE PROCEDURE [dbo].[qutl_insert_section_config]
 (@i_tabgroupsectionlabel	 varchar (100),
  @i_itemqsicode           integer,  --Send 0 for Home Page sections
  @i_classqsicode		       integer,  
  @i_position			         integer,  --If 0, will select the max position for the view
  @o_configobjectkey	     integer OUTPUT,
  @o_error_code            integer OUTPUT,
  @o_error_desc			       varchar(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qutl_insert_section_config  
**  Desc: This stored procedure searches to see if a tab group section exists based on 
**		  itemtypecode and defaultlabeldesc for qsiconfobjects.  
**        If no existing value is found, it is inserted; If it is found, it will
**        be updated.  Security is not needed for tab groups.      
**    Auth: Uday A. Khisty
**    Date: 1 July 2016
********************************************************************************************
**    Change History
********************************************************************************************
**    Date:         Author:        Description:
**    --------      --------       --------------------------------------------------------
**    9/1/16        Alan           Changed default configobject visibility to false and added
**                                 code to add section as visible to all default views for item type
**                                 when no class is passed in
**
**	  11-9-16	      Dustin		     Improved the logic to figure out the position for the object/detail
**																 when it is not passed as a parameter
**
**	  11-9-16		    Dustin		     Added missing functionality to generate the qsiconfigdetailtab records
**		04-14-17      Dustin         This procedure was not intended for Title Tab groups, those have a different
																	 ControlName and qsiconfigdetailtabs records have a flag to indicate it is title based.
																	 Title Tabs get converted via the TMM 9.9 009 table sql.
**    12-01-17      Colman         Case 48604 Issues inserting title tabs to main title relationship group
********************************************************************************************/

  DECLARE
  @v_itemtypecode		integer,
  @v_itemtypedesc		varchar(40),
  @v_classcode			integer,
  @v_windowid			integer,
  @v_qsiwindowviewkey	integer,
  @v_configobjectid		varchar (100),
  @v_key				integer,
  @v_configdetailkey    integer,
  @v_sectioncontrolname varchar (4000), -- tab group control
  @v_windowviewname		varchar (40),
  @v_sort				integer,
  @v_maxposition        integer,
  @v_usageclass			integer,
  @v_datacode			integer,
  @v_objposition		integer,
  @v_detposition		integer,
  @v_tabcode			integer,
  @v_tabsort			integer,
  @v_tabtableid   integer,
  @v_count				integer
     
BEGIN

  SET @v_itemtypecode = 0
  SET @v_itemtypedesc = ' '
  SET @v_classcode = 0
  SET @v_windowid = 0
  SET @v_qsiwindowviewkey = 0
  SET @v_configobjectid = 0
  SET @v_key = 0
  SET @v_configdetailkey = 0
  SET @v_sectioncontrolname = NULL	
  SET @v_windowviewname = NULL
  SET @o_configobjectkey = 0
  SET @v_maxposition = 0
  SET @v_datacode = 0
  SET @o_configobjectkey = 0
  SET @v_objposition = @i_position
   
  -- Get Item Type and class codes from the item and class qsicodes
  IF @i_itemqsicode = 0  BEGIN
    --HOME page
    SET @v_itemtypecode = 0
    SET @v_classcode = 0
    SET @v_itemtypedesc = 'HOME'
  END
  ELSE  BEGIN
    exec qutl_get_item_class_datacodes_from_qsicodes @i_itemqsicode, @i_classqsicode,  @v_itemtypecode output, @v_classcode output,
         @o_error_code output,@o_error_desc output
	  IF @o_error_code <> 0 BEGIN
	    RETURN
	  END 
	
	  IF COALESCE(@v_itemtypecode, 0) > 0 BEGIN
	     SELECT @v_itemtypedesc = datadesc FROM gentables WHERE tableid = 550 AND datacode = @v_itemtypecode
	  END
  END

  --Check to see if section exists already
  SELECT @o_configobjectkey = configobjectkey
  FROM qsiconfigobjects
  WHERE defaultlabeldesc = @i_tabgroupsectionlabel AND itemtypecode = @v_itemtypecode
    
  IF @o_configobjectkey = 0 BEGIN
    SET @v_sectioncontrolname = '~/PageControls/Projects/Sections/Summary/TabGroupSection.ascx'

    -- Section does not exists already; insert into qsiconfig objects 
    -- Determine Section Control Name and WindowID based on Item Type     
	  IF @v_itemtypecode = 0  BEGIN
	      SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'home')
	  END
	  ELSE IF @v_itemtypecode = 1  BEGIN
	     SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'productsummary')
	  END
	  ELSE IF @v_itemtypecode = 2  BEGIN
	      SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'contactsummary')
	  END
	  ELSE IF @v_itemtypecode = 3  BEGIN
	      SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'projectsummary')
	  END	
	  ELSE IF @v_itemtypecode = 6  BEGIN
	      SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'journalsummary')
	  END	
	  ELSE IF @v_itemtypecode = 7  BEGIN    	
	      SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'elements')
	  END	
	  ELSE IF @v_itemtypecode = 9  BEGIN   	
	      SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'worksummary')
	  END	
	  ELSE IF @v_itemtypecode = 10  BEGIN
	      SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'contractsummary')
	  END	
	  ELSE IF @v_itemtypecode = 11  BEGIN
	      SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'scalesummary')
	  END	
	  ELSE IF @v_itemtypecode = 14  BEGIN
	      SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'printingsummary')
	  END		    
	  ELSE IF @v_itemtypecode = 15  BEGIN
	      SET @v_windowid = (SELECT windowid FROM qsiwindows WHERE LTRIM(RTRIM(LOWER(windowname))) = 'posummary')
	  END		    
	  ELSE BEGIN
		  SET @o_error_code = -1	
		  SET @o_error_desc = 'Section Control and WindowID could not be identified by Item Type for item type code = '+ cast(@v_itemtypecode AS VARCHAR)+'.  Tab Group section = ' +@i_tabgroupsectionlabel +' could no be created.  qutl_insert_section_config may need to be updated'  
		  RETURN
	  END
	
	  IF EXISTS (SELECT * FROM gentables_ext WHERE tableid = 680 AND LTRIM(RTRIM(LOWER(gentext1))) = LTRIM(RTRIM(LOWER(@i_tabgroupsectionlabel)))) BEGIN
		  SELECT @v_datacode = datacode FROM gentables_ext WHERE tableid = 680 AND LTRIM(RTRIM(LOWER(gentext1))) = LTRIM(RTRIM(LOWER(@i_tabgroupsectionlabel)))
	  END
	  ELSE IF EXISTS (SELECT * FROM gentables WHERE tableid = 680 AND LTRIM(RTRIM(LOWER(datadesc))) = LTRIM(RTRIM(LOWER(@i_tabgroupsectionlabel)))) BEGIN
		  SELECT @v_datacode = datacode FROM gentables WHERE tableid = 680 AND LTRIM(RTRIM(LOWER(datadesc))) = LTRIM(RTRIM(LOWER(@i_tabgroupsectionlabel)))
	  END
	  ELSE BEGIN
	     SET @o_error_code = -1	
	     SET @o_error_desc = 'Error occurred in trying to locate entry for gentables 680 in gentext1 or datadesc for ' + @i_tabgroupsectionlabel  
	     RETURN	
	  END	
	
	  IF COALESCE(@v_objposition, 0) = 0
	  BEGIN
		  SELECT @v_objposition = sortorder
		  FROM gentables
		  WHERE tableid = 680
		    AND datacode = @v_datacode
	  END

    SET @v_configobjectid = @v_itemtypedesc + 'Tabgroup' + convert(varchar(30),@v_datacode)	

	  SELECT @v_key = MAX(configobjectkey)
	  FROM qsiconfigobjects

    SET @o_configobjectkey = @v_key + 1
      
    -- default to not visible
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, itemtypecode,miscsectionind,
      sectioncontrolname ,configobjecttype, groupkey, tabgroupsectionind, position)
    VALUES (@o_configobjectkey, @v_windowid, @v_configobjectid, @i_tabgroupsectionlabel, @i_tabgroupsectionlabel,
      'QSIDBA', getdate(), 0, @v_itemtypecode, 0, @v_sectioncontrolname,3,@o_configobjectkey, 1, @v_objposition)
  
    SELECT @o_error_code = @@ERROR
    IF @o_error_code <> 0 BEGIN
	    SET @o_error_code = -1	
		  SET @o_error_desc = 'Error occurred inserting into qsiconfigobjects for ' + @i_tabgroupsectionlabel  
		  RETURN
	  END
  END
  ELSE  BEGIN
    -- Section already exists; update description and label in qsiconfig objects
    UPDATE qsiconfigobjects
    SET configobjectdesc= @i_tabgroupsectionlabel, defaultlabeldesc = @i_tabgroupsectionlabel, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE configobjectkey = @o_configobjectkey
    
    SELECT @o_error_code = @@ERROR
       IF @o_error_code <> 0 BEGIN
	  	 SET @o_error_code = -1	
		 SET @o_error_desc = 'Error occurred updating qsiconfigobjects for ' + @i_tabgroupsectionlabel  
		 RETURN
    END
  END

  IF @v_itemtypecode = 7 and coalesce(@v_classcode,0) = 0 BEGIN
    -- for now elements must have usageclass selected
    return
  END
 
  --Find the window views for this class and add the section if it does not already exist; if it exists,
  --update the label and position
  IF @v_itemtypecode > 0 and coalesce(@v_classcode,0) = 0 BEGIN
    -- no usage class so find all window views for the item type
 	  DECLARE windowview_cur CURSOR FOR
     SELECT qsiwindowviewkey, usageclasscode
       FROM qsiwindowview
      WHERE itemtypecode = @v_itemtypecode
  END
  ELSE BEGIN
 	  DECLARE windowview_cur CURSOR FOR
     SELECT qsiwindowviewkey, usageclasscode
       FROM qsiwindowview
      WHERE itemtypecode = @v_itemtypecode and usageclasscode = @v_classcode
  END

	OPEN windowview_cur
	
	FETCH NEXT FROM windowview_cur INTO @v_qsiwindowviewkey, @v_usageclass
	
	WHILE (@@FETCH_STATUS = 0) BEGIN
    IF @v_qsiwindowviewkey = 0 OR @v_qsiwindowviewkey IS NULL  BEGIN
 	    SET @o_error_code = -1	
	    SET @o_error_desc = 'No default window view exists for class qsicode =  ' +  cast(@i_classqsicode AS VARCHAR) + '.  Cannot insert section label, ' + @i_tabgroupsectionlabel + ', into view.'  
      print @o_error_desc
	    continue
    END
    ELSE BEGIN
      -- insert or update the qsiconfigdetail row for this section and the default window view for class 
	    SET @v_configdetailkey = NULL

      SELECT @v_configdetailkey = configdetailkey
        FROM qsiconfigdetail
       WHERE configobjectkey = @o_configobjectkey AND
             qsiwindowviewkey = @v_qsiwindowviewkey
	  
	    SET @v_detposition = @i_position

      IF @v_configdetailkey = 0 OR @v_configdetailkey IS NULL BEGIN
        --Create the qsiconfigdetail row to get the section in the default window view for the class
        EXEC dbo.get_next_key 'QSIDBA', @v_configdetailkey OUT

	      IF COALESCE(@v_detposition, 0) = 0 BEGIN 
			    SELECT @v_detposition = sortorder
			    FROM gentablesitemtype
			    WHERE tableid = 680
				    AND datacode = @v_datacode
				    AND itemtypecode = @v_itemtypecode
				    AND itemtypesubcode = @v_usageclass

			    IF COALESCE(@v_detposition, 0) = 0
			    BEGIN
				    SELECT @v_detposition = position FROM qsiconfigobjects WHERE configobjectkey = @o_configobjectkey

				    IF COALESCE(@v_detposition, 0) = 0
				    BEGIN
					    SELECT @v_detposition = max(position) FROM qsiconfigdetail WHERE configobjectkey = @o_configobjectkey AND qsiwindowviewkey = @v_qsiwindowviewkey
				    END
			    END
  	  	END

        INSERT INTO qsiconfigdetail
          (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, position, lastuserid, lastmaintdate,qsiwindowviewkey)
        VALUES (@v_configdetailkey, @o_configobjectkey, @v_usageclass, @i_tabgroupsectionlabel, 1, @v_detposition, 'QSIDBA', getdate(),@v_qsiwindowviewkey)
        
        SELECT @o_error_code = @@ERROR
        IF @o_error_code <> 0 BEGIN
	        SET @o_error_code = -1	
		      SET @o_error_desc = 'Error occurred inserting into qsiconfigdetail for ' + @i_tabgroupsectionlabel  
		      RETURN
        END
      END
      ELSE BEGIN
	      --Update the label and position on the existing section
	      IF @v_detposition = 0 BEGIN
		      SET @v_detposition = NULL
	      END

	      UPDATE qsiconfigdetail 
	         SET labeldesc = @i_tabgroupsectionlabel, visibleind = 1, position = COALESCE(@v_detposition, position), lastuserid = 'QSIDBA', lastmaintdate = getdate() 
         WHERE @v_configdetailkey = configdetailkey

        SELECT @o_error_code = @@ERROR
        IF @o_error_code <> 0 BEGIN
	        SET @o_error_code = -1	
		      SET @o_error_desc = 'Error occurred updating qsiconfigdetail for ' + @i_tabgroupsectionlabel  
		      RETURN
        END
      END
    END

    IF @v_itemtypecode = 1
      SET @v_tabtableid = 440
    ELSE
      SET @v_tabtableid = 583
    
	  --Generate qsiconfigdetailtabs records
	  DECLARE tab_cur CURSOR FOR
	  SELECT i.datacode, i.sortorder
	  FROM gentablesitemtype i
	  JOIN gentables g
	  ON i.tableid = g.tableid AND i.datacode = g.datacode
	  WHERE i.tableid = @v_tabtableid
	    AND i.itemtypecode = @v_itemtypecode
	    AND (i.itemtypesubcode = @v_usageclass OR @v_usageclass = 0)
	    AND (g.deletestatus <> 'Y' or g.deletestatus <> 'y')
	  ORDER BY i.datacode
	
	  OPEN tab_cur
	
	  FETCH NEXT FROM tab_cur INTO @v_tabcode, @v_tabsort
	
	  WHILE (@@FETCH_STATUS = 0)
	  BEGIN
		  SELECT @v_count = COUNT(*)
		  FROM qsiconfigdetailtabs t
		  WHERE t.configdetailkey = @v_configdetailkey
		    AND t.relationshiptabcode = @v_tabcode

		  IF @v_count = 0
		  BEGIN
			  INSERT INTO qsiconfigdetailtabs
			  (configdetailkey, relationshiptabcode, sortorder, lastuserid, lastmaintdate)
			  VALUES
			  (@v_configdetailkey, @v_tabcode, @v_tabsort, 'QSIDBA', GETDATE())
		  END

		  FETCH NEXT FROM tab_cur INTO @v_tabcode, @v_tabsort
	  END

	  CLOSE tab_cur
	  DEALLOCATE tab_cur

  	FETCH NEXT FROM windowview_cur INTO @v_qsiwindowviewkey, @v_usageclass
  END
 
  CLOSE windowview_cur 
  DEALLOCATE windowview_cur  

END

GO
GRANT EXEC ON qutl_insert_section_config TO PUBLIC
GO
