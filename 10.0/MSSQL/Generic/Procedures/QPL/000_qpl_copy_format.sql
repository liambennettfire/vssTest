if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpl_copy_format') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure dbo.qpl_copy_format
GO

CREATE PROCEDURE [dbo].[qpl_copy_format] (  
  @i_new_projectkey   integer,
  @i_new_plstage      integer,
  @i_new_plversion    integer, 
  @i_new_formatkey    integer, 
  @i_from_formatkey   integer,
  @i_format_price     float,  
  @i_copyvalues       tinyint,
  @i_bookkey          integer,
  @i_userid           varchar(30),
  @o_error_code       integer output,
  @o_error_desc       varchar(2000) output)
AS

/*********************************************************************************************************
**  Name: qpl_copy_format
**  Desc: This stored procedure copies information for the given format:
**        if @i_copyvalues = 0, do not copy anything but format
**        if @i_copyvalues = 1, copy rows for the given format but not the data (not the units/costs/income values)
**        if @i_copyvalues = 2, copy all rows and values for the given format
**        if @i_copyvalues = 3, copy all rows and values for the given format but zero out costs
**
**  Auth: Kate
**  Date: November 3 2011
********************************************************************************************************
**    Change History
**********************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   06/19/2014   Uday Khisty  27689     Change for PL Approve to copy Notes as well
**   01/14/2015   Uday Khisty  31244     Change to allow itemdetailsubcode & itemdetailsub2code to be copied over
**   07/12/2016   Colman       39064     Deactivated Spec Items showing up on Summary Specs 
**   01/20/2017   Colman       42178     Royalty advances by contributor
**   01/20/2017   Joshua G     42178     Royalty advances by contributor 
**   02/08/2017   Colman       41910     Added netprice and calcdiscountind to taqversaleschannel
**   06/06/2017   Colman       45522     Copy sharedposectionind and allocationtype, new copyvalues option
**   09/30/2017   Colman       47475     Unit costs dropped when copying a printing P&L version
**   12/11/2017   Colman       48688     Copying P&L does not calculate Total Cost
**********************************************************************************************************/

DECLARE
  @v_addtlunitskey  INT,
  @v_count	INT,  
  @v_cur_addtlunitskey  INT,
  @v_cur_formatyearkey  INT,
  @v_cur_royaltykey INT,
  @v_cur_saleskey INT,
  @v_decprecision_mask VARCHAR(20),
  @v_description  VARCHAR(2000),
  @v_description2 VARCHAR(2000),
  @v_discountpercent FLOAT,
  @v_error  INT,
  @v_floatvalue FLOAT,  
  @v_formatyearkey  INT,
  @v_grossunits INT,
  @v_lastthresholdind TINYINT,
  @v_longvalue INT,  
  @v_misckey INT,
  @v_misctype INT,  
  @v_netunits INT,
  @v_new_formatkey  INT,
  @v_num_decprecision INT,
  @v_percentage  FLOAT,
  @v_plunittype INT,
  @v_plunitsubtype  INT,
  @v_pricetypeforroyalty INT,
  @v_printingnumber INT,
  @v_prodcostgenkey INT,
  @v_quantity INT,
  @v_returnpercent FLOAT,
  @v_royaltykey INT,
  @v_royaltyratekey INT,
  @v_royaltyrate FLOAT,
  @v_saleskey INT,
  @v_saleschannelcode INT,
  @v_saleschannelsubcode INT,
  @v_salespercent FLOAT,
  @v_showonproditemsind  TINYINT,
  @v_specitemcategory INT,
  @v_specitem INT,
  @v_specitemdetail  INT,
  @v_specitemdetailSubCode  INT,
  @v_specitemdetailSub2Code  INT,      
  @v_specitemkey  INT,
  @v_textvalue	VARCHAR(255),  
  @v_threshold INT,
  @v_validforprtgscode INT,  
  @v_yearcode INT,
  @v_new_taqversionspecategorykey INT,
  @v_new_taqversionspecnotekey INT,  
  @v_old_taqversionspecategorykey	INT,
  @v_decimalvalue decimal(15,4),
  @v_unitofmeasurecode INT,
  @v_old_notekey INT,
  @v_roleTypeCode INT, 
  @v_globalcontactkey INT,
  @v_netprice DECIMAL(9,2),
  @v_calcdiscountind TINYINT,
  @v_zerocostsind TINYINT
    
BEGIN
    
  SET @o_error_code = 0
  SET @o_error_desc = ''
  
  SET @v_zerocostsind = 0
  
  IF @i_copyvalues = 3
  BEGIN
    SET @i_copyvalues = 2
    SET @v_zerocostsind = 1
  END
  
  -- NOTE: @i_new_formatkey is passed when this procedure is called from within qpl_create_version.
  -- When this procedure is called directly (from Edit Formats popup in P&L), we will copy from P&L Template (never from work).
  IF @i_new_formatkey > 0
    SET @v_new_formatkey = @i_new_formatkey
  ELSE
  BEGIN
    -- generate new taqprojectformatkey
    EXEC get_next_key @i_userid, @v_new_formatkey OUTPUT

    -- TAQVERSIONFORMAT
    IF @i_copyvalues = 2 AND @i_bookkey = 0 --copy everything from Acq. Project/P&L Template
      INSERT INTO taqversionformat
        (taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, mediatypecode, mediatypesubcode,
        activeprice, scaleselectioncode, charsperpage, formatpercentage, pricechangedind, formatpercentchangedind,
        description, sharedposectionind, allocationtype, sortorder, lastuserid, lastmaintdate)
      SELECT
        @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, mediatypecode, mediatypesubcode,
        @i_format_price, scaleselectioncode, charsperpage, formatpercentage, pricechangedind, formatpercentchangedind,
        description, sharedposectionind, allocationtype, sortorder, @i_userid, getdate()
      FROM taqversionformat
      WHERE taqprojectformatkey = @i_from_formatkey
    ELSE  --don't copy any values for the format
      INSERT INTO taqversionformat
        (taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, mediatypecode, mediatypesubcode, lastuserid, lastmaintdate)
      SELECT
        @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, mediatypecode, mediatypesubcode, @i_userid, getdate()
      FROM taqversionformat
      WHERE taqprojectformatkey = @i_from_formatkey  
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      SET @o_error_desc = 'Could not insert into taqversionformat table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END
  END


  IF @i_bookkey > 0 --copying from work
  BEGIN
    DECLARE bookmisc_cursor CURSOR FOR
      SELECT misckey, longvalue, floatvalue, textvalue
      FROM bookmisc 
      WHERE bookkey = @i_bookkey AND 
        (misckey IN (SELECT numericdesc2 FROM subgentables WHERE tableid = 616) OR 
         misckey IN (SELECT numericdesc2 FROM sub2gentables WHERE tableid = 616))

    OPEN bookmisc_cursor 

    FETCH bookmisc_cursor INTO @v_misckey, @v_longvalue, @v_floatvalue, @v_textvalue

    WHILE (@@FETCH_STATUS=0)
    BEGIN
      -- check if single row exists on subgentables for this misckey
      SELECT @v_count = COUNT(*)
      FROM subgentables
      WHERE tableid = 616 AND numericdesc2 = @v_misckey
            AND COALESCE(subgen4ind,0) = 1 -- Show as Spec

      IF @v_count = 1
        SELECT @v_specitemcategory = datacode, @v_specitem = datasubcode, @v_specitemdetail = NULL
        FROM subgentables
        WHERE tableid = 616 AND numericdesc2 = @v_misckey
      ELSE
      BEGIN
        -- check if single row exists on sub2gentables for this misckey
        SELECT @v_count = COUNT(*)
        FROM sub2gentables
        WHERE tableid = 616 AND numericdesc2 = @v_misckey

        IF @v_count = 1
          SELECT @v_specitemcategory = datacode, @v_specitem = datasubcode, @v_specitemdetail = datasub2code
          FROM sub2gentables
          WHERE tableid = 616 AND numericdesc2 = @v_misckey      
      END

      IF @v_count = 1  --single subgentables or sub2gentables row exists for this misckey
      BEGIN
        SELECT @v_misctype = misctype
        FROM bookmiscitems
        WHERE misckey = @v_misckey

        IF @v_misctype IN (1,3,5)
        BEGIN
          -- generate new taqversionspecategorykey
          EXEC get_next_key @i_userid, @v_new_taqversionspecategorykey OUTPUT

          INSERT INTO taqversionspeccategory
            (taqversionspecategorykey, taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, itemcategorycode, 
            speccategorydescription, scaleprojecttype, vendorcontactkey,lastuserid, lastmaintdate, finishedgoodind, sortorder, deriveqtyfromfgqty, spoilagepercentage)
          SELECT
            @v_new_taqversionspecategorykey, @i_new_projectkey,@i_new_plstage, @i_new_plversion, @v_new_formatkey, itemcategorycode,
            speccategorydescription, scaleprojecttype, vendorcontactkey, @i_userid, getdate(), finishedgoodind, sortorder, deriveqtyfromfgqty, spoilagepercentage
          FROM taqversionspeccategory
          WHERE taqversionformatkey = @i_from_formatkey AND itemcategorycode = @v_specitemcategory

          SELECT @v_error = @@ERROR
            IF @v_error <> 0 BEGIN
            SET @o_error_desc = 'Could not insert into taqversionspeccategory table (Error ' + cast(@v_error AS VARCHAR) + ').'
            GOTO RETURN_ERROR
          END

          -- generate new taqversionspecitemkey
          EXEC get_next_key @i_userid, @v_specitemkey OUTPUT

          IF @v_misctype = 3  --text
            INSERT INTO taqversionspecitems
              (taqversionspecitemkey, taqversionspecategorykey, itemcode, itemdetailcode, 
               quantity, validforprtgscode, description, decimalvalue, unitofmeasurecode, lastuserid, lastmaintdate)
            VALUES
              (@v_specitemkey, @v_new_taqversionspecategorykey, @v_specitemcategory, @v_specitem, 
               NULL, 3, @v_textvalue, NULL, NULL, @i_userid, getdate())
          ELSE  --numeric or gentable
            INSERT INTO taqversionspecitems
              (taqversionspecitemkey, taqversionspecategorykey, itemcode, itemdetailcode, 
               quantity, validforprtgscode, description, decimalvalue, unitofmeasurecode, lastuserid, lastmaintdate)
            VALUES
              (@v_specitemkey, @v_new_taqversionspecategorykey, @v_specitemcategory, @v_specitem, 
               @v_longvalue, 3, NULL, NULL, NULL, @i_userid, getdate())

          SELECT @v_error = @@ERROR
          IF @v_error <> 0 BEGIN
            CLOSE bookmisc_cursor 
            DEALLOCATE bookmisc_cursor 
            SET @o_error_desc = 'Could not insert into taqversionspecitems table (Error ' + cast(@v_error AS VARCHAR) + ').'
            GOTO RETURN_ERROR
          END
        END --@v_misctype IN (1,3,5)
      END --@v_count = 1

      FETCH bookmisc_cursor INTO @v_misckey, @v_longvalue, @v_floatvalue, @v_textvalue
    END

    CLOSE bookmisc_cursor
    DEALLOCATE bookmisc_cursor
  END
  
  -- If the copy option was 0 - 'Do Not Copy Template', return
  IF @i_copyvalues = 0
    RETURN

  CREATE TABLE #speccategorykeys (
	oldtaqversionspeccategorykey	INT,
	newtaqversionspeccategorykey INT)

  -- TAQVERSIONSPECCATEGORY
  -- *** Loop through version spec item records for this format ***
  DECLARE versionspeccategory_cur CURSOR FOR
    SELECT taqversionspecategorykey
    FROM taqversionspeccategory
    WHERE taqversionformatkey = @i_from_formatkey 

  OPEN versionspeccategory_cur 

  FETCH versionspeccategory_cur INTO @v_old_taqversionspecategorykey

  WHILE (@@FETCH_STATUS=0)
  BEGIN
    -- generate new taqversionspecategorykey
    EXEC get_next_key @i_userid, @v_new_taqversionspecategorykey OUTPUT

    IF @i_copyvalues = 2
      INSERT INTO taqversionspeccategory
        (taqversionspecategorykey, taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, itemcategorycode, 
        speccategorydescription, scaleprojecttype, vendorcontactkey, lastuserid, lastmaintdate, finishedgoodind, sortorder, deriveqtyfromfgqty, spoilagepercentage)
      SELECT
        @v_new_taqversionspecategorykey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, itemcategorycode,
        speccategorydescription, scaleprojecttype, vendorcontactkey, @i_userid, getdate(), finishedgoodind, sortorder, deriveqtyfromfgqty, spoilagepercentage
      FROM taqversionspeccategory
      WHERE taqversionformatkey = @i_from_formatkey AND taqversionspecategorykey = @v_old_taqversionspecategorykey
        
    ELSE IF @i_copyvalues = 1
      INSERT INTO taqversionspeccategory
        (taqversionspecategorykey, taqprojectkey, plstagecode, taqversionkey, taqversionformatkey, itemcategorycode, 
        speccategorydescription, scaleprojecttype, lastuserid, lastmaintdate, finishedgoodind, sortorder, deriveqtyfromfgqty, spoilagepercentage)
      SELECT
        @v_new_taqversionspecategorykey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, itemcategorycode,
        speccategorydescription, scaleprojecttype, @i_userid, getdate(), finishedgoodind, sortorder, deriveqtyfromfgqty, spoilagepercentage
      FROM taqversionspeccategory
      WHERE taqversionformatkey = @i_from_formatkey AND taqversionspecategorykey = @v_old_taqversionspecategorykey
      
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE versionspeccategory_cur 
      DEALLOCATE versionspeccategory_cur      
      SET @o_error_desc = 'Could not insert into taqversionspeccategory table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    -- save keys for use later in copying costs
    insert into #speccategorykeys (oldtaqversionspeccategorykey,newtaqversionspeccategorykey)
    values (@v_old_taqversionspecategorykey,@v_new_taqversionspecategorykey)
    
    -- *** Loop through version spec item records for this format ***
    DECLARE specitems_cur CURSOR FOR
      SELECT i.taqversionspecategorykey, i.itemcode, i.itemdetailcode, i.itemdetailsubcode, i.itemdetailsub2code, i.quantity, i.validforprtgscode, 
		         i.description, i.description2, i.decimalvalue, i.unitofmeasurecode
      FROM taqversionspecitems i
      JOIN taqversionspeccategory c ON i.taqversionspecategorykey = c.taqversionspecategorykey
      JOIN subgentables s ON s.tableid=616 
          AND c.itemcategorycode = s.datacode 
          AND i.itemcode = s.datasubcode
          AND COALESCE(s.subgen4ind,0) = 1  -- Do not copy spec items that have since been deactivated
      WHERE i.taqversionspecategorykey = @v_old_taqversionspecategorykey

    OPEN specitems_cur 

    FETCH specitems_cur
    INTO @v_specitemcategory, @v_specitem, @v_specitemdetail, @v_specitemdetailSubCode, @v_specitemdetailSub2Code, @v_quantity, @v_validforprtgscode, 
      @v_description, @v_description2, @v_decimalvalue, @v_unitofmeasurecode

    WHILE (@@FETCH_STATUS=0)
    BEGIN

      -- generate new taqversionspecitemkey
      EXEC get_next_key @i_userid, @v_specitemkey OUTPUT

      IF @i_copyvalues = 2
        INSERT INTO taqversionspecitems
          (taqversionspecitemkey, taqversionspecategorykey, itemcode, itemdetailcode, itemdetailsubcode, itemdetailsub2code, quantity, validforprtgscode, 
          description, description2, decimalvalue, unitofmeasurecode, lastuserid, lastmaintdate)
        VALUES
          (@v_specitemkey, @v_new_taqversionspecategorykey, @v_specitem, @v_specitemdetail, @v_specitemdetailSubCode, @v_specitemdetailSub2Code, @v_quantity, @v_validforprtgscode, 
          @v_description, @v_description2, @v_decimalvalue, @v_unitofmeasurecode, @i_userid, getdate()) 
      ELSE IF @i_copyvalues = 1
        INSERT INTO taqversionspecitems
          (taqversionspecitemkey, taqversionspecategorykey, itemcode, itemdetailcode, itemdetailsubcode, itemdetailsub2code, 
           validforprtgscode, unitofmeasurecode, lastuserid, lastmaintdate)
        VALUES
          (@v_specitemkey, @v_new_taqversionspecategorykey, @v_specitem, @v_specitemdetail, @v_specitemdetailSubCode, @v_specitemdetailSub2Code, 
           @v_validforprtgscode, @v_unitofmeasurecode, @i_userid, getdate()) 

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE specitems_cur 
        DEALLOCATE specitems_cur 
        CLOSE versionspeccategory_cur 
        DEALLOCATE versionspeccategory_cur        
        SET @o_error_desc = 'Could not insert into taqversionspecitems table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END

      FETCH specitems_cur
      INTO @v_specitemcategory, @v_specitem, @v_specitemdetail, @v_specitemdetailSubCode, @v_specitemdetailSub2Code, @v_quantity, @v_validforprtgscode, 
        @v_description, @v_description2, @v_decimalvalue, @v_unitofmeasurecode
    END

    CLOSE specitems_cur
    DEALLOCATE specitems_cur

    -- *** Loop through version spec note records for this format ***
    DECLARE specnotes_cursor_insert CURSOR FOR
	  SELECT taqversionspecnotekey
	  FROM taqversionspecnotes
	  WHERE taqversionspecategorykey = @v_old_taqversionspecategorykey
    OPEN specnotes_cursor_insert 

    FETCH specnotes_cursor_insert
    INTO @v_old_notekey

    WHILE (@@FETCH_STATUS=0)
    BEGIN

      -- generate new taqversionspecitemkey
      EXEC get_next_key @i_userid, @v_new_taqversionspecnotekey OUTPUT

      IF @i_copyvalues = 2
        INSERT INTO taqversionspecnotes
          (taqversionspecnotekey, taqversionspecategorykey, text, showonpoind, 
          copynextprtgind, sortorder, lastuserid, lastmaintdate)
		SELECT @v_new_taqversionspecnotekey ,@v_new_taqversionspecategorykey ,text ,showonpoind ,
		copynextprtgind ,sortorder ,@i_userid ,getdate()                      
		FROM taqversionspecnotes 
		WHERE taqversionspecategorykey = @v_old_taqversionspecategorykey AND  taqversionspecnotekey = @v_old_notekey          

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE specnotes_cursor_insert 
        DEALLOCATE specnotes_cursor_insert 
        CLOSE versionspeccategory_cur 
        DEALLOCATE versionspeccategory_cur        
        SET @o_error_desc = 'Could not insert into taqversionspecnotes table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END

      FETCH specnotes_cursor_insert
      INTO @v_old_notekey
    END

    CLOSE specnotes_cursor_insert
    DEALLOCATE specnotes_cursor_insert

    FETCH versionspeccategory_cur INTO @v_old_taqversionspecategorykey
  END

  CLOSE versionspeccategory_cur
  DEALLOCATE versionspeccategory_cur  


  -- *** Loop through version additional unit records for this format ***
  DECLARE addtlunits_cur CURSOR FOR
    SELECT addtlunitskey, plunittypecode, plunittypesubcode
    FROM taqversionaddtlunits
    WHERE taqprojectformatkey = @i_from_formatkey

  OPEN addtlunits_cur

  FETCH addtlunits_cur INTO @v_cur_addtlunitskey, @v_plunittype, @v_plunitsubtype

  WHILE (@@FETCH_STATUS=0)
  BEGIN

    -- generate new addtlunitskey
    EXEC get_next_key @i_userid, @v_addtlunitskey OUTPUT

    -- TAQVERSIONADDTLUNITS
    INSERT INTO taqversionaddtlunits
      (addtlunitskey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, 
      plunittypecode, plunittypesubcode, lastuserid, lastmaintdate)
    VALUES
      (@v_addtlunitskey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, 
      @v_plunittype, @v_plunitsubtype, @i_userid, getdate())

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE addtlunits_cur
      DEALLOCATE addtlunits_cur
      SET @o_error_desc = 'Could not insert into taqversionaddtlunits table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    -- *** Loop through additional unit quantities for this PL Unit Type/Subtype and copy one at a time with new key ***
    DECLARE quantities_cur CURSOR FOR
      SELECT yearcode, quantity
      FROM taqversionaddtlunitsyear
      WHERE addtlunitskey = @v_cur_addtlunitskey

    OPEN quantities_cur

    FETCH quantities_cur INTO @v_yearcode, @v_quantity

    WHILE (@@FETCH_STATUS=0)
    BEGIN

      -- TAQVERSIONADDTLUNITSYEAR
      IF @i_copyvalues = 2  --copy everything
        INSERT INTO taqversionaddtlunitsyear
          (addtlunitskey, yearcode, quantity, lastuserid, lastmaintdate)
        VALUES
          (@v_addtlunitskey, @v_yearcode, @v_quantity, @i_userid, getdate())
      ELSE  --don't copy quantities
        INSERT INTO taqversionaddtlunitsyear
          (addtlunitskey, yearcode, lastuserid, lastmaintdate)
        VALUES
          (@v_addtlunitskey, @v_yearcode, @i_userid, getdate())
          
      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE quantities_cur
        DEALLOCATE quantities_cur        
        CLOSE addtlunits_cur
        DEALLOCATE addtlunits_cur
        SET @o_error_desc = 'Could not insert into taqversionaddtlunitsyear table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END      

      FETCH quantities_cur INTO @v_yearcode, @v_quantity
    END

    CLOSE quantities_cur
    DEALLOCATE quantities_cur

    FETCH addtlunits_cur INTO @v_cur_addtlunitskey, @v_plunittype, @v_plunitsubtype
  END

  CLOSE addtlunits_cur
  DEALLOCATE addtlunits_cur


  -- *** Loop through version royalty sales channel records for this format ***
  --Find all royalties
  SELECT taqversionroyaltykey, saleschannelcode, pricetypeforroyalty, roleTypeCode, globalcontactkey, @i_new_projectkey AS taqprojectKey, taqprojectformatkey
  INTO #contactsRolesForInsert
    FROM taqversionroyaltysaleschannel
    WHERE taqprojectformatkey = @i_from_formatkey
  ORDER BY taqversionroyaltykey
  
  --If the person doesn't exist on the project do not copy them set to all contacts for the role
  UPDATE cr 
  SET cr.globalcontactkey = 0 
  FROM #contactsRolesForInsert cr
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
	SELECT taqversionroyaltykey,roleTypeCode,globalContactKey,taqProjectkey,
			ROW_NUMBER() OVER(PARTITION BY saleschannelcode,roleTypeCode,globalContactKey,taqProjectkey,taqprojectformatkey ORDER BY taqversionroyaltykey DESC) AS rnk
	FROM #contactsRolesForInsert
  )
  DELETE cte_wins
  WHERE rnk > 1
  
  --If we have a contact for a role, but also have a row for that role with a contact of 0 we need to delete it
  --as it contradicts.  Since 0 means all contacts and we have a specific one as well.
  DELETE ct1
  FROM #contactsRolesForInsert ct1
  WHERE EXISTS(SELECT 1 FROM #contactsRolesForInsert ct2	
  				WHERE ct1.roletypecode = ct2.roletypecode
				AND ct1.taqversionroyaltykey = ct2.taqversionroyaltykey
  				AND ct1.globalcontactkey != 0) 
  AND ct1.globalcontactkey = 0
		
  DECLARE saleschannel_cur CURSOR FOR
    SELECT taqversionroyaltykey, saleschannelcode, pricetypeforroyalty, roleTypeCode, globalcontactkey
    FROM #contactsRolesForInsert
    ORDER BY taqversionroyaltykey

  OPEN saleschannel_cur

  FETCH saleschannel_cur INTO @v_cur_royaltykey, @v_saleschannelcode, @v_pricetypeforroyalty,  @v_roleTypeCode, @v_globalcontactkey

  WHILE (@@FETCH_STATUS=0)
  BEGIN

    -- generate new taqversionroyaltykey
    EXEC get_next_key @i_userid, @v_royaltykey OUTPUT

    -- TAQVERSIONROYALTYSALESCHANNEL
    INSERT INTO taqversionroyaltysaleschannel
      (taqversionroyaltykey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
      saleschannelcode, pricetypeforroyalty, lastuserid, lastmaintdate, roleTypeCode, globalcontactkey)
    VALUES
      (@v_royaltykey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, 
      @v_saleschannelcode, @v_pricetypeforroyalty, @i_userid, getdate(), @v_roleTypeCode, @v_globalcontactkey)

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE saleschannel_cur
      DEALLOCATE saleschannel_cur
      SET @o_error_desc = 'Could not insert into taqversionroyaltysaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    -- Copy actual royalty rates only when copying data
    IF @i_copyvalues = 2
    BEGIN
      -- *** Loop through royalty rates for this sales channel and copy one at a time with new key ***
      DECLARE royaltyrates_cur CURSOR FOR
        SELECT royaltyrate, threshold, lastthresholdind
        FROM taqversionroyaltyrates
        WHERE taqversionroyaltykey = @v_cur_royaltykey

      OPEN royaltyrates_cur

      FETCH royaltyrates_cur INTO @v_royaltyrate, @v_threshold, @v_lastthresholdind

      WHILE (@@FETCH_STATUS=0)
      BEGIN

        -- generate new taqversionroyaltyratekey
        EXEC get_next_key @i_userid, @v_royaltyratekey OUTPUT

        -- TAQVERSIONROYALTYRATES
        INSERT INTO taqversionroyaltyrates
          (taqversionroyaltyratekey, taqversionroyaltykey, royaltyrate, threshold, lastthresholdind, lastuserid, lastmaintdate)
        VALUES
          (@v_royaltyratekey, @v_royaltykey, @v_royaltyrate, @v_threshold, @v_lastthresholdind, @i_userid, getdate())

        SELECT @v_error = @@ERROR
        IF @v_error <> 0 BEGIN
          CLOSE royaltyrates_cur
          DEALLOCATE royaltyrates_cur        
          CLOSE saleschannel_cur
          DEALLOCATE saleschannel_cur
          SET @o_error_desc = 'Could not insert into taqversionroyaltyrates table (Error ' + cast(@v_error AS VARCHAR) + ').'
          GOTO RETURN_ERROR
        END      

        FETCH royaltyrates_cur 
        INTO @v_royaltyrate, @v_threshold, @v_lastthresholdind
      END

      CLOSE royaltyrates_cur
      DEALLOCATE royaltyrates_cur
    END --@i_copyvalues = 2

    FETCH saleschannel_cur 
    INTO @v_cur_royaltykey, @v_saleschannelcode, @v_pricetypeforroyalty,  @v_roleTypeCode, @v_globalcontactkey
  END

  CLOSE saleschannel_cur
  DEALLOCATE saleschannel_cur


  -- *** Loop through version sales channel records for this format ***
  DECLARE saleschannel_cur CURSOR FOR
    SELECT taqversionsaleskey, saleschannelcode, saleschannelsubcode, discountpercent, returnpercent, netprice, calcdiscountind
    FROM taqversionsaleschannel
    WHERE taqprojectformatkey = @i_from_formatkey

  OPEN saleschannel_cur

  FETCH saleschannel_cur 
  INTO @v_cur_saleskey, @v_saleschannelcode, @v_saleschannelsubcode, @v_discountpercent, @v_returnpercent, @v_netprice, @v_calcdiscountind

  WHILE (@@FETCH_STATUS=0)
  BEGIN

    -- generate new taqversionsaleskey
    EXEC get_next_key @i_userid, @v_saleskey OUTPUT

    -- TAQVERSIONSALESCHANNEL
    IF @i_copyvalues = 2 --copy everything
      INSERT INTO taqversionsaleschannel
        (taqversionsaleskey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
        saleschannelcode, saleschannelsubcode, discountpercent, returnpercent, netprice, calcdiscountind, lastuserid, lastmaintdate)
      VALUES
        (@v_saleskey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, 
        @v_saleschannelcode, @v_saleschannelsubcode, @v_discountpercent, @v_returnpercent, @v_netprice, @v_calcdiscountind, @i_userid, getdate())
    ELSE  --don't copy percentages
      INSERT INTO taqversionsaleschannel
        (taqversionsaleskey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey,
        saleschannelcode, saleschannelsubcode, lastuserid, lastmaintdate)
      VALUES
        (@v_saleskey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, 
        @v_saleschannelcode, @v_saleschannelsubcode, @i_userid, getdate())    

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE saleschannel_cur
      DEALLOCATE saleschannel_cur
      SET @o_error_desc = 'Could not insert into taqversionsaleschannel table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    -- *** Loop through sales unit info for this sales channel and copy one at a time with new key ***
    DECLARE salesunit_cur CURSOR FOR
      SELECT yearcode, grosssalesunits, netsalesunits, salespercent
      FROM taqversionsalesunit
      WHERE taqversionsaleskey = @v_cur_saleskey

    OPEN salesunit_cur

    FETCH salesunit_cur 
    INTO @v_yearcode, @v_grossunits, @v_netunits, @v_salespercent

    WHILE (@@FETCH_STATUS=0)
    BEGIN

      -- TAQVERSIONSALESUNIT
      IF @i_copyvalues = 2 --copy everything
        INSERT INTO taqversionsalesunit
          (taqversionsaleskey, yearcode, grosssalesunits, netsalesunits, salespercent, lastuserid, lastmaintdate)
        VALUES
          (@v_saleskey, @v_yearcode, @v_grossunits, @v_netunits, @v_salespercent, @i_userid, getdate())
      ELSE  --don't copy percentages or units
        INSERT INTO taqversionsalesunit
          (taqversionsaleskey, yearcode, lastuserid, lastmaintdate)
        VALUES
          (@v_saleskey, @v_yearcode, @i_userid, getdate())                

      SELECT @v_error = @@ERROR
      IF @v_error <> 0 BEGIN
        CLOSE salesunit_cur
        DEALLOCATE salesunit_cur        
        CLOSE saleschannel_cur
        DEALLOCATE saleschannel_cur
        SET @o_error_desc = 'Could not insert into taqversionsalesunit table (Error ' + cast(@v_error AS VARCHAR) + ').'
        GOTO RETURN_ERROR
      END      

      FETCH salesunit_cur 
      INTO @v_yearcode, @v_grossunits, @v_netunits, @v_salespercent
    END

    CLOSE salesunit_cur
    DEALLOCATE salesunit_cur

    FETCH saleschannel_cur 
    INTO @v_cur_saleskey, @v_saleschannelcode, @v_saleschannelsubcode, @v_discountpercent, @v_returnpercent, @v_netprice, @v_calcdiscountind
  END

  CLOSE saleschannel_cur
  DEALLOCATE saleschannel_cur    

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

  -- *** Loop through version format year records for this format ***
  DECLARE formatyear_cur CURSOR FOR
    SELECT taqversionformatyearkey, yearcode, printingnumber, prodcostgeneratekey, quantity, percentage
    FROM taqversionformatyear
    WHERE taqprojectformatkey = @i_from_formatkey

  OPEN formatyear_cur

  FETCH formatyear_cur 
  INTO @v_cur_formatyearkey, @v_yearcode, @v_printingnumber, @v_prodcostgenkey, @v_quantity, @v_percentage

  WHILE (@@FETCH_STATUS=0)
  BEGIN

    -- generate new taqversionformatyearkey
    EXEC get_next_key @i_userid, @v_formatyearkey OUTPUT

    -- TAQVERSIONFORMATYEAR
    IF @i_copyvalues = 2  --copy everything
      INSERT INTO taqversionformatyear
        (taqversionformatyearkey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, yearcode,
        printingnumber, prodcostgeneratekey, quantity, percentage, lastuserid, lastmaintdate)
      VALUES
        (@v_formatyearkey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, @v_yearcode,
        @v_printingnumber, @v_prodcostgenkey, @v_quantity, @v_percentage, @i_userid, getdate())
    ELSE  --don't copy format details
      INSERT INTO taqversionformatyear
        (taqversionformatyearkey, taqprojectkey, plstagecode, taqversionkey, taqprojectformatkey, yearcode, lastuserid, lastmaintdate)
      VALUES
        (@v_formatyearkey, @i_new_projectkey, @i_new_plstage, @i_new_plversion, @v_new_formatkey, @v_yearcode, @i_userid, getdate())    

    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE formatyear_cur
      DEALLOCATE formatyear_cur
      SET @o_error_desc = 'Could not insert into taqversionformatyear table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    -- TAQVERSIONCOSTS
    IF @i_copyvalues = 2 BEGIN --copy everything
      INSERT INTO taqversioncosts
        (taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsnote, plcalccostsubcode, taqversionspeccategorykey,
        versioncostsamount, unitcost, compunitcost, acceptgenerationind, printingnumber, lastuserid, lastmaintdate)
      SELECT
        @v_formatyearkey, acctgcode, plcalccostcode, versioncostsnote, plcalccostsubcode, 0,
        CASE WHEN @v_zerocostsind = 1 THEN 0 ELSE ROUND(versioncostsamount, @v_num_decprecision) END versioncostsamount,
        CASE WHEN @v_zerocostsind = 1 THEN 0 ELSE unitcost END unitcost,
        CASE WHEN @v_zerocostsind = 1 OR plcalccostcode = 1 THEN 0 ELSE compunitcost END compunitcost,
        acceptgenerationind, printingnumber, @i_userid, getdate()
      FROM taqversioncosts
      WHERE taqversionformatyearkey = @v_cur_formatyearkey
        and taqversionspeccategorykey = 0

      INSERT INTO taqversioncosts
        (taqversionformatyearkey, acctgcode, plcalccostcode, versioncostsnote, plcalccostsubcode, taqversionspeccategorykey,
        versioncostsamount, unitcost, compunitcost, acceptgenerationind, printingnumber, lastuserid, lastmaintdate)
      SELECT
        @v_formatyearkey, acctgcode, plcalccostcode, versioncostsnote, plcalccostsubcode, 
        (select top 1 newtaqversionspeccategorykey from #speccategorykeys where oldtaqversionspeccategorykey = taqversioncosts.taqversionspeccategorykey),
        CASE WHEN @v_zerocostsind = 1 THEN 0 ELSE ROUND(versioncostsamount, @v_num_decprecision) END versioncostsamount,
        CASE WHEN @v_zerocostsind = 1 THEN 0 ELSE unitcost END unitcost,
        CASE WHEN @v_zerocostsind = 1 OR plcalccostcode = 1 THEN 0 ELSE compunitcost END compunitcost,
        acceptgenerationind, printingnumber, @i_userid, getdate()
      FROM taqversioncosts
      WHERE taqversionformatyearkey = @v_cur_formatyearkey
        and taqversionspeccategorykey > 0
    END
    ELSE BEGIN --don't copy cost details
      INSERT INTO taqversioncosts
        (taqversionformatyearkey, acctgcode, plcalccostcode, lastuserid, lastmaintdate, plcalccostsubcode, taqversionspeccategorykey)
      SELECT
        @v_formatyearkey, acctgcode, plcalccostcode, @i_userid, getdate(), plcalccostsubcode, 0
      FROM taqversioncosts
      WHERE taqversionformatyearkey = @v_cur_formatyearkey    
        and taqversionspeccategorykey = 0

      INSERT INTO taqversioncosts
        (taqversionformatyearkey, acctgcode, plcalccostcode, lastuserid, lastmaintdate, plcalccostsubcode, taqversionspeccategorykey)
      SELECT
        @v_formatyearkey, acctgcode, plcalccostcode, @i_userid, getdate(), plcalccostsubcode, 
        (select top 1 newtaqversionspeccategorykey from #speccategorykeys where oldtaqversionspeccategorykey = taqversioncosts.taqversionspeccategorykey)
      FROM taqversioncosts
      WHERE taqversionformatyearkey = @v_cur_formatyearkey    
        and taqversionspeccategorykey > 0
    END
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE formatyear_cur
      DEALLOCATE formatyear_cur
      SET @o_error_desc = 'Could not insert into taqversioncosts table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    -- TAQVERSIONINCOME
    IF @i_copyvalues = 2  --copy everything
      INSERT INTO taqversionincome
        (taqversionformatyearkey, acctgcode, incomenote, incomeamount, lastuserid, lastmaintdate)
      SELECT
        @v_formatyearkey, acctgcode, incomenote, ROUND(incomeamount, @v_num_decprecision), @i_userid, getdate()
      FROM taqversionincome
      WHERE taqversionformatyearkey = @v_cur_formatyearkey
    ELSE  --don't copy income details
      INSERT INTO taqversionincome
        (taqversionformatyearkey, acctgcode, lastuserid, lastmaintdate)
      SELECT
        @v_formatyearkey, acctgcode, @i_userid, getdate()
      FROM taqversionincome
      WHERE taqversionformatyearkey = @v_cur_formatyearkey
    
    SELECT @v_error = @@ERROR
    IF @v_error <> 0 BEGIN
      CLOSE formatyear_cur
      DEALLOCATE formatyear_cur
      SET @o_error_desc = 'Could not insert into taqversionincome table (Error ' + cast(@v_error AS VARCHAR) + ').'
      GOTO RETURN_ERROR
    END

    FETCH formatyear_cur 
    INTO @v_cur_formatyearkey, @v_yearcode, @v_printingnumber, @v_prodcostgenkey, @v_quantity, @v_percentage
  END

  CLOSE formatyear_cur
  DEALLOCATE formatyear_cur
     
  drop table #speccategorykeys      
  RETURN

RETURN_ERROR:  
  drop table #speccategorykeys      
  SET @o_error_code = -1
  RETURN
  
END
GO

GRANT EXEC ON qpl_copy_format TO PUBLIC
GO
