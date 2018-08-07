if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_CategoryExHome_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_CategoryExHome_Update]

GO


CREATE procedure [dbo].[qweb_ecf_CategoryExHome_Update] as

DECLARE @i_home_categoryid int,
		@i_title_categoryid int,
		@i_journal_categoryid int,
		@d_datetime datetime,
		@n_UNP_News varchar(max),
		@n_SpecialOffers varchar(max),
		@n_SpecialMessages varchar(max),
		@v_seasonalcatalog_path varchar(max),
		@v_seasonalcatalogimage_path varchar(max)
		


BEGIN

	Select @i_home_categoryid = dbo.qweb_ecf_get_Category_ID('Home')
	Select @i_title_categoryid = dbo.qweb_ecf_get_Category_ID('Featured Titles')
	--Select @i_journal_categoryid = dbo.qweb_ecf_get_Category_ID('Featured Home Page')
	Select @d_datetime = getdate()
	select @v_seasonalcatalog_path = seasonalcatalog from categoryex_home where objectid = @i_home_categoryid
	select @v_seasonalcatalogimage_path = seasonalcatalogimage from categoryex_home where objectid = @i_home_categoryid

Select @n_UNP_News = ''
Select @n_SpecialOffers = ''
Select @n_SpecialMessages = ''


Select @n_UNP_News = UNP_News,
	   @n_SpecialOffers = Special_Offers,
	   @n_SpecialMessages = Special_Messages
from CategoryEx_Home
where objectid = @i_home_categoryid

	

	exec [dbo].[mdpsp_avto_CategoryEx_Home_Update] 
	@i_home_categoryid,   --@ObjectId INT, 
	1,                    --@CreatorId INT, 
	@d_datetime,          --@Created DATETIME, 
	1,                    --@ModifierId INT, 
	@d_datetime,          --@Modified DATETIME, 
	NULL,                 --@Retval INT OUT, 
	0,					  --@pss_featuredtitle_categoryid int, 
	@i_title_categoryid,  --@featuredproduct_categoryid int, 
	@v_seasonalcatalog_path,				  --@seasonalcatalog
	@v_seasonalcatalogimage_path,					--@seasonalcatalogimage	
	0, -- journals are not listed on home page for UAP
	--@i_journal_categoryid,--@newthismonth_categoryid int, 
	0,					  --@pss_featuredjournal_categoryid int, 
	@n_UNP_News,		  --@UNP_News ntext, 
	@n_SpecialOffers,	  --@Special_Offers ntext, 
	@n_SpecialMessages	  --@Special_Messages ntext




END
GO
Grant execute on dbo.qweb_ecf_CategoryExHome_Update to Public
GO