IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qcs_get_product]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qcs_get_product]
GO
CREATE PROCEDURE [dbo].[qcs_get_product](@bookkey int)
AS
BEGIN
    DECLARE @customerKeyStr VARCHAR(15)
    DECLARE @bookKeyStr VARCHAR(15)
    DECLARE @productTag VARCHAR(35)
    DECLARE @amazonbrandcodeind	int
    DECLARE	@amazonbrandcode	varchar(255)
	DECLARE @AOPconflictsource varchar(50)
	DECLARE @mediatag		varchar(50)
    DECLARE @SendRightsToCloud  INT
	DECLARE @defaultweightuom	varchar(25)

--this client option controls whether we should pull any print prices from the print isbn for ebooks (1/'print') or pull them only from the AOP price type on the ebook (2/'ebook')
	select @AOPconflictsource = case when optionvalue = 2 then 'ebook' else 'print' end
	from clientoptions
	where optionid = 113

	if @AOPconflictsource is null
		set @AOPconflictsource = 'print'

  -- Send Rights to Cloud client option  114
  -- 1 - (default) use standard prioritization for rights 
  -- 2 - use new territories with countries
  -- 3 - use Rights Comments
  -- 5 - use legacy territory

  SELECT @SendRightsToCloud = optionvalue
    FROM clientoptions
   WHERE optionid = 114

	IF @SendRightsToCloud IS NULL
		SET @SendRightsToCloud = 1

	select @mediatag = eloquencefieldtag
	from bookdetail bd
	join gentables g
	on bd.mediatypecode = g.datacode
	and g.tableid = 312
	and bd.bookkey = @bookkey

    SELECT @customerKeyStr = eloqcustomerid 
        FROM book b, customer c WHERE b.bookkey=@bookkey AND b.elocustomerkey=c.customerkey

    SET @bookKeyStr = CAST(@bookkey AS VARCHAR(15))
    SET @productTag = @customerKeyStr + '-' + @bookKeyStr

    /* Use this logic before querying for Imprint / Publisher Name */
    DECLARE @ImprintName nvarchar(200)
    DECLARE @PublisherName nvarchar(200)

    SELECT    
        @ImprintName = sg1.datadesc
    FROM      
        bookmisc AS bm INNER JOIN
        bookmiscitems AS bmi ON bm.misckey = bmi.misckey INNER JOIN
        gentables AS g1 ON bmi.eloquencefieldidcode = g1.datacode AND g1.eloquencefieldtag = 'DPIDXBIZEXTIMPRNT' AND g1.tableid = 560 INNER 	JOIN
        gentables AS g2 ON bmi.datacode = g2.datacode AND g2.tableid = 525 INNER JOIN
        subgentables AS sg1 ON bm.longvalue = sg1.datasubcode AND sg1.tableid = 525 AND sg1.datacode = g2.datacode
    WHERE     
        bookkey = @bookkey and bmi.sendtoeloquenceind = 1 and bm.sendtoeloquenceind = 1
    
    SELECT    
        @PublisherName = sg1.datadesc
    FROM      
        bookmisc AS bm INNER JOIN
        bookmiscitems AS bmi ON bm.misckey = bmi.misckey INNER JOIN
        gentables AS g1 ON bmi.eloquencefieldidcode = g1.datacode AND g1.eloquencefieldtag = 'DPIDXBIZEXTPBLSHR' AND g1.tableid = 560 INNER 	JOIN
        gentables AS g2 ON bmi.datacode = g2.datacode AND g2.tableid = 525 INNER JOIN
        subgentables AS sg1 ON bm.longvalue = sg1.datasubcode AND sg1.tableid = 525 AND sg1.datacode = g2.datacode
    WHERE     
        bookkey = @bookkey and bmi.sendtoeloquenceind = 1 and bm.sendtoeloquenceind = 1

    
    select @amazonbrandcodeind = optionvalue
    from clientoptions
    where optionid = 112

    if (isnull(@amazonbrandcodeind,0) = 1) or (isnull(@amazonbrandcodeind,0) = 2 and @mediatag <> 'EP')
    begin
        select 
            @amazonbrandcode = o.amazonbrandcode
        from 
            filterorglevel fl join 
            orgentry o	on fl.filterorglevelkey = o.orglevelkey	join 
            bookorgentry bo	on o.orgentrykey = bo.orgentrykey
        where 
            bo.bookkey = @bookkey	and 
            fl.filterkey = 35	and 
            amazonbrandcode is not null and amazonbrandcode <> ''
    end

	select @defaultweightuom = eloquencefieldtag 
	FROM gentables g
	join clientdefaults cd
	on g.datacode = cd.clientdefaultvalue
	and g.tableid = 613
	and cd.clientdefaultid = 51
	WHERE deletestatus='N' and exporteloquenceind = 1


    /************************************************************************************
     ** This procedure is used by TMM to get all Title or Product data to send to the
     ** Cloud.  The order of SELECTed or returned resuslts is important.  TMM expects
     ** to receive certain pieces of data in each SELECT statement.  
     ** 
     ** There are a few SELECT statements that return only a single value.  This will 
     ** translate into a List of Strings for the Cloud.  Make sure these statements never 
     ** return more than 1 column.
     **
     ** For all SELECT statements that return more than one column, the name is used
     ** by TMM to map these to Cloud fields.  For instance 
     ** gm.eloquencefieldtag AS MediaTag would map to Cloud field in Product named
     ** MediaTag.
     **
     ** As far as associating all child structures with the parent Product, this is
     ** done automatically when the message is sent to the Cloud.  So there is no need
     ** to return a ProductId, bookkey, or any other reference to the parent Product or
     ** book.  For example, for ProductContributor, we do not need to return the 
     ** bookkey or ProductId of the parent book or Product.  When the message is processed
     ** by the Cloud it will assign the ProductId of the parent Product automatically
     ** before saving to the Cloud database.
     **
     ** A NOTE about Ids:  Each Select statement that returns more than 1 column, gets
     ** translated to a Cloud structure that has common elements such as Id and Tag.
     ** A limitation of Linq to SQL forces us to return a unique Id per row.  So in
     ** each case we return NEWID() AS Id.  This is just temporary.  The real Id is
     ** generated or looked up when the structure makes it to the Cloud.
     ************************************************************************************/
    
    /************************************************************************************
     ** Product - This get's translated to Product in the Cloud.  There should be only
     **           one row returned.
     ************************************************************************************/
    SELECT TOP 1
        CAST(i.cloudproductid AS UNIQUEIDENTIFIER) AS Id,
        @productTag AS Tag,
        b.workkey AS WorkKey,
        bd.additionaleditinfo AS AdditionalEditionInfo,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=552 AND datacode=p.barcodeid1 AND deletestatus='N' and exporteloquenceind = 1) AS Barcode1IndicatorTag,
        (SELECT TOP 1 eloquencefieldtag FROM subgentables 
            WHERE tableid=552 AND datacode=p.barcodeid1 AND datasubcode=p.barcodeposition1 AND deletestatus='N' and exporteloquenceind = 1) AS Barcode1PositionTag,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=552 AND datacode=p.barcodeid2 AND deletestatus='N' and exporteloquenceind = 1) AS Barcode2IndicatorTag,
        (SELECT TOP 1 eloquencefieldtag FROM subgentables 
            WHERE tableid=552 AND datacode=p.barcodeid2 AND datasubcode=p.barcodeposition2 AND deletestatus='N' and exporteloquenceind = 1) AS Barcode2PositionTag,
        i.isbn10 AS Isbn10,
        i.ean AS Ean,
        i.ean13 AS Ean13,
        i.upc AS Upc,
        i.lccn AS Lccn,
        bd.editiondescription AS EditionDescription,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=557 AND datacode=bd.editionnumber AND deletestatus='N' and exporteloquenceind = 1) AS EditionNumber,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=200 AND datacode=bd.editioncode AND deletestatus='N' and exporteloquenceind = 1) AS EditionTag,
        b.subtitle AS SubTitle,
        b.title AS Title,
        bd.titleprefix AS TitlePrefix,
        (SELECT TOP 1 CAST(bo.orgentrykey AS VARCHAR(25)) FROM bookorgentry bo, customer c
            WHERE bo.orglevelkey = c.elopublisherorglevelkey AND bo.bookkey = bd.bookkey AND c.customerkey = b.elocustomerkey) AS PublisherKey,
        (SELECT TOP 1 CASE 
                WHEN @PublisherName != '' OR @PublisherName != null THEN @PublisherName
                WHEN c.elopublisherusealt1ind = 1 AND o.altdesc1 IS NOT NULL AND LTRIM(o.altdesc1) <> '' THEN o.altdesc1		  
                WHEN c.elopublisherusealt2ind = 1 and o.altdesc2 IS not NULL and LTRIM(o.altdesc2) <> '' THEN o.altdesc2
                ELSE o.orgentrydesc END
            FROM bookorgentry bo, customer c, orgentry o
            WHERE 
                bo.orglevelkey = c.elopublisherorglevelkey AND 
                bo.orglevelkey = o.orglevelkey AND 
                bo.orgentrykey = o.orgentrykey AND 
                bo.bookkey = bd.bookkey AND
                c.customerkey = b.elocustomerkey) AS PublisherName,
        (SELECT TOP 1 CAST(bo.orgentrykey AS VARCHAR(25)) FROM bookorgentry bo, customer c 
            WHERE bo.orglevelkey = c.eloimprintorglevelkey AND bo.bookkey = bd.bookkey AND c.customerkey = b.elocustomerkey) AS ImprintKey,
        (SELECT TOP 1 CASE 
                WHEN @ImprintName != '' OR @ImprintName != null THEN @ImprintName 
                WHEN c.eloimprintusealt1ind = 1 and o.altdesc1 IS not NULL and LTRIM(o.altdesc1) <> '' THEN o.altdesc1		  
                WHEN c.eloimprintusealt2ind = 1 and o.altdesc2 IS not NULL and LTRIM(o.altdesc2) <> '' THEN o.altdesc2
                ELSE o.orgentrydesc END
            FROM bookorgentry bo, customer c, orgentry o 
            WHERE 
                bo.orglevelkey = c.eloimprintorglevelkey AND
                bo.orglevelkey = o.orglevelkey AND 
                bo.orgentrykey = o.orgentrykey AND
                bo.bookkey = bd.bookkey AND
                c.customerkey = b.elocustomerkey) AS ImprintName,
        bd.fullauthordisplayname AS FullAuthorDisplayName,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=312 AND datacode=bd.mediatypecode AND deletestatus='N' AND exporteloquenceind=1) AS MediaTag,
        (SELECT TOP 1 eloquencefieldtag FROM subgentables 
            WHERE tableid=312 AND datacode=bd.mediatypecode AND datasubcode=bd.mediatypesubcode AND deletestatus='N' AND exporteloquenceind=1) AS FormatTag,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=314 AND datacode=bd.bisacstatuscode AND deletestatus='N' and exporteloquenceind = 1) AS BisacStatusTag,
        (SELECT TOP 1 eloquencefieldtag FROM subgentables 
            WHERE tableid=314 AND datacode=bd.bisacstatuscode AND datasubcode = bd.prodavailability and deletestatus='N' and exporteloquenceind = 1) AS ProductAvailabilityTag,
        (SELECT TOP 1 CASE WHEN alternatedesc1 IS NULL OR LTRIM(alternatedesc1) = '' THEN datadesc ELSE alternatedesc1 END 
            FROM gentables WHERE tableid=327 AND datacode=bd.seriescode AND deletestatus='N' ) AS Series,
        cast(dbo.rpt_get_best_page_count (bd.bookkey, 1) as int) AS PageCount,
        (SELECT TOP 1 numcassettes FROM audiocassettespecs WHERE bookkey=b.bookkey AND printingkey=1) AS NumberOfAudioUnits,
        (SELECT TOP 1 totalruntime FROM audiocassettespecs WHERE bookkey=b.bookkey AND printingkey=1) AS TotalRuntime,
        case when isnull(bd.gradehighupind,0) = 0 and isnull(bd.gradehigh,'') = '' 
             then CASE 
                        WHEN bd.gradelow = '0K' THEN 'K'
                        WHEN bd.gradelow = '0P' THEN 'P'
                        WHEN bd.gradelow = 'K' THEN 'K'
                        WHEN bd.gradelow = 'P' THEN 'P'
                        WHEN bd.gradelow = '' THEN NULL
                        WHEN bd.gradelow is NULL THEN NULL
                        WHEN isnumeric(bd.gradelow) = 0 THEN NULL
                        ELSE CAST(CAST(bd.gradelow AS INT) AS VARCHAR(2)) END
             else CASE 
                        WHEN bd.gradehigh = '0K' THEN 'K'
                        WHEN bd.gradehigh = '0P' THEN 'P'
                        WHEN bd.gradehigh = 'K' THEN 'K'
                        WHEN bd.gradehigh = 'P' THEN 'P'
                        WHEN bd.gradehigh = '' THEN NULL
                        WHEN bd.gradehigh is NULL THEN NULL
                        WHEN isnumeric(bd.gradehigh) = 0 THEN NULL
                        ELSE CAST(CAST(bd.gradehigh AS INT) AS VARCHAR(2)) END END AS GradeHigh,
        case when isnull(bd.gradelowupind,0) = 0 and isnull(bd.gradelow,'') = '' 
            then CASE
                        WHEN bd.gradehigh = '0K' THEN 'K'
                        WHEN bd.gradehigh = '0P' THEN 'P'
                        WHEN bd.gradehigh = 'K' THEN 'K'
                        WHEN bd.gradehigh = 'P' THEN 'P'
                        WHEN bd.gradehigh = '' THEN NULL
                        WHEN bd.gradehigh is NULL THEN NULL
                        WHEN isnumeric(bd.gradehigh) = 0 THEN NULL
                        ELSE CAST(CAST(bd.gradehigh AS INT) AS VARCHAR(2)) END
            else CASE 
                        WHEN bd.gradelow = '0K' THEN 'K'
                        WHEN bd.gradelow = '0P' THEN 'P'
                        WHEN bd.gradelow = 'K' THEN 'K'
                        WHEN bd.gradelow = 'P' THEN 'P'
                        WHEN bd.gradelow = '' THEN NULL
                        WHEN bd.gradelow is NULL THEN NULL
                        WHEN isnumeric(bd.gradelow) = 0 THEN NULL
                        ELSE CAST(CAST(bd.gradelow AS INT) AS VARCHAR(2)) END END AS GradeLow,
        case when isnull(CAST(bd.agelow AS INT),0) = 0 and isnull(bd.agelowupind,0) = 0
            then CAST(bd.agehigh AS INT)
            else CAST(bd.agelow AS INT) END AS AgeLow,
        case when isnull(CAST(bd.agehigh AS INT),0) = 0 and isnull(bd.agehighupind,0) = 0
            then CAST(bd.agelow AS INT)
            else CAST(bd.agehigh AS INT) END AS AgeHigh,
        p.pubmonthcode	AS PublishMonth,
        datepart(yyyy,p.pubmonth) AS PublishYear,
        case when actualinsertillus is not null and actualinsertillus <> '' then actualinsertillus else estimatedinsertillus end AS InsertIllustration,
        dbo.rpt_get_best_trim_dimension (b.bookkey, 1, 'W') AS TrimWidth,
        dbo.rpt_get_best_trim_dimension (b.bookkey, 1, 'L') AS TrimLength,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=613 AND datacode=p.trimsizeunitofmeasure AND deletestatus='N' and exporteloquenceind = 1) AS TrimSizeUomTag,
        bd.volumenumber AS VolumeNumber,
        (SELECT TOP 1 case when alternatedesc1 is null or alternatedesc1 = '' then datadesc else alternatedesc1 end FROM gentables 
            WHERE tableid=459 AND datacode=bd.discountcode AND deletestatus='N') AS DiscountDescription,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=459 AND datacode=bd.discountcode AND deletestatus='N') AS DiscountTag,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=428 AND datacode=bd.canadianrestrictioncode AND deletestatus='N' and exporteloquenceind = 1) AS SalesRestrictionTag,
         CASE 
            WHEN @SendRightsToCloud = 1 OR @SendRightsToCloud = 5 
              THEN (SELECT TOP 1 eloquencefieldtag FROM gentables 
                WHERE tableid=131 AND datacode=b.territoriescode AND deletestatus='N' and exporteloquenceind = 1)
            ELSE ' ' 
            END AS TerritoriesTag,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=319 AND datacode=bd.returncode AND deletestatus='N' and exporteloquenceind = 1) AS ReturnsTag,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=320 AND datacode=bd.restrictioncode AND deletestatus='N' and exporteloquenceind = 1) AS ReturnRestrictionsTag,
        (SELECT TOP 1 cartonqty1 FROM bindingspecs WHERE bookkey=b.bookkey AND printingkey=1) AS CartonQuantity,
        p.bookweight AS BookWeight,
        isnull((SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=613 AND datacode=p.bookweightunitofmeasure AND deletestatus='N' and exporteloquenceind = 1), @defaultweightuom) AS BookWeightUomTag,
        isnull(announcedfirstprint, estannouncedfirstprint) AS AnnouncedFirstPrint,
        p.spinesize AS SpineSize,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=613 AND datacode=p.spinesizeunitofmeasure AND deletestatus='N' and exporteloquenceind = 1) AS SpineSizeUomTag,
        CAST(bd.copyrightyear AS INT) AS CopyrightYear,
        @amazonbrandcode AS AmazonBrandCode,
        bd.CSApprovalCode AS ApprovalCode,
        isnull(b.sendtoeloind,0) AS SendToEloquence,
		CAST(isnull(bd.publishtowebind,0) AS BIT) AS WebEnabled,
		(Case WHEN ISNULL(b.usageclasscode,0) <> (SElect s.datasubcode from gentables g join subgentables s on g.datacode = s.datacode and g.tableid = s.tableid
												where g.tableid = 550 and g.qsicode = 1  and s.qsicode = 27) THEN NULL -- (Tolga) passing NULL for now if it's not a SET
		ELSE -- it is a set
		(Case when exists (Select 1 from booksets where bookkey = b.bookkey and ISNULL(settypecode, 0) = 0) THEN 'SET|'
			  ELSE (Select TOP 1  'SET|' + eloquencefieldtag from booksets bs join gentables g on bs.settypecode = g.datacode where bs.bookkey = b.bookkey and g.tableid = 481)
			  END) END) as ItemDescription
		
    FROM
        book AS b,
        bookdetail AS bd,
        isbn AS i,
        printing AS p
    WHERE
        b.bookkey = @bookkey AND
        bd.bookkey = b.bookkey AND
        i.bookkey = b.bookkey AND
        p.bookkey = b.bookkey AND
        p.printingkey = 1

    /************************************************************************************
     ** Product.LanguageTags - This get's translated to the LanguageTags List on Product.
     **                        We had to do this as a separate SELECT to translate it to
     **                        a List.  It should return 0, 1, or 2 rows.  Only one
     **                        column should be returned.
     ************************************************************************************/
    SELECT TOP 1 g.eloquencefieldtag 
    FROM bookdetail bd, gentables g
    WHERE 
        bd.bookkey=@bookkey AND
        g.tableid=318 AND 
        g.datacode=bd.languagecode AND 
        g.deletestatus='N' AND 
        g.exporteloquenceind = 1
    UNION ALL
    SELECT TOP 1 g.eloquencefieldtag 
    FROM bookdetail bd, gentables g
    WHERE 
        bd.bookkey=@bookkey AND
        g.tableid=318 AND 
        g.datacode=bd.languagecode2 AND 
        g.deletestatus='N' AND 
        g.exporteloquenceind = 1

    /************************************************************************************
     ** Product.BisacCategories - This get's translated to the Product.BisacCategories
     **                           List in the Cloud.  It may return 0 or more rows with
     **                           1 column.
     ************************************************************************************/
    SELECT
        s.bisacdatacode
    FROM
        bookbisaccategory bc,
        subgentables s
    WHERE
        bc.bookkey=@bookkey AND
        bc.printingkey=1 AND
        s.tableid=339 AND
        s.deletestatus='N' AND
        bc.bisaccategorycode=s.datacode AND
        bc.bisaccategorysubcode=s.datasubcode AND
        s.exporteloquenceind = 1
    ORDER BY bc.sortorder

    /************************************************************************************
     ** Product.SubjectCategories - This get's translated to the 
     **                             Product.SubjectCategories List in the Cloud.  
     **                             It may return 0 or more rows with 1 column.
     ************************************************************************************/
    -- 01/07/2015: changed to pull data from gentables where elofieldid=SUBJECTCAT. This will allow for any subject to be sent to  product.subjectcategories field on the Cloud
--        Currently being used for ELO enabled categories and BIC subjects. BIC subjects can have 1,2, or 3 levels in TMM. 
--				Take the eloquencefieldtag from lowest level of the three levels used - gentables, subgentables,sub2gentables
--				Since this data is loaded into the generic "Product.SubjectCategories field, the BIC subject eloquencefieldtags must start with BIC_ so that they can be distinguished on the Cloud side
--

 select  -- CASE #25783 - We will be allowing this data to send now - the ONIX code is being changed to correctly handle this data

        coalesce( rtrim(s2.eloquencefieldtag),rtrim(s.eloquencefieldtag),rtrim(g.eloquencefieldtag)) as 'eloquencefieldtag'
    FROM
        booksubjectcategory bc
		join gentables g on  g.datacode=bc.categorycode  and g.tableid=bc.categorytableid
		join gentablesdesc gd on gd.tableid=g.tableid 
		left outer join subgentables s on s.datacode=bc.categorycode and s.datasubcode=bc.categorysubcode and s.tableid=bc.categorytableid and s.deletestatus='N' AND s.exporteloquenceind = 1
		left outer join sub2gentables s2 on s2.datacode=bc.categorycode and s2.datasubcode=bc.categorysubcode and  bc.categorysub2code = s2.datasub2code  and   s2.tableid=bc.categorytableid and s2.deletestatus='N' AND s2.exporteloquenceind = 1
    WHERE
        bc.bookkey=@bookkey AND
		bc.categorytableid  in (558,668) and
        g.deletestatus='N' AND g.exporteloquenceind = 1 and gd.elofieldid='SUBJECTCAT'
    
order by bc.categorytableid,bc.sortorder

    /************************************************************************************
     ** Product.AudienceTags - This get's translated to the Product.AudienceTags List in 
     **                        the Cloud.  It may return 0 or more rows with 1 column.
     ************************************************************************************/
    SELECT
        g.bisacdatacode
    FROM
        bookaudience a,
        gentables g
    WHERE
        a.bookkey=@bookkey AND
        a.audiencecode=g.datacode AND
        g.tableid=460 AND
        g.deletestatus='N' AND
        g.bisacdatacode IS NOT NULL AND
        g.exporteloquenceind = 1
    ORDER BY a.sortorder


    /************************************************************************************
     ** Product.FormDetailTags - This get's translated to the Product.FormDetailTags List 
     **                          in the Cloud.  It may return 0 or more rows with 1 
     **                          column.
     ************************************************************************************/
		--eloquence field tag
		SELECT g.eloquencefieldtag AS DetailTag
		FROM booksimon bs 
		JOIN  gentables g
		ON g.tableid = 300
			AND g.datacode = bs.formatchildcode
			AND g.eloquencefieldtag IS NOT NULL
			AND g.deletestatus <> 'Y'
			AND g.exporteloquenceind = 1
		WHERE bs.bookkey = @bookkey

    /************************************************************************************
     ** Product.ContentTypeTags - This get's translated to the Product.ContentTypeTags 
     **                           List in the Cloud.  It may return 0 or more rows with 
     **                           1 column.
     ************************************************************************************/
		--eBook Features 
		SELECT sg.eloquencefieldtag AS DetailTag
		FROM booksubjectcategory bsc
		JOIN gentables g
		ON g.tableid = 558
			AND g.eloquencefieldtag = 'pct' 
		JOIN subgentables sg
		ON sg.datacode = g.datacode
			AND sg.tableid = g.tableid
		WHERE bsc.bookkey = @bookkey
			AND bsc.categorycode = sg.datacode 
			AND bsc.categorysubcode = sg.datasubcode
			AND bsc.categorytableid = 558
			AND g.eloquencefieldtag IS NOT NULL
			AND g.deletestatus <> 'Y'
			AND g.exporteloquenceind = 1
			AND sg.eloquencefieldtag IS NOT NULL
			AND sg.deletestatus <> 'Y'
			AND sg.exporteloquenceind = 1
		ORDER BY sg.eloquencefieldtag

    /************************************************************************************
     ** ProductRegion         - This collection gets pulled into a list of
     ** (Product.RegionGroups)  ProductRegion objects which then get converted to 
     **                         a list of ProductRegionGroup objects that get set on
     **                         Product.RegionGroups property.  It may return 0 or more
     **                         rows with 3 columns.
     **    EXAMPLE:
     **     SELECT
     **       2 AS RightsType,     -- 1 for Exclusive, 2 for NonExclusive, and 3 for NotForSale
     **           'C' AS RegionType,   -- C for Country, T for Territory (such as WORLD)
     **           'US' AS RegionTag    -- Onix Country or Territory tag (ie. US, GB, CA, WORLD)
     ************************************************************************************/
    IF @SendRightsToCloud = 1 OR @SendRightsToCloud = 2 BEGIN
      -- Exclusive Rights
      SELECT 1 AS RightsType,'C' AS RegionType,g.eloquencefieldtag as RegionTag
      FROM qtitle_get_territorycountry_by_title(@bookkey) t, gentables g
      WHERE forsaleind = 1
       AND currentexclusiveind = 1
         AND t.countrycode = g.datacode 
         AND g.tableid=114 
         AND g.deletestatus='N' 
         AND g.eloquencefieldtag IS NOT NULL 
         AND g.exporteloquenceind = 1
      UNION
      -- Non-exclusive Rights
      SELECT 2 AS RightsType,'C' AS RegionType,g.eloquencefieldtag as RegionTag
      FROM qtitle_get_territorycountry_by_title(@bookkey) t, gentables g
      WHERE forsaleind = 1
       AND (currentexclusiveind IS NULL OR currentexclusiveind = 0)
         AND t.countrycode = g.datacode 
         AND g.tableid=114 
         AND g.deletestatus='N' 
         AND g.eloquencefieldtag IS NOT NULL 
         AND g.exporteloquenceind = 1
      UNION
      -- Not For Sale
      SELECT 3 AS RightsType,'C' AS RegionType,g.eloquencefieldtag as RegionTag
      FROM qtitle_get_territorycountry_by_title(@bookkey) t, gentables g
      WHERE forsaleind = 0
         AND t.countrycode = g.datacode 
         AND g.tableid=114 
         AND g.deletestatus='N' 
         AND g.eloquencefieldtag IS NOT NULL 
         AND g.exporteloquenceind = 1
    END
    ELSE BEGIN
      -- if sendrightstocloud is not 1 or 2, we still need to return an empty dataset otherwise code that calls getproduct will fail 
      SELECT datacode AS RightsType,datadesc AS RegionType,eloquencefieldtag as RegionTag
      FROM gentables g
      WHERE tableid = -100
    END
     
    /************************************************************************************
     ** ProductComment     - This get's translated to ProductComment in the Cloud.  It is
     ** (Product.Comments)   also accessible as the Product.Comments List.  It may return
     **                      0 or more rows with 5 columns.  The Tag is considered
     **                      a Unique Key in the Cloud.
     ************************************************************************************/
    IF @SendRightsToCloud = 1 OR @SendRightsToCloud = 3 BEGIN
      DECLARE @4SALE NVARCHAR(MAX)
      DECLARE @N4SALE NVARCHAR(MAX)
      DECLARE @COMBINED NVARCHAR(MAX)
      SET @COMBINED = ''
      SET @4SALE = ''
      SET @N4SALE = ''
          
      SELECT
          @4SALE = dbo.remove_control_chars(c.commenttext)
      FROM
          bookcomments c,
          subgentables s
      WHERE
          c.bookkey = @bookkey AND
          c.printingkey = 1 AND
          s.tableid = 284 AND
          s.deletestatus = 'N' AND
          c.commenttypecode = s.datacode AND
          c.commenttypesubcode = s.datasubcode AND
          s.eloquencefieldtag IS NOT NULL AND
          s.eloquencefieldtag != 'N/A' AND
          s.eloquencefieldtag != '' AND
          s.exporteloquenceind = 1 AND
          c.releasetoeloquenceind = 1 AND
          c.commenthtmllite is not null
          AND (s.eloquencefieldtag = '4SALE')
          
      SELECT
          @N4SALE = dbo.remove_control_chars(c.commenttext)
      FROM
          bookcomments c,
          subgentables s
      WHERE
          c.bookkey = @bookkey AND
          c.printingkey = 1 AND
          s.tableid = 284 AND
          s.deletestatus = 'N' AND
          c.commenttypecode = s.datacode AND
          c.commenttypesubcode = s.datasubcode AND
          s.eloquencefieldtag IS NOT NULL AND
          s.eloquencefieldtag != 'N/A' AND
          s.eloquencefieldtag != '' AND
          s.exporteloquenceind = 1 AND
          c.releasetoeloquenceind = 1 AND
          c.commenthtmllite is not null
          AND (s.eloquencefieldtag = 'N4SALE') 
              
       IF @4SALE <> '' 
       BEGIN
          SET @4SALE = LTrim(RTrim('<salesrights><b089>01</b089><b090>' + LTrim(RTrim(@4SALE)) + '</b090></salesrights>'))
       END
       IF @N4SALE <> ''
       BEGIN
          SET @N4SALE = LTrim(RTrim('<notforsale><b090>' + LTrim(RTrim(@N4SALE)) + '</b090></notforsale>'))
       END
       
       IF (@4SALE <> '' AND @N4SALE = '')
       BEGIN
          SET @COMBINED = @4SALE
       END
       IF (@4SALE = '' AND @N4SALE <> '')
       BEGIN
          SET @COMBINED = @N4SALE
       END
       IF (@4SALE <> '' AND @N4SALE <> '')
       BEGIN
          SET @COMBINED =  + @4SALE + @N4SALE
       END
       IF (@4SALE = '' AND @N4SALE = '')
       BEGIN
          SET @COMBINED = ''
       END
   
       DECLARE @datasubcode INT
       SET @datasubcode = 0
       SELECT @datasubcode = datasubcode 
       FROM subgentables s WHERE
           s.tableid = 284 AND
           s.deletestatus = 'N' AND
           s.eloquencefieldtag IS NOT NULL AND
           s.eloquencefieldtag != 'N/A' AND
           s.eloquencefieldtag != '' AND
           s.exporteloquenceind = 1 
           AND s.eloquencefieldtag = 'SALES'
   
       -- If SALES tag doesn't exist you need to create it
       IF @datasubcode = 0
       BEGIN
           SELECT @datasubcode = COALESCE(MAX(datasubcode), 0) + 1
           FROM subgentables s WHERE
              s.tableid = 284
              AND datacode = 4
              
           INSERT INTO subgentables
           (tableid,datacode,datasubcode,datadesc,deletestatus,applid,sortorder,tablemnemonic,alldivisionsind,externalcode,datadescshort,lastuserid,lastmaintdate,eloquencefieldtag, exporteloquenceind)
            VALUES (284,4,@datasubcode,'Sales Rights','N',null,null,'COMMENTT',null,null,'Sales Rights','qsiadmin',getdate(),'SALES', 1)
       END
       
          DECLARE @HTML NVARCHAR(MAX) 
      SET @HTML = '<DIV>' + @COMBINED + '</DIV>'
       
      DECLARE @CNTR INT
      SET @CNTR = 0
      SELECT @CNTR = count(*) FROM bookcomments WHERE commenttypecode = 4 and bookkey = @bookkey and commenttypesubcode = @datasubcode
           
       IF @CNTR = 0
       BEGIN
          IF LTRIM(RTRIM(@COMBINED)) <> ''
          BEGIN       
           INSERT INTO bookcomments(bookkey,printingkey,commenttypecode,commenttypesubcode,commentstring,commenttext,lastuserid,lastmaintdate,
           releasetoeloquenceind,commenthtml,commenthtmllite,invalidhtmlind)
           VALUES(@bookkey,1,4,@datasubcode,@COMBINED,@COMBINED,'qsiadmin',getdate(),1,@HTML,@HTML ,0)
          END
       END
       ELSE
       BEGIN
          IF LTRIM(RTRIM(@COMBINED)) <> ''
          BEGIN
           UPDATE bookcomments SET commenttext = @COMBINED, commenthtml = @HTML, commenthtmllite = @HTML, lastuserid = 'qsiadmin', lastmaintdate = getdate()
           WHERE bookkey = @bookkey and commenttypecode = 4 and commenttypesubcode = @datasubcode
          END
       END
    END              

    -- Author Bio
    DECLARE @v_author_bio_qsicode int,
            @v_author_bio_count int

    -- default to title author bio
    SET @v_author_bio_qsicode = 1
    
    SELECT
        @v_author_bio_count = count(*) 
    FROM
        bookcomments c,
        subgentables s
    WHERE
        c.bookkey = @bookkey AND
        c.printingkey = 1 AND
        s.tableid = 284 AND
        s.deletestatus = 'N' AND
        c.commenttypecode = s.datacode AND
        c.commenttypesubcode = s.datasubcode AND
        s.eloquencefieldtag IS NOT NULL AND
        s.eloquencefieldtag != 'N/A' AND
        s.eloquencefieldtag != '' AND
        s.eloquencefieldtag = 'AI' AND 
        s.exporteloquenceind = 1 AND
        c.releasetoeloquenceind = 1 AND
        c.commenthtmllite is not null AND
        s.qsicode = 1 -- Author Bio
    
    IF @v_author_bio_count = 0 BEGIN
      -- Title does not have an author bio so see if there is a generated one     
      SELECT
          @v_author_bio_count = count(*) 
      FROM
          bookcomments c,
          subgentables s
      WHERE
          c.bookkey = @bookkey AND
          c.printingkey = 1 AND
          s.tableid = 284 AND
          s.deletestatus = 'N' AND
          c.commenttypecode = s.datacode AND
          c.commenttypesubcode = s.datasubcode AND
          s.eloquencefieldtag IS NOT NULL AND
          s.eloquencefieldtag != 'N/A' AND
          s.eloquencefieldtag != '' AND
          s.eloquencefieldtag = 'AI' AND 
          s.exporteloquenceind = 1 AND
          c.releasetoeloquenceind = 1 AND
          c.commenthtmllite is not null AND
          s.qsicode = 7 -- Generated Author Bio
      
      IF @v_author_bio_count = 1 BEGIN
        -- Title has a generated author bio so use that one     
        SET @v_author_bio_qsicode = 7 -- Generated Author Bio
      END
    END

    SELECT
        NEWID() AS Id,
        @productTag + '-' + CAST(c.commenttypecode AS VARCHAR(15)) + '-' + CAST(c.commenttypesubcode AS VARCHAR(15)) AS Tag,
        s.eloquencefieldtag AS TypeTag,
        c.commenttext AS Text,
        c.commenthtmllite AS Html
    FROM
        bookcomments c,
        subgentables s
    WHERE
        c.bookkey = @bookkey AND
        c.printingkey = 1 AND
        s.tableid = 284 AND
        s.deletestatus = 'N' AND
        c.commenttypecode = s.datacode AND
        c.commenttypesubcode = s.datasubcode AND
        s.eloquencefieldtag IS NOT NULL AND
        s.eloquencefieldtag != 'N/A' AND
        s.eloquencefieldtag != '' AND
        s.eloquencefieldtag != 'AI' AND  -- Author Bio Handled differently due to possibility of using generated Author Bio (qsicode 7)
        s.exporteloquenceind = 1 AND
        c.releasetoeloquenceind = 1 AND
        c.commenthtmllite is not null
    UNION ALL  -- due to commenthtmllite being a ntext column, we need to use union all which will not remove duplicate rows (both sides of union returning the same data) 
               -- be careful modifying this query
    SELECT
        NEWID() AS Id,
        @productTag + '-' + CAST(c.commenttypecode AS VARCHAR(15)) + '-' + CAST(c.commenttypesubcode AS VARCHAR(15)) AS Tag,
        s.eloquencefieldtag AS TypeTag,
        c.commenttext AS Text,
        c.commenthtmllite AS Html
    FROM
        bookcomments c,
        subgentables s
    WHERE
        c.bookkey = @bookkey AND
        c.printingkey = 1 AND
        s.tableid = 284 AND
        s.deletestatus = 'N' AND
        c.commenttypecode = s.datacode AND
        c.commenttypesubcode = s.datasubcode AND
        s.eloquencefieldtag IS NOT NULL AND
        s.eloquencefieldtag != 'N/A' AND
        s.eloquencefieldtag != '' AND
        s.eloquencefieldtag = 'AI' AND  -- Author Bio Handled differently due to possibility of using generated Author Bio (qsicode 7)
        s.exporteloquenceind = 1 AND
        c.releasetoeloquenceind = 1 AND
        c.commenthtmllite is not null AND
        s.qsicode = @v_author_bio_qsicode 

    /************************************************************************************
     ** ProductContributor     - This get's translated to ProductContributor in the Cloud.  
     ** (Product.Contributors)   It is also accessible as the Product.Contributors List.  
     **                          It may return 0 or more rows with 10 columns.  The Tag is 
     **                          considered a Unique Key in the Cloud.
     ************************************************************************************/
    SELECT
        NEWID() AS Id,
        @productTag + '-' + CAST(ba.authorkey AS VARCHAR(15)) + '-' + CAST(ba.authortypecode AS VARCHAR(15)) AS Tag,
        g.eloquencefieldtag AS RoleTag,
        CAST(ba.primaryind AS BIT) AS IsPrimary,
		CASE WHEN gc.individualind = 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsCompany,
        gc.firstname AS FirstName,
        gc.middlename AS MiddleName,
        gc.lastname AS KeyName,
        gc.suffix AS Suffix,
        gc.degree AS Degree,
        g2.datadesc AS Title,
        c.commenthtmllite AS Bio,
        ba.sortorder AS [Order]
    FROM bookauthor ba
    JOIN globalcontact gc ON ba.authorkey = gc.globalcontactkey
    JOIN gentables g ON 
        g.tableid = 134 AND
        g.datacode = ba.authortypecode AND
        g.deletestatus = 'N' AND
        g.exporteloquenceind = 1 AND
        g.eloquencefieldtag is not null
    LEFT JOIN gentables g2 ON
        g2.tableid = 210 AND
        g2.datacode = gc.accreditationcode AND
        g2.deletestatus = 'N'
	LEFT JOIN gentables dt ON
		dt.tableid=528 AND
		dt.qsicode=2 AND
		dt.exporteloquenceind=1
	LEFT JOIN gentables dm ON
		dm.tableid=673 AND
		dm.qsicode=1 AND
		dm.exporteloquenceind=1
	LEFT JOIN qsicommentmarkets cm ON 
		cm.commentkey=gc.globalcontactkey AND
		cm.marketcode=dm.datacode AND
		cm.commenttypecode=dt.datacode
	LEFT JOIN qsicomments c ON
		c.commentkey=gc.globalcontactkey AND
		c.commenttypecode=cm.commenttypecode AND
		c.commenttypesubcode=cm.commenttypesubcode AND
		c.releasetoeloquenceind=1
    WHERE 
        ba.bookkey = @bookkey 
    ORDER by ba.sortorder

    /************************************************************************************
     ** ProductContributorComment- This get's translated to ProductContributorComment in the Cloud.  
     ** (Product.Contributors)   It is also accessible as the Product.Contributor[i].Comments List.  
     **                          It may return 0 or more rows with 6 columns.  The Tag is 
     **                          considered a Unique Key in the Cloud.
     ************************************************************************************/
	 SELECT
		NEWID() AS Id,
		@productTag+'-'+CAST(ba.authorkey AS VARCHAR(15))+'-'+CAST(ba.authortypecode AS VARCHAR(15))+'-'+
		CAST(tt.eloquencefieldtag AS VARCHAR(15))+'-'+CAST(mt.eloquencefieldtag AS VARCHAR(15)) AS Tag,
		tt.eloquencefieldtag AS TypeTag,
		mt.eloquencefieldtag AS MarketTag,
		c.commenttext AS [Text],
		c.commenthtml AS Html
	FROM bookauthor ba
	JOIN globalcontact gc ON ba.authorkey = gc.globalcontactkey
	JOIN qsicommentmarkets cm ON cm.commentkey=gc.globalcontactkey
	JOIN qsicomments c ON
		c.commentkey=gc.globalcontactkey AND
		c.commenttypecode=cm.commenttypecode AND
		c.commenttypesubcode=cm.commenttypesubcode
	JOIN gentables tt ON
		tt.tableid=528 AND
		tt.exporteloquenceind=1 AND
		tt.datacode=c.commenttypecode
	JOIN gentables mt ON
		mt.tableid=673 AND
		mt.exporteloquenceind=1 AND
		mt.datacode = cm.marketcode
	WHERE ba.bookkey=@bookkey AND 
		COALESCE(tt.eloquencefieldtag,'')<>'' AND
		COALESCE(mt.eloquencefieldtag,'')<>'' AND
		c.releasetoeloquenceind=1

    /************************************************************************************
     ** ProductContributorPlace- This get's translated to ProductContributorPlace in the Cloud.  
     ** (Product.Contributors)   It is also accessible as the Product.Contributor[i].Places List.  
     **                          It may return 0 or more rows with 10 columns.  The Tag is 
     **                          considered a Unique Key in the Cloud.
     ************************************************************************************/
    SELECT
        NEWID() AS Id,
        @productTag + '-' + CAST(ba.authorkey AS VARCHAR(15)) + '-' + CAST(ba.authortypecode AS VARCHAR(15))+'-'+
            CAST(tt.eloquencefieldtag AS VARCHAR(15)) AS Tag,
        tt.eloquencefieldtag AS TypeTag,
        STUFF((
            SELECT DISTINCT '|'+cr.Tag
            FROM cloudregion cr
            JOIN globalcontactplaces gcp1 ON
                cr.Id=gcp1.countrycode OR cr.Id=gcp1.regioncode
            WHERE gcp1.globalcontactkey=gcp.globalcontactkey AND
                gcp1.placecode=gcp.placecode
            ORDER BY '|'+cr.Tag
            FOR XML PATH(''),
        TYPE).value('.', 'varchar(max)')
        ,1,1,'') AS Territories
    FROM bookauthor ba
    JOIN globalcontact gc ON gc.globalcontactkey=ba.authorkey
    JOIN globalcontactplaces gcp ON gcp.globalcontactkey=ba.authorkey
    JOIN gentables tt ON
        tt.tableid=672 AND
		tt.exporteloquenceind=1 AND
        tt.datacode=gcp.placecode
    WHERE ba.bookkey=@bookkey AND
		COALESCE(tt.eloquencefieldtag,'')<>''
    GROUP BY ba.authorkey,ba.authortypecode,gcp.globalcontactkey,gcp.placecode,tt.eloquencefieldtag
	/************************************************************************************
     ** ProductContributorField- This get's translated to ProductContributorField in the Cloud.  
     ** (Product.Contributors)    -- Will send global contact misc fields to the cloud 
     **                           -- Added by TT - 030716
     **                          
     ************************************************************************************/
	 SELECT 
        NEWID() AS Id,
        @productTag + '-' + CAST(ba.authorkey AS VARCHAR(15)) + '-' + CAST(ba.authortypecode AS VARCHAR(15))+'-'+ CAST(gcm.misckey AS VARCHAR(15)) AS Tag,
        g.eloquencefieldtag AS 'Key', 
        SUBSTRING(g.eloquencefieldtag,8,20) AS AlternateKey, 
        CASE  
            WHEN bmi.misctype = 1 THEN CAST(longvalue AS VARCHAR(30))
            WHEN bmi.misctype = 2 THEN CAST(floatvalue AS VARCHAR(30))
            WHEN bmi.misctype = 3 THEN textvalue
            WHEN bmi.misctype = 4 THEN CAST(longvalue AS VARCHAR(30))
 			WHEN bmi.misctype = 5 and isnull(sg.alternatedesc1,'') <> '' THEN sg.alternatedesc1 
			WHEN bmi.misctype = 5 and ISNULL(sg.alternatedesc1,'') = '' THEN sg.datadesc END AS Value
    FROM globalcontactmisc gcm
	JOIN bookauthor ba
	on gcm.globalcontactkey = ba.authorkey  
    JOIN bookmiscitems bmi ON gcm.misckey = bmi.misckey
    JOIN gentables g ON 
        bmi.eloquencefieldidcode = g.datacode AND 
        g.tableid = 560
    LEFT JOIN subgentables sg ON 
        sg.tableid = 525 AND 
        bmi.datacode = sg.datacode AND 
        sg.datasubcode = gcm.longvalue AND 
        bmi.misctype = 5
    WHERE
        ba.bookkey = @bookkey AND 
        bmi.sendtoeloquenceind = 1 AND
        gcm.sendtoeloquenceind = 1 AND
		(longvalue is not null or floatvalue is not null or textvalue is not null) 



	  --SELECT NULL as ID, 
	  --NULL as Tag, 
	  --NULL as ProductContributorID,
	  --NULL as [Key],
	  --NULL as AlternateKey,
	  --NULL as Value


    /************************************************************************************
     ** ProductPrice     - This get's translated to ProductPrice in the Cloud.  It is 
     ** (Product.Prices)   also accessible as the Product.Prices List.  It may return 0 
     **                    or more rows with 7 columns.  The Tag is considered a Unique 
     **                    Key in the Cloud.
     ************************************************************************************/
--only go through this first option for ebooks, skip to easier logic if non-ebooks
--pull what print prices you can from the ebook isbn where the currency doesn't already exist on the print, then pull those from the print
	if @mediatag = 'EP' and @AOPconflictsource = 'print'	
	begin
		SELECT 
			NEWID() AS Id,
			@productTag + '-' + CAST(p.pricekey AS VARCHAR(15)) AS Tag,
			t.eloquencefieldtag AS TypeTag,
			c.eloquencefieldtag AS CurrencyTag,
			null AS CountryTag,
			CAST(isnull(p.finalprice, p.budgetprice) AS Money) AS Amount,
			p.effectivedate AS EffectiveDate,
			p.expirationdate AS ExpirationDate
		FROM
			bookprice p,
			gentables t,
			gentables c
		WHERE
			p.bookkey=@bookkey AND
			t.tableid=306 AND
			p.pricetypecode=t.datacode AND
			t.deletestatus='N' AND
			p.activeind=1 AND
			c.tableid=122 AND
			c.datacode=p.currencytypecode AND
			c.deletestatus='N' AND
			t.exporteloquenceind = 1 AND
			c.exporteloquenceind = 1 AND
			t.eloquencefieldtag is not null AND
			c.eloquencefieldtag is not null AND
			isnull(p.finalprice, p.budgetprice) is not null AND
	--		(isnull(p.finalprice, p.budgetprice) <> 0 or t.eloquencefieldtag = 'PRP') AND		--commented out for zero prices case 15601
			not exists (select a.bookkey, 
							'AOP' AS TypeTag,
							bpc.eloquencefieldtag AS CurrencyTag,
							CAST(isnull(bp.finalprice, bp.budgetprice) AS Money) AS Amount,
							bp.effectivedate AS EffectiveDate,
							bp.expirationdate AS ExpirationDate
						from associatedtitles a
							join subgentables s
							on a.associationtypecode = s.datacode
							and a.associationtypesubcode = s.datasubcode
							and s.tableid = 440
							and s.eloquencefieldtag = 13
							and a.releasetoeloquenceind = 1
							join bookprice bp
							on a.associatetitlebookkey = bp.bookkey
							and bp.activeind = 1
							join gentables bpp
							on bp.pricetypecode = bpp.datacode
							and bpp.tableid = 306
							and bpp.eloquencefieldtag = 'MSR'
							join gentables bpc
							on bp.currencytypecode = bpc.datacode
							and bpc.tableid = 122
							join bookdetail bd 
							on p.bookkey = bd.bookkey
							join gentables gm
							on bd.mediatypecode = gm.datacode
							and gm.tableid = 312
						WHERE
							p.bookkey=@bookkey AND
							a.bookkey = p.bookkey AND
							t.eloquencefieldtag = 'AOP' AND
							isnull(bp.finalprice, bp.budgetprice) is not null AND
							gm.eloquencefieldtag = 'EP' and
							a.bookkey <> a.associatetitlebookkey and
							c.eloquencefieldtag = bpc.eloquencefieldtag)
		UNION
		SELECT  
			NEWID() AS Id,
			@productTag + '-' + CAST(bp.pricekey AS VARCHAR(15)) AS Tag,
			'AOP' AS TypeTag,
			bpc.eloquencefieldtag AS CurrencyTag,
			null AS CountryTag,
			CAST(isnull(bp.finalprice, bp.budgetprice) AS Money) AS Amount,
			bp.effectivedate AS EffectiveDate,
			bp.expirationdate AS ExpirationDate
		FROM 
			associatedtitles a
			join subgentables s
			on a.associationtypecode = s.datacode
			and a.associationtypesubcode = s.datasubcode
			and s.tableid = 440
			and s.eloquencefieldtag = 13
			join bookprice bp
			on a.associatetitlebookkey = bp.bookkey
			and bp.activeind = 1
			and a.releasetoeloquenceind = 1
			join gentables bpp
			on bp.pricetypecode = bpp.datacode
			and bpp.tableid = 306
			and bpp.eloquencefieldtag = 'MSR'
			join gentables bpc
			on bp.currencytypecode = bpc.datacode
			and bpc.tableid = 122
      and bpc.exporteloquenceind=1 and isnull(bpc.eloquencefieldtag,'') not in ('NA','N/A','') -- ***** Case #32974			
			join bookdetail bd 
			on a.bookkey = bd.bookkey
			join gentables gm
			on bd.mediatypecode = gm.datacode
			and gm.tableid = 312
		WHERE
			a.bookkey=@bookkey
			and isnull(bp.finalprice, bp.budgetprice) is not null
			and gm.eloquencefieldtag = 'EP'
			and a.bookkey <> a.associatetitlebookkey
	end
	else		--if EP, pull all prices from the ebook record itself; for all non ebooks, skip right to this easier query to pull all price records directly from the bookkey in question
	begin
		SELECT 
			NEWID() AS Id,
			@productTag + '-' + CAST(p.pricekey AS VARCHAR(15)) AS Tag,
			t.eloquencefieldtag AS TypeTag,
			c.eloquencefieldtag AS CurrencyTag,
			null AS CountryTag,
			CAST(isnull(p.finalprice, p.budgetprice) AS Money) AS Amount,
			p.effectivedate AS EffectiveDate,
			p.expirationdate AS ExpirationDate
		FROM
			bookprice p,
			gentables t,
			gentables c
		WHERE
			p.bookkey=@bookkey AND
			t.tableid=306 AND
			p.pricetypecode=t.datacode AND
			t.deletestatus='N' AND
			p.activeind=1 AND
			c.tableid=122 AND
			c.datacode=p.currencytypecode AND
			c.deletestatus='N' AND
			t.exporteloquenceind = 1 AND
			c.exporteloquenceind = 1 AND
			t.eloquencefieldtag is not null AND
			c.eloquencefieldtag is not null AND
			isnull(p.finalprice, p.budgetprice) is not null 
	end


    /************************************************************************************
     ** ProductCitation     - This get's translated to ProductCitation in the Cloud.  
     ** (Product.Citations)   It is also accessible as the Product.Citations List.  It 
     **                       may return 0 or more rows with 8 columns.  The Tag is 
     **                       considered a Unique Key in the Cloud.
     ************************************************************************************/
    SELECT
        NEWID() AS Id,
        @productTag + '-' + CAST(c.citationkey AS VARCHAR(15)) AS Tag,
        c.citationsource AS Source,
        c.citationauthor AS Author,
        c.citationdate AS Date,
        q.commenttext AS Text,
        q.commenthtmllite AS Html,
        isnull(g.eloquencefieldtag, '08') AS CitationType
    FROM
        citation c join
        qsicomments q on c.qsiobjectkey=q.commentkey 
        left outer join gentables g
        on c.citationexternaltypecode = g.datacode
        and g.tableid = 504
        AND	g.exporteloquenceind = 1
        and g.eloquencefieldtag <> ''
    WHERE
        c.bookkey=@bookkey AND
        c.releasetoeloquenceind = 1 
	ORDER BY c.sortorder

    /************************************************************************************
     ** ProductAssociation     - This get's translated to ProductAssociation in the 
     ** (Product.Associations)   Cloud.  It is also accessible as the 
     **                          Product.Associations List.  It  may return 0 or more 
     **                          rows with 8 columns.  The Tag is considered a Unique Key 
     **                          in the Cloud.
     ************************************************************************************/
    SELECT			--this select brings in associations not tied through bookkey
        NEWID() AS Id,
        NULL AS Tag,
        s.eloquencefieldtag AS TypeTag,
        NULL AS AssociateTag,
        replace(a.isbn,'-','') AS Identifier,
        a.title AS Title,
        a.authorname AS Author,
        (SELECT TOP 1 datadesc FROM gentables 
            WHERE tableid = 126 and datacode = a.origpubhousecode)
            AS Publisher,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=312 AND datacode=a.mediatypecode AND deletestatus='N' AND exporteloquenceind=1) 
            AS MediaTag,
        (SELECT TOP 1 eloquencefieldtag FROM subgentables 
            WHERE tableid=312 AND datacode=a.mediatypecode AND datasubcode=a.mediatypesubcode AND deletestatus='N' AND exporteloquenceind=1) 
            AS FormatTag,
        (SELECT TOP 1 eloquencefieldtag FROM gentables 
            WHERE tableid=314 AND datacode=a.bisacstatus AND deletestatus='N' and exporteloquenceind = 1) 
            AS BisacStatusTag, 
        CAST(a.price AS Money) AS Price,
        case when g.eloquencefieldtag in ('02', '03') AND LEN(replace(a.isbn,'-','')) = 13 AND a.isbn like '97%' then '15' else g.eloquencefieldtag end AS IdentifierTag,
		-- 4 fields added by TT on 03-07-16
		a.quantity as Quantity,
		a.volumenumber  as Volume,
		a.sortorder as SortOrder,
		CAST(case when a.sortorder = 1 then 1 else 0 end AS BIT) as IsPrimary
	
	FROM
        associatedtitles a,
        subgentables s,
        gentables g
    WHERE
        a.bookkey=@bookkey AND
        s.tableid=440 AND
        a.associationtypecode=s.datacode AND
        a.associationtypesubcode=s.datasubcode AND
        s.deletestatus='N' AND
        a.releasetoeloquenceind = 1 AND
        s.exporteloquenceind = 1 AND
        a.productidtype = g.datacode AND
        g.tableid = 551 AND
        a.associatetitlebookkey = 0 AND
        a.isbn is not null AND
        a.isbn <> '' AND
        LEN(replace(a.isbn,'-','')) = 13 AND 
        a.isbn like '97%' AND
        g.eloquencefieldtag = '03'
    UNION
    SELECT			--this select brings in associations tied through bookkey
        NEWID() AS Id,
        NULL AS Tag,
        s.eloquencefieldtag AS TypeTag,
        @customerKeyStr + '-' + CAST(a.associatetitlebookkey AS VARCHAR(15)) AS AssociateTag,
        i.ean13 AS Identifier,
        (SELECT TOP 1 title FROM book WHERE bookkey = a.associatetitlebookkey  ) AS Title,
        (SELECT TOP 1 gc.displayname
            FROM      bookauthor AS ba INNER JOIN
                      globalcontact AS gc ON ba.authorkey = gc.globalcontactkey
            WHERE     ba.sortorder = 1 AND ba.primaryind = 1 AND ba.bookkey = a.associatetitlebookkey) AS Author,
        (SELECT TOP 1 CASE 
                WHEN @PublisherName != '' OR @PublisherName != null THEN @PublisherName
                WHEN c.elopublisherusealt1ind = 1 AND o.altdesc1 IS NOT NULL AND LTRIM(o.altdesc1) <> '' THEN o.altdesc1		  
                WHEN c.elopublisherusealt2ind = 1 and o.altdesc2 IS not NULL and LTRIM(o.altdesc2) <> '' THEN o.altdesc2
                ELSE o.orgentrydesc END
            FROM bookorgentry bo, customer c, orgentry o
            WHERE 
                bo.orglevelkey = c.elopublisherorglevelkey AND 
                bo.orglevelkey = o.orglevelkey AND 
                bo.orgentrykey = o.orgentrykey AND 
                bo.bookkey = a.associatetitlebookkey) AS Publisher,
        (SELECT TOP 1 eloquencefieldtag FROM gentables, bookdetail 
                    WHERE tableid=312 AND datacode=mediatypecode AND deletestatus='N' AND exporteloquenceind=1 AND bookkey = a.associatetitlebookkey )
         AS MediaTag,
        (SELECT TOP 1 eloquencefieldtag FROM subgentables, bookdetail 
                    WHERE tableid=312 AND datacode=mediatypecode AND datasubcode=mediatypesubcode AND deletestatus='N' AND exporteloquenceind=1 AND bookkey = a.associatetitlebookkey)  
        AS FormatTag,
        (SELECT TOP 1 eloquencefieldtag FROM gentables, bookdetail 
                    WHERE tableid=314 AND datacode=bisacstatuscode AND deletestatus='N' and exporteloquenceind = 1 AND bookkey = a.associatetitlebookkey)   
        AS BisacStatusTag, 
        (SELECT TOP 1
                CAST(ISNULL(p.finalprice, p.budgetprice) AS Money)
                FROM
                    bookprice p,
                    gentables t,
                    gentables c
                WHERE
                    p.bookkey=a.associatetitlebookkey AND
                    t.tableid=306 AND
                    p.pricetypecode=t.datacode AND
                    t.deletestatus='N' AND
                    p.activeind=1 AND
                    c.tableid=122 AND
                    c.datacode=p.currencytypecode AND
                    c.deletestatus='N' AND
                    t.exporteloquenceind = 1 AND
                    c.exporteloquenceind = 1 AND
                    t.eloquencefieldtag is not null AND
                    c.eloquencefieldtag is not null
                    AND t.eloquencefieldtag = 'MSR'
                    AND c.eloquencefieldtag = 'USD' )
         AS Price,
		'15' AS IdentifierTag,
		-- 4 fields added by TT on 03-07-16
		a.quantity as Quantity,
		a.volumenumber  as Volume,
		a.sortorder as SortOrder,
		CAST(case when a.sortorder = 1 then 1 else 0 end AS BIT)  as IsPrimary
    FROM
        associatedtitles a,
        subgentables s,
        isbn i,
        book b,
        gentables g
    WHERE
        a.bookkey=@bookkey AND
        s.tableid=440 AND
        a.associationtypecode=s.datacode AND
        a.associationtypesubcode=s.datasubcode AND
        s.deletestatus='N' AND
        a.releasetoeloquenceind = 1 AND
        s.exporteloquenceind = 1 AND
        a.productidtype = g.datacode AND
        g.tableid = 551 AND
        a.associatetitlebookkey > 0 AND
        a.associatetitlebookkey = i.bookkey AND
        a.associatetitlebookkey = b.bookkey AND
        isnull(i.ean13,'') <> ''
	UNION
 	SELECT			--this select brings in associations for desktop sets - web bundles for Courier
		NEWID() AS Id,
		NULL AS Tag,
		'997' AS TypeTag,
		@customerKeyStr + '-' + bp.productnumberx + '-997' AS AssociateTag,
		bp.productnumberx AS Identifier,
		bp.title AS Title,
        (SELECT TOP 1 gc.displayname
			FROM      bookauthor AS ba INNER JOIN
                      globalcontact AS gc ON ba.authorkey = gc.globalcontactkey
			WHERE     ba.sortorder = 1 AND ba.primaryind = 1 AND ba.bookkey = bp.bookkey) AS Author,
		(SELECT TOP 1 CASE 
				WHEN c.elopublisherusealt1ind = 1 AND o.altdesc1 IS NOT NULL AND LTRIM(o.altdesc1) <> '' THEN o.altdesc1		  
				WHEN c.elopublisherusealt2ind = 1 and o.altdesc2 IS not NULL and LTRIM(o.altdesc2) <> '' THEN o.altdesc2
				ELSE o.orgentrydesc END
			FROM bookorgentry bo, customer c, orgentry o
			WHERE 
				bo.orglevelkey = c.elopublisherorglevelkey AND 
				bo.orglevelkey = o.orglevelkey AND 
				bo.orgentrykey = o.orgentrykey AND 
				bo.bookkey = bp.bookkey) AS Publisher,
		gpm.eloquencefieldtag     AS MediaTag,
		spf.eloquencefieldtag	AS FormatTag,
		(SELECT TOP 1 eloquencefieldtag FROM gentables, bookdetail 
					WHERE tableid=314 AND datacode=bisacstatuscode AND deletestatus='N' and exporteloquenceind = 1 AND bookkey = bp.bookkey)   AS BisacStatusTag,
		null AS Price,
		'15'  AS IdentifierTag,
		-- 4 fields added by TT on 03-07-16
		bf.quantity as Quantity,
		NULL as Volume, -- no volume field on the desktop
		bf.sortorder as SortOrder,
		CAST(case when bf.sortorder = 1 then 1 else 0 end AS BIT)  as IsPrimary
		from bookfamily bf					--table where desktop sets are stored
			join coretitleinfo bp				--coretitleinfo table for the parentbookkey
			on bf.parentbookkey = bp.bookkey
			and bp.printingkey = 1
			join coretitleinfo bc				--coretitleinfo table for the childbookkey
			on bf.childbookkey = bc.bookkey
			and bc.printingkey = 1
			join gentables gr					--gentables for the relationshipcode
			on bf.relationcode = gr.datacode
			and gr.tableid = 145
			join gentables gpm					--gentables for the parent media type
			on bp.mediatypecode = gpm.datacode
			and gpm.tableid = 312
			join subgentables spf				--subgentables for the parent format type
			on gpm.tableid = spf.tableid
			and gpm.datacode = spf.datacode
			and bp.mediatypesubcode = spf.datasubcode
			join gentables bspg					--gentables for the formatchildcode of the parent isbn
			on bp.formatchildcode = bspg.datacode
			and bspg.tableid = 300
			join subgentables sgc				--subgentables for the childbookkey's format
			on bc.mediatypecode = sgc.datacode
			and bc.mediatypesubcode = sgc.datasubcode
			and sgc.tableid = 312
		where bf.childbookkey = @bookkey
			and gpm.eloquencefieldtag = 'P'
			and spf.eloquencefieldtag = 'PWX'
			and bspg.eloquencefieldtag = 'EBBUND'
    /************************************************************************************
     ** ProductDate     - This get's translated to ProductDate in the Cloud.  It is also 
     ** (Product.Dates)   accessible as the Product.Dates List.  It  may return 0 or more 
     **                   rows with 4 columns.  The Tag is considered a Unique Key in the 
     **                   Cloud.
     ************************************************************************************/
    SELECT
        NEWID() AS Id,
        @productTag + '-' + CAST(d.datetypecode AS VARCHAR(15)) AS Tag,
        eloquencefieldtag AS TypeTag,
        bestdate as Date
    FROM 
        bookdates bd,
        datetype d
    WHERE 
        bd.bookkey = @bookkey AND
        bd.datetypecode = d.datetypecode AND
        d.exporteloquenceind = 1 AND 
        eloquencefieldtag IS NOT NULL AND 
        eloquencefieldtag <> 'N/A' AND 
        printingkey = 1 AND 
        bestdate IS NOT NULL
    UNION
    SELECT		--only send apple preorder date if pub date and on sale date are in the future
        NEWID() AS Id,
        @productTag + '-' + 'PreOrder' AS Tag,
        'AppPreOrder' AS TypeTag,
        getdate() as Date
    FROM 
        book b,
        bookdates bd,
        datetype d,
        bookdates bdos,
        datetype dos
    WHERE 
        b.bookkey = @bookkey AND
        b.bookkey = bd.bookkey AND
        bd.datetypecode = d.datetypecode AND
        d.eloquencefieldtag = 'PD' AND
        b.bookkey = bdos.bookkey AND
        bdos.datetypecode = dos.datetypecode AND
        dos.eloquencefieldtag = 'OSD' AND
        bd.bestdate >= getdate() AND
		bdos.bestdate >= getdate() AND
		@mediatag = 'EP'
    UNION
    SELECT  
        NEWID() AS Id,
        null AS Tag,
        'PPD' AS TypeTag,
        bestdate as Date
    FROM 
        associatedtitles a
        join subgentables s
        on a.associationtypecode = s.datacode
        and a.associationtypesubcode = s.datasubcode
        and s.tableid = 440
        and s.eloquencefieldtag = 13
        and a.releasetoeloquenceind = 1
        join bookdates bp
        on a.associatetitlebookkey = bp.bookkey
        join datetype bpp
        on bp.datetypecode = bpp.datetypecode
        and bpp.eloquencefieldtag = 'PD'
    WHERE
        a.bookkey=@bookkey and
        printingkey = 1 AND 
        bestdate IS NOT NULL		

    /************************************************************************************
     ** ProductField     - This get's translated to ProductField in the Cloud.  It is 
     ** (Product.Fields)   also accessible as the Product.Dates List.  In addition it is
     ** (Product.Flt)      available as the Product.Fld Dictionary.  It  may return 0
     **                    or more rows with 5 columns.  The Tag is considered a Unique 
     **                    Key in the Cloud.
     ************************************************************************************/
    SELECT 
        NEWID() AS Id,
        @productTag + '-' + CAST(bm.misckey AS VARCHAR(15)) AS Tag,
        g.eloquencefieldtag AS 'Key', 
        SUBSTRING(g.eloquencefieldtag,8,20) AS AlternateKey, 
        CASE  
            WHEN bmi.misctype = 1 THEN CAST(longvalue AS VARCHAR(30))
            WHEN bmi.misctype = 2 THEN CAST(floatvalue AS VARCHAR(30))
            WHEN bmi.misctype = 3 THEN textvalue
            WHEN bmi.misctype = 4 THEN CAST(longvalue AS VARCHAR(30))
            WHEN bmi.misctype = 5 and g.eloquencefieldtag = 'DPIDXBIZBICSUBJX' THEN sg.eloquencefieldtag
			WHEN bmi.misctype = 5 and isnull(sg.alternatedesc1,'') <> '' THEN sg.alternatedesc1 
			WHEN bmi.misctype = 5 and (sg.alternatedesc1 is null or sg.alternatedesc1 = '') THEN sg.datadesc END AS Value
    FROM bookmisc bm
    JOIN bookmiscitems bmi ON bm.misckey = bmi.misckey
    JOIN gentables g ON 
        bmi.eloquencefieldidcode = g.datacode AND 
        g.tableid = 560
    LEFT JOIN subgentables sg ON 
        sg.tableid = 525 AND 
        bmi.datacode = sg.datacode AND 
        sg.datasubcode = bm.longvalue AND 
        bmi.misctype = 5
    WHERE
        bm.bookkey = @bookkey AND 
        bmi.sendtoeloquenceind = 1 AND
        bm.sendtoeloquenceind = 1 AND
		(longvalue is not null or floatvalue is not null or textvalue is not null) AND
        g.eloquencefieldtag not in ('DPIDXBIZPISBN', 'DPIDXBIZDISTRACC')
    UNION
    SELECT 
        NEWID() AS Id,
        NULL AS Tag,
        'DPIDXBIZPISBN' AS 'Key', 
        'ZPISBN' AS AlternateKey, 
        replace(a.isbn,'-','') AS Value
    FROM
        associatedtitles a,
        subgentables s,
        gentables g
    WHERE
        a.bookkey=@bookkey AND
        s.tableid=440 AND
        a.associationtypecode=s.datacode AND
        a.associationtypesubcode=s.datasubcode AND
        s.deletestatus='N' AND
        a.releasetoeloquenceind = 1 AND
        s.exporteloquenceind = 1 AND
        a.productidtype = g.datacode AND
        g.tableid = 551 AND
        a.associatetitlebookkey = 0 AND
        a.isbn is not null AND
        a.isbn <> '' AND
        LEN(replace(a.isbn,'-','')) = 13 AND 
        a.isbn like '97%' AND
        g.eloquencefieldtag = '03' and
        s.eloquencefieldtag = '13'
    UNION
    SELECT 
        NEWID() AS Id,
        NULL AS Tag,
        'DPIDXBIZPISBN' AS 'Key', 
        'ZPISBN' AS AlternateKey, 
        replace(i.ean13,'-','') AS Value
    FROM
        associatedtitles a,
        subgentables s,
        isbn i,
        book b,
        gentables g
    WHERE
        a.bookkey=@bookkey AND
        s.tableid=440 AND
        a.associationtypecode=s.datacode AND
        a.associationtypesubcode=s.datasubcode AND
        s.deletestatus='N' AND
        a.releasetoeloquenceind = 1 AND
        s.exporteloquenceind = 1 AND
        a.productidtype = g.datacode AND
        g.tableid = 551 AND
        a.associatetitlebookkey > 0 AND
        a.associatetitlebookkey = i.bookkey AND
        a.associatetitlebookkey = b.bookkey AND
        isnull(i.ean13,'') <> '' and
        s.eloquencefieldtag = '13'
    UNION
--send product's isbn as PISBN if the product is a book
    SELECT 
        NEWID() AS Id,
        NULL AS Tag,
        'DPIDXBIZPISBN' AS 'Key', 
        'ZPISBN' AS AlternateKey, 
        replace(c.ean,'-','') AS Value
    FROM
        coretitleinfo c,
        gentables g
    WHERE
        c.bookkey=@bookkey AND
        g.tableid=312 AND
        g.deletestatus='N' AND
        c.mediatypecode = g.datacode AND
        c.ean is not null AND
        c.ean <> '' AND
        g.eloquencefieldtag = 'B' AND
		c.printingkey = 1
    UNION
    SELECT 
        NEWID() AS Id,
        @productTag + '-' + CAST(bm.misckey AS VARCHAR(15)) AS Tag,
        g.eloquencefieldtag AS 'Key', 
        SUBSTRING(g.eloquencefieldtag,8,20) AS AlternateKey, 
        CASE bmi.misctype 
            WHEN 1 THEN CAST(longvalue AS VARCHAR(30))
            WHEN 2 THEN CAST(floatvalue AS VARCHAR(30))
            WHEN 3 THEN textvalue
            WHEN 4 THEN CAST(longvalue AS VARCHAR(30))
            WHEN 5 THEN sg.eloquencefieldtag END AS Value		--sending eloquencefieldtag instead of full datadesc for ease in the cloud
    FROM bookmisc bm
    JOIN bookmiscitems bmi ON bm.misckey = bmi.misckey
    JOIN gentables g ON 
        bmi.eloquencefieldidcode = g.datacode AND 
        g.tableid = 560
    LEFT JOIN subgentables sg ON 
        sg.tableid = 525 AND 
        bmi.datacode = sg.datacode AND 
        sg.datasubcode = bm.longvalue AND 
        bmi.misctype = 5
    WHERE
        bm.bookkey = @bookkey AND 
        bmi.sendtoeloquenceind = 1 AND
        bm.sendtoeloquenceind = 1 AND
        g.eloquencefieldtag = 'DPIDXBIZDISTRACC'
    UNION
--send product's parent's ISBN as Primary ISBN (may be different from Print ISBN)
    SELECT 
        NEWID() AS Id,
        @productTag + '-' + 'ZPRIMISBN' AS Tag, 
        'DPIDXBIZPRIMISBN' AS 'Key', 
        'ZPRIMISBN' AS AlternateKey, 
        replace(i.ean13,'-','') AS Value
    FROM
        book b,
        isbn i
    WHERE
        b.bookkey=@bookkey AND
        b.workkey = i.bookkey AND	--if book is a primary title, workkey will point to its own bookkey, otherwise, workkey is the bookkey of the parent
        isnull(i.ean13,'') <> ''
    UNION
--send product's send to eloquence indicator
    SELECT 
        NEWID() AS Id,
        @productTag + '-' + 'ZELOIND' AS Tag, 
        'DPIDXBIZELOIND' AS 'Key', 
        'ZELOIND' AS AlternateKey, 
        cast(isnull(b.sendtoeloind,0) as varchar(15)) AS Value
    FROM
        book b
    WHERE
        b.bookkey=@bookkey
    UNION
    select 
        NEWID() AS Id,
        @productTag + '-' + case when elofieldidlevel = 1 then gd.elofieldid when elofieldidlevel = 2 then ge.eloquencefieldid else null end AS Tag, 
        case when elofieldidlevel = 1 then gd.elofieldid when elofieldidlevel = 2 then ge.eloquencefieldid else null end AS 'Key', 
        substring(case when elofieldidlevel = 1 then gd.elofieldid when elofieldidlevel = 2 then ge.eloquencefieldid else null end, 8, 247) AS AlternateKey, 
        case g.qsicode when 1 then o.customid1 when 2 then o.customid2 when 3 then o.customid3 when 4 then o.customid4 when 5 then o.customid5 end AS Value
    from gentables g
        join gentablesdesc gd
        on g.tableid = gd.tableid
        left outer join gentables_ext ge
        on g.tableid = ge.tableid
        and g.datacode = ge.datacode
        join filterorglevel fol
        on g.numericdesc1 = fol.filterkey
        join orgentry o
        on fol.filterorglevelkey = o.orglevelkey
        join bookorgentry bo
        on o.orgentrykey = bo.orgentrykey
    where 
        bo.bookkey=@bookkey
        and g.tableid = 653
        and g.deletestatus = 'N'
        and g.exporteloquenceind = 1
        and isnull(case g.qsicode when 1 then o.customid1 when 2 then o.customid2 when 3 then o.customid3 when 4 then o.customid4 when 5 then o.customid5 end, '') <> ''
    UNION
--send product's item number
    SELECT 
          NEWID() AS Id,
          @productTag + '-' + 'ZITEMNUM' AS Tag, 
          'DPIDXBIZITEMNUM' AS 'Key', 
          'ZITEMNUM' AS AlternateKey, 
          i.itemnumber AS Value
    FROM
          isbn i
    WHERE
          i.bookkey=@bookkey AND
          i.itemnumber IS NOT NULL AND LTRIM(i.itemnumber) <> ''

	UNION 

	SELECT  
		NEWID() AS Id,
		Tag, 
		[Key],
		Alternatekey, 
		Value 
	FROM dbo.qcs_get_misc_generic(@bookkey, @productTag)

    /************************************************************************************
     ** ProductOnixDetail     - This collection applies to the Product.OnixDetails list.
     ** (Product.OnixDetails)   It can return 0 or more rows with 7 columns.
     ************************************************************************************/
		-- Old Style - Eloquence Enabled Category - Product Form Feature 
    DECLARE @slashtable TABLE
		(
			datacode	INT,
			datasubcode	INT,
			forwardslash	INT
		)
		INSERT INTO @slashtable
		SELECT datacode,
					 datasubcode,
					 CASE WHEN charindex('/', sg.eloquencefieldtag, 1) > 0 THEN charindex('/', sg.eloquencefieldtag, 1)
					 ELSE 0 END forwardslash
		FROM subgentables sg
		WHERE tableid = 558
		
		SELECT NEWID() AS Id,
					 NULL AS Tag,
					 'ProductFormFeature' DetailTypeTag,
					 CASE WHEN st.forwardslash > 0 THEN
					   substring(sg.eloquencefieldtag,1,forwardslash-1)
					 ELSE
					   sg.eloquencefieldtag
					 END AS DetailTag,
					 CASE WHEN st.forwardslash > 0 THEN
						 g.datadesc
					 ELSE
						 sg.datadesc
					 END AS DetailDescription,
					 CASE WHEN st.forwardslash > 0 THEN
						 substring(sg.eloquencefieldtag,forwardslash+1, len(sg.eloquencefieldtag)-forwardslash)
					 ELSE
						 ''
					 END AS SubDetailTag,
					 CASE WHEN sg.alternatedesc1 IS NOT NULL THEN
					   sg.alternatedesc1
					 ELSE
					   ''
					 END AS SubDetailDescription,
			     '' Sub2DetailTag,
			     '' Sub2DetailDescription
		FROM book b
		JOIN gentables g
		ON g.tableid = 558
			AND g.eloquencefieldtag = 'pff' 
		JOIN subgentables sg
		ON sg.datacode = g.datacode
			AND sg.tableid = g.tableid
		JOIN booksubjectcategory bsc
		ON bsc.categorycode = sg.datacode
			AND bsc.bookkey = b.bookkey
			AND bsc.categorysubcode = sg.datasubcode
			AND bsc.categorytableid = 558
		JOIN @slashtable st
		ON st.datacode = sg.datacode
			AND st.datasubcode = sg.datasubcode
		WHERE bsc.bookkey = @bookkey
			AND g.eloquencefieldtag IS NOT NULL
			AND coalesce(g.deletestatus,'N') <> 'Y'
			AND g.exporteloquenceind = 1
			AND sg.eloquencefieldtag IS NOT NULL
			AND coalesce(sg.deletestatus,'N') <> 'Y'
			AND sg.exporteloquenceind = 1
    UNION
    -- new style - ProductOnixDetail
    SELECT NEWID() AS Id,
			     NULL AS Tag,
			     CASE WHEN gd.elofieldidlevel = 1 THEN
			            gd.elofieldid
			          WHEN gd.elofieldidlevel = 2 THEN
			            (select eloquencefieldid from gentables_ext where tableid = bpd.tableid and datacode = bpd.datacode)
			     ELSE ''
			     END AS DetailTypeTag,
			     g.eloquencefieldtag DetailTag,
			     coalesce(ge.gentext1,g.datadesc) DetailDescription,
			     '' SubDetailTag,
			     '' SubDetailDescription,
			     '' Sub2DetailTag,
			     '' Sub2DetailDescription
      FROM bookproductdetail bpd, gentablesdesc gd, gentables g, gentables_ext ge
     WHERE bpd.bookkey = @bookkey
       and bpd.tableid = gd.tableid
       and gd.elofieldidlevel > 0
       and bpd.tableid = g.tableid
       and bpd.datacode = g.datacode
       and coalesce(bpd.datasubcode,0) = 0
       and coalesce(bpd.datasub2code, 0) = 0
       and g.tableid = ge.tableid
       and g.datacode = ge.datacode
 			 and coalesce(g.deletestatus,'N') <> 'Y'
       and g.exporteloquenceind = 1
    UNION
    SELECT NEWID() AS Id,
			     NULL AS Tag,
			     CASE WHEN gd.elofieldidlevel = 1 THEN
			            gd.elofieldid
			          WHEN gd.elofieldidlevel = 2 THEN
			            (select eloquencefieldid from gentables_ext where tableid = bpd.tableid and datacode = bpd.datacode)
			     ELSE ''
			     END AS DetailTypeTag,
			     (select eloquencefieldtag from gentables where tableid = bpd.tableid and datacode = bpd.datacode) AS DetailTag,
           (select coalesce(ge.gentext1,g.datadesc) from gentables g, gentables_ext ge 
                                                    where g.tableid = ge.tableid and g.datacode = ge.datacode 
                                                    and g.tableid = bpd.tableid and g.datacode = bpd.datacode) AS DetailDescription,
			     sg.eloquencefieldtag SubDetailTag,
			     coalesce(sge.gentext1,sg.datadesc) SubDetailDescription,
			     '' Sub2DetailTag,
			     '' Sub2DetailDescription
      FROM bookproductdetail bpd, gentablesdesc gd, subgentables sg, subgentables_ext sge
     WHERE bpd.bookkey = @bookkey
       and bpd.tableid = gd.tableid
       and gd.elofieldidlevel > 0
       and bpd.tableid = sg.tableid
       and bpd.datacode = sg.datacode
       and bpd.datasubcode = sg.datasubcode
       and coalesce(bpd.datasub2code, 0) = 0
       and sg.tableid = sge.tableid
       and sg.datacode = sge.datacode
       and sg.datasubcode = sge.datasubcode
 			 and coalesce(sg.deletestatus,'N') <> 'Y'
       and sg.exporteloquenceind = 1
    UNION
    SELECT NEWID() AS Id,
			     NULL AS Tag,
			     CASE WHEN gd.elofieldidlevel = 1 THEN
			            gd.elofieldid
			          WHEN gd.elofieldidlevel = 2 THEN
			            (select eloquencefieldid from gentables_ext where tableid = bpd.tableid and datacode = bpd.datacode)
			     ELSE ''
			     END AS DetailTypeTag,
			     (select eloquencefieldtag from gentables where tableid = bpd.tableid and datacode = bpd.datacode) AS DetailTag,
           (select coalesce(ge.gentext1,g.datadesc) from gentables g, gentables_ext ge 
                                                    where g.tableid = ge.tableid and g.datacode = ge.datacode 
                                                    and g.tableid = bpd.tableid and g.datacode = bpd.datacode) AS DetailDescription,
			     (select eloquencefieldtag from subgentables where tableid = bpd.tableid and datacode = bpd.datacode and datasubcode = bpd.datasubcode) AS SubDetailTag,
           (select coalesce(sge.gentext1,sg.datadesc) from subgentables sg, subgentables_ext sge 
                                                      where sg.tableid = sge.tableid and sg.datacode = sge.datacode and sg.datasubcode = sge.datasubcode
                                                      and sg.tableid = bpd.tableid and sg.datacode = bpd.datacode and sg.datasubcode = bpd.datasubcode) AS SubDetailDescription,
			     s2g.eloquencefieldtag Sub2DetailTag,
 		       coalesce(s2ge.gentext1,s2g.datadesc) Sub2DetailDescription
      FROM bookproductdetail bpd, gentablesdesc gd, sub2gentables s2g, sub2gentables_ext s2ge
     WHERE bpd.bookkey = @bookkey
       and bpd.tableid = gd.tableid
       and gd.elofieldidlevel > 0
       and bpd.tableid = s2g.tableid
       and bpd.datacode = s2g.datacode
       and bpd.datasubcode = s2g.datasubcode
       and bpd.datasub2code = s2g.datasub2code
       and s2g.tableid = s2ge.tableid
       and s2g.datacode = s2ge.datacode
       and s2g.datasubcode = s2ge.datasubcode
       and s2g.datasub2code = s2ge.datasub2code
 			 and coalesce(s2g.deletestatus,'N') <> 'Y'
       and s2g.exporteloquenceind = 1
	UNION
	-- Added by TT on 03/04/2016. Sending awards data from Elements
		select NEWID() AS Id,
			NULL AS Tag,
			--Cast(tpe.taqelementkey as varchar(100)) + '-' + Cast(ISNULL(tpe.taqelementnumber,0) as varchar(20)) as Tag,  
			'AWARDS' as DetailTypeTag,

			g.eloquencefieldtag + '-' + Cast(tpe.taqelementkey as varchar(100)) + '-' + Cast(ISNULL(tpe.taqelementnumber,0) as varchar(20))  as DetailTag, 

			(select textvalue from taqelementmisc tem join bookmiscitems bmi on tem.misckey = bmi.misckey 
			where tem.taqelementkey =  tpe.taqelementkey and bmi.qsicode = 29) as DetailDescription, --AwardName

			(Select sg.alternatedesc1 from taqelementmisc tem join bookmiscitems bmi
			on tem.misckey = bmi.misckey join subgentables sg on bmi.datacode = sg.datacode and tem.longvalue = sg.datasubcode 
			where tem.taqelementkey = tpe.taqelementkey and bmi.qsicode = 32 and sg.tableid =525) as SubDetailTag, --AwardCode
			
			(select textvalue from taqelementmisc tem join bookmiscitems bmi on tem.misckey = bmi.misckey 
			where tem.taqelementkey =  tpe.taqelementkey and bmi.qsicode = 33) as SubDetailDescription, --AwardJury

			(Select sg.alternatedesc1 from taqelementmisc tem join bookmiscitems bmi on tem.misckey = bmi.misckey join subgentables sg
			on bmi.datacode = sg.datacode and tem.longvalue = sg.datasubcode 
			where tem.taqelementkey = tpe.taqelementkey and bmi.qsicode = 31 and sg.tableid =525) as Sub2DetailTag, --AwardCountry
					
			(select Cast(longvalue as varchar(50)) from taqelementmisc tem join bookmiscitems bmi on tem.misckey = bmi.misckey 
			where tem.taqelementkey =  tpe.taqelementkey and bmi.qsicode = 30) as Sub2DetailDescription --AwardYear 

			FROM gentables g
			join taqprojectelement tpe
			on g.datacode = tpe.taqelementtypecode 
			where tpe.bookkey = @bookkey 
			and g.tableid = 287 and g.qsicode = 4 -- awards
			and g.exporteloquenceind = 1
			--  name is required in ONIX
			and exists (Select 1 from taqelementmisc e  join bookmiscitems bmi on e.misckey = bmi.misckey where e.taqelementkey  = tpe.taqelementkey and bmi.qsicode = 29 and ISNULL(e.textvalue, '') <> '')
			--and exists (Select 1 from taqelementmisc e join bookmiscitems bmi on e.misckey = bmi.misckey where e.taqelementkey  = tpe.taqelementkey and bmi.qsicode = 30 and ISNULL(e.longvalue , 0) <> 0)
			--and exists (Select 1 from taqelementmisc e join bookmiscitems bmi on e.misckey = bmi.misckey where e.taqelementkey  = tpe.taqelementkey and bmi.qsicode = 32 and ISNULL(e.longvalue , 0) <> 0)


    /************************************************************************************
     ** Record           - This get's translated to Record in the Cloud.  It is 
     ** (Product.Records)  also accessible as the Product.Records List.
     ************************************************************************************/
    -- THIS IS ONLY AN EXAMPLE
    CREATE TABLE #records (
        [Id]         UNIQUEIDENTIFIER NOT NULL,
        [Tag]        VARCHAR (25)     NOT NULL,
        [TypeTag]    VARCHAR (30)     NOT NULL,
        [Text1]      VARCHAR (255)    NULL,
        [Text2]      VARCHAR (255)    NULL,
        [Text3]      VARCHAR (255)    NULL,
        [Text4]      VARCHAR (255)    NULL,
        [Text5]      VARCHAR (255)    NULL,
        [Text6]      VARCHAR (255)    NULL,
        [Text7]      VARCHAR (255)    NULL,
        [Text8]      VARCHAR (255)    NULL,
        [Text9]      VARCHAR (255)    NULL,
        [Text10]     VARCHAR (255)    NULL,
        [Number1]    INT              NULL,
        [Number2]    INT              NULL,
        [Number3]    INT              NULL,
        [Number4]    INT              NULL,
        [Number5]    INT              NULL,
        [Decimal1]   MONEY            NULL,
        [Decimal2]   MONEY            NULL,
        [Decimal3]   MONEY            NULL,
        [DateTime1]  DATETIME         NULL,
        [DateTime2]  DATETIME         NULL,
        [LargeText1] VARCHAR (MAX)    NULL,
        [LargeText2] VARCHAR (MAX)    NULL
    );

/*
    INSERT INTO #records
    SELECT
        NEWID() AS Id,
        @productTag + '-R1' AS Tag,
        'TestProductType' AS TypeTag,
        'Text1' AS Text1,
        'Text2' AS Text2,
        'Text3' AS Text3,
        'Text4' AS Text4,
        'Text5' AS Text5,
        'Text6' AS Text6,
        'Text7' AS Text7,
        'Text8' AS Text8,
        'Text9' AS Text9,
        'Text10' AS Text10,
        1 AS Number1,
        2 AS Number2,
        3 AS Number3,
        4 AS Number4,
        5 AS Number5,
        1.1 AS Decimal1,
        2.2 AS Decimal2,
        3.3 AS Decimal3,
        '2011-1-1' AS DateTime1,
        '2011-2-2' AS DateTime2,
        'LargeText1' AS LargeText1,
        'LargeText2' AS LargeText2

    INSERT INTO #records(Id, Tag, TypeTag, Text1, Number1) VALUES(NEWID(), @productTag + '-R2', 'TestProductType', 'Text1-2', 12)
*/
    
    SELECT TOP 0 * FROM #records  -- SELECT TOP 0

    DROP TABLE #records
	
	EXEC qcs_get_product_postprocess @bookkey
END

GO
GRANT EXEC ON dbo.qcs_get_product TO PUBLIC
GO

