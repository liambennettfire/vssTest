SET NOCOUNT ON

DECLARE @v_count		INT
DECLARE @v_count2		INT
DECLARE @NumberRecords	INT
DECLARE @RowCount		INT
DECLARE @o_error_code	INT
DECLARE @o_configobjectkey INT
DECLARE @v_datacode		INT
DECLARE @v_datacode2	INT
DECLARE @v_itemtypecode INT
DECLARE @v_itemtypesubcode INT
DECLARE @v_sortorder    INT
DECLARE @v_qsicode      INT
DECLARE @o_error_desc   VARCHAR(255)
DECLARE @v_tabgroupsectionlabel VARCHAR(100)
DECLARE @v_itemtypedesc		varchar(120)
DECLARE @v_configobjectid		varchar (100)
DECLARE @v_config_count int
DECLARE @v_defaultposition int

BEGIN
  -- this script is written to add any tabgroups that were not created during the initial conversion 97_013_webrelationshiptabs_section_config_38527_conversion.sql

	SELECT @v_datacode = COALESCE(datacode,0) FROM gentables WHERE tableid = 680 AND qsicode = 1 --Main Relationship Group
	
	IF @v_datacode > 0 BEGIN
	
		SELECT @v_tabgroupsectionlabel = COALESCE(gentext1,'') FROM gentables_ext WHERE tableid = 680 AND datacode = @v_datacode
		
		IF @v_tabgroupsectionlabel = '' BEGIN
			SELECT @v_tabgroupsectionlabel = COALESCE(datadesc,'') FROM gentables WHERE tableid = 680 AND datacode = @v_datacode
		END
			
--print '@v_tabgroupsectionlabel: ' + @v_tabgroupsectionlabel

		CREATE TABLE #webrelationshipitemtyperows (
			RowID int IDENTITY (1,1),
			datacode		INT,
			itemtypecode	INT,
			itemtypesubcode	INT,
			sortorder		INT)
			
		INSERT INTO #webrelationshipitemtyperows (datacode,itemtypecode,itemtypesubcode,sortorder)
			SELECT DISTINCT datacode,itemtypecode,itemtypesubcode,sortorder
			  FROM gentablesitemtype
			 WHERE tableid = 583 --AND relateddatacode is  null
			 ORDER by itemtypecode, itemtypesubcode
	    
	    SET @NumberRecords	= @@ROWCOUNT
	    SET @RowCount = 1
	    
	   WHILE @RowCount <= @NumberRecords BEGIN
			SELECT @v_datacode2 = datacode, @v_itemtypecode = itemtypecode,@v_itemtypesubcode = itemtypesubcode,@v_sortorder = sortorder 
			  FROM #webrelationshipitemtyperows
			 WHERE ROWID = @RowCount
  
      SET @v_itemtypedesc = ''
	    IF COALESCE(@v_itemtypecode, 0) > 0 BEGIN
	       SELECT @v_itemtypedesc = datadesc FROM gentables WHERE tableid = 550 AND datacode = @v_itemtypecode
	    END

      IF coalesce(@v_itemtypedesc, '') = '' BEGIN
        goto NEXT_ROW
      END

      SET @v_configobjectid = @v_itemtypedesc + 'Tabgroup' + convert(varchar(30),@v_datacode)	
--print '@v_configobjectid: ' + @v_configobjectid
     
      SELECT @v_config_count = count(*) 
        FROM qsiconfigobjects
       WHERE defaultlabeldesc = @v_tabgroupsectionlabel AND itemtypecode = @v_itemtypecode

      IF coalesce(@v_config_count, 0) > 0 BEGIN
        -- section already exists
        goto NEXT_ROW
      END

			IF @v_itemtypesubcode = 0 BEGIN
				DECLARE usageclass_cur CURSOR FOR
					SELECT qsicode FROM subgentables WHERE tableid = 550 AND datacode = @v_itemtypecode AND deletestatus = 'N' 
					--AND qsicode IS NOT NULL
						ORDER BY qsicode
					
				OPEN usageclass_cur
				
				FETCH NEXT FROM usageclass_cur INTO @v_qsicode
				
				WHILE (@@FETCH_STATUS = 0) BEGIN
--print '@v_qsicodeA: ' + cast(@v_qsicode as varchar)
--print '@v_itemtypecode: ' + cast(@v_itemtypecode as varchar)

					EXEC dbo.qutl_insert_section_config @v_tabgroupsectionlabel,@v_itemtypecode,@v_qsicode,0,@o_configobjectkey OUTPUT,
						@o_error_code OUTPUT,@o_error_desc OUTPUT

--print '@o_configobjectkey: ' + cast(@o_configobjectkey as varchar)

          -- attempt to set the defaultposition
          SELECT top 1 @v_defaultposition = position
          FROM qsiconfigobjects
          WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = 1

					UPDATE qsiconfigobjects
					SET defaultvisibleind = 1, position = @v_defaultposition
					WHERE configobjectkey = @o_configobjectkey
					
          --SELECT * FROM qsiconfigdetailtabs
          DELETE FROM qsiconfigdetailtabs
          WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where configobjectkey = @o_configobjectkey)
          	
					FETCH NEXT FROM usageclass_cur INTO @v_qsicode
				END
				
				CLOSE usageclass_cur
				DEALLOCATE usageclass_cur
			
			END --IF @v_itemtypesubcode = 0
			ELSE BEGIN
			  SELECT @v_qsicode = qsicode FROM subgentables WHERE tableid = 550 AND datacode = @v_itemtypecode AND datasubcode = @v_itemtypesubcode
			    
--print '@v_qsicodeB: ' + cast(@v_qsicode as varchar)
--print '@v_itemtypecode: ' + cast(@v_itemtypecode as varchar)

				EXEC dbo.qutl_insert_section_config @v_tabgroupsectionlabel,@v_itemtypecode,@v_qsicode,0,@o_configobjectkey OUTPUT,
				   @o_error_code OUTPUT,@o_error_desc OUTPUT

--print '@o_configobjectkey: ' + cast(@o_configobjectkey as varchar)

          -- attempt to set the defaultposition
          SELECT top 1 @v_defaultposition = position
          FROM qsiconfigobjects
          WHERE configobjectid = 'ProjectRelationshipsTab' AND itemtypecode = 1

					UPDATE qsiconfigobjects
					SET defaultvisibleind = 1, position = @v_defaultposition
					WHERE configobjectkey = @o_configobjectkey

        --SELECT * FROM qsiconfigdetailtabs
        DELETE FROM qsiconfigdetailtabs
        WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where configobjectkey = @o_configobjectkey)
			
			END --IF @v_itemtypesubcode > 0
			     
      NEXT_ROW:
			SET @RowCount = @RowCount + 1
		END --WHILE @RowCount <= @NumberRecords
		
		UPDATE gentablesitemtype 
		   SET relateddatacode = @v_datacode,
			   lastuserid = 'CONVERSION',
			   lastmaintdate = GETDATE() 
		 WHERE tableid = 583 AND (relateddatacode is NULL OR relateddatacode = 0)
	END --IF @v_datacode > 0
	
	DROP TABLE #webrelationshipitemtyperows

END
go

-- remove old project relationship section from product summary
DECLARE @v_windowid int
 
select @v_windowid = windowid from qsiwindows where windowname = 'productsummary'

DELETE from qsiconfigdetail
WHERE configobjectkey in (SELECT configobjectkey FROM qsiconfigobjects
                           WHERE defaultlabeldesc = 'Project Relationships'
                             and windowid = @v_windowid)

DELETE FROM qsiconfigobjects
 WHERE defaultlabeldesc = 'Project Relationships'
   and windowid = @v_windowid
go