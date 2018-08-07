USE [TAMU_ECF_DEV]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_CategoryExHome_Update]    Script Date: 05/12/2009 11:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[qweb_ecf_CategoryExHome_Update] as

DECLARE @i_home_categoryid int,
		@i_title_categoryid int,
		@i_journal_categoryid int,
		@i_upcomingtitles_categoryid int,
		@i_giftServices_categoryid int,
		@d_datetime datetime,
		@n_UNP_News varchar(max),
		@n_SpecialOffers varchar(max),
		@n_SpecialMessages varchar(max),
		@v_seasonalcatalog_path varchar(max),
		@v_seasonalcatalogimage_path varchar(max),
		@v_MostPopularList varchar(max),
		@v_DownloadCatalogList varchar(max)

BEGIN

	Select @i_home_categoryid = dbo.qweb_ecf_get_Category_ID('Home')
	Select @i_upcomingtitles_categoryid = 0
	Select @i_title_categoryid = dbo.qweb_ecf_get_Category_ID('Home Page Feature')
	Select @i_giftServices_categoryid = dbo.qweb_ecf_get_Category_ID('Gift Services')

	Select @i_journal_categoryid = 0
	Select @d_datetime = getdate()
	select @v_seasonalcatalog_path = seasonalcatalog from categoryex_home where objectid = @i_home_categoryid
	select @v_seasonalcatalogimage_path = seasonalcatalogimage from categoryex_home where objectid = @i_home_categoryid

Select @n_UNP_News = ''
Select @n_SpecialOffers = ''
Select @n_SpecialMessages = ''
Select @v_MostPopularList = ''
Select @v_DownloadCatalogList = ''


Select @n_UNP_News = UNP_News,
	   @n_SpecialOffers = Special_Offers,
	   @n_SpecialMessages = Special_Messages,
	   @v_MostPopularList = Most_Popular_List,
	   @v_DownloadCatalogList = Download_Catalog_List
from CategoryEx_Home
where objectid = @i_home_categoryid

	

	exec [dbo].[mdpsp_avto_CategoryEx_Home_Update] 
	@i_home_categoryid,				--@ObjectId INT, 
	1,								--@CreatorId INT,  
	@d_datetime,					--@Created DATETIME,  
	1,								--@ModifierId INT,
	@d_datetime,					--@Modified DATETIME, 
	NULL,							--@Retval INT OUT,  
	0,								--@pss_featuredtitle_categoryid int,
	@i_title_categoryid,			--@featuredproduct_categoryid int, 
	@v_seasonalcatalog_path,		--@SeasonalCatalog nvarchar(       512) , 
	@i_upcomingtitles_categoryid,	--@upcomingtitles_categoryid int, 
	@v_MostPopularList,				--@Most_Popular_List ntext, 
	@v_DownloadCatalogList,			--@Download_Catalog_List ntext, 
	@i_giftServices_categoryid,							--@giftServices_categoryid int, 
	@v_seasonalcatalogimage_path,	--@seasonalcatalogimage	
	@i_journal_categoryid,			--@newthismonth_categoryid int, 
	0,								--@pss_featuredjournal_categoryid int, 
	@n_UNP_News,					--@UNP_News ntext, 
	@n_SpecialOffers,				--@Special_Offers ntext, 
	@n_SpecialMessages				--@Special_Messages ntext






END



