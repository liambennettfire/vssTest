if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_sync_version_to_acq_project') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_sync_version_to_acq_project
GO

CREATE PROCEDURE qpl_sync_version_to_acq_project
 (@i_projectkey     integer,
  @i_plstagecode    integer,
  @i_plversionkey   integer,
  @i_userkey        integer,
  @i_copy_select_data_from_pl_to_acq_project	integer,
  @o_error_code     integer output,
  @o_error_desc     varchar(2000) output)
AS

/*****************************************************************************************************
**  Name: qpl_sync_to_acq_project
**  Desc: This stored procedure syncs selected P&L Version to Acquisiton Project
**        Formats, selected comments and selected categories will be synced. 
**        
**
**  Auth: Kusum
**  Date: October 31, 2011
*****************************************************************************************************************
**  Change History
*****************************************************************************************************************
**  Date:     Author:   Description:
**  --------  -------   ------------------------------------------------------------------------
**  03/28/17  Colman    Case 44038 - Add selectedversionformatkey column to taqprojecttitle
**  07/24/18  Colman    TM-584     - Support for "shared cost" formats
*****************************************************************************************************/

DECLARE
  @v_isopentrans TINYINT,
  @v_userid VARCHAR(30),
  @v_taqprojectformatkey	INT,
  @v_selectedversionformatkey INT,
  @v_activeprice  FLOAT,
  @v_mediatypecode	INT,
  @v_mediatypesubcode	INT,
  @v_count	INT,
  @v_count1	INT,
  @v_count2	INT,
  @v_count3	INT,
  @v_quantity	INT,
  @v_taqprojectformatdesc VARCHAR(120),
  @v_version_commentkey INT,
  @v_project_commentkey	INT,
  @v_new_version_commentkey	INT,
  @v_commenttext	varchar(max),
  @v_commenthtml	varchar(max),
  @v_commenthtmllite	varchar(max),
  @v_invalidhtmlind	INT,
  @v_releasetoeloquenceind	TINYINT,
  @v_sortorder INT,	
  @v_clientdefaultvalue	INT,
  @v_cur_marketkey	INT, 
  @v_marketcode	INT, 
  @v_marketsubcode	INT, 
  @v_marketsub2code	INT, 
  @v_marketgrowthrate	INT, 
  @v_subjectkey	INT,
  @v_error	INT,
  @v_rowcount	INT,
  @v_commenttype	INT,
  @v_commentsubtype	INT,
  @v_titlerolecode INT,
  @v_versionformatkey INT,
  @v_primaryformatind TINYINT,
  @v_updateprimaryind TINYINT,
  @v_projectrolecode INT

BEGIN

	SET @v_isopentrans = 0
	SET @o_error_code = 0
	SET @o_error_desc = ''

  -- exec qutl_trace 'qpl_sync_version_to_acq_project', '@i_projectkey', @i_projectkey, NULL,
    -- '@i_plstagecode', @i_plstagecode, NULL,
    -- '@i_plversionkey', @i_plversionkey

	IF @i_projectkey IS NULL OR @i_projectkey <= 0 BEGIN
		SET @o_error_desc = 'Invalid projectkey.'
		GOTO RETURN_ERROR
	END

	IF @i_plstagecode = 0 AND @i_plversionkey = 0 BEGIN
		SET @o_error_desc = 'Invalid versionkey.'
		GOTO RETURN_ERROR
	END

	-- Get the User ID for the passed userkey
	SET @v_userid = 'SyncPLVer'
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

	IF @i_copy_select_data_from_pl_to_acq_project = 0 BEGIN
		SET @o_error_desc = 'Client option value is not set to sync P&L version to Acquisition Project.'
		GOTO RETURN_ERROR
	END
	
  SELECT @v_titlerolecode = datacode
  FROM gentables
  WHERE tableid = 605 AND qsicode = 2
  
	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 OR @v_rowcount <= 0 BEGIN
	 SET @o_error_desc = 'Could not get Title Role datacode for Formats (qsicode=2).'
	 GOTO RETURN_ERROR
	END  

	-- ***** BEGIN TRANSACTION ****  
	BEGIN TRANSACTION
	SET @v_isopentrans = 1

  SET @v_updateprimaryind = 0

  -- formats that exist on Project and not on the P&L Version
  -- exec qutl_trace 'qpl_sync_version_to_acq_project', 'formats that exist on Project and not on the P&L Version'
  DECLARE formats_project_cur CURSOR FOR
    SELECT taqprojectformatkey, primaryformatind
    FROM taqprojecttitle
    WHERE taqprojectkey = @i_projectkey
      AND taqprojecttitle.titlerolecode = @v_titlerolecode  --only want formats
      AND NOT EXISTS 
        (SELECT * FROM taqversionformat 
         WHERE taqprojecttitle.taqprojectkey = taqversionformat.taqprojectkey AND 
          taqprojecttitle.mediatypecode = taqversionformat.mediatypecode AND 
          taqprojecttitle.mediatypesubcode = taqversionformat.mediatypesubcode AND
          taqversionformat.plstagecode = @i_plstagecode AND 
          taqversionformat.taqversionkey = @i_plversionkey)
    
  OPEN formats_project_cur

  FETCH formats_project_cur INTO @v_taqprojectformatkey, @v_primaryformatind

  WHILE (@@FETCH_STATUS=0)
  BEGIN
    -- exec qutl_trace 'qpl_sync_version_to_acq_project', '@v_taqprojectformatkey', @v_taqprojectformatkey

    DELETE FROM taqprojecttask
    WHERE taqprojectformatkey = @v_taqprojectformatkey    

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Error deleting from taqprojecttask table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    DELETE FROM taqprojecttitle
    WHERE taqprojectformatkey = @v_taqprojectformatkey  

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Error deleting from taqprojecttitle table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    IF @v_primaryformatind = 1
      SET @v_updateprimaryind = 1

    FETCH formats_project_cur INTO @v_taqprojectformatkey, @v_primaryformatind
  END

  CLOSE formats_project_cur
  DEALLOCATE formats_project_cur 

  -- formats that exist on both Project and the P&L Version
  -- exec qutl_trace 'qpl_sync_version_to_acq_project', 'formats that exist on both Project and the P&L Version', NULL, NULL, '@v_titlerolecode', @v_titlerolecode

  DECLARE formats_on_project_version_cur CURSOR FOR
    SELECT v.taqprojectformatkey versionformatkey, p.taqprojectformatkey projectformatkey, 
      v.mediatypecode, v.mediatypesubcode, v.activeprice, p.selectedversionformatkey
    FROM taqprojecttitle p, taqversionformat v 
    WHERE p.taqprojectkey = v.taqprojectkey 
      AND p.mediatypecode = v.mediatypecode 
      AND p.mediatypesubcode = v.mediatypesubcode 
      AND p.taqprojectkey = @i_projectkey
      AND v.plstagecode = @i_plstagecode 
      AND v.taqversionkey = @i_plversionkey
      AND p.titlerolecode = @v_titlerolecode
      
  OPEN formats_on_project_version_cur

  FETCH formats_on_project_version_cur INTO @v_versionformatkey, @v_taqprojectformatkey, @v_mediatypecode, @v_mediatypesubcode, @v_activeprice, @v_selectedversionformatkey

  WHILE (@@FETCH_STATUS=0)
  BEGIN
    -- exec qutl_trace 'qpl_sync_version_to_acq_project', '@v_versionformatkey, ', @v_versionformatkey, NULL, '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL, '@v_selectedversionformatkey', @v_selectedversionformatkey

    SET @v_quantity = NULL
    
    SELECT @v_count = COUNT(*)
    FROM taqversionformatyear
    WHERE taqprojectformatkey = @v_versionformatkey

    IF @v_count > 0
      SELECT @v_quantity = COALESCE(SUM(quantity),0)
      FROM taqversionformatyear
      WHERE taqprojectformatkey = @v_versionformatkey

    IF ISNULL(@v_selectedversionformatkey,0) = 0
      SET @v_selectedversionformatkey = @v_versionformatkey
    
    SET @v_taqprojectformatdesc = ''
    
    SELECT @v_taqprojectformatdesc = ISNULL(datadesc, '')
    FROM subgentables 
    WHERE tableid = 312 AND datacode = @v_mediatypecode AND datasubcode = @v_mediatypesubcode

    -- exec qutl_trace 'qpl_sync_version_to_acq_project', 'UPDATE taqprojecttitle', NULL, NULL, '@v_selectedversionformatkey', @v_selectedversionformatkey, NULL,
      -- '@v_mediatypecode', @v_mediatypecode, NULL, '@v_mediatypesubcode', @v_mediatypesubcode, NULL, ' @v_taqprojectformatdesc', NULL,  @v_taqprojectformatdesc

    UPDATE taqprojecttitle
    SET price = @v_activeprice, initialrun = @v_quantity, selectedversionformatkey = @v_selectedversionformatkey, taqprojectformatdesc = @v_taqprojectformatdesc, lastuserid = @v_userid, lastmaintdate = getdate()
    WHERE taqprojectformatkey = @v_taqprojectformatkey

    FETCH formats_on_project_version_cur INTO @v_versionformatkey, @v_taqprojectformatkey, @v_mediatypecode, @v_mediatypesubcode, @v_activeprice, @v_selectedversionformatkey
  END

  CLOSE formats_on_project_version_cur
  DEALLOCATE formats_on_project_version_cur 	


  -- formats that exist only on the P&L Version
  -- exec qutl_trace 'qpl_sync_version_to_acq_project', 'formats that exist only on the P&L Version'
  DECLARE formats_version_cur CURSOR FOR
  SELECT v.taqprojectformatkey, v.mediatypecode, v.mediatypesubcode, v.activeprice, p.selectedversionformatkey
  FROM taqversionformat v
  LEFT OUTER JOIN taqprojecttitle p ON p.selectedversionformatkey = v.taqprojectformatkey
  WHERE v.taqprojectkey = @i_projectkey
    AND v.plstagecode = @i_plstagecode
    AND v.taqversionkey = @i_plversionkey
    AND ISNULL(v.sharedposectionind, 0) <> 1
    AND NOT EXISTS 
      (SELECT * FROM taqprojecttitle t 
       WHERE t.taqprojectkey = v.taqprojectkey AND 
        t.mediatypecode = v. mediatypecode AND 
        t.mediatypesubcode = v.mediatypesubcode)		   

  OPEN formats_version_cur

  FETCH formats_version_cur INTO @v_versionformatkey, @v_mediatypecode, @v_mediatypesubcode, @v_activeprice, @v_selectedversionformatkey

  WHILE (@@FETCH_STATUS=0)
  BEGIN

    -- exec qutl_trace 'qpl_sync_version_to_acq_project', '@v_versionformatkey', @v_versionformatkey, NULL, '@v_selectedversionformatkey', @v_selectedversionformatkey
    SELECT @v_count = COUNT(*)
    FROM taqversionformatyear
    WHERE taqprojectformatkey = @v_versionformatkey

    IF @v_count > 0
      SELECT @v_quantity = COALESCE(SUM(quantity),0)
      FROM taqversionformatyear
      WHERE taqprojectformatkey = @v_versionformatkey
    ELSE
      SET @v_quantity = NULL

    SET @v_taqprojectformatdesc = ''
    
    SELECT @v_taqprojectformatdesc = ISNULL(datadesc, '')
    FROM subgentables 
    WHERE tableid = 312 AND datacode = @v_mediatypecode AND datasubcode = @v_mediatypesubcode

    IF ISNULL(@v_selectedversionformatkey,0) = 0
      SET @v_selectedversionformatkey = @v_versionformatkey
      
    EXEC get_next_key @v_userid, @v_taqprojectformatkey OUTPUT

    SET @v_projectrolecode = (SELECT datacode FROM gentables WHERE tableid = 604 and qsicode = 2)

    -- exec qutl_trace 'qpl_sync_version_to_acq_project', 'INSERT INTO taqprojecttitle', NULL, NULL, '@v_taqprojectformatkey', @v_taqprojectformatkey, NULL, '@v_selectedversionformatkey', @v_selectedversionformatkey

    -- TAQPROJECTTITLE
    INSERT INTO taqprojecttitle
      (taqprojectformatkey, taqprojectkey, mediatypecode, mediatypesubcode, taqprojectformatdesc, 
      price, initialrun, printingkey, titlerolecode, projectrolecode, primaryformatind, selectedversionformatkey, lastuserid, lastmaintdate)
    VALUES
      (@v_taqprojectformatkey, @i_projectkey, @v_mediatypecode, @v_mediatypesubcode, @v_taqprojectformatdesc, 
      @v_activeprice, @v_quantity, 1, @v_titlerolecode, @v_projectrolecode, 0, @v_selectedversionformatkey, @v_userid, getdate())

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Could not insert into taqprojecttitle table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END    

    FETCH formats_version_cur INTO @v_versionformatkey, @v_mediatypecode, @v_mediatypesubcode, @v_activeprice, @v_selectedversionformatkey
  END

  CLOSE formats_version_cur
  DEALLOCATE formats_version_cur 
	

	--COMMENTS
	DECLARE versioncomments_cur CURSOR FOR
		SELECT commentkey, commenttypecode, commenttypesubcode, sortorder
		 FROM taqversioncomments
		WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstagecode AND taqversionkey = @i_plversionkey
	    
	OPEN versioncomments_cur 
	  
	FETCH versioncomments_cur INTO @v_version_commentkey,@v_commenttype, @v_commentsubtype, @v_sortorder

	WHILE (@@FETCH_STATUS=0)
	BEGIN
		SELECT @v_count1 = 0
		SELECT @v_count2 = 0
		
		-- Item type filtering set for Projects/Title Acquisition
		SELECT @v_count1 = COUNT(*)
          FROM gentablesitemtype 
         WHERE tableid = 284
           AND itemtypecode = (select datacode from gentables where tableid = 550 and qsicode = 3)
           AND itemtypesubcode = (select datasubcode from subgentables where tableid = 550 and datacode = (select datacode from gentables where tableid = 550 and qsicode = 3)
                          and qsicode = 1) 
           AND datacode = @v_commenttype 
           AND datasubcode = @v_commentsubtype

		IF @v_count1 = 1 
        BEGIN
			-- Item type filtering set for User Admin/P&L Templat
			SELECT @v_count2 = COUNT(*)
			  FROM gentablesitemtype 
			 WHERE tableid = 284
			   AND itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 and qsicode = 5)
			   AND itemtypesubcode = (SELECT datasubcode FROM subgentables WHERE tableid = 550 and datacode = (SELECT datacode FROM gentables WHERE tableid = 550 and qsicode = 5)
							          AND qsicode = 29) 
			   AND datacode = @v_commenttype 
			   AND datasubcode = @v_commentsubtype

			IF @v_count2 = 1
            BEGIN
				SELECT @v_count3 = 0

				SELECT @v_count3 = COUNT(*)
				  FROM taqprojectcomments
                 WHERE taqprojectkey = @i_projectkey
				   AND commenttypecode = @v_commenttype
                   AND commenttypesubcode = @v_commentsubtype

				IF @v_count3 = 1 BEGIN

					SELECT @v_project_commentkey = commentkey
                      FROM taqprojectcomments
					 WHERE taqprojectkey = @i_projectkey
				       AND commenttypecode = @v_commenttype
                       AND commenttypesubcode = @v_commentsubtype

					IF @v_project_commentkey <> @v_version_commentkey
					BEGIN
						SELECT @v_commenttext = commenttext, @v_commenthtml = commenthtml, @v_commenthtmllite = commenthtmllite,
								@v_invalidhtmlind = invalidhtmlind, @v_releasetoeloquenceind = releasetoeloquenceind
						  FROM qsicomments	
						 WHERE commentkey = @v_version_commentkey
						   AND commenttypecode = @v_commenttype
						   AND commenttypesubcode = @v_commentsubtype

						UPDATE qsicomments
						   SET commenttext = commenttext, commenthtml = @v_commenthtml, commenthtmllite = @v_commenthtmllite,
							   lastuserid = @v_userid, lastmaintdate = getdate()
						 WHERE commentkey = @v_project_commentkey
						   AND commenttypecode = @v_commenttype
						   AND commenttypesubcode = @v_commentsubtype
					END
       			END
                ELSE
                BEGIN
				-- generate new commentkey
					EXEC get_next_key @v_userid, @v_new_version_commentkey OUTPUT

					INSERT INTO qsicomments
					  (commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml,commenthtmllite, lastuserid, lastmaintdate,invalidhtmlind,releasetoeloquenceind)
					SELECT
					  @v_new_version_commentkey, commenttypecode, commenttypesubcode, parenttable, commenttext, commenthtml,commenthtmllite, @v_userid, getdate(),invalidhtmlind,releasetoeloquenceind 
					FROM qsicomments
					WHERE commentkey = @v_version_commentkey

					SELECT @v_error = @@ERROR
					IF @v_error <> 0 BEGIN
						SET @o_error_desc = 'Could not insert into qsicomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
						GOTO RETURN_ERROR
					END

					INSERT INTO taqprojectcomments
					(taqprojectkey,  commenttypecode, commenttypesubcode, commentkey, sortorder, lastuserid, lastmaintdate)
					VALUES
					(@i_projectkey,  @v_commenttype, @v_commentsubtype, @v_new_version_commentkey, @v_sortorder, @v_userid, getdate())
					 
					SELECT @v_error = @@ERROR
					IF @v_error <> 0 BEGIN
						SET @o_error_desc = 'Could not insert into taqversioncomments table (Error ' + cast(@v_error AS VARCHAR) + ').'
						GOTO RETURN_ERROR
					END
				END
			END
		END

		FETCH versioncomments_cur INTO @v_version_commentkey, @v_commenttype, @v_commentsubtype	, @v_sortorder
	END
	    
	CLOSE versioncomments_cur 
	DEALLOCATE versioncomments_cur 
	
	--CATEGORIES
	SELECT @v_count = 0

	SELECT @v_count = count(*)
	  FROM clientdefaults
     WHERE clientdefaultid = 54  -- P&L Target Market Table ID

    IF @v_count = 1
	BEGIN
		SELECT @v_clientdefaultvalue = clientdefaultvalue
		  FROM clientdefaults
		 WHERE clientdefaultid = 54

		DELETE FROM taqprojectsubjectcategory
			  WHERE taqprojectkey = @i_projectkey
                AND categorytableid = @v_clientdefaultvalue

		DECLARE markets_cur CURSOR FOR
			SELECT targetmarketkey, marketcode, marketsubcode, marketsub2code, marketgrowthpercent, sortorder
			FROM taqversionmarket
			WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_plstagecode AND taqversionkey = @i_plversionkey
		    
		OPEN markets_cur
		  
		FETCH markets_cur
		  INTO @v_cur_marketkey, @v_marketcode, @v_marketsubcode, @v_marketsub2code, @v_marketgrowthrate, @v_sortorder

		WHILE (@@FETCH_STATUS=0)
		BEGIN
			EXEC get_next_key @v_userid, @v_subjectkey OUTPUT

			SELECT @v_count2 = 0

			SELECT @v_count2 = COUNT(*)
              FROM taqprojectsubjectcategory
			 WHERE taqprojectkey = @i_projectkey AND categorytableid = @v_clientdefaultvalue 
               AND categorycode = @v_marketcode AND categorysubcode = @v_marketsubcode
               AND categorysub2code = @v_marketsub2code

			IF @v_count2 = 0
			BEGIN
				INSERT INTO taqprojectsubjectcategory
					(taqprojectkey, subjectkey, categorytableid, categorycode,categorysubcode, categorysub2code, sortorder, lastuserid, lastmaintdate)
				VALUES
					(@i_projectkey, @v_subjectkey, @v_clientdefaultvalue, @v_marketcode, @v_marketsubcode, @v_marketsub2code, @v_sortorder,@v_userid, getdate()) 
			END

			FETCH markets_cur
				INTO @v_cur_marketkey, @v_marketcode, @v_marketsubcode, @v_marketsub2code, @v_marketgrowthrate, @v_sortorder
		END
	  
	  CLOSE markets_cur
	  DEALLOCATE markets_cur 
	END
    ELSE
	BEGIN
		SELECT @v_clientdefaultvalue = 0
	END
	
  -- Primary format was deleted, need to set the next one as primary
  IF @v_updateprimaryind = 1
  BEGIN
    IF EXISTS (SELECT 1 FROM taqprojecttitle 
               WHERE taqprojectkey = @i_projectkey AND taqprojecttitle.titlerolecode = @v_titlerolecode)
    BEGIN
      UPDATE taqprojecttitle SET primaryformatind = 1 
      WHERE taqprojectformatkey = 
        (SELECT TOP(1) taqprojectformatkey
        FROM taqprojecttitle
        WHERE taqprojectkey = @i_projectkey
          AND primaryformatind = 0
          AND taqprojecttitle.titlerolecode = @v_titlerolecode)  --only want formats
    END
  END

	IF @v_isopentrans = 1
		COMMIT
    
	RETURN  

RETURN_ERROR:  
  IF @v_isopentrans = 1
    ROLLBACK
    
  SET @o_error_code = -1
  RETURN


END
GO

GRANT EXEC ON qpl_sync_version_to_acq_project TO PUBLIC
GO