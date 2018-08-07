IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hmco_import_from_SAP_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[hmco_import_from_SAP_detail]


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =================================================================================================================
-- Author:		Jennifer Hurd
-- Create date: 2/24/09
-- Description:	imports data from SAP
-- you can run this by calling hmco_import_from_sap_driver to let it determine bookkeys to run
-- or run it for individual bookkeys, just sending in the arguments setting the prevstartdatetime to the starting
-- period for the data and startdatetime as the end of the run period.  this startdatetime will be written as 
-- the extract date on the file.

-- 3/10/15 - KB - Case 31794 @i_update_mode - Michelle's response to possible values for this parameter:
--·A = overwrite any existing values B = if value exists, do not overwrite it
-- We typically run the stored procedure using A
--
-- 12/10/15 - KB - Case 35244 Add following fields to Xart:
--	Season - Description field from User Tables 
--  Pub Month - month name
--  Pub Year - four digit year
--  Jacket Vendor - Name field from Vendor Maintenance
--  
--  For @ProdAvailaibilty pass datadesc (which is unique) instead of alternatedesc1 (not unique) to staging table
--
-- 03/08/2016 - KB - Case 36850
-- =================================================================================================================
CREATE PROCEDURE [dbo].[hmco_import_from_SAP_detail] 
	@i_bookkey int = 0, 
	@i_rowid	int,
	@i_update_mode	char(1),
	@i_userid   varchar(30),
	@o_error_code   integer output,
	@o_error_desc   varchar(2000) output

AS
BEGIN
print 'hmco_import_from_SAP_detail'
declare     
@DEBUG int,
@datacode int,
@datasubcode int,
@v_error  INT,
@v_rowcount INT,
@count	int,
@update		int,
@insert		int,
@misckey	int,
@fielddesc	varchar(30),
@new_code	int,
@orglevelkey	int,
@material  varchar(20),
@author  varchar(50),
@titleshort  varchar(50),
@nextanceid  varchar(20),
@materialstatus  varchar(255),--mk20130214>Case 22403 Xart enhancement (MaterialSatus)
@copyrightyear  varchar(4),
@materialtype  varchar(20),
@materialgroup  varchar(20),
@productpresentation  varchar(20),
@mediatype  varchar(20),
@publicationtype  varchar(20),
@externalmaterialgroup  varchar(20),
@contentcategory  varchar(20),
@accountassignmentgroup  varchar(20),
@pricegroup  varchar(20),
@returndispositioncode  varchar(20),
@salesrestriction  varchar(20),
@reprintingtype  varchar(20),
@itemcategory  varchar(20),
@phlevel1  varchar(2),
@phlevel2  varchar(4),
@phlevel3  varchar(6),
@phlevel4  varchar(9),
@phlevel5  varchar(11),
@cartonrounding  varchar(20),
@plant  varchar(20),
@materialstatisticsgroup  varchar(20),
@ea  varchar(20),
@pu  varchar(20),
@sapdatasetup	varchar(40),
@workkey		int,
@workkey2		int

declare @cartonquantity	int,
@unitweight			float,
@countryoforigin		varchar(20),
@subtitle2			varchar(80)	,
@format				varchar(20)	,
@bisacmedia				varchar(20),
@bisacmediacode			int,
@territories			varchar(20)	,
@internalstatus		varchar(20)	,
@returnrestriction	varchar(20)	,
@trimwidth			varchar(10)	,
@trimlength			varchar(10)	,
@pagecount			int			,
@releasedate			datetime	,
@warehousedate		datetime	,
@pubdate				datetime	,
@textink		varchar(30)			,
@usretailprice		float		,
@agencyprice		float		,
@optionvalue		int,
@printingkey		int,
@datetypecode		int,
@textinkkey			int,
@textinkdesc		varchar(30),
@newkey				int,
@filetypecode		int,
@pathname			varchar(255),
@filedescription	varchar(max),--mk20140529> Case: 27609 New fields for XART import
@filesendtoeloquenceind	int,
@authorkey			int,
@authortypecode		int,
@newmiscvalue		varchar(255),
@newmisckey			int,
@miscname			varchar(50),
@misctype			int,
@categorytableid	int,
@category			varchar(100),
@categorysub		varchar(100),
@categorysub2		varchar(100),
@categorycode		int,
@categorysubcode		int,
@categorysub2code	int,
@subjectkey			int

declare @cartonquantity2	int,
@unitweight2			float,
@subtitle22			varchar(80)	,
@format2			varchar(20)	,
@bisacmedia2				varchar(20)	,
@territories2			varchar(20)	,
@internalstatus2		varchar(20)	,
@returnrestriction2	varchar(20)	,
@trimwidth2			varchar(10)	,
@trimlength2			varchar(10)	,
@pagecount2			int			,
@releasedate2			datetime	,
@warehousedate2		datetime	,
@pubdate2				datetime	,
@textink2		varchar(30)			,
@usretailprice2		float,		
@agencyprice2		float	,
@sortorder			int	

declare @material2  varchar(20),
@author2  varchar(50),
@titleshort2  varchar(50),
@nextanceid2  varchar(20),
@materialstatus2  varchar(255),--mk20130214>Case 22403 Xart enhancement (MaterialSatus)
@ProdAvailability2 varchar(100),--mk2012.10.11> Case: 21256 Trax "material status" and Xart "product availability" fields
@copyrightyear2  varchar(4),
@pricegroup2  varchar(20),
@returndispositioncode2  varchar(20),
@salesrestriction2  varchar(20),
@reprintingtype2  int,
@ea2  varchar(20),
@pu2  varchar(20),
@safetytest	int,
@safetytest2	int,
@associatedbookkey	int,
@associationtypecode	int,
@associationtypesubcode	int,
@datetypecodepassed	int,
@datevalue	datetime,
@actualind	int,
@barcodetype1code	int,
@barcodeposition1code	int,
@pricetypecode		int,
@currencytypecode	int,
@priceeffdate	datetime,
@priceactiveind	int,
@pricevalue	float,
@QuantityEst	int, 
@QuantityAct int, 
@ProjectedSalesEst int, 
@ProjectedSalesAct int, 
@PrintVendor varchar(255),--mk2012.07.26> Case: 20220 Changes to Xart feed
@PrintVendorKey int, --mk2012.07.26> Case: 20220 Changes to Xart feed
@agelow int, --mk2012.07.26> Case: 20220 Changes to Xart feed
@agehigh int, --mk2012.07.26> Case: 20220 Changes to Xart feed
@agelowupind int, --mk2012.07.26> Case: 20220 Changes to Xart feed
@agehighupind int, --mk2012.07.26> Case: 20220 Changes to Xart feed
@agelowORIG int, --mk2012.07.26> Case: 20220 Changes to Xart feed
@agehighORIG int, --mk2012.07.26> Case: 20220 Changes to Xart feed
@agelowupindORIG int, --mk2012.07.26> Case: 20220 Changes to Xart feed
@agehighupindORIG int, --mk2012.07.26> Case: 20220 Changes to Xart feed
@estwarehousedate datetime, --mk2012.08.21> Case: 20653 Add estimated warehouse date to XART
@ProdAvailability varchar(100)--mk2012.10.11> Case: 21256 Trax "material status" and Xart "product availability" fields

DECLARE @GradeLow varchar(max),@GradeLow_ORIG varchar(max)--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @GradeHigh varchar(max),@GradeHigh_ORIG varchar(max)--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @GradeLow_AndUnder int,@GradeLow_AndUnder_ORIG int--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @GradeHigh_AndAbove int,@GradeHigh_AndAbove_ORIG int--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Spine_Size varchar(max),@Spine_Size_ORIG varchar(max)--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Inserts_Estimated varchar(max),@Inserts_Estimated_ORIG varchar(max)--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Inserts_Actual varchar(max),@Inserts_Actual_ORIG varchar(max)--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Illustrations_Estimated varchar(max),@Illustrations_Estimated_ORIG varchar(max)--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Illustrations_Actual varchar(max),@Illustrations_Actual_ORIG varchar(max)--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Author_Primary_indicator int,@Author_Primary_indicator_ORIG int--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Author_Sort_order int,@Author_Sort_order_ORIG int--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement

DECLARE @Participant_globalcontactkey int,@Participant_globalcontactkey_ORIG int--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Participant_Role_type int,@Participant_Role_type_ORIG int--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement



DECLARE @Announced_First_Printing_Estimated int,@Announced_First_Printing_Estimated_ORIG int--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Announced_First_Printing_Actual int,@Announced_First_Printing_Actual_ORIG int--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Title_Actual varchar(max),@Title_Actual_ORIG varchar(max)--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
--DECLARE @Audience int,@Audience_ORIG int--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
DECLARE @Language varchar(max),@Language_ORIG varchar(max)--mk20140522> Case: 26341 ESTIMATE: Xart Enhancement

DECLARE @Fullauthordisplayname varchar(max),@Fullauthordisplayname_ORIG varchar(max)--mk20140529> Case: 27609 New fields for XART import
DECLARE @Editioncode int,@Editioncode_ORIG int--mk20140529> Case: 27609 New fields for XART import
DECLARE @Series  varchar(max),@Series_ORIG varchar(max)--mk20140529> Case: 27609 New fields for XART import
DECLARE @Internal_category  varchar(max),@Internal_category_ORIG varchar(max)--mk20140529> Case: 27609 New fields for XART import
DECLARE @Audience_codes varchar(max),@Audience_codes_ORIG varchar(max)--mk20140529> Case: 27609 New fields for XART import
DECLARE @never_send_2_elo int --mk20140529> Case: 27609 New fields for XART import
DECLARE @i_previousedistatuscode int --mk20140529> Case: 27609 New fields for XART import


-- 12/10/15 - KB - Case 35244
DECLARE @Season varchar(80), @Season_ORIG varchar(80)
DECLARE @PubMonth varchar(20)
DECLARE @PubMonthCode int
DECLARE @PubYear varchar(10)
DECLARE @PubMonth_Year datetime  -- value of pubmonthcode and pubyear combined into datetime field; saved to pubmonth on printing table
DECLARE @PubMonth_Year_ORIG datetime
DECLARE @JacketVendor varchar(255)
DECLARE @JacketVendorKey int

SET @o_error_code = 0
SET @o_error_desc = ''  
set @printingkey = 1
set @DEBUG=0

IF @DEBUG<>0 PRINT 'START hmco_import_from_SAP_detail'

select @material = isnull(material,''),
@author = isnull(author,''),
@titleshort = isnull(title_short,''),
@nextanceid = isnull(nextance_id,''),
@materialstatus = isnull(material_status,''),
@copyrightyear = isnull(copyright_year,''),
@materialtype = isnull(material_type,''),
@materialgroup = isnull(material_group,''),
@productpresentation = isnull(product_presentation,''),
@mediatype = isnull(media_type,''),
@publicationtype = isnull(publication_type,''),
@externalmaterialgroup = isnull(external_material_group,''),
@contentcategory = isnull(content_category,''),
@accountassignmentgroup = isnull(account_assignment_group,''),
@pricegroup = isnull(price_group,''),
@returndispositioncode = isnull(return_disposition_code,''),
@salesrestriction = isnull(sales_restriction,''),
@reprintingtype = isnull(reprinting_type,''),
@itemcategory = isnull(item_category,''),
@phlevel1 = isnull(ph_level_1,''),
@phlevel2 = isnull(ph_level_2,''),
@phlevel3 = isnull(ph_level_3,''),
@phlevel4 = isnull(ph_level_4,''),
@phlevel5 = isnull(ph_level_5,''),
@cartonrounding = isnull(carton_rounding,''),
@plant = isnull(plant,''),
@materialstatisticsgroup = isnull(material_statistics_group,''),
@ea = isnull(ea,''),
@pu = isnull(pu,''),
@cartonquantity	= cartonquantity,
@unitweight			= unitweight,
@countryoforigin	= isnull(countryoforigin,''),
@subtitle2			= isnull(subtitle2,'')	,
@bisacmedia				= isnull(bisacmedia,'')	,
@format				= isnull(format,'')	,
@territories		= isnull(territories,'')	,
@internalstatus		= isnull(internalstatus,'')	,
@returnrestriction	= isnull(returnrestriction,'')	,
@trimwidth			= isnull(trimwidth,'')	,
@trimlength			= isnull(trimlength,'')	,
@pagecount			= pagecount			,
@releasedate		= releasedate	,
@warehousedate		= warehousedate	,
@pubdate			= pubdate	,
@textink			= isnull(textink, ''),
@usretailprice		= usretailprice,
@agencyprice		= agencyprice,
@filetypecode		= isnull(filetypecode,0),
@pathname			= isnull(pathname,''),
@filedescription	= isnull(filedescription,''),--mk20140529> Case: 27609 New fields for XART import
@filesendtoeloquenceind	= filesendtoeloquenceind,
@authorkey			= isnull(authorkey,0),
@authortypecode		= isnull(authortypecode,0),
@workkey			= isnull(workkey,0),
@safetytest			= case when safetytestind = 'Y' then 1 when safetytestind = 'N' then 0 else null end,
@sapdatasetup		= isnull(sapdatasetup,''),
@newmiscvalue		= newmiscvalue,
@newmisckey			= newmisckey,
@categorytableid	= categorytableid,
@category			= category,
@categorysub		= categorysub,
@categorysub2		= categorysub2,
@associatedbookkey	= associatedbookkey,
@associationtypecode	= associationtypecode,
@associationtypesubcode	= isnull(associationtypesubcode,0),
@datetypecodepassed	= isnull(datetypecodepassed,0),
@datevalue			= datevalue,
@actualind			= actualind,
@barcodetype1code	= barcodetype1code,
@barcodeposition1code	= barcodeposition1code,
@pricetypecode		= isnull(pricetypecode, 0),
@currencytypecode	= isnull(currencytypecode, 0),
@priceeffdate		= priceeffdate,
@priceactiveind		= priceactiveind,
@pricevalue			= pricevalue,
@QuantityEst		= isnull(QuantityEst, -2), --mk2012.07.26> Case: 20220 Changes to Xart feed
@QuantityAct		= isnull(QuantityAct, -2), --mk2012.07.26> Case: 20220 Changes to Xart feed
@ProjectedSalesEst	= isnull(ProjectedSalesEst, -2), --mk2012.07.26> Case: 20220 Changes to Xart feed
@ProjectedSalesAct	= isnull(ProjectedSalesAct, -2),--mk2012.07.26> Case: 20220 Changes to Xart feed
@PrintVendor		= isnull(PrintVendor, ''), --mk2012.07.26> Case: 20220 Changes to Xart feed
@agelow				= isnull(AgeLow, -2), --mk2012.07.26> Case: 20220 Changes to Xart feed
@agehigh			= isnull(AgeHigh, -2), --mk2012.07.26> Case: 20220 Changes to Xart feed
@agelowupind		= isnull(AgeLow_AndUnder, -2), --mk2012.07.26> Case: 20220 Changes to Xart feed
@agehighupind		= isnull(AgeHigh_AndAbove, -2), --mk2012.07.26> Case: 20220 Changes to Xart feed
@estwarehousedate	= EstWarehouseDate, --mk2012.08.21> Case: 20653 Add estimated warehouse date to XART
@ProdAvailability	= ProdAvailability--mk2012.10.11> Case: 21256 Trax "material status" and Xart "product availability" fields

,@GradeLow = isnull(GradeLow,'') --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@GradeHigh = isnull(GradeHigh,'') --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@GradeLow_AndUnder = isnull(cast(GradeLow_AndUnder as int),-1) --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@GradeHigh_AndAbove = isnull(cast(GradeHigh_AndAbove as int),-1) --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Spine_Size = isnull(Spine_Size,'') --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Inserts_Estimated = isnull(Inserts_Estimated,'') --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Inserts_Actual = isnull(Inserts_Actual,'') --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Illustrations_Estimated = isnull(Illustrations_Estimated,'') --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Illustrations_Actual = isnull(Illustrations_Actual,'') --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Author_Primary_indicator = isnull(cast(Author_Primary_indicator as int),-1) --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Author_Sort_order = isnull(Author_Sort_order,-1) --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Participant_globalcontactkey = isnull(Participant_globalcontactkey,-1) --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Participant_Role_type = isnull(Participant_Role_type,-1) --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Announced_First_Printing_Estimated = isnull(Announced_First_Printing_Estimated,-1) --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Announced_First_Printing_Actual = isnull(Announced_First_Printing_Actual,-1) --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Title_Actual = isnull(Title_Actual,'') --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
--,@Audience = isnull(Audience,0) --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement
,@Language = isnull(Language,'') --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement

,@Fullauthordisplayname = isnull(Fullauthordisplayname,'')--mk20140529> Case: 27609 New fields for XART import
,@Editioncode = isnull(Editioncode,-1)--mk20140529> Case: 27609 New fields for XART import
,@Series = isnull(Series,'')--mk20140529> Case: 27609 New fields for XART import
,@Internal_category = isnull(Internal_category,'')--mk20140529> Case: 27609 New fields for XART import
,@Audience_codes = isnull(Audience_codes,'')--mk20140529> Case: 27609 New fields for XART import
,@never_send_2_elo=isnull(never_send_2_elo,-1)--mk20140529> Case: 27609 New fields for XART import
,@Season = ISNULL(Season,'')   -- 12/10/15 - KB - Case 35244
,@PubMonth = ISNULL(PubMonth,'') -- 12/10/15 - KB - Case 35244
,@PubYear  = ISNULL(PubYear ,'') -- 12/10/15 - KB - Case 35244
,@JacketVendor  = ISNULL(JacketVendor ,'') -- 12/10/15 - KB - Case 35244


from hmco_import_into_pss
where bookkey = @i_bookkey
and row_id = @i_rowid
and (is_processed = 'N'
or is_processed is null)

if @material <> ''
begin
	select @update = 1

	select @Material2 = isnull(dbo.get_isbn_item (@i_bookkey, 15),'')

	if @i_update_mode = 'B' and @material2 <> ''
		select @update = 0

	if @update = 1 and @material <> @material2
	begin
		if @material = '&&&'	
			select @material = null

		update isbn
		set itemnumber = @material,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update material on isbn table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'isbn', 'itemnumber' , @i_bookkey, 1, 0, @material, 'Update', @i_userid, 
				null, 'Material Number', @o_error_code output, @o_error_desc output
	end
end

if @author <> ''
begin
	select @misckey = 27

	select @miscname = miscname, @misctype = misctype
	from bookmiscitems
	where misckey = @misckey

	exec hmco_import_from_SAP_misctext @i_bookkey, @i_update_mode, @i_userid, @misckey, @author, @miscname, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @titleshort <> ''
begin
	select @update = 1

	select @titleshort2 = substring(isnull(shorttitle,''),1,50)
	from book
	where bookkey = @i_bookkey

	if @i_update_mode = 'B' and @titleshort2 <> ''
		select @update = 0

	if @update = 1 and @titleshort <> @titleshort2
	begin
		if @titleshort = '&&&'	
			select @titleshort = null

		update book
		set shorttitle = @titleshort,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update short title on book table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'book', 'shorttitle' , @i_bookkey, 1, 0, @titleshort, 'Update', @i_userid, 
			null, 'Short Title', @o_error_code output, @o_error_desc output
	end
end

if @nextanceid <> ''
begin
	select @misckey = 23

	select @miscname = miscname, @misctype = misctype
	from bookmiscitems
	where misckey = @misckey

	exec hmco_import_from_SAP_misctext @i_bookkey, @i_update_mode, @i_userid, @misckey, @nextanceid, @miscname, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @materialstatus <> ''
begin
	select @update = 1

	select @MaterialStatus2 = dbo.get_bisacstatus (@i_bookkey, 'D')--mk20130214>Case 22403 Xart enhancement (MaterialSatus)

	if @i_update_mode = 'B' and @MaterialStatus2 <> ''
		select @update = 0

	if @update = 1 and @materialstatus <> @materialstatus2
	begin
		if @materialstatus = '&&&'	
		begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = datacode
			from gentables 
			where tableid = 314
			--and alternatedesc1 = @materialstatus
			and datadesc = @materialstatus--mk20130214>Case 22403 Xart enhancement (MaterialSatus)
			and deletestatus = 'N'

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update bookdetail table.  BISAC status value of '+@materialstatus+' not found.'
				RETURN
			end
		end

		update bookdetail
		set bisacstatuscode = @new_code,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update BISAC status on bookdetail table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @MaterialStatus2 = dbo.get_bisacstatus (@i_bookkey, 'D')

		exec qtitle_update_titlehistory 'bookdetail', 'bisacstatuscode' , @i_bookkey, 1, 0, @materialstatus2, 'Update', @i_userid, 
			null, 'BISAC status', @o_error_code output, @o_error_desc output
	end
end

if @ProdAvailability <> ''
begin
    declare @oldcode int
	select	@update = 1
	
		
	SELECT @datacode=coalesce(bd.bisacstatuscode,0),@oldcode = coalesce(bd.prodavailability,0)
	  from bookdetail bd
	 where  bd.bookkey=@i_bookkey
	
	IF @datacode > 0 AND @oldcode > 0 BEGIN  -- Both bisacstatuscode and prodavailability exist on title
		select @count = count(*)
		  from subgentables sgt 
		 where sgt.tableid=314
		  and sgt.deletestatus='N'
		  and sgt.datacode = @datacode
		  and sgt.datasubcode = @oldcode
		  
	  
	    if @count = 1 --row found on gentables: obtain value of existing subgentable datadesc
	
			select	@ProdAvailability2 = coalesce(sgt.datadesc,''), @datacode=coalesce(sgt.datacode,0)   -- 12/10/15 - KB - Case 35244
			  from subgentables sgt 
			 where sgt.tableid=314
			   and sgt.deletestatus='N'
			   and sgt.datacode = @datacode
			   and sgt.datasubcode = @oldcode
			   
		else if @count = 0       -- row does not exist on subgentables for the bisacstatuscode and prodavailability
		   set @ProdAvailability2 = ''
	END
	ELSE IF @datacode > 0 AND @oldcode = 0    -- only bisacstatuscode on title; prodavailability is NULL on title
		set @ProdAvailability2 = ''
	ELSE                                      -- neither exist on title
		set @ProdAvailability2 = ''
		
		
	if @i_update_mode = 'B' and @ProdAvailability2 <> ''
		select @update = 0

	if @update = 1 and @ProdAvailability <> @ProdAvailability2 AND @datacode > 0 begin
		if @ProdAvailability = '&&&' begin
			select @new_code = null
		end
		else begin
			select	top 1 @new_code = sgt.datasubcode
			  from	subgentables sgt
			 where	tableid = 314
			   and datadesc = @ProdAvailability
			   and datacode=@datacode
			   and deletestatus = 'N'

			if @new_code is null begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update bookdetail table.  Product Availability value of '+@ProdAvailability+' not found.'
				RETURN
			end
		end

		update	bookdetail
		   set	ProdAvailability = @new_code,lastuserid = @i_userid,lastmaintdate = getdate()
		 where	bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update Product Availability on bookdetail table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 
		
		exec qtitle_update_titlehistory 'bookdetail', 'ProdAvailability' , @i_bookkey, 1, 0, @ProdAvailability, 'Update', @i_userid, 
			null, 'Product Availability', @o_error_code output, @o_error_desc output
	end
end

if @CopyrightYear <> ''
begin
	select @update = 1

	select @CopyrightYear2 = isnull(copyrightyear,'')
	from bookdetail bd
	where bd.bookkey = @i_bookkey

	if @i_update_mode = 'B' and @CopyrightYear2 <> ''
		select @update = 0

	if @update = 1 and @copyrightyear <> @copyrightyear2
	begin

		update bookdetail
		set copyrightyear = @CopyrightYear,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update copyright year on bookdetail table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'bookdetail', 'copyrightyear' , @i_bookkey, 1, 0, @copyrightyear, 'Update', @i_userid, 
			null, 'Copyright Year', @o_error_code output, @o_error_desc output
	end
end

if @materialtype <> ''
begin
	select @misckey = 22
	select @fielddesc = 'material type'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @materialtype, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @materialgroup <> ''
begin
	select @misckey = 15
	select @fielddesc = 'material group'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @materialgroup, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @productpresentation <> ''
begin
	select @misckey = 20
	select @fielddesc = 'product presentation'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @productpresentation, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @mediatype <> ''
begin
	select @misckey = 14
	select @fielddesc = 'media type'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @mediatype, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @publicationtype <> ''
begin
	select @misckey = 8
	select @fielddesc = 'publication type'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @publicationtype, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @externalmaterialgroup <> ''
begin
	select @misckey = 10
	select @fielddesc = 'external material group'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @externalmaterialgroup, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @contentcategory <> ''
begin
	select @misckey = 19
	select @fielddesc = 'content category'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @contentcategory, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @accountassignmentgroup <> ''
begin
	select @misckey = 16
	select @fielddesc = 'account assignment group'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @accountassignmentgroup, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @countryoforigin <> ''
begin
	select @misckey = 28
	select @fielddesc = 'country of origin'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @countryoforigin, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @pricegroup <> ''
begin
	select @update = 1

	select @priceGroup2 = dbo.get_discount (@i_bookkey, 'S')

	if @i_update_mode = 'B' and @priceGroup2 <> ''
		select @update = 0

	if @update = 1 and @pricegroup <> @pricegroup2
	begin
		if @pricegroup = '&&&'	
		begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = datacode
			from gentables 
			where tableid = 459
			and datadescshort = @pricegroup
			and deletestatus = 'N'

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update bookdetail table.  Discount value of '+@pricegroup+' not found.'
				RETURN
			end
		end

		update bookdetail
		set discountcode = @new_code,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update discount code on bookdetail table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @priceGroup2 = dbo.get_discount (@i_bookkey, 'D')

		exec qtitle_update_titlehistory 'bookdetail', 'discountcode' , @i_bookkey, 1, 0, @pricegroup2, 'Update', @i_userid, 
			null, 'Discount Code', @o_error_code output, @o_error_desc output
	end
end

if @ReturnDispositioncode <> ''
begin
	select @update = 1

	select @ReturnDispositioncode2 = dbo.get_returnind (@i_bookkey, 'S')

	if @i_update_mode = 'B' and @ReturnDispositioncode2 <> ''
		select @update = 0

	if @update = 1 and @returndispositioncode <> @returndispositioncode2
	begin
		if @ReturnDispositioncode = '&&&'	
		begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = datacode
			from gentables 
			where tableid = 319
			and datadescshort = @ReturnDispositioncode
			and deletestatus = 'N'

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update bookdetail table.  Return disposition value of '+@ReturnDispositioncode+' not found.'
				RETURN
			end
		end

		update bookdetail
		set returncode = @new_code,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update return disposition on bookdetail table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @ReturnDispositioncode2 = dbo.get_returnind (@i_bookkey, 'D')

		exec qtitle_update_titlehistory 'bookdetail', 'returncode' , @i_bookkey, 1, 0, @ReturnDispositioncode2, 'Update', @i_userid, 
			null, 'Return Code', @o_error_code output, @o_error_desc output
	end
end

if @salesrestriction <> ''
begin
	select @update = 1

	select @salesrestriction2 = dbo.get_SalesRestriction (@i_bookkey, 'S')

	if @i_update_mode = 'B' and @salesrestriction2 <> ''
		select @update = 0

	if @update = 1 and @salesrestriction <> @salesrestriction2
	begin
		if @salesrestriction = '&&&'	
		begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = datacode
			from gentables 
			where tableid = 428
			and datadescshort = @salesrestriction
			and deletestatus = 'N'

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update bookdetail table.  Sales restriction value of '+@salesrestriction+' not found.'
				RETURN
			end
		end

		update bookdetail
		set canadianrestrictioncode = @new_code,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update sales restriction on bookdetail table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @salesrestriction2 = dbo.get_SalesRestriction (@i_bookkey, 'D')

		exec qtitle_update_titlehistory 'bookdetail', 'canadianrestrictioncode' , @i_bookkey, 1, 0, @salesrestriction2, 'Update', @i_userid, 
			null, 'Sales Restriction Code', @o_error_code output, @o_error_desc output
	end
end

if @bisacmedia <> '' and @format = ''
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update bookdetail table.  Format value must be populated if bisacmedia is populated.'
	RETURN
end

if @bisacmedia <> '' and @format <> ''
begin
	select top 1 @new_code = s.datasubcode
	from subgentables s
	join gentables g
	on s.tableid = g.tableid
	where g.tableid = 312
	and g.datadescshort = @bisacmedia
	and s.datadescshort = @format

	if @new_code is null
	begin
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update bookdetail table.  Bisac media of ' + @bisacmedia + ' and format of ' + @format + ' combination is not valid.'
		RETURN
	end
end

if @bisacmedia <> ''
begin
	select @update = 1

	select @bisacmedia2 = dbo.rpt_get_media (@i_bookkey, 'S')

	if @i_update_mode = 'B' and @bisacmedia2 <> ''
		select @update = 0

	if @update = 1 and @bisacmedia <> @bisacmedia2
	begin
		if @bisacmedia = '&&&'	begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = datacode
			from gentables 
			where tableid = 312
			and datadescshort = @bisacmedia

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update bookdetail table.  Bisac media short value of '+@bisacmedia+' not found.'
				RETURN
			end
		end

		update bookdetail
		set mediatypecode = @new_code,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update media on bookdetail table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @bisacmedia2 = dbo.rpt_get_media (@i_bookkey, 'D')

		exec qtitle_update_titlehistory 'bookdetail', 'mediatypecode' , @i_bookkey, 1, 0, @bisacmedia2, 'Update', @i_userid, 
			null, 'Media', @o_error_code output, @o_error_desc output
	end
end

set @new_code = null

if @format <> ''
begin
	select @update = 1

	select @format2 = dbo.get_format (@i_bookkey, 'S')
	select @bisacmediacode = mediatypecode
	from bookdetail
	where bookkey = @i_bookkey

	if @i_update_mode = 'B' and @format2 <> ''
		select @update = 0

	if @update = 1 and @format <> @format2
	begin
		if @format = '&&&'	begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = datasubcode
			from subgentables 
			where tableid = 312
			and datacode = @bisacmediacode
			and datadescshort = @format

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update bookdetail table.  Format value of '+@format+' not found.'
				RETURN
			end
		end

		update bookdetail
		set mediatypesubcode = @new_code,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update format on bookdetail table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @format2 = dbo.get_format (@i_bookkey, 'D')

		exec qtitle_update_titlehistory 'bookdetail', 'mediatypesubcode' , @i_bookkey, 1, 0, @format2, 'Update', @i_userid, 
			null, 'Format', @o_error_code output, @o_error_desc output
	end
end

if @territories <> ''
begin
	select @update = 1

	select @territories2 = dbo.get_territory (@i_bookkey, 'S')

	if @i_update_mode = 'B' and @territories2 <> ''
	begin
		select @update = 0
	end

	if @update = 1 and @territories <> @territories2
	begin
		if @territories = '&&&'	
		begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = datacode
			from gentables 
			where tableid = 131
			and datadescshort = @territories
			and deletestatus = 'N'

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update book table.  Territory value of '+@territories+' not found.'
				RETURN
			end
		end

		update book
		set territoriescode = @new_code,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update territories on book table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @territories2 = dbo.get_territory (@i_bookkey, 'D')

		exec qtitle_update_titlehistory 'book', 'territoriescode' , @i_bookkey, 1, 0, @territories2, 'Update', @i_userid, 
			null, 'Territory', @o_error_code output, @o_error_desc output
	end
end

if @returnrestriction <> ''
begin
	select @update = 1

	select @returnrestriction2 = dbo.get_returnrestriction (@i_bookkey, 'S')

	if @i_update_mode = 'B' and @returnrestriction2 <> ''
		select @update = 0

	if @update = 1 and @returnrestriction <> @returnrestriction2
	begin
		if @returnrestriction = '&&&'	
		begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = datacode
			from gentables 
			where tableid = 320
			and datadescshort = @returnrestriction
			and deletestatus = 'N'

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update bookdetail table.  Return restriction value of '+@returnrestriction+' not found.'
				RETURN
			end
		end

		update bookdetail
		set restrictioncode = @new_code,
		lastuserid = @i_userid,
		lastmaintdate = getdate()
		where bookkey = @i_bookkey

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update return restriction on bookdetail table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @returnrestriction2 = dbo.get_returnrestriction (@i_bookkey, 'D')

		exec qtitle_update_titlehistory 'bookdetail', 'restrictioncode' , @i_bookkey, 1, 0, @returnrestriction2, 'Update', @i_userid, 
			null, 'Return Restriction', @o_error_code output, @o_error_desc output
	end
end

--if @subtitle2 <> ''
--begin
--	select @update = 1

--	select  @subtitle22 = isnull(seriescode,0)
--	from bookdetail bd
--	where bd.bookkey = @i_bookkey

--	if @i_update_mode = 'B' and @subtitle22 <> 0
--	begin
--		select @update = 0
--	end

--	if @update = 1
--	begin
--		if @subtitle2 = '&&&'	
--		begin
--			select @new_code = null
--		end
--		else
--		begin
--			select top 1 @new_code = datacode
--			from gentables 
--			where tableid = 327
--			and datadesc = @subtitle2
--			and deletestatus = 'N'

--			if @new_code is null
--			begin
--				SET @o_error_code = -2
--				SET @o_error_desc = 'Unable to update bookdetail table.  Series value of '+@subtitle2+' not found.'
--				RETURN
--			end
--		end

--		if isnull(@new_code,0) <> @subtitle22
--		begin
--			update bookdetail
--			set seriescode = @new_code,
--			lastuserid = @i_userid,
--			lastmaintdate = getdate()
--			where bookkey = @i_bookkey

--			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
--			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
--				SET @o_error_code = -1
--				SET @o_error_desc = 'Unable to update series on bookdetail table.   Error #' + cast(@v_error as varchar(20))
--				RETURN
--			END 

--			select  @subtitle2 = g.datadesc
--			from bookdetail bd
--			join gentables g
--			on bd.seriescode = g.datacode
--			and g.tableid = 327
--			where bd.bookkey = @i_bookkey

--			exec qtitle_update_titlehistory 'bookdetail', 'seriescode' , @i_bookkey, 1, 0, @subtitle2, 'Update', @i_userid, 
--				null, 'Series', @o_error_code output, @o_error_desc output
--		end
--	end
--end

if @reprintingtype <> ''
begin
	select @update = 1

	select @ReprintingType2 = isnull(slotcode,0)
	from printing p
	where p.bookkey = @i_bookkey
	and p.printingkey = 1

	if @i_update_mode = 'B' and @ReprintingType2 <> ''
		select @update = 0

	if @update = 1
	begin
		if @ReprintingType = '&&&'	
		begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = datacode
			from gentables 
			where tableid = 102
			and datadescshort = @ReprintingType
			and deletestatus = 'N'

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update printing table.  Reprinting type value of '+@ReprintingType+' not found.'
				RETURN
			end
		end

		if isnull(@new_code,0) <> @reprintingtype2
		begin
			update printing
			set slotcode = @new_code,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			where bookkey = @i_bookkey
			and printingkey = 1

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to update reprinting type on printing table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			select @ReprintingType = datadesc
			from printing p
			join gentables g
			on p.slotcode = g.datacode
			and g.tableid = 102
			where p.bookkey = @i_bookkey
			and p.printingkey = 1

			exec qtitle_update_titlehistory 'printing', 'slotcode' , @i_bookkey, 1, 0, @ReprintingType, 'Update', @i_userid, 
				null, 'Slot', @o_error_code output, @o_error_desc output
		end
	end
end

if @itemcategory <> ''
begin
	select @misckey = 11
	select @fielddesc = 'item category'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @itemcategory, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @phlevel1 <> '' and @i_update_mode <> 'B'
begin
	select @orglevelkey = 1

	exec hmco_import_from_SAP_orgs @i_bookkey, @i_userid, @orglevelkey, @phlevel1, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @phlevel2 <> '' and @i_update_mode <> 'B'
begin
	select @orglevelkey = 2

	exec hmco_import_from_SAP_orgs @i_bookkey, @i_userid, @orglevelkey, @phlevel2, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @phlevel3 <> '' and @i_update_mode <> 'B'
begin
	select @orglevelkey = 3

	exec hmco_import_from_SAP_orgs @i_bookkey, @i_userid, @orglevelkey, @phlevel3, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @phlevel4 <> '' and @i_update_mode <> 'B'
begin
	select @orglevelkey = 4

	exec hmco_import_from_SAP_orgs @i_bookkey, @i_userid, @orglevelkey, @phlevel4, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @phlevel5 <> '' and @i_update_mode <> 'B'
begin
	select @orglevelkey = 5

	exec hmco_import_from_SAP_orgs @i_bookkey, @i_userid, @orglevelkey, @phlevel5, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @cartonrounding <> ''
begin
	select @misckey = 18
	select @fielddesc = 'carton rounding'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @cartonrounding, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @plant <> ''
begin
	select @misckey = 12
	select @fielddesc = 'plant'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @plant, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @materialstatisticsgroup <> ''
begin
	select @misckey = 17
	select @fielddesc = 'material statistics  group'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @materialstatisticsgroup, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @ea <> ''
begin
	select @misckey = 25

	select @miscname = miscname, @misctype = misctype
	from bookmiscitems
	where misckey = @misckey

	exec hmco_import_from_SAP_miscnum @i_bookkey, @i_update_mode, @i_userid, @misckey, @misctype, @ea, @miscname, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @pu <> ''
begin
	select @misckey = 26

	select @miscname = miscname, @misctype = misctype
	from bookmiscitems
	where misckey = @misckey

	exec hmco_import_from_SAP_miscnum @i_bookkey, @i_update_mode, @i_userid, @misckey, @misctype, @pu, @miscname, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @cartonquantity > 0
begin
	select @update = 1
	select @insert = 0

	select @cartonquantity2 = isnull(cartonqty1,0)
	from bindingspecs
	where bookkey = @i_bookkey
	and printingkey = 1

	SELECT @v_rowcount = @@ROWCOUNT
	if @v_rowcount = 0
		set @insert = 1

	if @i_update_mode = 'B' and @cartonquantity2 > 0
		select @update = 0

	if @update = 1 and isnull(@cartonquantity,0) <> isnull(@cartonquantity2,0)
	begin
--		if @cartonquantity = '&&&'	
--			select @cartonquantity = null

		if @insert = 1
		begin
			insert into bindingspecs (bookkey, printingkey, cartonqty1, lastmaintdate, lastuserid)
			values (@i_bookkey, 1, @cartonquantity, getdate(), @i_userid)

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to insert carton quantity on bindingspecs table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			exec qtitle_update_titlehistory 'bindingspecs', 'cartonqty1' , @i_bookkey, 1, 0, @cartonquantity, 'Insert', @i_userid, 
				null, 'Carton Quantity', @o_error_code output, @o_error_desc output
		end
		else
		begin
			update bindingspecs
			set cartonqty1 = @cartonquantity,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			where bookkey = @i_bookkey
			and printingkey = 1

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to update carton quantity on bindingspecs table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			exec qtitle_update_titlehistory 'bindingspecs', 'cartonqty1' , @i_bookkey, 1, 0, @cartonquantity, 'Update', @i_userid, 
				null, 'Carton Quantity', @o_error_code output, @o_error_desc output
		end
	end
end

if @unitweight > 0
begin
	select @update = 1
	
	select @unitweight2 = isnull(bookweight,0)
	from printing
	where bookkey = @i_bookkey
	  and printingkey = 1

	
	if @i_update_mode = 'B' and @unitweight2 > 0
		select @update = 0

	if @update = 1 and isnull(@unitweight,0) <> isnull(@unitweight2,0)
	begin
		if @unitweight = -9	
			select @unitweight = null

		update printing
		   set bookweight = @unitweight,
		       lastuserid = @i_userid,
			   lastmaintdate = getdate()
		 where bookkey = @i_bookkey
			   and printingkey = 1

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update unitweight on printing table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'printing', 'bookweight' , @i_bookkey, 1, 0, @unitweight, 'Update', @i_userid, 
			null, 'Unit Weight', @o_error_code output, @o_error_desc output
	end
end

if @trimlength <> '' or @trimwidth <> ''
begin
	--trim width & height - check options table to know which fields store actual
	SELECT @optionvalue = 0

	SELECT @optionvalue = optionvalue 
	FROM 	clientoptions
	WHERE 	optionid = 7  /*clientoptions trim*/

	IF @optionvalue = 1
		SELECT @trimlength2 = isnull(tmmactualtrimlength,''),
				@trimwidth2 = isnull(tmmactualtrimwidth,'')
		FROM printing
		WHERE bookkey = @i_bookkey
		AND  printingkey = 1 
	ELSE
		SELECT @trimlength2 = isnull(trimsizelength,''),
				@trimwidth2 = isnull(trimsizewidth,'')
		FROM printing
		WHERE bookkey = @i_bookkey
		AND  printingkey = 1 
end

if @trimlength <> ''
begin
	select @update = 1

	if @i_update_mode = 'B' and @trimlength2 <> ''
		select @update = 0

	if @update = 1 and @trimlength <> @trimlength2
	begin
		if @trimlength = '&&&'	
			select @trimlength = null

		IF @optionvalue = 1
			update printing
			set tmmactualtrimlength = @trimlength,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			WHERE bookkey = @i_bookkey
			AND  printingkey = 1 
		ELSE
			update printing
			set trimsizelength = @trimlength,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			WHERE bookkey = @i_bookkey
			AND  printingkey = 1 

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update trim length on printing table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'printing', 'trimsizelength' , @i_bookkey, 1, 0, @trimlength, 'Update', @i_userid, 
			null, 'Trim length', @o_error_code output, @o_error_desc output
	end
end

if @trimwidth <> ''
begin
	select @update = 1

	if @i_update_mode = 'B' and @trimwidth2 <> ''
		select @update = 0

	if @update = 1 and @trimwidth <> @trimwidth2
	begin
		if @trimwidth = '&&&'	
			select @trimwidth = null

		IF @optionvalue = 1
			update printing
			set tmmactualtrimwidth = @trimwidth,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			WHERE bookkey = @i_bookkey
			AND  printingkey = 1 
		ELSE
			update printing
			set trimsizewidth = @trimwidth,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			WHERE bookkey = @i_bookkey
			AND  printingkey = 1 

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update trim width on printing table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'printing', 'trimsizewidth' , @i_bookkey, 1, 0, @trimwidth, 'Update', @i_userid, 
			null, 'Trim width', @o_error_code output, @o_error_desc output
	end
end

if @pagecount > 0
begin
	select @update = 1

	SELECT @optionvalue = 0

	SELECT @optionvalue = optionvalue 
	FROM 	clientoptions
	WHERE 	optionid = 4  /*clientoptions pagecount*/

	IF @optionvalue = 1
		SELECT @pagecount2 = isnull(tmmpagecount,0) 
		FROM 	printing
		WHERE 	bookkey = @i_bookkey
			AND  printingkey = 1 
	ELSE
		SELECT @pagecount2 = isnull(pagecount,0) 
		FROM 	printing
		WHERE 	bookkey = @i_bookkey
			AND  printingkey = 1 

	if @i_update_mode = 'B' and @pagecount2 > 0
		select @update = 0

	if @update = 1 and @pagecount <> @pagecount2
	begin
--		if @pagecount = '&&&'	
--			select @pagecount = null

		IF @optionvalue = 1
			update printing
			set tmmpagecount = @pagecount,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			WHERE bookkey = @i_bookkey
			AND  printingkey = 1 
		ELSE
			update printing
			set pagecount = @pagecount,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			WHERE bookkey = @i_bookkey
			AND  printingkey = 1 

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update page count on printing table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'printing', 'pagecount' , @i_bookkey, 1, 0, @pagecount, 'Update', @i_userid, 
			null, 'Page count', @o_error_code output, @o_error_desc output
	end
end

if @releasedate <> ''
begin
	select @datetypecode = 32
	select @fielddesc = 'release date'

	exec hmco_import_from_SAP_bookdate @i_bookkey, @printingkey, @i_update_mode, @i_userid, @datetypecode, 
			@releasedate, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if len(@estwarehousedate)<>0
begin
	if @DEBUG<>0 print 'start processing @estwarehousedate ...'
	select @datetypecode = 47
	select @fielddesc = 'Est warehouse date'
	

	exec hmco_import_from_SAP_bookdate @i_bookkey, @printingkey, @i_update_mode, @i_userid, @datetypecode, 
			@estwarehousedate, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		if @DEBUG<>0 print 'error processing @estwarehousedate'
		return
	end
	if @DEBUG<>0 print 'end processing @estwarehousedate'
end

if len(@warehousedate)<>0
begin
	if @DEBUG<>0 print 'start processing @warehousedate ...'
	select @datetypecode = 47
	select @fielddesc = 'warehouse date'

	exec hmco_import_from_SAP_bookdate @i_bookkey, @printingkey, @i_update_mode, @i_userid, @datetypecode, 
			@warehousedate, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		if @DEBUG<>0 print 'error processing @warehousedate'
		return
	end
	if @DEBUG<>0 print 'end processing @warehousedate'
end

if @pubdate <> ''
begin
	select @datetypecode = 8
	select @fielddesc = 'publication date'

	exec hmco_import_from_SAP_bookdate @i_bookkey, @printingkey, @i_update_mode, @i_userid, @datetypecode, 
			@pubdate, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @internalstatus <> ''
begin
	select @update = 1

	select  @internalstatus2 = isnull(titlestatuscode,0)
	from book bd
	where bd.bookkey = @i_bookkey

	if @i_update_mode = 'B' and @internalstatus2 > 0
		select @update = 0

	if @update = 1
	begin
		if @internalstatus = '&&&'	
		begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = datacode
			from gentables 
			where tableid = 149
			and datadescshort = @internalstatus
			and deletestatus = 'N'

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update book table.  Internal status value of '+@internalstatus+' not found.'
				RETURN
			end
		end

		if isnull(@new_code,0) <> @internalstatus2
		begin
			update book
			set titlestatuscode = @new_code,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			where bookkey = @i_bookkey

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to update internal status on book table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			select  @internalstatus = g.datadesc
			from book bd
			join gentables g
			on bd.titlestatuscode = g.datacode
			and g.tableid = 149
			where bd.bookkey = @i_bookkey

			exec qtitle_update_titlehistory 'book', 'titlestatuscode' , @i_bookkey, 1, 0, @internalstatus, 'Update', @i_userid, 
				null, 'Internal Status', @o_error_code output, @o_error_desc output
		end
	end
end

if @usretailprice > 0
begin
	select @update = 1
	select @insert = 0

	select @usretailprice2 = isnull(finalprice,0)
	from bookprice
	where bookkey = @i_bookkey
	and pricetypecode = 8
	and currencytypecode = 6
	and activeind = 1

	SELECT @v_rowcount = @@ROWCOUNT
	if @v_rowcount = 0
		set @insert = 1

	if @i_update_mode = 'B' and @usretailprice2 > 0
		select @update = 0

	if @update = 1 and isnull(@usretailprice,0) <> isnull(@usretailprice2,0)
	begin
--		if @usretailprice = '&&&'	
--			select @usretailprice = null

		if @insert = 1
		begin
			select @sortorder = max(sortorder) + 1 from bookprice where bookkey = @i_bookkey
			if @sortorder is null 
				set @sortorder = 1

			exec get_next_key @i_userid, @newkey output
			insert into bookprice (pricekey, bookkey, pricetypecode, currencytypecode, effectivedate, activeind, finalprice, sortorder, lastmaintdate, lastuserid)
			values (@newkey, @i_bookkey, 8, 6, getdate(), 1, @usretailprice, @sortorder, getdate(), @i_userid)

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to insert US retail price on bookprice table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			exec qtitle_update_titlehistory 'bookprice', 'finalprice' , @i_bookkey, 1, 0, @usretailprice, 'Insert', @i_userid, 
				null, 'Retail', @o_error_code output, @o_error_desc output
		end
		else
		begin
			update bookprice
			set finalprice = @usretailprice,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			where bookkey = @i_bookkey
			and pricetypecode = 8
			and currencytypecode = 6
			and activeind = 1

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to update US retail price on bookprice table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			exec qtitle_update_titlehistory 'bookprice', 'finalprice' , @i_bookkey, 1, 0, @usretailprice, 'Update', @i_userid, 
				null, 'Retail', @o_error_code output, @o_error_desc output
		end
	end
end

if @agencyprice > 0
begin
	select @update = 1
	select @insert = 0

	select @agencyprice2 = isnull(finalprice,0)
	from bookprice
	where bookkey = @i_bookkey
	and pricetypecode = 16
	and currencytypecode = 6
	and activeind = 1

	SELECT @v_rowcount = @@ROWCOUNT
	if @v_rowcount = 0
		set @insert = 1

	if @i_update_mode = 'B' and @agencyprice2 > 0
		select @update = 0

	if @update = 1 and isnull(@agencyprice,0) <> isnull(@agencyprice2,0)
	begin
--		if @agencyprice = '&&&'	
--			select @agencyprice = null

		if @insert = 1
		begin
			select @sortorder = max(sortorder) + 1 from bookprice where bookkey = @i_bookkey
			if @sortorder is null 
				set @sortorder = 1

			exec get_next_key @i_userid, @newkey output
			insert into bookprice (pricekey, bookkey, pricetypecode, currencytypecode, activeind, finalprice, sortorder, lastmaintdate, lastuserid)
			values (@newkey, @i_bookkey, 16, 6, 1, @agencyprice, @sortorder, getdate(), @i_userid)

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to insert agency price on bookprice table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			exec qtitle_update_titlehistory 'bookprice', 'finalprice' , @i_bookkey, 1, 0, @agencyprice, 'Insert', @i_userid, 
				null, 'Agency price', @o_error_code output, @o_error_desc output
		end
		else
		begin
			update bookprice
			set finalprice = @agencyprice,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			where bookkey = @i_bookkey
			and pricetypecode = 16
			and currencytypecode = 6
			and activeind = 1

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to update agency price on bookprice table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			exec qtitle_update_titlehistory 'bookprice', 'finalprice' , @i_bookkey, 1, 0, @agencyprice, 'Update', @i_userid, 
				null, 'Agency price', @o_error_code output, @o_error_desc output
		end
	end
end

if @textink <> '' and @textink is not null
begin
	select @update = 1
	select @insert = 0

	select @textink2 = isnull(i.inkdescshort,'')
	from textspecs t
	left outer join ink i
	on t.inks = i.inkkey
	where bookkey = @i_bookkey
	and printingkey = 1

	SELECT @v_rowcount = @@ROWCOUNT
	if @v_rowcount = 0
		set @insert = 1

	if @i_update_mode = 'B' and @textink2 <> '' and @textink2 is not null
		select @update = 0

	if @update = 1 and isnull(@textink,'') <> isnull(@textink2,'')
	begin
		if @textink = '&&&'	
			select @textinkkey = null
		else
		begin
			select @textinkkey = inkkey, @textinkdesc = inkdesc
			from ink
			where inkdescshort = @textink		

			if @textinkkey is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to process text inks value.  Text ink value of '+@textink+' not found.'
				RETURN
			end
		end

		if @insert = 1
		begin
			insert into textspecs (bookkey, printingkey, inks, lastmaintdate, lastuserid)
			values (@i_bookkey, 1, @textinkkey, getdate(), @i_userid)

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to insert textink on textspecs table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			exec qtitle_update_titlehistory 'textspecs', 'inks' , @i_bookkey, 1, 0, @textinkdesc, 'Insert', @i_userid, 
				null, 'Text Inks', @o_error_code output, @o_error_desc output
		end
		else
		begin
			update textspecs
			set inks = @textinkkey,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			where bookkey = @i_bookkey
			and printingkey = 1

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to update text inks on textspecs table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			exec qtitle_update_titlehistory 'textspecs', 'inks' , @i_bookkey, 1, 0, @textinkdesc, 'Update', @i_userid, 
				null, 'Text Inks', @o_error_code output, @o_error_desc output
		end
	end
end

if @filetypecode > 0 or @pathname <> '' or @filedescription<>''--mk20140529> Case: 27609 New fields for XART import
begin
	exec hmco_import_from_SAP_fileloc @i_bookkey, @printingkey, @i_update_mode, @i_userid, @filetypecode, @pathname, @filesendtoeloquenceind, @filedescription,@o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @authortypecode > 0 and @authorkey > 0 
begin
	exec hmco_import_from_SAP_author @i_bookkey, @printingkey, @i_update_mode, @i_userid, @authortypecode, @authorkey, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @workkey > 0 
begin
	select @update = 1

	select @workkey2 = isnull(workkey,0)
	from book
	where bookkey = @i_bookkey

	if @i_update_mode = 'B' and @workkey2 > 0
		select @update = 0

	--validate given workkey is a valid bookkey
	select @newkey = count(*)
	from book
	where bookkey = @workkey

	SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
	IF @v_error <> 0 or @v_rowcount = 0 or @newkey = 0 or @newkey is null BEGIN 
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update the workkey for this bookkey - workkey is not a valid bookkey.   Error #' + cast(@v_error as varchar(20))
		RETURN
	END 

	if @update = 1 and isnull(@workkey,0) <> isnull(@workkey2,0)
	begin

		if @workkey = @i_bookkey
		begin
			update book
			set workkey = @workkey,
			linklevelcode = 10,
			propagatefrombookkey = null,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			from book
			where bookkey = @i_bookkey
		end
		else
		begin
			update book
			set workkey = @workkey,
			linklevelcode = 20,
			propagatefrombookkey = @workkey,
			lastuserid = @i_userid,
			lastmaintdate = getdate()
			from book
			where bookkey = @i_bookkey
		end

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 or @v_rowcount = 0 BEGIN 
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to update the workkey for this bookkey.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		exec qtitle_update_titlehistory 'book', 'workkey' , @i_bookkey, 1, 0, @workkey, 'Update', @i_userid, 
			null, 'Primary ISBN-13/EAN', @o_error_code output, @o_error_desc output
	end
end

--generic book misc fields
if @newmiscvalue <> '' and @newmiscvalue is not null and @newmisckey is not null
begin
	select @miscname = miscname, @misctype = misctype
	from bookmiscitems
	where misckey = @newmisckey

	if @misctype = 1 or @misctype = 4			--numeric or checkbox
	begin
		exec hmco_import_from_SAP_miscnum @i_bookkey, @i_update_mode, @i_userid, @newmisckey, @misctype, @newmiscvalue, @miscname, @o_error_code output, @o_error_desc output

		IF @o_error_code < 0 BEGIN
			return
		end
	end
	else if @misctype = 2		--float
	begin
		exec hmco_import_from_SAP_miscfloat @i_bookkey, @i_update_mode, @i_userid, @newmisckey, @misctype, @newmiscvalue, @miscname, @o_error_code output, @o_error_desc output

		IF @o_error_code < 0 BEGIN
			return
		end
	end
	else if @misctype = 3		--text
	begin
		exec hmco_import_from_SAP_misctext @i_bookkey, @i_update_mode, @i_userid, @newmisckey, @newmiscvalue, @miscname, @o_error_code output, @o_error_desc output

		IF @o_error_code < 0 BEGIN
			return
		end
	end
	else if @misctype = 5		--gentable
	begin
		exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @newmisckey, @newmiscvalue, @miscname, @o_error_code output, @o_error_desc output

		IF @o_error_code < 0 BEGIN
			return
		end
	end
end

--if subs are populated without higher fields, fail record
if ((@categorytableid is null or @categorytableid = 0) or (@category is null or @category = ''))
		and ((@categorysub is not null and @categorysub <> '') or (@categorysub2 is not null and @categorysub2 <> ''))
begin
	SET @o_error_code = -2
	SET @o_error_desc = 'Unable to update categories.  Categorytableid and Category are required for all category updates.'
	RETURN
end

if @categorytableid > 0 and @category is not null and @category <> ''
begin
	select @categorycode = datacode
	from gentables
	where tableid = @categorytableid
	and datadesc = @category

	if @categorycode is null
	begin
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update categories.  Categorytableid of '+ cast(@categorytableid as varchar(4)) + ' and Category of ' + @category + ' is not a valid combination.'
		RETURN
	end

	if @categorysub is not null and @categorysub <> ''
	begin
		select @categorysubcode = datasubcode
		from subgentables
		where tableid = @categorytableid
		and datacode = @categorycode
		and datadesc = @categorysub

		if @categorysubcode is null
		begin
			SET @o_error_code = -2
			SET @o_error_desc = 'Unable to update categories.  Categorytableid of '+ cast(@categorytableid as varchar(4)) + ', Category of ' + @category + ', Subcategory of '+ @categorysub + ' is not a valid combination.'
			RETURN
		end

		if @categorysub2 is not null and @categorysub2 <> ''
		begin
			select @categorysub2code = datasub2code
			from sub2gentables
			where tableid = @categorytableid
			and datacode = @categorycode
			and datasubcode = @categorysubcode
			and datadesc = @categorysub2

			if @categorysub2code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update categories.  Categorytableid of '+ cast(@categorytableid as varchar(4)) + ', Category of ' + @category + ', Subcategory of '+ @categorysub + ', 2nd Subcategory of ' + @categorysub2 + ' is not a valid combination.'
				RETURN
			end
		end
	end

	select @count = count(*)
	from booksubjectcategory
	where bookkey = @i_bookkey
	and categorytableid = @categorytableid
	and categorycode = @categorycode
	and isnull(categorysubcode,99999) = isnull(@categorysubcode,99999)
	and isnull(categorysub2code,99999) = isnull(@categorysub2code,99999)

	if @count = 0 or @count is null  --that category combo doesn't exist for title, so add it
	begin
		select @subjectkey = max(subjectkey)
		from booksubjectcategory
		where bookkey = @i_bookkey
		and categorytableid = @categorytableid

		select @subjectkey = isnull(@subjectkey,0) + 1

		select @sortorder = max(sortorder)
		from booksubjectcategory
		where bookkey = @i_bookkey
		and categorytableid = @categorytableid

		select @sortorder = isnull(@sortorder,0) + 1

		insert into booksubjectcategory (bookkey, subjectkey, categorytableid, categorycode, categorysubcode, categorysub2code, sortorder, lastuserid, lastmaintdate)
		values (@i_bookkey, @subjectkey, @categorytableid, @categorycode, @categorysubcode, @categorysub2code, @sortorder, @i_userid, getdate())

		SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
			SET @o_error_code = -1
			SET @o_error_desc = 'Unable to insert categories to booksubjectcategory table.   Error #' + cast(@v_error as varchar(20))
			RETURN
		END 

		select @fielddesc = 'Subject ' + cast(@sortorder as varchar(2))

		exec qtitle_update_titlehistory 'booksubjectcategory', 'categorycode' , @i_bookkey, 1, 0, @category, 'Insert', @i_userid, 
			null, @fielddesc, @o_error_code output, @o_error_desc output

		if @categorysub is not null and @categorysub <> ''
		begin
			select @fielddesc = @fielddesc + ' - ' + @category

			exec qtitle_update_titlehistory 'booksubjectcategory', 'categorysubcode' , @i_bookkey, 1, 0, @categorysub, 'Insert', @i_userid, 
				null, @fielddesc, @o_error_code output, @o_error_desc output

			if @categorysub2 is not null and @categorysub2 <> ''
			begin
				select @fielddesc = @fielddesc + ' - ' + @categorysub

				exec qtitle_update_titlehistory 'booksubjectcategory', 'categorysub2code' , @i_bookkey, 1, 0, @categorysub2, 'Insert', @i_userid, 
					null, @fielddesc, @o_error_code output, @o_error_desc output
			end
		end

	end
end

--safety test is a check box - valid values are 0 or 1
if @safetytest is not null
begin
	select @misckey = 31

	select @miscname = miscname, @misctype = misctype
	from bookmiscitems
	where misckey = @misckey

	exec hmco_import_from_SAP_miscnum @i_bookkey, @i_update_mode, @i_userid, @misckey, @misctype, @safetytest, @miscname, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @sapdatasetup <> ''
begin
	select @misckey = 24
	select @fielddesc = 'SAP Data Setup'

	exec hmco_import_from_SAP_miscgent @i_bookkey, @i_update_mode, @i_userid, @misckey, @sapdatasetup, @fielddesc, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @associatedbookkey > 0 or @associationtypecode > 0 or @associationtypesubcode > 0
begin
	exec hmco_import_from_sap_associated_titles @i_bookkey, @i_userid, @associatedbookkey, @associationtypecode,
			@associationtypesubcode, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @datetypecodepassed > 0 or @datevalue is not null or @actualind is not null
begin
	exec hmco_import_from_sap_update_task @i_bookkey, @i_userid, @datetypecodepassed, @datevalue, 
		@actualind, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @barcodetype1code > 0 or @barcodeposition1code is not null
begin
	exec hmco_import_from_sap_barcode @i_bookkey, @i_userid, @i_update_mode, @barcodetype1code,	@barcodeposition1code, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

if @pricetypecode <> 0 or @currencytypecode <> 0 or @priceeffdate is not null or @priceactiveind is not null or @pricevalue is not null
begin
	exec hmco_import_from_sap_price @i_bookkey, @i_userid, @i_update_mode, @pricetypecode,	@currencytypecode, @priceeffdate, @priceactiveind, @pricevalue, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

--mk2012.07.26> Case: 20220 Changes to Xart feed
--mk20140530> Case: 27609 New fields for XART import ... Commented out ProjectedSales into new miscitems (162/163)
if @QuantityEst > -2 or @QuantityAct > -2 /*or @ProjectedSalesEst > -2 or @ProjectedSalesAct > -2*/
begin
	exec hmco_import_from_sap_qtysales @i_bookkey, @i_userid, @i_update_mode, @QuantityEst, @QuantityAct, /*@ProjectedSalesEst*/NULL, /*@ProjectedSalesAct*/NULL, @o_error_code output, @o_error_desc output

	IF @o_error_code < 0 BEGIN
		return
	end
end

--mk2012.07.26> Case: 20220 Changes to Xart feed
if @PrintVendor <> ''
begin
	if @DEBUG<>0 print char(13)+char(10)
	if @DEBUG<>0 print 'start processing @PrintVendor ...'
	
	if @DEBUG<>0 print 'see if the @PrintVendor is a number or text'
	if isnumeric(@PrintVendor)= 1 begin
		if @DEBUG<>0 print 'if this is a number it could either be the vendorid (which could be alphanumeric)'
		select	@PrintVendorKey =VendorKey 
		from	vendor
		where	vendorid=@PrintVendor 
		
		if isnull(@PrintVendorKey,-1)=-1 begin
			if @DEBUG<>0 print ' ... or the VendorKey'
			select	@PrintVendorKey =VendorKey 
			from	vendor
			where	VendorKey=cast(@PrintVendor as int)
		end
	end
	else begin
		if @DEBUG<>0 print 'this is not a number therefore it is either a name of vendorid'
		select	@PrintVendorKey =VendorKey 
		from	vendor
		where	name=@PrintVendor or vendorid=@PrintVendor 
	end 
	
	if @DEBUG<>0 print 'now make sure a valid vendor key was found'
	if isnull(@PrintVendorKey,-1)<>-1 begin
		select	@count=count(*)
		from	textspecs
		where	printingkey = 1
				and bookkey=@i_bookkey

		if @count>0 begin
			update	textspecs
			set		vendorkey=@PrintVendorKey
			where	printingkey = 1
					and bookkey=@i_bookkey
		end
		else begin
			insert into textspecs (vendorkey, printingkey, bookkey)
			values(@PrintVendorKey, 1, @i_bookkey)
		end
		if @DEBUG<>0 print 'VendorKey has been successfully updated on the textspecs table'
	end
	else begin
		if @DEBUG<>0 print 'the vendor was not found in the vendor table'
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update Print Vendor.  The vendor was not found in the vendor table.'
	end

	IF @o_error_code < 0 BEGIN
		return
	end
	if @DEBUG<>0 print 'end processing @PrintVendor ...'
end

--mk2012.07.26> Case: 20220 Changes to Xart feed
--if (@agelow > -2 or @agehigh > -2 or @agelowupind > -2 or @agehighupind > -2) or 
--    (@agelow > -999 or @agehigh > -999 or @agelowupind > -9 or @agehighupind > -9)	
--if (@agelow <> -2 or @agehigh <> -2 or @agelowupind <> -2 or @agehighupind <> -2) 
--begin
--	if @DEBUG<>0 print char(13)+char(10)
--	if @DEBUG<>0 print 'start processing Age values ...'
--	if @DEBUG<>0 print 'get the existing values from bookdetail'
	
--	select @update = 1
			
--	select	@count=1
--			,@agelowORIG=coalesce(agelow,-1)
--			,@agehighORIG=coalesce(agehigh,-1)
--			,@agelowupindORIG=coalesce(agelowupind,-1)
--			,@agehighupindORIG=coalesce(agehighupind,-1)
--	  from	bookdetail
--	 where	bookkey=@i_bookkey
	
--	if isnull(@count,0)=1 begin	
--		if @DEBUG<>0 print 'record found ... now compare original and new values to see if anything changed'
		
--		if (@i_update_mode = 'B') 
--			select @update = 0
			
--		if @update = 1 AND @agelow = -999
--			SET @agelow = NULL
--		if @update = 1 AND @agehigh = -999
--			SET @agehigh = NULL
--		if @update = 1 AND @agelowupind = -9
--			SET @agelowupind = NULL
--		if @update = 1 AND @agehighupind = -9
--			SET @agehighupind = NULL
		
--		if	@update = 1 AND (@agelow <> @agelowORIG 
--			or @agehigh <> @agehighORIG 
--			or @agelowupind <> @agelowupindORIG 
--			or @agehighupind <> @agehighupindORIG) begin
			
--			if @agelow < 0 set @agelow=null
--			if @agehigh < 0 set @agehigh=null
--			if @agelowupind < 0 set @agelowupind=null
--			if @agehighupind < 0 set @agehighupind=null
			
--			if @DEBUG<>0 print '@agelow = '+ coalesce(cast(@agelow as varchar(max)), '*NULL*')
--			if @DEBUG<>0 print '@agehigh = '+ coalesce(cast(@agehigh as varchar(max)), '*NULL*')
--			if @DEBUG<>0 print '@agelowupind = '+ coalesce(cast(@agelowupind as varchar(max)), '*NULL*')
--			if @DEBUG<>0 print '@agehighupind = '+ coalesce(cast(@agehighupind as varchar(max)), '*NULL*')
			
--			if @DEBUG<>0 print 'there are new values that need updating'
--			if (@agelow <> @agelowORIG) begin
--				update bookdetail
--				   set agelow = @agelow
--				 where bookkey=@i_bookkey
--			end
--			if (@agehigh <> @agehighORIG) begin
--				update bookdetail
--				   set agehigh = @agehigh
--				 where bookkey=@i_bookkey
--			end
--			if (@agelowupind <> @agelowupindORIG) begin
--				update bookdetail
--				   set agelowupind = @agelowupind
--				 where bookkey=@i_bookkey
--			end
--			if (@agehighupind <> @agehighupindORIG) begin
--				update bookdetail
--				   set agehighupind = @agehighupind
--				 where bookkey=@i_bookkey
--			end
--			if @DEBUG<>0 print 'Age Values have been successfully updated on the bookdetail table'
--		end 
--	end 
--	else begin
--		if @DEBUG<>0 print 'The information for this title was not found in the bookdetail table'
--		SET @o_error_code = -2
--		SET @o_error_desc = 'Unable to update Age info.  The information for this title was not found in the bookdetail table.'
--	end	

--	IF @o_error_code < 0 BEGIN
--		return
--	end
--	if @DEBUG<>0 print 'end processing Age values ...'
--end

if (@agelow <> -2 or @agelow = -9999) 
begin
	if @DEBUG<>0 print char(13)+char(10)
	if @DEBUG<>0 print 'start processing agelow ...'
	if @DEBUG<>0 print 'get the existing values from bookdetail'
	
	select @update = 1
			
	select	@count=1,@agelowORIG=coalesce(agelow,-1)
	  from	bookdetail
	 where	bookkey=@i_bookkey
	
	if isnull(@count,0)=1 begin	
		if @DEBUG<>0 print 'record found ... now compare original and new values to see if anything changed'
		
		if (@i_update_mode = 'B') 
			select @update = 0
			
		--if @update = 1 AND @agelow = -999
		--	SET @agelow = NULL
		
		
		if	@update = 1 AND (@agelow <> @agelowORIG) begin
		
		    if @update = 1 AND @agelow = -999
				SET @agelow = NULL
			
			if @agelow < 0 set @agelow=null
						
			if @DEBUG<>0 print '@agelow = '+ coalesce(cast(@agelow as varchar(max)), '*NULL*')
						
			if @DEBUG<>0 print 'there are new values that need updating'
			if (@agelow <> @agelowORIG) OR (@agelow IS NULL) begin
				update bookdetail
				   set agelow = @agelow
				 where bookkey=@i_bookkey
			end
				
			if @DEBUG<>0 print 'Age Low Values have been successfully updated on the bookdetail table'
			
			exec qtitle_update_titlehistory 'bookdetail', 'agelow' , @i_bookkey, 1, 0, @AgeLow, 'Update', @i_userid, 
				null, 'Age-Low', @o_error_code output, @o_error_desc output
				
		end 
	end 
	else begin
		if @DEBUG<>0 print 'The information for this title was not found in the bookdetail table'
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update Age Low info.  The information for this title was not found in the bookdetail table.'
	end	

	IF @o_error_code < 0 BEGIN
		return
	end
	if @DEBUG<>0 print 'end processing Age values ...'
end

if (@agehigh <> -2 or @agehigh = -9999) 
begin
	if @DEBUG<>0 print char(13)+char(10)
	if @DEBUG<>0 print 'start processing agehigh ...'
	if @DEBUG<>0 print 'get the existing values from bookdetail'
	
	select @update = 1
			
	select	@count=1,@agehighORIG=coalesce(agehigh,-1)
	  from	bookdetail
	 where	bookkey=@i_bookkey
	
	if isnull(@count,0)=1 begin	
		if @DEBUG<>0 print 'record found ... now compare original and new values to see if anything changed'
		
		if (@i_update_mode = 'B') 
			select @update = 0
			
		--if @update = 1 AND @agehigh = -999
		--	SET @agehigh = NULL
		
		
		if	@update = 1 AND (@agehigh <> @agehighORIG) begin
		
		   if @update = 1 AND @agehigh = -999
			SET @agehigh = NULL
			
			if @agehigh < 0 set @agehigh=null
						
			if @DEBUG<>0 print '@agehigh = '+ coalesce(cast(@agehigh as varchar(max)), '*NULL*')
						
			if @DEBUG<>0 print 'there are new values that need updating'
			if (@agehigh <> @agehighORIG) OR (@agehigh IS NULL) begin
				update bookdetail
				   set agehigh = @agehigh
				 where bookkey=@i_bookkey
			end
				
			if @DEBUG<>0 print 'Age Low Values have been successfully updated on the bookdetail table'
			
			exec qtitle_update_titlehistory 'bookdetail', 'agehigh' , @i_bookkey, 1, 0, @agehigh, 'Update', @i_userid, 
				null, 'Age-High', @o_error_code output, @o_error_desc output
				
		end 
	end 
	else begin
		if @DEBUG<>0 print 'The information for this title was not found in the bookdetail table'
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update Age High info.  The information for this title was not found in the bookdetail table.'
	end	

	IF @o_error_code < 0 BEGIN
		return
	end
	if @DEBUG<>0 print 'end processing Age values ...'
end

if (@agelowupind <> -2 or @agelowupind = -9) 
begin
	if @DEBUG<>0 print char(13)+char(10)
	if @DEBUG<>0 print 'start processing Age Low Up Ind values ...'
	if @DEBUG<>0 print 'get the existing values from bookdetail'
	
	select @update = 1
			
	select	@count=1,@agelowupindORIG=coalesce(agelowupind,-1)
	  from	bookdetail
	 where	bookkey=@i_bookkey
	
	if isnull(@count,0)=1 begin	
		if @DEBUG<>0 print 'record found ... now compare original and new values to see if anything changed'
		
		if (@i_update_mode = 'B') 
			select @update = 0
			
		--if @update = 1 AND @agelowupind = -9
		--	SET @agelowupind = NULL
		
		
		if	@update = 1 AND @agelowupind <> @agelowupindORIG begin
		
			if @update = 1 AND @agelowupind = -9
				SET @agelowupind = NULL
						
			if @agelowupind < 0 set @agelowupind=null
												
			if @DEBUG<>0 print '@agelowupind = '+ coalesce(cast(@agelowupind as varchar(max)), '*NULL*')
						
			if @DEBUG<>0 print 'there are new values for age low up ind that need updating'
			if (@agelowupind <> @agelowupindORIG) OR (@agelowupind IS NULL )begin
				update bookdetail
				   set agelowupind = @agelowupind
				 where bookkey=@i_bookkey
			end
			
			if @DEBUG<>0 print 'Age Low Up Ind have been successfully updated on the bookdetail table'
			
			exec qtitle_update_titlehistory 'bookdetail', 'agelowupind' , @i_bookkey, 1, 0, @agelowupind, 'Update', @i_userid, 
				null, 'Age-Low Indicator', @o_error_code output, @o_error_desc output
		end 
	end 
	else begin
		if @DEBUG<>0 print 'The information for this title was not found in the bookdetail table'
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update Age Low Up Ind info.  The information for this title was not found in the bookdetail table.'
	end	

	IF @o_error_code < 0 BEGIN
		return
	end
	if @DEBUG<>0 print 'end processing Age values ...'
end

if (@agehighupind  <> -2 or @agehighupind  = -9) 
begin
	if @DEBUG<>0 print char(13)+char(10)
	if @DEBUG<>0 print 'start processing Age Low Up Ind values ...'
	if @DEBUG<>0 print 'get the existing values from bookdetail'
	
	select @update = 1
			
	select	@count=1,@agehighupindORIG=coalesce(agehighupind ,-1)
	  from	bookdetail
	 where	bookkey=@i_bookkey
	
	if isnull(@count,0)=1 begin	
		if @DEBUG<>0 print 'record found ... now compare original and new values to see if anything changed'
		
		if (@i_update_mode = 'B') 
			select @update = 0
			
		--if @update = 1 AND @agehighupind  = -9
		--	SET @agehighupind  = NULL
			
		if	@update = 1 AND @agehighupind  <> @agehighupindORIG begin
		
		   if @update = 1 AND @agehighupind  = -9
			SET @agehighupind  = NULL
						
			if @agehighupind  < 0 set @agehighupind =null
						
			if @DEBUG<>0 print '@agehighupind  = '+ coalesce(cast(@agehighupind  as varchar(max)), '*NULL*')
						
			if @DEBUG<>0 print 'there are new values for age low up ind that need updating'
			if (@agehighupind  <> @agehighupindORIG) OR (@agehighupind IS NULL ) begin
				update bookdetail
				   set agehighupind = @agehighupind 
				 where bookkey=@i_bookkey
			end
			
			if @DEBUG<>0 print 'Age High Up Ind have been successfully updated on the bookdetail table'
			
			exec qtitle_update_titlehistory 'bookdetail', 'agehighupind' , @i_bookkey, 1, 0, @agehighupind , 'Update', @i_userid, 
				null, 'Age-High Indicator', @o_error_code output, @o_error_desc output
		end 
	end 
	else begin
		if @DEBUG<>0 print 'The information for this title was not found in the bookdetail table'
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update Age High Up Ind info.  The information for this title was not found in the bookdetail table.'
	end	

	IF @o_error_code < 0 BEGIN
		return
	end
	if @DEBUG<>0 print 'end processing Age values ...'
end
 
--START mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 
IF @GradeLow <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing gradelow ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookdetail'
	
	select @update = 1
	
	SELECT @GradeLow_ORIG = gradelow
	FROM bookdetail
	WHERE bookkey = @i_bookkey
	
	if @i_update_mode = 'B' and @GradeLow_ORIG <> ''
		select @update = 0

	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @update = 1 AND @GradeLow <> coalesce(@GradeLow_ORIG,'*NULL*')
	BEGIN
		IF @DEBUG <> 0 PRINT '@GradeLow = ' + coalesce(cast(@GradeLow AS VARCHAR(max)), '*NULL*')
				
		IF @GradeLow = '&&&'	
			select @GradeLow = null

		UPDATE bookdetail
		SET gradelow = @GradeLow
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		IF @DEBUG <> 0 PRINT 'gradelow has been successfully updated on the bookdetail table'

		exec qtitle_update_titlehistory 'bookdetail', 'gradelow' , @i_bookkey, 1, 0, @GradeLow, 'Update', @i_userid, 
				null, 'Grade-Low', @o_error_code output, @o_error_desc output
		
	END

	IF @DEBUG <> 0 PRINT 'end processing @GradeLow values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @GradeHigh <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing gradehigh ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookdetail'

    select @update = 1
    
	SELECT @GradeHigh_ORIG = gradehigh
	FROM bookdetail
	WHERE bookkey = @i_bookkey
	
	if @i_update_mode = 'B' and @GradeLow_ORIG <> ''
		select @update = 0

	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @update = 1 AND @GradeHigh <> coalesce(@GradeHigh_ORIG,'*NULL*')
	BEGIN
		IF @DEBUG <> 0 PRINT '@GradeHigh = ' + coalesce(cast(@GradeHigh AS VARCHAR(max)), '*NULL*')
		
		IF @GradeHigh = '&&&'	
			select @GradeHigh = null

		UPDATE bookdetail
		SET gradehigh = @GradeHigh
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'bookdetail', 'gradehigh' , @i_bookkey, 1, 0, @GradeHigh, 'Update', @i_userid, 
				null, 'Grade-High', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'gradehigh has been successfully updated on the bookdetail table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @GradeHigh values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

-- Case 31794
IF @GradeLow_AndUnder in (0,1,-9)
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing gradelowupind ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookdetail'
	
	select @update = 1

	SELECT @GradeLow_AndUnder_ORIG = coalesce(gradelowupind,255)
	FROM bookdetail
	WHERE bookkey = @i_bookkey
	
	if @i_update_mode = 'B' and @GradeLow_AndUnder_ORIG <> 0
		select @update = 0
	
	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @update = 1  AND @GradeLow_AndUnder <> coalesce(@GradeLow_AndUnder_ORIG,0)
	BEGIN
		IF @DEBUG <> 0 PRINT '@GradeLow_AndUnder = ' + coalesce(cast(@GradeLow_AndUnder AS VARCHAR(max)), '*NULL*')
		
		if @GradeLow_AndUnder = -9	
			select @GradeLow_AndUnder = null

		UPDATE bookdetail
		SET gradelowupind = @GradeLow_AndUnder
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'bookdetail', 'gradelowupind' , @i_bookkey, 1, 0, @GradeLow_AndUnder, 'Update', @i_userid, 
				null, 'Grade-Low Indicator', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'gradelowupind has been successfully updated on the bookdetail table'
	END
	IF @DEBUG <> 0 PRINT 'end processing @GradeLow_AndUnder values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @GradeHigh_AndAbove in (0,1,-9)
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing gradehighupind ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookdetail'
	
	select @update = 1

	SELECT @GradeHigh_AndAbove_ORIG = coalesce(gradehighupind,255)
	FROM bookdetail
	WHERE bookkey = @i_bookkey
	
	if @i_update_mode = 'B' and @GradeHigh_AndAbove_ORIG <> 0
		select @update = 0

	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @update = 1  AND @GradeHigh_AndAbove <> coalesce(@GradeHigh_AndAbove_ORIG,0)
	BEGIN
		IF @DEBUG <> 0 PRINT '@GradeHigh_AndAbove = ' + coalesce(cast(@GradeHigh_AndAbove AS VARCHAR(max)), '*NULL*')
		
		if @GradeHigh_AndAbove = -9	
			select @GradeHigh_AndAbove = null

		UPDATE bookdetail
		SET gradehighupind = @GradeHigh_AndAbove
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'bookdetail', 'gradehighupind' , @i_bookkey, 1, 0, @GradeHigh_AndAbove, 'Update', @i_userid, 
				null, 'Grade-High Indicator', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'gradehighupind has been successfully updated on the bookdetail table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @GradeHigh_AndAbove values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF COALESCE(@Spine_Size,'') <>''
BEGIN
	SET @DEBUG=1

	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing spinesize ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from printing'
	
	SELECT @update = 1

	SELECT @Spine_Size_ORIG = COALESCE(spinesize,'')
	FROM printing
	WHERE bookkey = @i_bookkey
		
	IF @i_update_mode = 'B' and @Spine_Size_ORIG <> ''
		SELECT @update = 0
		
	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @update = 1 AND @Spine_Size <> COALESCE(@Spine_Size_ORIG,'')
	BEGIN
		IF @DEBUG <> 0 PRINT '@Spine_Size = ' + coalesce(cast(@Spine_Size AS VARCHAR(max)), '*NULL*')
		
		IF @Spine_Size = '&&&'	
			SELECT @Spine_Size = null

		UPDATE printing
		SET spinesize = @Spine_Size
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'printing', 'spinesize' , @i_bookkey, 1, 0, @Spine_Size, 'Update', @i_userid, 
				null, 'Spine Size', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'spinesize has been successfully updated on the bookdetail table'
	END
	
	IF @DEBUG <> 0 PRINT 'end processing @Spine_Size values ...'
	SET @DEBUG=1

END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @Inserts_Estimated <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing estimatedinsertillus ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from printing'
	
	SELECT @update = 1

	SELECT @Inserts_Estimated_ORIG = estimatedinsertillus
	FROM printing
	WHERE bookkey = @i_bookkey
	
	IF @i_update_mode = 'B' AND @Inserts_Estimated_ORIG <> ''
		SELECT @update = 0

	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @update = 1 AND @Inserts_Estimated <> COALESCE(@Inserts_Estimated_ORIG,'*NULL*')
	BEGIN
		IF @DEBUG <> 0 PRINT '@Inserts_Estimated = ' + coalesce(cast(@Inserts_Estimated AS VARCHAR(max)), '*NULL*')
		
		IF @Inserts_Estimated = '&&&'	
			SELECT @Inserts_Estimated = null
		
		UPDATE printing
		SET estimatedinsertillus = @Inserts_Estimated
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'printing', 'estimatedinsertillus' , @i_bookkey, 1, 0, @Inserts_Estimated, 'Update', @i_userid, 
				null, 'Estimated Num of Inserts', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'estimatedinsertillus has been successfully updated on the bookdetail table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @Inserts_Estimated values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @Inserts_Actual <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing actualinsertillus ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from printing'
	
	SELECT @update = 1
	
	SELECT @Inserts_Actual_ORIG = actualinsertillus
	FROM printing
	WHERE bookkey = @i_bookkey
	
	IF @i_update_mode = 'B' AND @Inserts_Actual_ORIG <> ''
		SELECT @update = 0

	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @update = 1 AND @Inserts_Actual <> COALESCE(@Inserts_Actual_ORIG,'*NULL*')
	BEGIN
		IF @DEBUG <> 0 PRINT '@Inserts_Actual = ' + coalesce(cast(@Inserts_Actual AS VARCHAR(max)), '*NULL*')
		
		IF @Inserts_Actual = '&&&'	
			SELECT @Inserts_Actual = null
		
		UPDATE printing
		SET actualinsertillus = @Inserts_Actual
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'printing', 'actualinsertillus' , @i_bookkey, 1, 0, @Inserts_Actual, 'Update', @i_userid, 
				null, 'Actual Num of Inserts', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'actualinsertillus has been successfully updated on the bookdetail table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @Inserts_Actual values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @Illustrations_Estimated <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing estimatedinsertillus ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from printing'

	
	SELECT @update = 1
	
	SELECT @Illustrations_Estimated_ORIG = estimatedinsertillus
	FROM printing
	WHERE bookkey = @i_bookkey
	
	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'
	
	IF @i_update_mode = 'B' AND @Illustrations_Estimated_ORIG <> ''
		SELECT @update = 0
		
	IF @update = 1 AND @Illustrations_Estimated <> COALESCE(@Illustrations_Estimated_ORIG,'*NULL*')
	BEGIN
		IF @DEBUG <> 0 PRINT '@Illustrations_Estimated = ' + coalesce(cast(@Illustrations_Estimated AS VARCHAR(max)), '*NULL*')

		IF @Illustrations_Estimated = '&&&'	
			SELECT @Illustrations_Estimated = null
		
		UPDATE printing
		SET estimatedinsertillus = @Illustrations_Estimated
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'printing', 'estimatedinsertillus' , @i_bookkey, 1, 0, @Illustrations_Estimated, 'Update', @i_userid, 
				null, 'Estimated Num of Illustrations', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'estimatedinsertillus has been successfully updated on the bookdetail table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @Illustrations_Estimated values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @Illustrations_Actual <> ''
BEGIN
	SELECT @update = 1
	
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing actualinsertillus ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from printing'

	SELECT @Illustrations_Actual_ORIG = actualinsertillus
	FROM printing
	WHERE bookkey = @i_bookkey
	
	IF @i_update_mode = 'B' AND @Illustrations_Actual_ORIG <> ''
		SELECT @update = 0

	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @update = 1 AND @Illustrations_Actual <> COALESCE(@Illustrations_Actual_ORIG,'*NULL*')
	BEGIN
		IF @DEBUG <> 0 PRINT '@Illustrations_Actual = ' + coalesce(cast(@Illustrations_Actual AS VARCHAR(max)), '*NULL*')
		
		IF @Illustrations_Actual = '&&&'	
			SELECT @Illustrations_Actual = null
		
		UPDATE printing
		SET actualinsertillus = @Illustrations_Actual
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'printing', 'actualinsertillus' , @i_bookkey, 1, 0, @Illustrations_Actual, 'Update', @i_userid, 
				null, 'Actual Num of Illustrations', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'actualinsertillus has been successfully updated on the bookdetail table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @Illustrations_Actual values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

if @Author_Primary_indicator>-1 and COALESCE(@authorkey,0)>1
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing primaryind ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookauthor'

	SELECT @count = 1
		,@Author_Primary_indicator_ORIG = primaryind
	FROM bookauthor
	WHERE bookkey = @i_bookkey and authorkey=@authorkey

	IF isnull(@count, 0) = 1
	BEGIN
		IF @DEBUG <> 0PRINT 'record found ... now compare original and new values to see if anything changed'

		IF @Author_Primary_indicator <> coalesce(@Author_Primary_indicator_ORIG,0)
		BEGIN
			IF @DEBUG <> 0 PRINT '@Author_Primary_indicator = ' + coalesce(cast(@Author_Primary_indicator AS VARCHAR(max)), '*NULL*')

			UPDATE bookauthor
			SET primaryind = @Author_Primary_indicator
				,lastuserid=@i_userid
				,lastmaintdate=GETDATE()
			WHERE bookkey = @i_bookkey and authorkey=@authorkey

			exec qtitle_update_titlehistory 'bookauthor', 'primaryind' , @i_bookkey, 1, 0, @Author_Primary_indicator, 'Update', @i_userid, 
					null, 'Author Primary Indicator', @o_error_code output, @o_error_desc output

			IF @DEBUG <> 0 PRINT 'primaryind has been successfully updated on the bookdetail table'
		END
	END
	ELSE
	BEGIN
		IF @DEBUG <> 0 PRINT 'the primaryind for this title was not found in the bookauthor table'

		SET @o_error_code = - 2
		SET @o_error_desc = 'Unable to update primaryind.  The information for this title was not found in the bookauthor table.'
	END

	IF @o_error_code < 0
	BEGIN
		RETURN
	END

	IF @DEBUG <> 0 PRINT 'end processing @Author_Primary_indicator values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

if @Author_Sort_order>-1 and COALESCE(@authorkey,0)>1
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing sortorder ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookauthor'

	SELECT @count = 1
		,@Author_Sort_order_ORIG = sortorder
	FROM bookauthor
	WHERE bookkey = @i_bookkey and authorkey=@authorkey

	IF isnull(@count, 0) = 1
	BEGIN
		IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

		IF @Author_Sort_order <> COALESCE(@Author_Sort_order_ORIG,-1)
		BEGIN
			IF @DEBUG <> 0 PRINT '@Author_Sort_order = ' + coalesce(cast(@Author_Sort_order AS VARCHAR(max)), '*NULL*')

			UPDATE bookauthor
			SET sortorder = @Author_Sort_order
				,lastuserid=@i_userid
				,lastmaintdate=GETDATE()
			WHERE bookkey = @i_bookkey and authorkey=@authorkey

			exec qtitle_update_titlehistory 'bookauthor', 'sortorder' , @i_bookkey, 1, 0, @Author_Sort_order, 'Update', @i_userid, 
					null, 'Author Sort Order', @o_error_code output, @o_error_desc output

			IF @DEBUG <> 0 PRINT 'sortorder has been successfully updated on the bookdetail table'
		END
	END
	ELSE
	BEGIN
		IF @DEBUG <> 0 PRINT 'the sortorder for this title was not found in the bookauthor table'

		SET @o_error_code = - 2
		SET @o_error_desc = 'Unable to update sortorder.  The information for this title was not found in the bookauthor table.'
	END

	IF @o_error_code < 0
	BEGIN
		RETURN
	END

	IF @DEBUG <> 0 PRINT 'end processing @Author_Sort_order values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 


-- 1/26/15 Case 31190 KB Xart updating participant names
IF @Participant_globalcontactkey>-1 and @Participant_Role_type>-1
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing rolecode ...'
 	IF @DEBUG <> 0 PRINT 'get the existing values from bookcontact'
 	IF @DEBUG <> 0 PRINT 'get the existing values from bookcontactrole'
 	
 	DECLARE @bookcontactkey INT=-1
 	
 		
 	SELECT @bookcontactkey=bookcontactkey FROM bookcontactrole WHERE bookcontactkey in (SELECT bookcontactkey FROM bookcontact
		where bookkey=@i_bookkey AND printingkey = @printingkey) and rolecode = @Participant_Role_type
	
	--print '@Participant_Role_type'
	--print @Participant_Role_type
 		
 	IF @bookcontactkey >-1   -- roletype exists for title and printing
 	BEGIN
 		SET @Participant_globalcontactkey_ORIG=-1
 		SELECT @Participant_globalcontactkey_ORIG=COALESCE(globalcontactkey,0) from bookcontact where bookcontactkey=@bookcontactkey
 		IF @Participant_globalcontactkey_ORIG <> @Participant_globalcontactkey
 		BEGIN
 			IF @DEBUG <> 0 PRINT 'role code found ... update bookcontact with globalcontactkey for '
 			IF @DEBUG <> 0 PRINT 'bookkey=' + cast(coalesce(@i_bookkey,'*NULL*') as varchar(max))
 			IF @DEBUG <> 0 PRINT ' AND globalcontactkey=' + cast(coalesce(@Participant_globalcontactkey,'*NULL*') as varchar(max))
 			IF @DEBUG <> 0 PRINT ' AND rolecode =' + cast(coalesce(@Participant_Role_type,'*NULL*') as varchar(max))
 			
 			UPDATE bookcontact
 			   SET globalcontactkey = @Participant_globalcontactkey
 			       ,lastuserid=@i_userid
 				   ,lastmaintdate=GETDATE()
 			 WHERE bookcontactkey=@bookcontactkey
 		END
 	END
	ELSE  --given roletype does not exist for title and printing
	BEGIN
	    DECLARE @v_sortorder INT
	    
		SELECT @bookcontactkey=generickey+1 from keys
		
		SELECT @v_sortorder = COALESCE(MAX(sortorder),0) FROM bookcontact where bookkey=@i_bookkey AND printingkey = @printingkey + 1
		
		INSERT INTO bookcontact(bookcontactkey,bookkey,printingkey,globalcontactkey,keyind,sortorder,lastuserid,lastmaintdate)
			VALUES(@bookcontactkey,@i_bookkey,@printingkey,@Participant_globalcontactkey,0,@v_sortorder,@i_userid,GETDATE())
			
		INSERT INTO bookcontactrole(bookcontactkey,rolecode,activeind,workrate,ratetypecode,departmentcode,lastuserid,lastmaintdate)
 			VALUES(@bookcontactkey,@Participant_Role_type,1,NULL,NULL,NULL,@i_userid,GETDATE())
 			
 		IF @DEBUG <> 0 PRINT 'role was not found - insert into bookcontact and bookcontactrole for '
 		IF @DEBUG <> 0 PRINT 'bookkey=' + cast(coalesce(@i_bookkey,'*NULL*') as varchar(max))
 		IF @DEBUG <> 0 PRINT ' AND globalcontactkey=' + cast(coalesce(@Participant_globalcontactkey,'*NULL*') as varchar(max))
 		IF @DEBUG <> 0 PRINT ' AND rolecode =' + cast(coalesce(@Participant_Role_type,'*NULL*') as varchar(max))
	END
	IF @o_error_code < 0
	BEGIN
		RETURN
	END

	IF @DEBUG <> 0 PRINT 'end processing @Participant_Role_type values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @Announced_First_Printing_Estimated>-1
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing estannouncedfirstprint ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from printing'

	SELECT @Announced_First_Printing_Estimated_ORIG = estannouncedfirstprint
	FROM printing
	WHERE bookkey = @i_bookkey

	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @Announced_First_Printing_Estimated <> COALESCE(@Announced_First_Printing_Estimated_ORIG,-1)
	BEGIN
		IF @DEBUG <> 0 PRINT '@Announced_First_Printing_Estimated = ' + coalesce(cast(@Announced_First_Printing_Estimated AS VARCHAR(max)), '*NULL*')

		UPDATE printing
		SET estannouncedfirstprint = @Announced_First_Printing_Estimated
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'printing', 'estannouncedfirstprint' , @i_bookkey, 1, 0, @Announced_First_Printing_Estimated, 'Update', @i_userid, 
				null, 'Estimated Announced First Printing', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'announcedfirstprint has been successfully updated on the bookdetail table'
	END
	
	IF @DEBUG <> 0 PRINT 'end processing @Announced_First_Printing_Estimated values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @Announced_First_Printing_Actual>-1
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing announcedfirstprint ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from printing'

	SELECT @Announced_First_Printing_Actual_ORIG = announcedfirstprint
	FROM printing
	WHERE bookkey = @i_bookkey

	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @Announced_First_Printing_Actual <> COALESCE(@Announced_First_Printing_Actual_ORIG,-1)
	BEGIN
		IF @DEBUG <> 0 PRINT '@Announced_First_Printing_Actual = ' + coalesce(cast(@Announced_First_Printing_Actual AS VARCHAR(max)), '*NULL*')

		UPDATE printing
		SET announcedfirstprint = @Announced_First_Printing_Actual
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'printing', 'announcedfirstprint' , @i_bookkey, 1, 0, @Announced_First_Printing_Actual, 'Update', @i_userid, 
				null, 'Actual Announced First Printing', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'announcedfirstprint has been successfully updated on the bookdetail table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @Announced_First_Printing_Actual values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @Title_Actual <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing @Title_Actual ...'
 	IF @DEBUG <> 0 PRINT 'get the existing values from book'
		
	SELECT @update = 1
	
	SELECT @Title_Actual_ORIG= title
	FROM book
	WHERE bookkey = @i_bookkey
	
	IF @i_update_mode = 'B' AND @Title_Actual_ORIG <> ''
		SELECT @update = 0
	
	IF @update = 1 AND @Title_Actual <> coalesce(@Title_Actual_ORIG,'*NULL*')
	BEGIN
		IF @DEBUG <> 0 PRINT '@Title_Actual = ' + coalesce(cast(@Title_Actual AS VARCHAR(max)), '*NULL*')

		IF @Title_Actual = '&&&'	
			SELECT @Title_Actual = null
		
		UPDATE book
		SET title = @Title_Actual
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'book', 'title' , @i_bookkey, 1, 0, @Title_Actual, 'Update', @i_userid, 
				null, null, @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'Title has been successfully updated on the book table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @Title_Actual values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

--mk20140718> This is a duplicate ... refer to @Audience_CODE
--IF COALESCE(@Audience,-1)>-1
--BEGIN
--	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
--	IF @DEBUG <> 0 PRINT 'start processing audiencecode ...'
--	IF @DEBUG <> 0 PRINT 'get the existing values from bookaudience'

--	SELECT  @count = 1
--		,@Audience_ORIG = audiencecode
--	FROM bookaudience
--	WHERE bookkey = @i_bookkey

--	IF isnull(@count, 0) = 1
--	BEGIN
--		IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

--		IF @Audience <> COALESCE(@Audience_ORIG,-1)
--		BEGIN
--			IF @DEBUG <> 0 PRINT '@Audience = ' + coalesce(cast(@Audience AS VARCHAR(max)), '*NULL*')

--			UPDATE bookaudience
--			SET audiencecode = @Audience
--				,lastuserid=@i_userid
--				,lastmaintdate=GETDATE()
--			WHERE bookkey = @i_bookkey
			
--			--mk20140715> write datadesc to title history
--			declare @Audience_datadesc as varchar(max)
--			select @Audience_datadesc=coalesce(datadesc,'Could not find AudienceCode='+cast(@Audience AS VARCHAR(max))+' in Gentable 460 ') from gentables where tableid=460 and datacode=@Audience

--			exec qtitle_update_titlehistory 'bookaudience', 'audiencecode' , @i_bookkey, 1, 0, @Audience_datadesc, 'Update', @i_userid, 
--					null, null, @o_error_code output, @o_error_desc output

--			IF @DEBUG <> 0 PRINT 'audiencecode has been successfully updated on the bookdetail table'
--		END
--	END
--	ELSE
--	BEGIN
--		IF @DEBUG <> 0 PRINT 'the audiencecode for this title was not found in the bookaudience table'

--		SET @o_error_code = - 2
--		SET @o_error_desc = 'Unable to update audiencecode.  The information for this title was not found in the bookaudience	 table.'
		
--	END

--	IF @o_error_code < 0
--	BEGIN
--		RETURN
--	END

--	IF @DEBUG <> 0 PRINT 'end processing @Audience values ...'
--END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @Language <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing languagecode ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookdetail'
	
	Declare @Language_ISNUMERIC bit
	
	IF ISNUMERIC(@Language) = 1
	BEGIN
		SET @Language_ISNUMERIC=1
		SELECT @Language_ORIG =languagecode
		FROM bookdetail
		WHERE bookkey = @i_bookkey
	END
	ELSE
	BEGIN
		SET @Language_ISNUMERIC=0
		SELECT @Language_ORIG =gt.datadesc
		FROM bookdetail
		INNER JOIN GENTABLES GT on gt.tableid=318 and gt.datacode=languagecode
		WHERE bookkey = @i_bookkey
	END


	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'
	
	IF @Language <> coalesce(@Language_ORIG,'*NULL*')
	BEGIN
		IF @DEBUG < > 0 PRINT '@Language = ' + coalesce(cast(@Language AS VARCHAR(max)), '*NULL*')
			
		declare @Language_CODE as int
		
		IF @Language_ISNUMERIC=1
		BEGIN
			SELECT @Language_CODE=CAST(@Language as integer)
		END
		ELSE
		BEGIN
			SELECT @Language_CODE=datacode from gentables where tableid=318 and datadesc=@Language
		END
		

		UPDATE bookdetail
		SET languagecode = @Language_CODE
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'bookdetail', 'languagecode' , @i_bookkey, 1, 0, @Language_CODE, 'Update', @i_userid, 
				null, 'Language', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'languagecode has been successfully updated on the bookdetail table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @Language values ...'
END --mk20140522> Case: 26341 ESTIMATE: Xart Enhancement 

IF @Fullauthordisplayname <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing Fullauthordisplayname ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookdetail'

	SELECT @update = 1
	
	SELECT @Fullauthordisplayname_ORIG =Fullauthordisplayname
	FROM bookdetail
	WHERE bookkey = @i_bookkey
	
	
	IF @i_update_mode = 'B' AND @Fullauthordisplayname_ORIG <> ''
		SELECT @update = 0

	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @update = 1 AND @Fullauthordisplayname <> coalesce(@Fullauthordisplayname_ORIG,'*NULL*')
	BEGIN
		IF @DEBUG <> 0 PRINT '@Fullauthordisplayname = ' + coalesce(cast(@Fullauthordisplayname AS VARCHAR(max)), '*NULL*')
				
		IF @Fullauthordisplayname = '&&&'	
			SELECT @Fullauthordisplayname = null
		
		UPDATE bookdetail
		SET Fullauthordisplayname = @Fullauthordisplayname
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'bookdetail', 'Fullauthordisplayname' , @i_bookkey, 1, 0, @Fullauthordisplayname, 'Update', @i_userid, 
				null, 'Full Author Display Name', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'Fullauthordisplayname has been successfully updated on the bookdetail table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @Fullauthordisplayname values ...'
END --mk20140529> Case: 27609 New fields for XART import

IF @Editioncode>-1
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing Editioncode ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookdetail'

	SELECT @Editioncode_ORIG =Editioncode
	FROM bookdetail
	WHERE bookkey = @i_bookkey

	IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

	IF @Editioncode <> COALESCE(@Editioncode_ORIG,-1)
	BEGIN
		IF @DEBUG <> 0 PRINT '@Editioncode = ' + coalesce(cast(@Editioncode AS VARCHAR(max)), '*NULL*')
					
		UPDATE bookdetail
		SET Editioncode = @Editioncode
			,lastuserid=@i_userid
			,lastmaintdate=GETDATE()
		WHERE bookkey = @i_bookkey

		exec qtitle_update_titlehistory 'bookdetail', 'Editioncode' , @i_bookkey, 1, 0, @Editioncode, 'Update', @i_userid, 
				null, null, @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'Editioncode has been successfully updated on the bookdetail table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @Editioncode values ...'
END --mk20140529> Case: 27609 New fields for XART import

IF @Series <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing Seriescode ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookdetail'
		
	--this one is a little different because the gentable lookup is either alternatedesc1 or datadesc - need to find out how it's joining first
	DECLARE @Series_CODE as int=-1
	DECLARE @SeriesLookUpField as varchar(max)=''
	
	SELECT @Series_CODE=datacode from gentables where tableid=327 and alternatedesc1=@Series
	IF @Series_CODE >-1 
	BEGIN
		SET @SeriesLookUpField='alternatedesc1'
	END 
	ELSE BEGIN
		SELECT @Series_CODE=datacode from gentables where tableid=327 and datadesc=@Series
		SET @SeriesLookUpField='datadesc'
	END
	IF @Series_CODE >-1  
	BEGIN 
		IF @SeriesLookUpField='alternatedesc1'
		BEGIN
			SELECT @Series_ORIG =gt.alternatedesc1
			FROM bookdetail
			INNER JOIN GENTABLES GT on gt.tableid=327 and gt.datacode=Seriescode
			WHERE bookkey = @i_bookkey			
		END ELSE BEGIN
			SELECT @Series_ORIG =gt.datadesc
			FROM bookdetail
			INNER JOIN GENTABLES GT on gt.tableid=327 and gt.datacode=Seriescode
			WHERE bookkey = @i_bookkey
		END

		IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

		IF @Series <> COALESCE(@Series_ORIG,'*NULL*	')
		BEGIN
			IF @DEBUG <> 0 PRINT '@Series = ' + coalesce(cast(@Series AS VARCHAR(max)), '*NULL*')
				
			UPDATE bookdetail
			SET Seriescode = @Series_CODE
				,lastuserid=@i_userid
				,lastmaintdate=GETDATE()
			WHERE bookkey = @i_bookkey

			exec qtitle_update_titlehistory 'bookdetail', 'Seriescode' , @i_bookkey, 1, 0, @Series_CODE, 'Update', @i_userid, 
					null, null, @o_error_code output, @o_error_desc output

			IF @DEBUG <> 0 PRINT 'Seriescode has been successfully updated on the bookdetail table'
		END
	END ELSE BEGIN
		IF @DEBUG <> 0
			PRINT 'the Seriescode for this title was not found in the gentable (327)'

		SET @o_error_code = - 2
		SET @o_error_desc = 'Unable to update Seriescode.  The Seriescode for this title was not found'
	END

	IF @o_error_code < 0
	BEGIN
		RETURN
	END
			
	IF @DEBUG <> 0 PRINT 'end processing @Series values ...'
END --mk20140529> Case: 27609 New fields for XART import
	
IF @Internal_category <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing Internal_categorycode ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookcategory'
		
	DECLARE @Internal_category_CODE as int=-1
	SELECT @Internal_category_CODE=datacode from gentables where tableid=317 and datadesc=@Internal_category

	IF @Internal_category_CODE >-1  
	BEGIN 
		--See if this category already exists in bookcategory
		-- ... INSERT if it DOES NOT
		SELECT @Internal_category_ORIG =gt.datadesc
		FROM bookcategory
		INNER JOIN GENTABLES GT on gt.tableid=317 and gt.datacode=categorycode
		WHERE bookkey = @i_bookkey and gt.datadesc=@Internal_category
		
		IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

		IF @Internal_category_ORIG is null
		BEGIN
			IF @DEBUG <> 0 PRINT '@Internal_category = ' + coalesce(cast(@Internal_category AS VARCHAR(max)), '*NULL*')
			
			INSERT INTO bookcategory(bookkey,categorycode,sortorder,lastuserid,lastmaintdate)
			SELECT	@i_bookkey
					,@Internal_category_CODE
					,(select MAX(sortorder)+1 from bookcategory where bookkey = @i_bookkey)--get sort order
					,@i_userid
					,getdate()

			--mk20140715> write datadesc to title history
			exec qtitle_update_titlehistory 'bookcategory', 'categorycode' , @i_bookkey, 1, 0, @Internal_category, 'Update', @i_userid, 
					null, 'Internal Category', @o_error_code output, @o_error_desc output

			IF @DEBUG <> 0 PRINT 'Internal_categorycode has been successfully updated on the bookdetail table'
		END
	END ELSE BEGIN
		IF @DEBUG <> 0
			PRINT 'the Internal_categorycode for this title was not found in the gentable (317)'

		SET @o_error_code = - 2
		SET @o_error_desc = 'Unable to update Internal_categorycode.  The information for this title was not found in the bookcategory table.'
		
	END

	IF @o_error_code < 0
	BEGIN
		RETURN
	END
			
	IF @DEBUG <> 0 PRINT 'end processing @Internal_category values ...'
END --mk20140529> Case: 27609 New fields for XART import

IF @Audience_codes <> ''
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing Audience_codescode ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookcategory'
		
	DECLARE @Audience_codes_CODE as int=-1
	SELECT @Audience_codes_CODE=datacode from gentables where tableid=460 and datadesc=@Audience_codes
	
	IF @Audience_codes_CODE >-1  
	BEGIN 
		--See if this code already exists in bookcategory
		-- ... INSERT if it DOES NOT
		SELECT @Audience_codes_ORIG =gt.datadesc
		FROM bookaudience
		INNER JOIN GENTABLES GT on gt.tableid=460 and gt.datacode=audiencecode
		WHERE bookkey = @i_bookkey and gt.datadesc=@Audience_codes
		
		IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'

		IF @Audience_codes_ORIG is null
		BEGIN
			IF @DEBUG <> 0 PRINT '@Audience_codes = ' + coalesce(cast(@Audience_codes AS VARCHAR(max)), '*NULL*')
			INSERT INTO bookaudience(bookkey,audiencecode,sortorder,lastuserid,lastmaintdate)
			SELECT	@i_bookkey
					,@Audience_codes_CODE
					,(select MAX(sortorder)+1 from bookaudience where bookkey = @i_bookkey)--get sort order
					,@i_userid
					,getdate()

			exec qtitle_update_titlehistory 'bookaudience', 'audiencecode' , @i_bookkey, 1, 0, @Audience_codes, 'Update', @i_userid, 
					null, NULL, @o_error_code output, @o_error_desc output

			IF @DEBUG <> 0 PRINT 'Audience_codescode has been successfully updated on the bookdetail table'
		END
	END ELSE BEGIN
		IF @DEBUG <> 0
			PRINT 'the Audience_codescode for this title was not found in the gentable (460)'

		SET @o_error_code = - 2
		SET @o_error_desc = 'Unable to update Audience_codescode.  The information for this title was not found in the bookaudience table.'
		
	END

	IF @o_error_code < 0
	BEGIN
		RETURN
	END
			
	IF @DEBUG <> 0 PRINT 'end processing @Audience_codes values ...'
END --mk20140529> Case: 27609 New fields for XART import

IF @ProjectedSalesAct > -2 --(misckey=163)
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing ProjectedSalesAct ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookmisc'
		
	--See if this code already exists in bookmisc
	-- ... INSERT if it DOES NOT
	declare @ProjectedSalesAct_ORIG int
	declare @ProjectedSalesAct_COUNT int=0
	
	SELECT @ProjectedSalesAct_COUNT=1,@ProjectedSalesAct_ORIG=longvalue
	FROM bookmisc 
	WHERE misckey in (163) and bookkey=@i_bookkey
	
	IF @ProjectedSalesAct_COUNT >0
	BEGIN 
		IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'
		IF coalesce(@ProjectedSalesAct_ORIG,-1)<>@ProjectedSalesAct
		BEGIN
			if @ProjectedSalesAct=-1 set @ProjectedSalesAct=null
			IF @DEBUG <> 0 PRINT '@ProjectedSalesAct = ' + coalesce(cast(@ProjectedSalesAct AS VARCHAR(max)), '*NULL*')
			
			UPDATE bookmisc
			SET longvalue=@ProjectedSalesAct
				,lastuserid=@i_userid
				,lastmaintdate=GETDATE()
			WHERE misckey in (163) and bookkey=@i_bookkey
			
			exec qtitle_update_titlehistory 'bookmisc', 'longvalue' , @i_bookkey, 1, 0, @ProjectedSalesAct, 'Update', @i_userid, 
					null, 'Actual Projected Sales', @o_error_code output, @o_error_desc output

			IF @DEBUG <> 0 PRINT 'ProjectedSalesActcode has been successfully updated on the bookmisc table'
		END
	END 
	ELSE 
	BEGIN
		IF @DEBUG <> 0 PRINT '@ProjectedSalesAct = ' + coalesce(cast(@ProjectedSalesAct AS VARCHAR(max)), '*NULL*')
		
		INSERT INTO bookmisc(bookkey,misckey,longvalue,floatvalue,textvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
		SELECT	@i_bookkey
				,163
				,@ProjectedSalesAct
				,null
				,null
				,@i_userid
				,getdate()
				,0
		exec qtitle_update_titlehistory 'bookmisc', 'longvalue' , @i_bookkey, 1, 0, @ProjectedSalesAct, 'Update', @i_userid, 
				null, 'Actual Projected Sales', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'ProjectedSalesActcode has been successfully inserted into the bookmisc table'
	END
			
	IF @DEBUG <> 0 PRINT 'end processing @ProjectedSalesAct values ...'
END --mk20140529> Case: 27609 New fields for XART import


IF @ProjectedSalesEst > -2 --(misckey=162)
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing ProjectedSalesEst ...'
	IF @DEBUG <> 0 PRINT 'get the existing values from bookmisc'
		
	--See if this code already exists in bookmisc
	-- ... INSERT if it DOES NOT
	declare @ProjectedSalesEst_ORIG int
	declare @ProjectedSalesEst_COUNT int=0
	
	SELECT @ProjectedSalesEst_COUNT=1,@ProjectedSalesEst_ORIG=longvalue
	FROM bookmisc 
	WHERE misckey in (162) and bookkey=@i_bookkey
	
	IF @ProjectedSalesEst_COUNT>0
	BEGIN 
		IF @DEBUG <> 0 PRINT 'record found ... now compare original and new values to see if anything changed'
		IF coalesce(@ProjectedSalesEst_ORIG,-1)<>@ProjectedSalesEst
		BEGIN
			if @ProjectedSalesEst=-1 set @ProjectedSalesEst=null
			IF @DEBUG <> 0 PRINT '@ProjectedSalesEst = ' + coalesce(cast(@ProjectedSalesEst AS VARCHAR(max)), '*NULL*')
			
			UPDATE bookmisc
			SET longvalue=@ProjectedSalesEst
				,lastuserid=@i_userid
				,lastmaintdate=GETDATE()
			WHERE misckey in (162) and bookkey=@i_bookkey
			
			exec qtitle_update_titlehistory 'bookmisc', 'longvalue' , @i_bookkey, 1, 0, @ProjectedSalesEst, 'Update', @i_userid, 
					null, 'Estimated Projected Sales', @o_error_code output, @o_error_desc output

			IF @DEBUG <> 0 PRINT 'ProjectedSalesEstcode has been successfully updated on the bookmisc table'
		END
	END 
	ELSE 
	BEGIN
		IF @DEBUG <> 0 PRINT '@ProjectedSalesEst = ' + coalesce(cast(@ProjectedSalesEst AS VARCHAR(max)), '*NULL*')
		
		INSERT INTO bookmisc(bookkey,misckey,longvalue,floatvalue,textvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
		SELECT	@i_bookkey
				,162
				,@ProjectedSalesEst
				,null
				,null
				,@i_userid
				,getdate()
				,0

		exec qtitle_update_titlehistory 'bookmisc', 'longvalue' , @i_bookkey, 1, 0, @ProjectedSalesEst, 'Update', @i_userid, 
				null, 'Estimated Projected Sales', @o_error_code output, @o_error_desc output
		IF @DEBUG <> 0 PRINT 'ProjectedSalesEstcode has been successfully inserted into the bookmisc table'
	END
			
	IF @DEBUG <> 0 PRINT 'end processing @ProjectedSalesEst values ...'
END --mk20140529> Case: 27609 New fields for XART import

--
IF @never_send_2_elo =1
BEGIN
	IF @DEBUG <> 0 PRINT CHAR(13) + CHAR(10)
	IF @DEBUG <> 0 PRINT 'start processing @never_send_2_elo ...'

	BEGIN
		IF @DEBUG <> 0 PRINT '@never_send_2_elo = ' + coalesce(cast(@never_send_2_elo AS VARCHAR(max)), '*NULL*')
		
		If not exists (Select * from bookedistatus where bookkey = @i_bookkey)
		begin
			insert into bookedistatus (edipartnerkey,bookkey,printingkey,edistatuscode,lastuserid,lastmaintdate,previousedistatuscode)
			Select 1, @i_bookkey, 1, 8, @i_userid,getdate(), 0
			
		end 
		else
		begin
			Select @i_previousedistatuscode = ISNULL(previousedistatuscode,0)
			from bookedistatus where bookkey = @i_bookkey
			
			UPDATE bookedistatus
			SET edistatuscode=8
				,previousedistatuscode = @i_previousedistatuscode
				,lastuserid=@i_userid
				,lastmaintdate=GETDATE()
			WHERE bookkey = @i_bookkey
			
			UPDATE bookedipartner
			SET Sendtoeloquenceind =0
				,lastuserid=@i_userid
				,lastmaintdate=GETDATE()
			WHERE bookkey = @i_bookkey
			
			
		end 

		exec qtitle_update_titlehistory 'bookedistatus', 'edistatuscode' , @i_bookkey, 1, 0, 8, 'Update', @i_userid, 
				null, 'edistatuscode', @o_error_code output, @o_error_desc output

		IF @DEBUG <> 0 PRINT 'edistatuscode has been successfully updated/inserted on the bookedistatus table'
	END

	IF @DEBUG <> 0 PRINT 'end processing @never_send_2_elo values ...'
END --mk20140529> Case: 27609 New fields for XART import

---- 12/10/15 - KB - Case 35244
if @Season <> ''
begin
	select @update = 1

	select  @Season_ORIG = isnull(seasonkey,0)
	from printing p
	where p.bookkey = @i_bookkey
	  and printingkey = 1

	if @i_update_mode = 'B' and @Season_ORIG > 0
		select @update = 0

	if @update = 1 begin
		if @Season = '&&&'	
		begin
			select @new_code = null
		end
		else
		begin
			select top 1 @new_code = seasonkey
			  from season
			 where lower(seasondesc) = lower(ltrim(rtrim(@Season))) 
			   and activeind = 1

			if @new_code is null
			begin
				SET @o_error_code = -2
				SET @o_error_desc = 'Unable to update printing table.  Season value of '+@Season +' not found.'
				RETURN
			end
		end

		if isnull(@new_code,0) <> @Season_ORIG 
		begin
			update printing
			   set seasonkey = @new_code,
			       lastuserid = @i_userid,
			       lastmaintdate = getdate()
			where bookkey = @i_bookkey
              and printingkey = 1

			SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
			IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
				SET @o_error_code = -1
				SET @o_error_desc = 'Unable to update season on printing table.   Error #' + cast(@v_error as varchar(20))
				RETURN
			END 

			
			exec qtitle_update_titlehistory 'printing', 'seasonkey' , @i_bookkey, 1, 0, @Season, 'Update', @i_userid, 
				null, null, @o_error_code output, @o_error_desc output
		end
	end
end
---- 12/10/15 - KB - Case 35244 Season

---- 12/10/15 - KB - Case 35244 Jacket vendor
if @JacketVendor <> ''
begin
	if @DEBUG<>0 print char(13)+char(10)
	if @DEBUG<>0 print 'start processing @JacketVendor ...'
	
	if @DEBUG<>0 print 'see if the @JacketVendor is a number or text'
	if isnumeric(@JacketVendor)= 1 begin
		if @DEBUG<>0 print 'if this is a number it could either be the vendorid (which could be alphanumeric)'
			select @JacketVendorKey = VendorKey 
		      from vendor
		     where vendorid = @JacketVendor  
		
		if isnull(@JacketVendorKey,-1)=-1 begin
			if @DEBUG<>0 print ' ... or the VendorKey'
				select @JacketVendorKey = VendorKey 
			      from vendor
			     where VendorKey = cast(@JacketVendor as int)
		end
	end
	else begin
		if @DEBUG<>0 print 'this is not a number therefore it is either a name of vendorid'
			select @JacketVendorKey = VendorKey 
		      from vendor
		     where name = @JacketVendor  
		        or vendorid = @JacketVendor  
	end 
	
	if @DEBUG<>0 print 'now make sure a valid vendor key was found'
	if isnull(@JacketVendorKey,-1)<>-1 begin
		select @count = count(*)
		  from jacketspecs
		 where printingkey = 1
		   and bookkey = @i_bookkey

		if @count>0 begin
		    
			update jacketspecs
			   set vendorkey = @JacketVendorKey,
			       lastuserid = @i_userid,
		           lastmaintdate = getdate()
			 where printingkey = 1
			   and bookkey = @i_bookkey

	        exec qtitle_update_titlehistory 'jacketspecs', 'vendorkey' , @i_bookkey, 1, 0, @JacketVendor, 'Update', @i_userid, 
				null, null, @o_error_code output, @o_error_desc output
		end
		else begin
			insert into jacketspecs(vendorkey, printingkey, bookkey, lastuserid, lastmaintdate)
			values(@JacketVendorKey , 1, @i_bookkey, @i_userid, GETDATE())

            exec qtitle_update_titlehistory 'jacketspecs', 'vendorkey' , @i_bookkey, 1, 0, @JacketVendor, 'Insert', @i_userid, 
				null, 'Jacket Vendor', @o_error_code output, @o_error_desc output
		end
		if @DEBUG<>0 print 'VendorKey has been successfully updated on the jacketspecs table'
	end
	else begin
		if @DEBUG<>0 print 'the vendor was not found in the vendor table'
		SET @o_error_code = -2
		SET @o_error_desc = 'Unable to update Jacket Vendor.  The vendor was not found in the vendor table.'
	end

	IF @o_error_code < 0 BEGIN
		return
	end
	if @DEBUG<>0 print 'end processing @JacketVendor  ...'
end
---- 12/10/15 - KB - Case 35244 Jacket vendor

---- 12/10/15 - KB - Case 35244 Pub Month and Pub Year
DECLARE @update_pubmonth int
DECLARE @update_pubmonthcode int
DECLARE @Pubdate_Str varchar(20)
DECLARE @PubMonthCode_ORIG INT

SET @update_pubmonth = 0
SET @update_pubmonthcode = 0

if @PubMonth <> '' begin
    /* Convert string into month code */
    SET @PubMonthCode = CONVERT(int,@PubMonth)
    IF LEN(@PubMonth) = 1 
		SELECT @PubMonth  = '0' + @PubMonth
	ELSE
		SELECT @PubMonth  = @PubMonth
	--CASE lower(@PubMonth)
	--  WHEN 'january'  THEN 1
	--  WHEN 'february' THEN 2
	--  WHEN 'march'    THEN 3
	--  WHEN 'april'    THEN 4
	--  WHEN 'may'      THEN 5
	--  WHEN 'june'     THEN 6
	--  WHEN 'july'     THEN 7
	--  WHEN 'august'   THEN 8
	--  WHEN 'september' THEN 9
	--  WHEN 'october'  THEN 10
	--  WHEN 'november' THEN 11
	--  WHEN 'december' THEN 12
	--END
end

select @PubMonth_Year_ORIG  = ISNULL(pubmonth,''), @PubMonthCode_ORIG = ISNULL(pubmonthcode,0)
  from printing p
 where p.bookkey = @i_bookkey
   and printingkey = 1
   
select @update = 1
		
if @i_update_mode = 'B' and @PubMonth_Year_ORIG <> ''
	select @update = 0

if @update = 1 BEGIN
	if @PubYear <> '' BEGIN
		if @PubMonth = '' begin  -- Pub Month is null
			IF @PubMonth_Year_ORIG <> '' AND @PubMonthCode_ORIG > 0 begin
				SET @PubMonth_Year = convert(datetime,(substring(convert(varchar,@PubMonth_Year_ORIG,101),1,2) + '/' + CONVERT(varchar,@PubMonthCode_ORIG) +'/' + @PubYear),101)
				SET @update_pubmonth = 1
			end
			ELSE IF @PubMonth_Year_ORIG <> '' AND @PubMonthCode_ORIG = 0 begin
				SET @PubMonth_Year = convert(datetime,(substring(convert(varchar,@PubMonth_Year_ORIG,101),1,2) + '/01/' + @PubYear),101)
				SET @update_pubmonth = 1
			END
			ELSE IF @PubMonth_Year_ORIG = '' AND @PubMonthCode_ORIG > 0 begin
				SET @Pubdate_Str = @PubYear + '/' + CONVERT(varchar,@PubMonthCode_ORIG) + '/' +  '01'
				SET @PubMonth_Year = convert(datetime,(@Pubdate_Str),101)
				SET @update_pubmonth = 1
			END
			ELSE begin
				SET @PubMonth_Year = convert(datetime,('01' +'/01/' + @PubYear),101)
				SET @update_pubmonth = 1
			END	
			SET @update_pubmonth = 1
		end
		if @PubMonth <> '' begin  -- Pub Month and Pub Year are populated
		    SET @Pubdate_Str = @PubMonth + '/01/' + @PubYear
			SET @PubMonth_Year = convert(datetime,(@Pubdate_Str),101)
			SET @update_pubmonthcode = 1
			SET @update_pubmonth = 1
		end
	END
	ELSE BEGIN  -- Pub Year is null
		if @PubMonth = '' begin  -- Pub Month and Pub Year are both null
			if @PubMonth_Year_ORIG = ''
				select @update = 0
				SET @update_pubmonthcode = 0
				SET @update_pubmonth = 0
		end
		if @PubMonth <> '' begin  -- Pub Month is populated
			if @PubMonth_Year_ORIG IS NULL begin
				SET @Pubdate_Str = @PubMonth + '/01/' + '1900'
				SET @PubMonth_Year = convert(datetime,(@Pubdate_Str),101)
				SET @update_pubmonthcode = 1
			end
			else begin
			    SET @Pubdate_Str = @PubMonth + '/01/' + substring(convert(varchar,@PubMonth_Year_ORIG,101),7,4)
				SET @PubMonth_Year = convert(datetime,(@Pubdate_Str),101)
				SET @update_pubmonthcode = 1
				SET @update_pubmonth = 1
			end
		end
	END
END

if @update = 1 begin
	if @update_pubmonthcode = 1 AND @update_pubmonth = 1 begin
		UPDATE printing
		   SET pubmonthcode = @PubMonthCode,
		       pubmonth = @PubMonth_Year,
		       lastuserid = @i_userid,
		       lastmaintdate = getdate()
		 WHERE bookkey = @i_bookkey
           AND printingkey = 1 
         
         exec qtitle_update_titlehistory 'printing', 'pubmonthcode' , @i_bookkey, 1, 0, @PubMonthCode, 'Update', @i_userid, 
				null, null, @o_error_code output, @o_error_desc output
	end
	else if @update_pubmonthcode = 1 AND @update_pubmonth = 0 begin
		UPDATE printing
		   SET pubmonthcode = @PubMonthCode,
		       lastuserid = @i_userid,
		       lastmaintdate = getdate()
		 WHERE bookkey = @i_bookkey
           AND printingkey = 1 
           
        exec qtitle_update_titlehistory 'printing', 'pubmonthcode' , @i_bookkey, 1, 0, @PubMonthCode, 'Update', @i_userid, 
				null, null, @o_error_code output, @o_error_desc output
	end
	else if @update_pubmonthcode = 0 AND @update_pubmonth = 1 begin
		UPDATE printing
		   SET pubmonth = @PubMonth_Year,
		       lastuserid = @i_userid,
		       lastmaintdate = getdate()
		 WHERE bookkey = @i_bookkey
           AND printingkey = 1 
	end
end
---- 12/10/15 - KB - Case 35244 Pub Month

--comment procedure will check if complete data exists
exec hmco_import_from_SAP_comment @i_bookkey, @printingkey, @i_update_mode, @i_userid, @i_rowid, @o_error_code output, @o_error_desc output

IF @o_error_code < 0 BEGIN
	return
end

update hmco_import_into_pss
set is_processed = 'Y',
processed_date = getdate(),
comments = null
where bookkey = @i_bookkey
and row_id = @i_rowid

SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
IF @v_error <> 0 or @v_rowcount = 0 BEGIN 
	SET @o_error_code = -1
	SET @o_error_desc = 'Unable to update the processed flags for this bookkey.   Error #' + cast(@v_error as varchar(20))
	RETURN
END 

END



GO


