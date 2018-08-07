IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_Truly_Yours_Catalog]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_Truly_Yours_Catalog]
go

create procedure [dbo].[qweb_ecf_Category_Insert_Truly_Yours_Catalog] as

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
		@v_cnt int,
		@v_year varchar(4)

BEGIN

  DECLARE c_pss_catalogs CURSOR fast_forward FOR

	Select barb.dbo.fn_TitleCase(c.catalogtitle), c.catalogkey, COALESCE(cs.sortorder,0) sortorder,
		     substring(cs.description, 1, 4) clubyear
	from barb..catalog c, barb..catalogsection cs
	where c.catalogkey = cs.catalogkey
	  and lower(rtrim(ltrim(c.catalogtitle))) = 'truly yours'
	order by sortorder
				
	OPEN c_pss_catalogs

	/* get the next one*/	
	FETCH NEXT FROM c_pss_catalogs
		INTO @v_categorydesc,@v_catalogkey,@i_sortorder,@v_year

	select  @category_fetch_status  = @@FETCH_STATUS

	 while (@category_fetch_status >-1 )
		begin
		IF (@category_fetch_status <>-2) 
		begin

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Truly Yours Fiction')
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
							  and [name] = @v_year)
		
			begin
			
			exec CategoryInsert
			NULL,				--@CategoryId int = NULL output,
			@v_year,		--@Name nvarchar(50),
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
			@d_datetime,		--@Created datetime = NULL,
			1					--@IsInherited bit = 0
		
			--print 'cateogry inserted'
			Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

			exec dbo.mdpsp_avto_CategoryEx_Title_Catalogs_Update
			@Current_ObjectID,			 --@ObjectId INT, 
			1,							 --@CreatorId INT, 
			@d_datetime,				 --@Created DATETIME, 
			1,							 --@ModifierId INT, 
			@d_datetime,				 --@Modified DATETIME, 
			null,						 --@Retval INT OUT, 
			@v_catalogkey,		--@pss_CatalogKey int, 
			@v_categorydesc		--@CatalogName int 
			--print 'title subject inserted'
			end
	end
  
	FETCH NEXT FROM c_pss_catalogs
		INTO @v_categorydesc,@v_catalogkey,@i_sortorder,@v_year
		
	select  @category_fetch_status = @@FETCH_STATUS
end

close c_pss_catalogs
deallocate c_pss_catalogs


END
