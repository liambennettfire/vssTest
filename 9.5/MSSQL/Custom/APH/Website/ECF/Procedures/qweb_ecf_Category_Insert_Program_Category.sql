/****** Object:  StoredProcedure [dbo].[aph_web_feed_info]    Script Date: 12/09/2008 15:10:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_Program_Category]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_Program_Category]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<jhess>
-- Create date: <05/07/2009>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[qweb_ecf_Category_Insert_Program_Category] as

DECLARE @unpcategory_fetch_status int,
		@v_categorydesc varchar(40),
		@v_datacode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_sortorder int,
		@v_deletestatus varchar (1),
		@i_catcount int,
		@v_cnt int,
		@v_tableid int

BEGIN

	SET @v_tableid = 435

	DECLARE c_pss_unpcategories INSENSITIVE CURSOR
	FOR

	Select datadesc, datacode, sortorder, deletestatus
	from APH..gentables
	where tableid = @v_tableid
	--and deletestatus<>'Y'
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

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Programs')
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Title_Program')
			select @d_datetime = getdate()
			Select @i_categorytemplateid = categorytemplateid from categorytemplate where name = 'Category Simple Template'
						
			IF @v_deletestatus='Y'
			begin
				delete from category where parentcategoryid = @parent_categoryid and name = @v_categorydesc
			end			
			
			Select @i_catcount = count (*) from category where parentcategoryid = @parent_categoryid and [name] = @v_categorydesc 
			
			IF coalesce (@i_catcount,0) <1 and @v_deletestatus='N'
			
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
				@d_datetime,		--@Created datetime = NULL,
				1					--@IsInherited bit = 0
		
				Select @Current_ObjectID = IDENT_CURRENT( 'Category' )
			
				exec dbo.mdpsp_avto_CategoryEx_Title_Program_Update
				@Current_ObjectID,			 --@ObjectId INT, 
				1,							 --@CreatorId INT, 
				@d_datetime,				 --@Created DATETIME, 
				1,							 --@ModifierId INT, 
				@d_datetime,				 --@Modified DATETIME, 
				null,						 --@Retval INT OUT, 
				435,						 --@pss_subject_categorytableid int, 
				@v_datacode,					 --@pss_subject_datacode int, 
				0							 --@pss_subject_datasubcode int 
			
				end
		 end

		--This is where we insert the subcategories if they exist
		Select @v_cnt = count(*)
		from APH..subgentables
		where tableid = @v_tableid
		  and datacode = @v_datacode
		  
		if @v_cnt > 0 begin
		exec dbo.qweb_ecf_Category_Insert_Program_SubCategory @v_tableid, @v_datacode
	  end
	
	 FETCH NEXT FROM c_pss_unpcategories
	 INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus
	 select  @unpcategory_fetch_status = @@FETCH_STATUS
	 end

close c_pss_unpcategories
deallocate c_pss_unpcategories


END





