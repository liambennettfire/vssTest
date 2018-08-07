USE [BT_SD_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_Catalog]    Script Date: 01/27/2010 16:21:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[qweb_ecf_Category_Insert_Catalog] as

DECLARE @category_fetch_status int,
		@v_categorydesc varchar(50),
		@v_catalogkey int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_sortorder int,
		@v_deletestatus varchar (1),
		@v_cnt int

BEGIN

  DECLARE c_pss_catalogs CURSOR fast_forward FOR

	Select c.catalogtitle, c.catalogkey, COALESCE(c.sortorder,0)
	from BT..catalog c
	where purposetypecode = 4   -- purposetype = online
	and catalogstatuscode = 2   -- status = finalized
				
	OPEN c_pss_catalogs

	/* get the next one*/	
	FETCH NEXT FROM c_pss_catalogs
		INTO @v_categorydesc,@v_catalogkey,@i_sortorder

	select  @category_fetch_status  = @@FETCH_STATUS

	 while (@category_fetch_status >-1 )
		begin
		IF (@category_fetch_status <>-2) 
		begin

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Catalogs')
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
			@i_sortorder,		--@Ordering int = NULL,
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

			exec dbo.mdpsp_avto_CategoryEx_Title_Catalogs_Update
			@Current_ObjectID,			 --@ObjectId INT, 
			1,							 --@CreatorId INT, 
			@d_datetime,				 --@ALTERd DATETIME, 
			1,							 --@ModifierId INT, 
			@d_datetime,				 --@Modified DATETIME, 
			null,						 --@Retval INT OUT, 
			@v_catalogkey,		--@pss_CatalogKey int, 
			@v_categorydesc		--@CatalogName int 
			--print 'title subject inserted'
			end
	end
  
	FETCH NEXT FROM c_pss_catalogs
		INTO @v_categorydesc,@v_catalogkey,@i_sortorder
	select  @category_fetch_status = @@FETCH_STATUS
		end

close c_pss_catalogs
deallocate c_pss_catalogs


END



