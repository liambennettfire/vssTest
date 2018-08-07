/****** Object:  StoredProcedure [dbo].[qpo_generate_gpoimportvendors]    Script Date: 02/20/2015 07:21:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpo_generate_gpoimportvendors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpo_generate_gpoimportvendors]
GO

/****** Object:  StoredProcedure [dbo].[qpo_generate_gpoimportvendors]    Script Date: 02/20/2015 07:21:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[qpo_generate_gpoimportvendors]
 (@i_related_projectkey   integer,
  @i_gpokey               integer,
  @i_lastuserid           varchar(30),
  @o_error_code           integer output,
  @o_error_desc           varchar(2000) output)
AS

/******************************************************************************
**  Name: qpo_generate_gpoimportvendors
**  Desc: This procedure will be called from the Generate PO Report Function.
**        Related project key, gpokey and lastuserid 
**        will be passed in.
**	Auth: Kusum
**	Date: 17 September 2014
*******************************************************************************
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**    03/02/2016   UK		   Case 36783  Issues finalizing a PO
**	  4/23/18		JL						Pull country description from misc field drop down, 
**											concatenate State value into City field since there isn't a separate State field
*******************************************************************************/
BEGIN

 SET @o_error_code = 0
 SET @o_error_desc = ''
 
 DECLARE
	@v_misckey INT,
	@v_paymentterms_char VARCHAR(100),
	@v_paymentterms_int INT,
	@v_freightterms INT,
	@v_importcountry INT,
	@v_importcountry_desc VARCHAR(40),
	@v_count INT,
	@v_foreign_vendor INT,
	@v_forwarding_agent INT,
	@v_packager INT,
	@v_globalcontactkey INT,
	@v_rolecode INT,
	@v_importkey INT,
	@v_addresskey INT,
    @v_address1 VARCHAR(255),
    @v_address2 VARCHAR(255),
    @v_city VARCHAR(25),
    @v_province VARCHAR(25),
    @v_shiptocity VARCHAR(25),
    @v_country VARCHAR(40),
    @v_zipcode VARCHAR(10),
    @v_shiptoattn VARCHAR(255),
    @v_name VARCHAR(255),
    @v_globalcontactrelationshipkey INT,
    @i_companymailingcode INT,
	@v_importcountrytable	int,
	@v_state	varchar(255)
    
 SELECT @i_companymailingcode = datacode from gentables where qsicode=1 and tableid=207   
 
 SELECT @v_misckey = misckey FROM bookmiscitems WHERE qsicode = 12 --Payment Terms
 
 SELECT @v_paymentterms_char = textvalue FROM taqprojectmisc where taqprojectkey = @i_related_projectkey AND misckey = @v_misckey
 
 SELECT @v_paymentterms_char = dbo.qutl_get_numeric_fromalphanumeric (@v_paymentterms_char) 
 
 IF IsNumeric(@v_paymentterms_char) = 1 BEGIN
	SET @v_paymentterms_int = CAST(@v_paymentterms_char AS INT)
 END
  
 
 SELECT @v_misckey = misckey FROM bookmiscitems WHERE qsicode = 19 --Freight Terms
 
 SELECT @v_freightterms = longvalue FROM taqprojectmisc where taqprojectkey = @i_related_projectkey AND misckey = @v_misckey
 
  
 SELECT @v_misckey = misckey, @v_importcountrytable = datacode FROM bookmiscitems WHERE qsicode = 20 --Import Country
 
 SELECT @v_importcountry = longvalue FROM taqprojectmisc where taqprojectkey = @i_related_projectkey AND misckey = @v_misckey
 
 IF @v_importcountry > 0 BEGIN
  SELECT @v_importcountry_desc = datadesc FROM subgentables WHERE tableid = 525 AND datacode = @v_importcountrytable and datasubcode = @v_importcountry
 END
 
 --Foreign Vendor or Foreign Manufacturer
 SELECT @v_foreign_vendor = datacode FROM gentables WHERE tableid = 285 and qsicode = 19
 
 -- Forwarding Agent
 SELECT @v_forwarding_agent = datacode FROM gentables WHERE tableid = 285 and qsicode = 20
  
 -- PAckager
 SELECT @v_packager = datacode FROM gentables WHERE tableid = 285 and qsicode = 21
 
 SET @v_count = 0 
 
 DELETE FROM gpoimport WHERE gpokey = @i_gpokey
 
 DELETE FROM gpoimportvendors WHERE gpokey = @i_gpokey
 
 INSERT INTO gpoimport(gpokey, paytermsdays, freightpricingind, freightpricingcountry, lastuserid,lastmaintdate)
	VALUES(@i_gpokey,@v_paymentterms_int,@v_freightterms,@v_importcountry_desc,@i_lastuserid,getdate())
	
 SELECT @v_count = COUNT(*)
   FROM taqprojectcontactrole
  WHERE taqprojectkey = @i_related_projectkey
    AND rolecode IN (@v_foreign_vendor,@v_forwarding_agent,@v_packager)
    
 
 IF @v_count > 0 BEGIN
	DECLARE taqprojectcontacts_cur CURSOR FOR 
	    SELECT DISTINCT c.globalcontactkey, r.rolecode, c.addresskey,r.globalcontactrelationshipkey
		  FROM taqprojectcontact c, taqprojectcontactrole r
	  WHERE c.taqprojectcontactkey = r.taqprojectcontactkey AND 
		  c.taqprojectkey = @i_related_projectkey 
		  AND r.rolecode IN (@v_foreign_vendor,@v_forwarding_agent,@v_packager)
		  
	OPEN taqprojectcontacts_cur
    
    FETCH taqprojectcontacts_cur INTO @v_globalcontactkey, @v_rolecode, @v_addresskey,@v_globalcontactrelationshipkey
    
    WHILE @@fetch_status = 0 BEGIN
		SET @v_name = NULL
		SET @v_address1 = NULL
		SET @v_address2 = NULL
		SET @v_shiptocity = NULL
		SET @v_country = NULL
		SET @v_zipcode = NULL
		SET @v_shiptoattn = NULL
		    
	    IF @v_rolecode = @v_foreign_vendor SET @v_importkey = 1
	    IF @v_rolecode = @v_forwarding_agent SET @v_importkey = 2
	    IF @v_rolecode = @v_packager SET @v_importkey = 3
	    
	    IF coalesce (@v_addresskey,0) =0
		begin	
		    select @v_addresskey = max(globalcontactaddresskey) from globalcontactaddress where globalcontactkey = @v_globalcontactkey
		    and addresstypecode = @i_companymailingcode
	    	end

	    SELECT @v_name = displayname FROM globalcontact WHERE globalcontactkey = @v_globalcontactkey
	    
	   		
	    SELECT @v_address1 = address1,@v_address2 = address2, @v_city = city,@v_province = province,
				@v_state = gs.datadesc, @v_country = gc.datadesc,
	           @v_zipcode = coalesce(zipcode,'')
	    	  FROM globalcontactaddress gca
			  left outer join gentables gs
			  on gca.statecode = gs.datacode
			  and gs.tableid = 160 
			  left outer join gentables gc
			  on gca.countrycode = gc.datacode
			  and gc.tableid = 114
			  WHERE globalcontactaddresskey = @v_addresskey
	    	
	   
	   --state and province are mutually exclusive so only one of them will be populated
		if isnull(@v_state,'') <> ''
		begin
			if (isnull(@v_city,'') <> '')
				SET @v_shiptocity = @v_city + ', ' + @v_state
			else
				set @v_shiptocity = @v_state
		end

		if isnull(@v_province,'') <> ''
		begin
			if (isnull(@v_city,'') <> '')
				SET @v_shiptocity = @v_city + ', ' + @v_province
			else
				set @v_shiptocity = @v_province
		end

		if @v_shiptocity is null
			set @v_shiptocity = @v_city

 
	    SELECT @v_shiptoattn = contactname2 FROM globalcontactrelationship_view WHERE globalcontactrelationshipkey = @v_globalcontactrelationshipkey
			
	    INSERT INTO gpoimportvendors (gpokey,vendorkey,importkey,name,address1,address2,city,country,zipcode,attention, lastuserid,
	      lastmaintdate,dcponum)
	      VALUES(@i_gpokey,@v_globalcontactkey,@v_importkey,@v_name,@v_address1,@v_address2,@v_shiptocity,@v_country ,@v_zipcode,@v_shiptoattn,
	       @i_lastuserid,getdate(),NULL )
 
 
		FETCH taqprojectcontacts_cur INTO @v_globalcontactkey, @v_rolecode, @v_addresskey,@v_globalcontactrelationshipkey
	END -- end of cursor loop
	
	CLOSE taqprojectcontacts_cur
	DEALLOCATE taqprojectcontacts_cur
 
 END  --@v_count > 0
 
END

GO

GRANT EXEC on [dbo].[qpo_generate_gpoimportvendors] to PUBLIC
GO


