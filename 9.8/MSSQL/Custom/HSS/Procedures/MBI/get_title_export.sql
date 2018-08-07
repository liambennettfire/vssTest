SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[get_title_export]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[get_title_export]
GO




CREATE PROCEDURE get_title_export(@bookkey	INT,
				  @o_errorcode	INT OUTPUT,
				  @o_errormsg	VARCHAR(1000) OUTPUT)

AS

DECLARE @isbn10			VARCHAR(20)
DECLARE @isbn13			VARCHAR(20)
DECLARE @ean			VARCHAR(20)
DECLARE @upc			VARCHAR(20)
DECLARE @titleprefix		CHAR(3)
DECLARE @title			VARCHAR(255)
DECLARE @fulltitle		VARCHAR(260)
DECLARE @searchtitle		VARCHAR(260)
DECLARE @subtitle		VARCHAR(255)
DECLARE @shorttitle		VARCHAR(50)
DECLARE @grouplevel1		VARCHAR(255)
DECLARE @grouplevel1code	VARCHAR(40)
DECLARE @grouplevel2		VARCHAR(255)
DECLARE @grouplevel2code	VARCHAR(40)
DECLARE @grouplevel3		VARCHAR(255)
DECLARE @grouplevel3code	VARCHAR(40)
DECLARE @sendtoeloquence	CHAR(10)
DECLARE @pubmonth		VARCHAR(20)
DECLARE @pubmonthyear		VARCHAR(20)
DECLARE @cartonqty		VARCHAR(20)
DECLARE @insertillus		VARCHAR(255)
DECLARE @media			VARCHAR(255)
DECLARE @mediacode		VARCHAR(40)
DECLARE @format			VARCHAR(255)
DECLARE @formatcode		VARCHAR(40)
DECLARE @pagecount		VARCHAR(20)
DECLARE @releaseqty		VARCHAR(20)
DECLARE @trimsize		VARCHAR(40)
DECLARE @usretailprice		VARCHAR(20)
DECLARE @usretaileffdate	VARCHAR(20)
DECLARE @canadianretailprice	VARCHAR(20)
DECLARE @canadianretaileffdate	VARCHAR(20)
DECLARE @ukretailprice		VARCHAR(20)
DECLARE @ukretaileffdate	VARCHAR(20)
DECLARE @season			VARCHAR(255)
DECLARE @seasoncode		VARCHAR(40)
DECLARE @discount		VARCHAR(255)
DECLARE @discountcode		VARCHAR(40)
DECLARE @territories		VARCHAR(255)
DECLARE @territoriescode	VARCHAR(40)
DECLARE @series			VARCHAR(255)
DECLARE @seriescode		VARCHAR(40)
DECLARE @edition		VARCHAR(255)
DECLARE @editioncode		VARCHAR(40)
DECLARE @language		VARCHAR(255)
DECLARE @languagecode		VARCHAR(40)
DECLARE @bisacstatus		VARCHAR(255)
DECLARE @bisacstatuscode	VARCHAR(40)
DECLARE @returns		VARCHAR(255)
DECLARE @returnscode		VARCHAR(40)
DECLARE @restrictions		VARCHAR(255)
DECLARE @restrictionscode	VARCHAR(40)
DECLARE @canadianrx		VARCHAR(255)
DECLARE @canadianrxcode		VARCHAR(40)
DECLARE @audience		VARCHAR(255)
DECLARE @audiencecode		VARCHAR(40)
DECLARE @pubdate		VARCHAR(20)
DECLARE @rowcount		INT
DECLARE @itemno			VARCHAR(20)
DECLARE @volume			VARCHAR(20)
DECLARE @editor1		VARCHAR(80)
DECLARE @editor2		VARCHAR(80)
DECLARE @sendtoelo		CHAR(1)
DECLARE @verify			VARCHAR(40)
DECLARE @firstprint		VARCHAR(20)
DECLARE @agerange		VARCHAR(20)
DECLARE @graderange		VARCHAR(20)
DECLARE @spinesize		VARCHAR(20)
DECLARE @barcode		CHAR(1)
DECLARE @otherformatcode	VARCHAR(40)
DECLARE @otherformat		VARCHAR(255)
DECLARE @releasedate		VARCHAR(20)


BEGIN
/*  GET ELEMENT VALUES OR SET VARIABLES AS BLANK		*/
	SET @rowcount = 0
	SET @o_errorcode = 0
	SET @o_errormsg = ''

	SET @isbn10 = COALESCE(dbo.get_ISBN(@bookkey,10),'')
	SET @isbn13 = COALESCE(dbo.get_ISBN(@bookkey,13),'')
	SET @ean = COALESCE(dbo.get_ISBN(@bookkey,16),'')
	SET @titleprefix = COALESCE(dbo.get_TitlePrefix(@bookkey),'')
	SET @title = COALESCE(dbo.get_title(@bookkey,'t'),'')
	SET @fulltitle = COALESCE(dbo.get_title(@bookkey,'f'),'')
	SET @searchtitle = COALESCE(dbo.get_title(@bookkey,'s'),'')
	SET @subtitle = COALESCE(dbo.get_subtitle(@bookkey),'')
	SET @shorttitle = COALESCE(dbo.get_shorttitle(@bookkey),'')
	SET @grouplevel1 = COALESCE(dbo.get_GroupLevel1(@bookkey,'F'),'')
	SET @grouplevel1code = COALESCE(dbo.get_GroupLevel1(@bookkey,'S'),'')
	SET @grouplevel2 = COALESCE(dbo.get_GroupLevel2(@bookkey,'F'),'')
	SET @grouplevel2code = COALESCE(dbo.get_GroupLevel3(@bookkey,'S'),'')
	SET @grouplevel3 = COALESCE(dbo.get_GroupLevel3(@bookkey,'F'),'')
	SET @grouplevel3code = COALESCE(dbo.get_GroupLevel3(@bookkey,'S'),'')
	SET @sendtoeloquence = COALESCE(dbo.get_SendtoEloquenceInd(@bookkey),'')
	SET @pubmonth = COALESCE(dbo.get_pubmonth(@bookkey,1,'M'),'')
	SET @pubmonthyear = COALESCE(dbo.get_pubmonth(@bookkey,1,'Y'),'')
	SET @cartonqty = COALESCE(dbo.get_cartonqty(@bookkey,1),'')
	SET @releaseqty = COALESCE(dbo.get_BestReleaseQty(@bookkey),'')
	SET @insertillus = COALESCE(dbo.get_BestInsertIllus(@bookkey,1),'')
	SET @media = COALESCE(dbo.get_Media(@bookkey,'D'),'')
	SET @mediacode = COALESCE(dbo.get_Media(@bookkey,'B'),'')
	SET @format = COALESCE(dbo.get_Format(@bookkey,'D'),'')
	SET @formatcode =  COALESCE(dbo.get_Format(@bookkey,'B'),'')
	SET @pagecount = COALESCE(dbo.get_BestPageCount(@bookkey,1),'')
	SET @trimsize = COALESCE(dbo.get_BestTrimSize(@bookkey,1),'')
	SET @usretailprice = COALESCE(dbo.get_BestUSPrice(@bookkey,8),'')
	SET @usretaileffdate = COALESCE(dbo.get_BestUSPrice_EffDate(@bookkey,8),'')
	SET @canadianretailprice = COALESCE(dbo.get_BestCanadianPrice(@bookkey,8),'')
	SET @canadianretaileffdate = COALESCE(dbo.get_BestCanadianPrice_EffDate(@bookkey,8),'')
	SET @ukretailprice = COALESCE(dbo.get_BestUKPrice(@bookkey,8),'')
	SET @ukretaileffdate = COALESCE(dbo.get_BestUKPrice_EffDate(@bookkey,8),'')
	SET @season = COALESCE(dbo.get_BestSeason(@bookkey,1,'D'),'')
	SET @seasoncode = COALESCE(dbo.get_BestSeason(@bookkey,1,'S'),'')
	SET @series = COALESCE(dbo.get_series(@bookkey,'d'),'')
	SET @seriescode = COALESCE(dbo.get_series(@bookkey,'b'),'')
	SET @discount = COALESCE(dbo.get_Discount(@bookkey,'d'),'')
	SET @discountcode = COALESCE(dbo.get_discount(@bookkey,'b'),'')
	SET @territories = COALESCE(dbo.get_territory(@bookkey,'d'),'')
	SET @territoriescode = COALESCE(dbo.get_territory(@bookkey,'b'),'')
	SET @edition = COALESCE(dbo.get_edition(@bookkey,'d'),'')
	SET @editioncode = COALESCE(dbo.get_edition(@bookkey,'S'),'')
	SET @language = COALESCE(dbo.get_language(@bookkey,'d'),'')
	SET @languagecode = COALESCE(dbo.get_language(@bookkey,'b'),'')
	SET @bisacstatus = COALESCE(dbo.get_bisacstatus(@bookkey,'d'),'')
	SET @bisacstatuscode = COALESCE(dbo.get_bisacstatus(@bookkey,'b'),'')
	SET @returns = COALESCE(dbo.get_returnind(@bookkey,'d'),'')
	SET @returnscode = COALESCE(dbo.get_returnind(@bookkey,'b'),'')
	SET @restrictions = COALESCE(dbo.get_returnrestriction(@bookkey,'d'),'')
	SET @restrictionscode = COALESCE(dbo.get_returnrestriction(@bookkey,'b'),'')
	SET @canadianrx = COALESCE(dbo.get_canadianrestriction(@bookkey,'d'),'')
	SET @canadianrxcode = COALESCE(dbo.get_canadianrestriction(@bookkey,'b'),'')
	SET @audience = COALESCE(dbo.get_audience(@bookkey,'d',1),'')
	SET @audiencecode = COALESCE(dbo.get_audience(@bookkey,'s',1),'')
	SET @pubdate = COALESCE(dbo.get_BestPubDate(@bookkey,1),'')
	SET @volume = COALESCE(dbo.get_SeriesVolume(@bookkey),'')
	SET @editor1 = COALESCE(dbo.get_WebRolePerson(@bookkey,1,'D'),'')
	SET @editor2 = COALESCE(dbo.get_WebRolePerson(@bookkey,2,'D'),'')
	SET @verify = COALESCE(dbo.get_TitleVerifyStatus(@bookkey,'D'),'')
	SET @firstprint = COALESCE(dbo.get_BestAnncd1stPrint(@bookkey,1),'')
	SET @agerange = COALESCE(dbo.get_AgeRange(@bookkey),'')
	SET @graderange = COALESCE(dbo.get_GradeRange(@bookkey),'')
	SET @spinesize = COALESCE(dbo.get_SpineSize(@bookkey,1),'')
	SET @barcode = COALESCE(dbo.get_CustomInd01(@bookkey),'')
	SET @otherformatcode = COALESCE(dbo.get_otherformat(@bookkey,'d'),'')
	SET @otherformat = COALESCE(dbo.get_otherformat(@bookkey,'b'),'')
	SET @releasedate = COALESCE(dbo.get_BestReleaseDate(@bookkey,1),'')


	SELECT @itemno = COALESCE(itemnumber,''),
		@upc = COALESCE(upc,'')
	FROM isbn
	WHERE bookkey = @bookkey

	SELECT @sendtoelo = CASE
				WHEN sendtoeloind = 1  THEN 'Y'
				ELSE	'N'
			END
	FROM book
	WHERE bookkey = @bookkey


	INSERT INTO export_title(bookkey,itemno,isbn10,isbn13,ean,upc,titleprefix,title,fulltitle,searchtitle,subtitle,shorttitle,grouplevel1,grouplevel1code,grouplevel2,grouplevel2code,grouplevel3,grouplevel3code,
				sendtoeloquence,pubmonth,pubmonthyear,cartonqty,insertillus,mediacode,media,formatcode,[format],pagecount,releaseqty,trimsize,usretailprice,usretaileffdate,
				canadianretailprice,canadianretaildate,ukretailprice,ukretaildate,seasoncode,season,seriescode,series,discountcode,discount,territoriescode,territories,
				editioncode,edition,languagecode,language,bisacstatuscode,bisacstatus,returncode,[return],restrictioncode,restriction,canadianrxcode,canadianrx,
				audiencecode,audience,pubdate,releasedate,volume,editor1,editor2,sendtoeloind,verifycode,anncd1stprint,agerange,graderange,spinesize,barcodeind,otherformatcode,otherformat)
	VALUES (@bookkey,@itemno,@isbn10,@isbn13,@ean,@upc,@titleprefix,@title,@fulltitle,@searchtitle,@subtitle,@shorttitle,@grouplevel1,@grouplevel1code,@grouplevel2,@grouplevel2code,@grouplevel3,@grouplevel3code,
		@sendtoeloquence,@pubmonth,@pubmonthyear,@cartonqty,@insertillus,@mediacode,@media,@formatcode,@format,@pagecount,@releaseqty,@trimsize,@usretailprice,@usretaileffdate,
		@canadianretailprice,@canadianretaileffdate,@ukretailprice,@ukretaileffdate,@seasoncode,@season,@seriescode,@series,@discountcode,@discount,@territoriescode,@territories,
		@editioncode,@edition,@languagecode,@language,@bisacstatuscode,@bisacstatus,@returnscode,@returns,@restrictionscode,@restrictions,@canadianrxcode,@canadianrx,
		@audiencecode,@audience,@pubdate,@releasedate,@volume,@editor1,@editor2,@sendtoelo,@verify,@firstprint,@agerange,@graderange,@spinesize,@barcode,@otherformatcode,@otherformat)

	SELECT @o_errorcode = @@ERROR, @rowcount = @@ROWCOUNT

	IF @o_errorcode <> 0 
		BEGIN
        		SET @o_errorcode = 1
        		SET @o_errormsg = 'Unable insert ('+@bookkey+') into the export_title table'
		END 


END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

