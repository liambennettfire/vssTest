if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_CategoryExAuthorHome_Update]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_CategoryExAuthorHome_Update]


CREATE procedure [dbo].[qweb_ecf_CategoryExAuthorHome_Update] as

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



GO
Grant execute on dbo.qweb_ecf_CategoryExAuthorHome_Update to Public
GO