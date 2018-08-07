USE [BT_TB_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_UNP_Category]    Script Date: 01/27/2010 16:48:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[qweb_ecf_Category_Insert_UNP_Category] as

DECLARE @unpcategory_fetch_status int,
		@v_categorydesc varchar(40),
		@v_tableid int,
		@v_datacode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_sortorder int,
		@v_deletestatus varchar (1),
		@v_cnt int,
		@v_SubjectDescription varchar(max),
		@v_SubjectCategoryId1 int,
		@v_SubjectCategoryId2 int

BEGIN

  SET @v_tableid = 413
  
	DECLARE c_pss_unpcategories INSENSITIVE CURSOR
	FOR

	Select datadesc, datacode, COALESCE(sortorder,0) sortorder, deletestatus
	from BT..gentables
	where tableid = @v_tableid
	and deletestatus<>'Y'
	--and sortorder is not null
	

	FOR READ ONLY
			
	OPEN c_pss_unpcategories

	/* get the next one*/	
	FETCH NEXT FROM c_pss_unpcategories
		INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus

	select  @unpcategory_fetch_status  = @@FETCH_STATUS

	 while (@unpcategory_fetch_status >-1 )
		begin
		IF (@unpcategory_fetch_status <>-2) 
		begin

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Subjects')
			print 	@parent_categoryid
			print '@v_categorydesc'
			print @v_categorydesc
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Title_Subject')
			--print  @i_metaclassid
			Select @d_datetime = getdate()
			Select @i_categorytemplateid = categorytemplateid from categorytemplate where name = 'Subject Category Template'
			--print  @i_categorytemplateid
			--print 'end var'
--			IF @v_deletestatus='Y'
--				delete from category where parentcategoryid = @parent_categoryid and name = @v_categorydesc
--				delete from categoryex_title_subject where pss_subject_datacode=@v_datacode
--			return

      Select @v_SubjectDescription = SubjectDescription,
	         @v_SubjectCategoryId1 = SubjectCategoryId1,
	         @v_SubjectCategoryId2 = SubjectCategoryId2
      from CategoryEx_Title_Subject
      where pss_subject_categorytableid = @v_tableid
        and pss_subject_datacode = @v_datacode
        and pss_subject_datasubcode = 0
			
			if @v_SubjectCategoryId1 is null begin
			  set @v_SubjectCategoryId1 = 0
			end
			if @v_SubjectCategoryId2 is null begin
			  set @v_SubjectCategoryId2 = 0
			end

			If not exists (Select * 
							from category 
							where parentcategoryid = @parent_categoryid
							  and [name] = @v_categorydesc)
		
			begin
			
			exec CategoryInsert
			NULL,				--@CategoryId int = NULL output,
			@v_categorydesc,	--@Name nvarchar(50),
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
			1,					--@IsInherited bit = 0
			0					--@code
		
--			print 'cateogry inserted'
			Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

--			exec dbo.mdpsp_avto_CategoryEx_Title_Subject_Update
--			@Current_ObjectID,			 --@ObjectId INT, 
--			1,							 --@CreatorId INT, 
--			@d_datetime,				 --@ALTERd DATETIME, 
--			1,							 --@ModifierId INT, 
--			@d_datetime,				 --@Modified DATETIME, 
--			null,						 --@Retval INT OUT, 
--			@v_tableid,						 --@pss_subject_categorytableid int, 
--			@v_SubjectDescription,  --@SubjectDescription,
--			@v_SubjectCategoryId1,  --@SubjectCategoryId1,
--			@v_datacode,					 --@pss_subject_datacode int, 
--			0,							 --@pss_subject_datasubcode int 
--			@v_SubjectCategoryId2  --@SubjectCategoryId2
--			print 'title subject inserted'

			exec dbo.mdpsp_avto_CategoryEx_Title_Subject_Update
			@Current_ObjectID,			--			@ObjectId INT, 
			1,							--			@CreatorId INT, 
			@d_datetime,				--			@ALTERd DATETIME, 
			1,							--			@ModifierId INT, 
			@d_datetime,				--			@Modified DATETIME, 
			null,						--			@Retval INT OUT, 
			null,						--			@MetaDescription nvarchar(       512) , 
			null,						--			@MetaKeywords nvarchar(       512) , 
			null,						--			@Page_Content ntext, 
			@v_SubjectDescription,		--			@SubjectDescription ntext, 
			@v_tableid,					--			@pss_subject_categorytableid int, 
			@v_datacode,				--			@pss_subject_datacode int, 
			@v_SubjectCategoryId1,		--			@SubjectCategoryId1 int, 
			@v_SubjectCategoryId2,		--			@SubjectCategoryId2 int,
			0							--			@pss_subject_datasubcode

			end
	end

	Select @v_cnt = count(*)
	from BT..subgentables
	where tableid = @v_tableid
	  and datacode = @v_datacode
	  and datadesc is not null
	if @v_cnt > 0 begin
    exec dbo.qweb_ecf_Category_Insert_UNP_SubCategory @v_tableid, @v_datacode, @v_categorydesc
  end
  
	FETCH NEXT FROM c_pss_unpcategories
		INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus
	        select  @unpcategory_fetch_status = @@FETCH_STATUS
		end

close c_pss_unpcategories
deallocate c_pss_unpcategories


END










