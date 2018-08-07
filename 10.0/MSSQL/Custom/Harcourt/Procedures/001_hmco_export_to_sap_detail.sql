/****** Object:  StoredProcedure [dbo].[hmco_export_to_SAP_detail]    Script Date: 10/05/2008 15:39:25 ******/
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[hmco_export_to_SAP_detail]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[hmco_export_to_SAP_detail]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



-- =============================================
-- Author:		Jennifer Hurd
-- Create date: 10/1/08
-- Description:	exports data to SAP
-- you can run this by calling hmco_export_to_sap_driver to let it determine bookkeys to run
-- or run it for individual bookkeys, just sending in the arguments setting the prevstartdatetime to the starting
-- period for the data and startdatetime as the end of the run period.  this startdatetime will be written as 
-- the extract date on the file.
--
--  12/10/15 - KB - Case 35150 
--  Remove Internal Comment logic and Merchandising Theme logic
--  Add Edition Category logic
--  02/02/2016 - KB - Case 35150  Task 002 - Reopened
--	08/21/17 - JL - case 46623 add tariff code misc field
-- =============================================
CREATE PROCEDURE [dbo].[hmco_export_to_SAP_detail] 
	@i_bookkey int = 0, 
	@i_userid   varchar(30),
	@i_prevstart_datetime	datetime,
	@i_start_datetime	datetime,
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN

declare     @v_error  INT,
@v_rowcount INT,
@whichgenfield	char(1), 
@Plant varchar(15) ,
@MaterialType varchar(15)  ,
@Material varchar(20)  ,
@EditionCategory varchar(20),     --12/10/15 - KB - Case 35150
@ISBN13 varchar(13) ,
@ISBN10 varchar(10) ,
@UPCCode varchar(13) ,
@Description varchar(50) ,
@Author varchar(50) ,
@Subtitle2 varchar(80) ,
@Subtitle3 varchar(80) ,
@Language varchar(30) ,
--@MediaProduct varchar(15) ,
@ContentCategory varchar(15) ,
@PublicationType varchar(15) ,
@MediaType varchar(15) ,
@Publicationdate datetime,
@EditionCounter int ,
@CopyrightYear int,
@MaterialStatus varchar(15) ,
@ReprintingType varchar(30) ,
@UnitofMeasure int,
@NumberofPubs int,
@BasicDataText varchar(2000) ,
@InspectionText varchar(2000) ,
--@InternalComment varchar(2000) ,
@ProductPresentation varchar(15) ,
@MaterialGroup varchar(15) ,
@ExternalMaterialGroup varchar(15) ,
@Division varchar(15),
@ProductHierarchy varchar(11) ,
@GeneralItemCategory varchar(15) ,
@DchainSpecStatus varchar(15) ,
@MaterialStatisticsGroup varchar(15) ,
@MaterialPricingGroup varchar(15) ,
@AccountAssignmentGroup varchar(15) ,
@CartonRounding varchar(15) ,
@ReturnsDisposition varchar(15) ,
@BeginningGradeLevel varchar(15) ,
@EndingGradeLevel varchar(15) ,
@PreviousISBN10 varchar(10) ,
@PreviousISBN13 varchar(13) ,
@NextISBN10 varchar(10) ,
@NextISBN13 varchar(13) ,
@OnixMedia varchar(15) ,
@OnixBinding varchar(15) ,
@AudienceType varchar(15) ,
--@PubYear int,
@Season varchar(15) ,
--@MerchandisingTheme varchar(15) ,
@BeginningAge varchar(15),
@EndingAge varchar(15),
@USRetailPrice float,
--@CanRetailprice float,	--7/20/10 removed per MV
--@CartonCount int,
@SAPDataSetup varchar(30),
@trimwidth	varchar(10),
@trimlength	varchar(10),
@pagecount	int,
@numcolors	int,
@textink	varchar(30),
@returnrestriction	varchar(15),
@releasedate	datetime,
@internalstatus	varchar(15),
@authorartist varchar(30),
@tariffcode varchar(30),
@countryoforigin varchar(15),
@requestUPC varchar(15),
@requestISBN varchar(15),
@safetytest varchar(15),
@bookkey int,
@pss_extract_date datetime,
@sap_status varchar(20) ,
@sap_request_type varchar(20) ,
@sap_status_change_date	datetime,
@sap_status_change_user varchar(30) ,
@sap_email_sent char(1) ,
@pss_email_sent char(1) ,
@comments		varchar(2000),
@count int,
@authortype	int,
@onsaledate	datetime,
@productsafety varchar(10),
@cpsiasafetytestreq varchar(10)

declare @Plantchange    int,
@MaterialTypechange    int,
@Materialchange    int,
@EditionCategorychange int,   --12/10/15 - KB - Case 35150
@ISBN13change    int,
@ISBN10change    int,
@UPCCodechange    int,
@Descriptionchange    int,
@Authorchange    int,
@Subtitle2change    int,
@Subtitle3change    int,
@Languagechange    int,
--@MediaProductchange    int,
@ContentCategorychange    int,
@PublicationTypechange    int,
@MediaTypechange    int,
@Publicationdatechange    int,
@EditionCounterchange    int,
@CopyrightYearchange    int,
@MaterialStatuschange    int,
@ReprintingTypechange    int,
@UnitofMeasurechange    int,
@NumberofPubschange    int,
@BasicDataTextchange    int,
@InspectionTextchange    int,
--@InternalCommentchange    int,
@ProductPresentationchange    int,
@MaterialGroupchange    int,
@ExternalMaterialGroupchange    int,
@Divisionchange    int,
@ProductHierarchychange    int,
@GeneralItemCategorychange    int,
@DchainSpecStatuschange    int,
@MaterialStatisticsGroupchange    int,
@MaterialPricingGroupchange    int,
@AccountAssignmentGroupchange    int,
@CartonRoundingchange    int,
@ReturnsDispositionchange    int,
@BeginningGradeLevelchange    int,
@EndingGradeLevelchange    int,
@PreviousISBN10change    int,
@PreviousISBN13change    int,
@NextISBN10change    int,
@NextISBN13change    int,
@OnixMediachange    int,
@OnixBindingchange    int,
@AudienceTypechange    int,
--@PubYearchange    int,
@Seasonchange    int,
--@MerchandisingThemechange    int,
@BeginningAgechange    int,
@EndingAgechange    int,
@USRetailPricechange    int,
--@CanRetailpricechange    int,	--7/20/10 removed per MV
--@CartonCountchange    int,
@SAPDataSetupchange    int,
@trimwidthchange	int,
@trimlengthchange	int,
@pagecountchange	int,
@numcolorschange	int,
@textinkchange	int,
@returnrestrictionchange	int,
@releasedatechange	int,
@internalstatuschange	int,
@authorartistchange    int,
@tariffcodechange    int,
@countryoforiginchange    int,
@requestupcchange    int,
@requestISBNchange    int,
@safetytestchange    int,
@onsaledatechange	int,
@productsafetychange int,
@cpsiasafetytestreqchange int	



set @whichgenfield = 'S'
/*		Column
		D = Data Description
		E = External code
		S = Short Description
		B = BISAC Data Code
		T = Eloquence Field Tag
		1 = Alternative Description 1
		2 = Alternative Deccription 2 */


SET @o_error_code = 0
SET @o_error_desc = ''  

--	set @comments = ''
set @Division = 20
set @pss_extract_date = @i_start_datetime
set @sap_status = 'Pending'
set @sap_status_change_date = @i_start_datetime
set @sap_status_change_user = 'PSS'
set @sap_email_sent = 'N'
set @pss_email_sent = 'N'


--	SET NOCOUNT ON
set @count = 0
set @sap_request_type = ''

--only continue with this bookkey if status is Request, Fix Request, or Release
-- PM 10/3/14 add 'Reprocess' per Michelle VU
select @SAPDataSetup = isnull(dbo.get_bookmisc_gent (@i_bookkey, 24, 'D'),'')
--if @sapdatasetup <> 'Request' and @sapdatasetup <> 'Fix Request'  and @sapdatasetup <> 'Release' begin
--	return
--end
if @sapdatasetup <> 'Request' and @sapdatasetup <> 'Fix Request'  and @sapdatasetup <> 'Release' and @sapdatasetup <> 'Reprocess' begin  -- reprocess added pm 10/3/14
	return
end


select @Material = substring(dbo.get_isbn_item (@i_bookkey, 15),1,20)
if @sapdatasetup <> 'Request' begin		--must send material for update
	if @material is null or @material = '' begin
		SET @o_error_code = 1
		SET @o_error_desc = 'Material empty with status above request.  Row not written for this bookkey.'
		RETURN
	end
end

----if sap data setup value just changed to "Request", insert record with all details as the initial record for this bookkey
--this code commented out and replaced with simple @sapdatasetup check below
--select @count = isnull(count(*),0)
--from titlehistory th
--join subgentables gt
--on th.currentstringvalue = gt.datadesc
--and gt.tableid = 525
--and gt.datacode = 14
--and gt.qsicode = 2
--where th.bookkey = @i_bookkey
--and columnkey = 248
--and fielddesc = 'SAP Data Setup'
--and th.lastmaintdate > @i_prevstart_datetime		
--and th.lastmaintdate <= @i_start_datetime

--5/17/10 JL - set @material = '' commented out per Michelle Vu, don't clear it out if it exists
if @sapdatasetup = 'Request' begin
	set @sap_request_type = 'Request'
--	set @material = ''
end
else begin
	set @count = 0
--if bookkey is not a new request, check to see what fields have changed that are being sent to SAP
--Update records should only be populated with fields that have changed and there should only be 1 row per bookkey per run
	select @count = isnull(count(*),0),
	@MaterialStatuschange = sum(case when columnkey = 4 then 1 else 0 end),
	@OnixMediachange = isnull(sum(case when columnkey = 10 then 1 else 0 end),0),
	@OnixBindingchange = isnull(sum(case when columnkey = 11 then 1 else 0 end),0),
	@Seasonchange = sum(case when columnkey = 12 or columnkey = 13 then 1 else 0 end),
	@ProductHierarchychange = sum(case when columnkey = 23 then 1 else 0 end),
	@Languagechange = sum(case when columnkey = 28 then 1 else 0 end),
	@BeginningGradeLevelchange = isnull(sum(case when columnkey = 29 then 1 when columnkey = 64 then 1 else 0 end),0),
	@EndingGradeLevelchange = isnull(sum(case when columnkey = 30 then 1 when columnkey = 63 then 1 else 0 end),0),
	@BeginningAgechange = isnull(sum(case when columnkey = 32 then 1 when columnkey = 62 then 1 else 0 end),0),
	@EndingAgechange = isnull(sum(case when columnkey = 33 then 1 when columnkey = 61 then 1 else 0 end),0),
	@ReturnsDispositionchange = sum(case when columnkey = 35 then 1 else 0 end),
	@Descriptionchange = sum(case when columnkey = 41 then 1 else 0 end),
	@ISBN10change = sum(case when columnkey = 43 then 1 else 0 end),
	@UPCCodechange = sum(case when columnkey = 44 then 1 else 0 end),
	@ISBN13change = sum(case when columnkey = 45 then 1 else 0 end),
	@EditionCounterchange = isnull(sum(case when columnkey = 243 then 1 else 0 end),0),
	@Subtitle2change = isnull(sum(case when columnkey = 50 then 1 else 0 end),0),
	@Subtitle3change = isnull(sum(case when columnkey = 50 then 1 else 0 end),0),
--	@PubYearchange = sum(case when columnkey = 76 then 1 else 0 end),
--	@CartonCountchange = sum(case when columnkey = 89 then 1 else 0 end),
	@MaterialPricingGroupchange = sum(case when columnkey = 90 then 1 else 0 end),
	@AudienceTypechange = sum(case when columnkey = 91 then 1 else 0 end),
  @InspectionTextchange = sum(case when columnkey = 3 then 1 else 0 end),
	@DchainSpecStatuschange = isnull(sum(case when columnkey = 210 then 1 else 0 end),0),
--	@ReprintingTypechange = sum(case when columnkey = 218 then 1 else 0 end), 7/26/14 MV removed
	@CopyrightYearchange = isnull(sum(case when columnkey = 235 then 1 else 0 end),0),
	@trimlengthchange = isnull(sum(case when columnkey = 20 or columnkey = 87 or columnkey = 22 then 1 else 0 end),0),
	@trimwidthchange = isnull(sum(case when columnkey = 19 or columnkey = 86 or columnkey = 21 then 1 else 0 end),0),
	@pagecountchange = isnull(sum(case when columnkey = 15 or columnkey = 16 or columnkey = 88 then 1 else 0 end),0),
	@numcolorschange = isnull(sum(case when columnkey = 263 then 1 else 0 end),0),
	@textinkchange = isnull(sum(case when columnkey = 263 then 1 else 0 end),0),
	@returnrestrictionchange = isnull(sum(case when columnkey = 34 then 1 else 0 end),0),
	@internalstatuschange = isnull(sum(case when columnkey = 2 then 1 else 0 end),0),
	@NextISBN10change = sum(case when columnkey = 240 and fielddesc = 'Replaced by' then 1 else 0 end),
	@PreviousISBN10change = sum(case when columnkey = 240 and fielddesc = 'Replaces' then 1 else 0 end),
	@BasicDataTextchange = sum(case when columnkey = 42 or columnkey = 1 then 1 else 0 end)
--  @InternalCommentchange = sum(case when columnkey = 42 or columnkey = 1 or columnkey = 10 or columnkey = 11 then 1 else 0 end),
	--@MerchandisingThemechange = sum(case when columnkey = 220 or columnkey = 221 or columnkey =222 then 1 else 0 end)
	from titlehistory th
	where bookkey = @i_bookkey
	and th.printingkey = 1
	and th.lastmaintdate > @i_prevstart_datetime		
	and th.lastmaintdate <= @i_start_datetime
	and th.lastuserid not in ('sapimport','xart2')
	and (columnkey in (1,2,3,4,10,11,13,15,16,19,20,21,22,23,28,29,30,32,33,34,35,41,42,43,44,45,50,86,87,88,90,91,210,218,235,243,263)
	or (columnkey = 240 and fielddesc in ('Replaced by','Replaces')))

	if @count > 0 begin
		set @sap_request_type = 'Update'
	end
	
		set @count = 0

	select @count = isnull(count(*),0),
	 @ProductSafetyChange = isnull(sum(case when columnkey = 220 or columnkey = 221 or columnkey =222 then 1 else 0 end),0)
	 from titlehistory th
	where bookkey = @i_bookkey
	and th.printingkey = 1
	and th.lastmaintdate > @i_prevstart_datetime		
	and th.lastmaintdate <= @i_start_datetime
	and th.lastuserid <> 'sapimport'
	and (lower(currentstringvalue) LIKE '%product safety%' or 
         lower(currentstringvalue) LIKE '%chocking hazard%' or
         lower(currentstringvalue)  LIKE '%chemical hazard%' OR 
         LOWER(fielddesc) like '%product safety%')
         
    if @count > 0 begin
		set @sap_request_type = 'Update'
	end

	set @count = 0
--bookmisc gentable value fields
	select @count = isnull(count(*),0),
	@Plantchange = sum(case when misckey = 12 then 1 else 0 end),
	@MaterialTypechange = sum(case when misckey = 22 then 1 else 0 end),
	@ContentCategorychange = sum(case when misckey = 19 then 1 else 0 end),
	@PublicationTypechange = sum(case when misckey = 8 then 1 else 0 end),
	@MediaTypechange = sum(case when misckey = 14 then 1 else 0 end),
	@ProductPresentationchange = sum(case when misckey = 20 then 1 else 0 end),
	@MaterialGroupchange = sum(case when misckey = 15 then 1 else 0 end),
	@ExternalMaterialGroupchange = sum(case when misckey = 10 then 1 else 0 end),
	@Reprintingtypechange = sum(case when misckey = 174 then 1 else 0 end),
	@GeneralItemCategorychange = sum(case when misckey = 11 then 1 else 0 end),
	@MaterialStatisticsGroupchange = sum(case when misckey = 17 then 1 else 0 end),
	@AccountAssignmentGroupchange = sum(case when misckey = 16 then 1 else 0 end),
	@CartonRoundingchange = sum(case when misckey = 18 then 1 else 0 end),
	@countryoforiginchange = sum(case when misckey = 28 then 1 else 0 end),
	@EditionCategorychange = SUM(case when misckey = 228 then 1 else 0 end),   -- 12/10/15 - KB - Case 35150
	@SAPDataSetupchange = isnull(sum(case when misckey = 24 and currentstringvalue <> 'Pre - SAP' and currentstringvalue <> 'Request' then 1 else 0 end),0)
	from titlehistory th
	join bookmiscitems bmi
	on th.fielddesc = bmi.miscname
	where th.bookkey = @i_bookkey
	and columnkey = 248
	and th.lastmaintdate > @i_prevstart_datetime		
	and th.lastmaintdate <= @i_start_datetime
	and th.lastuserid <> 'sapimport'
	and (bmi.misckey in (12,22,19,8,14,20,15,10,11,17,16,18,28,174,228)
	or (bmi.misckey = 24 and currentstringvalue <> 'Pre-SAP' and currentstringvalue <> 'Request')) 


	if @count > 0 begin
		set @sap_request_type = 'Update'
	end

	set @count = 0
--bookmisc textvalue fields
	select @count = isnull(count(*),0),
--	@MediaProductchange = sum(case when misckey = 23 then 1 else 0 end),
	@authorartistchange = sum(case when misckey = 27 then 1 else 0 end),
	@tariffcodechange = sum(case when misckey = 232 then 1 else 0 end)
	from titlehistory th
	join bookmiscitems bmi
	on th.fielddesc = bmi.miscname
	where th.bookkey = @i_bookkey
	and columnkey = 227
	and bmi.misckey in (27,232)
	and th.lastmaintdate > @i_prevstart_datetime		
	and th.lastmaintdate <= @i_start_datetime
	and th.lastuserid <> 'sapimport'

	if @count > 0 begin
		set @sap_request_type = 'Update'
	end

	set @count = 0
--bookmisc numeric value fields
	select @count = isnull(count(*),0),
	@UnitofMeasurechange = sum(case when misckey = 25 then 1 else 0 end),
	@NumberofPubschange = sum(case when misckey = 26 then 1 else 0 end)
	from titlehistory th
	join bookmiscitems bmi
	on th.fielddesc = bmi.miscname
	where th.bookkey = @i_bookkey
	and columnkey = 225
	and bmi.misckey in (25,26)
	and th.lastmaintdate > @i_prevstart_datetime		
	and th.lastmaintdate <= @i_start_datetime
	and th.lastuserid <> 'sapimport'

	if @count > 0 begin
		set @sap_request_type = 'Update'
	end


	set @count = 0
--bookmisc checkbox value fields
	select @count = isnull(count(*),0),
	@requestupcchange = sum(case when misckey = 29 then 1 else 0 end),
	@requestisbnchange = sum(case when misckey = 30 then 1 else 0 end),
	@safetytestchange = sum(case when misckey = 31 then 1 else 0 end),  --CPSIA Cert Req
	@cpsiasafetytestreqchange = SUM(case WHEN misckey = 112 then 1 else 0 end)  -- Case 31967 KB 04/13/2015 CPSIA Safety Test Req
	from titlehistory th
	join bookmiscitems bmi
	on th.fielddesc = bmi.miscname
	where th.bookkey = @i_bookkey
	and columnkey = 247
	and bmi.misckey in (29,30, 31,112)
	and th.lastmaintdate > @i_prevstart_datetime		
	and th.lastmaintdate <= @i_start_datetime
	and th.lastuserid <> 'sapimport'

	if @count > 0 begin
		set @sap_request_type = 'Update'
	end

--determine if existing 1st author's last name has changed
	select @count = isnull(count(*),0),
	@authorchange = isnull(count(*),0)
	from globalcontacthistory th
	join bookauthor ba
	on th.globalcontactkey = ba.authorkey
	join author a
	on ba.authorkey = a.authorkey
	and a.lastname = th.currentstringvalue
	and ba.sortorder = 1
	join gentables g
	on ba.authortypecode = g.datacode
	and g.tableid = 134
	where ba.bookkey = @i_bookkey
	and columnkey = 6
	and g.alternatedesc1 = 'author'
	and th.lastmaintdate > @i_prevstart_datetime		
	and th.lastmaintdate <= @i_start_datetime
	and th.lastuserid <> 'sapimport'

	if @count > 0 begin
		set @sap_request_type = 'Update'
	end
	else begin

		--determine if the authorkey, sortorder, or author type have changed on any author on the book
		select @count = isnull(count(*),0),
		@authorchange = isnull(count(*),0)
		from titlehistory th
		where bookkey = @i_bookkey
		and columnkey in (6, 40)
		and th.lastmaintdate > @i_prevstart_datetime		
		and th.lastmaintdate <= @i_start_datetime
		and th.lastuserid <> 'sapimport'

		if @count > 0 begin
			set @sap_request_type = 'Update'
		end
	end

--determine if US retail price changed
	select @count = isnull(count(*),0),
	@usretailpricechange = count(*)
	from titlehistory th
	where bookkey = @i_bookkey
	and columnkey in ( 8,9)
	and currentstringvalue like '%USDL%'
	and fielddesc like '%Retail%'
	and th.lastmaintdate > @i_prevstart_datetime		
	and th.lastmaintdate <= @i_start_datetime
	and th.lastuserid <> 'sapimport'

	if @count > 0 begin
		set @sap_request_type = 'Update'
	end

--determine if Can retail price changed		--7/20/10 removed per MV
--	select @count = isnull(count(*),0),
--	@canretailpricechange = count(*)
--	from titlehistory th
--	where bookkey = @i_bookkey
--	and columnkey in ( 8,9)
--	and currentstringvalue like '%CNDL%'
--	and fielddesc like '%Retail%'
--	and th.lastmaintdate > @i_prevstart_datetime		
--	and th.lastmaintdate <= @i_start_datetime
--
--	if @count > 0 begin
--		set @sap_request_type = 'Update'
--	end

	select @count = isnull(count(*),0),
	@publicationdatechange = count(*)
	from datehistory
	where bookkey = @i_bookkey
	and datetypecode = 8			--pub date
	and lastmaintdate > @i_prevstart_datetime		
	and lastmaintdate <= @i_start_datetime
	and lastuserid <> 'sapimport'

	if @count > 0 begin
		set @sap_request_type = 'Update'
	end

	select @count = isnull(count(*),0),
	@releasedatechange = count(*)
	from datehistory
	where bookkey = @i_bookkey
	and datetypecode = 32			--release date
	and lastmaintdate > @i_prevstart_datetime		
	and lastmaintdate <= @i_start_datetime
	and lastuserid <> 'sapimport'

	if @count > 0 begin
		set @sap_request_type = 'Update'
	end

	select @count = isnull(count(*),0),
	@onsaledatechange = count(*)
	from datehistory
	where bookkey = @i_bookkey
	and datetypecode = 20003			--on sale date
	and lastmaintdate > @i_prevstart_datetime		
	and lastmaintdate <= @i_start_datetime
	and lastuserid <> 'sapimport'

	if @count > 0 begin
		set @sap_request_type = 'Update'
	end
end

--if bookkey doesn't have any SAP related changes, return to process the next bookkey
if @sap_request_type ='' begin
	return
end

--need to know materialtype value to determine what critical fields to check at the end

if @sap_request_type = 'Request' or @materialtypechange > 0 begin
	select @MaterialType = substring(dbo.get_bookmisc_gent (@i_bookkey, 22, @whichgenfield),1,15)
end
if (@materialtype is null or @materialtype = '') and @materialtypechange > 0 begin
	set @materialtype = '&&&'
end

-- 12/10/15 - KB - Case 35150
if @sap_request_type = 'Request' or @EditionCategorychange  > 0 begin
	select @EditionCategory = substring(dbo.get_bookmisc_gent (@i_bookkey, 228, @whichgenfield),1,15)
end
if (@EditionCategory is null or @EditionCategory = '') and @EditionCategorychange > 0 begin
	set @EditionCategory = '&&&'
end

if @sap_request_type = 'Request' or @isbn13change > 0 begin
	select @ISBN13 = substring(dbo.get_isbn_item (@i_bookkey, 17),1,13)
end
if (@isbn13 is null or @isbn13 = '') and @isbn13change > 0 begin
	set @isbn13 = '&&&'
end

if @sap_request_type = 'Request' or @isbn10change > 0 begin
	select @ISBN10 = substring(dbo.get_isbn_item (@i_bookkey, 10),1,10)
end
if (@isbn10 is null or @isbn10 = '') and @isbn10change > 0 begin
	set @isbn10 = '&&&'
end

if @sap_request_type = 'Request' or @upccodechange > 0 begin
	select @UPCCode = substring(dbo.get_isbn_item (@i_bookkey, 21),1,15)
end
if (@upccode is null or @upccode = '') and @upccodechange > 0 begin
	set @upccode = '&&&'
end

if @sap_request_type = 'Request' or @languagechange > 0 begin
	select @Language = substring(dbo.get_language (@i_bookkey, 'S'),1,30)
end
if (@language is null or @language = '') and @languagechange > 0 begin
	set @language = '&&&'
end

if @sap_request_type = 'Request' or @materialstatuschange > 0 begin
	select @MaterialStatus = substring(dbo.get_bisacstatus (@i_bookkey, 1),1,15)
end
if (@materialstatus is null or @materialstatus = '') and @materialstatuschange > 0 begin
	set @materialstatus = '&&&'
end

if @sap_request_type = 'Request' or @basicdatatextchange > 0 begin
	select @BasicDataText = substring(dbo.get_title (@i_bookkey, 'F'),1,2000)
end
if (@basicdatatext is null or @basicdatatext = '') and @basicdatatextchange > 0 begin
	set @basicdatatext = '&&&'
end

if @sap_request_type = 'Request' or @inspectiontextchange > 0 begin
	select @InspectionText = substring(dbo.get_subtitle (@i_bookkey),1,2000)
end
if (@inspectiontext is null or @inspectiontext = '') and @inspectiontextchange > 0 begin
	set @inspectiontext = '&&&'
end

-- 12/10/15 - KB - Case 35150
--if @sap_request_type = 'Request' or @internalcommentchange > 0 begin
--	select @InternalComment = substring(dbo.get_title (@i_bookkey, 'F')+ ' ' + isnull(dbo.get_format (@i_bookkey, 'D'),''),1,2000)
--end
--if (@internalcomment is null or @internalcomment = '') and @internalcommentchange > 0 begin
--	set @internalcomment = '&&&'
--end

if @sap_request_type = 'Request' or @materialpricinggroupchange > 0 begin
	select @MaterialPricingGroup = substring(dbo.get_discount (@i_bookkey, @whichgenfield),1,15)
end
if (@materialpricinggroup is null or @materialpricinggroup = '') and @materialpricinggroupchange > 0 begin
	set @materialpricinggroup = '&&&'
end

if @sap_request_type = 'Request' or @returnsdispositionchange > 0 begin
	select @ReturnsDisposition = substring(dbo.get_returnind (@i_bookkey, @whichgenfield),1,15)
end
if (@returnsdisposition is null or @returnsdisposition = '') and @returnsdispositionchange > 0 begin
	set @returnsdisposition = '&&&'
end

if @sap_request_type = 'Request' or @audiencetypechange > 0 begin
	select @AudienceType = substring(dbo.get_audience (@i_bookkey, @whichgenfield, 1),1,15)
end
if (@audiencetype is null or @audiencetype = '') and @audiencetypechange > 0 begin
	set @audiencetype = '&&&'
end

--if @sap_request_type = 'Request' or @pubyearchange > 0 begin
--	select @PubYear = dbo.get_pubmonth (@i_bookkey, 1, 'Y')
--end

if @sap_request_type = 'Request' or @seasonchange > 0 begin
	select @Season = substring(dbo.get_bestseason (@i_bookkey, 1, @whichgenfield),1,15)
end
if (@season is null or @season = '') and @seasonchange > 0 begin
	set @season = '&&&'
end

--if @sap_request_type = 'Request' or @merchandisingthemechange > 0 begin
--	select @MerchandisingTheme = substring(dbo.get_MerchCat (@i_bookkey, 1, @whichgenfield),1,15)
--end
--if (@merchandisingtheme is null or @merchandisingtheme = '') and @merchandisingthemechange > 0 begin
--	set @merchandisingtheme = '&&&'
--end

--if @sap_request_type = 'Request' or @cartoncountchange > 0 begin
--	select @CartonCount = dbo.get_cartonqty (@i_bookkey, 1)
--end

if @sap_request_type = 'Request' or @plantchange > 0 begin
	select @Plant = substring(dbo.get_bookmisc_gent (@i_bookkey, 12, @whichgenfield),1,15)
end
if (@plant is null or @plant = '') and @plantchange > 0 begin
	set @plant = '&&&'
end

if @sap_request_type = 'Request' or @contentcategorychange > 0 begin
	select @ContentCategory = substring(dbo.get_bookmisc_gent (@i_bookkey, 19, @whichgenfield),1,15)
end
if (@contentcategory is null or @contentcategory = '') and @contentcategorychange > 0  begin
	set @contentcategory = '&&&'
end

if @sap_request_type = 'Request' or @publicationtypechange > 0 begin
	select @PublicationType = substring(dbo.get_bookmisc_gent (@i_bookkey, 8, @whichgenfield),1,15)
end
if (@PublicationType is null or @PublicationType = '') and @publicationtypechange > 0  begin
	set @PublicationType = '&&&'
end

if @sap_request_type = 'Request' or @mediatypechange > 0 begin
	select @MediaType = substring(dbo.get_bookmisc_gent (@i_bookkey, 14, @whichgenfield),1,15)
end
if (@mediatype is null or @mediatype = '') and @mediatypechange > 0 begin
	set @mediatype = '&&&'
end

if @sap_request_type = 'Request' or @productpresentationchange > 0 begin
	select @ProductPresentation = substring(dbo.get_bookmisc_gent (@i_bookkey, 20, @whichgenfield),1,15)
end
if (@productpresentation is null or @productpresentation = '') and @productpresentationchange > 0 begin
	set @productpresentation = '&&&'
end

if @sap_request_type = 'Request' or @materialgroupchange > 0 begin
	select @MaterialGroup = substring(dbo.get_bookmisc_gent (@i_bookkey, 15, @whichgenfield),1,15)
end
if (@materialgroup is null or @materialgroup = '') and  @materialgroupchange > 0 begin
	set @materialgroup = '&&&'
end

if @sap_request_type = 'Request' or @externalmaterialgroupchange > 0 begin
	select @ExternalMaterialGroup = substring(dbo.get_bookmisc_gent (@i_bookkey, 10, @whichgenfield),1,15)
end
if (@externalmaterialgroup is null or @externalmaterialgroup = '') and @externalmaterialgroupchange > 0 begin
	set @externalmaterialgroup = '&&&'
end

if @sap_request_type = 'Request' or @generalitemcategorychange > 0 begin
	select @GeneralItemCategory = substring(dbo.get_bookmisc_gent (@i_bookkey, 11, @whichgenfield),1,15)
end
if (@generalitemcategory is null or @generalitemcategory = '') and @generalitemcategorychange > 0 begin
	set @generalitemcategory = '&&&'
end

if @sap_request_type = 'Request' or @materialstatisticsgroupchange > 0 begin
	select @MaterialStatisticsGroup = substring(dbo.get_bookmisc_gent (@i_bookkey, 17, @whichgenfield),1,15)
end
if (@materialstatisticsgroup is null or @materialstatisticsgroup = '') and @materialstatisticsgroupchange > 0 begin
	set @materialstatisticsgroup = '&&&'
end
	
if @sap_request_type = 'Request' or @accountassignmentgroupchange > 0 begin
	select @AccountAssignmentGroup = substring(dbo.get_bookmisc_gent (@i_bookkey, 16, @whichgenfield),1,15)
end
if (@accountassignmentgroup is null or @accountassignmentgroup = '') and @accountassignmentgroupchange > 0 begin
	set @accountassignmentgroup = '&&&'
end

--7/26/14 MV added Reprint Type as misc item field
if @sap_request_type = 'Request' or @reprintingtypechange > 0 begin
	select @reprintingtype = substring(dbo.get_bookmisc_gent (@i_bookkey, 174, @whichgenfield),1,15)
end
if (@reprintingtype is null or @materialgroup = '') and  @reprintingtypechange > 0 begin
	set @reprintingtype = '&&&'
end


if @sap_request_type = 'Request' or @cartonroundingchange > 0 begin
	select @CartonRounding = substring(dbo.get_bookmisc_gent (@i_bookkey, 18, @whichgenfield),1,15)
end
if (@cartonrounding is null or @cartonrounding = '') and @cartonroundingchange > 0 begin
	set @cartonrounding = '&&&'
end

if @sap_request_type = 'Request' or @countryoforiginchange > 0 begin
	select @countryoforigin = substring(dbo.get_bookmisc_gent (@i_bookkey, 28, @whichgenfield),1,15)
end
if (@countryoforigin is null or @countryoforigin = '') and @countryoforiginchange > 0 begin
	set @countryoforigin = '&&&'
end

if @sap_request_type = 'Request' or @trimwidthchange > 0 begin
	select @trimwidth = substring(dbo.get_BestTrimDimension (@i_bookkey, 1, 'W'),1,10)
end
if (@trimwidth is null or @trimwidth = '') and @trimwidthchange > 0 begin
	set @trimwidth = '&&&'
end

if @sap_request_type = 'Request' or @trimlengthchange > 0 begin
	select @trimlength = substring(dbo.get_BestTrimDimension (@i_bookkey, 1, 'L'),1,10)
end
if (@trimlength is null or @trimlength = '') and @trimlengthchange > 0 begin
	set @trimlength = '&&&'
end

if @sap_request_type = 'Request' or @pagecountchange > 0 begin
	select @pagecount = dbo.get_BestPageCount (@i_bookkey, 1)
end

if @sap_request_type = 'Request' or @numcolorschange > 0 begin
	SELECT @numcolors = i.numcolors
	FROM	ink i, textspecs t
	WHERE	@i_bookkey = t.bookkey
		AND t.printingkey = 1
		AND i.inkkey = t.inks
end

if @sap_request_type = 'Request' or @textinkchange > 0 begin
	SELECT @textink = isnull(i.inkdescshort,'')
	FROM	ink i, textspecs t
	WHERE	@i_bookkey = t.bookkey
		AND t.printingkey = 1
		AND i.inkkey = t.inks
end
if (@textink is null or @textink = '') and @textinkchange > 0 begin
	set @textink = '&&&'
end


if @sap_request_type = 'Request' or @returnrestrictionchange > 0 begin
	select @returnrestriction = substring(dbo.get_ReturnRestriction (@i_bookkey, @whichgenfield),1,15)
end
if (@returnrestriction is null or @returnrestriction = '') and @returnrestrictionchange > 0 begin
	set @returnrestriction = '&&&'
end
else begin
	if (@returnrestriction is null or @returnrestriction = '') begin
		set @returnrestriction = null 
	end
end
if (@returnrestriction = '.') begin
	set @returnrestriction = ''
end

--if @sap_request_type <> 'Request' and @sapdatasetupchange < 1 begin
--	set @SAPDataSetup = null
--end

if @sap_request_type = 'Request' or @previousisbn10change > 0 begin
	select @PreviousISBN13 = substring(isnull(i.ean13,replace(at.isbn,'-','')),1,13), 
		@PreviousISBN10 = substring(i.isbn10 ,1,10)
	from associatedtitles at
	left outer join isbn i
	on at.associatetitlebookkey = i.bookkey
	where at.bookkey = @i_bookkey
	and associationtypecode=4 
	and associationtypesubcode = 3

end
if @previousisbn10change > 0 begin
	if @previousisbn13 is null or @previousisbn13 = '' begin
		set @previousisbn13 = '&&&'
	end

	if @previousisbn10 is null or @previousisbn10 = '' begin
		set @previousisbn10 = '&&&'
	end
end

if @sap_request_type = 'Request' or @nextisbn10change > 0 begin
	select @NextISBN13 = substring(isnull(i.ean13,replace(at.isbn,'-','')),1,13), 
		@NextISBN10 = substring(i.isbn10 ,1,10)
	from associatedtitles at
	left outer join isbn i
	on at.associatetitlebookkey = i.bookkey
	where at.bookkey = @i_bookkey
	and associationtypecode=4 
	and associationtypesubcode = 4
end
if @nextisbn10change > 0 begin
	if @nextisbn13 is null or @nextisbn13 = '' begin
		set @nextisbn13 = '&&&'
	end

	if @nextisbn10 is null or @nextisbn10 = '' begin
		set @nextisbn10 = '&&&'
	end
end

if @sap_request_type = 'Request' or @descriptionchange > 0 or @internalstatuschange > 0 begin
	select @Description = substring(shorttitle,1,50),
			@internalstatus = substring(datadescshort,1,15)
	from book b
	left outer join gentables g
	on b.titlestatuscode = g.datacode
	and g.tableid = 149
	where bookkey = @i_bookkey
end

if @sap_request_type <> 'Request' and @descriptionchange < 1 begin
	set @description = null
end
if (@description is null or @description = '') and @descriptionchange > 0 begin
	set @description = '&&&'
end

if @sap_request_type <> 'Request' and @internalstatuschange < 1 begin
	set @internalstatus = null
end
if (@internalstatus is null or @internalstatus = '') and @internalstatuschange > 0 begin
	set @internalstatus = '&&&'
end

if @sap_request_type = 'Request' or @producthierarchychange > 0 begin
	select @ProductHierarchy = substring(altdesc1,1,11)
	from bookorgentry bo
	join orgentry o
	on bo.orgentrykey = o.orgentrykey
	and bo.orglevelkey = 5
	where bo.bookkey = @i_bookkey

end
if (@producthierarchy is null or @producthierarchy = '') and @producthierarchychange > 0 begin
	set @producthierarchy = '&&&'
end

--7/26/14 MV remove ReprintType from Slot field
--if @sap_request_type = 'Request' or @reprintingtypechange > 0 begin
--	select @ReprintingType = substring(datadescshort,1,30)
--	from printing p
--	join gentables gt
--	on p.slotcode = gt.datacode
--	and gt.tableid = 102
--	where p.bookkey = @i_bookkey
--	and p.printingkey = 1
--end
--if (@reprintingtype is null or @reprintingtype = '') and @reprintingtypechange > 0 begin
--	set @reprintingtype = '&&&'
--end

if @sap_request_type = 'Request' or @authorchange > 0 begin

	select @authortype = isnull(min(authortypecode),0)
	from bookauthor ba
	join gentables g
	on ba.authortypecode = g.datacode
	and g.tableid = 134
	and ba.sortorder = 1
	where ba.bookkey = @i_bookkey
	and g.alternatedesc1 = 'author'

	select @Author = substring(dbo.get_author (@i_bookkey, 1, @authortype,'L'),1,50)
end
if (@author is null or @author = '') and @authorchange > 0 begin
	set @author = '&&&'
end

if @sap_request_type = 'Request' or @USRetailPricechange > 0 begin
	select @USRetailPrice = cast(dbo.get_bestusprice (@i_bookkey, 8) as float)
end

--7/20/10 removed per MV
--if @sap_request_type = 'Request' or @CanRetailpricechange > 0 begin
--	select @CanRetailprice = cast(dbo.get_bestcanadianprice (@i_bookkey, 8) as float)
--end

if @sap_request_type = 'Request' or @publicationdatechange > 0 begin
	select @Publicationdate = dbo.get_bestpubdate (@i_bookkey, 1)
end

if @sap_request_type = 'Request' or @releasedatechange > 0 begin
	select @releasedate = dbo.get_bestreleasedate (@i_bookkey, 1)
end

if @sap_request_type = 'Request' or @onsaledatechange > 0 begin
	select @onsaledate = dbo.get_bestdate (@i_bookkey, 1, 20003)
end

select @Subtitle2 = substring(gts.datadesc,1,80),
 @Subtitle3 = substring(gts.datadesc,81,80),
 @CopyrightYear = copyrightyear,
 @DchainSpecStatus = substring(gtc.datadescshort,1,15),
 @EditionCounter = bd.editionnumber,
 @BeginningGradeLevel = case when gradelowupind = 1 then '00' else substring(gradelow,1,15) end,
 @EndingGradeLevel = case when gradehighupind = 1 then 'UP' else substring(gradehigh,1,15) end,
 @BeginningAge = case when agelowupind = 1 then '00' else convert(varchar(15),agelow) end,
 @EndingAge = case when agehighupind = 1 then 'UP' else convert(varchar(15),agehigh) end,
 @OnixMedia = substring(gtm.alternatedesc1,1,15),
 @OnixBinding = substring(sgtf.alternatedesc1,1,15)
from bookdetail bd
left outer join gentables gts
on bd.seriescode = gts.datacode
and gts.tableid = 327
left outer join gentables gtc
on bd.canadianrestrictioncode = gtc.datacode
and gtc.tableid = 428
left outer join gentables gtm
on bd.mediatypecode = gtm.datacode
and gtm.tableid = 312
left outer join subgentables sgtf
on bd.mediatypesubcode = sgtf.datasubcode
and bd.mediatypecode = sgtf.datacode
and sgtf.tableid = 312
where bd.bookkey = @i_bookkey

if @sap_request_type <> 'Request' and @subtitle2change < 1 begin
	set @Subtitle2 = null
end
if (@Subtitle2 is null or @Subtitle2 = '') and @subtitle2change > 0 begin
	set @Subtitle2 = '&&&'
end

if @sap_request_type <> 'Request' and @subtitle3change < 1 begin
	set @Subtitle3 = null
end
if (@Subtitle3 is null or @Subtitle3 = '') and @subtitle3change > 0 begin
	set @Subtitle3 = '&&&'
end

if @sap_request_type <> 'Request' and @CopyrightYearchange < 1 begin
	set @CopyrightYear = null
end

if @sap_request_type <> 'Request' and @DchainSpecStatuschange < 1 begin
	set @DchainSpecStatus = null
end
if (@DchainSpecStatus is null or @DchainSpecStatus = '') and @DchainSpecStatuschange > 0 begin
	set @DchainSpecStatus = '&&&'
end

if @sap_request_type <> 'Request' and @editioncounterchange < 1 begin
	select @EditionCounter = null
end

if @sap_request_type <> 'Request' and @BeginningGradeLevelchange < 1 begin
	set @BeginningGradeLevel = null
end

if (@BeginningGradeLevel is null or @BeginningGradeLevel = '') and @BeginningGradeLevelchange > 0 begin
	set @BeginningGradeLevel = '&&&'
end

if @sap_request_type <> 'Request' and @EndingGradeLevelchange < 1 begin
	set @EndingGradeLevel = null
end
if (@EndingGradeLevel is null or @EndingGradeLevel = '') and @EndingGradeLevelchange > 0 begin
	set @EndingGradeLevel = '&&&'
end

if @sap_request_type <> 'Request' and @BeginningAgechange < 1 begin
	set @BeginningAge = null
end
if (@BeginningAge is null or @BeginningAge = '') and @BeginningAgechange > 0 begin
	set @BeginningAge = '&&&'
end

if @sap_request_type <> 'Request' and @EndingAgechange < 1 begin
	set @EndingAge = null
end
if (@EndingAge is null or @EndingAge = '') and @EndingAgechange > 0 begin
	set @EndingAge = '&&&'
end

if @sap_request_type <> 'Request' and @OnixMediachange < 1 begin
	set @OnixMedia = null
end
if (@OnixMedia is null or @OnixMedia = '') and @OnixMediachange > 0 begin
	set @OnixMedia = '&&&'
end

if @sap_request_type <> 'Request' and @OnixBindingchange < 1 begin
	set @OnixBinding = null
end
if (@OnixBinding is null or @OnixBinding = '') and @OnixBindingchange > 0 begin
	set @OnixBinding = '&&&'
end

--media product = nextance ID
--if @sap_request_type = 'Request' or @mediaproductchange > 0 begin
--	select @MediaProduct = substring(textvalue,1,15)
--	from bookmisc
--	where misckey = 23
--	and bookkey = @i_bookkey
--end
--if (@MediaProduct is null or @MediaProduct = '') and @mediaproductchange > 0 begin
--	set @MediaProduct = '&&&'
--end

if @sap_request_type = 'Request' or @authorartistchange > 0 begin
	select @authorartist = substring(textvalue,1,30)
	from bookmisc
	where misckey = 27
	and bookkey = @i_bookkey
end
if (@authorartist is null or @authorartist = '') and @authorartistchange > 0 begin
	set @authorartist = '&&&'
end

if @sap_request_type = 'Request' or @tariffcodechange > 0 begin
	select @tariffcode = substring(textvalue,1,30)
	from bookmisc
	where misckey = 232
	and bookkey = @i_bookkey
end
if (@tariffcode is null or @tariffcode = '') and @tariffcodechange > 0 begin
	set @tariffcode = '&&&'
end

if @sap_request_type = 'Request' or @unitofmeasurechange > 0 begin
	select @UnitofMeasure = longvalue
	from bookmisc
	where misckey = 25
	and bookkey = @i_bookkey
end

if @sap_request_type = 'Request' or @numberofpubschange > 0 begin
	select @NumberofPubs = longvalue
	from bookmisc
	where misckey = 26
	and bookkey = @i_bookkey
end

if @sap_request_type = 'Request' or @requestupcchange > 0 begin
	select @requestupc = case when longvalue = 1 then 'Y'
								when longvalue = 0 then 'N' end
	from bookmisc
	where misckey = 29
	and bookkey = @i_bookkey
end
if (@requestupc is null or @requestupc = '') and @requestupcchange > 0 begin
	set @requestupc = '&&&'
end

if @sap_request_type = 'Request' or @requestisbnchange > 0 begin
	select @requestISBN = case when longvalue = 1 then 'Y'
								when longvalue = 0 then 'N' end
	from bookmisc
	where misckey = 30
	and bookkey = @i_bookkey
end
if (@requestISBN is null or @requestISBN = '') and @requestisbnchange > 0 begin
	set @requestISBN = '&&&'
end

if @sap_request_type = 'Request' or @safetytestchange > 0 begin
	select @safetytest = case when longvalue = 1 then 'Y'
								when longvalue = 0 then 'N' end
	from bookmisc
	where misckey = 31
	and bookkey = @i_bookkey
end
if (@safetytest is null or @safetytest = '') and @safetytestchange > 0 begin
	set @safetytest = '&&&'
end

if @sap_request_type = 'Request' or @cpsiasafetytestreqchange > 0 begin
	select @cpsiasafetytestreq = case when longvalue = 1 then 'Y'
								when longvalue = 0 then 'N' end
	from bookmisc
	where misckey = 112
	and bookkey = @i_bookkey
end
if (@cpsiasafetytestreq is null or @cpsiasafetytestreq = '') and @cpsiasafetytestreqchange > 0 begin
	set @cpsiasafetytestreq = '&&&'
end


if @sap_request_type = 'Request' or @ProductSafetyChange > 0 begin
    select @count = 0
	select @count = count(*) 
	from booksubjectcategory
	where categorytableid = 558 and categorycode in (5,6)
	and bookkey = @i_bookkey
	
	IF @count > 0 
		set @ProductSafety = 'Y'
end
if (@count = 0) and @ProductSafetychange > 0 begin
	set @ProductSafety = '&&&'
end

--critical values checks
if @sap_request_type = 'Request'
begin
	if isnull(@plant,'') = ''
	begin
		SET @o_error_code = 1
		SET @o_error_desc = 'Plant'
	end
	if isnull(@materialtype,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Material Type'
	end
	
	-- 12/10/15 - KB - Case 35150
	if isnull(@EditionCategory  ,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Edition Category'
	end
	
	if isnull(@description,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Description (Short title)'
	end
	if isnull(@authorartist,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Author/Artist'
	end
	if isnull(@tariffcode,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Tariff Code'
	end
	if isnull(@language,'') = '' and @materialtype <> 'ZPRO'
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Language'
	end
--	if isnull(@mediaproduct,'') = '' and @materialtype <> 'ZPRO' and @materialtype <> 'ZNBW' and @materialtype <> 'HALB'
--	begin
--		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
--		SET @o_error_code = 1
--		SET @o_error_desc = @o_error_desc + 'Media Product'
--	end
	if isnull(@contentcategory,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Content Category'
	end
	if isnull(@Publicationtype,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Publication Type'
	end
	if isnull(@mediatype,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Media Type'
	end
	if isnull(@Publicationdate,'') = '' and @materialtype <> 'ZPRO'
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Pub Date'
	end
	if isnull(@copyrightyear,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Copyright Year'
	end
	if isnull(@materialstatus,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Material Status'
	end
	if isnull(@reprintingtype,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Reprinting Type'
	end
	if isnull(@numberofpubs,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Number of Pubs'
	end
	if isnull(@unitofmeasure,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Unit of Measure'
	end
	if isnull(@materialgroup,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Material Group'
	end
	if isnull(@externalmaterialgroup,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'External Material Group'
	end
	if isnull(@producthierarchy,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Product Hierarchy'
	end
	if isnull(@generalitemcategory,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'General Item Category'
	end
	if isnull(@dchainspecstatus,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Dchain Spec Status'
	end
	if isnull(@Materialstatisticsgroup,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Material Statistics Group'
	end
	if isnull(@materialpricinggroup,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Material Pricing Group'
	end
	if isnull(@accountassignmentgroup,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Account Assignment Group'
	end
	if isnull(@cartonrounding,'') = ''
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'Carton Rounding'
	end
	if isnull(@USRetailPrice,0) = 0 and @materialtype <> 'ZPRO' and @materialtype <> 'HALB'
	begin
		if @o_error_code = 1 set @o_error_desc = @o_error_desc + ', '
		SET @o_error_code = 1
		SET @o_error_desc = @o_error_desc + 'US Price'
	end

	if @o_error_code = 1
	begin
		set @o_error_desc = 'Critical SAP values not populated completely – ' + @o_error_desc +'.  Row not written for this bookkey'
		RETURN
	end
end	

INSERT INTO hmco_export_to_sap
		(Plant
		,MaterialType
		,Material
		,ISBN13
		,ISBN10
		,UPCCode
		,Description
		,Author
		,Subtitle2
		,Subtitle3
		,Language
--		,MediaProduct
		,ContentCategory
		,PublicationType
		,MediaType
		,Publicationdate
		,EditionCounter
		,CopyrightYear
		,MaterialStatus
		,ReprintingType
		,uom_ea
		,uom_pu
		,BasicDataText
	    ,InspectionText    
	--  ,InternalComment   -- 12/10/15 - KB - Case 35150
		,ProductPresentation
		,MaterialGroup
		,ExternalMaterialGroup
		,Division
		,ProductHierarchy
		,GeneralItemCategory
		,DchainSpecStatus
		,MaterialStatisticsGroup
		,MaterialPricingGroup
		,AccountAssignmentGroup
		,CartonRounding
		,ReturnsDisposition
		,BeginningGradeLevel
		,EndingGradeLevel
		,PreviousISBN10
		,PreviousISBN13
		,NextISBN10
		,NextISBN13
		,OnixMedia
		,OnixBinding
		,AudienceType
--		,PubYear
		,Season
--      ,MerchandisingTheme  -- 12/10/15 - KB - Case 35150
		,BeginningAge
		,EndingAge
		,USRetailPrice
--		,CanRetailprice		--7/20/10 removed per MV
--		,uom_cs
		,SAPDataSetup
		,bookkey
		,pss_extract_date
		,sap_status
		,sap_request_type
		,sap_status_change_date
		,sap_status_change_user
		,sap_email_sent
		,pss_email_sent
		,comments
		,trimwidth
		,trimlength
		,pagecount
		,numberofcolors
		,textink
		,returnrestriction
		,releasedate
		,internalstatus
		,countryoforigin
		,authorartist
		,tariffcode
		,requestupc
		,requestisbn
		,safetytestind
		,onsaledate	
		,ProductSafety
		,CPSIASAFETYTESTREQ
		,editioncategory)  -- 12/10/15 - KB - Case 35150
 VALUES
		(@Plant
		,@MaterialType
		,@Material
		,@ISBN13
		,@ISBN10
		,@UPCCode
		,@Description
		,@Author
		,@Subtitle2
		,@Subtitle3
		,@Language
--		,@MediaProduct
		,@ContentCategory
		,@PublicationType
		,@MediaType
		,@Publicationdate
		,@EditionCounter
		,@CopyrightYear
		,@MaterialStatus
		,@ReprintingType
		,@UnitofMeasure
		,@NumberofPubs
		,@BasicDataText
		,@InspectionText   
		--,@InternalComment  -- 12/10/15 - KB - Case 35150
		,@ProductPresentation
		,@MaterialGroup
		,@ExternalMaterialGroup
		,@Division
		,@ProductHierarchy
		,@GeneralItemCategory
		,@DchainSpecStatus
		,@MaterialStatisticsGroup
		,@MaterialPricingGroup
		,@AccountAssignmentGroup
		,@CartonRounding
		,@ReturnsDisposition
		,@BeginningGradeLevel
		,@EndingGradeLevel
		,@PreviousISBN10
		,@PreviousISBN13
		,@NextISBN10
		,@NextISBN13
		,@OnixMedia
		,@OnixBinding
		,@AudienceType
--		,@PubYear
		,@Season
--      ,@MerchandisingTheme  -- 12/10/15 - KB - Case 35150
		,@BeginningAge
		,@EndingAge
		,@USRetailPrice
--		,@CanRetailprice	--7/20/10 removed per MV
--		,@CartonCount
		,@SAPDataSetup 
		,@i_bookkey
		,@pss_extract_date
		,@sap_status
		,@sap_request_type
		,@pss_extract_date
		,@sap_status_change_user
		,@sap_email_sent
		,@pss_email_sent
		,@comments
		,@trimwidth
		,@trimlength
		,@pagecount
		,@numcolors
		,@textink
		,@returnrestriction
		,@releasedate
		,@internalstatus
		,@countryoforigin
		,@authorartist
		,@tariffcode
		,@requestupc
		,@requestisbn
		,@safetytest
		,@onsaledate
		,@ProductSafety
		,@cpsiasafetytestreq
		,@EditionCategory)  -- 12/10/15 - KB - Case 35150


SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
	SET @o_error_code = -1
	SET @o_error_desc = 'Unable to insert into the hmco_export_to_sap table.   Error #' + cast(@v_error as varchar(20))
	RETURN
END 

if @sapdatasetup = 'Request' or @sapdatasetup = 'Fix Request' or @sapdatasetup = 'Reprocess' begin -- added reprocess pm 10/3/14
	update bookmisc
	set longvalue = 4,		--set to 'Release'
	lastuserid = 'qsidba_sap',
	lastmaintdate = getdate()
	where bookkey = @i_bookkey
	and misckey = 24

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 or @v_rowcount = 0 BEGIN 
		delete from hmco_export_to_sap
		where bookkey = @i_bookkey
		and pss_extract_date = @i_start_datetime

		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to update the last feed to SAP date on bookdates table - export to sap row deleted for this bookkey.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 

end

update bookdates
set activedate = @i_start_datetime,
bestdate = @i_start_datetime,
lastuserid = 'qsidba_sap',
lastmaintdate = getdate()
where bookkey = @i_bookkey
and datetypecode = 20004

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 BEGIN
	delete from hmco_export_to_sap
	where bookkey = @i_bookkey
	and pss_extract_date = @i_start_datetime

	SET @o_error_code = -1
	SET @o_error_desc = 'Unable to update the last feed to SAP date on bookdates table - export to sap row deleted for this bookkey.   Error #' + cast(@v_error as varchar(20))
	RETURN
END 

if @v_rowcount = 0 begin
	insert into bookdates
	(bookkey, printingkey, datetypecode, activedate, actualind, recentchangeind, lastuserid,
	lastmaintdate, estdate, sortorder, bestdate, scmatkey)
	values 
	(@i_bookkey,1,20004,@i_start_datetime,null,null,'qsidba_sap',getdate(),null,null,@i_start_datetime,null)

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 or @v_rowcount = 0 BEGIN
		delete from hmco_export_to_sap
		where bookkey = @i_bookkey
		and pss_extract_date = @i_start_datetime

		SET @o_error_code = -1
		SET @o_error_desc = 'Unable to insert the last feed to SAP date on bookdates table - export to sap row deleted for this bookkey.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 
end


END

