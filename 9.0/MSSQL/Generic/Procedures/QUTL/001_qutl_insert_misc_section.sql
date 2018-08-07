
/****** Object:  StoredProcedure [dbo].[qutl_insert_misc_section]    Script Date: 01/09/2015 11:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type = 'p' and name = 'qutl_insert_misc_section' ) 
     DROP PROCEDURE qutl_insert_misc_section 
go

CREATE PROCEDURE [dbo].[qutl_insert_misc_section]
 (@i_miscsectionlabel	 varchar (100),
  @i_classqsicode		 integer,  --Send 0 for Home Page sections
  @i_position			 integer,  --If 0, will select the max position for the view
  @o_configobjectkey	 integer OUTPUT,
  @o_error_code          integer OUTPUT,
  @o_error_desc			 varchar(2000) OUTPUT)
AS

/******************************************************************************************
**  Name: qutl_insert_misc_section  
**  Desc: This stored procedure searches to see if a miscitemsection exists based on 
**		  itemtypecode and defaultlabeldesc for qsiconfobjects.  
**        If no existing value is found, it is inserted; If it is found, it will
**        be updated.  Security will be created for this section as well.      
**    Auth: SLB
**    Date: 11 Jan 2015
********************************************************************************************
**    Change History
********************************************************************************************
**    Date:    Author:        Description:
**    --------    --------        --------------------------------------------------------
**    
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
  @v_sectioncontrolname varchar (4000),
  @v_windowviewname		varchar (40),
  @v_sort				integer,
  @v_maxposition        integer,
  @v_usageclass			integer
     
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
   
  -- Get Item Type and class codes from the class qsicode
  IF @i_classqsicode = 0  BEGIN
    --HOME page
    SET @v_itemtypecode = 0
    SET @v_classcode = 0
    SET @v_itemtypedesc = 'HOME'
  END
  ELSE  BEGIN
    exec qutl_get_item_class_datacodes_from_qsicodes NULL, @i_classqsicode,  @v_itemtypecode output, @v_classcode output,
         @o_error_code output,@o_error_desc output
	IF @o_error_code <> 0 BEGIN
	  RETURN
	END 
  END
  
  --Check to see if section exists already
  SELECT @o_configobjectkey = configobjectkey
  FROM qsiconfigobjects
  WHERE defaultlabeldesc = @i_miscsectionlabel AND itemtypecode = @v_itemtypecode
  
  IF @o_configobjectkey = 0 BEGIN
   -- Section does not exists already; insert into qsiconfig objects 
   -- Determine Section Control Name and WindowID based on Item Type     
	IF @v_itemtypecode = 0  BEGIN
	    SET @v_sectioncontrolname= '~/PageControls/Home/Sections/HomeMisc.ascx'
	    SET @v_windowid = 658
	    END
	ELSE IF @v_itemtypecode = 1  BEGIN
	    SET @v_sectioncontrolname= '~/PageControls/TitleSummary/Sections/TitleMiscSection.ascx'
	    SET @v_windowid = 660
	    END
	ELSE IF @v_itemtypecode = 2  BEGIN
	    SET @v_sectioncontrolname= '~/PageControls/Contacts/Sections/Summary/ContactsMisc.ascx'
	    SET @v_windowid = 674
	    END
	ELSE IF @v_itemtypecode = 3  BEGIN
	    SET @v_sectioncontrolname=  '~/PageControls/Projects/Sections/Summary/ProjectsMisc.ascx' 
	    SET @v_windowid = 669
	    END	
	ELSE IF @v_itemtypecode = 6  BEGIN
	    SET @v_sectioncontrolname=  '~/PageControls/Journals/Sections/Summary/JournalsMisc.ascx' 
	    SET @v_windowid = 730
	    END	
	ELSE IF @v_itemtypecode = 7  BEGIN
	    SET @v_sectioncontrolname=  '~/PageControls/Elements/Sections/Summary/ElementsMisc.ascx'     	
	    SET @v_windowid = 667
	    END	
	ELSE IF @v_itemtypecode = 9  BEGIN
	    SET @v_sectioncontrolname=  '~/PageControls/Work/Sections/Summary/WorkMisc.ascx'     	
	    SET @v_windowid = 779
	    END	
	ELSE IF @v_itemtypecode = 10  BEGIN
	    SET @v_sectioncontrolname=  '~/PageControls/Contracts/Sections/Summary/ContractMisc.ascx' 
	    SET @v_windowid = 804
	    END	
	ELSE IF @v_itemtypecode = 11  BEGIN
	    SET @v_sectioncontrolname=  '~/PageControls/Scales/Sections/Summary/ScalesMisc.ascx' 
	    SET @v_windowid = 806
	    END	
	--COMMENTED OUT UNTIL I GET ANSWERS FROM DEV ON CORRECT SECTION FOR PURCHASE ORDERS AND PRINTINGS
	--ELSE IF @v_itemtypecode = 15  BEGIN
	--    SET @v_sectioncontrolname=  '~/PageControls/Projects/Sections/Summary/ProjectsMisc.ascx' 
	--    SET @v_windowid = 915
	--    END	
	ELSE BEGIN
		SET @o_error_code = -1	
		SET @o_error_desc = 'Section Control and WindowID could not be identified by Item Type for item type code = '+ cast(@v_itemtypecode AS VARCHAR)+'.  Misc section = ' +@i_miscsectionlabel +' could no be created.  qutl_insert_misc_section may need to be updated'  
		RETURN
	END

	SELECT @v_key = MAX(configobjectkey)
	FROM qsiconfigobjects

    SET @o_configobjectkey = @v_key + 1

    SET @v_configobjectid = @v_itemtypedesc + 'Misc' + convert(varchar(30),@v_key)
      
    INSERT INTO qsiconfigobjects
      (configobjectkey, windowid, configobjectid, configobjectdesc, defaultlabeldesc, 
      lastuserid, lastmaintdate, defaultvisibleind, itemtypecode,miscsectionind,
      sectioncontrolname ,configobjecttype, groupkey)
    VALUES (@o_configobjectkey, @v_windowid, @v_configobjectid, @i_miscsectionlabel, @i_miscsectionlabel,
      'QSIDBA', getdate(), 0, @v_itemtypecode, 1, @v_sectioncontrolname,3,@o_configobjectkey)
  
    SELECT @o_error_code = @@ERROR
       IF @o_error_code <> 0 BEGIN
	  	 SET @o_error_code = -1	
		 SET @o_error_desc = 'Error occurred inserting into qsiconfigobjects for ' + @i_miscsectionlabel  
		 RETURN
	   END
  END
  ELSE  BEGIN
    -- Section already exists; update description and label in qsiconfig objects
    UPDATE qsiconfigobjects
    SET configobjectdesc= @i_miscsectionlabel, defaultlabeldesc = @i_miscsectionlabel, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
    WHERE configobjectkey = @o_configobjectkey
    
    SELECT @o_error_code = @@ERROR
       IF @o_error_code <> 0 BEGIN
	  	 SET @o_error_code = -1	
		 SET @o_error_desc = 'Error occurred updating qsiconfigobjects for ' + @i_miscsectionlabel  
		 RETURN
    END
  END
 
  --Find the Default window view for this class and add the section if it does not already exist; if it exists,
  --update the label and position
   SELECT TOP 1 @v_qsiwindowviewkey = qsiwindowviewkey
      FROM qsiwindowview
      WHERE itemtypecode = @v_itemtypecode and usageclasscode = @v_classcode and defaultind = 1

  IF @v_qsiwindowviewkey = 0 OR @v_qsiwindowviewkey IS NULL  BEGIN
	  	 SET @o_error_code = -1	
		 SET @o_error_desc = 'No default window exists for class qsicode =  ' +  cast(@i_classqsicode AS VARCHAR) + '.  Cannot insert section label, ' + @i_miscsectionlabel + ', into view.'  
		 END
  ELSE  BEGIN
  -- insert or update the qsiconfigdetail row for this section and the default window view for class 
    SELECT @v_configdetailkey = configdetailkey
    FROM qsiconfigdetail
    WHERE configobjectkey = @o_configobjectkey AND
      qsiwindowviewkey = @v_qsiwindowviewkey
	

    IF @v_configdetailkey = 0 OR @v_configdetailkey IS NULL BEGIN
      --Create the qsiconfigdetail row to get the section in the default window view for the class
      EXEC dbo.get_next_key 'QSIDBA', @v_configdetailkey OUT
	  IF @i_position = 0 SELECT @i_position = max(position) FROM qsiconfigdetail WHERE configobjectkey = @o_configobjectkey AND qsiwindowviewkey = @v_qsiwindowviewkey
	  	  
      INSERT INTO qsiconfigdetail
        (configdetailkey,configobjectkey, usageclasscode, labeldesc, visibleind, position, lastuserid, lastmaintdate,qsiwindowviewkey)
      VALUES (@v_configdetailkey, @o_configobjectkey, @v_classcode, @i_miscsectionlabel, 1, @i_position, 'QSIDBA', getdate(),@v_qsiwindowviewkey)
        
      SELECT @o_error_code = @@ERROR
      IF @o_error_code <> 0 BEGIN
	    SET @o_error_code = -1	
		SET @o_error_desc = 'Error occurred inserting into qsiconfigdetail for ' + @i_miscsectionlabel  
		RETURN
      END
    END
    ELSE BEGIN
	  --Update the label and position on the existing section
	  UPDATE qsiconfigdetail 
	  SET labeldesc = @i_miscsectionlabel, visibleind = 1, position = @i_position, lastuserid = 'QSIDBA', lastmaintdate = getdate() 
      WHERE    @v_configdetailkey = configdetailkey
      SELECT @o_error_code = @@ERROR
      IF @o_error_code <> 0 BEGIN
	    SET @o_error_code = -1	
		SET @o_error_desc = 'Error occurred updating qsiconfigdetail for ' + @i_miscsectionlabel  
		RETURN
       END
    END
  END 
 
--Create a security record for the miscitem section in securityobjectsavailable table for the Summary Window determined above based on item type
  SELECT @v_sort = ( select max(sortorder) from securityobjectsavailable where windowid = @v_windowid 
                    and availobjectname is null and availobjectdesc like '%- ALL%' ) 

  IF ( @v_sort is null ) SET @v_sort = 0

  IF not exists ( select availablesecurityobjectskey from securityobjectsavailable where windowid = @v_windowid and availobjectid = @v_configobjectid )
  BEGIN
    SET @v_sort = @v_sort + 1
	EXEC get_next_key 'qsidba', @v_key output
    INSERT INTO securityobjectsavailable
        (availablesecurityobjectskey, windowid, availobjectid, availobjectname, availobjectdesc, sortorder,lastuserid, lastmaintdate)           
    VALUES ( @v_key, @v_windowid, @v_configobjectid, null, @i_miscsectionlabel + ' - ALL', @v_sort,  'QSIDBA', getdate()) 
    
    SELECT @o_error_code = @@ERROR
    IF @o_error_code <> 0 BEGIN
	  SET @o_error_code = -1	
	  SET @o_error_desc = 'Error occurred updating securityobjectsavailable for ' + @i_miscsectionlabel  
	END
  END

END

GO