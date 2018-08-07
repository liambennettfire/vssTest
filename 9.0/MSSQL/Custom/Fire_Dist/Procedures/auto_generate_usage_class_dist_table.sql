if exists (select * from dbo.sysobjects where id = object_id(N'dbo.auto_generate_usage_class_dist_table') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.auto_generate_usage_class_dist_table
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE auto_generate_usage_class_dist_table
 (@i_itemtypecode					 integer,
  @i_usageclasscode         integer,
  @i_action                 integer,
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: auto_generate_usage_class_dist_table
**  Desc: This stored procedure determines which gentables, misc items and task
**        view/groups to export based on item type filtering
**        (Use in DWO) 
**        
**  Parameters: Item Type, Usage Class,
**              Action - 0 (Replace) - the procedure will delete everything 
**													currently in the usageclassdist table
**                                     for that item type, usage class and 
**                                     then add in all items that can be
**                                     determined automatically
**                       1 (Add)     - the procedure will leave everything
**                                     currently in the usageclassdist table
**                                     for that item type, usageclass and then
**                                     add in all items that do not exist
**                                     currently         
**
**    Auth: Kusum Basra
**    Date: 30 March 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

 SET @o_error_code = 0
 SET @o_error_desc = ''
 DECLARE @error_var    INT
 DECLARE @rowcount_var INT

 IF @i_action IS NULL BEGIN
   SET @o_error_code = -1
   SET @o_error_desc = 'Unable to auto generate usageclassdistribution table : action is empty.'
   RETURN
 END 

 DECLARE
	@v_count 							INT,
   @v_count2 							INT,
	@v_tableid							INT,
	@v_datacode							INT,
	@v_datasubcode						INT,
   @v_data2subcode					INT,
   @v_classexportcategory			INT,
   @v_misckey							INT,
   @v_configobjectkey				INT,
   @v_configdetailkey				INT,
   @v_taqrelationshiptabconfigkey INT,
   @v_taskviewkey						INT
	


 SET @v_count = 0

 IF @i_action = 0 BEGIN
   SELECT @v_count = count(*)
     FROM usageclassdistribution
    WHERE itemtypecode = @i_itemtypecode
      AND usageclasscode = @i_usageclasscode

	IF @v_count > 0
   BEGIN
		DELETE FROM usageclassdistribution
		 WHERE itemtypecode = @i_itemtypecode
			AND usageclasscode = @i_usageclasscode
   END
 END

 DECLARE gentablesitemtype_cursor CURSOR FOR
	SELECT tableid,datacode,datasubcode,datasub2code
	  FROM gentablesitemtype 
	 WHERE itemtypecode = @i_itemtypecode
		AND itemtypesubcode = @i_usageclasscode
	 ORDER BY tableid

 OPEN gentablesitemtype_cursor

 FETCH NEXT FROM gentablesitemtype_cursor INTO @v_tableid, @v_datacode, @v_datasubcode, @v_data2subcode	
  
 WHILE (@@FETCH_STATUS = 0) 
 BEGIN
     SET @v_count2 = 0

     SET @v_classexportcategory = 1  -- datacode for gentables tableid 612 (Class Export Category)

	  SELECT @v_count2 = count(*)
       FROM usageclassdistribution
      WHERE itemtypecode = @i_itemtypecode
        AND usageclasscode = @i_usageclasscode
        AND classexportcategory = @v_classexportcategory
        AND key1 = @v_tableid
        AND key2 = @v_datacode
        AND key3 = @v_datasubcode
        AND key4 = @v_data2subcode

      
		IF @v_count2 = 0
      BEGIN
			INSERT INTO usageclassdistribution (itemtypecode,usageclasscode,classexportcategory,key1,key2,key3,key4,autogenerateind,lastmaintdate,lastuserid)
          VALUES(@i_itemtypecode,@i_usageclasscode,@v_classexportcategory,@v_tableid,@v_datacode,@v_datasubcode,@v_data2subcode,1,getdate(),'AUTO_GENERATE')
		END

		FETCH NEXT FROM gentablesitemtype_cursor INTO @v_tableid, @v_datacode, @v_datasubcode, @v_data2subcode
 END /* @@FETCH_STATUS=0 - gentablesitemtype_cursor cursor */
    
 CLOSE gentablesitemtype_cursor 
 DEALLOCATE gentablesitemtype_cursor

 DECLARE miscitemsection_cursor CURSOR FOR
	SELECT misckey, configobjectkey
     FROM miscitemsection
    WHERE itemtypecode = @i_itemtypecode
		AND usageclasscode = @i_usageclasscode
    ORDER BY misckey

 OPEN miscitemsection_cursor

 FETCH NEXT FROM miscitemsection_cursor INTO @v_misckey, @v_configobjectkey
  
 WHILE (@@FETCH_STATUS = 0) 
 BEGIN
     SET @v_count2 = 0

     SET @v_classexportcategory = 2 -- datacode for Misc Items tableid 612 (Class Export Category)

	  SELECT @v_count2 = count(*)
       FROM usageclassdistribution
      WHERE itemtypecode = @i_itemtypecode
        AND usageclasscode = @i_usageclasscode
        AND classexportcategory = @v_classexportcategory
        AND key1 = @v_misckey
        AND key2 = @v_configobjectkey
        
	  IF @v_count2 = 0
     BEGIN
			INSERT INTO usageclassdistribution (itemtypecode,usageclasscode,classexportcategory,key1,key2,key3,key4,autogenerateind,lastmaintdate,lastuserid)
          VALUES(@i_itemtypecode,@i_usageclasscode,@v_classexportcategory,@v_misckey,@v_configobjectkey,NULL,NULL,1,getdate(),'AUTO_GENERATE')
	  END
	  FETCH NEXT FROM miscitemsection_cursor INTO @v_misckey, @v_configobjectkey
 END /* @@FETCH_STATUS=0 - miscitemsection_cursor cursor */
    
 CLOSE miscitemsection_cursor 
 DEALLOCATE miscitemsection_cursor

 DECLARE qsiconfigdetail_cursor CURSOR FOR
	SELECT configdetailkey 
	  FROM qsiconfigdetail, qsiconfigobjects
	 WHERE qsiconfigdetail.configobjectkey = qsiconfigobjects.configobjectkey
		AND itemtypecode = @i_itemtypecode 
		AND usageclasscode = @i_usageclasscode
   ORDER BY configdetailkey

 OPEN qsiconfigdetail_cursor

 FETCH NEXT FROM qsiconfigdetail_cursor INTO @v_configdetailkey
  
 WHILE (@@FETCH_STATUS = 0) 
 BEGIN
     SET @v_count2 = 0

     SET @v_classexportcategory = 4  -- datacode for Window Config tableid 612 (Class Export Category)

	  SELECT @v_count2 = count(*)
       FROM usageclassdistribution
      WHERE itemtypecode = @i_itemtypecode
        AND usageclasscode = @i_usageclasscode
        AND classexportcategory = @v_classexportcategory
        AND key1 = @v_configdetailkey
            
	  IF @v_count2 = 0
     BEGIN
			INSERT INTO usageclassdistribution (itemtypecode,usageclasscode,classexportcategory,key1,key2,key3,key4,autogenerateind,lastmaintdate,lastuserid)
          VALUES(@i_itemtypecode,@i_usageclasscode,@v_classexportcategory,@v_configdetailkey,NULL,NULL,NULL,1,getdate(),'AUTO_GENERATE')
	  END
	  FETCH NEXT FROM qsiconfigdetail_cursor INTO @v_configdetailkey
 END /* @@FETCH_STATUS=0 - qsiconfigdetail_cursor cursor */
    
 CLOSE qsiconfigdetail_cursor 
 DEALLOCATE qsiconfigdetail_cursor

 DECLARE taskview_cursor CURSOR FOR
	SELECT taskviewkey
    FROM taskview
   WHERE itemtypecode = @i_itemtypecode 
	  AND usageclasscode = @i_usageclasscode
   ORDER BY taskviewkey

 OPEN taskview_cursor

 FETCH NEXT FROM taskview_cursor INTO @v_taskviewkey
  
 WHILE (@@FETCH_STATUS = 0) 
 BEGIN
     SET @v_count2 = 0

     SET @v_classexportcategory = 3  -- datacode for Tasks tableid 612 (Class Export Category)

	  SELECT @v_count2 = count(*)
       FROM usageclassdistribution
      WHERE itemtypecode = @i_itemtypecode
        AND usageclasscode = @i_usageclasscode
        AND classexportcategory = @v_classexportcategory
        AND key1 = @v_taskviewkey
             
	  IF @v_count2 = 0
     BEGIN
			INSERT INTO usageclassdistribution (itemtypecode,usageclasscode,classexportcategory,key1,key2,key3,key4,autogenerateind,lastmaintdate,lastuserid)
          VALUES(@i_itemtypecode,@i_usageclasscode,@v_classexportcategory,@v_taskviewkey,NULL,NULL,NULL,1,getdate(),'AUTO_GENERATE')
	  END
	  FETCH NEXT FROM taskview_cursor INTO @v_taskviewkey
 END /* @@FETCH_STATUS=0 - taskview_cursor cursor */
    
 CLOSE taskview_cursor 
 DEALLOCATE taskview_cursor

 DECLARE taqrelationshiptabconfig_cursor CURSOR FOR
	SELECT taqrelationshiptabconfigkey
     FROM taqrelationshiptabconfig
    WHERE itemtypecode = @i_itemtypecode 
	   AND usageclass = @i_usageclasscode
    ORDER BY taqrelationshiptabconfigkey

 OPEN taqrelationshiptabconfig_cursor

 FETCH NEXT FROM taqrelationshiptabconfig_cursor INTO @v_taqrelationshiptabconfigkey
  
 WHILE (@@FETCH_STATUS = 0) 
 BEGIN
     SET @v_count2 = 0

     SET @v_classexportcategory = 5  -- datacode for Tab Config tableid 612 (Class Export Category)

	  SELECT @v_count2 = count(*)
       FROM usageclassdistribution
      WHERE itemtypecode = @i_itemtypecode
        AND usageclasscode = @i_usageclasscode
        AND classexportcategory = @v_classexportcategory
        AND key1 = @v_taqrelationshiptabconfigkey
             
	  
	  IF @v_count2 = 0
     BEGIN
			INSERT INTO usageclassdistribution (itemtypecode,usageclasscode,classexportcategory,key1,key2,key3,key4,autogenerateind,lastmaintdate,lastuserid)
          VALUES(@i_itemtypecode,@i_usageclasscode,@v_classexportcategory,@v_taqrelationshiptabconfigkey,NULL,NULL,NULL,1,getdate(),'AUTO_GENERATE')
	  END
	  FETCH NEXT FROM taqrelationshiptabconfig_cursor INTO @v_taqrelationshiptabconfigkey
 END /* @@FETCH_STATUS=0 - taqrelationshiptabconfig_cursor cursor */
    
 CLOSE taqrelationshiptabconfig_cursor 
 DEALLOCATE taqrelationshiptabconfig_cursor

GO
GRANT EXEC ON auto_generate_usage_class_dist_table TO PUBLIC
GO