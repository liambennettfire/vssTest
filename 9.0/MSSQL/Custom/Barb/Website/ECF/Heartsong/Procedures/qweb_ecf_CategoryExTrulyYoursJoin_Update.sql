IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_CategoryExTrulyYoursJoin_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_CategoryExTrulyYoursJoin_Update]
go

create procedure [dbo].[qweb_ecf_CategoryExTrulyYoursJoin_Update] as

DECLARE @i_home_categoryid int,
		@d_datetime datetime,
		@v_featured_title_categoryid int,
		@v_BookClubJoinDescription varchar(max)

BEGIN

	Select @i_home_categoryid = dbo.qweb_ecf_get_Category_ID('Truly Yours Join')
	Select @v_featured_title_categoryid = dbo.qweb_ecf_get_Category_ID('Truly Yours Free Book')
	
	Select @d_datetime = getdate()

  Select @v_BookClubJoinDescription = ''

  Select @v_BookClubJoinDescription = BookClubJoinDescription
  from CategoryEx_TrulyYours_Join
  where objectid = @i_home_categoryid

	exec [dbo].[mdpsp_avto_CategoryEx_TrulyYours_Join_Update] 
	@i_home_categoryid,   --@ObjectId INT, 
	1,                    --@CreatorId INT, 
	@d_datetime,          --@Created DATETIME, 
	1,                    --@ModifierId INT, 
	@d_datetime,          --@Modified DATETIME, 
	NULL,                 --@Retval INT OUT, 
	@v_featured_title_categoryid, --@featured_author_categoryid,
	@v_BookClubJoinDescription  --@BookClubJoinDescription

END

