IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.qpo_generate_gposhiptovendor') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE [dbo].[qpo_generate_gposhiptovendor]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[qpo_generate_gposhiptovendor] (
  @i_po_report_projectkey INTEGER,
  @i_po_projectkey INTEGER,
  @i_gpokey INTEGER,
  @i_lastuserid VARCHAR(30),
  @o_error_code INTEGER OUTPUT,
  @o_error_desc VARCHAR(2000) OUTPUT
  )
AS
/*********************************************************************************************************************
**  Name: qpo_generate_gposhiptovendor
**  Desc: This procedure will be called from the Generate PO Report Function.
**        New projectkey key, related project key, gpokey and lastuserid 
**        will be passed in.
**  Auth: Kusum
**  Date: 3 September 2014
**********************************************************************************************************************
**********************************************************************************************************************
**    Change History
**********************************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   -----------------------------------------------------------------------------
**    12/13/16    Uday         42158     ShipTo Address 1 not written to gposhiptovendor 
**    02/08/17    Uday         43175     The sectionkey columns on gposhiptovendor and gposection do not match
**    06/23/17    BL           45987     Add vendorid2 to gposhiptovendor    
**    06/23/17    BL           46015     get ship date from printing instead of participant by role since it isn't working yet  
**    03/22/18    Colman       50385     Add text field to Participant by Role section
**    06/22/18    Colman       52137     Ship To Attention Names not displaying correctly on PO 
**    06/28/2018  Colman       TM-559    Report shipping date wrong
************************************************************************************************************************/
BEGIN
  SET @o_error_code = 0
  SET @o_error_desc = ''

  DECLARE @v_shipping_location_datacode INT,
    @v_shipping_location_rarelyused_datacode INT,
    @v_count INT,
    @v_globalcontactkey INT,
    @v_shiptoname VARCHAR(255),
    @v_taqprojectcontactkey INT,
    @v_addresskey INT,
    @v_shiptoaddress1 VARCHAR(255),
    @v_shiptoaddress2 VARCHAR(255),
    @v_shiptoaddress3 VARCHAR(255),
    @v_city VARCHAR(25),
    @v_province VARCHAR(25),
    @v_shiptocity VARCHAR(25),
    @v_statecode INT,
    @v_shiptostate VARCHAR(2),
    @v_shiptozipcode VARCHAR(10),
    @v_shipquantity INT,
    @v_shiptovendorid VARCHAR(100),
    @v_shiptovendorid2 VARCHAR(255),
    @v_country VARCHAR(40),
    @v_shippingmethodcode INT,
    @v_indicator INT,
    @v_tobesoldind INT,
    @v_note VARCHAR(MAX),
    @v_generictext VARCHAR(50),
    @v_detaillinenbr INT,
    @v_shiptoattn VARCHAR(30),
    @v_shipdate DATETIME,
    @v_globalcontactrelationshipkey INT,
    @v_purchaseorder_itemtypecode INT,
    @v_relateddatacode INT,
    @v_taqprojectcontactrolekey INT,
    @v_vendor_misckey INT,
    @v_vendor_misckey2 INT,
    @i_companymailingcode INT,
    @i_sectionkey INT,
    @i_finishedgoodtaqspeccategorykey INT, --this is from the printing project
    @i_relationshipcode1 INT, --15
    @i_relationshipcode2 INT, --14
    @v_taqversionformatkey INT,
    @v_printitemtype INT,
    @v_titleprintsectiontype INT,
    @v_projectsectiontype INT,
    @v_relcount INT,
    @v_relformatprojkey INT,
    @v_relformatbookkey INT,
    @v_relformatprintkey INT,
    @i_potypekey INT,
    @v_datetypecode INT,
    @v_po_typecode INT,
    @v_po_classcode INT,
    @v_taqtaskkey INT, 
    @v_rolecode INT


  SELECT @v_po_typecode = searchitemcode, @v_po_classcode = usageclasscode 
  FROM taqproject 
  WHERE taqprojectkey = @i_po_projectkey
  
  SELECT @v_datetypecode = (
    SELECT TOP(1) relateddatacode 
    FROM gentablesitemtype 
    WHERE tableid = 636 
      AND datacode = 7        -- Participants by Role 2 (Shipping Locations)
      AND datasubcode = 11    -- Date
      AND itemtypecode = @v_po_typecode
      AND itemtypesubcode IN (0, @v_po_classcode) 
    ORDER BY itemtypesubcode desc
  )
                        
  SELECT @i_companymailingcode = datacode
  FROM gentables
  WHERE tableid = 207
    AND qsicode = 1

  SELECT @i_relationshipcode1 = datacode
  FROM gentables
  WHERE tableid = 582
    AND qsicode = 28

  SELECT @i_relationshipcode2 = datacode
  FROM gentables
  WHERE tableid = 582
    AND qsicode = 27

  SELECT @v_printitemtype = datacode
  FROM gentables
  WHERE tableid = 550
    AND qsicode = 14

  SELECT @v_titleprintsectiontype = datacode
  FROM gentables
  WHERE tableid = 249
    AND qsicode = 2

  SELECT @v_projectsectiontype = datacode
  FROM gentables
  WHERE tableid = 249
    AND qsicode = 6

  SELECT @i_potypekey = potypekey
  FROM gpo
  WHERE gpokey = @i_po_report_projectkey

  SELECT @i_finishedgoodtaqspeccategorykey = tpo.taqversionspecategorykey
  FROM taqversionspeccategory tp --printing
  INNER JOIN taqversionspeccategory tpo ON tp.taqversionspecategorykey = tpo.relatedspeccategorykey
    AND ISNULL(tp.finishedgoodind, 0) = 1 --po summary to printing
  INNER JOIN taqprojectrelationship tr ON tpo.taqprojectkey = tr.taqprojectkey2
    AND tr.relationshipcode1 = @i_relationshipcode1
    AND tr.relationshipcode2 = @i_relationshipcode2
    AND tr.taqprojectkey1 = @i_gpokey --po summary to po report 

  --SELECT @i_sectionkey = sectionkey from gposection where gpokey= @i_gpokey and key3 =  @i_finishedgoodtaqspeccategorykey
  --IF ISNULL(@i_sectionkey,0)=0
  --select @i_sectionkey = min(sectionkey) from gposection where gpokey= @i_gpokey     
  SET @v_detaillinenbr = 0

  SELECT @v_shipping_location_datacode = datacode
  FROM gentables
  WHERE tableid = 285
    AND qsicode = 17

  SELECT @v_shipping_location_rarelyused_datacode = datacode
  FROM gentables
  WHERE tableid = 285
    AND qsicode = 18

  --Vendor
  SELECT @v_vendor_misckey = misckey
  FROM bookmiscitems
  WHERE qsicode = 13

  SELECT @v_vendor_misckey2 = misckey
  FROM bookmiscitems
  WHERE qsicode = 41

  DELETE
  FROM gposhiptovendor
  WHERE gpokey = @i_gpokey

  DECLARE taqprojectcontactrole_cur CURSOR
  FOR
  SELECT taqprojectcontactrolekey,
    taqprojectcontactkey,
    quantity,
    shippingmethodcode,
    indicator,
    globalcontactrelationshipkey,
    taqversionformatkey,
    generictext,
    rolecode
  FROM taqprojectcontactrole
  WHERE taqprojectkey = @i_po_projectkey
    AND rolecode IN (@v_shipping_location_datacode, @v_shipping_location_rarelyused_datacode)

  OPEN taqprojectcontactrole_cur

  FETCH taqprojectcontactrole_cur
  INTO @v_taqprojectcontactrolekey,
    @v_taqprojectcontactkey,
    @v_shipquantity,
    @v_shippingmethodcode,
    @v_indicator,
    @v_globalcontactrelationshipkey,
    @v_taqversionformatkey,
    @v_generictext,
    @v_rolecode

  WHILE @@FETCH_STATUS = 0
  BEGIN
    SET @v_relcount = NULL
    SET @v_relformatprojkey = NULL
    --Get sectionkey from gposection via multiple paths depending on related projects for taqversionformatkey
    SET @i_sectionkey = NULL

    SELECT @v_relcount = COUNT(*)
    FROM (
      SELECT relatedprojectkey AS relatedprojkey
      FROM taqversionformatrelatedproject
      WHERE taqversionformatkey = @v_taqversionformatkey
      
      UNION
      
      SELECT taqprojectkey AS relatedprojkey
      FROM taqversionformatrelatedproject
      WHERE relatedversionformatkey = @v_taqversionformatkey
      ) AS tvfrp

    IF @v_relcount = 1
    BEGIN
      SELECT @v_relformatprojkey = tvfrp.relatedprojkey
      FROM (
        SELECT relatedprojectkey AS relatedprojkey
        FROM taqversionformatrelatedproject
        WHERE taqversionformatkey = @v_taqversionformatkey
        
        UNION
        
        SELECT taqprojectkey AS relatedprojkey
        FROM taqversionformatrelatedproject
        WHERE relatedversionformatkey = @v_taqversionformatkey
        ) AS tvfrp

      IF EXISTS (
          SELECT *
          FROM taqproject
          WHERE taqprojectkey = @v_relformatprojkey
            AND searchitemcode = @v_printitemtype
          )
      BEGIN
        --Use printings bookkey as key1 and printingkey as key2 w/ sectiontype title/printing to get gposection
        SET @v_relformatbookkey = NULL
        SET @v_relformatprintkey = NULL

        SELECT @v_relformatbookkey = bookkey,
          @v_relformatprintkey = printingkey
        FROM taqprojectprinting_view
        WHERE taqprojectkey = @v_relformatprojkey

        IF ISNULL(@v_relformatbookkey, 0) > 0
          AND ISNULL(@v_relformatprintkey, 0) > 0
        BEGIN
          SELECT TOP 1 @i_sectionkey = sectionkey
          FROM gposection
          WHERE key1 = @v_relformatbookkey
            AND key2 = @v_relformatprintkey
            AND sectiontype = @v_titleprintsectiontype
            AND gpokey = @i_gpokey
        END
      END
      ELSE
      BEGIN
        --Use projectkey as key1 w/ sectiontype project (6) to get gposection
        SELECT TOP 1 @i_sectionkey = sectionkey
        FROM gposection
        WHERE key1 = @v_relformatprojkey
          AND sectiontype = @v_projectsectiontype
          AND gpokey = @i_gpokey
      END
    END
    ELSE
    BEGIN
      --Use actual PO projectkey (@i_po_projectkey) w/ sectiontype project (6) to get gposection
      SELECT TOP 1 @i_sectionkey = sectionkey
      FROM gposection
      WHERE key1 = @i_po_projectkey
        AND sectiontype = @v_projectsectiontype
        AND gpokey = @i_gpokey
    END

    SELECT @v_shiptoaddress1 = NULL,
      @v_shiptoaddress2 = NULL,
      @v_shiptoaddress3 = NULL,
      @v_city = NULL,
      @v_province = NULL,
      @v_shiptocity = NULL,
      @v_shiptozipcode = NULL,
      @v_statecode = NULL,
      @v_country = NULL,
      @v_shiptovendorid = NULL,
      @v_shiptovendorid2 = NULL,
      @v_note = NULL,
      @v_tobesoldind = NULL,
      @v_shiptoattn = NULL

    SELECT @v_globalcontactkey = globalcontactkey,
      @v_addresskey = addresskey
    FROM taqprojectcontact
    WHERE taqprojectcontactkey = @v_taqprojectcontactkey

    SELECT @v_shiptoname = displayname
    FROM globalcontact
    WHERE globalcontactkey = @v_globalcontactkey

    IF ISNULL(@v_addresskey, 0) = 0
    BEGIN
      SELECT @v_addresskey = max(globalcontactaddresskey)
      FROM globalcontactaddress
      WHERE globalcontactkey = @v_globalcontactkey
        AND addresstypecode = @i_companymailingcode
    END

    SELECT @v_shiptoaddress1 = address1,
      @v_shiptoaddress2 = address2,
      @v_shiptoaddress3 = address3,
      @v_city = city,
      @v_province = province,
      @v_shiptozipcode = zipcode,
      @v_statecode = statecode
    FROM globalcontactaddress
    WHERE globalcontactaddresskey = @v_addresskey
      AND globalcontactkey = @v_globalcontactkey

    IF (
        @v_city IS NOT NULL
        AND @v_city <> ''
        )
      AND (
        @v_province IS NOT NULL
        AND @v_province <> ''
        )
      SET @v_shiptocity = @v_city + ' ' + @v_province
    ELSE IF (
        @v_city IS NULL
        OR @v_city = ''
        )
      AND (
        @v_province IS NOT NULL
        AND @v_province <> ''
        )
      SET @v_shiptocity = @v_province
    ELSE IF (
        @v_city IS NOT NULL
        AND @v_city <> ''
        )
      AND (
        @v_province IS NULL
        OR @v_province = ''
        )
      SET @v_shiptocity = @v_city

    IF @v_statecode > 0
      SELECT @v_shiptostate = datadesc
      FROM gentables
      WHERE tableid = 160
        AND datacode = @v_statecode
    ELSE
      SET @v_shiptostate = ''

    SELECT @v_country = datadesc
    FROM gentables
    WHERE tableid = 114
      AND datacode = (
        SELECT countrycode
        FROM globalcontactaddress
        WHERE globalcontactaddresskey = @v_addresskey
        )

    SELECT @v_shiptovendorid = textvalue
    FROM globalcontactmisc
    WHERE globalcontactkey = @v_globalcontactkey
      AND misckey = @v_vendor_misckey

    SELECT @v_shiptovendorid2 = textvalue
    FROM globalcontactmisc
    WHERE globalcontactkey = @v_globalcontactkey
      AND misckey = @v_vendor_misckey2

    --SELECT @v_shipmethod = datadesc FROM gentables WHERE tableid = 1004 and datacode = @v_shippingmethodcode
    SELECT @v_tobesoldind = @v_indicator

    --SELECT @v_note = participantnote FROM taqprojectcontact WHERE globalcontactkey = @v_globalcontactkey AND taqprojectkey = @i_po_projectkey
    SELECT @v_note = participantnote
    FROM taqprojectcontact
    WHERE taqprojectcontactkey = @v_taqprojectcontactkey

    SELECT @v_shiptoattn = globalcontactname2
    FROM globalcontactrelationship_view
    WHERE globalcontactrelationshipkey = @v_globalcontactrelationshipkey

    -- relateddatacode for gentablesitemtype.tableid = 636 (Web Section), itemtype = Purchase Order,
    -- datacode for Pariticipant by Role2 section (7) and datasubcode = date (11)
    SELECT @v_purchaseorder_itemtypecode = datacode
    FROM gentables
    WHERE tableid = 550
      AND qsicode = 15

    SELECT @v_relateddatacode = relateddatacode
    FROM gentablesitemtype
    WHERE tableid = 636
      AND itemtypecode = @v_purchaseorder_itemtypecode
      AND datacode = 7
      AND datasubcode = 11

    SET @v_taqtaskkey = dbo.qutl_get_related_taqtaskkey(@v_datetypecode, @v_taqprojectcontactrolekey, @v_globalcontactkey, @v_rolecode, @i_po_projectkey, NULL, NULL)
    SELECT @v_shipdate = (
      SELECT activedate 
      FROM taqprojecttask 
      WHERE taqtaskkey = @v_taqtaskkey
    )

    SET @v_detaillinenbr = @v_detaillinenbr + 1

    --exec get_next_key @i_lastuserid, @v_shiptovendorkey output     
    -- Case 35134 - Shipping Locations are showing up under each section for an express PO:
    -- Hard-code sectionkey to 0 for now, until we get the Shared Component POs working     
    INSERT INTO gposhiptovendor (
      gpokey,
      sectionkey,
      shiptovendorkey,
      detaillinenbr,
      shiptoname,
      shiptoaddress1,
      shiptoaddress2,
      shiptoaddress3,
      shiptocity,
      shiptostate,
      shiptozipcode,
      shiptoattn,
      shiptovendorid,
      shipquantity,
      shipdate,
      shipmethod,
      lastuserid,
      lastmaintdate,
      distributionctr,
      tobesoldind,
      dcponum,
      gposhippinginstructions,
      country,
      shiptovendorid2
      )
    VALUES (
      @i_gpokey,
      ISNULL(@i_sectionkey, 0),
      @v_globalcontactkey,
      @v_detaillinenbr,
      @v_shiptoname,
      @v_shiptoaddress1,
      @v_shiptoaddress2,
      @v_shiptoaddress3,
      @v_shiptocity,
      @v_shiptostate,
      @v_shiptozipcode,
      @v_shiptoattn,
      @v_shiptovendorid,
      @v_shipquantity,
      @v_shipdate,
      @v_shippingmethodcode,
      @i_lastuserid,
      getdate(),
      NULL,
      @v_tobesoldind,
      @v_generictext,
      @v_note,
      @v_country,
      @v_shiptovendorid2
      )

    FETCH taqprojectcontactrole_cur
    INTO @v_taqprojectcontactrolekey,
      @v_taqprojectcontactkey,
      @v_shipquantity,
      @v_shippingmethodcode,
      @v_indicator,
      @v_globalcontactrelationshipkey,
      @v_taqversionformatkey,
      @v_generictext,
      @v_rolecode
  END -- fetch of taqprojectcontactrole_cur

  CLOSE taqprojectcontactrole_cur

  DEALLOCATE taqprojectcontactrole_cur
END
GO

GRANT EXECUTE
  ON [dbo].[qpo_generate_gposhiptovendor]
  TO [public] AS [dbo]
GO


