USE [BT_TB_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_Distributors]    Script Date: 01/27/2010 16:48:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[qweb_ecf_Category_Insert_Distributors] as

DECLARE @category_fetch_status int,
		@v_categorydesc varchar(50),
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_sortorder int,
		@v_deletestatus varchar (1),
		@v_cnt int

BEGIN

  DECLARE c_pss_distributors CURSOR fast_forward FOR

	Select o.orgentrydesc
	from BT..orgentry o
	where orglevelkey = 3
	and orgentrykey = 9
				
	OPEN c_pss_distributors

	/* get the next one*/	
	FETCH NEXT FROM c_pss_distributors
		INTO @v_categorydesc

	select  @category_fetch_status  = @@FETCH_STATUS

	 while (@category_fetch_status >-1 )
		begin
		IF (@category_fetch_status <>-2) 
		begin

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Distributors')
			--print 	@parent_categoryid
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Title_Catalogs')
			--print  @i_metaclassid
			Select @d_datetime = getdate()
			Select @i_categorytemplateid = categorytemplateid from categorytemplate where name = 'Category Simple Template'
			--print  @i_categorytemplateid
			--print 'end var'
--			IF @v_deletestatus='Y'
--				delete from category where parentcategoryid = @parent_categoryid and name = @v_categorydesc
--				delete from categoryex_title_subject where pss_subject_datacode=@v_datacode
--			return

			
			If not exists (Select * 
							from category 
							where parentcategoryid = @parent_categoryid
							  and [name] = @v_categorydesc)
		
			begin
			
			exec CategoryInsert
			NULL,				--@CategoryId int = NULL output,
			@v_categorydesc,		--@Name nvarchar(50),
			1,		--@Ordering int = NULL,
			1,					--@IsVisible bit = NULL,
			@parent_categoryid,	--@ParentCategoryId int = NULL,
			@i_categorytemplateid,--@CategoryTemplateId int = NULL,
			0,					--@TypeId int = NULL,
			null,				--@PageUrl nvarchar(255) = null,	
			1,					--@ObjectLanguageId int = NULL output,
			1,					--@LanguageId int,
			@i_metaclassid,		--@MetaClassId int = NULL,
			0,					--@ObjectGroupId int = 0,
			@d_datetime,		--@Updated datetime = NULL,
			@d_datetime,		--@ALTERd datetime = NULL,
			1					--@IsInherited bit = 0
		
			--print 'cateogry inserted'
			Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

			exec dbo.mdpsp_avto_CategoryEx_Title_Distributors_Update
			@Current_ObjectID,			 --@ObjectId INT, 
			1,							 --@CreatorId INT, 
			@d_datetime,				 --@ALTERd DATETIME, 
			1,							 --@ModifierId INT, 
			@d_datetime,				 --@Modified DATETIME, 
			null,						 --@Retval INT OUT, 
			@v_categorydesc,		--@DistributorName nvarchar(512)
			3,		--@PSS_Orglevelkey nvarchar(512)
			9 		--@PSS_Orgentrykey nvarchar(512)
			--print 'title subject inserted'
			end
	end
  
	FETCH NEXT FROM c_pss_distributors
		INTO @v_categorydesc
	select  @category_fetch_status = @@FETCH_STATUS
		end

close c_pss_distributors
deallocate c_pss_distributors


END



