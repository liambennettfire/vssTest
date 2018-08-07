if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_get_TitleInfo]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[qweb_get_TitleInfo]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO



CREATE FUNCTION qweb_get_TitleInfo(@bookkey	INT)
RETURNS @titleinfo TABLE(
	bookkey			INT,
	isbn10			VARCHAR(10),
	isbn13			VARCHAR(13),
	ean			VARCHAR(17),
	ean13			VARCHAR(13),
	upc			VARCHAR(20),
	itemno			VARCHAR(20),
	titleprefix			VARCHAR(20),
	title			VARCHAR(255),		
	fulltitle			VARCHAR(260),
	searchtitle		VARCHAR(255),
	subtitle			VARCHAR(255),
	shorttitle			VARCHAR(50),
	grouplevel1		VARCHAR(40),
	grouplevel1code		VARCHAR(255),
	grouplevel2		VARCHAR(40),
	grouplevel2code		VARCHAR(255),
	grouplevel3		VARCHAR(40),
	grouplevel3code		VARCHAR(255),
	sendtoeloquence		VARCHAR(20),
	pubmonth		VARCHAR(20),
	pubmonthyear		VARCHAR(20),
	cartonqty		VARCHAR(20),
	insertillus			VARCHAR(255),
	media			VARCHAR(40),
	mediacode		VARCHAR(40),
	[format]			VARCHAR(40),
	formatcode		VARCHAR(40),
	pagecount		VARCHAR(20),
	releaseqty		VARCHAR(20),
	trimsize			VARCHAR(40),
	usretailprice		VARCHAR(20),
	usretaileffdate		VARCHAR(20),
	canadianretailprice		VARCHAR(20),
	canadianretaileffdate	VARCHAR(20),
	ukretailprice		VARCHAR(20),
	ukretaileffdate		VARCHAR(20),
	season			VARCHAR(40),
	seasoncode		VARCHAR(40),
	discount			VARCHAR(40),
	discountcode		VARCHAR(40),
	territories		VARCHAR(40),
	territoriescode		VARCHAR(255),
	series			VARCHAR(40),
	seriescode		VARCHAR(255),
	edition			VARCHAR(40),
	editioncode		VARCHAR(255),
	language			VARCHAR(40),
	languagecode		VARCHAR(40),
	bisacstatus		VARCHAR(40),
	bisacstatuscode		VARCHAR(40),
	[returns]			VARCHAR(40),
	returnscode		VARCHAR(40),
	restrictions		VARCHAR(40),
	restrictionscode		VARCHAR(40),
	canadianrx		VARCHAR(40),
	canadianrxcode		VARCHAR(40),
	audience			VARCHAR(40),
	audiencecode		VARCHAR(255),
	pubdate			VARCHAR(20),
	volume			VARCHAR(20),
	editor1			VARCHAR(80),
	editor2			VARCHAR(80),
	sendtoeloind		VARCHAR(20),
	verify			VARCHAR(40),
	verifycode		VARCHAR(40),
	anncdfirstprint		VARCHAR(20),
	agerange			VARCHAR(20),
	graderange		VARCHAR(20),
	spinesize			VARCHAR(20),
	otherformatcode		VARCHAR(40),
	otherformat		VARCHAR(40),
	releasedate		VARCHAR(20),
	titleheading		VARCHAR(40),
	titleheadingcode		VARCHAR(40),
	fullauthordisplayname	VARCHAR(500),
	customerkey INT
)
AS
BEGIN


DECLARE @isbn10			VARCHAR(20),
	@isbn13			VARCHAR(20),
	@ean			VARCHAR(20),
	@ean13			VARCHAR(20),
	@upc			VARCHAR(20),
	@titleprefix		VARCHAR(20),
	@title			VARCHAR(255),		
	@fulltitle			VARCHAR(260),
	@searchtitle		VARCHAR(255),
	@subtitle			VARCHAR(255),
	@shorttitle		VARCHAR(50),
	@grouplevel1		VARCHAR(40),
	@grouplevel1code		VARCHAR(255),
	@grouplevel2		VARCHAR(40),
	@grouplevel2code		VARCHAR(255),
	@grouplevel3		VARCHAR(40),
	@grouplevel3code		VARCHAR(255),
	@sendtoeloquence		VARCHAR(20),
	@pubmonth		VARCHAR(20),
	@pubmonthyear		VARCHAR(20),
	@cartonqty		VARCHAR(20),
	@insertillus		VARCHAR(255),
	@media			VARCHAR(40),
	@mediacode		VARCHAR(255),
	@format			VARCHAR(40),
	@formatcode		VARCHAR(255),
	@pagecount		VARCHAR(20),
	@releaseqty		VARCHAR(20),
	@trimsize			VARCHAR(40),
	@usretailprice		VARCHAR(20),
	@usretaileffdate		VARCHAR(20),
	@canadianretailprice	VARCHAR(20),
	@canadianretaileffdate	VARCHAR(20),
	@ukretailprice		VARCHAR(20),
	@ukretaileffdate		VARCHAR(20),
	@season			VARCHAR(40),
	@seasoncode		VARCHAR(255),
	@discount		VARCHAR(40),
	@discountcode		VARCHAR(255),
	@territories		VARCHAR(40),
	@territoriescode		VARCHAR(255),
	@series			VARCHAR(40),
	@seriescode		VARCHAR(255),
	@edition			VARCHAR(40),
	@editioncode		VARCHAR(255),
	@language		VARCHAR(40),
	@languagecode		VARCHAR(255),
	@bisacstatus		VARCHAR(40),
	@bisacstatuscode		VARCHAR(255),
	@returns			VARCHAR(40),
	@returnscode		VARCHAR(255),
	@restrictions		VARCHAR(40),
	@restrictionscode		VARCHAR(255),
	@canadianrx		VARCHAR(40),
	@canadianrxcode		VARCHAR(255),
	@audience		VARCHAR(40),
	@audiencecode		VARCHAR(255),
	@pubdate		VARCHAR(20),
	@itemno			VARCHAR(20),
	@volume			VARCHAR(20),
	@editor1			VARCHAR(80),
	@editor2			VARCHAR(80),
	@sendtoeloind		VARCHAR(20),
	@verify			VARCHAR(40),

	@verifycode		VARCHAR(255),
	@anncdfirstprint		VARCHAR(20),
	@agerange		VARCHAR(20),
	@graderange		VARCHAR(20),
	@spinesize		VARCHAR(20),
	@otherformatcode		VARCHAR(40),
	@otherformat		VARCHAR(255),
	@releasedate		VARCHAR(20),
	@titleheading		VARCHAR(40),
	@titleheadingcode		VARCHAR(255),
	@fullauthordisplayname	VARCHAR(500),
	@customerkey INT




	SELECT @isbn10 = dbo.qweb_get_ISBN(@bookkey,'10')
	SELECT @isbn13 = dbo.qweb_get_ISBN(@bookkey,'13')
	SELECT @ean = dbo.qweb_get_ISBN(@bookkey,'16')
	SELECT @ean13 = dbo.qweb_get_ISBN(@bookkey,'17')
	SELECT @upc = dbo.qweb_get_ISBN(@bookkey,'21')
	SELECT @titleprefix = dbo.qweb_get_TitlePrefix(@bookkey)
	SELECT @title = dbo.qweb_get_Title(@bookkey,'t')
	SELECT @fulltitle = dbo.qweb_get_Title(@bookkey,'f')
	SELECT @searchtitle = dbo.qweb_get_Title(@bookkey,'s')
	SELECT @subtitle = dbo.qweb_get_SubTitle(@bookkey)
	SELECT @shorttitle =  dbo.qweb_get_ShortTitle(@bookkey)
	SELECT @grouplevel1 = dbo.qweb_get_GroupLevel1(@bookkey,'f')
	SELECT @grouplevel1code = dbo.qweb_get_GroupLevel1(@bookkey,'s')
	SELECT @grouplevel2 =  dbo.qweb_get_GroupLevel2(@bookkey,'f')
	SELECT @grouplevel2code = dbo.qweb_get_GroupLevel2(@bookkey,'s')
	SELECT @grouplevel3 = dbo.qweb_get_GroupLevel3(@bookkey,'f')
	SELECT @grouplevel3code = dbo.qweb_get_GroupLevel3(@bookkey,'s')
	SELECT @sendtoeloquence = dbo.qweb_get_SendtoEloquenceInd(@bookkey)
	SELECT @pubmonth = dbo.qweb_get_Pubmonth(@bookkey,1,'M')
	SELECT @pubmonthyear = dbo.qweb_get_Pubmonth(@bookkey,1,'Y')
	SELECT @cartonqty = COALESCE(dbo.qweb_get_cartonqty(@bookkey,1),'')
	SELECT @releaseqty = COALESCE(dbo.qweb_get_BestReleaseQty(@bookkey),'')
	SELECT @insertillus = COALESCE(dbo.qweb_get_BestInsertIllus(@bookkey,1),'')
	SELECT @media = COALESCE(dbo.qweb_get_Media(@bookkey,'D'),'')
	SELECT @mediacode = COALESCE(dbo.qweb_get_Media(@bookkey,'B'),'')
	SELECT @format = COALESCE(dbo.qweb_get_Format(@bookkey,'D'),'')
	SELECT @formatcode =  COALESCE(dbo.qweb_get_Format(@bookkey,'B'),'')
	SELECT @pagecount = COALESCE(dbo.qweb_get_BestPageCount(@bookkey,1),'')
	SELECT @trimsize = COALESCE(dbo.qweb_get_BestTrimSize(@bookkey,1),'')

        -- For prices get retail price and if that is is empty get list price
	SELECT @usretailprice = COALESCE(dbo.qweb_get_BestUSPrice(@bookkey,8),'')
        IF (@usretailprice = '') BEGIN
  	  SELECT @usretailprice = COALESCE(dbo.qweb_get_BestUSPrice(@bookkey,11),'')
        END  
	SELECT @usretaileffdate = COALESCE(dbo.qweb_get_BestUSPrice_EffDate(@bookkey,8),'')
        IF (@usretaileffdate = '') BEGIN
	  SELECT @usretaileffdate = COALESCE(dbo.qweb_get_BestUSPrice_EffDate(@bookkey,11),'')
        END  
	SELECT @canadianretailprice = COALESCE(dbo.qweb_get_BestPrice(@bookkey,8,11),'')
        IF (@canadianretailprice = '') BEGIN
  	  SELECT @canadianretailprice = COALESCE(dbo.qweb_get_BestPrice(@bookkey,11,11),'')
        END  
	SELECT @canadianretaileffdate = COALESCE(dbo.qweb_get_BestPrice_EffDate(@bookkey,8,11),'')
        IF (@canadianretaileffdate = '') BEGIN
	  SELECT @canadianretaileffdate = COALESCE(dbo.qweb_get_BestPrice_EffDate(@bookkey,11,11),'')
        END  
	SELECT @ukretailprice = COALESCE(dbo.qweb_get_BestPrice(@bookkey,8,37),'')
        IF (@ukretailprice = '') BEGIN
	  SELECT @ukretailprice = COALESCE(dbo.qweb_get_BestPrice(@bookkey,11,37),'')
        END  
	SELECT @ukretaileffdate = COALESCE(dbo.qweb_get_BestPrice_EffDate(@bookkey,8,37),'')
        IF (@ukretaileffdate = '') BEGIN
	  SELECT @ukretaileffdate = COALESCE(dbo.qweb_get_BestPrice_EffDate(@bookkey,11,37),'')
        END  

--	SELECT @season = COALESCE(dbo.qweb_get_BestSeason(@bookkey,1,'D'),'')
--	SELECT @seasoncode = COALESCE(dbo.qweb_get_BestSeason(@bookkey,1,'S'),'')
	SELECT @series = COALESCE(dbo.qweb_get_series(@bookkey,'d'),'')
	SELECT @seriescode = COALESCE(dbo.qweb_get_series(@bookkey,'b'),'')
	SELECT @discount = COALESCE(dbo.qweb_get_Discount(@bookkey,'d'),'')
	SELECT @discountcode = COALESCE(dbo.qweb_get_discount(@bookkey,'b'),'')
	SELECT @territories = COALESCE(dbo.qweb_get_territory(@bookkey,'d'),'')
	SELECT @territoriescode = COALESCE(dbo.qweb_get_territory(@bookkey,'s'),'')
	SELECT @edition = COALESCE(dbo.qweb_get_edition(@bookkey,'d'),'')
	SELECT @editioncode = COALESCE(dbo.qweb_get_edition(@bookkey,'s'),'')
	SELECT @language = COALESCE(dbo.qweb_get_language(@bookkey,'d'),'')
	SELECT @languagecode = COALESCE(dbo.qweb_get_language(@bookkey,'s'),'')
	SELECT @bisacstatus = COALESCE(dbo.qweb_get_bisacstatus(@bookkey,'d'),'')
	SELECT @bisacstatuscode = COALESCE(dbo.qweb_get_bisacstatus(@bookkey,'s'),'')
	SELECT @returns = COALESCE(dbo.qweb_get_returnind(@bookkey,'d'),'')
	SELECT @returnscode = COALESCE(dbo.qweb_get_returnind(@bookkey,'s'),'')
	SELECT @restrictions = COALESCE(dbo.qweb_get_returnrestriction(@bookkey,'d'),'')
	SELECT @restrictionscode = COALESCE(dbo.qweb_get_returnrestriction(@bookkey,'s'),'')
	SELECT @canadianrx = COALESCE(dbo.qweb_get_canadianrestriction(@bookkey,'d'),'')
	SELECT @canadianrxcode = COALESCE(dbo.qweb_get_canadianrestriction(@bookkey,'s'),'')
	SELECT @audience = COALESCE(dbo.qweb_get_audience(@bookkey,'d',1),'')
	SELECT @audiencecode = COALESCE(dbo.qweb_get_audience(@bookkey,'s',1),'')
	SELECT @pubdate = COALESCE(dbo.qweb_get_BestPubDate(@bookkey,1),'')
	SELECT @volume = COALESCE(dbo.qweb_get_SeriesVolume(@bookkey),'')
--	SELECT @editor1 = COALESCE(dbo.qweb_get_WebRolePerson(@bookkey,1,'d'),'')
--	SELECT @editor2 = COALESCE(dbo.qweb_get_WebRolePerson(@bookkey,2,'d'),'')
	SELECT @verify = COALESCE(dbo.qweb_get_TitleVerifyStatus(@bookkey,'d'),'')
	SELECT @verifycode = COALESCE(dbo.qweb_get_TitleVerifyStatus(@bookkey,'e'),'')
	SELECT @anncdfirstprint = COALESCE(dbo.qweb_get_BestAnncd1stPrint(@bookkey,1),'')
--	SELECT @agerange = COALESCE(dbo.qweb_get_AgeRange(@bookkey),'')
--	SELECT @graderange = COALESCE(dbo.qweb_get_GradeRange(@bookkey),'')
--	SELECT @spinesize = COALESCE(dbo.qweb_get_SpineSize(@bookkey,1),'')
	SELECT @volume = COALESCE(dbo.qweb_get_SeriesVolume(@bookkey),'')
--	SELECT @otherformat = COALESCE(dbo.qweb_get_OtherFormat(@bookkey,'d'),'')
	SELECT @otherformatcode = COALESCE(dbo.qweb_get_Format(@bookkey,'s'),'')
	SELECT @releasedate = COALESCE(dbo.qweb_get_BestReleaseDate(@bookkey,1),'')
--	SELECT @titleheading = COALESCE(dbo.qweb_get_TitleHeading(@bookkey,'d'),'')
--	SELECT @titleheadingcode = COALESCE(dbo.qweb_get_TitleHeading(@bookkey,'s'),'')
	SELECT @fullauthordisplayname = COALESCE(dbo.qweb_get_FullAuthorDisplayName(@bookkey),dbo.qweb_create_FullAuthorDisplayName(@bookkey,', '))
	SELECT @customerkey = (SELECT elocustomerkey FROM book WHERE bookkey = @bookkey)

	SELECT @itemno = COALESCE(itemnumber,'')
	FROM isbn
	WHERE bookkey = @bookkey




	INSERT INTO @titleinfo(bookkey,isbn10,isbn13,ean,ean13,upc,itemno,titleprefix,title,fulltitle,searchtitle,subtitle,shorttitle,grouplevel1,
			grouplevel1code,grouplevel2,grouplevel2code,grouplevel3,grouplevel3code,sendtoeloquence,pubmonth,pubmonthyear,
			cartonqty,insertillus,media,mediacode,[format],formatcode,pagecount,releaseqty,trimsize,usretailprice,usretaileffdate,
			canadianretailprice,canadianretaileffdate,ukretailprice,ukretaileffdate,season,seasoncode,discount,discountcode,
			territories,territoriescode,series,seriescode,edition,editioncode,language,languagecode,bisacstatus,bisacstatuscode,
			[returns],returnscode,restrictions,restrictionscode,canadianrx,canadianrxcode,audience,audiencecode,pubdate,volume,
			editor1,editor2,verify,verifycode,anncdfirstprint,agerange,graderange,spinesize,otherformatcode,otherformat,releasedate,
			titleheading,titleheadingcode,fullauthordisplayname,customerkey)
	VALUES (@bookkey,@isbn10,@isbn13,@ean,@ean13,@upc,@itemno,@titleprefix,@title,@fulltitle,@searchtitle,@subtitle,@shorttitle,
		@grouplevel1,@grouplevel1code,@grouplevel2,@grouplevel2code,@grouplevel3,@grouplevel3code,@sendtoeloquence,
		@pubmonth,@pubmonthyear,@cartonqty,@insertillus,@media,@mediacode,@format,@formatcode,@pagecount,@releaseqty,
		@trimsize,@usretailprice,@usretaileffdate,@canadianretailprice,@canadianretaileffdate,@ukretailprice,
		@ukretaileffdate,@season,@seasoncode,@discount,@discountcode,@territories,@territoriescode,@series,@seriescode,
		@edition,@editioncode,@language,@languagecode,@bisacstatus,@bisacstatuscode,@returns,@returnscode,@restrictions,
		@restrictionscode,@canadianrx,@canadianrxcode,@audience,@audiencecode,@pubdate,@volume,@editor1,@editor2,@verify,
		@verifycode,@anncdfirstprint,@agerange,@graderange,@spinesize,@otherformatcode,@otherformat,@releasedate,@titleheading,
		@titleheadingcode,@fullauthordisplayname,@customerkey)


return
end




GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

