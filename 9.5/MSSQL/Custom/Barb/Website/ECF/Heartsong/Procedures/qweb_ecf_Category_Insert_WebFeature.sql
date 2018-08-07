IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_WebFeature]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_WebFeature]
go

CREATE procedure [dbo].[qweb_ecf_Category_Insert_WebFeature] as

DECLARE @unpWebFeature_fetch_status int,
		@v_categorydesc varchar(40),
		@v_tableid int,
		@v_datacode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_pss_featuredjournal_categoryid int,
		@v_cnt int

BEGIN

  set @v_tableid = 431
  
	DECLARE c_pss_unpWebFeature INSENSITIVE CURSOR
	FOR

	Select datadesc, datacode
	from barb..gentables
	where tableid = @v_tableid
	and deletestatus<>'Y'

	FOR READ ONLY
			
	OPEN c_pss_unpWebFeature

	FETCH NEXT FROM c_pss_unpWebFeature
		INTO @v_categorydesc,@v_datacode

	select  @unpWebFeature_fetch_status  = @@FETCH_STATUS

	 while (@unpWebFeature_fetch_status >-1 )
		begin
		IF (@unpWebFeature_fetch_status <>-2) 
		begin

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Web Feature')
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Web_Feature')
			Select @d_datetime = getdate()
			Select @i_categorytemplateid  = categorytemplateid from categorytemplate where name = 'Category Simple Template'

			If not exists (Select * from category
							where parentcategoryid = @parent_categoryid		
							  and name = @v_categorydesc)

			begin
			
			  exec CategoryInsert
			  NULL,				--@CategoryId int = NULL output,
			  @v_categorydesc,		--@Name nvarchar(50),
			  0,					--@Ordering int = NULL,
			  1,					--@IsVisible bit = NULL,
			  @parent_categoryid,	--@ParentCategoryId int = NULL,
			  @i_categorytemplateid, --@CategoryTemplateId int = NULL,
			  0,					--@TypeId int = NULL,
			  null,				--@PageUrl nvarchar(255) = null,	
			  1,					--@ObjectLanguageId int = NULL output,
			  1,					--@LanguageId int,
			  @i_metaclassid,		--@MetaClassId int = NULL,
			  0,					--@ObjectGroupId int = 0,
			  @d_datetime,		--@Updated datetime = NULL,
			  @d_datetime,		--@Created datetime = NULL,
			  1					--@IsInherited bit = 0
  		

			  Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

			  exec dbo.mdpsp_avto_CategoryEx_Web_Feature_Update
			  @Current_ObjectID,			 --@ObjectId INT, 
			  1,							 --@CreatorId INT, 
			  @d_datetime,				 --@Created DATETIME, 
			  1,							 --@ModifierId INT, 
			  @d_datetime,				 --@Modified DATETIME, 
			  null,						 --@Retval INT OUT, 
			  @v_tableid,						 --@pss_subject_categorytableid int, 
			  @v_datacode,				 --@pss_subject_datacode int, 
			  0							 --@pss_subject_datasubcode int 

			end
	end

	Select @v_cnt = count(*)
	from barb..subgentables
	where tableid = @v_tableid
	  and datacode = @v_datacode
	  
	if @v_cnt > 0 begin
    exec dbo.qweb_ecf_Category_Insert_WebFeature_SubCategory @v_tableid, @v_datacode, @v_categorydesc
  end

	FETCH NEXT FROM c_pss_unpWebFeature
		INTO @v_categorydesc,@v_datacode
	        select  @unpWebFeature_fetch_status = @@FETCH_STATUS
		end

close c_pss_unpWebFeature
deallocate c_pss_unpWebFeature


--			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('New This Month')
--			Select @i_pss_featuredjournal_categoryid = dbo.qweb_ecf_get_Category_ID('Featured Journal & Bison')

		


--			exec dbo.mdpsp_avto_CategoryEx_Home_Update
--			@parent_categoryid,		            --@ObjectId INT, 
--			1,						            --@CreatorId INT, 
--			@d_datetime,			            --@Created DATETIME, 
--			0,						            --@ModifierId INT, 
--			@d_datetime,			            --@Modified DATETIME, 
--			NULL,					            --@Retval INT OUT, 
--			@parent_categoryid,		            --@pss_featuredtitle_categoryid int, 
--			NULL,				                --@UNP_News ntext, 
--			NULL,				                --@Special_Offers ntext, 
--			@i_pss_featuredjournal_categoryid,	--@pss_featuredjournal_categoryid int 
--		    NULL				                --@Special_Messages ntext






END



