IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_CategoryExAuthorHome_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_CategoryExAuthorHome_Update]
go

create procedure [dbo].[qweb_ecf_CategoryExAuthorHome_Update] as

DECLARE @i_home_categoryid int,
		@d_datetime datetime,
		@v_featured_author_categoryid int
		


BEGIN

	Select @i_home_categoryid = dbo.qweb_ecf_get_Category_ID('Authors')
	Select @v_featured_author_categoryid = dbo.qweb_ecf_get_Category_ID('Featured Author')
	
	Select @d_datetime = getdate()

	exec [dbo].[mdpsp_avto_CategoryEx_Author_Home_Update] 
	@i_home_categoryid,   --@ObjectId INT, 
	1,                    --@CreatorId INT, 
	@d_datetime,          --@Created DATETIME, 
	1,                    --@ModifierId INT, 
	@d_datetime,          --@Modified DATETIME, 
	NULL,                 --@Retval INT OUT, 
	@v_featured_author_categoryid --@featured_author_categoryid

END

