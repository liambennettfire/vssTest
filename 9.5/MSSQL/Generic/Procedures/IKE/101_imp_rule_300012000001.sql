SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
**  Name: imp_rule_ext_300012000001
**  Desc: IKE 
**  Auth: Bennett     
**  Date: 5/9/2016
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  5/9/2016     Bennett     original
*******************************************************************************/

SET ANSI_NULLS ON
GO

IF EXISTS (
		SELECT *
		FROM dbo.sysobjects
		WHERE id = object_id(N'[dbo].[imp_rule_ext_300012000001]')
			AND OBJECTPROPERTY(id, N'IsProcedure') = 1
		)
	DROP PROCEDURE [dbo].[imp_rule_ext_300012000001]
GO

CREATE PROCEDURE dbo.imp_rule_ext_300012000001 (
	@bookkey INT
	,@template_bookkey INT
	,@lastuserid VARCHAR(30)
	)
AS
/********************************************************************************************************************************************************/
/********************** BOOK TABLE  *********************************************************************************************************************/
/********************************************************************************************************************************************************/
DECLARE @titlestatuscode INT
	,@standardind CHAR(1)
	,@titletypecode INT
	,@territoriescode INT
	,@sku VARCHAR(10)
	,@specsrecind CHAR(1)
	,@nextprintingnbr SMALLINT
	,@workkey INT
	,@templatetypecode INT
	,@cycle INT
	,@scaleorgentrykey INT
	,@ratecategorycode INT
	,@lastmaintdate DATETIME
	,@primarycontractkey INT
	,@nosoonerthanmonth CHAR(5)
	,@nolaterthanmonth CHAR(5)
	,@origpubhousecode SMALLINT
	,@reuseisbnind TINYINT
	,@linklevelcode TINYINT
	,@propagatefromprimarycode TINYINT
	,@sendtoeloind INT
	,@tmmwebtemplateind TINYINT
	,@nextjobnbr INT
	,@elocustomerkey INT

SELECT @titlestatuscode = titlestatuscode
	,@standardind = 'N'
	,@titletypecode = titletypecode
	,@territoriescode = territoriescode
	,@sku = sku
	,@specsrecind = specsrecind
	,@nextprintingnbr = nextprintingnbr
	,@workkey = @bookkey
	,@templatetypecode = NULL
	,@cycle = cycle
	,@scaleorgentrykey = scaleorgentrykey
	,@ratecategorycode = ratecategorycode
	,@primarycontractkey = primarycontractkey
	,@lastmaintdate = GETDATE()
	,@nosoonerthanmonth = nosoonerthanmonth
	,@nolaterthanmonth = nolaterthanmonth
	,@origpubhousecode = origpubhousecode
	,@reuseisbnind = reuseisbnind
	,@linklevelcode = 10
	,@propagatefromprimarycode = propagatefromprimarycode
	,@sendtoeloind = sendtoeloind
	,@tmmwebtemplateind = 0
	,@nextjobnbr = nextjobnbr
	,@elocustomerkey = elocustomerkey
FROM book
WHERE bookkey = @template_bookkey

UPDATE book
SET titlestatuscode = @titlestatuscode
	,standardind = @standardind
	,titletypecode = @titletypecode
	,territoriescode = @territoriescode
	,sku = @sku
	,specsrecind = @specsrecind
	,nextprintingnbr = @nextprintingnbr
	,workkey = @workkey
	,templatetypecode = @templatetypecode
	,cycle = @cycle
	,scaleorgentrykey = @scaleorgentrykey
	,ratecategorycode = @ratecategorycode
	,primarycontractkey = @primarycontractkey
	,lastuserid = @lastuserid
	,lastmaintdate = @lastmaintdate
	,nosoonerthanmonth = @nosoonerthanmonth
	,nolaterthanmonth = @nolaterthanmonth
	,origpubhousecode = @origpubhousecode
	,reuseisbnind = @reuseisbnind
	,linklevelcode = @linklevelcode
	,propagatefromprimarycode = @propagatefromprimarycode
	,sendtoeloind = @sendtoeloind
	,tmmwebtemplateind = @tmmwebtemplateind
	,nextjobnbr = @nextjobnbr
	,elocustomerkey = @elocustomerkey
WHERE bookkey = @bookkey

/********************************************************************************************************************************************************/
/********************** BOOK CUSTOM TABLE  **************************************************************************************************************/
/********************************************************************************************************************************************************/
DECLARE @customind01 TINYINT
	,@customind02 TINYINT
	,@customind03 TINYINT
	,@customind04 TINYINT
	,@customind05 TINYINT
	,@customind06 TINYINT
	,@customind07 TINYINT
	,@customind08 TINYINT
	,@customind09 TINYINT
	,@customind10 TINYINT
	,@customcode01 SMALLINT
	,@customcode02 SMALLINT
	,@customcode03 SMALLINT
	,@customcode04 SMALLINT
	,@customcode05 SMALLINT
	,@customcode06 SMALLINT
	,@customcode07 SMALLINT
	,@customcode08 SMALLINT
	,@customcode09 SMALLINT
	,@customcode10 SMALLINT
	,@customint01 INT
	,@customint02 INT
	,@customint03 INT
	,@customint04 INT
	,@customint05 INT
	,@customint06 INT
	,@customint07 INT
	,@customint08 INT
	,@customint09 INT
	,@customint10 INT
	,@customfloat01 FLOAT
	,@customfloat02 FLOAT
	,@customfloat03 FLOAT
	,@customfloat04 FLOAT
	,@customfloat05 FLOAT
	,@customfloat06 FLOAT
	,@customfloat07 FLOAT
	,@customfloat08 FLOAT
	,@customfloat09 FLOAT
	,@customfloat10 FLOAT
	,@count INT

SELECT @count = count(*)
FROM bookcustom
WHERE bookkey = @bookkey

IF @count < 1
BEGIN
	INSERT INTO bookcustom (
		bookkey
		,lastuserid
		,lastmaintdate
		)
	VALUES (
		@bookkey
		,@lastuserid
		,@lastmaintdate
		)
END

SELECT @customind01 = customind01
	,@customind02 = customind02
	,@customind03 = customind03
	,@customind04 = customind04
	,@customind05 = customind05
	,@customind06 = customind06
	,@customind07 = customind07
	,@customind08 = customind08
	,@customind09 = customind09
	,@customind10 = customind10
	,@customcode01 = customcode01
	,@customcode02 = customcode02
	,@customcode03 = customcode03
	,@customcode04 = customcode04
	,@customcode05 = customcode05
	,@customcode06 = customcode06
	,@customcode07 = customcode07
	,@customcode08 = customcode08
	,@customcode09 = customcode09
	,@customcode10 = customcode10
	,@customint01 = customint01
	,@customint02 = customint02
	,@customint03 = customint03
	,@customint04 = customint04
	,@customint05 = customint05
	,@customint06 = customint06
	,@customint07 = customint07
	,@customint08 = customint08
	,@customint09 = customint09
	,@customint10 = customint10
	,@customfloat01 = customfloat01
	,@customfloat02 = customfloat02
	,@customfloat03 = customfloat03
	,@customfloat04 = customfloat04
	,@customfloat05 = customfloat05
	,@customfloat06 = customfloat06
	,@customfloat07 = customfloat07
	,@customfloat08 = customfloat08
	,@customfloat09 = customfloat09
	,@customfloat10 = customfloat10
	,@lastmaintdate = GETDATE()
FROM bookcustom
WHERE bookkey = @template_bookkey

UPDATE bookcustom
SET customind01 = @customind01
	,customind02 = @customind02
	,customind03 = @customind03
	,customind04 = @customind04
	,customind05 = @customind05
	,customind06 = @customind06
	,customind07 = @customind07
	,customind08 = @customind08
	,customind09 = @customind09
	,customind10 = @customind10
	,customcode01 = @customcode01
	,customcode02 = @customcode02
	,customcode03 = @customcode03
	,customcode04 = @customcode04
	,customcode05 = @customcode05
	,customcode06 = @customcode06
	,customcode07 = @customcode07
	,customcode08 = @customcode08
	,customcode09 = @customcode09
	,customcode10 = @customcode10
	,customint01 = @customint01
	,customint02 = @customint02
	,customint03 = @customint03
	,customint04 = @customint04
	,customint05 = @customint05
	,customint06 = @customint06
	,customint07 = @customint07
	,customint08 = @customint08
	,customint09 = @customint09
	,customint10 = @customint10
	,customfloat01 = @customfloat01
	,customfloat02 = @customfloat02
	,customfloat03 = @customfloat03
	,customfloat04 = @customfloat04
	,customfloat05 = @customfloat05
	,customfloat06 = @customfloat06
	,customfloat07 = @customfloat07
	,customfloat08 = @customfloat08
	,customfloat09 = @customfloat09
	,customfloat10 = @customfloat10
	,lastuserid = @lastuserid
	,lastmaintdate = @lastmaintdate
WHERE bookkey = @bookkey

/********************************************************************************************************************************************************/
/********************** BOOK DETAIL TABLE  **************************************************************************************************************/
/********************************************************************************************************************************************************/
DECLARE @mediatypecode INT
	,@mediatypesubcode SMALLINT
	,@origincode SMALLINT
	,@salesdivisioncode INT
	,@editioncode INT
	,@languagecode INT
	,@restrictioncode INT
	,@returncode INT
	,@seriescode INT
	,@volumenumber INT
	,@platformcode INT
	,@userlevelcode INT
	,@agelow FLOAT
	,@agehigh FLOAT
	,@gradelow VARCHAR(4)
	,@gradehigh VARCHAR(4)
	,@agelowupind TINYINT
	,@agehighupind TINYINT
	,@gradelowupind TINYINT
	,@gradehighupind TINYINT
	,@bisacstatuscode SMALLINT
	,@publishtowebind INT
	,@canadianrestrictioncode INT
	,@allagesind TINYINT
	,@discountcode INT
	,@laydownind INT
	,@embargoind INT
	,@titleverifycode SMALLINT
	,@newtitleheading INT

SELECT @mediatypecode = mediatypecode
	,@mediatypesubcode = mediatypesubcode
	,@origincode = origincode
	,@salesdivisioncode = salesdivisioncode
	,@editioncode = editioncode
	,@languagecode = languagecode
	,@restrictioncode = restrictioncode
	,@returncode = returncode
	,@seriescode = seriescode
	,@volumenumber = volumenumber
	,@platformcode = platformcode
	,@userlevelcode = userlevelcode
	,@agelow = agelow
	,@agehigh = agehigh
	,@gradelow = gradelow
	,@gradehigh = gradehigh
	,@agelowupind = agelowupind
	,@agehighupind = agehighupind
	,@gradelowupind = gradelowupind
	,@gradehighupind = gradehighupind
	,@bisacstatuscode = bisacstatuscode
	,@lastmaintdate = GETDATE()
	,@publishtowebind = publishtowebind
	,@canadianrestrictioncode = canadianrestrictioncode
	,@allagesind = allagesind
	,@discountcode = discountcode
	,@laydownind = laydownind
	,@embargoind = embargoind
	,@titleverifycode = titleverifycode
	,@newtitleheading = newtitleheading
FROM bookdetail
WHERE bookkey = @template_bookkey

UPDATE bookdetail
SET mediatypecode = @mediatypecode
	,mediatypesubcode = @mediatypesubcode
	,origincode = @origincode
	,salesdivisioncode = @salesdivisioncode
	,editioncode = editioncode
	,languagecode = @languagecode
	,restrictioncode = @restrictioncode
	,returncode = @returncode
	,seriescode = @seriescode
	,volumenumber = @volumenumber
	,platformcode = @platformcode
	,userlevelcode = @userlevelcode
	,agelow = @agelow
	,agehigh = @agehigh
	,gradelow = @gradelow
	,gradehigh = @gradehigh
	,agelowupind = @agelowupind
	,agehighupind = @agehighupind
	,gradelowupind = @gradelowupind
	,gradehighupind = @gradehighupind
	,bisacstatuscode = @bisacstatuscode
	,lastuserid = @lastuserid
	,lastmaintdate = @lastmaintdate
	,publishtowebind = @publishtowebind
	,canadianrestrictioncode = @canadianrestrictioncode
	,allagesind = @allagesind
	,discountcode = @discountcode
	,laydownind = @laydownind
	,embargoind = @embargoind
	,titleverifycode = @titleverifycode
	,newtitleheading = @newtitleheading
WHERE bookkey = @bookkey

/********************************************************************************************************************************************************/
/********************** BOOK DATES  *********************************************************************************************************************/
/********************************************************************************************************************************************************/
DECLARE @printingkey INT
	,@datetypecode SMALLINT
	,@sortorder INT
	,@cstatus INT

--,	@count		INT
BEGIN
	SET @lastmaintdate = GETDATE()
	SET @count = 0

	DECLARE c_dates INSENSITIVE CURSOR
	FOR
	SELECT printingkey
		,datetypecode
		,sortorder
	FROM bookdates
	WHERE bookkey = @template_bookkey

	OPEN c_dates

	FETCH NEXT
	FROM c_dates
	INTO @printingkey
		,@datetypecode
		,@sortorder

	SELECT @cstatus = @@FETCH_STATUS

	WHILE @cstatus <> - 1
	BEGIN
		IF @cstatus <> - 2
		BEGIN
			SET @count = 0
			SET @sortorder = 0

			SELECT @count = COUNT(*)
			FROM bookdates
			WHERE bookkey = @bookkey
				AND datetypecode = @datetypecode

			IF @count < 1
			BEGIN
				INSERT INTO bookdates (
					bookkey
					,printingkey
					,datetypecode
					,lastuserid
					,lastmaintdate
					,sortorder
					)
				VALUES (
					@bookkey
					,@printingkey
					,@datetypecode
					,@lastuserid
					,@lastmaintdate
					,@sortorder
					)
			END
		END

		FETCH NEXT
		FROM c_dates
		INTO @printingkey
			,@datetypecode
			,@sortorder

		SELECT @cstatus = @@FETCH_STATUS
	END
END

CLOSE c_dates

DEALLOCATE c_dates

/********************************************************************************************************************************************************/
/********************** BOOK PRICE TABLE ****************************************************************************************************************/
/********************************************************************************************************************************************************/
DECLARE @pricekey INT
	,@pricetypecode INT
	,@currencytypecode INT
	,@activeind INT
	,
	--	@sortorder		SMALLINT,
	@pstatus INT

BEGIN
	SET @lastmaintdate = GETDATE()
	SET @sortorder = 0

	DELETE
	FROM bookprice
	WHERE bookkey = @bookkey

	DECLARE c_price INSENSITIVE CURSOR
	FOR
	SELECT pricetypecode
		,currencytypecode
		,activeind
		,sortorder
	FROM bookprice
	WHERE bookkey = @template_bookkey

	OPEN c_price

	FETCH NEXT
	FROM c_price
	INTO @pricetypecode
		,@currencytypecode
		,@activeind
		,@sortorder

	SELECT @pstatus = @@FETCH_STATUS

	WHILE @pstatus <> - 1
	BEGIN
		IF @pstatus <> - 2
		BEGIN
			SELECT @pricekey = generickey + 1
			FROM keys

			UPDATE keys
			SET generickey = @pricekey

			IF COALESCE(@sortorder, 0) = 0
			BEGIN
				SELECT @sortorder = MAX(COALESCE(sortorder, 0)) + 1
				FROM bookprice
				WHERE bookkey = @bookkey
			END

			INSERT INTO bookprice (
				bookkey
				,pricekey
				,pricetypecode
				,currencytypecode
				,activeind
				,sortorder
				,lastuserid
				,lastmaintdate
				)
			VALUES (
				@bookkey
				,@pricekey
				,@pricetypecode
				,@currencytypecode
				,@activeind
				,@sortorder
				,@lastuserid
				,@lastmaintdate
				)
		END

		FETCH NEXT
		FROM c_price
		INTO @pricetypecode
			,@currencytypecode
			,@activeind
			,@sortorder

		SELECT @pstatus = @@FETCH_STATUS
	END
END

CLOSE c_price

DEALLOCATE c_price

/********************************************************************************************************************************************************/
/********************** BOOK AUDIENCE TABLE *************************************************************************************************************/
/********************************************************************************************************************************************************/
DECLARE @audiencecode INT
	,
	--	@sortorder	SMALLINT,
	@astatus INT

--,	@count		INT
BEGIN
	SET @lastmaintdate = GETDATE()
	SET @sortorder = 0
	SET @count = 0

	DECLARE c_audience INSENSITIVE CURSOR
	FOR
	SELECT audiencecode
		,sortorder
	FROM bookaudience
	WHERE bookkey = @template_bookkey

	OPEN c_audience

	FETCH NEXT
	FROM c_audience
	INTO @audiencecode
		,@sortorder

	SELECT @astatus = @@FETCH_STATUS

	WHILE @astatus <> - 1
	BEGIN
		IF @astatus <> - 2
		BEGIN
			SET @sortorder = 0
			SET @count = 0

			SELECT @count = COUNT(*)
			FROM bookaudience
			WHERE bookkey = @bookkey
				AND audiencecode = @audiencecode

			IF @count < 1
			BEGIN
				INSERT INTO bookaudience (
					bookkey
					,audiencecode
					,lastuserid
					,lastmaintdate
					,sortorder
					)
				VALUES (
					@bookkey
					,@audiencecode
					,@lastuserid
					,@lastmaintdate
					,@sortorder
					)
			END
		END

		FETCH NEXT
		FROM c_audience
		INTO @audiencecode
			,@sortorder

		SELECT @astatus = @@FETCH_STATUS
	END
END

CLOSE c_audience

DEALLOCATE c_audience

/********************************************************************************************************************************************************/
/********************** PRINTING TABLE      *************************************************************************************************************/
/********************************************************************************************************************************************************/
DECLARE @tentativeqty INT
	,@tentativepagecount INT
	,@pagecount SMALLINT
	,@trimfamily SMALLINT
	,@trimsizewidth VARCHAR(10)
	,@trimsizelength VARCHAR(10)
	,@esttrimsizewidth VARCHAR(10)
	,@esttrimsizelength VARCHAR(10)
	,@printingnum INT
	,@jobnum INT
	,@printingjob VARCHAR(10)
	,@issuenumber INT
	,@pubmonthcode INT
	,@pubmonth DATETIME
	,@slotcode INT
	,@firstprintingqty INT
	,@specind INT
	,@nastaind CHAR(1)
	,@statelabelind CHAR(1)
	,@statuscode TINYINT
	,@seasonkey INT
	,@estseasonkey INT
	,@servicearea INT
	,@conversionind TINYINT
	,@ccestatus VARCHAR(5)
	,@dateccefinalized DATETIME
	,@bookbulk FLOAT
	,@origreprintind CHAR(1)
	,@copycostsversionkey INT
	,@projectedsales INT
	,@announcedfirstprint INT
	,@estimatedinsertillus VARCHAR(255)
	,@actualinsertillus VARCHAR(255)
	,@requestdatetime DATETIME
	,@requestbyname VARCHAR(100)
	,@requestid VARCHAR(30)
	,@requestcomment VARCHAR(255)
	,@requeststatuscode TINYINT
	,@approvedqty INT
	,@approvedondate DATETIME
	,@requestbatchid VARCHAR(30)
	,@pceqty1 INT
	,@pceqty2 INT
	,@estannouncedfirstprint INT
	,@estprojectedsales INT
	,@spinesize VARCHAR(15)
	,@tmmactualtrimwidth VARCHAR(10)
	,@tmmactualtrimlength VARCHAR(10)
	,@tmmpagecount SMALLINT
	,@impressionnumber VARCHAR(10)
	,@qtyreceived INT
	,@printingcloseddate DATETIME
	,@jobnumberalpha CHAR(7)
	,@boardtrimsizewidth VARCHAR(10)
	,@boardtrimsizelength VARCHAR(10)

SET @printingkey = 0

SELECT @printingkey = printingkey
	,@tentativeqty = tentativeqty
	,@tentativepagecount = tentativepagecount
	,@pagecount = pagecount
	,@trimfamily = trimfamily
	,@trimsizewidth = trimsizewidth
	,@trimsizelength = trimsizelength
	,@esttrimsizewidth = esttrimsizewidth
	,@esttrimsizelength = esttrimsizelength
	,@printingnum = printingnum
	,@jobnum = jobnum
	,@printingjob = printingjob
	,@issuenumber = issuenumber
	,@pubmonthcode = pubmonthcode
	,@pubmonth = pubmonth
	,@slotcode = slotcode
	,@firstprintingqty = firstprintingqty
	,@specind = specind
	,@nastaind = nastaind
	,@statelabelind = statelabelind
	,@statuscode = statuscode
	,@seasonkey = seasonkey
	,@estseasonkey = estseasonkey
	,@servicearea = servicearea
	,@conversionind = conversionind
	,@ccestatus = ccestatus
	,@dateccefinalized = dateccefinalized
	,@bookbulk = bookbulk
	,@origreprintind = origreprintind
	,@copycostsversionkey = copycostsversionkey
	,@projectedsales = projectedsales
	,@announcedfirstprint = announcedfirstprint
	,@estimatedinsertillus = estimatedinsertillus
	,@actualinsertillus = actualinsertillus
	,@requestdatetime = requestdatetime
	,@requestbyname = requestbyname
	,@requestid = requestid
	,@requestcomment = requestcomment
	,@requeststatuscode = requeststatuscode
	,@approvedqty = approvedqty
	,@approvedondate = approvedondate
	,@requestbatchid = requestbatchid
	,@lastmaintdate = GETDATE()
	,@pceqty1 = pceqty1
	,@pceqty2 = pceqty2
	,@estannouncedfirstprint = estannouncedfirstprint
	,@estprojectedsales = estprojectedsales
	,@spinesize = spinesize
	,@tmmactualtrimwidth = tmmactualtrimwidth
	,@tmmactualtrimlength = tmmactualtrimlength
	,@tmmpagecount = tmmpagecount
	,@impressionnumber = impressionnumber
	,@qtyreceived = qtyreceived
	,@printingcloseddate = printingcloseddate
	,@jobnumberalpha = jobnumberalpha
	,@boardtrimsizewidth = boardtrimsizewidth
	,@boardtrimsizelength = boardtrimsizelength
FROM printing
WHERE bookkey = @template_bookkey

UPDATE printing
SET printingkey = @printingkey
	,tentativeqty = @tentativeqty
	,tentativepagecount = @tentativepagecount
	,pagecount = @pagecount
	,trimfamily = @trimfamily
	,trimsizewidth = @trimsizewidth
	,trimsizelength = @trimsizelength
	,esttrimsizewidth = @esttrimsizewidth
	,esttrimsizelength = @esttrimsizelength
	,printingnum = @printingnum
	,jobnum = @jobnum
	,printingjob = @printingjob
	,issuenumber = @issuenumber
	,pubmonthcode = @pubmonthcode
	,pubmonth = @pubmonth
	,slotcode = @slotcode
	,firstprintingqty = @firstprintingqty
	,specind = @specind
	,nastaind = @nastaind
	,statelabelind = @statelabelind
	,statuscode = @statuscode
	,seasonkey = @seasonkey
	,estseasonkey = @estseasonkey
	,servicearea = @servicearea
	,conversionind = @conversionind
	,ccestatus = @ccestatus
	,dateccefinalized = @dateccefinalized
	,bookbulk = @bookbulk
	,origreprintind = @origreprintind
	,copycostsversionkey = @copycostsversionkey
	,projectedsales = @projectedsales
	,announcedfirstprint = @announcedfirstprint
	,estimatedinsertillus = @estimatedinsertillus
	,actualinsertillus = @actualinsertillus
	,requestdatetime = @requestdatetime
	,requestbyname = @requestbyname
	,requestid = @requestid
	,requestcomment = @requestcomment
	,requeststatuscode = @requeststatuscode
	,approvedqty = @approvedqty
	,approvedondate = @approvedondate
	,requestbatchid = @requestbatchid
	,lastuserid = @lastuserid
	,lastmaintdate = @lastmaintdate
	,pceqty1 = @pceqty1
	,pceqty2 = @pceqty2
	,estannouncedfirstprint = @estannouncedfirstprint
	,estprojectedsales = @estprojectedsales
	,spinesize = @spinesize
	,tmmactualtrimwidth = @tmmactualtrimwidth
	,tmmactualtrimlength = @tmmactualtrimlength
	,tmmpagecount = @tmmpagecount
	,impressionnumber = @impressionnumber
	,qtyreceived = @qtyreceived
	,printingcloseddate = @printingcloseddate
	,jobnumberalpha = @jobnumberalpha
	,boardtrimsizewidth = @boardtrimsizewidth
	,boardtrimsizelength = @boardtrimsizelength
WHERE bookkey = @bookkey
GO

SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

GRANT EXECUTE
	ON dbo.[imp_rule_ext_300012000001]
	TO PUBLIC
GO

