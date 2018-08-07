if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_recalc_pl_items_consolidated_for_projects') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_recalc_pl_items_consolidated_for_projects
GO

CREATE PROCEDURE qpl_recalc_pl_items_consolidated_for_projects (  
  @i_projectkey     integer,
  @i_userid         varchar(30),
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*************************************************************************************************************************
**  Name: qpl_recalc_pl_items_consolidated_for_projects
**  Desc: This stored procedure recalculates all p&l consolidated summary items for All non-locked levels of the Projects.
**
**  Auth: Uday A. Khisty
**  Date: March 13 2015
*************************************************************************************************************************/

DECLARE
  @v_calc_stage_items TINYINT,
  @v_calcvalue  DECIMAL(18,4),
  @v_count  INT,
  @v_display_currency	INT,
  @v_errorcode  INT,
  @v_errordesc  VARCHAR(2000),
  @v_itemkey  INT,  
  @v_itemlevel  INT,  
  @v_usageclass INT,
  @v_userkey  INT,
  @v_yearcode INT,
  @v_related_projectkey INT,
  @v_is_stage_locked INT,
  @v_PL_Final_Approved_Status INT ,
  @v_plstagecode  INT,
  @v_selectedversionkey INT,
  @v_previous_plstagecode INT,
  @v_Is_Master_Project INT,
  @v_projectkey_master INT,
  @v_approved_project_status INT,
  @v_project_status INT,
  @v_project_version_status INT
  

BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_previous_plstagecode = NULL
  
  SELECT @v_display_currency = COALESCE(plenteredcurrency,0)
  FROM taqproject
  WHERE taqprojectkey = @i_projectkey

  IF @v_display_currency = 0
	SELECT @v_display_currency = datacode 
	FROM gentables 
	WHERE tableid = 122 AND qsicode = 2	--US Dollars  
  
  SELECT @v_Is_Master_Project = dbo.qpl_is_master_pl_project(@i_projectkey)
  SET @v_projectkey_master = @i_projectkey
  
  IF @v_Is_Master_Project < 0 AND EXISTS (SELECT * from taqplsummaryitems WHERE taqprojectkey = @i_projectkey AND plsummaryitemkey IN (
																												SELECT plsummaryitemkey
																												FROM plsummaryitemdefinition
																												WHERE summarylevelcode = 5)) BEGIN
	  --  if you delete the only master P&L relationship from this project, remove the taqplsummaryitems for the consolidated summary level 																			  
      DELETE from taqplsummaryitems
      WHERE taqprojectkey = @i_projectkey
      AND plsummaryitemkey IN (
            SELECT plsummaryitemkey
			  FROM plsummaryitemdefinition
			  WHERE summarylevelcode = 5)																					  
	
  END
        
  IF @v_Is_Master_Project = -1 BEGIN -- Not calculating consolidated for any Project that is NOT a Master Project. See Case 31557
    RETURN
  END    
  
  SELECT @v_is_stage_locked = COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 103
    
  IF @v_is_stage_locked = 1 BEGIN
     SELECT @v_PL_Final_Approved_Status = COALESCE(CAST(clientdefaultvalue AS INT), 0) FROM clientdefaults where clientdefaultid = 61 
  END
  
  SELECT @v_approved_project_status = datacode
  FROM gentables 
  WHERE tableid = 522 AND qsicode = 1  
  
  IF @v_Is_Master_Project = 1 BEGIN        
	  -- This function will return the active projectkey to use for processing related projects
	  -- Ex: For approved acquisition projects, the returned active projectkey will be its related work projectkey.
	  -- For non-approved acquisitions, the returned active projectkey is self  
	  --SELECT @v_projectkey_master = out_projectkey 
	  --FROM dbo.rpt_get_active_taq_work() 
	  --WHERE in_projectkey = @v_projectkey_master     
	     
	  SET @v_previous_plstagecode = NULL
	  DECLARE taqplstage_cur CURSOR FOR
		SELECT plstagecode, selectedversionkey
		FROM taqplstage
		WHERE taqprojectkey = @v_projectkey_master
		ORDER BY plstagecode ASC
	      
	  OPEN taqplstage_cur 

	  FETCH taqplstage_cur INTO @v_plstagecode, @v_selectedversionkey

	  WHILE (@@FETCH_STATUS=0)
	  BEGIN
	   IF @v_previous_plstagecode = @v_plstagecode BEGIN
		  FETCH taqplstage_cur INTO @v_plstagecode, @v_selectedversionkey
		  CONTINUE
	   END
		   IF @v_is_stage_locked = 1
		   AND EXISTS (SELECT * FROM taqversion WHERE taqprojectkey = @v_projectkey_master AND plstagecode = @v_plstagecode AND taqversionkey = @v_selectedversionkey) BEGIN
	      SELECT @v_project_version_status = plstatuscode FROM taqversion WHERE taqprojectkey = @v_projectkey_master AND plstagecode = @v_plstagecode AND taqversionkey = @v_selectedversionkey
		  IF @v_PL_Final_Approved_Status > 0 AND @v_project_version_status = @v_PL_Final_Approved_Status BEGIN
		     SET @v_previous_plstagecode = @v_plstagecode
			 FETCH taqplstage_cur INTO @v_plstagecode, @v_selectedversionkey
			 CONTINUE
		  END
	   END

	   EXEC qpl_recalc_pl_items @v_projectkey_master, @v_plstagecode, 0, @i_userid, @o_error_code, @o_error_desc

	   IF @o_error_code <> 0
	   BEGIN
		  SET @o_error_desc = 'Could not recalculate P&L stage-level summary items (projectkey=' + CONVERT(VARCHAR, @v_projectkey_master)
		  GOTO ERROR
			
	   END	
		  SET @v_previous_plstagecode = @v_plstagecode
		  FETCH taqplstage_cur INTO @v_plstagecode, @v_selectedversionkey
	   END

	  CLOSE taqplstage_cur
	  DEALLOCATE taqplstage_cur	
  END
  
  IF @v_Is_Master_Project = 0 BEGIN 
      DECLARE relatedprojects_consolidated_cur CURSOR FOR        										
          SELECT taqprojectkey2 projectkey, projectstatus
        FROM taqprojectrelationship r, coreprojectinfo c 
        WHERE r.taqprojectkey2 = c.projectkey
	        AND r.taqprojectkey1 = @i_projectkey
            AND relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)          
	        AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
        UNION
        SELECT taqprojectkey1 projectkey, projectstatus
        FROM taqprojectrelationship r, coreprojectinfo c 
        WHERE r.taqprojectkey1 = c.projectkey
	        AND r.taqprojectkey2 = @i_projectkey
	        AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND e.gen3ind = 1)
	        AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)								         	        	          
        OPEN relatedprojects_consolidated_cur 

        FETCH relatedprojects_consolidated_cur INTO @v_related_projectkey, @v_project_status

        WHILE (@@FETCH_STATUS=0)
        BEGIN
		  SELECT @v_related_projectkey = out_projectkey 
		  FROM dbo.rpt_get_active_taq_work() 
		  WHERE in_projectkey = @v_related_projectkey        
		  
		  IF @v_project_status = @v_approved_project_status BEGIN
			FETCH relatedprojects_consolidated_cur INTO @v_related_projectkey, @v_project_status	
			CONTINUE		
		  END
		                  
	      SET @v_previous_plstagecode = NULL		                  
		  DECLARE taqplstage_cur CURSOR FOR
			SELECT plstagecode, selectedversionkey
			FROM taqplstage
			WHERE taqprojectkey = @v_related_projectkey
			ORDER BY plstagecode ASC
		      
		  OPEN taqplstage_cur 

		  FETCH taqplstage_cur INTO @v_plstagecode, @v_selectedversionkey

		  WHILE (@@FETCH_STATUS=0)
		  BEGIN
		   IF @v_previous_plstagecode = @v_plstagecode BEGIN
			  FETCH taqplstage_cur INTO @v_plstagecode, @v_selectedversionkey
		   END
		   
		   IF @v_is_stage_locked = 1
		   AND EXISTS (SELECT * FROM taqversion WHERE taqprojectkey = @v_related_projectkey AND plstagecode = @v_plstagecode AND taqversionkey = @v_selectedversionkey) BEGIN
		      SELECT @v_project_version_status = plstatuscode FROM taqversion WHERE taqprojectkey = @v_related_projectkey AND plstagecode = @v_plstagecode AND taqversionkey = @v_selectedversionkey
			  IF @v_PL_Final_Approved_Status > 0 AND @v_project_version_status = @v_PL_Final_Approved_Status BEGIN
			     SET @v_previous_plstagecode = @v_plstagecode
				 FETCH taqplstage_cur INTO @v_plstagecode, @v_selectedversionkey
				 CONTINUE
			  END
		   END

		   EXEC qpl_recalc_pl_items @v_related_projectkey, @v_plstagecode, 0, @i_userid, @o_error_code, @o_error_desc

		   IF @o_error_code <> 0
		   BEGIN
			  SET @o_error_desc = 'Could not recalculate P&L stage-level summary items (projectkey=' + CONVERT(VARCHAR, @v_related_projectkey)
			  GOTO ERROR
				
		   END	
			  SET @v_previous_plstagecode = @v_plstagecode
			  FETCH taqplstage_cur INTO @v_plstagecode, @v_selectedversionkey
		   END

		  CLOSE taqplstage_cur
		  DEALLOCATE taqplstage_cur	
		  
          FETCH relatedprojects_consolidated_cur INTO @v_related_projectkey, @v_project_status
     END
    
     CLOSE relatedprojects_consolidated_cur
     DEALLOCATE relatedprojects_consolidated_cur    		  
  END  
  
  RETURN

  ERROR:
  SET @o_error_code = -1
  SET @o_error_desc = 'Recalc of P&L summary items failed: taqprojectkey = ' + CAST(@v_projectkey_master AS VARCHAR)
  IF @v_errordesc <> ''
    SET @o_error_desc = @o_error_desc + ' (' + @v_errordesc + ')'
  RETURN
   
END
GO

GRANT EXEC ON qpl_recalc_pl_items_consolidated_for_projects TO PUBLIC
GO
