IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'qproject_transmit_to_tmm')
  BEGIN
    PRINT 'Dropping Procedure qproject_transmit_to_tmm'
    DROP  Procedure  qproject_transmit_to_tmm
  END
GO

PRINT 'Creating Procedure qproject_transmit_to_tmm'
GO

CREATE PROCEDURE [dbo].[qproject_transmit_to_tmm]
 (@i_projectkey         integer,
  @i_process_contracts  integer,
  @i_process_titles     integer,
  @i_userkey            integer,
  @i_validate_only      integer,
  @i_propagateind       tinyint,
  @o_work_projectkey    integer output,
  @o_error_code         integer output,
  @o_error_desc         varchar(2000) output)
AS

/*********************************************************************************************************************
**  Name: qproject_transmit_to_tmm
**              
**    Parameters:
**    Input              
**    ----------         
**    projectkey - Key of Project Being Processed - Required
**    process_contracts - Flag that determines if Contracts should be transmitted to TMM - Required (null will be considered 0)
**    process_titles - Flag that determines if Titles should be transmitted to TMM - Required (null will be considered 0)
**    userkey - userkey of user transmitting to TMM - NOT Required 
**    
**    Output
**    -----------
**    error_code - error code
**    error_desc - error message - empty if No Error
**
**    Auth: Alan Katzen
**    Date: 5/3/05
*********************************************************************************************************************
**  Change History
**********************************************************************************************************************
**  Date:   Author: Description:
**  -----   ------  -------------------------------------------
**  4/7/09  Kusum   Alter procedure to access titles directly on the web after the send to TMM without having to go
**                  through the setup process on desktop TMM (Case# 10785 - specs attached in case)
**  8/7/09  Kate    Case 10799 - Based on clientoption 75 (if 0), automatically apply default template at the end.
**  1/12/10 Jon     Case 11794 - Based on clientoption 72 (if 0), -if optionvalue = 0 TMM is desired(bookdates), if 1 then use TMMWEB(taqprojecttask)     
**  12/11/14 Uday   Case 30701 - Copy Specs after approving a TAQ
**  02/18/15 Kusum Case 31553 - Generate job number alpha and save to printing row
********************************************************************************************************************/
  
  -- verify projectkey is filled in
  IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to transmit to TMM: projectkey is empty.'
    RETURN
  END 

  DECLARE @error_var    INT,
          @rowcount_var INT,
          @errormsg_var varchar(2000),
          @warningmsg_var varchar(2000),
          @is_error_var TINYINT,
          @is_warning_var TINYINT,
          @process_contracts_var INT,
          @process_titles_var INT,
          @count_var INT,
          @contractkey_var INT,
          @bookkey_var INT,
          @printingkey_var INT,
          @lastmaintdate_var DATETIME,
          @lastuserid_var VARCHAR(30),
	        @taqprojectformatkey_var int,
	        @seasoncode_var int,
	        @seasonfirmind_var tinyint,
	        @mediatypecode_var int,
    	    @mediatypesubcode_var int,
	        @discountcode_var smallint,
	        @price_var numeric(9,2),
	        @initialrun_var int,
	        @primaryproductrequiredforsendtotmm_var int,
		      @usewebscheduling int,
		      @taqtaskkey int,
	        @projectdollars_var numeric(15,2),
	        @marketingplancode_var int,
	        @primaryformatind_var tinyint,
	        @isbn_var varchar(13),
	        @isbn10_var varchar(10),
	        @ean_var varchar(17),
	        @ean13_var varchar(13),
	        @gtin_var varchar(19),
	        @gtin14_var varchar(14),
	        @lccn_var varchar(50),
	        @dsmarc_var varchar(50),
	        @itemnumber_var varchar(20),
	        @upc_var varchar(50),
	        @format_bookkey_var int,
	        @primary_bookkey_var int,
	        @formatdesc_var varchar(120),
	        @isbnprefixcode_var int,
	        @eanprefixcode_var int,
	        @projecttitle_var varchar(255),
	        @projectsubtitle_var varchar(255),
	        @projecttype_var int,
	        @projecteditionnumcode_var int,
	        @projectseriescode_var int,
	        @projectstatuscode_var int,
	        @projecttitleprefix_var varchar(15),
	        @projecteditiontypecode_var int,
    	    @projecteditiondesc_var varchar(100),
    	    @additionaleditioninfo_var varchar(100),
	        @projectvolumenumber_var int,
	        @termsofagreement_var varchar(255),
          @projectcontractkey_var int,
          @taqelementkey_var int,
          @elementkey_var int,
          @elementtypecode_var int,
          @elementtypesubcode_var int,
          @taqelementsortorder_var int,
          @elementname_var varchar(20),
          @elementdesc_var varchar(255),
          @taskkey_var int,
          @pricekey_var int,
          @titlestatuscode_var int,
          @newprojectstatuscode_var int,
          @globalcontactkey_var int,
          @globalcontactkey2_var int,
          @rolecode_var int,
          @rolecode2_var int,
          @scheduleind_var tinyint,
          @stagecode_var int,
          @duration_var int,
          @activedate_var datetime,
          @keyind_var tinyint,
          @decisioncode_var smallint,
          @authortypecode_var int,
          @primaryind_var int,
          @sortorder_var int,
          @datetypecode_var int,
          @estdate_var datetime,
          @actualind_var int,
          @dup_date_count_var int,
          @bookcontactkey_var int,
          @participantnote_var varchar(2000),
          @taqprojectcontactkey_var int,
          @setuprequiredforsendtotmm_var int,
          @numberofrequiredorglevels_var int,
          @numberoforglevels_var int,
          @sendtotmmtitlestatus_var int,
          @orgentrykey_var		int,
          @orglevelkey_var   int,
          @v_template_bookkey  INT,
          @v_template_printingkey  INT,
          @v_work_projectkey INT,
          @v_linkworktotitleind INT,
          @v_linked_projectkey INT,
          @v_linked_bookkey INT,
          @v_linked_printingkey INT,
          @v_taqtotmmind INT,
          @TranName VARCHAR(20),
          @new_elementkey_var int,
          @prodnum_projectkey_var int,
          @productnumberkey_var int,
          @new_productnumberkey_var int,
          @filelocationgeneratedkey_var int,
          @new_filelocationgeneratedkey_var int,
          @taqtaskkey_var int,
          @new_taqtaskkey int,
          @new_taqprojectformatkey int,
          @v_work_project_role int,
          @v_title_title_role int,
          @v_templatekey int,
          --<added columns on taqprojecttitle for case 14197>
          @v_project_role_code int,
          @v_competitivetitlesassotypecode int,
          @v_comparativetitlesassotypecode int,
          @v_taqprojecttitle_projectrolecode int,
          @v_taqprojecttitle_titlerolecode int,
          @v_Commentkey1 int,
          @v_Commentkey2 int,
          --</added for case 14197
          @v_org_count_max int,
          @v_org_count int,
          @v_title_cnt int,
          @v_work_cnt int,
          @v_loop_cnt int,
          @v_loop_total int,
          @v_readerrolecode int,
          @v_manuscriptcode int, 
          @v_iterationcode int,
          @v_taqelementtypecode int,
          @v_taqelementtypesubcode int,
          @v_taqprojectcontactrolekey int,
          @v_globalcontactkey int,
          @v_initial_status INT,
          @v_datadesc VARCHAR(120),
          @v_client_option  INT,
          @v_proc_name  VARCHAR(255),
          @v_sql NVARCHAR(500),
          @v_veriftype	INT,
          @v_verifdesc	VARCHAR(120),
          @v_history_order INT,
		      @autosetpriceactiveind	INT,
		      @v_optionvalue	INT,
          @v_startdate  DATETIME,
          @v_startdateactualind TINYINT,
          @v_lag  INT,
          @v_title_task_cnt INT,
          @v_work_task_cnt INT,
          @taqtaskdatetypecode_var  INT,
          @scheduleind_task_var  TINYINT,
          @lag_task_var  INT,
          @sortorder_task_var  INT,
          @v_default_prodnum_col  varchar(50),
          @v_exchangerate FLOAT,
          @v_exchangeratelockind TINYINT,
          @v_plstagecode  INT,
   		  @v_copy_elementkey int,
		  @v_new_elementkey int,
		  @taqprojecttaskoverride_rowcount int,
		  @insert_in_taqprojecttask bit, 
		  @v_taqtaskkey int,
		  @o_taqtaskkey   int,
		  @o_returncode   int,
          @o_restrictioncode int,
		  @v_restriction_value_title int,
		  @v_restriction_value_work  int,
		  @paymentamt_var NUMERIC(9, 2),
		  @taqtaskqty_var INT,
		  @transactionkey_var INT,
		  @taqtasknote_var VARCHAR(2000),
          @v_work_loop	BIT,
          @v_itemtypecode int,
          @v_usageclasscode int,
          @v_count_taqprojecttask INT,
          @v_projectkey INT,
		  @v_itemtype_qsicode INT,
		  @v_usageclass_qsicode INT,
		  @v_taqprojectformatkey INT,
		  @o_jobnumberseq  CHAR(7) ,
		 @v_generate_jobnumberalpha INT                     

		 CREATE TABLE #TempTaqprojectaskKeysOldNew 
		   (OldTaqtaskkey INT,    
			NewTaqtaskkey INT,
			BookKey INT,
			PrintingKey INT,
			WorkKey INT)          
                   
  SET @o_error_code = 0
  SET @o_error_desc = ''
  SET @process_contracts_var = @i_process_contracts
  SET @process_titles_var = @i_process_titles
  SET @is_warning_var = 0
  SET @warningmsg_var = ''
  SET @TranName = 'SentToTmm_tran';
  SET @v_projectkey = 0

  IF @i_projectkey = 0 OR @i_projectkey is null BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to approve project: Invalid Projectkey.'
    RETURN
  END 

  -- if flags are not filled in, just set them to 0
  IF @process_contracts_var IS NULL OR @process_contracts_var < 0 BEGIN
    SET @process_contracts_var = 0
  END 

  IF @process_titles_var IS NULL OR @process_titles_var < 0 BEGIN
    SET @process_titles_var = 0
  END 

  IF @process_contracts_var = 0 AND @process_titles_var = 0 BEGIN
    SET @o_error_code = 1
    SET @o_error_desc = 'Project not Approved: all flags are set to NOT process.'
    RETURN
  END 

  -- if project status is sent to tmm OR cancelled then don't resend
  IF @process_contracts_var = 1 OR @process_titles_var = 1 BEGIN
    SELECT @count_var = count(*)
      FROM gentables g, taqproject p
     WHERE p.taqprojectstatuscode = g.datacode and
           g.tableid = 522 and 
           g.qsicode in (1,2) and
           p.taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Error accessing project status on taqproject (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
    IF @count_var > 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project due to the Project Status.'
      RETURN
    END 
  END

  --check client option id = 81 (isbn Required for Send to TMM Process) -if optionvalue = 0 no isbn is required 
  SELECT @primaryproductrequiredforsendtotmm_var = optionvalue
  FROM clientoptions
  WHERE optionid = 81

  --check client option id = 72 (UseWebScheduling) -if optionvalue = 0 TMM is desired(bookdates), if 1 then use TMMWEB(taqprojecttask) 
  SELECT @usewebscheduling = optionvalue
  FROM clientoptions
  WHERE optionid = 72
 
  -- check client option id = 99 (Auto Set Price Active Ind) - if optionvalue = 0 no Price Active Ind and Dates validation is needed
  SELECT @autosetpriceactiveind = optionvalue
	  FROM clientoptions
	 WHERE optionid = 99
	 
  SELECT @v_itemtypecode = datacode, @v_usageclasscode = datasubcode
	  FROM subgentables
	 WHERE tableid = 550 and qsicode = 26 
	 
    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Error getting title Item Type and Usage Class.'
      RETURN
    END 	 

  -- There must be 1 primary format
  IF @process_contracts_var = 1 OR @process_titles_var = 1 BEGIN
    SELECT @count_var = count(*) 
      FROM taqprojecttitle
     WHERE primaryformatind = 1 and
           taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Error accessing taqprojecttitle table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
    IF @count_var <= 0 BEGIN
      -- No Primary Format - Unable to Continue
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: No Primary Format Exists for Project.'
      RETURN
    END 
  END
  
  -- There Must Be At Least One Primary Author on the Project 
  IF @process_contracts_var = 1 OR @process_titles_var = 1 BEGIN
    SELECT @count_var = count(*)
      FROM taqprojectcontactrole r
     WHERE r.authortypecode > 0 and
           r.primaryind > 0 and
           r.taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Error accessing bookauthor table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 

    IF @count_var <= 0 BEGIN
      -- Must be at least one primary author - Unable to Continue
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Must be at least one primary author.'
      RETURN
    END 
  END

  IF @i_userkey >= 0 BEGIN
    -- get userid from qsiusers
    SELECT @lastuserid_var = userid
      FROM qsiusers
     WHERE userkey = @i_userkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Error accessing qsiusers table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
    IF @rowcount_var <= 0 BEGIN
      -- User Not Found - just use default userid
      SET @lastuserid_var = 'ProjectToTmm'
    END 
  END
  ELSE BEGIN
    SET @lastuserid_var = 'ProjectToTmm'
  END

  --check client option id = 75 (Setup Required for Send to TMM Process) -if optionvalue = 0 need to validate that all orglevels for
  --project are entered 
  SELECT @setuprequiredforsendtotmm_var = optionvalue
    FROM clientoptions
   WHERE optionid = 75

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
     SET @o_error_code = -1
     SET @o_error_desc = 'Unable to approve project: Error accessing clientoptions for optionid 75 (' + cast(@error_var AS VARCHAR) + ').'
     RETURN
  END 
  IF @rowcount_var <= 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Optionid 75 (Setup Required for approve project Process) not found on clientoptions (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
  END

  IF @setuprequiredforsendtotmm_var = 0 BEGIN
    SELECT @numberofrequiredorglevels_var = count(orglevelkey)
    FROM orglevel
    WHERE Upper(deletestatus) = 'N'

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Error accessing orglevel table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
    IF @rowcount_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Unable to determine number of Group Levels required for project (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END

    SELECT @numberoforglevels_var = count(orglevelkey)
    FROM taqprojectorgentry
    WHERE taqprojectkey = @i_projectkey

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Error accessing taqprojectorgentry table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
    IF @rowcount_var < 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Unable to determine number of existing Group Levels for project (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END

    IF @numberoforglevels_var IS NULL BEGIN
      SET @numberoforglevels_var = 0
    END 

    IF @numberofrequiredorglevels_var IS NULL BEGIN
      SET @numberofrequiredorglevels_var = 0
    END 

    IF @numberoforglevels_var < @numberofrequiredorglevels_var BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: All Group Levels are required.'
      RETURN
    END
  END

  -- get projectstatuscode
  SET @newprojectstatuscode_var = 0
  IF @process_titles_var = 1 BEGIN
    -- set status to 'Acquisition Complete'
    SELECT @newprojectstatuscode_var = datacode
      FROM gentables
     WHERE tableid = 522 and 
           qsicode = 1

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Error accessing gentables tableid 522 (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
    IF @rowcount_var <= 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Acquisition Complete Status not found on gentables tableid 522 (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END 
  END

  -- get titlestatuscode
  SET @titlestatuscode_var = 0
  IF @process_titles_var = 1 BEGIN
	  IF @setuprequiredforsendtotmm_var = 1 BEGIN
		 -- set status to 'Title Requested'
		 SELECT @titlestatuscode_var = datacode
			FROM gentables
		  WHERE tableid = 149 and 
				  qsicode = 2
	
		 SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		 IF @error_var <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to approve project: Error accessing gentables tableid 149 (' + cast(@error_var AS VARCHAR) + ').'
			RETURN
		 END 
		 IF @rowcount_var <= 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to approve project: Title Requested Status not found on gentables tableid 149 (' + cast(@error_var AS VARCHAR) + ').'
			RETURN
		 END 
	  END
     ELSE BEGIN
	   -- set status to clientdefaultvalue for client optionid 2 - Null is an acceptable value 
		SELECT @sendtotmmtitlestatus_var = clientdefaultvalue
        FROM clientdefaults
       WHERE clientdefaultid = 2
     
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		 IF @error_var <> 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to approve project: Error accessing clientdefaults for defaultid 2 (' + cast(@error_var AS VARCHAR) + ').'
			RETURN
		 END 
		 IF @rowcount_var <= 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to approve project: Default Initial Title Status defaultid 2 not found on clientdefaults (' + cast(@error_var AS VARCHAR) + ').'
			RETURN
		 END 	

		 SET @titlestatuscode_var = @sendtotmmtitlestatus_var
     END
   END
  ELSE BEGIN
  IF @process_contracts_var = 1 BEGIN
      -- set status to 'Advance Contract Transmitted'
      SELECT @titlestatuscode_var = datacode
        FROM gentables
       WHERE tableid = 149 and 
             qsicode = 1

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to approve project: Error accessing gentables tableid 149 (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END 
      IF @rowcount_var <= 0 BEGIN
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to approve project: Advance Contract Transmitted Status not found on gentables tableid 149 (' + cast(@error_var AS VARCHAR) + ').'
        RETURN
      END 
    END
  END
  
  -- check if we are validating only
  IF @i_validate_only = 1 BEGIN
    SET @o_error_code = 0
    SET @o_error_desc = ''
    RETURN
  END
  
  -- Only require the primary product # if the client option is set to 1 (default)
  -- Check after validate only section in case popup wizard is used to setup isbns
  IF (@primaryproductrequiredforsendtotmm_var = 1)
  BEGIN
    -- use productnumlocation table to determine default productidtype
    SELECT @v_default_prodnum_col = columnname 
    FROM productnumlocation
    WHERE productnumlockey = 1

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 or @rowcount_var = 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Error accessing productnumlocation table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN 
    END

    SET @v_default_prodnum_col = LOWER(@v_default_prodnum_col)

    IF @v_default_prodnum_col = 'ean' BEGIN
      SELECT @count_var = count(*)
        FROM taqprojecttitle
       WHERE (ean IS NULL OR rtrim(ltrim(ean)) = '') AND taqprojectkey = @i_projectkey AND projectrolecode = 2
         AND titlerolecode = 2
    END
    
    IF @v_default_prodnum_col = 'ean13' BEGIN
      SELECT @count_var = count(*)
        FROM taqprojecttitle
       WHERE (ean13 IS NULL OR rtrim(ltrim(ean13)) = '') AND taqprojectkey = @i_projectkey AND projectrolecode = 2
         AND titlerolecode = 2
    END      

    IF @v_default_prodnum_col = 'isbn' BEGIN
      SELECT @count_var = count(*)
        FROM taqprojecttitle
       WHERE (isbn IS NULL OR rtrim(ltrim(isbn)) = '') AND taqprojectkey = @i_projectkey AND projectrolecode = 2
         AND titlerolecode = 2
    END
    
    IF @v_default_prodnum_col = 'gtin' BEGIN
      SELECT @count_var = count(*)
        FROM taqprojecttitle
       WHERE (gtin IS NULL OR rtrim(ltrim(gtin)) = '') AND taqprojectkey = @i_projectkey AND projectrolecode = 2
         AND titlerolecode = 2
    END
    
    IF @v_default_prodnum_col = 'upc' BEGIN
      SELECT @count_var = count(*)
        FROM taqprojecttitle
       WHERE (upc IS NULL OR rtrim(ltrim(upc)) = '') AND taqprojectkey = @i_projectkey AND projectrolecode = 2
         AND titlerolecode = 2
    END
    
    IF @v_default_prodnum_col = 'lccn' BEGIN
      SELECT @count_var = count(*)
        FROM taqprojecttitle
       WHERE (lccn IS NULL OR rtrim(ltrim(lccn)) = '') AND taqprojectkey = @i_projectkey AND projectrolecode = 2
         AND titlerolecode = 2
    END
    
    IF @v_default_prodnum_col = 'dsmarc' BEGIN
      SELECT @count_var = count(*)
        FROM taqprojecttitle
       WHERE (dsmarc IS NULL OR rtrim(ltrim(dsmarc)) = '') AND taqprojectkey = @i_projectkey AND projectrolecode = 2
         AND titlerolecode = 2
    END             
    
    IF @v_default_prodnum_col = 'itemnumber' BEGIN
      SELECT @count_var = count(*)
        FROM taqprojecttitle
       WHERE (itemnumber IS NULL OR rtrim(ltrim(itemnumber)) = '') AND taqprojectkey = @i_projectkey AND projectrolecode = 2
         AND titlerolecode = 2
    END        

    SELECT @error_var = @@ERROR,@rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to approve project: Error accessing taqprojecttitle table (' + cast(@error_var AS VARCHAR) + ').'
      RETURN
    END

    IF @count_var > 0
      BEGIN
        -- At least one format does not have an isbn assigned to it - Unable to Continue
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to approve project: All formats on the project must have an ' + upper(@v_default_prodnum_col)+ ' assigned to it.'
        RETURN
      END
  END
  
  -- need to create Work Project before creating titles
  SET @v_work_projectkey = 0
  SET @o_work_projectkey = 0
  
  SELECT @projecttitle_var = taqprojecttitle
    FROM taqproject
   WHERE taqprojectkey = @i_projectkey
   
  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to approve project: Error accessing taqproject table.'
    RETURN
  END 
  
  BEGIN TRANSACTION @TranName

  exec qproject_create_work @i_projectkey,0,@lastuserid_var,@projecttitle_var,@v_work_projectkey output,@o_error_code output,@o_error_desc output
  
  IF @o_error_code < 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to approve project (error creating work): ' + @o_error_desc + '.'
    rollback TRANSACTION @TranName
    RETURN
  END
    
  --PRINT '@v_work_projectkey: ' + convert(varchar, @v_work_projectkey)
    
  IF @v_work_projectkey is null OR @v_work_projectkey <= 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to approve project (error creating work): New Projectkey is empty.'
    rollback TRANSACTION @TranName
    RETURN
  END

  SET @o_work_projectkey = @v_work_projectkey
  
  SET @contractkey_var = 0
  SET @bookkey_var = 0
  SET @printingkey_var = 1
  SET @primary_bookkey_var = 0

  SELECT @v_work_project_role = datacode
    FROM gentables
   WHERE tableid = 604
     and qsicode = 1
     
  SELECT @v_project_role_code = datacode
    FROM gentables
   WHERE tableid = 604
     and qsicode = 2

  SELECT @v_competitivetitlesassotypecode = datacode
    FROM gentables g 
   WHERE tableid = 440
     and qsicode = 17
     
  SELECT @v_comparativetitlesassotypecode = datacode
    FROM gentables g 
   WHERE tableid = 440
     and qsicode = 3  

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to approve project: Error getting work project role.'
    RETURN
  END 
     
  SELECT @v_title_title_role = datacode
    FROM gentables
   WHERE tableid = 605
     and qsicode = 1

  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
  IF @error_var <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to approve project: Error getting title title role.'
    RETURN
  END 
    
  --PRINT '-- project_format_cur - for work'
  --PRINT '@i_projectkey: ' + convert(varchar, @i_projectkey)
   
  -- Cursor to obtain Project and Project Format Info
  DECLARE project_format_cur CURSOR FOR 
   SELECT COALESCE(f.taqprojectformatkey,0),f.seasoncode,f.seasonfirmind,f.mediatypecode,
	      f.mediatypesubcode,f.discountcode,f.price,f.initialrun,	f.projectdollars,
	      f.marketingplancode,f.primaryformatind,f.isbn,f.isbn10,f.ean,f.ean13,f.gtin,
	      COALESCE(f.bookkey,0),f.taqprojectformatdesc,f.isbnprefixcode,p.taqprojecttitle,p.taqprojectsubtitle,
        p.taqprojecttype,p.taqprojecteditionnumcode,p.taqprojectseriescode,p.taqprojectstatuscode,
        p.taqprojecttitleprefix,p.taqprojecteditiontypecode,p.taqprojecteditiondesc,
	      p.taqprojectvolumenumber,p.termsofagreement,COALESCE(c.contractkey,0) contractkey,
        f.eanprefixcode,f.gtin14,f.lccn,f.dsmarc,f.itemnumber,f.upc,p.additionaleditioninfo,
       COALESCE( f.templatekey,0)
     FROM taqproject p 
          LEFT OUTER JOIN taqprojectcontract c ON p.taqprojectkey = c.taqprojectkey,
          taqprojecttitle f
    WHERE f.taqprojectkey = p.taqprojectkey AND
          f.taqprojectkey = @i_projectkey AND  
          f.projectrolecode = 2 AND 
          f.titlerolecode = 2
  ORDER BY f.primaryformatind DESC, f.mediatypecode, f.taqprojectformatdesc

  OPEN project_format_cur 

  FETCH project_format_cur 
  INTO @taqprojectformatkey_var,@seasoncode_var,@seasonfirmind_var,@mediatypecode_var,
    @mediatypesubcode_var,@discountcode_var,@price_var,@initialrun_var,@projectdollars_var,
    @marketingplancode_var,@primaryformatind_var,@isbn_var,@isbn10_var,@ean_var,@ean13_var,
    @gtin_var,@format_bookkey_var,@formatdesc_var,@isbnprefixcode_var,@projecttitle_var,
    @projectsubtitle_var,@projecttype_var,@projecteditionnumcode_var,@projectseriescode_var,
    @projectstatuscode_var,@projecttitleprefix_var,@projecteditiontypecode_var,@projecteditiondesc_var,
    @projectvolumenumber_var,@termsofagreement_var,@projectcontractkey_var,@eanprefixcode_var,@gtin14_var,
    @lccn_var,@dsmarc_var,@itemnumber_var,@upc_var,@additionaleditioninfo_var,@v_templatekey

  WHILE @@fetch_status = 0 BEGIN
    --PRINT 'Title: ' + @projecttitle_var
    --PRINT 'Format: ' + cast(@mediatypecode_var as varchar) + '/' + cast(@mediatypesubcode_var as varchar)
    --PRINT '@v_templatekey: '+ convert(varchar, @v_templatekey)

    SET @errormsg_var = ''
    SET @is_error_var = 0

    -- Take care of keys
    -- contractkey
    IF @projectcontractkey_var > 0 BEGIN
      SET @contractkey_var = @projectcontractkey_var
    END
    ELSE BEGIN
      -- Generate contractkey
      execute get_next_key 'QSIADMIN',@contractkey_var OUTPUT
    END
    -- bookkey
    IF @format_bookkey_var > 0 BEGIN
      SET @bookkey_var = @format_bookkey_var
    END
    ELSE BEGIN
      -- Generate bookkey
      execute get_next_key 'QSIADMIN',@bookkey_var OUTPUT
    END
    -- Save Primary Format Bookkey to Be Used Later
    -- Note: There Must be 1 (and only 1) Primary Format.  
    --       We sorted to make the primary format the first one processed.  
    IF @primaryformatind_var = 1 BEGIN
      SET @primary_bookkey_var = @bookkey_var
      
      -- set workkey on taqproject with primary bookkey
      UPDATE taqproject
         SET workkey = @primary_bookkey_var
       WHERE taqprojectkey = @v_work_projectkey 

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to approve project: Error updating taqproject table (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END      
    END

    -- Some Book Tables Need to be Processed for Both Contracts and Titles
    IF @process_contracts_var = 1 OR @process_titles_var = 1 BEGIN
      IF @format_bookkey_var > 0 BEGIN
        --PRINT 'Update...'
        -- Book already exists for this format - just update the data
        -- Book
        UPDATE book
           SET title=@projecttitle_var,subtitle=@projectsubtitle_var,standardind='N',workkey=@primary_bookkey_var,
               linklevelcode=CASE WHEN @primaryformatind_var = 1 THEN 10 ELSE 20 END,
               titlestatuscode=@titlestatuscode_var,primarycontractkey=@contractkey_var,lastuserid=@lastuserid_var,
               lastmaintdate=getdate(),propagatefromprimarycode=CASE WHEN @primaryformatind_var = 1 THEN 0 ELSE 1 END,
               propagatefrombookkey=CASE WHEN @primaryformatind_var = 1 THEN NULL ELSE CASE WHEN @i_propagateind = 1 THEN @primary_bookkey_var ELSE NULL END END
         WHERE bookkey = @bookkey_var

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project: Error updating book table (' + cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END 
        -- bookdetail
        UPDATE bookdetail
           SET mediatypecode=@mediatypecode_var,mediatypesubcode=@mediatypesubcode_var,
               seriescode=@projectseriescode_var,titleprefix=@projecttitleprefix_var,
               volumenumber=@projectvolumenumber_var,lastuserid=@lastuserid_var,lastmaintdate=getdate(),
               editioncode=@projecteditiontypecode_var,discountcode=@discountcode_var,
               editiondescription=@projecteditiondesc_var,editionnumber=@projecteditionnumcode_var,
               additionaleditinfo=@additionaleditioninfo_var
         WHERE bookkey = @bookkey_var

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project: Error updating bookdetail table (' + cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END 
        -- printing
        UPDATE printing
           SET tentativeqty=@initialrun_var,printingnum=1,
               seasonkey=CASE WHEN @seasonfirmind_var = 1 THEN @seasoncode_var END,
               estseasonkey=CASE WHEN @seasonfirmind_var = 0 OR @seasonfirmind_var IS NULL THEN @seasoncode_var END,
               lastuserid=@lastuserid_var,lastmaintdate=getdate(), printingjob=1
         WHERE bookkey = @bookkey_var and
               printingkey = @printingkey_var

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project: Error updating printing table (' + cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END 
        -- isbn
        -- bookauthor
        -- bookorgentry
      END
      ELSE BEGIN
        --PRINT 'Insert...'
        -- Book
        INSERT INTO book (bookkey,title,subtitle,standardind,workkey,linklevelcode,
                primarycontractkey,titlestatuscode,lastuserid,lastmaintdate,propagatefromprimarycode,
                propagatefrombookkey,creationdate)
        VALUES (@bookkey_var,@projecttitle_var,@projectsubtitle_var,'N',@primary_bookkey_var,
                CASE WHEN @primaryformatind_var = 1 THEN 10 ELSE 20 END,@contractkey_var,@titlestatuscode_var,
                @lastuserid_var,getdate(),CASE WHEN @primaryformatind_var = 1 THEN 0 ELSE 1 END,
                CASE WHEN @primaryformatind_var = 1 THEN NULL ELSE CASE WHEN @i_propagateind = 1 THEN @primary_bookkey_var ELSE NULL END END,
                getdate())

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project: Error inserting into book table (' + cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END 
        -- bookdetail
        INSERT INTO bookdetail (bookkey,mediatypecode,mediatypesubcode,seriescode,titleprefix,
                volumenumber,lastuserid,lastmaintdate,editioncode,discountcode,editiondescription,
                editionnumber,additionaleditinfo)
        VALUES (@bookkey_var,@mediatypecode_var,@mediatypesubcode_var,@projectseriescode_var,
                @projecttitleprefix_var,@projectvolumenumber_var,@lastuserid_var,getdate(),
                @projecteditiontypecode_var,@discountcode_var,@projecteditiondesc_var,
                @projecteditionnumcode_var,@additionaleditioninfo_var)

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project: Error inserting into bookdetail table (' + cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END 
        -- printing
       IF  @v_templatekey = 0  OR @v_templatekey = -1 BEGIN 
		   --- generate job number alpha value
		 SELECT @v_generate_jobnumberalpha = COALESCE(gen2ind,0) FROM gentables WHERE tableid = 594 and qsicode = 14  
		  IF @v_generate_jobnumberalpha = 1 
			 exec dbo.qprinting_get_next_jobnumber_alpha  @o_jobnumberseq output,@o_error_code output, @o_error_desc output
		  ELSE
			  SET  @o_jobnumberseq = NULL
	   END
	   ELSE
			SET  @o_jobnumberseq = NULL
  
      -- Set bookkey on taqprojecttitle PRIOR to insert into printing table
      -- (the bookkey is referenced inside qprinting_prtgproj_from_prtgtbl - called from printing_create_prtgproj trigger)
      UPDATE taqprojecttitle
          SET bookkey = @bookkey_var, printingkey = @printingkey_var
        WHERE taqprojectformatkey = @taqprojectformatkey_var	--current Acq. Project format

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT        
      IF @error_var <> 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to approve project: Error updating taqprojecttitle table (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END 			
		  
		-- NOTE: this insert fires the printing_create_prtgproj trigger
		INSERT INTO printing (bookkey,printingkey,tentativeqty,printingnum,seasonkey,estseasonkey,lastuserid,lastmaintdate,printingjob,jobnumberalpha)
        VALUES (@bookkey_var,@printingkey_var,@initialrun_var,1,CASE WHEN @seasonfirmind_var = 1 THEN @seasoncode_var END,
               CASE WHEN @seasonfirmind_var = 0 OR @seasonfirmind_var IS NULL THEN @seasoncode_var END,
               @lastuserid_var,getdate(),1,@o_jobnumberseq)

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project: Error inserting into printing table (' + cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END 
        
	    SELECT @v_projectkey = taqprojectkey
	    FROM taqprojectprinting_view
	    WHERE bookkey = @bookkey_var AND printingkey = @printingkey_var   
	    
		IF @v_projectkey = 0 OR @v_projectkey is null BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to approve project: Invalid Printing Projectkey.'
			RETURN
		END 	      
        
        IF ((@primaryproductrequiredforsendtotmm_var = 1 and (len(@isbnprefixcode_var) > 0 or len(@eanprefixcode_var) > 0)) OR 
            @primaryproductrequiredforsendtotmm_var = 0) OR
           ((@v_default_prodnum_col = 'itemnumber' AND @primaryproductrequiredforsendtotmm_var = 1  AND len(@itemnumber_var) > 0))
        BEGIN
            -- isbn
            INSERT INTO isbn (bookkey,isbnkey,isbn,isbnprefixcode,isbn10,ean,ean13,eanprefixcode,gtin,gtin14,
                              lccn,dsmarc,itemnumber,upc,lastuserid,lastmaintdate)
            VALUES (@bookkey_var,@bookkey_var,@isbn_var,COALESCE(@isbnprefixcode_var,0),@isbn10_var,@ean_var,@ean13_var,
                    COALESCE(@eanprefixcode_var,0),@gtin_var,@gtin14_var,@lccn_var,@dsmarc_var,@itemnumber_var,@upc_var,
                    @lastuserid_var,getdate())

            SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
            IF @error_var <> 0 BEGIN
              SET @is_error_var = 1
              SET @o_error_code = -1
              SET @errormsg_var = 'Unable to approve project: Error inserting into isbn table (' + cast(@error_var AS VARCHAR) + ').'
              GOTO ExitHandler
            END 
        END
        
        -- bookauthor
       DECLARE author1_cur CURSOR FOR 
        SELECT @bookkey_var,c.globalcontactkey,r.authortypecode,COALESCE(r.primaryind,0),
               c.sortorder
          FROM taqprojectcontact c,taqprojectcontactrole r
         WHERE c.taqprojectkey = r.taqprojectkey and
               c.taqprojectcontactkey = r.taqprojectcontactkey and
               r.authortypecode > 0 and
               r.taqprojectkey = @i_projectkey
      ORDER BY c.sortorder

         OPEN author1_cur 
        FETCH author1_cur 
         INTO @bookkey_var,@globalcontactkey_var,@authortypecode_var,
              @primaryind_var,@sortorder_var

        SET @count_var = 0
        WHILE @@fetch_status = 0 BEGIN
          -- not all participants will be sent to TMM so reset sortorder to start at 1 
          SET @count_var = @count_var + 1

		  IF NOT EXISTS(SELECT * from bookauthor WHERE bookkey = @bookkey_var AND authorkey = @globalcontactkey_var AND authortypecode = @authortypecode_var) BEGIN
			  INSERT INTO bookauthor (bookkey,authorkey,authortypecode,primaryind,reportind,
									  sortorder,lastuserid,lastmaintdate)
			  VALUES (@bookkey_var,@globalcontactkey_var,@authortypecode_var,
					  @primaryind_var,0,@count_var,@lastuserid_var,getdate())
		  END
		  
          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            SET @is_error_var = 1
            SET @o_error_code = -1
            SET @errormsg_var = 'Unable to approve project: Error inserting into bookauthor table (' + cast(@error_var AS VARCHAR) + ').'
            CLOSE author1_cur 
            DEALLOCATE author1_cur 
            GOTO ExitHandler
          END 

          -- make sure Authors exist
          execute qauthor_contact_to_author @globalcontactkey_var,@lastuserid_var,@o_error_code OUTPUT,@errormsg_var OUTPUT

          IF @o_error_code <> 0 BEGIN
            SET @is_error_var = 1
            SET @o_error_code = -1
            SET @errormsg_var = 'Unable to approve project: Error inserting into author table.'
            CLOSE author1_cur 
            DEALLOCATE author1_cur 
            GOTO ExitHandler
          END 

          FETCH author1_cur 
           INTO @bookkey_var,@globalcontactkey_var,@authortypecode_var,
                @primaryind_var,@sortorder_var
        END
        CLOSE author1_cur 
        DEALLOCATE author1_cur 


        -- bookorgentry

		  DECLARE bookorgentry1_cur CURSOR FOR 
			SELECT @bookkey_var,orgentrykey,orglevelkey
          FROM taqprojectorgentry
         WHERE taqprojectkey = @i_projectkey
          ORDER BY orglevelkey

		  OPEN bookorgentry1_cur 
        FETCH bookorgentry1_cur INTO @bookkey_var,@orgentrykey_var,@orglevelkey_var

        
        WHILE @@fetch_status = 0 BEGIN
				INSERT INTO bookorgentry (bookkey,orgentrykey,orglevelkey,lastuserid,lastmaintdate)
					VALUES (@bookkey_var,@orgentrykey_var,@orglevelkey_var,@lastuserid_var,getdate())

				SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			   IF @error_var <> 0 BEGIN
			 	  SET @is_error_var = 1
			  	  SET @o_error_code = -1
				  SET @errormsg_var = 'Unable to approve project: Error inserting into bookorgentry table (' + cast(@error_var AS VARCHAR) + ').'
				  GOTO ExitHandler
			   END 
			   
				INSERT INTO taqprojectorgentry (taqprojectkey,orgentrykey,orglevelkey,lastuserid,lastmaintdate)
					VALUES (@v_projectkey,@orgentrykey_var,@orglevelkey_var,@lastuserid_var,getdate())

				SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			   IF @error_var <> 0 BEGIN
			 	  SET @is_error_var = 1
			  	  SET @o_error_code = -1
				  SET @errormsg_var = 'Unable to approve project: Error inserting into taqprojectorgentry table (' + cast(@error_var AS VARCHAR) + ').'
				  GOTO ExitHandler
			   END 			   
			   

				FETCH bookorgentry1_cur INTO @bookkey_var,@orgentrykey_var,@orglevelkey_var

        END
        CLOSE bookorgentry1_cur 
        DEALLOCATE bookorgentry1_cur 
        
        -- insert taqprojecttitle row for work
        IF @v_work_project_role > 0 and @v_title_title_role > 0 BEGIN
	        exec get_next_key @lastuserid_var, @new_taqprojectformatkey output

	        insert into taqprojecttitle
			        (taqprojectformatkey ,taqprojectkey, seasoncode ,seasonfirmind ,mediatypecode ,
			        mediatypesubcode ,discountcode ,price ,initialrun ,projectdollars ,marketingplancode ,
			        primaryformatind ,isbn ,isbn10 ,ean ,ean13 ,gtin ,bookkey ,taqprojectformatdesc ,
			        isbnprefixcode ,lastuserid ,lastmaintdate ,gtin14 ,lccn ,dsmarc ,itemnumber ,upc ,eanprefixcode,
			        printingkey, projectrolecode, titlerolecode, keyind, sortorder, indicator1, indicator2,
			        quantity1, quantity2, relateditem2name, relateditem2status, relateditem2participants, decimal1, decimal2)
	        select @new_taqprojectformatkey, @v_work_projectkey, seasoncode,  seasonfirmind, 
	            mediatypecode, mediatypesubcode, discountcode,
			        price, initialrun,  projectdollars, marketingplancode, primaryformatind, null, null, null, null, null,
			        @bookkey_var, taqprojectformatdesc, null, @lastuserid_var, getdate(), null, null, null, null, null, null,
			        printingkey, @v_work_project_role, @v_title_title_role, keyind, sortorder, indicator1, indicator2,
			        quantity1, quantity2, relateditem2name, relateditem2status, relateditem2participants, decimal1, decimal2
	        from taqprojecttitle
	        where taqprojectkey = @i_projectkey
		        and taqprojectformatkey = @taqprojectformatkey_var
		    END
      END
    END

    -- Process Tables Needed for Contracts
    --IF @process_contracts_var = 1 BEGIN
    --END

    -- Process Tables Needed for Titles
    IF @process_titles_var = 1 AND COALESCE(@format_bookkey_var,0) = 0 BEGIN
      -- bookbisaccategory
      INSERT INTO bookbisaccategory (bookkey,printingkey,bisaccategorycode,bisaccategorysubcode,sortorder,lastuserid,lastmaintdate)
      SELECT @bookkey_var,@printingkey_var,categorycode,COALESCE(categorysubcode,0),sortorder,@lastuserid_var,getdate()
        FROM taqprojectsubjectcategory
       WHERE taqprojectkey = @i_projectkey AND
             categorytableid = 339
             
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to approve project: Error inserting into bookbisaccategory table (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END 
      -- bookcategory
      INSERT INTO bookcategory (bookkey,categorycode,sortorder,lastuserid,lastmaintdate)
      SELECT @bookkey_var,categorycode,sortorder,@lastuserid_var,getdate()
        FROM taqprojectsubjectcategory
       WHERE taqprojectkey = @i_projectkey AND
             categorytableid = 317
             
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to approve project: Error inserting into bookcategory table (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END 
      -- bookcomments
      INSERT INTO bookcomments (bookkey,printingkey,commenttypecode,commenttypesubcode,commenttext,commenthtml,
                               commenthtmllite,lastuserid,lastmaintdate)
      SELECT @bookkey_var,@printingkey_var,c.commenttypecode,c.commenttypesubcode,q.commenttext,q.commenthtml,
             q.commenthtmllite,@lastuserid_var,getdate()
        FROM taqprojectcomments c, qsicomments q, gentables g
       WHERE c.commentkey = q.commentkey AND
             c.commenttypecode = g.datacode AND
             g.tableid = 284 AND
             g.gen2ind = 1 AND
             c.taqprojectkey = @i_projectkey

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to approve project: Error inserting into bookcomments table (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END       
      -- bookcontact & bookcontactrole      
      DECLARE bookcontact_cur CURSOR FOR 
      SELECT DISTINCT c.globalcontactkey,c.participantnote,c.keyind,c.sortorder,c.taqprojectcontactkey
        FROM taqprojectcontact c INNER JOIN taqprojectcontactrole r
       ON c.taqprojectkey = r.taqprojectkey 
          AND c.taqprojectcontactkey = r.taqprojectcontactkey          
       WHERE  (r.authortypecode is null OR r.authortypecode = 0) 
       AND r.rolecode IN (SELECT DISTINCT datacode from gentablesitemtype
							where tableid = 285
							  and itemtypecode = @v_itemtypecode
							  and itemtypesubcode in (@v_usageclasscode,0))
       AND c.taqprojectkey = @i_projectkey
             
       OPEN bookcontact_cur 
      FETCH bookcontact_cur 
       INTO @globalcontactkey_var,@participantnote_var,@keyind_var,@sortorder_var,@taqprojectcontactkey_var

      WHILE @@fetch_status = 0 BEGIN      
        -- Generate bookcontactkey
        execute get_next_key 'QSIADMIN',@bookcontactkey_var OUTPUT
              
        -- bookcontact
        INSERT INTO bookcontact (bookcontactkey,bookkey,printingkey,globalcontactkey,participantnote,
                                 keyind,sortorder,lastuserid,lastmaintdate)
             VALUES (@bookcontactkey_var,@bookkey_var,@printingkey_var,@globalcontactkey_var,@participantnote_var,
                     @keyind_var,@sortorder_var,@lastuserid_var,getdate())

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project: Error inserting into bookcontact table (' + cast(@error_var AS VARCHAR) + ').'
          CLOSE bookcontact_cur 
          DEALLOCATE bookcontact_cur 
          GOTO ExitHandler
        END

        -- bookcontactrole
        INSERT INTO bookcontactrole (bookcontactkey,rolecode,activeind,workrate,ratetypecode,lastuserid,lastmaintdate)
        SELECT @bookcontactkey_var,r.rolecode,r.activeind,r.workrate,r.ratetypecode,@lastuserid_var,getdate()
          FROM taqprojectcontact c, taqprojectcontactrole r
         WHERE c.taqprojectkey = r.taqprojectkey AND
               c.taqprojectcontactkey = r.taqprojectcontactkey AND
              (r.authortypecode is null OR r.authortypecode = 0) AND 
			   r.rolecode IN (SELECT DISTINCT datacode from gentablesitemtype
										where tableid = 285
										  and itemtypecode = @v_itemtypecode
										  and itemtypesubcode in (@v_usageclasscode,0)) AND                
               c.taqprojectkey = @i_projectkey AND
               r.taqprojectcontactkey = @taqprojectcontactkey_var

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project: Error inserting into bookcontactrole table (' + cast(@error_var AS VARCHAR) + ').'
          CLOSE bookcontact_cur 
          DEALLOCATE bookcontact_cur 
          GOTO ExitHandler
        END
        
        FETCH bookcontact_cur 
         INTO @globalcontactkey_var,@participantnote_var,@keyind_var,@sortorder_var,@taqprojectcontactkey_var
      END
      CLOSE bookcontact_cur 
      DEALLOCATE bookcontact_cur 
      
      -- bookmisc
      INSERT INTO bookmisc (bookkey,misckey,longvalue,floatvalue,textvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
      SELECT @bookkey_var,p.misckey,p.longvalue,p.floatvalue,p.textvalue,@lastuserid_var,getdate(),
             CASE WHEN COALESCE(i.sendtoeloquenceind,0)=1 THEN i.defaultsendtoeloqvalue ELSE 0 END
        FROM taqprojectmisc p, bookmiscitems i
       WHERE p.misckey = i.misckey AND
             COALESCE(i.taqtotmmind,0) = 1 AND
             p.taqprojectkey = @i_projectkey      

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to approve project: Error inserting into bookmisc table (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END 

      -- bookdates
      -- key dates for this format
      SET @taqprojecttaskoverride_rowcount = 0

      SELECT @v_count_taqprojecttask = COUNT(*)
        FROM taqprojecttask t,datetype d
        WHERE t.datetypecode = d.datetypecode AND
          t.taqprojectkey = @i_projectkey AND
          t.taqprojectformatkey = @taqprojectformatkey_var AND 
          COALESCE(t.taqelementkey,0) = 0 AND
          t.taqtaskkey in (select p.taqtaskkey from taqprojecttask p
                           where p.taqprojectkey = @i_projectkey AND
                                 p.taqprojectformatkey = @taqprojectformatkey_var AND
                                 p.datetypecode = t.datetypecode AND 
                                 COALESCE(p.taqelementkey,0) = 0)

      IF @v_count_taqprojecttask > 0 BEGIN
        DECLARE keydate_cur CURSOR FOR 
          SELECT t.datetypecode,CASE WHEN t.actualind = 1 THEN t.activedate END,
            CASE WHEN t.actualind = 1 THEN t.originaldate ELSE t.activedate END,
            COALESCE(t.actualind,0),d.sortorder, globalcontactkey, rolecode, globalcontactkey2, rolecode2, 
            scheduleind, stagecode, duration, activedate, actualind, keyind, decisioncode,
            startdate,startdateactualind,lag, t.taqtaskkey, t.paymentamt, t.taqtaskqty, t.transactionkey, t.taqtasknote
          FROM taqprojecttask t,datetype d
          WHERE t.datetypecode = d.datetypecode AND
            t.taqprojectkey = @i_projectkey AND
            t.taqprojectformatkey = @taqprojectformatkey_var AND 
            COALESCE(t.taqelementkey,0) = 0 AND
            t.taqtaskkey in (select p.taqtaskkey from taqprojecttask p
                             where p.taqprojectkey = @i_projectkey AND
                                   p.taqprojectformatkey = @taqprojectformatkey_var AND
                                   p.datetypecode = t.datetypecode AND 
                                   COALESCE(p.taqelementkey,0) = 0)
          ORDER BY t.datetypecode,d.sortorder

          OPEN keydate_cur 

          --PRINT '-- key dates for format=' + convert(varchar, @taqprojectformatkey_var) + ':'

          FETCH keydate_cur 
          INTO @datetypecode_var,@activedate_var,@estdate_var,@actualind_var,@sortorder_var,
            @globalcontactkey_var,@rolecode_var,@globalcontactkey2_var,@rolecode2_var,@scheduleind_var,@stagecode_var,@duration_var,
            @activedate_var,@actualind_var,@keyind_var,@decisioncode_var,@v_startdate,@v_startdateactualind,@v_lag, @v_taqtaskkey,
            @paymentamt_var, @taqtaskqty_var, @transactionkey_var, @taqtasknote_var

          WHILE @@fetch_status = 0 BEGIN          
            select @taqprojecttaskoverride_rowcount = count(*)
            from taqprojecttaskoverride
            where taqtaskkey = @v_taqtaskkey

            if @taqprojecttaskoverride_rowcount = 0
            begin
              select @v_title_cnt = count(*)
              from gentablesitemtype
              where tableid = 323
                and datacode = @datetypecode_var
                and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
                and itemtypecode = 1
                and itemtypesubcode in (1,0)

              select @v_restriction_value_title = relateddatacode
              from gentablesitemtype
              where tableid = 323
                and datacode = @datetypecode_var
                and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
                and itemtypecode = 1
                and itemtypesubcode in (1,0)

              SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
              IF @error_var <> 0 BEGIN
                SET @is_error_var = 1
                SET @o_error_code = -1
                SET @errormsg_var = 'Unable to approve project: Error counting gentablesitemtype table - datetype titles(' + cast(@error_var AS VARCHAR) + ').'
                CLOSE keydate_cur 
                DEALLOCATE keydate_cur 
                GOTO ExitHandler
              END

              select @v_work_cnt = count(*)
              from gentablesitemtype
              where tableid = 323
                and datacode = @datetypecode_var
                and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
                and itemtypecode = 9
                and itemtypesubcode in (1,0)

              select @v_restriction_value_work = relateddatacode
              from gentablesitemtype
              where tableid = 323
                and datacode = @datetypecode_var
                and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
                and itemtypecode = 9
                and itemtypesubcode in (1,0)

              SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
              IF @error_var <> 0 BEGIN
                SET @is_error_var = 1
                SET @o_error_code = -1
                SET @errormsg_var = 'Unable to approve project: Error counting gentablesitemtype table - datetypetype works(' + cast(@error_var AS VARCHAR) + ').'
                CLOSE keydate_cur 
                DEALLOCATE keydate_cur 
                GOTO ExitHandler
              END

              -- Branch here for the client options choice of Web vs. TMM      
              IF @usewebscheduling = 0 AND @v_title_cnt = 1
              BEGIN
                INSERT INTO bookdates (bookkey, printingkey, datetypecode, activedate,
                  estdate, actualind, sortorder, lastuserid, lastmaintdate)
                VALUES (@bookkey_var, @printingkey_var, @datetypecode_var, @activedate_var,
	                @estdate_var, @actualind_var, @sortorder_var, @lastuserid_var, getdate())
              END
              
              IF @usewebscheduling = 1 
              BEGIN
                -- For Format tasks, process only once (as opposed to processing first for titles, second time for work).
                -- Bookkey/printingkey should always be filled since these tasks were linked to a given project format.
                -- Projectkey should be filled if itemtype filter is set for works for this task.
                SET @o_returncode = 0						
                SET @v_linked_bookkey = @bookkey_var
                SET @v_linked_printingkey = @printingkey_var
                SET @v_linked_projectkey = NULL

                IF @v_title_cnt > 0 BEGIN
                  IF (@v_linked_bookkey > 0 AND @datetypecode_var IS NOT NULL) BEGIN
                    EXEC dbo.qutl_check_for_restrictions @datetypecode_var, @v_linked_bookkey, @v_linked_printingkey, NULL, NULL, NULL, NULL, 
                      @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
                    IF @o_error_code <> 0 BEGIN
                      SET @o_error_code = -1
                      SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
                      RETURN
                    END
                    IF (@o_returncode = 2 AND @v_restriction_value_title = 3 AND @keyind_var  = 0) BEGIN
                      SET @o_returncode = 0
                    END
                  END 
                END

                IF @v_work_cnt > 0 BEGIN  
                  SET @v_linked_projectkey = @v_work_projectkey

                  IF (@v_linked_projectkey > 0 AND @datetypecode_var IS NOT NULL) BEGIN
                    EXEC dbo.qutl_check_for_restrictions @datetypecode_var, NULL, NULL, @v_linked_projectkey, NULL, NULL, NULL, 
                      @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
                    IF @o_error_code <> 0 BEGIN
                      SET @o_error_code = -1
                      SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
                      RETURN
                    END
                    IF (@o_returncode = 3 AND @v_restriction_value_work = 3 AND @keyind_var  = 0) BEGIN
                      SET @o_returncode = 0
                    END
                  END
                END                  
            
                IF @o_returncode = 0 BEGIN
                  -- Generate taqtaskkey
                  execute get_next_key 'QSIADMIN',@taqtaskkey OUTPUT

                  --PRINT '@datetypecode_var=' + convert(varchar, @datetypecode_var)
                  --PRINT '@v_linked_bookkey=' + convert(varchar, @v_linked_bookkey)
                  --PRINT '@v_linked_projectkey=' + convert(varchar, @v_linked_projectkey)

                  INSERT INTO taqprojecttask 
                    (taqtaskkey, bookkey, printingkey, taqprojectkey, datetypecode, activedate, 
                    originaldate, actualind, keyind, sortorder, lastuserid, lastmaintdate, 
                    globalcontactkey, rolecode, globalcontactkey2, rolecode2,
                    scheduleind, stagecode, duration, decisioncode, startdate, startdateactualind,
                    lag, paymentamt, taqtaskqty, transactionkey, taqtasknote)
                  VALUES 
                    (@taqtaskkey, @v_linked_bookkey, @v_linked_printingkey, @v_linked_projectkey, @datetypecode_var, @activedate_var, 
                    @estdate_var, @actualind_var, @keyind_var, @sortorder_var, @lastuserid_var, getdate(), 
                    @globalcontactkey_var, @rolecode_var, @globalcontactkey2_var, @rolecode2_var,
                    @scheduleind_var, @stagecode_var, @duration_var, @decisioncode_var, @v_startdate, @v_startdateactualind,
                    @v_lag, @paymentamt_var, @taqtaskqty_var, @transactionkey_var, @taqtasknote_var)

                  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
                  IF @error_var <> 0 BEGIN
                    SET @is_error_var = 1
                    SET @o_error_code = -1
                    SET @errormsg_var = 'Unable to approve project: Error inserting into bookdates table 1(' + cast(@error_var AS VARCHAR) + ').'
                    CLOSE keydate_cur 
                    DEALLOCATE keydate_cur 
                    GOTO ExitHandler
                  END	
                END --IF @o_returncode=0
              END --IF @usewebscheduling=1
            end --if @taqprojecttaskoverride_rowcount=0

            FETCH keydate_cur 
            INTO @datetypecode_var,@activedate_var,@estdate_var,@actualind_var,@sortorder_var,
              @globalcontactkey_var,@rolecode_var,@globalcontactkey2_var,@rolecode2_var,@scheduleind_var,@stagecode_var,@duration_var,
              @activedate_var,@actualind_var,@keyind_var,@decisioncode_var,@v_startdate,@v_startdateactualind,@v_lag, @v_taqtaskkey,
              @paymentamt_var, @taqtaskqty_var, @transactionkey_var, @taqtasknote_var
          END
          
          CLOSE keydate_cur 
          DEALLOCATE keydate_cur 
      END --@v_count_taqprojecttask > 0
   
      -- primary format only dates
      SELECT @v_count_taqprojecttask = COUNT(*)
         FROM taqprojecttask t,datetype d
        WHERE t.datetypecode = d.datetypecode AND
          d.taqprimaryformatind = 1 AND   -- primary only tasks
          t.taqprojectkey = @i_projectkey AND
          COALESCE(t.taqprojectformatkey,0) = 0 AND 
          COALESCE(t.taqelementkey,0) = 0 AND
          t.taqtaskkey in (select p.taqtaskkey from taqprojecttask p
                          where p.taqprojectkey = @i_projectkey AND
                          COALESCE(p.taqprojectformatkey,0) = 0 AND 
                          p.datetypecode = t.datetypecode AND 
                          COALESCE(p.taqelementkey,0) = 0)

      IF @v_count_taqprojecttask > 0 BEGIN
        IF (@primaryformatind_var = 1) BEGIN      
          DECLARE keydate_cur CURSOR FOR 
          SELECT t.datetypecode,CASE WHEN t.actualind = 1 THEN t.activedate END,
            CASE WHEN t.actualind = 1 THEN t.originaldate ELSE t.activedate END,
            COALESCE(t.actualind,0),d.sortorder, globalcontactkey, rolecode, globalcontactkey2, rolecode2,
            scheduleind, stagecode, duration, activedate, actualind, keyind, decisioncode,
            startdate,startdateactualind,lag, t.taqtaskkey,
            t.paymentamt, t.taqtaskqty, t.transactionkey, t.taqtasknote
          FROM taqprojecttask t,datetype d
          WHERE t.datetypecode = d.datetypecode AND
            d.taqprimaryformatind = 1 AND   -- primary only tasks
            t.taqprojectkey = @i_projectkey AND
            COALESCE(t.taqprojectformatkey,0) = 0 AND 
            COALESCE(t.taqelementkey,0) = 0 AND
            t.taqtaskkey in (select p.taqtaskkey from taqprojecttask p
                            where p.taqprojectkey = @i_projectkey AND
                            COALESCE(p.taqprojectformatkey,0) = 0 AND 
                            p.datetypecode = t.datetypecode AND 
                            COALESCE(p.taqelementkey,0) = 0)
          ORDER BY t.datetypecode,d.sortorder

          OPEN keydate_cur 

          --PRINT '-- primary format only dates:'

          FETCH keydate_cur 
          INTO @datetypecode_var,@activedate_var,@estdate_var,@actualind_var,@sortorder_var,
            @globalcontactkey_var,@rolecode_var,@globalcontactkey2_var,@rolecode2_var,@scheduleind_var,@stagecode_var,@duration_var,
            @activedate_var,@actualind_var,@keyind_var,@decisioncode_var,@v_startdate,@v_startdateactualind,@v_lag, @v_taqtaskkey,
            @paymentamt_var, @taqtaskqty_var, @transactionkey_var, @taqtasknote_var

          WHILE @@fetch_status = 0 BEGIN
            select @taqprojecttaskoverride_rowcount = count(*)
            from taqprojecttaskoverride
            where taqtaskkey = @v_taqtaskkey

            if @taqprojecttaskoverride_rowcount = 0
            begin
              select @v_title_cnt = count(*)
              from gentablesitemtype
              where tableid = 323
                and datacode = @datetypecode_var
                and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
                and itemtypecode = 1
                and itemtypesubcode in (1,0)

              select @v_restriction_value_title = relateddatacode
              from gentablesitemtype
              where tableid = 323
                and datacode = @datetypecode_var
                and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
                and itemtypecode = 1
                and itemtypesubcode in (1,0)
                
              SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
              IF @error_var <> 0 BEGIN
                SET @is_error_var = 1
                SET @o_error_code = -1
                SET @errormsg_var = 'Unable to approve project: Error counting gentablesitemtype table - datetype titles(' + cast(@error_var AS VARCHAR) + ').'
                CLOSE keydate_cur 
                DEALLOCATE keydate_cur 
                GOTO ExitHandler
              END              

              select @v_work_cnt = count(*)
              from gentablesitemtype
              where tableid = 323
                and datacode = @datetypecode_var
                and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
                and itemtypecode = 9
                and itemtypesubcode in (1,0)

              select @v_restriction_value_work = relateddatacode
              from gentablesitemtype
              where tableid = 323
                and datacode = @datetypecode_var
                and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
                and itemtypecode = 9
                and itemtypesubcode in (1,0)
                
              SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
              IF @error_var <> 0 BEGIN
                SET @is_error_var = 1
                SET @o_error_code = -1
                SET @errormsg_var = 'Unable to approve project: Error counting gentablesitemtype table - datetypetype works(' + cast(@error_var AS VARCHAR) + ').'
                CLOSE keydate_cur 
                DEALLOCATE keydate_cur 
                GOTO ExitHandler
              END              

              -- Make a logic branch here if webscheduling
              IF @usewebscheduling = 0 AND @v_title_cnt > 0 BEGIN
                -- make sure that the datetype wasn't already added to bookdates
                SELECT @dup_date_count_var = count(*)
                FROM bookdates
                WHERE bookkey = @bookkey_var AND
                  printingkey = @printingkey_var AND
                  datetypecode = @datetypecode_var

                SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
                IF @error_var <> 0 BEGIN
                  SET @is_error_var = 1
                  SET @o_error_code = -1
                  SET @errormsg_var = 'Unable to approve project: Error counting bookdates table 2(' + cast(@error_var AS VARCHAR) + ').'
                  CLOSE keydate_cur 
                  DEALLOCATE keydate_cur 
                  GOTO ExitHandler
                END
                
                IF @dup_date_count_var <= 0 BEGIN   
                  INSERT INTO bookdates (bookkey, printingkey, datetypecode, activedate,
                    estdate, actualind, sortorder, lastuserid, lastmaintdate)
                  VALUES (@bookkey_var, @printingkey_var, @datetypecode_var, @activedate_var,
                    @estdate_var, @actualind_var, @sortorder_var, @lastuserid_var, getdate())

                  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
                  IF @error_var <> 0 BEGIN
                    SET @is_error_var = 1
                    SET @o_error_code = -1
                    SET @errormsg_var = 'Unable to approve project: Error inserting into bookdates table 2(' + cast(@error_var AS VARCHAR) + ').'
                    CLOSE keydate_cur 
                    DEALLOCATE keydate_cur 
                    GOTO ExitHandler
                  END
                END
              END

              IF @usewebscheduling = 1
              BEGIN
                -- For Primary Format Only tasks, process only once (as opposed to processing first for titles, second time for work).
                -- Bookkey/printingkey should always be filled since these tasks were linked to a given project format.
                -- Projectkey should be filled if itemtype filter is set for works for this task.            
                SET @o_returncode = 0
                SET @v_linked_bookkey = @bookkey_var
                SET @v_linked_printingkey = @printingkey_var
                SET @v_linked_projectkey = null

                IF @v_title_cnt > 0 BEGIN
                  IF (@v_linked_bookkey > 0 AND @datetypecode_var IS NOT NULL) BEGIN
                    EXEC dbo.qutl_check_for_restrictions @datetypecode_var, @v_linked_bookkey, @v_linked_printingkey, NULL, NULL, NULL, NULL, 
                      @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
                    IF @o_error_code <> 0 BEGIN
                      SET @o_error_code = -1
                      SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
                      RETURN
                    END
                    IF (@o_returncode = 2 AND @v_restriction_value_title = 3 AND @keyind_var  = 0) BEGIN
                      SET @o_returncode = 0
                    END
                  END 
                END

                IF @v_work_cnt > 0 BEGIN  
                  SET @v_linked_projectkey = @v_work_projectkey

                  IF (@v_linked_projectkey IS NOT NULL AND @v_linked_projectkey > 0 AND @datetypecode_var IS NOT NULL) BEGIN
                    EXEC dbo.qutl_check_for_restrictions @datetypecode_var, NULL, NULL, @v_linked_projectkey, NULL, NULL, NULL, 
                      @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
                    IF @o_error_code <> 0 BEGIN
                      SET @o_error_code = -1
                      SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
                      RETURN
                    END
                    IF (@o_returncode = 3 AND @v_restriction_value_work = 3 AND @keyind_var  = 0) BEGIN
                      SET @o_returncode = 0
                    END
                  END
                END

                IF @o_returncode = 0 BEGIN
                  -- Generate taqtaskkey
                  execute get_next_key 'QSIADMIN',@taqtaskkey OUTPUT

                  --PRINT '@datetypecode_var=' + convert(varchar, @datetypecode_var)
                  --PRINT '@v_linked_bookkey=' + convert(varchar, @v_linked_bookkey)
                  --PRINT '@v_linked_projectkey=' + convert(varchar, @v_linked_projectkey)

                  INSERT INTO taqprojecttask
                    (taqtaskkey, bookkey, printingkey, taqprojectkey, datetypecode, activedate,
                    originaldate, actualind, keyind, sortorder, lastuserid, lastmaintdate,
                    globalcontactkey, rolecode, globalcontactkey2, rolecode2,
                    scheduleind, stagecode, duration, decisioncode, startdate, startdateactualind,
                    lag, paymentamt, taqtaskqty, transactionkey, taqtasknote)
                  VALUES 
                    (@taqtaskkey, @v_linked_bookkey, @v_linked_printingkey, @v_linked_projectkey, @datetypecode_var, @activedate_var,
                    @estdate_var, @actualind_var, @keyind_var, @sortorder_var, @lastuserid_var, getdate(),
                    @globalcontactkey_var, @rolecode_var, @globalcontactkey2_var, @rolecode2_var,
                    @scheduleind_var, @stagecode_var, @duration_var, @decisioncode_var, @v_startdate, @v_startdateactualind,
                    @v_lag, @paymentamt_var, @taqtaskqty_var, @transactionkey_var, @taqtasknote_var)

                  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
                  IF @error_var <> 0 BEGIN
                    SET @is_error_var = 1
                    SET @o_error_code = -1
                    SET @errormsg_var = 'Unable to approve project: Error inserting into bookdates table 2(' + cast(@error_var AS VARCHAR) + ').'
                    CLOSE keydate_cur 
                    DEALLOCATE keydate_cur 
                    GOTO ExitHandler
                  END
                END --IF @o_returncode=0
              END --IF @usewebscheduling=1
            END --if @taqprojecttaskoverride_rowcount=0

            FETCH keydate_cur 
            INTO @datetypecode_var,@activedate_var,@estdate_var,@actualind_var,@sortorder_var,
              @globalcontactkey_var,@rolecode_var,@globalcontactkey2_var,@rolecode2_var,@scheduleind_var,@stagecode_var,@duration_var,
              @activedate_var,@actualind_var,@keyind_var,@decisioncode_var,@v_startdate,@v_startdateactualind,@v_lag, @v_taqtaskkey,
              @paymentamt_var, @taqtaskqty_var, @transactionkey_var, @taqtasknote_var
          END
          
          CLOSE keydate_cur 
          DEALLOCATE keydate_cur 
        END --@primaryformatind_var = 1
    END --@v_count_taqprojecttask > 0

      -- dates for any format
	  SET @taqprojecttaskoverride_rowcount = 0

    SELECT @v_count_taqprojecttask = COUNT(*)
       FROM taqprojecttask t,datetype d
       WHERE t.datetypecode = d.datetypecode AND
             COALESCE(d.taqprimaryformatind,0) = 0 AND   -- not primary only tasks
             t.taqprojectkey = @i_projectkey AND
             COALESCE(t.taqprojectformatkey,0) = 0 AND 
             COALESCE(t.taqelementkey,0) = 0 AND
             t.taqtaskkey in (select p.taqtaskkey from taqprojecttask p
                               where p.taqprojectkey = @i_projectkey AND
                                     COALESCE(p.taqprojectformatkey,0) = 0 AND 
                                     p.datetypecode = t.datetypecode AND 
                                     COALESCE(p.taqelementkey,0) = 0)

    IF @v_count_taqprojecttask > 0 BEGIN
        DECLARE keydate_cur CURSOR FOR 
        SELECT t.datetypecode,CASE WHEN t.actualind = 1 THEN t.activedate END,
               CASE WHEN t.actualind = 1 THEN t.originaldate ELSE t.activedate END,
               COALESCE(t.actualind,0),d.sortorder, globalcontactkey, rolecode, globalcontactkey2, rolecode2, 
               scheduleind, stagecode, duration, activedate, actualind, keyind, decisioncode,
               startdate,startdateactualind,lag, t.taqtaskkey,
			   t.paymentamt, t.taqtaskqty, t.transactionkey, t.taqtasknote
          FROM taqprojecttask t,datetype d
         WHERE t.datetypecode = d.datetypecode AND
               COALESCE(d.taqprimaryformatind,0) = 0 AND   -- not primary only tasks
               t.taqprojectkey = @i_projectkey AND
               COALESCE(t.taqprojectformatkey,0) = 0 AND 
               COALESCE(t.taqelementkey,0) = 0 AND
               t.taqtaskkey in (select p.taqtaskkey from taqprojecttask p
                                 where p.taqprojectkey = @i_projectkey AND
                                       COALESCE(p.taqprojectformatkey,0) = 0 AND 
                                       p.datetypecode = t.datetypecode AND 
                                       COALESCE(p.taqelementkey,0) = 0)
      ORDER BY t.datetypecode,d.sortorder
               
       OPEN keydate_cur 
       
        --PRINT '-- dates for any format:'

       FETCH keydate_cur 
        INTO @datetypecode_var,@activedate_var,@estdate_var,@actualind_var,@sortorder_var,
             @globalcontactkey_var,@rolecode_var,@globalcontactkey2_var,@rolecode2_var,@scheduleind_var,@stagecode_var,@duration_var,
             @activedate_var,@actualind_var,@keyind_var,@decisioncode_var,@v_startdate,@v_startdateactualind,@v_lag, @v_taqtaskkey,
		     @paymentamt_var, @taqtaskqty_var, @transactionkey_var, @taqtasknote_var

        WHILE @@fetch_status = 0 BEGIN
		    select @taqprojecttaskoverride_rowcount = count(*)
		    from taqprojecttaskoverride
		    where taqtaskkey = @v_taqtaskkey

		    if @taqprojecttaskoverride_rowcount = 0
		    begin
			    SELECT @v_title_cnt = 0 

			    select @v_title_cnt = count(*)
				  from gentablesitemtype
			     where tableid = 323
				   and datacode = @datetypecode_var
				   and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
				   and itemtypecode = 1
				   and itemtypesubcode in (1,0)

			    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			    IF @error_var <> 0 BEGIN
				  SET @is_error_var = 1
				  SET @o_error_code = -1
				  SET @errormsg_var = 'Unable to approve project: Error counting gentablesitemtype table - datetype titles(' + cast(@error_var AS VARCHAR) + ').'
				  CLOSE keydate_cur 
				  DEALLOCATE keydate_cur 
				  GOTO ExitHandler
			    END

			    SELECT @v_restriction_value_title = 1
			    select @v_restriction_value_title = relateddatacode
				  from gentablesitemtype
			     where tableid = 323
				   and datacode = @datetypecode_var
				   and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
				   and itemtypecode = 1
				   and itemtypesubcode in (1,0)

			    SELECT @v_work_cnt = 0 
			    select @v_work_cnt = count(*)
				  from gentablesitemtype
			     where tableid = 323
				   and datacode = @datetypecode_var
				   and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
				   and itemtypecode = 9
				   and itemtypesubcode in (1,0)

			    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			    IF @error_var <> 0 BEGIN
				  SET @is_error_var = 1
				  SET @o_error_code = -1
				  SET @errormsg_var = 'Unable to approve project: Error counting gentablesitemtype table - datetypetype works(' + cast(@error_var AS VARCHAR) + ').'
				  CLOSE keydate_cur 
				  DEALLOCATE keydate_cur 
				  GOTO ExitHandler
			    END


			    select @v_restriction_value_work = relateddatacode
				  from gentablesitemtype
			     where tableid = 323
				   and datacode = @datetypecode_var
				   and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
				   and itemtypecode = 9
				   and itemtypesubcode in (1,0)

			  -- Make a logic branch here if webscheduling
	  --	      IF @usewebscheduling = 0 AND @v_taqtotmmind = 1 BEGIN
			  IF @usewebscheduling = 0 AND @v_title_cnt > 0 BEGIN
			    -- make sure that the datetype wasn't already added to bookdates
			    SELECT @dup_date_count_var = count(*)
				  FROM bookdates
			     WHERE bookkey = @bookkey_var AND
					   printingkey = @printingkey_var AND
					   datetypecode = @datetypecode_var

			    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			    IF @error_var <> 0 BEGIN
				  SET @is_error_var = 1
				  SET @o_error_code = -1
				  SET @errormsg_var = 'Unable to approve project: Error counting bookdates table 3(' + cast(@error_var AS VARCHAR) + ').'
				  CLOSE keydate_cur 
				  DEALLOCATE keydate_cur 
				  GOTO ExitHandler
			    END
  	          
			    IF @dup_date_count_var <= 0 BEGIN   
				  INSERT INTO bookdates (bookkey,printingkey,datetypecode,activedate,estdate,actualind,
									   sortorder,lastuserid,lastmaintdate)
				  VALUES (@bookkey_var,@printingkey_var,@datetypecode_var,@activedate_var,
						     @estdate_var,@actualind_var,@sortorder_var,@lastuserid_var,getdate())

				  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
				  IF @error_var <> 0 BEGIN
				    SET @is_error_var = 1
				    SET @o_error_code = -1
				    SET @errormsg_var = 'Unable to approve project: Error inserting into bookdates table 3(' + cast(@error_var AS VARCHAR) + ').'
				    CLOSE keydate_cur 
				    DEALLOCATE keydate_cur 
				    GOTO ExitHandler
				  END
			    END
			  END

			    IF @usewebscheduling = 1 BEGIN
			    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
			    IF @error_var <> 0 BEGIN
				  SET @is_error_var = 1
				  SET @o_error_code = -1
				  SET @errormsg_var = 'Unable to approve project: Error counting taqprojecttask table 3(' + cast(@error_var AS VARCHAR) + ').'
				  CLOSE keydate_cur 
				  DEALLOCATE keydate_cur 
				  GOTO ExitHandler
			    END

				  if @v_title_cnt > 0 or @v_work_cnt > 0 begin
					    SET @v_loop_total = 1     
  	 
					   --gentablesitemtype has been setup for title and work,create separate element records for title and work
					   if @v_title_cnt > 0 and @v_work_cnt > 0 begin
						  SET @v_loop_total = 2
					    end
  	                
					    SET @v_loop_cnt = 0   

					    WHILE @v_loop_cnt < @v_loop_total BEGIN
						  SET @v_loop_cnt = @v_loop_cnt + 1
                          SET @v_work_loop = 0
						  SET @o_returncode = 0
						  -- if gentablesitemtype setup for titles, set bookkey,printingkey on taqprojecttask 
						  SET @v_linked_bookkey = null
						  SET @v_linked_printingkey = null
						  IF @v_title_cnt > 0 BEGIN
						    IF @v_loop_total = 1 OR (@v_loop_total = 2 AND @v_loop_cnt = 1) BEGIN
							  SET @v_linked_bookkey = @bookkey_var
							  SET @v_linked_printingkey = @printingkey_var

							  IF (@v_linked_bookkey IS NOT NULL AND @v_linked_bookkey > 0 AND @datetypecode_var IS NOT NULL) BEGIN
							     exec dbo.qutl_check_for_restrictions @datetypecode_var, @v_linked_bookkey, @v_linked_printingkey, NULL, NULL, NULL, NULL, 
                                   @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
							     IF @o_error_code <> 0 BEGIN
								    SET @o_error_code = -1
								    SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
								    RETURN
							     END
							     IF (@o_returncode = 2 AND @v_restriction_value_title = 3 AND @keyind_var  = 0) BEGIN
									  SET @o_returncode = 0
							     END
							  END 
						    END
						  END

						  -- if gentablesitemtype setup for works, set projectkey on taqprojecttask to work projectkey 
						  SET @v_linked_projectkey = null
						  IF @v_work_cnt > 0 BEGIN  
						    IF @v_loop_total = 1 OR (@v_loop_total = 2 AND @v_loop_cnt = 2) BEGIN
                              SET @v_work_loop = 1
							  SET @v_linked_projectkey = @v_work_projectkey

						      IF (@v_linked_projectkey IS NOT NULL AND @v_linked_projectkey > 0 AND @datetypecode_var IS NOT NULL) BEGIN
							     exec dbo.qutl_check_for_restrictions @datetypecode_var, NULL, NULL, @v_linked_projectkey, NULL, NULL, NULL, 
                                   @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
							     IF @o_error_code <> 0 BEGIN
								    SET @o_error_code = -1
								    SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
								    RETURN
							     END
							     IF (@o_returncode = 3 AND @v_restriction_value_work = 3 AND @keyind_var  = 0) BEGIN
									  SET @o_returncode = 0
							     END
						      END 
						    END
						  END
  	                  
					    IF @o_returncode = 0 AND (@v_work_loop = 0 OR (@v_work_loop = 1 AND @primaryformatind_var = 1)) BEGIN	                            
						    -- Generate taqtaskkey
						    execute get_next_key 'QSIADMIN',@taqtaskkey OUTPUT

                --PRINT '@datetypecode_var=' + convert(varchar, @datetypecode_var)
                --PRINT '@v_linked_bookkey=' + convert(varchar, @v_linked_bookkey)
                --PRINT '@v_linked_projectkey=' + convert(varchar, @v_linked_projectkey)

						    INSERT INTO taqprojecttask ( taqtaskkey,bookkey,printingkey,datetypecode,activedate,originaldate,actualind,
												   sortorder,lastuserid,lastmaintdate,globalcontactkey,rolecode,globalcontactkey2,rolecode2,scheduleind,stagecode,duration,
												   keyind,decisioncode,taqprojectkey,startdate,startdateactualind,lag, paymentamt, taqtaskqty, transactionkey, taqtasknote)
						    VALUES (@taqtaskkey, @v_linked_bookkey,@v_linked_printingkey,@datetypecode_var,@activedate_var,
									     @estdate_var,@actualind_var,@sortorder_var,@lastuserid_var,getdate(),
									     @globalcontactkey_var,@rolecode_var,@globalcontactkey2_var,@rolecode2_var,@scheduleind_var,@stagecode_var,@duration_var,
									     @keyind_var,@decisioncode_var,@v_linked_projectkey,@v_startdate,@v_startdateactualind,@v_lag,
									     @paymentamt_var, @taqtaskqty_var, @transactionkey_var, @taqtasknote_var)

						    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
						    IF @error_var <> 0 BEGIN
							  SET @is_error_var = 1
							  SET @o_error_code = -1
							  SET @errormsg_var = 'Unable to approve project: Error inserting into bookdates table 3(' + cast(@error_var AS VARCHAR) + ').'
							  CLOSE keydate_cur 
							  DEALLOCATE keydate_cur 
							  GOTO ExitHandler
						    END
					    END
				    END
				  END 
			  END 
		  end
          FETCH keydate_cur 
          INTO @datetypecode_var,@activedate_var,@estdate_var,@actualind_var,@sortorder_var,
             @globalcontactkey_var,@rolecode_var,@globalcontactkey2_var,@rolecode2_var,@scheduleind_var,@stagecode_var,@duration_var,
             @activedate_var,@actualind_var,@keyind_var,@decisioncode_var,@v_startdate,@v_startdateactualind,@v_lag, @v_taqtaskkey,
		     @paymentamt_var, @taqtaskqty_var, @transactionkey_var, @taqtasknote_var
        END
        CLOSE keydate_cur 
        DEALLOCATE keydate_cur 
     END --@v_count_taqprojecttask > 0

      -- elements - only create elements for primary format
      IF @primaryformatind_var = 1 BEGIN
        DECLARE element_cur CURSOR FOR 
         SELECT e.taqelementkey,e.taqelementtypecode,0 elementtypesubcode,e.sortorder,
                substring(ltrim(rtrim(g.datadesc)) + ' ' + cast(e.taqelementnumber as varchar),1,20) elementname,
                substring(ltrim(rtrim(g.datadesc)) + ' ' + cast(e.taqelementnumber as varchar) + ' - ' + ltrim(rtrim(e.taqelementdesc)),1,255) elementdesc,
                coalesce((select gen3ind from gentables_ext where tableid = 287 and datacode = g.datacode),0) worktotitleind
           FROM gentables g, taqprojectelement e
          WHERE e.taqelementtypecode = g.datacode and
               (e.taqelementtypesubcode is null OR e.taqelementtypesubcode = 0) and         
                g.tableid = 287 and
                g.gen2ind = 1 and   -- taqtotmmind
                e.taqprojectkey = @i_projectkey
         UNION
         SELECT e.taqelementkey,e.taqelementtypecode,e.taqelementtypesubcode elementtypesubcode,e.sortorder,
                substring(ltrim(rtrim(s.datadesc)) + ' ' + cast(e.taqelementnumber as varchar),1,20) elementname,
                substring(ltrim(rtrim(s.datadesc)) + ' ' + cast(e.taqelementnumber as varchar) + ' - ' + ltrim(rtrim(e.taqelementdesc)),1,255) elementdesc,
                coalesce(subgen3ind,0) worktotitleind
           FROM subgentables s, taqprojectelement e
          WHERE e.taqelementtypecode = s.datacode and
                e.taqelementtypesubcode = s.datasubcode and         
                s.tableid = 287 and 
                s.subgen2ind = 1 and  -- taqtotmmind
                e.taqprojectkey = @i_projectkey
       ORDER BY e.taqelementtypecode,elementtypesubcode,e.sortorder

       OPEN element_cur 
       FETCH element_cur 
        INTO @taqelementkey_var,@elementtypecode_var,@elementtypesubcode_var,
             @taqelementsortorder_var,@elementname_var,@elementdesc_var,@v_linkworktotitleind

        WHILE @@fetch_status = 0 BEGIN                   
          select @v_title_cnt = count(*)
            from gentablesitemtype
           where tableid = 287
             and datacode = @elementtypecode_var
             and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
             and itemtypecode = 1
             and itemtypesubcode in (1,0)

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            SET @is_error_var = 1
            SET @o_error_code = -1
            SET @errormsg_var = 'Unable to approve project: Error counting gentablesitemtype table - elementtype titles(' + cast(@error_var AS VARCHAR) + ').'
            CLOSE keydate_cur 
            DEALLOCATE keydate_cur 
            GOTO ExitHandler
          END

          select @v_work_cnt = count(*)
            from gentablesitemtype
           where tableid = 287
             and datacode = @elementtypecode_var
             and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
             and itemtypecode = 9
             and itemtypesubcode in (1,0)

          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            SET @is_error_var = 1
            SET @o_error_code = -1
            SET @errormsg_var = 'Unable to approve project: Error counting gentablesitemtype table - elementtype works(' + cast(@error_var AS VARCHAR) + ').'
            CLOSE keydate_cur 
            DEALLOCATE keydate_cur 
            GOTO ExitHandler
          END

          if @v_title_cnt > 0 or @v_work_cnt > 0 begin
            SET @v_loop_total = 1

            -- if linkworktotitleind (gen3ind) is false, but gentablesitemtype has been setup for title and work, 
            -- create separate element records for title and work
            if @v_title_cnt > 0 and @v_work_cnt > 0 and @v_linkworktotitleind = 0 begin
              SET @v_loop_total = 2
            end
          
            SET @v_loop_cnt = 0
            WHILE @v_loop_cnt < @v_loop_total BEGIN
              SET @v_loop_cnt = @v_loop_cnt + 1

              -- if gentablesitemtype setup for titles, set bookkey,printingkey on element 
              SET @v_linked_bookkey = null
              SET @v_linked_printingkey = null
              IF @v_title_cnt > 0 BEGIN
                IF @v_loop_total = 1 OR (@v_loop_total = 2 AND @v_loop_cnt = 1) BEGIN
                  SET @v_linked_bookkey = @bookkey_var
                  SET @v_linked_printingkey = @printingkey_var
                END
              END

              -- if gentablesitemtype setup for works, set projectkey on element to work projectkey 
              SET @v_linked_projectkey = null
              IF @v_work_cnt > 0 BEGIN  
                IF @v_loop_total = 1 OR (@v_loop_total = 2 AND @v_loop_cnt = 2) BEGIN
                  SET @v_linked_projectkey = @v_work_projectkey
                END
              END

              -- Generate new elementkey
              execute get_next_key 'QSIADMIN',@new_elementkey_var OUTPUT

              -- taqprojectelement
              insert into taqprojectelement
                (taqelementkey, taqelementtypecode, taqelementtypesubcode, taqprojectkey, bookkey, printingkey,
                globalcontactkey, globalcontactkey2, taqelementnumber, taqelementdesc, addtlinfokey, sortorder, 
                rolecode1, rolecode2, elementstatus, lastuserid, lastmaintdate, startpagenumber, endpagenumber)
              select @new_elementkey_var, taqelementtypecode, taqelementtypesubcode, @v_linked_projectkey, @v_linked_bookkey, 
                @v_linked_printingkey, globalcontactkey, globalcontactkey2,taqelementnumber, taqelementdesc,
                addtlinfokey, sortorder, rolecode1, rolecode2, elementstatus, 
                @lastuserid_var, getdate(), startpagenumber, endpagenumber
              from taqprojectelement
              where taqprojectkey = @i_projectkey and taqelementkey = @taqelementkey_var

              -- element taqproductnumbers
              DECLARE prodnum_cur CURSOR FOR 
               SELECT taqprojectkey, productnumberkey
                 FROM taqproductnumbers
                WHERE elementkey = @taqelementkey_var
                     
               OPEN prodnum_cur 
              FETCH prodnum_cur INTO @prodnum_projectkey_var,@productnumberkey_var

              WHILE @@fetch_status = 0 BEGIN
	              exec get_next_key @lastuserid_var, @new_productnumberkey_var output
              
                insert into taqproductnumbers  
                  (productnumberkey, taqprojectkey, elementkey, productidcode, prefixcode, productnumber, sortorder, 
                   lastuserid, lastmaintdate)
                select @new_productnumberkey_var, @v_linked_projectkey, @new_elementkey_var,  productidcode, prefixcode, productnumber,
                  sortorder, @lastuserid_var, getdate()
                from taqproductnumbers
                where elementkey = @taqelementkey_var and productnumberkey = @productnumberkey_var
                
                FETCH prodnum_cur INTO @prodnum_projectkey_var,@productnumberkey_var
              END
              CLOSE prodnum_cur 
              DEALLOCATE prodnum_cur 

              -- element comments
		          insert into qsicomments
			          (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext,
			           commenthtml, commenthtmllite, lastuserid, lastmaintdate, invalidhtmlind,
			           releasetoeloquenceind)
		          select @new_elementkey_var, commenttypecode, commenttypesubcode, parenttable, commenttext,
			           commenthtml, commenthtmllite, @lastuserid_var, getdate(), invalidhtmlind,
			           releasetoeloquenceind
		          from qsicomments
		          where commentkey = @taqelementkey_var
                
              -- element tasks
			  SET @taqprojecttaskoverride_rowcount = 0
              DECLARE task_cur CURSOR FOR 
               SELECT DISTINCT taqtaskkey,t.datetypecode, t.keyind
                 FROM taqprojecttask t,datetype d
                WHERE t.datetypecode = d.datetypecode AND
                      (taqelementkey = @taqelementkey_var) AND
					  taqprojectkey = @i_projectkey
				UNION
				SELECT DISTINCT taqtaskkey,t.datetypecode, t.keyind
				FROM taqprojecttask t,datetype d
				WHERE taqtaskkey IN (
				SELECT DISTINCT taqtaskkey from taqprojecttaskoverride where taqelementkey = @taqelementkey_var)
       
              OPEN task_cur 
              
              --PRINT 'element tasks for element=' + convert(varchar, @taqelementkey_var) + ':'
              
              FETCH task_cur INTO @taqtaskkey_var,@taqtaskdatetypecode_var, @keyind_var  

              WHILE @@fetch_status = 0 BEGIN

                select @v_title_task_cnt = count(*)
                  from gentablesitemtype
                 where tableid = 323
                   and datacode = @taqtaskdatetypecode_var
                   and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
                   and itemtypecode = 1
                   and itemtypesubcode in (1,0)

                SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
                IF @error_var <> 0 BEGIN
                  SET @is_error_var = 1
                  SET @o_error_code = -1
                  SET @errormsg_var = 'Unable to approve project: Error counting gentablesitemtype table - datetype titles(' + cast(@error_var AS VARCHAR) + ').'
                  CLOSE keydate_cur 
                  DEALLOCATE keydate_cur 
                  GOTO ExitHandler
                END

			  SELECT @v_restriction_value_title = 1
			  select @v_restriction_value_title = relateddatacode
				from gentablesitemtype
			   where tableid = 323
				 and datacode = @taqtaskdatetypecode_var
				 and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
				 and itemtypecode = 1
				 and itemtypesubcode in (1,0)

                select @v_work_task_cnt = count(*)
                  from gentablesitemtype
                 where tableid = 323
                   and datacode = @taqtaskdatetypecode_var
                   and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
                   and itemtypecode = 9
                   and itemtypesubcode in (1,0)

                SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
                IF @error_var <> 0 BEGIN
                  SET @is_error_var = 1
                  SET @o_error_code = -1
                  SET @errormsg_var = 'Unable to approve project: Error counting gentablesitemtype table - datetype works(' + cast(@error_var AS VARCHAR) + ').'
                  CLOSE keydate_cur 
                  DEALLOCATE keydate_cur 
                  GOTO ExitHandler
                END

			  SELECT @v_restriction_value_work = 1
			  select @v_restriction_value_work = relateddatacode
				from gentablesitemtype
			   where tableid = 323
				 and datacode = @taqtaskdatetypecode_var
				 and COALESCE(datasubcode,0) in (@elementtypesubcode_var,0)
				 and itemtypecode = 9
				 and itemtypesubcode in (1,0)

                if @v_title_task_cnt > 0 or @v_work_task_cnt > 0 begin
                  SET @v_loop_total = 1     
 
                 --gentablesitemtype has been setup for title and work,create separate element records for title and work
                 if @v_title_task_cnt > 0 and @v_work_task_cnt > 0 begin
                    SET @v_loop_total = 2
                  end
                
                  SET @v_loop_cnt = 0   

				  SET @v_copy_elementkey = NULL
				  SET @v_new_elementkey = NULL 

				  SELECT @v_copy_elementkey = taqelementkey
				  FROM taqprojecttask q
				  WHERE taqprojectkey = @i_projectkey AND q.taqtaskkey = @taqtaskkey_var

				  IF (@v_copy_elementkey IS NULL) BEGIN
					  select @taqprojecttaskoverride_rowcount = count(*)
					  from taqprojecttaskoverride
					  where taqtaskkey = @taqtaskkey_var AND taqelementkey = @taqelementkey_var
				      
					  SET @v_new_elementkey = NULL
				  END
				  ELSE BEGIN
					  SET @v_new_elementkey = @new_elementkey_var
				  END

				  IF ((@v_copy_elementkey IS NULL AND @taqprojecttaskoverride_rowcount > 0) OR (@v_copy_elementkey IS NOT NULL)) BEGIN
					  WHILE @v_loop_cnt < @v_loop_total BEGIN
						SET @v_loop_cnt = @v_loop_cnt + 1 
					    SET @insert_in_taqprojecttask = 0
						SET @o_returncode = 0
						-- if gentablesitemtype setup for titles, set bookkey,printingkey on taqprojecttask 
						SET @v_linked_bookkey = null
						SET @v_linked_printingkey = null
						IF @v_title_task_cnt > 0 BEGIN
						  IF @v_loop_total = 1 OR (@v_loop_total = 2 AND @v_loop_cnt = 1) BEGIN
							SET @v_linked_bookkey = @bookkey_var
							SET @v_linked_printingkey = @printingkey_var

							IF (@v_linked_bookkey IS NOT NULL AND @v_linked_bookkey > 0 AND @taqtaskdatetypecode_var IS NOT NULL) BEGIN
							   exec dbo.qutl_check_for_restrictions @taqtaskdatetypecode_var, @v_linked_bookkey, @v_linked_printingkey, NULL, NULL, NULL, NULL, 
                                 @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
							   IF @o_error_code <> 0 BEGIN
								  SET @o_error_code = -1
								  SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
								  RETURN
							   END
							   IF (@o_returncode = 2 AND @v_restriction_value_title = 3 AND @keyind_var  = 0) BEGIN
									SET @o_returncode = 0
							   END
							END 

								IF NOT EXISTS (SELECT * FROM #TempTaqprojectaskKeysOldNew t WHERE t.OldTaqtaskkey = @taqtaskkey_var AND BookKey = @bookkey_var AND PrintingKey = @printingkey_var) BEGIN
								   EXEC get_next_key @lastuserid_var, @new_taqtaskkey OUTPUT
								   INSERT INTO #TempTaqprojectaskKeysOldNew (OldTaqtaskkey, NewTaqtaskkey, BookKey, PrintingKey, WorkKey) VALUES (@taqtaskkey_var, @new_taqtaskkey, @bookkey_var, @printingkey_var, 0)
								   SET @insert_in_taqprojecttask = 1
								 END
								 ELSE BEGIN
								   SELECT @new_taqtaskkey = NewTaqtaskkey FROM #TempTaqprojectaskKeysOldNew t WHERE t.OldTaqtaskkey = @taqtaskkey_var AND BookKey = @bookkey_var AND PrintingKey = @printingkey_var
								   SET @insert_in_taqprojecttask = 0
								 END
						  END
						END

						-- if gentablesitemtype setup for works, set projectkey on taqprojecttask to work projectkey 
						SET @v_linked_projectkey = null
						IF @v_work_task_cnt > 0 BEGIN  
						  IF @v_loop_total = 1 OR (@v_loop_total = 2 AND @v_loop_cnt = 2) BEGIN
							SET @v_linked_projectkey = @v_work_projectkey

						    IF (@v_linked_projectkey IS NOT NULL AND @v_linked_projectkey > 0 AND @taqtaskdatetypecode_var IS NOT NULL) BEGIN
							   exec dbo.qutl_check_for_restrictions @taqtaskdatetypecode_var, NULL, NULL, @v_linked_projectkey, NULL, NULL, NULL, 
                                 @o_taqtaskkey output, @o_returncode output, @o_restrictioncode output, @o_error_code output, @o_error_desc output
							   IF @o_error_code <> 0 BEGIN
								  SET @o_error_code = -1
								  SET @o_error_desc = 'Unable to check for title task restrictions: ' + @o_error_desc
								  RETURN
							   END
							   IF (@o_returncode = 3 AND @v_restriction_value_work = 3 AND @keyind_var  = 0) BEGIN
									SET @o_returncode = 0
							   END
						    END 

								IF NOT EXISTS (SELECT * FROM #TempTaqprojectaskKeysOldNew t WHERE t.OldTaqtaskkey = @taqtaskkey_var AND WorkKey = @v_work_projectkey) BEGIN
								   EXEC get_next_key @lastuserid_var, @new_taqtaskkey OUTPUT
								   INSERT INTO #TempTaqprojectaskKeysOldNew (OldTaqtaskkey, NewTaqtaskkey, BookKey, PrintingKey, WorkKey) VALUES (@taqtaskkey_var, @new_taqtaskkey, 0, 0, @v_work_projectkey)
								   SET @insert_in_taqprojecttask = 1
								 END
								 ELSE BEGIN
								   SELECT @new_taqtaskkey = NewTaqtaskkey FROM #TempTaqprojectaskKeysOldNew t WHERE t.OldTaqtaskkey = @taqtaskkey_var AND WorkKey = @v_work_projectkey
								   SET @insert_in_taqprojecttask = 0
								 END
						  END
						END

					  IF @o_returncode = 0 BEGIN
	--							execute get_next_key @lastuserid_var,@new_taqtaskkey OUTPUT
						  IF @insert_in_taqprojecttask = 1 BEGIN
					               
                --PRINT '@datetypecode_var=' + convert(varchar, @datetypecode_var)
                --PRINT '@v_linked_bookkey=' + convert(varchar, @v_linked_bookkey)
                --PRINT '@v_linked_projectkey=' + convert(varchar, @v_linked_projectkey)
					               
							  insert into taqprojecttask
								(taqtaskkey, taqprojectkey, taqelementkey, bookkey, printingkey, orgentrykey, 
								globalcontactkey, rolecode, globalcontactkey2, rolecode2, scheduleind, 
								stagecode, duration, datetypecode, activedate, actualind, keyind, originaldate, 
								taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, taqprojectformatkey,
								lastuserid, lastmaintdate, lockind,startdate,startdateactualind,lag, transactionkey)
								select @new_taqtaskkey, @v_linked_projectkey, @v_new_elementkey, @v_linked_bookkey, @v_linked_printingkey, orgentrykey, 
								  globalcontactkey, rolecode, globalcontactkey2, rolecode2, scheduleind, stagecode, duration, datetypecode, 
								  activedate, actualind, keyind, originaldate, taqtasknote, decisioncode, paymentamt, taqtaskqty, sortorder, 
								  NULL, @lastuserid_var, getdate(), lockind,startdate,startdateactualind,lag, transactionkey
								from taqprojecttask
								where taqtaskkey = @taqtaskkey_var
								  and (taqelementkey = @taqelementkey_var OR taqelementkey IS NULL)
						  END

						   DECLARE taqprojecttaskoverride_cur CURSOR FOR 
							 SELECT scheduleind,lag,sortorder
							   FROM taqprojecttaskoverride
							  WHERE taqelementkey = @taqelementkey_var
								AND taqtaskkey = @taqtaskkey_var
		                           
							OPEN taqprojecttaskoverride_cur 
							FETCH taqprojecttaskoverride_cur INTO @scheduleind_task_var,@lag_task_var,@sortorder_task_var

							WHILE @@fetch_status = 0 BEGIN
							   insert into taqprojecttaskoverride
											(taqtaskkey, taqelementkey, scheduleind, lag, sortorder, lastuserid, lastmaintdate)
									values
										(@new_taqtaskkey, @new_elementkey_var, @scheduleind_task_var,@lag_task_var,@sortorder_task_var,
									  @lastuserid_var, getdate())
				                                            
								FETCH taqprojecttaskoverride_cur INTO @scheduleind_task_var,@lag_task_var,@sortorder_task_var       
							END
							CLOSE taqprojecttaskoverride_cur 
							DEALLOCATE taqprojecttaskoverride_cur
					  END
					END
                  END
                END
                FETCH task_cur INTO @taqtaskkey_var,@taqtaskdatetypecode_var, @keyind_var
              END
              CLOSE task_cur 
              DEALLOCATE task_cur 
                
              -- element misc
	            insert into taqelementmisc 
	              (taqelementkey, misckey, longvalue, floatvalue, textvalue, lastuserid, lastmaintdate)
	            select @new_elementkey_var, misckey, longvalue, floatvalue, textvalue, @lastuserid_var, getdate()
	            from taqelementmisc
	            where taqelementkey = @taqelementkey_var

              -- element filelocations
              DECLARE fileloc_cur CURSOR FOR 
               SELECT filelocationgeneratedkey
                 FROM filelocation
                WHERE taqelementkey = @taqelementkey_var
                     
               OPEN fileloc_cur 
              FETCH fileloc_cur INTO @filelocationgeneratedkey_var

              WHILE @@fetch_status = 0 BEGIN
	              exec get_next_key @lastuserid_var, @new_filelocationgeneratedkey_var output
              
		            insert into filelocation
				            (bookkey, printingkey, filetypecode, fileformatcode, filelocationkey, filestatuscode, 
				            pathname, notes, lastuserid, lastmaintdate, sendtoeloquenceind, sortorder, filelocationgeneratedkey,
				            taqprojectkey, taqelementkey, globalcontactkey, locationtypecode, stagecode, filedescription)
		            select 
		                @primary_bookkey_var, 1, filetypecode, fileformatcode, filelocationkey, filestatuscode, 
				            pathname, notes, @lastuserid_var, getdate(), sendtoeloquenceind, sortorder, @new_filelocationgeneratedkey_var, 
				            null, @new_elementkey_var, globalcontactkey, locationtypecode, stagecode, filedescription
		            from filelocation
		            where taqelementkey = @taqelementkey_var
			            and filelocationgeneratedkey = @filelocationgeneratedkey_var
                
                FETCH fileloc_cur INTO @filelocationgeneratedkey_var
              END
              CLOSE fileloc_cur 
              DEALLOCATE fileloc_cur 

              -- Check to see if Reader Iteration Info needs to be created for Work 
              IF @v_work_cnt > 0 AND @v_linked_projectkey > 0 BEGIN  
                -- Get the elementtypecode for 'Manuscript'
                SELECT @v_manuscriptcode = datacode
                FROM gentables
                WHERE tableid = 287 AND qsicode = 1

                SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
                IF @error_var <> 0 BEGIN
                  SET @is_error_var = 1
                  SET @o_error_code = -1
                  SET @errormsg_var = 'Error getting elementtypecode for Manuscript (gentables 287, qsicode=1).'
                  CLOSE element_cur 
                  DEALLOCATE element_cur 
                  GOTO ExitHandler
                END
                    
                -- Get the elementtypesubcode for 'Iteration' (subgentable 287, qsicode=1)
                SELECT @v_iterationcode = datasubcode
                FROM subgentables
                WHERE tableid = 287 AND datacode = @v_manuscriptcode AND qsicode = 1

                SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
                IF @error_var <> 0 BEGIN
                  SET @is_error_var = 1
                  SET @o_error_code = -1
                  SET @errormsg_var = 'Could not get elementtypesubcode for Iteration (subgentable 287, qsicode=1).'
                  CLOSE element_cur 
                  DEALLOCATE element_cur 
                  GOTO ExitHandler
                END
                
                select @v_taqelementtypecode=taqelementtypecode, @v_taqelementtypesubcode = COALESCE(taqelementtypesubcode,0)
                from taqprojectelement
                where taqelementkey = @new_elementkey_var

                SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
                IF @error_var <> 0 BEGIN
                  SET @is_error_var = 1
                  SET @o_error_code = -1
                  SET @errormsg_var = 'Could not access taqprojectelement.'
                  CLOSE element_cur 
                  DEALLOCATE element_cur 
                  GOTO ExitHandler
                END
                
                IF @v_taqelementtypecode = @v_manuscriptcode AND @v_taqelementtypesubcode = @v_iterationcode BEGIN
                  -- Get the rolecode for 'Reader' (gentable 285, qsicode=1)
                  SELECT @v_readerrolecode = datacode
                  FROM gentables 
                  WHERE tableid = 285 AND qsicode = 3

                  SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
                  IF @error_var <> 0 BEGIN
                    SET @is_error_var = 1
                    SET @o_error_code = -1
                    SET @errormsg_var = 'Error getting rolecode for Reader (gentables 285, qsicode=3).'
                    CLOSE element_cur 
                    DEALLOCATE element_cur 
                    GOTO ExitHandler
                  END
                  
                  -- Loop through reader records for the work
                  DECLARE reader_cur CURSOR FOR
                    SELECT r.taqprojectcontactrolekey, c.globalcontactkey
                    FROM taqprojectcontactrole r, taqprojectcontact c
                    WHERE r.taqprojectkey = c.taqprojectkey AND
                      r.taqprojectcontactkey = c.taqprojectcontactkey AND
                      r.taqprojectkey = @v_linked_projectkey AND
                      r.rolecode = @v_readerrolecode

                  OPEN reader_cur

                  FETCH NEXT FROM reader_cur INTO @v_taqprojectcontactrolekey, @v_globalcontactkey

                  WHILE (@@FETCH_STATUS = 0) 
                  BEGIN
                    INSERT INTO taqprojectreaderiteration
                      (taqprojectkey, taqprojectcontactrolekey, taqelementkey, readitrecommendation, readitsummary, 
                      statuscode, ratingcode, recommendationcode, lastuserid, lastmaintdate)
                    SELECT @v_linked_projectkey, @v_taqprojectcontactrolekey, @new_elementkey_var, i.readitrecommendation, i.readitsummary, 
                      i.statuscode, i.ratingcode, i.recommendationcode, @lastuserid_var, getdate()
                    FROM taqprojectreaderiteration i, taqprojectcontactrole r, taqprojectcontact c
                    WHERE i.taqprojectcontactrolekey = r.taqprojectcontactrolekey AND
                      r.taqprojectcontactkey = c.taqprojectcontactkey AND
                      c.globalcontactkey = @v_globalcontactkey AND
                      r.rolecode = @v_readerrolecode AND
                      i.taqprojectkey = @i_projectkey AND
                      i.taqelementkey = @taqelementkey_var 

                    FETCH NEXT FROM reader_cur INTO @v_taqprojectcontactrolekey, @v_globalcontactkey
                  END

                  CLOSE reader_cur 
                  DEALLOCATE reader_cur                  
                END
              END             
            END            
          END 
           
          FETCH element_cur 
           INTO @taqelementkey_var,@elementtypecode_var,@elementtypesubcode_var,
                @taqelementsortorder_var,@elementname_var,@elementdesc_var,@v_linkworktotitleind
        END
        CLOSE element_cur 
        DEALLOCATE element_cur 
      END
      
      -- bookprice
      -- Generate pricekey
      execute get_next_key 'QSIADMIN',@pricekey_var OUTPUT

      execute qtitle_get_next_history_order @bookkey_var, 0, 'bookprice', @lastuserid_var, 
        @v_history_order OUTPUT, @o_error_code OUTPUT, @o_error_desc OUTPUT

      IF @o_error_code < 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @o_error_desc = 'Unable to approve project: Error getting next bookprice history_order (' + @o_error_desc + ').'
        GOTO ExitHandler
      END

      INSERT INTO bookprice (bookkey,pricekey,pricetypecode,currencytypecode,budgetprice,
                             activeind,sortorder,effectivedate,lastuserid,lastmaintdate, history_order)
      SELECT @bookkey_var,@pricekey_var,pricetypecode,currencytypecode,@price_var,1,1,
             getdate(),@lastuserid_var,getdate(), @v_history_order
        FROM filterpricetype
       WHERE filterkey = 7

      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to approve project: Error inserting into bookprice table (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END 

      -- booksubjectcategory
      INSERT INTO booksubjectcategory (bookkey,subjectkey,categorytableid,categorycode,categorysubcode,
                                       categorysub2code,sortorder,lastuserid,lastmaintdate)
      SELECT @bookkey_var,c.subjectkey,c.categorytableid,c.categorycode,c.categorysubcode,c.categorysub2code,
             c.sortorder,@lastuserid_var,getdate()
        FROM taqprojectsubjectcategory c,gentablesdesc g,taqproject p
       WHERE c.taqprojectkey = @i_projectkey AND
             c.taqprojectkey = p.taqprojectkey AND
             dbo.qproject_is_sent_to_tmm(N'subjectcategory',g.tableid,0,COALESCE(p.usageclasscode,0)) = 1 AND
             c.categorytableid = g.tableid AND
             g.subjectcategoryind = 1 AND
             categorytableid not in (339,317)
             
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to approve project: Error inserting into booksubjectcategory table (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END 
    END
    
    --PRINT '@setuprequiredforsendtotmm_var: ' + convert(varchar, @setuprequiredforsendtotmm_var)
    
    -- Users may have already selected orgentries and the template to copy from
    IF @setuprequiredforsendtotmm_var = 2 BEGIN
      -- only update orgentries if all levels are filled in
      SELECT @v_org_count_max = count(*) 
        FROM orglevel
        
      SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
      IF @error_var <> 0 BEGIN
        SET @is_error_var = 1
        SET @o_error_code = -1
        SET @errormsg_var = 'Unable to approve project: Error accessing orglevel table (' + cast(@error_var AS VARCHAR) + ').'
        GOTO ExitHandler
      END 
      
      IF @v_org_count_max > 0 BEGIN
        SELECT @v_org_count = count(*) 
          FROM taqprojecttitleorgentry
         WHERE taqprojectformatkey = @taqprojectformatkey_var

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @is_error_var = 1
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project: Error accessing taqprojecttitleorgentry table (' + cast(@error_var AS VARCHAR) + ').'
          GOTO ExitHandler
        END 
        
        -- update bookorgentry from taqprojecttitleorgentry (or insert if missing)
        IF @v_org_count = @v_org_count_max BEGIN
        
          DECLARE cur_projecttitleorg CURSOR FOR
            SELECT orglevelkey, orgentrykey
            FROM taqprojecttitleorgentry
            WHERE taqprojectformatkey = @taqprojectformatkey_var
            
          OPEN cur_projecttitleorg
          
          FETCH NEXT FROM cur_projecttitleorg INTO @orglevelkey_var, @orgentrykey_var

          WHILE (@@FETCH_STATUS <> -1)
          BEGIN
            
            SELECT @count_var = COUNT(*)
            FROM bookorgentry
            WHERE bookkey = @bookkey_var AND orglevelkey = @orglevelkey_var
            
            IF @count_var > 0
              UPDATE bookorgentry
                 SET orgentrykey = (SELECT orgentrykey FROM taqprojecttitleorgentry tpo
                                     WHERE tpo.taqprojectformatkey = @taqprojectformatkey_var
                                       AND tpo.orglevelkey = bookorgentry.orglevelkey),
                     lastuserid = @lastuserid_var,
                     lastmaintdate = getdate()
               WHERE bookkey = @bookkey_var AND orglevelkey = @orglevelkey_var   
            ELSE  
              INSERT INTO bookorgentry
                (bookkey, orglevelkey, orgentrykey, lastuserid, lastmaintdate)
					    VALUES
					      (@bookkey_var, @orglevelkey_var, @orgentrykey_var, @lastuserid_var, getdate())
                  
            SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
            IF @error_var <> 0 BEGIN
              SET @is_error_var = 1
              SET @o_error_code = -1
              SET @errormsg_var = 'Unable to approve project: Error updating bookorgentry table (' + cast(@error_var AS VARCHAR) + ').'
              GOTO ExitHandler
            END
                             
            FETCH NEXT FROM cur_projecttitleorg INTO @orglevelkey_var, @orgentrykey_var
          END

          CLOSE cur_projecttitleorg 
          DEALLOCATE cur_projecttitleorg 
          
        END
      END

      -- Copy components and specs	  	                  
	  SELECT @v_itemtype_qsicode = g.qsicode, @v_usageclass_qsicode = sg.qsicode,
		@v_itemtypecode = sg.datacode, @v_usageclasscode = sg.datasubcode 
	  FROM taqproject p
	  JOIN gentables g
		ON p.searchitemcode = g.datacode
		AND g.tableid = 550
	  JOIN subgentables sg
		ON p.searchitemcode = sg.datacode
		AND p.usageclasscode = sg.datasubcode
		AND sg.tableid = 550
	  WHERE taqprojectkey = @v_projectkey 
	             
	  SET @o_error_desc = ''	
	  DECLARE taqversionformat_cursor CURSOR FOR
		SELECT taqprojectformatkey
		FROM taqversionformat
		WHERE taqprojectkey = @v_projectkey

		OPEN taqversionformat_cursor

		FETCH taqversionformat_cursor
		INTO @v_TaqProjectFormatKey

		WHILE (@@FETCH_STATUS = 0)
		BEGIN  		

		  EXEC qspec_apply_specificationtemplate @v_projectkey, @i_projectkey,
			  @v_TaqProjectFormatKey, @v_itemtypecode, @v_usageclasscode, @lastuserid_var, 2, @o_error_code OUTPUT, @o_error_desc OUTPUT		

		  IF @o_error_code <> 0 BEGIN
			SET @is_error_var = 1  
			SET @o_error_code = -1
			SET @errormsg_var = 'Unable to approve project: Error copying Production Specifications ' + @o_error_desc
			GOTO ExitHandler
		  END 
			
		  FETCH taqversionformat_cursor
		  INTO @v_TaqProjectFormatKey
		END

	  CLOSE taqversionformat_cursor
	  DEALLOCATE taqversionformat_cursor	      
      
      -- apply template
      IF @v_templatekey > 0 BEGIN

        EXEC qtitle_copy_title @bookkey_var, @printingkey_var, @v_templatekey, 1, NULL, NULL, 
          @lastuserid_var, @projecttitleprefix_var, @o_error_code OUTPUT, @o_error_desc OUTPUT
          
        IF @o_error_code <> 0 BEGIN
          SET @is_error_var = 1  
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project (copy title): ' + @o_error_desc
          GOTO ExitHandler
        END         
      END
      
      ELSE BEGIN  --No template selected
      
        -- Get the initial bookverification status
        SELECT @v_initial_status = COALESCE(datacode,0), @v_datadesc = LTRIM(RTRIM(datadesc))
        FROM gentables
        WHERE tableid = 513 AND qsicode = 1

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 or @rowcount_var = 0 BEGIN
          SET @v_initial_status = 0
        END

        -- Check the client option to see if verification should run
	      SELECT @v_client_option = optionvalue
	      FROM clientoptions
	      WHERE optionid = 71

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @v_client_option = 0
        END
        
        -- Loop to insert initial bookverification rows and run verification procedure if necessary
        DECLARE crBookVer CURSOR FOR
          SELECT datacode, LTRIM(RTRIM(datadesc)), alternatedesc1
          FROM gentables
          WHERE tableid = 556
            AND LOWER(deletestatus) = 'n'

        OPEN crBookVer 

        FETCH NEXT FROM crBookVer INTO @v_veriftype, @v_verifdesc, @v_proc_name

        WHILE (@@FETCH_STATUS <> -1)
        BEGIN
          SET @v_datadesc = @v_verifdesc + ' - ' + @v_datadesc
          
          INSERT INTO bookverification
            (bookkey, verificationtypecode, titleverifystatuscode, lastuserid, lastmaintdate)
          VALUES
            (@bookkey_var, @v_veriftype, @v_initial_status, @lastuserid_var, getdate())
            
          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            SET @is_error_var = 1
            SET @o_error_code = -1
            SET @errormsg_var = 'Unable to approve project: Error updating bookverification table (' + cast(@error_var AS VARCHAR) + ').'
            CLOSE crBookVer
            DEALLOCATE crBookVer            
            GOTO ExitHandler
          END
          
          EXEC qtitle_update_titlehistory 'bookverification', 'titleverifystatuscode', @bookkey_var, @printingkey_var, NULL,
            @v_datadesc, 'INSERT', @lastuserid_var, NULL, 'Title Verification', @o_error_code OUTPUT, @o_error_desc OUTPUT            
         
          IF @o_error_code <> 0 BEGIN
            SET @is_error_var = 1  
            SET @o_error_code = -1            
            SET @errormsg_var = 'Unable to approve project (bookverification title history): ' + @o_error_desc
            CLOSE crBookVer
            DEALLOCATE crBookVer
            GOTO ExitHandler
          END         
          
          IF @v_client_option = 1 AND @v_proc_name IS NOT NULL
          BEGIN
		        IF @v_proc_name = 'cs_verification' BEGIN	
							SET @v_sql = N'exec ' + @v_proc_name + 
								' @i_bookkey, @i_printingkey, @i_verificationtypecode, @i_username, @v_error_code OUTPUT, @v_error_desc OUTPUT'
                
							EXECUTE sp_executesql @v_sql, 
								N'@i_bookkey int, @i_printingkey int, @i_verificationtypecode int,
									@i_username varchar(15), @v_error_code INT OUTPUT, @v_error_desc VARCHAR(2000) OUTPUT', 
								@i_bookkey = @bookkey_var, 
								@i_printingkey = @printingkey_var, 
								@i_verificationtypecode = @v_veriftype, 
								@i_username = @lastuserid_var,
								@v_error_code = @o_error_code OUTPUT,
								@v_error_desc = @o_error_desc OUTPUT
							
						END
						ELSE BEGIN
							SET @v_sql = N'EXEC ' + @v_proc_name + ' ' + CONVERT(VARCHAR, @bookkey_var) + ',' + CONVERT(VARCHAR, @printingkey_var) + ',' + CONVERT(VARCHAR, @v_veriftype) + ',''' + @lastuserid_var + ''''
	    				EXEC sp_executesql @v_sql
	    	    END
					END
          
          FETCH NEXT FROM crBookVer INTO @v_veriftype, @v_verifdesc, @v_proc_name
        END

        CLOSE crBookVer 
        DEALLOCATE crBookVer      
      END
      
    END
    
    -- Case 10799 - If the client option 75, �Setup required for Send to TMM process�. is 0 (false), apply the default template 
    -- automatically to this book if there is one. 
    IF @setuprequiredforsendtotmm_var = 0
    BEGIN
      SET @v_template_bookkey = 0
      
      -- Find the default template based on title's orgentries - search backwards up thru the orglevels looking for a tmmweb template
      DECLARE bookorgentry_cur CURSOR FOR    
        SELECT orgentrykey, orglevelkey
        FROM bookorgentry
        WHERE bookkey = @bookkey_var
        ORDER BY orglevelkey DESC

      OPEN bookorgentry_cur
      
      FETCH bookorgentry_cur INTO @orgentrykey_var, @orglevelkey_var

      WHILE @@fetch_status = 0 BEGIN

        SELECT @count_var = COUNT(*)
        FROM book b, printing p, bookorgentry o
        WHERE b.bookkey = o.bookkey AND
          b.bookkey = p.bookkey AND
          UPPER(b.standardind) = 'Y' AND
          b.tmmwebtemplateind = 1 AND
          o.orglevelkey = @orglevelkey_var AND 
          o.orgentrykey = @orgentrykey_var AND
          dbo.qutl_verify_template(b.bookkey, @orglevelkey_var) = 1
          
        IF @count_var > 0
        BEGIN
          SELECT @v_template_bookkey = b.bookkey, @v_template_printingkey = p.printingkey
          FROM book b, printing p, bookorgentry o
          WHERE b.bookkey = o.bookkey AND
            b.bookkey = p.bookkey AND
            UPPER(b.standardind) = 'Y' AND
            b.tmmwebtemplateind = 1 AND
            o.orglevelkey = @orglevelkey_var AND 
            o.orgentrykey = @orgentrykey_var AND
            dbo.qutl_verify_template(b.bookkey, @orglevelkey_var) = 1

          BREAK
        END

        FETCH bookorgentry_cur INTO @orgentrykey_var, @orglevelkey_var
      END
      
      CLOSE bookorgentry_cur 
      DEALLOCATE bookorgentry_cur
            
      IF @v_template_bookkey > 0
      BEGIN

        EXEC qtitle_copy_title @bookkey_var, @printingkey_var, @v_template_bookkey, @v_template_printingkey, NULL, NULL, 
          @lastuserid_var, @projecttitleprefix_var, @o_error_code OUTPUT, @o_error_desc OUTPUT
          
        IF @o_error_code <> 0 BEGIN
          SET @is_error_var = 1  
          SET @o_error_code = -1
          SET @errormsg_var = 'Unable to approve project (copy title): ' + @o_error_desc
          GOTO ExitHandler
        END         
      END
      ELSE BEGIN  --No template found    
              
        -- Get the initial bookverification status
        SELECT @v_initial_status = COALESCE(datacode,0), @v_datadesc = LTRIM(RTRIM(datadesc))
        FROM gentables
        WHERE tableid = 513 AND qsicode = 1

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 or @rowcount_var = 0 BEGIN
          SET @v_initial_status = 0
        END

        -- Check the client option to see if verification should run
	      SELECT @v_client_option = optionvalue
	      FROM clientoptions
	      WHERE optionid = 71

        SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
        IF @error_var <> 0 BEGIN
          SET @v_client_option = 0
        END
        
        -- Loop to insert initial bookverification rows and run verification procedure if necessary
        DECLARE crBookVer CURSOR FOR
          SELECT datacode, LTRIM(RTRIM(datadesc)), alternatedesc1
          FROM gentables
          WHERE tableid = 556

        OPEN crBookVer 

        FETCH NEXT FROM crBookVer INTO @v_veriftype, @v_verifdesc, @v_proc_name

        WHILE (@@FETCH_STATUS <> -1)
        BEGIN
          SET @v_datadesc = @v_verifdesc + ' - ' + @v_datadesc
          
          INSERT INTO bookverification
            (bookkey, verificationtypecode, titleverifystatuscode, lastuserid, lastmaintdate)
          VALUES
            (@bookkey_var, @v_veriftype, @v_initial_status, @lastuserid_var, getdate())
            
          SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
          IF @error_var <> 0 BEGIN
            SET @is_error_var = 1
            SET @o_error_code = -1
            SET @errormsg_var = 'Unable to approve project: Error updating bookverification table (' + cast(@error_var AS VARCHAR) + ').'
            CLOSE crBookVer
            DEALLOCATE crBookVer            
            GOTO ExitHandler
          END
          
          EXEC qtitle_update_titlehistory 'bookverification', 'titleverifystatuscode', @bookkey_var, @printingkey_var, NULL,
            @v_datadesc, 'INSERT', @lastuserid_var, NULL, 'Title Verification', @o_error_code OUTPUT, @o_error_desc OUTPUT            
         
          IF @o_error_code <> 0 BEGIN
            SET @is_error_var = 1  
            SET @o_error_code = -1            
            SET @errormsg_var = 'Unable to approve project (bookverification title history): ' + @o_error_desc
            CLOSE crBookVer
            DEALLOCATE crBookVer
            GOTO ExitHandler
          END         
          
          IF @v_client_option = 1 AND @v_proc_name IS NOT NULL
          BEGIN
		        IF @v_proc_name = 'cs_verification' BEGIN	
							SET @v_sql = N'exec ' + @v_proc_name + 
								' @i_bookkey, @i_printingkey, @i_verificationtypecode, @i_username, @v_error_code OUTPUT, @v_error_desc OUTPUT'
                
							EXECUTE sp_executesql @v_sql, 
								N'@i_bookkey int, @i_printingkey int, @i_verificationtypecode int,
									@i_username varchar(15), @v_error_code INT OUTPUT, @v_error_desc VARCHAR(2000) OUTPUT', 
								@i_bookkey = @bookkey_var, 
								@i_printingkey = @printingkey_var, 
								@i_verificationtypecode = @v_veriftype, 
								@i_username = @lastuserid_var,
								@v_error_code = @o_error_code OUTPUT,
								@v_error_desc = @o_error_desc OUTPUT
							
						END
						ELSE BEGIN
							SET @v_sql = N'EXEC ' + @v_proc_name + ' ' + CONVERT(VARCHAR, @bookkey_var) + ',' + CONVERT(VARCHAR, @printingkey_var) + ',' + CONVERT(VARCHAR, @v_veriftype) + ',''' + @lastuserid_var + ''''
	    				EXEC sp_executesql @v_sql
	    	    END
					END
          
          FETCH NEXT FROM crBookVer INTO @v_veriftype, @v_verifdesc, @v_proc_name
        END

        CLOSE crBookVer 
        DEALLOCATE crBookVer      
      END         
    END   

    IF @primaryformatind_var = 1 BEGIN
		--Translate the competitive and comparative titles from taqprojecttitles to associatedtitles
		EXEC dbo.qproject_copy_project_comp_titles @i_projectkey, @bookkey_var, 'QSIADMIN',@o_error_code OUTPUT,@errormsg_var OUTPUT
		SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
		IF @o_error_code <> 0 BEGIN
			SET @is_error_var = 1
			SET @o_error_code = -1
			SET @errormsg_var = 'Unable to translate competitive/comparitive titles: Failed calling qproject_copy_project_comp_titles'
			GOTO ExitHandler
		  END
	 END 

    IF @autosetpriceactiveind = 1 BEGIN
		-- call the Validate Price Active Ind and Dates procedure with message type = 1 (include title/product), validate type = 1(check active indicators only)
		exec dbo.qtitle_price_validate_activeindanddates @bookkey_var,1,1, @o_error_code output, @o_error_desc output
		IF @o_error_code <> 0 BEGIN
		   SET @is_error_var = 1  
		   SET @o_error_code = -1
		   SET @errormsg_var = 'Unable to approve project (Validate Price Active Ind and Dates): ' + @o_error_desc
		   GOTO ExitHandler
		END  
	 END 
	 
	--Add a Summary component with specification items if it not present for the Title's first Printings
	 EXEC dbo.qprinting_insert_first_printings_summarycomponent @v_projectkey, 0, 0, @lastuserid_var,@o_error_code OUTPUT,@errormsg_var OUTPUT
	 
	 SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
	 IF @o_error_code <> 0 BEGIN
		 SET @is_error_var = 1
		 SET @o_error_code = -1
		 GOTO ExitHandler
	 END 	 

    FETCH project_format_cur 
    INTO @taqprojectformatkey_var,@seasoncode_var,@seasonfirmind_var,@mediatypecode_var,
      @mediatypesubcode_var,@discountcode_var,@price_var,@initialrun_var,@projectdollars_var,
      @marketingplancode_var,@primaryformatind_var,@isbn_var,@isbn10_var,@ean_var,@ean13_var,
      @gtin_var,@format_bookkey_var,@formatdesc_var,@isbnprefixcode_var,@projecttitle_var,
      @projectsubtitle_var,@projecttype_var,@projecteditionnumcode_var,@projectseriescode_var,
      @projectstatuscode_var,@projecttitleprefix_var,@projecteditiontypecode_var,@projecteditiondesc_var,
      @projectvolumenumber_var,@termsofagreement_var,@projectcontractkey_var,@eanprefixcode_var,@gtin14_var,
      @lccn_var,@dsmarc_var,@itemnumber_var,@upc_var,@additionaleditioninfo_var,@v_templatekey
  END
     
  IF @newprojectstatuscode_var > 0
  BEGIN
    -- Lock the Exchange Rate (if exists) for all stages
    DECLARE plstages_cur CURSOR FOR 
      SELECT plstagecode, exchangerate, exchangeratelockind 
      FROM taqplstage 
      WHERE taqprojectkey = @i_projectkey 

    OPEN plstages_cur 

    FETCH plstages_cur INTO @v_plstagecode, @v_exchangerate, @v_exchangeratelockind

    WHILE @@fetch_status = 0
    BEGIN
    
      IF @v_exchangerate IS NOT NULL AND @v_exchangeratelockind = 0
        UPDATE taqplstage
        SET exchangeratelockind = 1
        WHERE taqprojectkey = @i_projectkey AND plstagecode = @v_plstagecode
    
      FETCH plstages_cur INTO @v_plstagecode, @v_exchangerate, @v_exchangeratelockind 
    END
    
    CLOSE plstages_cur
    DEALLOCATE plstages_cur
    
    -- set project status on taqproject
    UPDATE taqproject
       SET taqprojectstatuscode = @newprojectstatuscode_var
     WHERE taqprojectkey = @i_projectkey 

    SELECT @error_var = @@ERROR, @rowcount_var = @@ROWCOUNT
    IF @error_var <> 0 BEGIN
      SET @is_error_var = 1
      SET @o_error_code = -1
      SET @errormsg_var = 'Unable to approve project: Error updating taqproject table (' + cast(@error_var AS VARCHAR) + ').'
      GOTO ExitHandler
    END 
  END
    
    -- print qsicomment check.      
   -- select top (20) * FROM qsicomments c order BY c.commentkey desc


  COMMIT TRANSACTION @TranName

  ExitHandler:
  DROP TABLE #TempTaqprojectaskKeysOldNew
  IF @is_error_var = 1 BEGIN
    IF @@trancount > 0 BEGIN
      ROLLBACK TRANSACTION @TranName
    END
    SET @o_error_desc = @errormsg_var
  END

  CLOSE project_format_cur 
  DEALLOCATE project_format_cur 
  
GO

GRANT EXEC ON qproject_transmit_to_tmm TO PUBLIC
GO
