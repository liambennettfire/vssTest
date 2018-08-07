if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_create_new_version') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_create_new_version
GO

CREATE PROCEDURE [dbo].[qpl_create_new_version]
 (@i_projectkey     integer,
  @i_plstage        integer,
  @i_plversion      integer,
  @i_new_projectkey integer,
  @i_new_plstage    integer,
  @i_new_plversion  integer,  
  @i_pltype         integer,
  @i_plsubtype      integer,
  @i_relstrategy    integer,
  @i_userkey        integer,
  @i_versiondesc    varchar(40),
  @i_copy_project_data	tinyint,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  Name: qpl_create_new_version
**  Desc: This stored procedure creates a new P&L Version by copying either an existing version, 
**        or by copying an active template information for the given project's orgentry assigment 
**        and selected (new) P&L Type/Subtype and Release Strategy.
**
**  Auth: Kate
**  Date: November 6 2007
**
*****************************************************************************************************************
**  Change History
*****************************************************************************************************************
**  Date:        Author:     Description:
*   --------     --------    ------------------------------------------------------------------------
**  02/10/2016   UK		     Case 36260
**  02/10/2016   UK		     Case 36260 - Task 002
**  02/11/2016   Colman      Case 36095
**  02/16/2016   UK          Case 35197 - Backing out change for Task 001
**  03/20/2016   Kate        Case 35197 - P&L Summary Item filter by Item Type/Usage Class
**	03/31/2016   Kate        Case 35972 - Background recalc
**  01/20/2017   Colman      Case 42178 - Royalty advances by contributor
**  01/20/2017   Colman      Case 42178 - Royalty advances by contributor
**  10/13/2017   Colman      Case 47248 - Only copy currency values to target project if they are NULL
**  07/24/2018   Colman      TM-584     - Support for "shared cost" formats
*****************************************************************************************************************/

DECLARE
  @v_activeprice  FLOAT,
  @v_activestatus INT,
  @v_approval_currency	INT,
  @v_authorpercent  INT,
  @v_bookkey	INT,
  @v_bookpages  INT,
  @v_budgetprice	FLOAT,
  @v_calcvalue	DECIMAL(18,4),
  @v_charsperpage INT,
  @v_commentkey	INT,
  @v_commenttype	INT, 
  @v_commentsubtype INT,   
  @v_count  INT,
  @v_count2 INT,
  @v_copyfrom_plstage INT,
  @v_copyfrom_plversion INT,
  @v_copyfrom_projectkey  INT,
  @v_copyfrom_template  TINYINT,
  @v_copy_acq_project_data TINYINT, 
  @v_copy_work_project_data TINYINT,
  @v_copy_prtg_project_data TINYINT, 
  @v_coverinkcode INT,    
  @v_cur_commentkey INT,
  @v_cur_formatkey INT,
  @v_cur_marketkey  INT,
  @v_cur_subrightskey INT,
  @v_decprecision_mask  VARCHAR(20),
  @v_default_channellevelind TINYINT,
  @v_default_enterroyaltyind TINYINT,
  @v_default_generateind TINYINT,
  @v_default_grossunitsind TINYINT,
  @v_default_maxyearcode INT,
  @v_description  VARCHAR(2000),
  @v_formatdesc  VARCHAR(2000),
  @v_error  INT,
  @v_errordesc	VARCHAR(2000),
  @v_exchangerate DECIMAL(18,4),
  @v_finalprice	FLOAT,
  @v_format_percent FLOAT,
  @v_initialstatus  INT,
  @v_input_currency	INT,
  @v_isopentrans TINYINT,
  @v_jacketinkcode  INT,  
  @v_market_tableid	INT,  
  @v_marketkey  INT,
  @v_marketcode INT,
  @v_marketsubcode  INT,
  @v_marketsub2code INT,
  @v_marketgrowthrate FLOAT,
  @v_maxyearcode  INT,
  @v_mediatype  INT,
  @v_mediasubtype INT,
  @v_message  VARCHAR(2000),  
  @v_new_formatkey  INT,
  @v_new_qsicode_itemtype INT,
  @v_new_qsicode_usageclass INT,
  @v_new_itemtype INT,
  @v_new_usageclass INT,  
  @v_newkey INT,
  @v_num_decprecision INT,
  @v_orgentrykey  INT,
  @v_orgfilter  VARCHAR(2000),
  @v_orgleveldesc VARCHAR(40),
  @v_plsummaryitemkey	INT,
  @v_prodqtyentrytypecode	INT,
  @v_prtg_media	INT,
  @v_prtg_format INT,
  @v_qsicode_itemtype INT,
  @v_qsicode_usageclass	INT,  
  @v_rightscode INT,
  @v_rowcount INT,
  @v_scaleselectcode  INT,  
  @v_sortorder  INT,
  @v_subrightskey INT,
  @v_taqversiontype	INT,
  @v_templatekey  INT,
  @v_template_currency  INT,
  @v_template_orglevel  INT,
  @v_textinkcode  INT,
  @v_trimfamcode  INT,  
  @v_userid VARCHAR(30),
  @v_versionformats VARCHAR(120),
  @v_versionformatsstring VARCHAR(255),
  @v_yearcode INT, 
  @v_yearnum  INT,
  @v_itemtypecode_PLTemplate INT,
  @v_itemtypesubcode_PLTemplate INT,
  @v_sharedposectionind TINYINT

BEGIN

  SET @v_orgleveldesc = ' '
  SET @v_isopentrans = 0
  SET @o_error_code = 0
  SET @o_error_desc = ''

  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_desc = 'Invalid projectkey.'
    GOTO RETURN_ERROR
  END
  
  IF @i_new_projectkey IS NULL OR @i_new_projectkey <= 0
    SET @i_new_projectkey = @i_projectkey
  
  -- When no PL Stage and PL Version was passed in to copy from, we will copy information from the active template
  SET @v_copyfrom_template = 0
  IF @i_plstage = 0 AND @i_plversion = 0
    SET @v_copyfrom_template = 1  
    
  -- Get the User ID for the passed userkey
  SET @v_userid = 'CopyPLVer'
  IF @i_userkey >= 0 BEGIN
    SELECT @v_userid = userid
    FROM qsiusers
    WHERE userkey = @i_userkey

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
      SET @o_error_desc = 'Could not access qsiusers table to get User ID.'
      GOTO RETURN_ERROR
    END
  END
  
  -- Make sure this project has orgentries filled in up to the required P&L Template orglevel
  SELECT @v_template_orglevel = filterorglevelkey, @v_orgleveldesc = orgleveldesc
  FROM filterorglevel f, orglevel o
  WHERE f.filterorglevelkey = o.orglevelkey AND	f.filterkey = 30
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not access filterorglevel table to get P&L Template orglevel (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END  
  IF @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Missing filterorglevel row for P&L Template (filterkey=30).'
    GOTO RETURN_ERROR
  END

  SELECT @v_count = COUNT(*)
  FROM taqprojectorgentry
  WHERE taqprojectkey = @i_projectkey AND orglevelkey = @v_template_orglevel
  
  IF @v_count = 0 BEGIN
    SET @o_error_desc = 'Project is missing orgentry value at the required P&L Template level: ' + @v_orgleveldesc + '(taqprojectkey=' + cast(@i_projectkey AS VARCHAR) + ').'
    GOTO RETURN_ERROR  
  END  
  
  SELECT @v_itemtypecode_PLTemplate = datacode, @v_itemtypesubcode_PLTemplate = datasubcode 
  FROM subgentables where tableid = 550 and qsicode = 29
  
  -- Check to see what type of project P&L version is being created for:
  -- Acquisition Project (itemtype qsicode = 3, usageclass qsicode = 1)
  -- Work Project (itemtype qsicode = 9, usageclass qsicode = 1)
  -- Printing (itemtype qsicode = 14, usageclass qsicode = 40)
  SELECT @v_qsicode_itemtype = g.qsicode, @v_qsicode_usageclass = sg.qsicode
  FROM taqproject p
    JOIN gentables g ON p.searchitemcode = g.datacode AND g.tableid = 550
    JOIN subgentables sg ON p.searchitemcode = sg.datacode AND p.usageclasscode = sg.datasubcode AND sg.tableid = 550
  WHERE taqprojectkey = @i_projectkey
  
  IF @v_copyfrom_template = 1
  BEGIN
  
    IF @i_copy_project_data = 1 
    BEGIN

      IF @v_qsicode_itemtype = 3 AND @v_qsicode_usageclass = 1
        SET @v_copy_acq_project_data = 1
      ELSE
        SET @v_copy_acq_project_data = 0

      IF @v_qsicode_itemtype = 9 
        SET @v_copy_work_project_data = 1
      ELSE
        SET @v_copy_work_project_data = 0
        
      IF @v_qsicode_itemtype = 14
        SET @v_copy_prtg_project_data = 1
      ELSE
        SET @v_copy_prtg_project_data = 0
    END
      
    -- Get Active Project Status (qsicode=3)
    SELECT @v_activestatus = datacode
    FROM gentables
    WHERE tableid = 522 AND qsicode = 3

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Could not access gentables to get Active Project Status (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
    IF @v_rowcount <= 0 BEGIN
      SET @o_error_desc = 'QSICode=3 for Active Project Status is not set on gentables.'
      GOTO RETURN_ERROR
    END
  
    -- Get Orgentry filter for this project
    DECLARE org_cur CURSOR FOR  
      SELECT orgentrykey FROM taqprojectorgentry 
      WHERE taqprojectkey = @i_projectkey
      ORDER BY orglevelkey
      
    OPEN org_cur
    
    FETCH org_cur INTO @v_orgentrykey

    SET @v_orgfilter = ' '
    WHILE (@@FETCH_STATUS=0)
    BEGIN  
      
      IF @v_orgfilter <> ' '
        SET @v_orgfilter = @v_orgfilter + ','
        
      SET @v_orgfilter = @v_orgfilter + CONVERT(VARCHAR, @v_orgentrykey)
      
      FETCH org_cur INTO @v_orgentrykey
    END
    
    CLOSE org_cur
    DEALLOCATE org_cur
    
    SET @v_orgfilter = '(' + @v_orgfilter + ')'

    -- Get the active templatekey for this project's orgentries and the selected P&L Type/Subtype and Release Strategy
    EXEC qpl_get_pltemplate_key @v_orgfilter, @v_activestatus, @i_pltype, @i_plsubtype, @i_relstrategy,
      @v_templatekey OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

    -- Exit if error was returned from stored procedure
    IF @o_error_code = -1
      GOTO RETURN_ERROR
  
    -- Copying from template
    SET @v_copyfrom_projectkey = @v_templatekey
    SET @v_copyfrom_plstage = (SELECT datacode FROM gentables WHERE tableid = 562 AND qsicode = 2)
    SET @v_copyfrom_plversion = 1
    
    -- When template is not found, get option defaults from clientdefaults table
    IF @v_templatekey = 0
    BEGIN
      SET @v_default_generateind = 0
      SET @v_default_grossunitsind = 0
      SET @v_default_channellevelind = 0
      SET @v_default_enterroyaltyind = 0
      SET @v_default_maxyearcode = 1    
      
      -- Generate (1) or Enter (0) Detail Sales Units
      SELECT @v_count = COUNT(*)
      FROM clientdefaults WHERE clientdefaultid = 13
      
      IF @v_count > 0
        SELECT @v_default_generateind = clientdefaultvalue
        FROM clientdefaults WHERE clientdefaultid = 13

      -- Gross (1) or Net (0) Sales Units
      SELECT @v_count = COUNT(*)
      FROM clientdefaults WHERE clientdefaultid = 12
      
      IF @v_count > 0
        SELECT @v_default_grossunitsind = clientdefaultvalue
        FROM clientdefaults WHERE clientdefaultid = 12

      -- Sales Channel Level (1) or Sub Sales Channel Level (0)
      SELECT @v_count = COUNT(*)
      FROM clientdefaults WHERE clientdefaultid = 16
      
      IF @v_count > 0
        SELECT @v_default_channellevelind = clientdefaultvalue
        FROM clientdefaults WHERE clientdefaultid = 16

      -- Include Up To Year value (1-4)
      SELECT @v_count = COUNT(*)
      FROM clientdefaults WHERE clientdefaultid = 15
      
      IF @v_count > 0
        SELECT @v_default_maxyearcode = clientdefaultvalue
        FROM clientdefaults WHERE clientdefaultid = 15

      -- Enter Royalty As Average (1) or By Sales Channel (0)
      SELECT @v_count = COUNT(*)
      FROM clientdefaults WHERE clientdefaultid = 14
      
      IF @v_count > 0
        SELECT @v_default_enterroyaltyind = clientdefaultvalue
        FROM clientdefaults WHERE clientdefaultid = 14  
    END
  END --IF @v_copyfrom_template = 1
  ELSE
  BEGIN
    -- Copying from the given project/stage/version
    SET @v_copyfrom_projectkey = @i_projectkey
    SET @v_copyfrom_plstage = @i_plstage
    SET @v_copyfrom_plversion = @i_plversion
  END  
  
  PRINT 'Copy From projectkey: ' + CONVERT(VARCHAR, @v_copyfrom_projectkey)
  PRINT 'Copy From plstage: ' + CONVERT(VARCHAR, @v_copyfrom_plstage)
  PRINT 'Copy From taqversionkey: ' + CONVERT(VARCHAR, @v_copyfrom_plversion)
  PRINT 'Copy From project itemtype/class (qsicode): ' + CONVERT(VARCHAR, @v_qsicode_itemtype) + '/' + CONVERT(VARCHAR, @v_qsicode_usageclass)

  SELECT @v_new_itemtype = p.searchitemcode, @v_new_qsicode_itemtype = g.qsicode, 
    @v_new_usageclass = p.usageclasscode, @v_new_qsicode_usageclass = sg.qsicode,
    @v_input_currency = COALESCE(p.plenteredcurrency,0), @v_approval_currency = COALESCE(p.plapprovalcurrency,0)
  FROM taqproject p
    JOIN gentables g ON p.searchitemcode = g.datacode AND g.tableid = 550
    JOIN subgentables sg ON p.searchitemcode = sg.datacode AND p.usageclasscode = sg.datasubcode AND sg.tableid = 550
  WHERE taqprojectkey = @i_new_projectkey
 
  PRINT 'NEW project itemtype/class (qsicode): ' + CONVERT(VARCHAR, @v_new_itemtype) + ' (' + CONVERT(VARCHAR, @v_new_qsicode_itemtype) + ') / ' + CONVERT(VARCHAR, @v_new_usageclass) + ' (' + CONVERT(VARCHAR, @v_new_qsicode_usageclass)  + ')'

  -- ***** BEGIN TRANSACTION ****  
  BEGIN TRANSACTION
  SET @v_isopentrans = 1
   
  -- For the very first Version within given Stage, insert a new taqplstage record if doesn't exist
  SELECT @v_count = COUNT(*)
  FROM taqplstage
  WHERE taqprojectkey = @i_new_projectkey AND plstagecode = @i_new_plstage
  
  IF @v_count = 0
  BEGIN      
    IF @v_new_itemtype = @v_itemtypecode_PLTemplate AND @v_new_usageclass = @v_itemtypesubcode_PLTemplate BEGIN
		INSERT INTO taqplstage 
		  (taqprojectkey, plstagecode, selectedversionkey, lastuserid, lastmaintdate)
		VALUES 
		  (@i_new_projectkey, @i_new_plstage, @i_plversion, @v_userid, getdate())
    END
    ELSE BEGIN 
		INSERT INTO taqplstage 
		  (taqprojectkey, plstagecode, selectedversionkey, lastuserid, lastmaintdate)
		VALUES 
		  (@i_new_projectkey, @i_new_plstage, 0, @v_userid, getdate())
	END        
      
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Insert into taqplstage table failed (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
  END
  
  -- When copying from a different template/project (rather than self), copy the currency fields
  IF @v_copyfrom_projectkey <> @i_new_projectkey AND @v_copyfrom_projectkey > 0 AND @v_input_currency = 0 AND @v_approval_currency = 0
  BEGIN
    SELECT @v_input_currency = plenteredcurrency, @v_approval_currency = plapprovalcurrency
    FROM taqproject
    WHERE taqprojectkey = @v_copyfrom_projectkey
      
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Could not access taqproject table to get currency information (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
    
    -- Only update currency values if they are NULL on the target project
    IF EXISTS (
      SELECT 1 FROM taqproject 
      WHERE taqprojectkey = @i_new_projectkey
        AND plenteredcurrency IS NULL)
    BEGIN
      UPDATE taqproject
      SET plenteredcurrency = @v_input_currency
      WHERE taqprojectkey = @i_new_projectkey
    END ELSE BEGIN
      SELECT @v_input_currency = plenteredcurrency
      FROM taqproject
      WHERE taqprojectkey = @i_new_projectkey
    END
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Could not update currency information for the new project (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    IF EXISTS (
      SELECT 1 FROM taqproject 
      WHERE taqprojectkey = @i_new_projectkey
        AND plapprovalcurrency IS NULL)
    BEGIN
      UPDATE taqproject
      SET plapprovalcurrency = @v_approval_currency
      WHERE taqprojectkey = @i_new_projectkey
    END ELSE BEGIN
      SELECT @v_approval_currency = plapprovalcurrency
      FROM taqproject
      WHERE taqprojectkey = @i_new_projectkey
    END
    
    -- If input currency differs from approval currency, update latest exchange rate if rate is null
    IF @v_input_currency <> @v_approval_currency
    BEGIN
      SELECT @v_exchangerate = exchangerate
      FROM taqplstage
      WHERE taqprojectkey = @i_new_projectkey AND plstagecode = @i_new_plstage
      
      IF @v_exchangerate IS NULL
      BEGIN 
        SELECT @v_count = COUNT(*)
        FROM gentablesrelationshipdetail
        WHERE gentablesrelationshipkey = 27 AND code1 = @v_input_currency AND code2 = @v_approval_currency

        IF @v_count > 0
        BEGIN
          SELECT @v_exchangerate = decimal1
          FROM gentablesrelationshipdetail
          WHERE gentablesrelationshipkey = 27 AND code1 = @v_input_currency AND code2 = @v_approval_currency
        
          UPDATE taqplstage
          SET exchangerate = @v_exchangerate
          WHERE taqprojectkey = @i_new_projectkey AND plstagecode = @i_new_plstage
        END
      END
    END    
  END   
  
  -- When copying from Title Acqusition to Work, copy the actual status; otherwise, copy the initial P&L Status from client defaults table.
  IF @v_qsicode_itemtype = 3 AND @v_qsicode_usageclass = 1 AND @v_new_qsicode_itemtype = 9
  BEGIN
    SELECT @v_initialstatus = plstatuscode
    FROM taqversion
    WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion
  END
  ELSE
  BEGIN
    SELECT @v_initialstatus = clientdefaultvalue
    FROM clientdefaults
    WHERE clientdefaultid = 56  --Initial P&L Status
    
    SELECT @v_rowcount = @@ROWCOUNT
    IF @v_rowcount = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Missing client default 56-Initial P&L Status.'
      RETURN
    END
    
    IF @v_initialstatus IS NULL OR @v_initialstatus = 0
    BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Client default 56 has no value.'
      RETURN
    END
  END

  -- Check if the initial P&L Status value is valid for the new project's itemtype/usageclass.
  -- If not, use a default value determined by item type and sortorder (see spec on case 27688 - section 13)
  SELECT @v_count = COUNT(*)
  FROM gentablesitemtype
  WHERE tableid = 565 AND datacode = @v_initialstatus 
    AND itemtypecode = @v_new_itemtype AND (itemtypesubcode = @v_new_usageclass OR itemtypesubcode = 0)

  IF @v_count = 0
  BEGIN
    SELECT @v_initialstatus = gi.datacode
    FROM gentablesitemtype gi, gentables g
    WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus='N'
      AND gi.tableid = 565 AND gi.itemtypecode = @v_new_itemtype
      AND (gi.itemtypesubcode = @v_new_usageclass OR gi.itemtypesubcode = 0)
    ORDER BY gi.sortorder ASC, g.sortorder ASC
  END
  
  IF @v_copyfrom_template = 1 AND @v_templatekey = 0
  BEGIN
    -- For Printings and POs, always set Prod Qty option to "Generate From FG Qty"
    IF @v_new_qsicode_itemtype = 14 OR @v_new_qsicode_itemtype = 15
      SET @v_prodqtyentrytypecode = 4
    ELSE
	  SET @v_prodqtyentrytypecode = (SELECT clientdefaultvalue FROM clientdefaults WHERE clientdefaultid = 62)
  END
  ELSE
    SET @v_prodqtyentrytypecode = (SELECT prodqtyentrytypecode FROM taqversion WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion)
  
  SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
  IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
    SET @o_error_desc = 'Could not get prodqtyentrytypecode for copy/create.'
    GOTO RETURN_ERROR
  END
  
  -- Get taqversiontype for P&L
  SELECT @v_taqversiontype=datacode
  FROM gentables
  WHERE tableid=629 AND lower(datadesc) like 'p&l'
  
  SELECT @v_rowcount = @@ROWCOUNT
  IF @v_rowcount = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Missing taqversiontype gentable entry (gentable 629).'
    RETURN
  END
  
  IF @v_taqversiontype IS NULL OR @v_taqversiontype = 0
  BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'taqversiontype (gentable 629) has no value.'
    RETURN
  END

  -- ****** Continue copying template/version detail to new P&L version ******
    
  IF @v_copy_acq_project_data = 1 OR @v_copy_work_project_data = 1 OR @v_copy_prtg_project_data = 1
  BEGIN
    IF @v_copy_acq_project_data = 1
      DECLARE versionformats_cur CURSOR FOR
        SELECT taqprojectformatdesc 
        FROM taqprojecttitle 
        WHERE taqprojectkey = @i_projectkey 
          AND titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)  --Title Role = Format
          AND projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 2) -- Proj Role=Title Acquisition  
          AND taqprojectformatdesc IS NOT NULL
    ELSE IF @v_copy_work_project_data = 1
      DECLARE versionformats_cur CURSOR FOR
        SELECT s.datadesc 
        FROM taqprojecttitle t, bookdetail bd, subgentables s
        WHERE t.bookkey = bd.bookkey 
          AND bd.mediatypecode = s.datacode 
          AND bd.mediatypesubcode = s.datasubcode 
          AND s.tableid = 312
          AND t.taqprojectkey = @i_projectkey 
          AND t.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 1)  --Title Role=Title
          AND t.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 1)	--Proj Role=Work
    ELSE IF @v_copy_prtg_project_data = 1
      DECLARE versionformats_cur CURSOR FOR
        SELECT s.datadesc 
        FROM taqprojecttitle t, bookdetail bd, subgentables s
        WHERE t.bookkey = bd.bookkey 
          AND bd.mediatypecode = s.datacode 
          AND bd.mediatypesubcode = s.datasubcode 
          AND s.tableid = 312
          AND t.taqprojectkey = @i_projectkey 
          AND t.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 7)  --Title Role=Printing Title 
          AND t.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 3) -- Proj Role=Printing

    OPEN versionformats_cur 
    
    FETCH versionformats_cur INTO @v_versionformats
    
    SET @v_versionformatsstring = ' '
    WHILE (@@FETCH_STATUS=0)
    BEGIN  
      IF @v_versionformatsstring <> ' '
        SET @v_versionformatsstring = @v_versionformatsstring + ','
        
      SET @v_versionformatsstring = @v_versionformatsstring + @v_versionformats

      FETCH versionformats_cur INTO @v_versionformats
    END

    CLOSE versionformats_cur 
    DEALLOCATE versionformats_cur
  END
  ELSE 
  BEGIN    
    SELECT @v_versionformatsstring = versionformats 
    FROM taqversion 
    WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion
  END

  -- TAQVERSION
  INSERT INTO taqversion 
    (taqprojectkey, plstagecode, taqversionkey, taqversiondesc, plstatuscode, pltypecode, pltypesubcode, 
     releasestrategycode, quantitytypecode, grosssalesunitind, saleschannellevelind, generatedetailsalesunitsind,
     avgroyaltyenteredind, maxyearcode, versionformats, totalsalesunits, numberofchars,
     numberofwords, manuscriptpages, lastuserid, lastmaintdate, copiedfromprojectkey, copiedfromstage, copiedfromversion, 
     prodqtyentrytypecode, generatecostsautoind, taqversiontype)
  SELECT
    @i_new_projectkey, @i_new_plstage, @i_new_plversion, @i_versiondesc, @v_initialstatus, @i_pltype, @i_plsubtype, 
    @i_relstrategy, quantitytypecode, grosssalesunitind, saleschannellevelind, generatedetailsalesunitsind,
    avgroyaltyenteredind, maxyearcode, @v_versionformatsstring AS versionformats, totalsalesunits, numberofchars,
    numberofwords, manuscriptpages, @v_userid, getdate(), @v_copyfrom_projectkey, @v_copyfrom_plstage, @v_copyfrom_plversion, 
    @v_prodqtyentrytypecode, generatecostsautoind, @v_taqversiontype
  FROM taqversion
  WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not insert into taqversion table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  
  -- TAQVERSIONCLIENTVALUES
  INSERT INTO taqversionclientvalues
    (taqprojectkey, plstagecode, taqversionkey, clientvaluecode, clientvalue, lastuserid, lastmaintdate)
  SELECT
    @i_new_projectkey, @i_new_plstage, @i_new_plversion, clientvaluecode, clientvalue, @v_userid, getdate()
  FROM taqversionclientvalues
  WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not insert into taqversionclientvalues table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END
  
  
  -- TAQPLSUMMARYITEMS
  -- Copy the Version and Year level summary items: all items if the summary level doesn't require item type filtering, 
  -- and only the filtered items for the NEW project's item type/usage class if the summary level requires item type filtering
  INSERT INTO taqplsummaryitems
    (taqprojectkey, plsummaryitemkey, plstagecode, taqversionkey, yearcode, longvalue, textvalue, decimalvalue, lastuserid, lastmaintdate)
  SELECT 
    @i_new_projectkey, i.plsummaryitemkey, @i_new_plstage, @i_new_plversion, i.yearcode, i.longvalue, i.textvalue, i.decimalvalue, @v_userid, getdate()
  FROM taqplsummaryitems i, plsummaryitemdefinition d, gentables g
  WHERE i.plsummaryitemkey = d.plsummaryitemkey 
    AND g.tableid = 561 AND g.datacode = d.summarylevelcode AND COALESCE(g.gen1ind, 0) = 0
	AND i.taqprojectkey = @v_copyfrom_projectkey AND i.plstagecode = @v_copyfrom_plstage AND i.taqversionkey = @v_copyfrom_plversion 
  UNION
  SELECT
    @i_new_projectkey, i.plsummaryitemkey, @i_new_plstage, @i_new_plversion, yearcode, longvalue, textvalue, decimalvalue, @v_userid, getdate()
  FROM taqplsummaryitems i, plsummaryitemdefinition d, gentables g, plsummaryitemtype t
  WHERE i.plsummaryitemkey = d.plsummaryitemkey 
    AND g.tableid = 561 AND g.datacode = d.summarylevelcode AND g.gen1ind = 1
	AND t.plsummaryitemkey = i.plsummaryitemkey AND t.itemtypecode = @v_new_itemtype AND t.itemtypesubcode IN (0, @v_new_usageclass)
	AND i.taqprojectkey = @v_copyfrom_projectkey AND i.plstagecode = @v_copyfrom_plstage AND i.taqversionkey = @v_copyfrom_plversion 
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not insert into taqplsummaryitems table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END

  
  -- Loop to calculate any additional p&l summary items filtered for the new project's item type/class but not copied from source project
  DECLARE addtlitems_cur CURSOR FOR
    SELECT plsummaryitemkey
    FROM plsummaryitemtype
    WHERE itemtypecode = @v_new_itemtype AND itemtypesubcode IN (0, @v_new_usageclass)
      AND NOT EXISTS (SELECT * FROM taqplsummaryitems i 
                      WHERE i.plsummaryitemkey = plsummaryitemtype.plsummaryitemkey 
                        AND taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion)
                        
  OPEN addtlitems_cur
  
  FETCH addtlitems_cur INTO @v_plsummaryitemkey

  WHILE (@@FETCH_STATUS=0)
  BEGIN
    EXEC qpl_run_pl_calcsql @i_new_projectkey, @i_new_plstage, @i_new_plversion, 0, @v_plsummaryitemkey, @v_input_currency,
      @v_calcvalue OUTPUT, @v_error OUTPUT, @v_errordesc OUTPUT
        
    IF @v_error = 0 --success
      INSERT INTO taqplsummaryitems
        (taqprojectkey, plstagecode, taqversionkey, yearcode, plsummaryitemkey, decimalvalue, lastuserid, lastmaintdate)
      VALUES
        (@i_new_projectkey, @i_new_plstage, @i_new_plversion, 0, @v_plsummaryitemkey, @v_calcvalue, @v_userid, getdate())

    FETCH addtlitems_cur INTO @v_plsummaryitemkey
  END

  CLOSE addtlitems_cur 
  DEALLOCATE addtlitems_cur
    
  
  -- TAQVERSIONCOMMENTS
  IF @v_copy_acq_project_data = 1 OR @v_copy_work_project_data = 1
  BEGIN
    IF @v_copy_acq_project_data = 1
      DECLARE projectcomments_cur CURSOR FOR
        SELECT commenttypecode, commenttypesubcode, commentkey, sortorder, 0 bookkey
        FROM taqprojectcomments
        WHERE taqprojectkey = @i_projectkey 
    ELSE IF @v_copy_work_project_data = 1
      DECLARE projectcomments_cur CURSOR FOR
        SELECT commenttypecode, commenttypesubcode, 0 commentkey, 0 sortorder, bookkey
        FROM bookcomments
        WHERE bookkey IN (SELECT p.bookkey FROM taqprojecttitle p WHERE p.taqprojectkey = @i_projectkey AND p.bookkey > 0)

    OPEN projectcomments_cur 

    FETCH projectcomments_cur INTO @v_commenttype, @v_commentsubtype, @v_cur_commentkey, @v_sortorder, @v_bookkey

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      IF @v_copy_acq_project_data = 1
      BEGIN
        -- Check if this comment is valid for Projects/Title Acquisition
        SELECT @v_count = COUNT(*)
        FROM gentablesitemtype 
        WHERE tableid = 284 AND datacode = @v_commenttype AND datasubcode = @v_commentsubtype
          AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 3)
          AND itemtypesubcode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 1)  
      END
      ELSE IF @v_copy_work_project_data = 1
      BEGIN
        -- Check if this comment is valid for Titles/Title
        SELECT @v_count = COUNT(*)
        FROM gentablesitemtype 
        WHERE tableid = 284 AND datacode = @v_commenttype AND datasubcode = @v_commentsubtype
          AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 1)
          AND itemtypesubcode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 26)
      END    

      IF @v_count > 0
      BEGIN
        -- Check if this comment is valid for User Admin/P&L Template
        SELECT @v_count = COUNT(*)
        FROM gentablesitemtype 
        WHERE tableid = 284 AND datacode = @v_commenttype AND datasubcode = @v_commentsubtype
          AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 AND qsicode = 5)
          AND itemtypesubcode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 AND qsicode = 29)      

        IF @v_count > 0
        BEGIN
          IF @v_copy_acq_project_data = 1
          BEGIN
            -- generate new commentkey
            EXEC get_next_key @v_userid, @v_commentkey OUTPUT

            INSERT INTO qsicomments
              (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, lastuserid, lastmaintdate, invalidhtmlind)
            SELECT
              @v_commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, @v_userid, getdate(), invalidhtmlind
            FROM qsicomments
            WHERE commentkey = @v_cur_commentkey

            SELECT @v_error = @@ERROR
            IF @v_error <> 0 BEGIN
              SET @o_error_desc = 'Could not insert into qsicomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
              GOTO RETURN_ERROR
            END

            INSERT INTO taqversioncomments
              (taqprojectkey, plstagecode, taqversionkey, commenttypecode, commenttypesubcode, commentkey, sortorder, lastuserid, lastmaintdate)
            VALUES
              (@i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_commenttype, @v_commentsubtype, @v_commentkey, @v_sortorder, @v_userid, getdate())

            SELECT @v_error = @@ERROR
            IF @v_error <> 0 BEGIN
              SET @o_error_desc = 'Could not insert into taqversioncomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
              GOTO RETURN_ERROR
            END
          END --@v_copy_acq_project_data = 1          
          ELSE IF @v_copy_work_project_data = 1
          BEGIN
            SELECT @v_count2 = COUNT(*)
            FROM taqversioncomments
            WHERE taqprojectkey = @i_new_projectkey AND plstagecode = @i_new_plstage AND taqversionkey = @i_new_plversion
              AND commenttypecode = @v_commenttype AND commenttypesubcode = @v_commentsubtype

            IF @v_count2 = 0
            BEGIN
              -- generate new commentkey
              EXEC get_next_key @v_userid, @v_commentkey OUTPUT

              INSERT INTO qsicomments
                (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, lastuserid, lastmaintdate, invalidhtmlind)
              SELECT
                @v_commentkey, commenttypecode, commenttypesubcode, NULL, commenttext, commenthtml, commenthtmllite, @v_userid, getdate(), invalidhtmlind
              FROM bookcomments
              WHERE bookkey = @v_bookkey AND commenttypecode = @v_commenttype AND commenttypesubcode = @v_commentsubtype

              SELECT @v_error = @@ERROR
              IF @v_error <> 0 BEGIN
                SET @o_error_desc = 'Could not insert into qsicomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
                GOTO RETURN_ERROR
              END
              
              INSERT INTO taqversioncomments
                (taqprojectkey, plstagecode, taqversionkey, commenttypecode, commenttypesubcode, commentkey, sortorder, lastuserid, lastmaintdate)
              VALUES
                (@i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_commenttype, @v_commentsubtype, @v_commentkey, @v_sortorder, @v_userid, getdate())

              SELECT @v_error = @@ERROR
              IF @v_error <> 0 BEGIN
                SET @o_error_desc = 'Could not insert into taqversioncomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
                GOTO RETURN_ERROR
              END
            END --@v_count2 = 0
          END --@v_copy_work_project_data = 1
        END --@v_count > 0 (valid User Admin/P&L Template comment)
      END --@v_count > 0 (valid Projects/Title Acquisition or Titles/Title comment)

      FETCH projectcomments_cur INTO @v_commenttype, @v_commentsubtype, @v_cur_commentkey, @v_sortorder	, @v_bookkey
    END

    CLOSE projectcomments_cur 
    DEALLOCATE projectcomments_cur
  END --@v_copy_acq_project_data = 1 OR @v_copy_work_project_data
  
  -- Copy comments from the template/project (only those not already copied from project above)
  DECLARE versioncomments_cur CURSOR FOR
    SELECT c1.commenttypecode, c1.commenttypesubcode, c1.commentkey, c1.sortorder
    FROM taqversioncomments c1
    WHERE c1.taqprojectkey = @v_copyfrom_projectkey AND c1.plstagecode = @v_copyfrom_plstage AND c1.taqversionkey = @v_copyfrom_plversion AND
      NOT EXISTS (SELECT * FROM taqversioncomments c2
                  WHERE c2.taqprojectkey = @i_new_projectkey AND
                    c2.plstagecode = @i_new_plstage AND
                    c2.taqversionkey = @i_new_plversion AND
                    c1.commenttypecode = c2.commenttypecode AND
                    c1.commenttypesubcode = c2.commenttypesubcode)

  OPEN versioncomments_cur 

  FETCH versioncomments_cur INTO @v_commenttype, @v_commentsubtype, @v_cur_commentkey, @v_sortorder

  WHILE (@@FETCH_STATUS=0)
  BEGIN
    -- generate new commentkey
    EXEC get_next_key @v_userid, @v_commentkey OUTPUT

    INSERT INTO qsicomments
      (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, lastuserid, lastmaintdate, invalidhtmlind)
    SELECT
      @v_commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml, commenthtmllite, @v_userid, getdate(), invalidhtmlind
    FROM qsicomments
    WHERE commentkey = @v_cur_commentkey

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Could not insert into qsicomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    INSERT INTO taqversioncomments
      (taqprojectkey, plstagecode, taqversionkey, commenttypecode, commenttypesubcode, commentkey, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_commenttype, @v_commentsubtype, @v_commentkey, @v_sortorder, @v_userid, getdate())

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Could not insert into taqversioncomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
    
    FETCH versioncomments_cur INTO @v_commenttype, @v_commentsubtype, @v_cur_commentkey, @v_sortorder
  END

  CLOSE versioncomments_cur 
  DEALLOCATE versioncomments_cur 

  -- Get the decimal precision mask for currency format as set for the new project's item type (default to none)
  SELECT @v_decprecision_mask = COALESCE(g.gentext1, '') 
  FROM taqproject p 
    LEFT OUTER JOIN gentables_ext g ON p.searchitemcode = g.datacode AND g.tableid = 550 
  WHERE p.taqprojectkey = @i_new_projectkey
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Could not access taqproject/gentables_ext tables to get P&L Currency Decimal Precision mask for the new project.'
  END

  IF @v_decprecision_mask <> ''
    SET @v_num_decprecision = SUBSTRING(@v_decprecision_mask, 2, 20)
  ELSE
    SET @v_num_decprecision = 0    
  
  -- TAQVERSIONROYALTYADVANCE
  -- ME ME EDIT ME! TODO
  --where exists taqprojectcontactrole and exists taqProjectContact
  --then if recordCount = 0 
  --insert a row with 0, 0
  --i_projectkey

  --for debug
  SELECT
    @i_new_projectkey AS taqprojectkey, 
	@i_new_plstage AS plstagecode, 
	@i_new_plversion AS taqversionkey, 
	yearcode, 
	datetypecode, 
	dateoffsetcode, 
	ROUND(amount, @v_num_decprecision) AS amount, 
	@v_userid AS lastUserID, 
	getdate() AS lastMaintDate,
	roletypecode,
	globalContactKey
  INTO #taqVersionRoyaltyAdv
  FROM taqversionroyaltyadvance
  WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion
  

  --If the person doesn't exist on the project do not copy them set to all contacts for the role
  UPDATE cr 
  SET cr.globalcontactkey = 0 
  FROM #taqVersionRoyaltyAdv cr
  WHERE NOT EXISTS(SELECT 1 FROM taqprojectcontact tpc
  					WHERE cr.taqProjectKey = tpc.taqprojectkey
  					AND cr.globalcontactkey = tpc.globalcontactkey)
  AND cr.globalcontactkey != 0

  --Remove dupes on role / contact level.  
  --This is mostly used for if we had two contacts for one roleTypeCode and taqprojectformatkey
  --that aren't associated with the project, we cant have two rows saying 0 for all contacts.
  ;WITH cte_wins
  AS
  (
	SELECT roleTypeCode,globalContactKey,taqProjectkey,taqVersionKey,plstagecode,yearCode,dateTypeCode,dateOffsetCode,
			ROW_NUMBER() OVER(PARTITION BY roleTypeCode,globalContactKey,taqProjectkey,taqVersionKey,plstagecode,yearCode,dateTypeCode,dateOffsetCode ORDER BY roleTypeCode DESC) AS rnk
	FROM #taqVersionRoyaltyAdv
  )
  DELETE cte_wins
  WHERE rnk > 1

  --If we have a contact for a role, but also have a row for that role with a contact of 0 we need to delete it
  --as it contradicts.  Since 0 means all contacts and we have a specific one as well.
  DELETE ct1
  FROM #taqVersionRoyaltyAdv ct1
  WHERE EXISTS(SELECT 1 FROM #taqVersionRoyaltyAdv ct2	
  				WHERE ct1.roletypecode = ct2.roletypecode
				AND ct1.taqProjectkey = ct2.taqProjectkey
				AND ct1.taqVersionKey = ct2.taqVersionKey
				AND ct1.plstagecode = ct2.plstagecode
				AND ct1.yearCode = ct2.yearCode
				AND ct1.dateTypeCode = ct2.dateTypeCode
				AND ct1.dateOffsetCode = ct2.dateOffsetCode
  				AND ct1.globalcontactkey != 0) 
  AND ct1.globalcontactkey = 0


  INSERT INTO taqversionroyaltyadvance
    (taqprojectkey, plstagecode, taqversionkey, yearcode, datetypecode, dateoffsetcode, amount, lastuserid, lastmaintdate,roletypecode,globalContactKey)
  SELECT
    taqProjectkey, plstagecode, taqversionkey, yearcode, datetypecode, dateoffsetcode, amount, lastuserid, lastmaintdate,roletypecode,globalContactKey
  FROM #taqVersionRoyaltyAdv
  
  SELECT @v_error = @@ERROR
  IF @v_error <> 0 BEGIN
    SET @o_error_desc = 'Could not insert into taqversionroyaltyadvance table (Error ' + cast(@v_error AS VARCHAR) + ').'
    GOTO RETURN_ERROR
  END    
  
  
  -- TAQVERSIONMARKET / TAQVERSIONMARKETCHANNELYEAR
  -- Loop through all version markets
  DECLARE markets_cur CURSOR FOR
    SELECT targetmarketkey, marketcode, marketsubcode, marketsub2code, marketgrowthpercent, sortorder
    FROM taqversionmarket
    WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion
    
  OPEN markets_cur
  
  FETCH markets_cur
  INTO @v_cur_marketkey, @v_marketcode, @v_marketsubcode, @v_marketsub2code, @v_marketgrowthrate, @v_sortorder

  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
    -- generate new marketkey
    EXEC get_next_key @v_userid, @v_marketkey OUTPUT
  
    -- TAQVERSIONMARKET
    INSERT INTO taqversionmarket
      (targetmarketkey, taqprojectkey, plstagecode, taqversionkey, 
       marketcode, marketsubcode, marketsub2code, marketgrowthpercent, sortorder, lastuserid, lastmaintdate)
    VALUES
      (@v_marketkey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, 
       @v_marketcode, @v_marketsubcode, @v_marketsub2code, @v_marketgrowthrate, @v_sortorder, @v_userid, getdate())

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE markets_cur
      DEALLOCATE markets_cur    
      SET @o_error_desc = 'Could not insert into taqversionmarket table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
    
    -- TAQVERSIONMARKETCHANNELYEAR
    INSERT INTO taqversionmarketchannelyear
      (targetmarketkey, saleschannelcode, yearcode, marketshare, marketsize, sellthroughunits, lastuserid, lastmaintdate)
    SELECT
      @v_marketkey, saleschannelcode, yearcode, marketshare, marketsize, sellthroughunits, @v_userid, getdate()
    FROM taqversionmarketchannelyear
    WHERE targetmarketkey = @v_cur_marketkey

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE markets_cur
      DEALLOCATE markets_cur
      SET @o_error_desc = 'Could not insert into taqversiotaqversionmarketchannelyearnsubrightsyear table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END    
      
    FETCH markets_cur
    INTO @v_cur_marketkey, @v_marketcode, @v_marketsubcode, @v_marketsub2code, @v_marketgrowthrate, @v_sortorder
  END
  
  CLOSE markets_cur
  DEALLOCATE markets_cur 

  -- When copying project data for Acquisition Projects, make sure all Market categories are copied from project
  -- that were not already copied from the template
  IF @v_copy_acq_project_data = 1 OR @v_copy_work_project_data = 1
  BEGIN
    SELECT @v_count = COUNT(*)
    FROM clientdefaults
    WHERE clientdefaultid = 54

    SET @v_market_tableid = 0
    IF @v_count = 1
      SELECT @v_market_tableid = clientdefaultvalue
      FROM clientdefaults
      WHERE clientdefaultid = 54

    IF @v_market_tableid > 0 
    BEGIN
      SELECT @v_count = COUNT(*)
      FROM taqversionmarket
      WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion
      
      SET @v_sortorder = 1
      IF @v_count > 0
        SELECT @v_sortorder = MAX(sortorder) + 1
        FROM taqversionmarket
        WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion
      
      IF @v_copy_acq_project_data = 1
        DECLARE taqprojectsubjectcategory_cur CURSOR FOR
          SELECT c.categorycode, c.categorysubcode, c.categorysub2code
          FROM taqprojectsubjectcategory c
          WHERE c.categorytableid = @v_market_tableid AND
            c.taqprojectkey = @i_projectkey AND 
            NOT EXISTS (SELECT * FROM taqversionmarket m 
                        WHERE m.marketcode = c.categorycode AND 
                          m.marketsubcode = c.categorysubcode AND 
                          m.marketsub2code = c.categorysub2code AND
                          m.taqprojectkey = @v_copyfrom_projectkey AND 
                          m.plstagecode = @v_copyfrom_plstage AND 
                          m.taqversionkey = @v_copyfrom_plversion) 
      ELSE IF @v_copy_work_project_data = 1    
        DECLARE taqprojectsubjectcategory_cur CURSOR FOR
          SELECT DISTINCT c.categorycode, c.categorysubcode, c.categorysub2code
          FROM booksubjectcategory c
          WHERE c.categorytableid = @v_market_tableid AND
            bookkey IN (SELECT p.bookkey FROM taqprojecttitle p WHERE p.taqprojectkey = @i_projectkey AND p.bookkey > 0) AND
            NOT EXISTS (SELECT * FROM taqversionmarket m 
                        WHERE m.marketcode = c.categorycode AND 
                          m.marketsubcode = c.categorysubcode AND 
                          m.marketsub2code = c.categorysub2code AND
                          m.taqprojectkey = @v_copyfrom_projectkey AND 
                          m.plstagecode = @v_copyfrom_plstage AND 
                          m.taqversionkey = @v_copyfrom_plversion)    

      OPEN taqprojectsubjectcategory_cur

      FETCH taqprojectsubjectcategory_cur INTO @v_marketcode, @v_marketsubcode, @v_marketsub2code

      WHILE (@@FETCH_STATUS=0)
      BEGIN
        -- generate new marketkey
        EXEC get_next_key @v_userid, @v_marketkey OUTPUT

        -- TAQVERSIONMARKET
        INSERT INTO taqversionmarket
          (targetmarketkey, taqprojectkey, plstagecode, taqversionkey, 
           marketcode, marketsubcode, marketsub2code, marketgrowthpercent, sortorder, lastuserid, lastmaintdate)
        VALUES
          (@v_marketkey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, 
           COALESCE(@v_marketcode,0), COALESCE(@v_marketsubcode,0), COALESCE(@v_marketsub2code,0), 0, 
           @v_sortorder, @v_userid, getdate())        

        FETCH taqprojectsubjectcategory_cur INTO @v_marketcode, @v_marketsubcode, @v_marketsub2code
		    SELECT @v_sortorder = @v_sortorder + 1
      END

      CLOSE taqprojectsubjectcategory_cur
      DEALLOCATE taqprojectsubjectcategory_cur

    END
  END  
  
  
  -- TAQVERSIONSUBRIGHTS / TAQVERSIONSUBRIGHTSYEAR
  -- Loop through all version subrights
  DECLARE subrights_cur CURSOR FOR
    SELECT subrightskey, rightscode, authorpercent
    FROM taqversionsubrights
    WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion
    
  OPEN subrights_cur
  
  FETCH subrights_cur INTO @v_cur_subrightskey, @v_rightscode, @v_authorpercent

  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
    -- generate new subrightskey
    EXEC get_next_key @v_userid, @v_subrightskey OUTPUT
  
    -- TAQVERSIONSUBRIGHTS
    INSERT INTO taqversionsubrights
      (subrightskey, taqprojectkey, plstagecode, taqversionkey, 
       rightscode, authorpercent, lastuserid, lastmaintdate)
    VALUES
      (@v_subrightskey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, 
       @v_rightscode, @v_authorpercent, @v_userid, getdate())

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE subrights_cur
      DEALLOCATE subrights_cur    
      SET @o_error_desc = 'Could not insert into taqversionsubrights table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
    
    -- TAQVERSIONSUBRIGHTSYEAR
    INSERT INTO taqversionsubrightsyear
      (subrightskey, yearcode, amount, lastuserid, lastmaintdate)
    SELECT
      @v_subrightskey, yearcode, ROUND(amount, @v_num_decprecision), @v_userid, getdate()
    FROM taqversionsubrightsyear
    WHERE subrightskey = @v_cur_subrightskey

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE subrights_cur
      DEALLOCATE subrights_cur
      SET @o_error_desc = 'Could not insert into taqversionsubrightsyear table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END    
      
    FETCH subrights_cur INTO @v_cur_subrightskey, @v_rightscode, @v_authorpercent
  END
  
  CLOSE subrights_cur
  DEALLOCATE subrights_cur
    
  
  -- TAQVERSIONFORMAT / TAQVERSIONSPECITEMS / TAQVERSIONADDTLUNITS / TAQVERSIONADDTLUNITSYEAR / TAQVERSIONROYALTYSALESCHANNEL / TAQVERSIONROYALTYRATES
  -- TAQVERSIONSALESCHANNEL / TAQVERSIONSALESUNIT / TAQVERSIONFORMATYEAR / TAQVERSIONCOSTS / TAVERSIONINCOME
  
  -- Get the Up To Year value for the new version (default to the client default value in case no template was found and nothing was copied)  
  SELECT @v_count = COUNT(*)
  FROM taqversion
  WHERE taqprojectkey = @i_new_projectkey AND plstagecode = @i_new_plstage AND taqversionkey = @i_new_plversion
  
  SET @v_maxyearcode = @v_default_maxyearcode
  IF @v_count > 0
  BEGIN
    SELECT @v_maxyearcode = maxyearcode
    FROM taqversion
    WHERE taqprojectkey = @i_new_projectkey AND plstagecode = @i_new_plstage AND taqversionkey = @i_new_plversion

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Could not obtain maxyearcode value from taqversion table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
  END  
    
  DECLARE @FormatTable TABLE (
    versionformatkey INT,
    mediatypecode INT,
    mediatypesubcode INT,
    activeprice FLOAT,
    scaleselectioncode INT,
    charsperpage INT,
    formatpercentage FLOAT,
    description VARCHAR(2000),
    sharedposectionind TINYINT,
    bookkey INT
    )

  -- Loop through all project formats (taqprojecttitle records) - first part of UNION are all project formats (or work formats)
  -- that have a matching format on the template, second part of UNION are all project formats (or work formats) that don't exist on template  
  IF @v_copy_acq_project_data = 1
    INSERT INTO @FormatTable (versionformatkey, mediatypecode, mediatypesubcode, activeprice, scaleselectioncode, charsperpage, formatpercentage, description, sharedposectionind, bookkey)
      SELECT v.taqprojectformatkey versionformatkey, v.mediatypecode, v.mediatypesubcode, 
        CASE
          WHEN p.price > 0 THEN p.price
          ELSE v.activeprice
        END price, 
        v.scaleselectioncode, v.charsperpage, v.formatpercentage, v.description, v.sharedposectionind, 0 bookkey       
      FROM taqprojecttitle p 
        JOIN taqversionformat v ON v.taqprojectkey = @v_copyfrom_projectkey AND 
          v.plstagecode = @v_copyfrom_plstage AND 
          v.taqversionkey = @v_copyfrom_plversion AND
          v.mediatypecode = p.mediatypecode AND 
          v.mediatypesubcode = p.mediatypesubcode 
      WHERE p.taqprojectkey = @i_projectkey AND
        p.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2)  --Format
      UNION
      SELECT 0 versionformatkey, p.mediatypecode, p.mediatypesubcode, p.price, 
         NULL, NULL, 0, NULL, 0, 0
      FROM taqprojecttitle p 
      WHERE p.taqprojectkey = @i_projectkey AND 
        p.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 2) AND
        NOT EXISTS (SELECT * FROM taqversionformat v 
                    WHERE v.taqprojectkey = @v_copyfrom_projectkey AND 
                      v.plstagecode = @v_copyfrom_plstage AND 
                      v.taqversionkey = @v_copyfrom_plversion AND 
                      v.mediatypecode = p.mediatypecode AND
                      v.mediatypesubcode = p.mediatypesubcode)                     
                      
  ELSE IF @v_copy_work_project_data = 1
    INSERT INTO @FormatTable (versionformatkey, mediatypecode, mediatypesubcode, activeprice, scaleselectioncode, charsperpage, formatpercentage, description, sharedposectionind, bookkey)
      SELECT v.taqprojectformatkey versionformatkey, v.mediatypecode, v.mediatypesubcode, v.activeprice price, 
        v.scaleselectioncode, v.charsperpage, v.formatpercentage, v.description, v.sharedposectionind, p.bookkey
      FROM taqprojecttitle p 
        JOIN bookdetail bd ON p.bookkey = bd.bookkey
        JOIN taqversionformat v ON v.taqprojectkey = @v_copyfrom_projectkey AND 
          v.plstagecode = @v_copyfrom_plstage AND 
          v.taqversionkey = @v_copyfrom_plversion AND
          v.mediatypecode = bd.mediatypecode AND 
          v.mediatypesubcode = bd.mediatypesubcode 
      WHERE p.taqprojectkey = @i_projectkey AND 
        p.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 1) AND  --Title
        p.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 and qsicode = 1)  --Work
      UNION 
      SELECT 0 versionformatkey, bd.mediatypecode, bd.mediatypesubcode, NULL price, 
         NULL, NULL, 0, NULL, 0, 0
      FROM taqprojecttitle p, bookdetail bd
      WHERE p.bookkey = bd.bookkey AND
        p.taqprojectkey = @i_projectkey AND 
        p.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 1) AND
        p.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 and qsicode = 1) AND
        NOT EXISTS (SELECT * FROM taqversionformat v 
                    WHERE v.taqprojectkey = @v_copyfrom_projectkey AND 
                      v.plstagecode = @v_copyfrom_plstage AND 
                      v.taqversionkey = @v_copyfrom_plversion AND 
                      v.mediatypecode = bd.mediatypecode AND
                      v.mediatypesubcode = bd.mediatypesubcode)
  ELSE IF @v_copy_prtg_project_data = 1
  BEGIN
	-- For Printing project versions, the created format must match the format on the Printing project.
	-- Check if the template has the matching format.
    SELECT @v_prtg_media = bd.mediatypecode, @v_prtg_format = bd.mediatypesubcode 
    FROM taqprojecttitle t, bookdetail bd
    WHERE t.bookkey = bd.bookkey 
      AND t.taqprojectkey = @i_projectkey 
      AND t.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 7)  --Title Role=Printing Title 
      AND t.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 AND qsicode = 3) --Proj Role=Printing
          	
    SELECT @v_count = COUNT(*)
    FROM taqversionformat
    WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion
      AND mediatypecode = @v_prtg_media AND mediatypesubcode = @v_prtg_format
    
    IF @v_count > 0  --matching format exists on the template - copy all info for this format from the template
      INSERT INTO @FormatTable (versionformatkey, mediatypecode, mediatypesubcode, activeprice, scaleselectioncode, charsperpage, formatpercentage, description, sharedposectionind, bookkey)
        SELECT v.taqprojectformatkey versionformatkey, v.mediatypecode, v.mediatypesubcode, v.activeprice price, 
          v.scaleselectioncode, v.charsperpage, v.formatpercentage, v.description, v.sharedposectionind, p.bookkey
        FROM taqprojecttitle p 
          JOIN bookdetail bd ON p.bookkey = bd.bookkey
          JOIN taqversionformat v ON v.taqprojectkey = @v_copyfrom_projectkey AND 
            v.plstagecode = @v_copyfrom_plstage AND 
            v.taqversionkey = @v_copyfrom_plversion AND
            v.mediatypecode = bd.mediatypecode AND 
            v.mediatypesubcode = bd.mediatypesubcode 
        WHERE p.taqprojectkey = @i_projectkey AND 
          p.titlerolecode = (SELECT datacode FROM gentables WHERE tableid = 605 AND qsicode = 7) AND  --Printing Title
          p.projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 and qsicode = 3)  --Printing  
    ELSE	--Printing's format does not exist on the template - use Printing project's format and do not copy anything from template
      DECLARE formats_cur CURSOR FOR
        SELECT 0 versionformatkey, @v_prtg_media, @v_prtg_format, NULL price, NULL, NULL, 0, 0
  END
  ELSE
    -- Loop through all version formats
    INSERT INTO @FormatTable (versionformatkey, mediatypecode, mediatypesubcode, activeprice, scaleselectioncode, charsperpage, formatpercentage, description, sharedposectionind, bookkey)
      SELECT taqprojectformatkey versionformatkey, mediatypecode, mediatypesubcode, activeprice, 
         scaleselectioncode, charsperpage, formatpercentage, description, sharedposectionind, 0 bookkey
      FROM taqversionformat
      WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion

  -- Add any "shared cost" formats that are not already there
  INSERT INTO @FormatTable (versionformatkey, mediatypecode, mediatypesubcode, activeprice, scaleselectioncode, charsperpage, formatpercentage, description, sharedposectionind, bookkey)
    SELECT taqprojectformatkey versionformatkey, mediatypecode, mediatypesubcode, activeprice, 
        scaleselectioncode, charsperpage, formatpercentage, description, sharedposectionind, 0 bookkey
    FROM taqversionformat
    WHERE taqprojectkey = @v_copyfrom_projectkey AND plstagecode = @v_copyfrom_plstage AND taqversionkey = @v_copyfrom_plversion AND sharedposectionind = 1
      AND NOT EXISTS (SELECT 1 FROM @FormatTable WHERE versionformatkey = taqprojectformatkey)

  ----- BEGIN LOOP --------------------------------
      
  DECLARE formats_cur CURSOR FOR
  SELECT versionformatkey, mediatypecode, mediatypesubcode, activeprice, scaleselectioncode, charsperpage, formatpercentage, description, sharedposectionind, bookkey
  FROM @FormatTable

  OPEN formats_cur
  
  FETCH formats_cur
  INTO @v_cur_formatkey, @v_mediatype, @v_mediasubtype, @v_activeprice, @v_scaleselectcode, @v_charsperpage, @v_format_percent, @v_formatdesc, @v_sharedposectionind, @v_bookkey

  WHILE (@@FETCH_STATUS=0)
  BEGIN
  
    PRINT '@v_cur_formatkey: ' + CONVERT(VARCHAR, @v_cur_formatkey)
    
    -- When @v_cur_formatkey = 0, the format is coming from project/work (taqprojecttitle) and not from p&l version (taqversionformat), 
    -- so we must create the required taqversionformatyear records.
    SET @v_new_formatkey = 0
    IF @v_cur_formatkey = 0
    BEGIN
      -- generate new key for taqversion.taqprojectformatkey (version formatkey)
      EXECUTE get_next_key @v_userid, @v_new_formatkey OUTPUT
      
      PRINT 'NEW generated @v_new_formatkey: ' + CONVERT(VARCHAR, @v_new_formatkey)
      
      DECLARE year_cur CURSOR FOR 
        SELECT datacode, sortorder
        FROM gentables 
        WHERE tableid = 563
        ORDER BY sortorder

      OPEN year_cur
      
      FETCH year_cur INTO @v_yearcode, @v_yearnum
        
      WHILE @@fetch_status = 0
      BEGIN

        IF (@v_yearnum <= @v_maxyearcode)
        BEGIN
          -- ****** TAQVERSIONFORMATYEAR - must exist for each Format/Year *****
          EXECUTE get_next_key @v_userid, @v_newkey OUTPUT

          INSERT INTO taqversionformatyear 
            (taqversionformatyearkey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
             yearcode, lastuserid, lastmaintdate)
          VALUES
            (@v_newkey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey,
             @v_yearcode, @v_userid, getdate())

          SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
          IF @v_error <> 0 BEGIN
            SET @o_error_desc = 'INSERT into taqversionformatyear table failed (Error ' + cast(@v_error AS VARCHAR) + ').'
            CLOSE year_cur 
            DEALLOCATE year_cur 
            CLOSE formats_cur
            DEALLOCATE formats_cur
            GOTO RETURN_ERROR
          END
        END --IF (@v_yearnum <= @v_maxyearcode)
      
        FETCH year_cur INTO @v_yearcode, @v_yearnum
      END

      CLOSE year_cur 
      DEALLOCATE year_cur      
    END
    
    -- When copying from work project, get the best pagecount and best price from the work title 
    -- (to override the p&l template values obtained above)
    IF @v_copy_work_project_data = 1
    BEGIN
      SELECT @v_bookpages = dbo.get_BestPageCount(@v_bookkey, 1)
    
      SELECT @v_count = COUNT(*)
      FROM bookprice
      WHERE bookkey = @v_bookkey AND activeind = 1
        AND currencytypecode = (SELECT currencytypecode FROM filterpricetype WHERE filterkey = 7)
        AND pricetypecode = (SELECT pricetypecode FROM filterpricetype WHERE filterkey = 7) 

      IF @v_count > 0
      BEGIN
        SELECT @v_finalprice = finalprice, @v_budgetprice = budgetprice
        FROM bookprice
        WHERE bookkey = @v_bookkey AND activeind = 1
          AND currencytypecode = (SELECT currencytypecode FROM filterpricetype WHERE filterkey = 7)
          AND pricetypecode = (SELECT pricetypecode FROM filterpricetype WHERE filterkey = 7) 

        IF @v_finalprice > 0 
          SELECT @v_activeprice = @v_finalprice
        ELSE IF @v_budgetprice > 0
          SELECT @v_activeprice = @v_budgetprice
      END
    END --@v_copy_work_project_data = 1
    

    -- generate new taqprojectformatkey
    IF @v_new_formatkey = 0
      EXEC get_next_key @v_userid, @v_new_formatkey OUTPUT

    -- TAQVERSIONFORMAT  
    INSERT INTO taqversionformat
      (taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, mediatypecode, mediatypesubcode,
      activeprice, scaleselectioncode, charsperpage, formatpercentage, description, sharedposectionind, lastuserid, lastmaintdate)
    VALUES
      (@i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, @v_mediatype, @v_mediasubtype,
       @v_activeprice, @v_scaleselectcode, @v_charsperpage, @v_format_percent, @v_formatdesc, @v_sharedposectionind, @v_userid, getdate())

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Could not insert into taqversionformat table (Error ' + cast(@v_error AS VARCHAR) + ').'
      CLOSE formats_cur
      DEALLOCATE formats_cur
      GOTO RETURN_ERROR
    END
  
    EXEC qpl_copy_format @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, @v_cur_formatkey, 
      @v_activeprice, 2, @v_bookkey, @v_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
	
    IF @o_error_code = -1
      GOTO RETURN_ERROR
      
    EXEC qpl_create_prod_qty_specitem @v_new_formatkey, @v_userid, @o_error_code OUTPUT, @o_error_desc OUTPUT
    
    IF @o_error_code < 0
      GOTO RETURN_ERROR
      
    FETCH formats_cur
    INTO @v_cur_formatkey, @v_mediatype, @v_mediasubtype, @v_activeprice, @v_scaleselectcode, @v_charsperpage, @v_format_percent, @v_formatdesc, @v_sharedposectionind, @v_bookkey
  END
  
  CLOSE formats_cur
  DEALLOCATE formats_cur

  --Update production quantities incase copying from template with old data, or one that has not been calculated
  IF @v_prodqtyentrytypecode <> 1
  BEGIN
		EXEC qpl_update_production_quantities @i_new_projectkey, @i_new_plstage, @i_new_plversion, 'qsidba', @o_error_code OUTPUT, @o_error_desc OUTPUT
		
		IF @o_error_code = -1
			GOTO RETURN_ERROR
  END

  -- When creating version from template, no summary items may exist - create by recalculating all
  SELECT @v_count = COUNT(*)
  FROM taqplsummaryitems
  WHERE taqprojectkey = @i_new_projectkey AND plstagecode = @i_new_plstage AND taqversionkey = @i_new_plversion
    AND decimalvalue > 0
   
  IF @v_count = 0
  BEGIN
	-- This procedure will immediately recalculate all summary items for p&l levels set up on plsummaryitemrecalcorder table
	-- to procecess immediately (recalcorder=0) and push remaining summary items to background recalc
	EXEC qpl_process_immediate_recalc @i_new_projectkey, @i_new_plstage, @i_new_plversion, 'FIREBRAND', @o_error_code, @o_error_desc

    IF @o_error_code <> 0
    BEGIN
      SET @o_error_desc = 'Could not recalculate P&L summary items (new projectkey=' + CONVERT(VARCHAR, @i_new_projectkey)
      RETURN
    END
  END
  
  -- When copying from template, check if input currency on the current project matches the input currency on template.
  -- Warning is needed if the input currencies don't match.
  IF @v_copyfrom_template = 1 AND @v_templatekey > 0
  BEGIN
    SELECT @v_template_currency = COALESCE(plenteredcurrency,0)
    FROM taqproject
    WHERE taqprojectkey = @v_templatekey
    
    IF @v_template_currency <> @v_input_currency
    BEGIN
      SET @v_message = 'WARNING. P&L Template input currency does not match input currency on the project.'
      SET @o_error_desc = @v_message
      GOTO RETURN_WARNING
    END
  END
  
  -- ****** TEMPLATE NOT FOUND - create a blank version and return error message ******
  IF @v_copyfrom_template = 1 AND @v_templatekey = 0
  BEGIN
    INSERT INTO taqversion 
      (taqprojectkey, plstagecode, taqversionkey, taqversiondesc, pltypecode, pltypesubcode, releasestrategycode, 
       generatedetailsalesunitsind, grosssalesunitind, saleschannellevelind, avgroyaltyenteredind, 
       maxyearcode, plstatuscode, lastuserid, lastmaintdate, versionformats, taqversiontype, prodqtyentrytypecode)
    VALUES
      (@i_new_projectkey, @i_new_plstage, @i_new_plversion, @i_versiondesc, @i_pltype, @i_plsubtype, @i_relstrategy, 
       @v_default_generateind, @v_default_grossunitsind, @v_default_channellevelind, @v_default_enterroyaltyind, 
       @v_default_maxyearcode, @v_initialstatus, @v_userid, getdate(), @v_versionformatsstring, @v_taqversiontype, @v_prodqtyentrytypecode)

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Insert into taqversion table failed (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
          
    COMMIT
    SET @v_isopentrans = 0
    
    -- Get the Project Orgentry description at the required P&L Template Orglevel
    SELECT @v_description = orgentrydesc
    FROM taqprojectorgentry po, orgentry o
    WHERE po.orglevelkey = o.orglevelkey AND
      po.orgentrykey = o.orgentrykey AND
      po.taqprojectkey = @i_projectkey AND 
      po.orglevelkey = @v_template_orglevel
    
    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
      SET @o_error_desc = 'Could not access taqprojectorgentry/orgentry tables to get Orgentry description.'
      GOTO RETURN_ERROR
    END
        
    -- **** Build the info message to be returned as error ****
    SET @v_message = 'WARNING. No active P&L Template exists for:<newline>'
    
    IF @v_orgleveldesc <> ' '
      SET @v_message = @v_message + '  ' + @v_orgleveldesc + ' -'
      
    SET @v_message = @v_message + '  ' + @v_description + '<newline>'

    -- Get P&L Type description
    SELECT @v_description = datadesc
    FROM gentables
    WHERE tableid = 566 AND datacode = @i_pltype

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
      SET @o_error_desc = 'Could not access gentables to get P&L Type description.'
      GOTO RETURN_ERROR
    END

    SET @v_message = @v_message + '  P&L Type - ' + @v_description
    
    IF @i_plsubtype > 0
    BEGIN
      -- Get P&L SubType description
      SELECT @v_description = datadesc
      FROM subgentables
      WHERE tableid = 566 AND datacode = @i_pltype AND datasubcode = @i_plsubtype

      SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
      IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
        SET @o_error_desc = 'Could not access subgentables to get P&L SubType description.'
        GOTO RETURN_ERROR
      END

      SET @v_message = @v_message + ' / ' + @v_description
    END

    -- Get Release Strategy description
    SELECT @v_description = datadesc
    FROM gentables
    WHERE tableid = 567 AND datacode = @i_relstrategy

    SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
    IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
      SET @o_error_desc = 'Could not access gentables to get Release Strategy description.'
      GOTO RETURN_ERROR
    END

    SET @v_message = @v_message + '<newline>  Release Strategy - ' + @v_description
    SET @v_message = @v_message + '<newline><newline>Creating a blank P&L Version.'
    
    SET @o_error_desc = @v_message
    GOTO RETURN_WARNING
  END
    
  IF @v_isopentrans = 1
    COMMIT
    
  RETURN  


RETURN_ERROR:  
  IF @v_isopentrans = 1
    ROLLBACK
    
  SET @o_error_code = -1
  RETURN
  
  
RETURN_WARNING:
  IF @v_isopentrans = 1
    COMMIT

  SET @o_error_code = -2
  RETURN  
    
END
GO

GRANT EXEC ON qpl_create_new_version TO PUBLIC
GO
