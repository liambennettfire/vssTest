IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_CategoryExHeartsongStoreHome_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_CategoryExHeartsongStoreHome_Update]
go

create procedure [dbo].[qweb_ecf_CategoryExHeartsongStoreHome_Update] as

DECLARE @i_home_categoryid int,
		@d_datetime datetime,
		@v_featured_title_categoryid_home int,
		@v_novellas_categoryid_home int,
		@v_featured_author_categoryid int

BEGIN

	Select @i_home_categoryid = dbo.qweb_ecf_get_Category_ID('Heartsong Store Home')
	Select @v_featured_title_categoryid_home = dbo.qweb_ecf_get_Category_ID('Heartsong Store Featured Titles - Home')
	Select @v_novellas_categoryid_home = dbo.qweb_ecf_get_Category_ID('Heartsong Store Novellas - Home')
	Select @v_featured_author_categoryid = dbo.qweb_ecf_get_Category_ID('Romance Featured Author - Home Page')
	
	Select @d_datetime = getdate()

	exec [dbo].[mdpsp_avto_CategoryEx_HeartsongStore_Home_Update] 
	@i_home_categoryid,   --@ObjectId INT, 
	1,                    --@CreatorId INT, 
	@d_datetime,          --@Created DATETIME, 
	1,                    --@ModifierId INT, 
	@d_datetime,          --@Modified DATETIME, 
	NULL,                 --@Retval INT OUT, 
	@v_featured_title_categoryid_home,  --@pss_featuredtitle_categoryid
	@v_novellas_categoryid_home,  --@upcomingtitles_categoryid
	@v_featured_author_categoryid --@featured_author_categoryid

END

