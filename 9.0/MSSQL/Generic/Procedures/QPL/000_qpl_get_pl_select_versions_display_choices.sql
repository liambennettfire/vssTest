if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_get_pl_select_versions_display_choices') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_get_pl_select_versions_display_choices
GO

CREATE PROCEDURE qpl_get_pl_select_versions_display_choices (  
  @i_projectkey integer,
  @o_error_code integer output,
  @o_error_desc varchar(2000) output)
AS

/***************************************************************************************************
**  Name: qpl_get_pl_select_versions_display_choices_
**  Desc: This stored procedure returns the display choices for the Select Version Popup
**
**
**  Auth: Uday A. Khisty
**  Date: May 06 2014
*****************************************************************************************************
**    Change History
*****************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   
*****************************************************************************************************/


BEGIN

  DECLARE
    @v_error  INT,
    @v_approved_pl_status INT,
    @v_lock_stage_with_approved_version INT
    
  SET @o_error_code = 0
  SET @o_error_desc = ''   
  SET @v_approved_pl_status = 0
  SET @v_lock_stage_with_approved_version = 0
  
  SELECT @v_lock_stage_with_approved_version = COALESCE(optionvalue, 0) FROM clientoptions WHERE optionid = 103
  SELECT @v_approved_pl_status = COALESCE(clientdefaultvalue, 0) FROM clientdefaults WHERE clientdefaultid = 61
  
  SELECT taqprojectkey2 projectkey, c.projecttitle + ' - Related Project' projecttitle, 2 sortorder,
      CASE v.taqversionkey
      WHEN (SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode) THEN 1
      ELSE 0
      END isselected,       
      CASE
      WHEN @v_lock_stage_with_approved_version = 1 AND EXISTS(SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode AND s.selectedversionkey > 0 AND 
      @v_approved_pl_status IN (SELECT v1.plstatuscode FROM taqversion v1 WHERE v1.taqprojectkey = c.projectkey AND v1.plstagecode = v.plstagecode)) THEN 1
      WHEN EXISTS(SELECT * FROM gentables g1 WHERE g1.tableid = 522 AND g1.gen2ind = 1 AND g1.datacode = c.projectstatus) THEN 1
      ELSE 0
      END islocked,           
    v.*,
    g.sortorder plstagesortorder,
	(SELECT plstagecode FROM (
	SELECT DISTINCT TOP(1) ver.plstagecode, g1.sortorder FROM taqversion ver JOIN gentables g1
	ON g1.datacode = ver.plstagecode AND g1.tableid=g.tableid and (g1.qsicode is null or g1.qsicode <>1)  WHERE taqprojectkey = v.taqprojectkey 
	ORDER BY g1.sortorder DESC) AS Temp) as maxplstagecode, dbo.qpl_is_master_pl_project(taqprojectkey2) ismasterplproject    
  FROM taqprojectrelationship r, coreprojectinfo c, taqversion v, gentables g  
  WHERE r.taqprojectkey2 = c.projectkey
	  AND r.taqprojectkey1 = @i_projectkey
	  AND v.taqprojectkey = c.projectkey
	  AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
	  AND g.datacode = v.plstagecode AND g.tableid = 562	  
  UNION
  SELECT taqprojectkey1 projectkey, c.projecttitle + ' - Related Project' projecttitle, 2 sortorder,
      CASE v.taqversionkey
      WHEN (SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode) THEN 1
      ELSE 0
      END isselected, 
      CASE
      WHEN @v_lock_stage_with_approved_version = 1 AND EXISTS(SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode AND s.selectedversionkey > 0 AND 
      @v_approved_pl_status IN (SELECT v1.plstatuscode FROM taqversion v1 WHERE v1.taqprojectkey = c.projectkey AND v1.plstagecode = v.plstagecode)) THEN 1
      WHEN EXISTS(SELECT * FROM gentables g1 WHERE g1.tableid = 522 AND g1.gen2ind = 1 AND g1.datacode = c.projectstatus) THEN 1
      ELSE 0
      END islocked,      
    v.*,
    g.sortorder plstagesortorder,
	(SELECT plstagecode FROM (
	SELECT DISTINCT TOP(1) ver.plstagecode, g1.sortorder FROM taqversion ver JOIN gentables g1
	ON g1.datacode = ver.plstagecode AND g1.tableid=g.tableid and (g1.qsicode is null or g1.qsicode <>1)  WHERE taqprojectkey = v.taqprojectkey 
	ORDER BY g1.sortorder DESC) AS Temp) as maxplstagecode, dbo.qpl_is_master_pl_project(taqprojectkey1) ismasterplproject      
  FROM taqprojectrelationship r, coreprojectinfo c, taqversion v, gentables g   
  WHERE r.taqprojectkey1 = c.projectkey
	  AND r.taqprojectkey2 = @i_projectkey
	  AND v.taqprojectkey = c.projectkey	  
	  AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
	  AND g.datacode = v.plstagecode AND g.tableid = 562	  
  UNION
  SELECT taqprojectkey2 projectkey, c.projecttitle + ' - Related Project' projecttitle, 2 sortorder,
      CASE v.taqversionkey
      WHEN (SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode) THEN 1
      ELSE 0
      END isselected, 
      CASE
      WHEN @v_lock_stage_with_approved_version = 1 AND EXISTS(SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode AND s.selectedversionkey > 0 AND 
      @v_approved_pl_status IN (SELECT v1.plstatuscode FROM taqversion v1 WHERE v1.taqprojectkey = c.projectkey AND v1.plstagecode = v.plstagecode)) THEN 1
      WHEN EXISTS(SELECT * FROM gentables g1 WHERE g1.tableid = 522 AND g1.gen2ind = 1 AND g1.datacode = c.projectstatus) THEN 1
      ELSE 0
      END islocked,      
    v.*,
    g.sortorder plstagesortorder,
	(SELECT plstagecode FROM (
	SELECT DISTINCT TOP(1) ver.plstagecode, g1.sortorder FROM taqversion ver JOIN gentables g1
	ON g1.datacode = ver.plstagecode AND g1.tableid=g.tableid and (g1.qsicode is null or g1.qsicode <>1)  WHERE taqprojectkey = v.taqprojectkey 
	ORDER BY g1.sortorder DESC) AS Temp) as maxplstagecode, dbo.qpl_is_master_pl_project(taqprojectkey2) ismasterplproject      
  FROM taqprojectrelationship r, coreprojectinfo c, taqversion v, gentables g   
  WHERE r.taqprojectkey2 = c.projectkey
	  AND r.taqprojectkey1 = @i_projectkey
	  AND v.taqprojectkey = c.projectkey	  
	  AND r.relationshipcode1 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
	  AND g.datacode = v.plstagecode AND g.tableid = 562	  
  UNION
  SELECT taqprojectkey1 projectkey, c.projecttitle + ' - Related Project' projecttitle, 2 sortorder,
      CASE v.taqversionkey
      WHEN (SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode) THEN 1
      ELSE 0
      END isselected, 
      CASE
      WHEN @v_lock_stage_with_approved_version = 1 AND EXISTS(SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode AND s.selectedversionkey > 0 AND 
      @v_approved_pl_status IN (SELECT v1.plstatuscode FROM taqversion v1 WHERE v1.taqprojectkey = c.projectkey AND v1.plstagecode = v.plstagecode)) THEN 1
      WHEN EXISTS(SELECT * FROM gentables g1 WHERE g1.tableid = 522 AND g1.gen2ind = 1 AND g1.datacode = c.projectstatus) THEN 1
      ELSE 0
      END islocked,        
    v.*,
    g.sortorder plstagesortorder,
	(SELECT plstagecode FROM (
	SELECT DISTINCT TOP(1) ver.plstagecode, g1.sortorder FROM taqversion ver JOIN gentables g1
	ON g1.datacode = ver.plstagecode AND g1.tableid=g.tableid and (g1.qsicode is null or g1.qsicode <>1)  WHERE taqprojectkey = v.taqprojectkey 
	ORDER BY g1.sortorder DESC) AS Temp) as maxplstagecode, dbo.qpl_is_master_pl_project(taqprojectkey1) ismasterplproject      
  FROM taqprojectrelationship r, coreprojectinfo c, taqversion v, gentables g   
  WHERE r.taqprojectkey1 = c.projectkey
	  AND r.taqprojectkey2 = @i_projectkey
	  AND v.taqprojectkey = c.projectkey	  
	  AND r.relationshipcode2 IN (SELECT g.datacode FROM gentables g INNER JOIN gentables_ext e ON g.tableid = e.tableid AND g.datacode = e.datacode WHERE g.tableid = 582 AND g.gen1ind = 1 AND COALESCE(e.gen3ind, 0) = 0)
	  AND g.datacode = v.plstagecode AND g.tableid = 562	  
  UNION
  SELECT c.projectkey, c.projecttitle + ' - Current Project' projecttitle, 1 sortorder,
      CASE v.taqversionkey
      WHEN (SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode) THEN 1
      ELSE 0
      END isselected, 
      CASE
      WHEN @v_lock_stage_with_approved_version = 1 AND EXISTS(SELECT s.selectedversionkey FROM taqplstage s WHERE s.taqprojectkey = v.taqprojectkey AND s.plstagecode = v.plstagecode AND s.selectedversionkey > 0 AND 
      @v_approved_pl_status IN (SELECT v1.plstatuscode FROM taqversion v1 WHERE v1.taqprojectkey = c.projectkey AND v1.plstagecode = v.plstagecode)) THEN 1
      WHEN EXISTS(SELECT * FROM gentables g1 WHERE g1.tableid = 522 AND g1.gen2ind = 1 AND g1.datacode = c.projectstatus) THEN 1
      ELSE 0
      END islocked,        
    v.*,
    g.sortorder plstagesortorder,
	(SELECT plstagecode FROM (
	SELECT DISTINCT TOP(1) ver.plstagecode, g1.sortorder FROM taqversion ver JOIN gentables g1
	ON g1.datacode = ver.plstagecode AND g1.tableid=g.tableid and (g1.qsicode is null or g1.qsicode <>1)  WHERE taqprojectkey = v.taqprojectkey 
	ORDER BY g1.sortorder DESC) AS Temp) as maxplstagecode, dbo.qpl_is_master_pl_project(projectkey) ismasterplproject      
  FROM coreprojectinfo c, taqversion v, gentables g  
  WHERE projectkey = @i_projectkey
  	  AND v.taqprojectkey = c.projectkey
	  AND g.datacode = v.plstagecode AND g.tableid = 562  	  
  ORDER BY ismasterplproject ASC
    	    
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access coreprojectinfo table to get display choices (taqprojectkey=' + CAST(@i_projectkey AS VARCHAR) + ').'
  END

END
GO

GRANT EXEC ON qpl_get_pl_select_versions_display_choices TO PUBLIC
GO