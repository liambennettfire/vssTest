if exists (select * from dbo.sysobjects where id = object_id(N'dbo.qpo_generate_gposhiptovendor') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.qpo_generate_gposhiptovendor
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE qpo_generate_gposhiptovendor
 (@i_projectkey           integer,
  @i_related_projectkey   integer,
  @i_gpokey               integer,
  @i_lastuserid           varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/*********************************************************************************************************************
**  Name: qpo_generate_gposhiptovendor
**  Desc: This procedure will be called from the Generate PO Report Function.
**        New projectkey key, related project key, gpokey and lastuserid 
**        will be passed in.
**	Auth: Kusum
**	Date: 3 September 2014
**********************************************************************************************************************
**********************************************************************************************************************
**    Change History
**********************************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   -----------------------------------------------------------------------------
**    12/13/16    Uday         42158     ShipTo Address 1 not written to gposhiptovendor
************************************************************************************************************************/
BEGIN

 SET @o_error_code = 0
 SET @o_error_desc = ''
 
 
 DECLARE @v_shipping_location_datacode INT,
         @v_shipping_location_rarelyused_datacode	INT,
         @v_count	INT,
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
         @v_country VARCHAR(40),
         @v_shippingmethodcode INT,
         @v_indicator INT,
         @v_tobesoldind INT,
         @v_note VARCHAR(MAX),
         @v_detaillinenbr INT,
         @v_shiptoattn VARCHAR(30),
         @v_shipdate DATETIME,
         @v_globalcontactrelationshipkey INT,
         @v_purchaseorder_itemtypecode INT,
         @v_relateddatacode INT,
         @v_taqprojectcontactrolekey INT,
         @v_vendor_misckey INT,
		 @i_companymailingcode INT,
		 @i_sectionkey INT,
		 @i_finishedgoodtaqspeccategorykey INT, --this is from the printing project
		 @i_relationshipcode1 INT, --15
		 @i_relationshipcode2 INT --14
         
 SELECT @i_companymailingcode = datacode from gentables where tableid=207 and qsicode=1
 SELECT @i_relationshipcode1 = datacode from gentables where tableid=582 and qsicode=28
 SELECT @i_relationshipcode2 = datacode from gentables where tableid =582 and qsicode = 27
 
 SELECT @i_finishedgoodtaqspeccategorykey = tpo.taqversionspecategorykey 
 from taqversionspeccategory tp --printing
 inner join taqversionspeccategory tpo on tp.taqversionspecategorykey = tpo.relatedspeccategorykey and coalesce(tp.finishedgoodind,0)=1 --po summary to printing
 inner join taqprojectrelationship tr on tpo.taqprojectkey = tr.taqprojectkey2 and  tr.relationshipcode1=@i_relationshipcode1 and tr.relationshipcode2=@i_relationshipcode2 and tr.taqprojectkey1=@i_gpokey  --po summary to po report
 
 SELECT  @i_sectionkey = sectionkey from gposection where gpokey= @i_gpokey and key3 =  @i_finishedgoodtaqspeccategorykey
 
 IF coalesce(@i_sectionkey,0)=0
	select @i_sectionkey = min(sectionkey) from gposection where gpokey= @i_gpokey     
         
 SET @v_detaillinenbr = 0		 
 SELECT @v_shipping_location_datacode = datacode FROM gentables WHERE tableid = 285 AND qsicode = 17
 SELECT @v_shipping_location_rarelyused_datacode = datacode FROM gentables WHERE tableid = 285 AND qsicode = 18
 --Vendor
 SELECT @v_vendor_misckey = misckey from bookmiscitems where qsicode = 13
         
 DELETE FROM gposhiptovendor WHERE gpokey = @i_gpokey
  
  
 SELECT @v_count = COUNT(*) 
   FROM taqprojectcontactrole
  WHERE taqprojectkey = @i_related_projectkey
    AND rolecode in (@v_shipping_location_datacode,@v_shipping_location_rarelyused_datacode)
   
  
 IF @v_count > 0 BEGIN
	DECLARE taqprojectcontactrole_cur CURSOR FOR
      SELECT taqprojectcontactrolekey, taqprojectcontactkey, quantity,shippingmethodcode,indicator,globalcontactrelationshipkey
	    FROM taqprojectcontactrole
       WHERE taqprojectkey = @i_related_projectkey
         AND rolecode in (@v_shipping_location_datacode,@v_shipping_location_rarelyused_datacode)
         
    OPEN taqprojectcontactrole_cur
         
	FETCH taqprojectcontactrole_cur INTO @v_taqprojectcontactrolekey, @v_taqprojectcontactkey, @v_shipquantity,@v_shippingmethodcode,
		@v_indicator,@v_globalcontactrelationshipkey
	
	
	 WHILE @@fetch_status = 0 BEGIN
	 
	   SELECT @v_shiptoaddress1  = NULL, @v_shiptoaddress2 = NULL, @v_shiptoaddress3 = NULL, @v_city = NULL, @v_province = NULL,
	          @v_shiptocity = NULL, @v_shiptozipcode = NULL, @v_statecode = NULL, @v_country = NULL, @v_shiptovendorid = NULL,
	          @v_note = NULL,@v_tobesoldind = NULL, @v_shiptoattn = NULL
	          	 
	   SELECT @v_globalcontactkey = globalcontactkey, @v_addresskey = addresskey
	     FROM taqprojectcontact
	    WHERE taqprojectcontactkey = @v_taqprojectcontactkey
	   
	   SELECT @v_shiptoname = displayname FROM globalcontact WHERE globalcontactkey = @v_globalcontactkey
	    
	   IF coalesce(@v_addresskey,0)=0
	   begin
	   select @v_addresskey = max(globalcontactaddresskey) from globalcontactaddress where globalcontactkey = @v_globalcontactkey
	    and addresstypecode = @i_companymailingcode 
	   end 
	       
	   SELECT @v_shiptoaddress1 = address1,@v_shiptoaddress2 = address2,@v_shiptoaddress3 = address3,
	           @v_city = city,@v_province = province,@v_shiptozipcode = zipcode,@v_statecode = statecode
	      FROM globalcontactaddress WHERE globalcontactaddresskey = @v_addresskey
	       AND globalcontactkey = @v_globalcontactkey
	 
	     
	   IF (@v_city IS NOT NULL AND @v_city <> '') AND (@v_province IS NOT NULL AND @v_province <> '')
		SET @v_shiptocity = @v_city + ' ' + @v_province
	   ELSE IF (@v_city IS NULL OR @v_city = '') AND (@v_province IS NOT NULL AND @v_province <> '')
		SET @v_shiptocity =  @v_province
	   ELSE IF (@v_city IS NOT NULL AND @v_city <> '') AND (@v_province IS NULL OR @v_province = '')
		SET @v_shiptocity = @v_city 
		
	  	   
	   IF @v_statecode > 0 
		SELECT @v_shiptostate = datadesc FROM gentables WHERE tableid = 160 and datacode = @v_statecode
	   ELSE
	    SET @v_shiptostate = ''
	    
	   	   
	   SELECT @v_country = datadesc FROM gentables WHERE tableid = 114 AND datacode = 
	     (SELECT countrycode FROM globalcontactaddress WHERE globalcontactaddresskey = @v_addresskey)
	   
	   SELECT @v_shiptovendorid = textvalue FROM globalcontactmisc WHERE globalcontactkey = @v_globalcontactkey
	     AND misckey = @v_vendor_misckey
	   
	   --SELECT @v_shipmethod = datadesc FROM gentables WHERE tableid = 1004 and datacode = @v_shippingmethodcode
	   
	   SELECT @v_tobesoldind = @v_indicator
	   
	  
	   --SELECT @v_note = participantnote FROM taqprojectcontact WHERE globalcontactkey = @v_globalcontactkey AND taqprojectkey = @i_related_projectkey
	   SELECT @v_note = participantnote FROM taqprojectcontact WHERE taqprojectcontactkey= @v_taqprojectcontactkey
	    
	   
	   SELECT @v_shiptoattn = contactname2 FROM globalcontactrelationship_view WHERE globalcontactrelationshipkey = @v_globalcontactrelationshipkey
 
     -- relateddatacode for gentablesitemtype.tableid = 636 (Web Section), itemtype = Purchase Order,
     -- datacode for Pariticipant by Role2 section (7) and datasubcode = date (11)
	   SELECT @v_purchaseorder_itemtypecode = datacode FROM gentables WHERE tableid = 550 and qsicode = 15

	   SELECT @v_relateddatacode = relateddatacode
	     FROM gentablesitemtype 
	    WHERE tableid = 636 
		  AND itemtypecode = @v_purchaseorder_itemtypecode 
		  AND datacode = 7 AND datasubcode = 11

       SELECT @v_shipdate = activedate 
         FROM taqprojecttask 
        WHERE globalcontactkey = @v_globalcontactkey
          AND datetypecode = @v_relateddatacode
	     
	   SET @v_detaillinenbr = @v_detaillinenbr + 1 
	   
	   --exec get_next_key @i_lastuserid, @v_shiptovendorkey output	   
     
     -- Case 35134 - Shipping Locations are showing up under each section for an express PO:
     -- Hard-code sectionkey to 0 for now, until we get the Shared Component POs working     
	   INSERT INTO gposhiptovendor (gpokey, sectionkey, shiptovendorkey, detaillinenbr,shiptoname,shiptoaddress1,
	     shiptoaddress2, shiptoaddress3, shiptocity, shiptostate, shiptozipcode, shiptoattn,
	     shiptovendorid, shipquantity, shipdate, shipmethod, lastuserid, lastmaintdate, distributionctr, tobesoldind,
	     dcponum, gposhippinginstructions, country)
	   VALUES (@i_gpokey, 0, @v_globalcontactkey,@v_detaillinenbr,@v_shiptoname, @v_shiptoaddress1,
	     @v_shiptoaddress2,@v_shiptoaddress3,@v_shiptocity,@v_shiptostate,@v_shiptozipcode,@v_shiptoattn,
	     @v_shiptovendorid,@v_shipquantity,@v_shipdate,@v_shippingmethodcode,@i_lastuserid,getdate(),NULL,@v_tobesoldind,
	     NULL,@v_note,@v_country)
	   
	  
		FETCH taqprojectcontactrole_cur INTO @v_taqprojectcontactrolekey, @v_taqprojectcontactkey, @v_shipquantity,@v_shippingmethodcode,
			@v_indicator,@v_globalcontactrelationshipkey
	 END  -- fetch of taqprojectcontactrole_cur
	 
	 CLOSE taqprojectcontactrole_cur 
	 DEALLOCATE taqprojectcontactrole_cur
 END --@v_count > 0
 
END
GO

GRANT EXEC ON qpo_generate_gposhiptovendor TO PUBLIC
GO
