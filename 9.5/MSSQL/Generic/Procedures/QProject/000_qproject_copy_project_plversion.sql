if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qproject_copy_project_plversion') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qproject_copy_project_plversion
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qproject_copy_project_plversion
  (@i_copy_projectkey     integer,
  @i_copy2_projectkey     integer,
  @i_new_projectkey       integer,
  @i_copy_first_stage     tinyint,
  @i_first_stage_copied   tinyint,
  @i_userid               varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/***************************************************************************************
**  Name: qproject_copy_project_plversion
**  Desc: This stored procedure copies the details of the selected version
**        for either the first or current stage.
**
**  If you call this procedure from anyplace other than qproject_copy_project,
**  you must do your own transaction/commit/rollbacks on return from this procedure.
**
**  Auth: Kate W.
**  Date: 17 November 2010
****************************************************************************************/

DECLARE
  @v_copy_itemtype  INT,
  @v_copy_plstage INT,
  @v_copy_plversion INT,
  @v_copy_projectkey  INT,
  @v_copy_usageclass  INT,
  @v_count  INT,
  @v_error  INT,
  @v_first_projectkey INT,
  @v_first_plstage  INT,
  @v_first_plversion INT,
  @v_new_plstage  INT,
  @v_new_plversion  INT,
  @v_new_proj_itemtype  INT,
  @v_new_proj_usageclass  INT,
  @v_new_proj_usageclassdesc  VARCHAR(255),
  @v_plsubtype  INT,
  @v_pltype INT,
  @v_relstrategy  INT,
  @v_stagedesc  VARCHAR(40),
  @v_userkey  INT,
  @v_versiondesc  VARCHAR(40)

BEGIN

  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @v_copy_projectkey = @i_copy_projectkey --default copy to first passed projectkey

  IF @i_copy_projectkey IS NULL OR @i_copy_projectkey = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Copy projectkey not passed to copy P&L Version.'
    RETURN
  END

  IF @i_new_projectkey IS NULL OR @i_new_projectkey = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'New projectkey not passed to copy P&L Version: copy_projectkey=' + CAST(@i_copy_projectkey AS VARCHAR)   
    RETURN
  END
  
  -- Get the userkey for the passed User ID
  SELECT @v_userkey = userkey
  FROM qsiusers
  WHERE userid = @i_userid
  
  SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
  IF @v_error <> 0 OR @v_count = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get userkey from qsiusers table for UserID: ' + CONVERT(VARCHAR, @i_userid)
    RETURN
  END

  -- Get the item type and usage class of the source project
  SELECT @v_copy_itemtype = searchitemcode, @v_copy_usageclass = COALESCE(usageclasscode,0)
  FROM coreprojectinfo 
  WHERE projectkey = @i_copy_projectkey

  -- Make sure first P&L Stage can be identified for the source project
  SELECT @v_first_plstage = g.datacode, @v_stagedesc = g.datadesc
  FROM gentablesitemtype gi, gentables g
  WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus='N'
    AND gi.tableid = 562 AND gi.itemtypecode = @v_copy_itemtype
    AND (gi.itemtypesubcode = @v_copy_usageclass OR gi.itemtypesubcode = 0)
    AND COALESCE(gi.sortorder, g.sortorder) = 1
  
  IF @v_first_plstage IS NULL
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Missing sortorder=1 P&L Stage on gentablesitemtype 562: copy_projectkey=' + CAST(@i_copy_projectkey AS VARCHAR)
    RETURN
  END
  
  SET @v_first_projectkey = @i_copy_projectkey
  
  -- Get the selected version in the first stage
  SELECT @v_first_plversion = s.selectedversionkey
  FROM taqplstage s
  WHERE s.taqprojectkey = @i_copy_projectkey AND s.plstagecode = @v_first_plstage
	  	
  SELECT @v_error = @@ERROR
  IF @v_error <> 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get selectedversionkey for first stage (taqprojectkey=' + CONVERT(VARCHAR, @i_copy_projectkey) + ')'
    RETURN
  END
  
  IF @v_first_plversion = 0 OR @v_first_plversion IS NULL
  BEGIN
    /* 5/5/12 - KW - From case 17842:
    P&L First Stage Version (16): copy from i_copy_projectkey; if none exist for i_copy_projectkey then copy from i_copy2_projectkey */    
    IF @i_copy2_projectkey > 0
    BEGIN
      SET @v_copy_projectkey = @i_copy2_projectkey
      SET @v_first_projectkey = @i_copy2_projectkey

      -- Get the item type and usage class of the second source project
      SELECT @v_copy_itemtype = searchitemcode, @v_copy_usageclass = COALESCE(usageclasscode,0)
      FROM coreprojectinfo 
      WHERE projectkey = @i_copy2_projectkey
      
      -- Make sure first P&L Stage can be identified for the second source project
      SELECT @v_first_plstage = g.datacode, @v_stagedesc = g.datadesc
      FROM gentablesitemtype gi, gentables g
      WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus='N'
        AND gi.tableid = 562 AND gi.itemtypecode = @v_copy_itemtype
        AND (gi.itemtypesubcode = @v_copy_usageclass OR gi.itemtypesubcode = 0)
        AND COALESCE(gi.sortorder, g.sortorder) = 1
  
      IF @v_first_plstage IS NULL
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Missing sortorder=1 P&L Stage on gentablesitemtype 562: copy2_projectkey=' + CAST(@i_copy2_projectkey AS VARCHAR)
        RETURN
      END
      
      -- Get the selected version in the first stage for the second source project
      SELECT @v_first_plversion = s.selectedversionkey
      FROM taqplstage s
      WHERE s.taqprojectkey = @i_copy2_projectkey AND s.plstagecode = @v_first_plstage

      SELECT @v_error = @@ERROR
      IF @v_error <> 0
      BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Could not get selectedversionkey for first stage (taqprojectkey=' + CONVERT(VARCHAR, @i_copy2_projectkey) + ')'
        RETURN
      END
    END
  END

  IF @i_copy_first_stage = 1  --copying selected version for the first stage
  BEGIN
    IF @v_first_plversion = 0 OR @v_first_plversion IS NULL
    BEGIN
      SET @o_error_code = 100
      SET @o_error_desc = 'Could not copy P&L First Stage Version - there was no version selected for the first P&L stage (' + @v_stagedesc + ').'
      RETURN
    END
  
    SET @v_copy_plstage = @v_first_plstage
    SET @v_copy_plversion = @v_first_plversion
  END
  
  ELSE  --copying selected version for the current stage
  BEGIN
    -- Check if there are any stages for @i_copy_projectkey that have a selected version
    SELECT @v_count = COUNT(*)
    FROM taqplstage
    WHERE taqprojectkey = @i_copy_projectkey AND selectedversionkey > 0

    IF @v_count = 0 AND @i_copy2_projectkey > 0
    BEGIN
      /* 5/5/12 - KW - From case 17842:
      P&L Current Stage Version (17): copy from i_copy_projectkey; if none exist for i_copy_projectkey then copy from i_copy2_projectkey */    
      SET @v_copy_projectkey = @i_copy2_projectkey
      
      -- Check if there are any stages for @i_copy2_projectkey that have a selected version
      SELECT @v_count = COUNT(*)
      FROM taqplstage
      WHERE taqprojectkey = @i_copy2_projectkey AND selectedversionkey > 0
    END         
    
    IF @v_count = 0
    BEGIN
      SELECT TOP 1 @v_stagedesc = g.datadesc
      FROM taqplstage s, gentables g
      WHERE s.plstagecode = g.datacode AND 
        g.tableid = 562 AND
        s.taqprojectkey = @v_copy_projectkey
      ORDER BY sortorder DESC --sort descending to show message for the last (current) stage
        
      SET @o_error_code = 100
      SET @o_error_desc = 'Could not copy P&L Current Stage Version - there was no version selected for the current P&L Stage (' + @v_stagedesc + ').'
      RETURN
    END

    -- Copy selected version details for the last stage that has a selected version on this project
    SELECT TOP 1 @v_copy_plstage = s.plstagecode, @v_copy_plversion = s.selectedversionkey, @v_stagedesc = g.datadesc
    FROM taqplstage s, taqproject p, gentables g, gentablesitemtype gi
    WHERE s.taqprojectkey = p.taqprojectkey AND
      s.plstagecode = g.datacode AND       
      gi.tableid = g.tableid AND gi.datacode = g.datacode AND
      gi.itemtypecode = p.searchitemcode AND (gi.itemtypesubcode = p.usageclasscode OR gi.itemtypesubcode = 0) AND
      g.tableid = 562 AND
      s.taqprojectkey = @v_copy_projectkey AND
      s.selectedversionkey > 0
    ORDER BY gi.sortorder DESC, g.sortorder DESC
    
    -- When copying current stage version, and the current stage version is the same as first stage version copied earlier,
    -- do not copy again - done
    IF @i_first_stage_copied = 1 AND @v_copy_projectkey = @v_first_projectkey AND @v_copy_plstage = @v_first_plstage AND @v_copy_plversion = @v_first_plversion
    BEGIN
      RETURN
    END
  END

  -- Get the Item Type and Usage Class for the NEW project
  SELECT @v_new_proj_itemtype = searchitemcode, @v_new_proj_usageclass = COALESCE(usageclasscode,0), 
    @v_new_proj_usageclassdesc = COALESCE(usageclasscodedesc, '')
  FROM coreprojectinfo 
  WHERE projectkey = @i_new_projectkey

  -- Get the plstagecode for the first P&L Stage for the NEW project - use item type filter
  SELECT TOP(1) @v_new_plstage = g.datacode FROM gentablesitemtype gi, gentables g
  WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus='N'
    AND gi.tableid = 562 AND gi.itemtypecode = @v_new_proj_itemtype
    AND (gi.itemtypesubcode = @v_new_proj_usageclass OR gi.itemtypesubcode = 0)
  ORDER BY gi.sortorder ASC, g.sortorder ASC
  
  -- Get the next versionkey to use for the new projectkey and the first P&L Stage
  SELECT @v_count = COUNT(*)
  FROM taqversion
  WHERE taqprojectkey = @i_new_projectkey AND plstagecode = @v_new_plstage
  
  IF @v_count = 0
    SET @v_new_plversion = 1
  ELSE
    SELECT @v_new_plversion = MAX(taqversionkey) + 1
    FROM taqversion
    WHERE taqprojectkey = @i_new_projectkey AND plstagecode = @v_new_plstage
    
  -- Get the P&L Type, Sub-Type and Release Strategy on the original version
  SELECT @v_pltype = pltypecode, @v_plsubtype = pltypesubcode, @v_relstrategy = releasestrategycode, @v_versiondesc = taqversiondesc
  FROM taqversion
  WHERE taqprojectkey = @v_copy_projectkey AND
    plstagecode = @v_copy_plstage AND
    taqversionkey = @v_copy_plversion
  
  SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
  IF @v_error <> 0 OR @v_count = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not get copy version details: copy_projectkey=' + CAST(@v_copy_projectkey AS VARCHAR) + 
      ', copy_plstage=' + CAST(@v_copy_plstage AS VARCHAR) + ', copy_plversion=' + CAST(@v_copy_plversion AS VARCHAR)
    RETURN
  END

  -- Check if the P&L Type and Release Strategy are valid values for the NEW project
  -- If they are not, use a default value determined by item type and sortorder (see spec on case 27688 - section 13)
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 566 AND datacode = @v_pltype 
    AND itemtypecode = @v_new_proj_itemtype AND (itemtypesubcode = @v_new_proj_usageclass OR itemtypesubcode = 0)

  IF @v_count = 0
  BEGIN
    SELECT @v_pltype = gi.datacode
    FROM gentablesitemtype gi, gentables g
    WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus='N'
      AND gi.tableid = 566 AND gi.itemtypecode = @v_new_proj_itemtype
      AND (gi.itemtypesubcode = @v_new_proj_usageclass OR gi.itemtypesubcode = 0)
    ORDER BY gi.sortorder ASC, g.sortorder ASC

    SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
    IF @v_error <> 0 OR @v_count = 0
    BEGIN
      SET @o_error_code = 100
      SET @o_error_desc = 'Could not copy version - missing default P&L Type value for ' + @v_new_proj_usageclassdesc + '.'
      RETURN
    END
  
    SELECT TOP (1) @v_plsubtype = datasubcode
    FROM subgentables
    WHERE tableid = 566 AND datacode = @v_pltype
    ORDER BY sortorder ASC, datasubcode ASC

    IF @v_plsubtype IS NULL
      SET @v_plsubtype = 0
  END

  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 567 AND datacode = @v_relstrategy 
    AND itemtypecode = @v_new_proj_itemtype AND (itemtypesubcode = @v_new_proj_usageclass OR itemtypesubcode = 0)

  IF @v_count = 0
  BEGIN
    SELECT @v_relstrategy = gi.datacode
    FROM gentablesitemtype gi, gentables g
    WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus='N'
      AND gi.tableid = 567 AND gi.itemtypecode = @v_new_proj_itemtype
      AND (gi.itemtypesubcode = @v_new_proj_usageclass OR gi.itemtypesubcode = 0)
    ORDER BY gi.sortorder ASC, g.sortorder ASC

    SELECT @v_error = @@ERROR, @v_count = @@ROWCOUNT
    IF @v_error <> 0 OR @v_count = 0
    BEGIN
      SET @o_error_code = 100
      SET @o_error_desc = 'Could not copy version - missing default Release Strategy value for ' + @v_new_proj_usageclassdesc + '.'
      RETURN
    END
  END

  /***** Create the new P&L version for the new project ****/
  EXEC qpl_create_new_version @v_copy_projectkey, @v_copy_plstage, @v_copy_plversion, @i_new_projectkey, @v_new_plstage, @v_new_plversion,
    @v_pltype, @v_plsubtype, @v_relstrategy, @v_userkey, @v_versiondesc, 0, @o_error_code, @o_error_desc

  IF @o_error_code <> 0 BEGIN
    SET @o_error_desc = 'Copy P&L Version failed (' + cast(@o_error_code AS VARCHAR) + '): taqprojectkey = ' + cast(@i_copy_projectkey AS VARCHAR)   
    RETURN
  END 
	  
END
go
