IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.taqversion_maintainrelatedversions') AND type = 'TR')
	DROP TRIGGER dbo.taqversion_maintainrelatedversions
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


CREATE TRIGGER taqversion_maintainrelatedversions ON taqversion
FOR INSERT, UPDATE AS
IF UPDATE (plstatuscode)

BEGIN
	DECLARE @v_taqprojectkey 	INT,
		@v_plstagecode          INT,
		@v_taqversionkey        INT,
		@v_Is_Master_Project INT,
		@v_PL_Final_Approved_Status INT,
		@v_related_projectkey INT,
		@v_optionvalue INT,
		@v_next_stage INT,
		@v_error_var    INT,
        @v_error_desc VARCHAR(2000),
	    @v_rowcount_var INT,
	    @v_next_taqversionkey INT,
	    @v_plsubtype  INT,
		@v_pltype INT,
		@v_relstrategy  INT,
		@v_stagedesc  VARCHAR(40),
		@v_lastuserid VARCHAR(30),
		@v_userkey  INT,
		@v_versiondesc  VARCHAR(40),
		@v_itemtype INT,
		@v_usageclass INT,
		@v_itemtype_AcquisitionProject INT,
		@v_usageclass_AcquisitionProject INT,	
		@v_itemtype_Work INT,	
		@v_CopySelectData INT,
		@v_IsCopySelectDatafromPLtoAcqProject INT,
		@v_IsCopySelectDatafromPLtoTitles INT,
		@v_IsLockStageWithApprovedVersion INT,
		@v_allow_approve_master_pl_version INT,		
		@o_error_code    INT,
        @o_error_desc    INT

	DECLARE taqversion_cur CURSOR FOR
	SELECT i.taqprojectkey,
	       i.plstagecode,
	       i.taqversionkey,
	       i.lastuserid
	FROM inserted i

	OPEN taqversion_cur

	FETCH NEXT FROM taqversion_cur 
	INTO @v_taqprojectkey,
		 @v_plstagecode,
		 @v_taqversionkey,
		 @v_lastuserid

	WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
	  BEGIN
	    SET @v_Is_Master_Project = 0
	    SET @v_error_var = 0
		SET @v_error_desc = ''
		SET @o_error_code = 0
        SET @o_error_desc = ''
		SET @v_next_taqversionkey = 1
		SET @v_pltype = 0
		SET @v_plsubtype = 0
		SET @v_relstrategy = 0
		SET @v_CopySelectData = 1
		SET @v_allow_approve_master_pl_version = 0
		
		SELECT @v_IsLockStageWithApprovedVersion = COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 103
		IF @v_IsLockStageWithApprovedVersion = 0 
			GOTO Exit_Cursor
		
	    SELECT @v_Is_Master_Project = dbo.qpl_is_master_pl_project(@v_taqprojectkey)
	    SELECT @v_allow_approve_master_pl_version = dbo.qpl_allow_approve_master_pl_version(@v_taqprojectkey, @v_plstagecode)	    
	    SELECT @v_PL_Final_Approved_Status = COALESCE(CAST(clientdefaultvalue AS INT), 0) FROM clientdefaults where clientdefaultid = 61   
	    
	    SELECT @v_itemtype_AcquisitionProject = datacode, @v_usageclass_AcquisitionProject = datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 1
		SELECT @v_itemtype_Work = datacode FROM gentables WHERE tableid = 550 AND qsicode = 9	    
	      
	    IF @v_Is_Master_Project = 1 AND @v_PL_Final_Approved_Status > 0  AND @v_allow_approve_master_pl_version = 1 BEGIN
		    -- Get the userkey for the passed User ID
		    SELECT @v_userkey = userkey
		    FROM qsiusers
		    WHERE userid = @v_lastuserid
		  
		    SELECT @v_error_var = @@ERROR, @v_rowcount_var = @@ROWCOUNT
		    IF @v_error_var <> 0 OR @v_rowcount_var = 0
		      GOTO Exit_Cursor    
		    
			SELECT @v_optionvalue = optionvalue from clientoptions where optionid=102	
			SELECT @v_IsCopySelectDatafromPLtoAcqProject = optionvalue from clientoptions where optionid=101	
			SELECT @v_IsCopySelectDatafromPLtoTitles = optionvalue from clientoptions where optionid=104	    
			
			IF EXISTS(SELECT * FROM taqversion WHERE taqprojectkey = @v_taqprojectkey AND plstagecode = @v_plstagecode AND plstatuscode = @v_PL_Final_Approved_Status)
			BEGIN
				DECLARE relatedsecondaryprojects_cur CURSOR FOR
				  SELECT DISTINCT taqprojectkey2 projectkey, t.taqversionkey, t.pltypecode, t.pltypesubcode, t.releasestrategycode, t.taqversiondesc, c.searchitemcode, c.usageclasscode
				  FROM taqprojectrelationship r, coreprojectinfo c, taqversion t 
				  WHERE r.taqprojectkey2 = c.projectkey
					  AND r.taqprojectkey1 = @v_taqprojectkey
					  AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 1)	          
					  AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
					  AND t.taqprojectkey = r.taqprojectkey2  AND t.plstagecode = @v_plstagecode AND t.taqversionkey = (SELECT selectedversionkey FROM taqplstage WHERE taqprojectkey = r.taqprojectkey2 AND plstagecode = @v_plstagecode)
					  AND t.plstatuscode <> @v_PL_Final_Approved_Status
				  UNION
				  SELECT DISTINCT taqprojectkey1 projectkey, t.taqversionkey, t.pltypecode, t.pltypesubcode, t.releasestrategycode, t.taqversiondesc, c.searchitemcode, c.usageclasscode
				  FROM taqprojectrelationship r, coreprojectinfo c, taqversion t 
				  WHERE r.taqprojectkey1 = c.projectkey
					  AND r.taqprojectkey2 = @v_taqprojectkey
					  AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
					  AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 1)
					  AND t.taqprojectkey = r.taqprojectkey1  AND t.plstagecode = @v_plstagecode AND t.taqversionkey = (SELECT selectedversionkey FROM taqplstage WHERE taqprojectkey = r.taqprojectkey1 AND plstagecode = @v_plstagecode)
			          AND t.plstatuscode <> @v_PL_Final_Approved_Status
			          
				OPEN relatedsecondaryprojects_cur 

				FETCH relatedsecondaryprojects_cur INTO @v_related_projectkey, @v_taqversionkey, @v_pltype, @v_plsubtype, @v_relstrategy, @v_versiondesc, @v_itemtype, @v_usageclass  

				WHILE (@@FETCH_STATUS=0)
				BEGIN
				  IF @v_pltype IS NULL BEGIN
				    SET @v_pltype = 0
				  END	
				  				
				  IF @v_plsubtype IS NULL BEGIN
				    SET @v_plsubtype = 0
				  END		
				  
				  IF @v_relstrategy IS NULL BEGIN
				    SET @v_relstrategy = 0
				  END					  
				  		
				  UPDATE taqversion SET plstatuscode = @v_PL_Final_Approved_Status 
				  WHERE taqprojectkey = @v_related_projectkey AND plstagecode = @v_plstagecode AND taqversionkey = @v_taqversionkey
				  
				  IF @v_optionvalue = 1 BEGIN
					SELECT @v_rowcount_var = COUNT(*) 
					FROM gentables 
					WHERE tableid=562 AND lower(datadesc) <> 'actuals' 
						AND sortorder=(SELECT min(sortorder) FROM gentables WHERE tableid=562 AND datacode > @v_plstagecode)
						 
					IF @v_rowcount_var = 0  BEGIN
						FETCH relatedsecondaryprojects_cur INTO @v_related_projectkey, @v_taqversionkey, @v_pltype, @v_plsubtype, @v_relstrategy, @v_versiondesc, @v_itemtype, @v_usageclass   
						CONTINUE
					END						 
				  -- get the next stage if it is not 'Actuals'
					SELECT TOP(1) @v_next_stage = datacode 
					FROM gentables 
					WHERE tableid=562 AND lower(datadesc) <> 'actuals' 
						AND sortorder=(SELECT min(sortorder) FROM gentables WHERE tableid=562 AND datacode > @v_plstagecode)
					
					SELECT @v_error_var = @@ERROR
					IF @v_error_var <> 0 OR @v_rowcount_var = 0  BEGIN
						FETCH relatedsecondaryprojects_cur INTO @v_related_projectkey, @v_taqversionkey, @v_pltype, @v_plsubtype, @v_relstrategy, @v_versiondesc, @v_itemtype, @v_usageclass    
						CONTINUE
					END
					
					-- get the next version number within the next stage
					IF EXISTS(SELECT * FROM taqversion WHERE taqprojectkey = @v_related_projectkey AND plstagecode = @v_next_stage) BEGIN
					   SELECT @v_rowcount_var = COUNT(*) FROM taqversion WHERE taqprojectkey = @v_related_projectkey AND plstagecode = @v_next_stage	
					   
					   IF @v_rowcount_var = 0 BEGIN
						   FETCH relatedsecondaryprojects_cur INTO @v_related_projectkey, @v_taqversionkey, @v_pltype, @v_plsubtype, @v_relstrategy, @v_versiondesc, @v_itemtype, @v_usageclass   
						   CONTINUE
					   END	
					   					   			
					   SELECT @v_next_taqversionkey = max(taqversionkey) FROM taqversion WHERE taqprojectkey = @v_related_projectkey AND plstagecode = @v_next_stage
											   					
					   SELECT @v_error_var = @@ERROR
					   IF @v_error_var <> 0 OR @v_rowcount_var = 0 BEGIN
						   FETCH relatedsecondaryprojects_cur INTO @v_related_projectkey, @v_taqversionkey, @v_pltype, @v_plsubtype, @v_relstrategy, @v_versiondesc, @v_itemtype, @v_usageclass    
						   CONTINUE
					   END			
					   
					   SET @v_next_taqversionkey = @v_next_taqversionkey + 1	-- set the next version number	  
					END
					ELSE BEGIN
					   SET @v_next_taqversionkey = 1  -- no version on next stage yet, this is the 1st
					END
					
					/***** Create the new P&L version for the new project ****/
					EXEC qpl_create_new_version @v_related_projectkey, @v_plstagecode, @v_taqversionkey, @v_related_projectkey, @v_next_stage, @v_next_taqversionkey,
						@v_pltype, @v_plsubtype, @v_relstrategy, @v_userkey, @v_versiondesc, 0, @o_error_code, @o_error_desc

					IF @o_error_code <> 0 BEGIN
					  CLOSE relatedsecondaryprojects_cur
					  DEALLOCATE relatedsecondaryprojects_cur 				
					  SET @o_error_desc = 'Copy P&L Version failed (' + cast(@o_error_code AS VARCHAR) + '): taqprojectkey = ' + cast(@v_related_projectkey AS VARCHAR)   
					  ROLLBACK TRANSACTION	
					  GOTO Exit_cursor
					END 
					
					IF @v_itemtype_AcquisitionProject = @v_itemtype AND @v_usageclass_AcquisitionProject = @v_usageclass BEGIN
						EXEC qpl_sync_version_to_acq_project @v_related_projectkey, @v_next_stage, @v_next_taqversionkey, @v_userkey, 1, @o_error_code OUTPUT, @o_error_desc OUTPUT	
						IF @o_error_code <> 0 BEGIN
						  CLOSE relatedsecondaryprojects_cur
						  DEALLOCATE relatedsecondaryprojects_cur 				
						  SET @o_error_desc = 'Sync version to Acquisition Project failed: taqprojectkey = ' + CAST(@v_related_projectkey AS VARCHAR) 
						  ROLLBACK TRANSACTION	
						  GOTO Exit_cursor
						END 											
					END		
					ELSE IF @v_itemtype_Work = @v_itemtype BEGIN
						EXEC qpl_sync_version_to_work_titles @v_related_projectkey, @v_next_stage, @v_next_taqversionkey, @v_userkey, 1, @o_error_code OUTPUT, @o_error_desc OUTPUT						
						IF @o_error_code <> 0 BEGIN
						  CLOSE relatedsecondaryprojects_cur
						  DEALLOCATE relatedsecondaryprojects_cur 				
						  SET @o_error_desc = 'Sync version to Work Titles failed: taqprojectkey = ' + CAST(@v_related_projectkey AS VARCHAR) 
						  ROLLBACK TRANSACTION	
						  GOTO Exit_cursor
						END 						
					END																								 	
				  END
				  
				  FETCH relatedsecondaryprojects_cur INTO @v_related_projectkey, @v_taqversionkey, @v_pltype, @v_plsubtype, @v_relstrategy, @v_versiondesc, @v_itemtype, @v_usageclass   
				END
		        
				CLOSE relatedsecondaryprojects_cur
				DEALLOCATE relatedsecondaryprojects_cur          		
			END			
	    END  
	    
		FETCH NEXT FROM taqversion_cur 
		INTO @v_taqprojectkey,
			 @v_plstagecode,
			 @v_taqversionkey,
			 @v_lastuserid
	  END

Exit_Cursor:
	CLOSE taqversion_cur
	DEALLOCATE taqversion_cur


END
GO
