IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_CategoryExRomanceHome_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_CategoryExRomanceHome_Update]
go

create procedure [dbo].[qweb_ecf_CategoryExRomanceHome_Update] as

DECLARE @i_home_categoryid int,
		@d_datetime datetime,
		@v_featured_title_categoryid int,
		@v_upcoming_title_categoryid int,
		@v_featured_author_categoryid int,
		@v_LastTitleNum int,
		@v_MonthNum int

BEGIN

	Select @i_home_categoryid = dbo.qweb_ecf_get_Category_ID('Heartsong Romance Home')
	Select @v_featured_title_categoryid = dbo.qweb_ecf_get_Category_ID('Romance Featured Titles')
	Select @v_upcoming_title_categoryid = dbo.qweb_ecf_get_Category_ID('Romance Upcoming Titles')
	Select @v_featured_author_categoryid = dbo.qweb_ecf_get_Category_ID('Romance Featured Author - Home Page')
	
	Select @d_datetime = getdate()

  Select @v_LastTitleNum = 0
  Select @v_MonthNum = 0

  Select @v_LastTitleNum = LastFeaturedTitleNumber,
         @v_MonthNum = BookClubMonthNum
  from CategoryEx_Romance_Home
  where objectid = @i_home_categoryid

	exec [dbo].[mdpsp_avto_CategoryEx_Romance_Home_Update] 
	@i_home_categoryid,   --@ObjectId INT, 
	1,                    --@CreatorId INT, 
	@d_datetime,          --@Created DATETIME, 
	1,                    --@ModifierId INT, 
	@d_datetime,          --@Modified DATETIME, 
	NULL,                 --@Retval INT OUT, 
	@v_MonthNum,          --@BookClubMonthNum,
	@v_featured_title_categoryid,  --@pss_featuredtitle_categoryid
	@v_upcoming_title_categoryid,  --@upcomingtitles_categoryid
	@v_featured_author_categoryid, --@featured_author_categoryid
	@v_LastTitleNum       --@LastFeaturedTitleNumber

END

