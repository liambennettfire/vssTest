/****** Object:  StoredProcedure [dbo].[aph_web_feed_info]    Script Date: 12/09/2008 15:10:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_Category_Insert_Program_SubCategory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_Category_Insert_Program_SubCategory]


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<jhess>
-- Create date: <05/07/2009>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[qweb_ecf_Category_Insert_Program_SubCategory] (@i_tableid int,@i_datacode int) as

DECLARE @unpcategory_fetch_status int,
		@v_categorydesc varchar(40),
		@v_datasubcode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_sortorder int,
		@v_deletestatus varchar (1),
		@rowcount int

BEGIN

	DECLARE c_pss_unpsubcategories INSENSITIVE CURSOR
	FOR

	Select datadesc, datasubcode, COALESCE(sortorder,0), deletestatus
	from APH..subgentables
	where tableid = @i_tableid
	and datacode = @i_datacode
	--and deletestatus<>'Y'
	
	FOR READ ONLY
			
	OPEN c_pss_unpsubcategories

	/* get the next one*/	
	FETCH NEXT FROM c_pss_unpsubcategories
		INTO @v_categorydesc,@v_datasubcode,@i_sortorder, @v_deletestatus

	select  @unpcategory_fetch_status  = @@FETCH_STATUS

	while (@unpcategory_fetch_status >-1 )
	begin
	  IF (@unpcategory_fetch_status <>-2) 
	  begin
		  --Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID(@i_parent_datadesc)
		  -- get the parent categoryid using tableid and datacode (not description because there may be a duplicate)
				Select @parent_categoryid = ObjectId
				from CategoryEx_Title_Program
				where pss_program_categorytableid = @i_tableid
				and pss_program_datacode = @i_datacode
				and pss_program_datasubcode = 0

				Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Title_Program_SubCategory')
				Select @d_datetime = getdate()
				Select @i_categorytemplateid = categorytemplateid from categorytemplate where name = 'Category Simple Template'

				--Select * FROM categorytemplate
				--Select * FROM MetaClass
				--select * FROM CategoryEx_Title_Subject_SubCategory
				--
				--Select * FROM Category
				--where categoryid > 538
				--and categoryid < 548

				--print 	@parent_categoryid
				--print  @i_metaclassid
				--print  @i_categorytemplateid

				select @rowcount = count(*) from category 
				where parentcategoryid = @parent_categoryid
				and name = @v_categorydesc


				IF @rowcount>0 and @v_deletestatus='Y'
					begin
						update category set isvisible=0 where parentcategoryid=@parent_categoryid  and [name] = @v_categorydesc
					end	

				ELSE IF @v_deletestatus='N'
					--if this entry already exists in CategoryEx_Title_Subject_SubCategory table 
					--then the user changed the data desc of subcategory (or inactive flag) in TMM, only update
					--if it doesn't exist then insert a new record

					begin
						If exists (select * from CategoryEx_Title_Program_SubCategory where pss_program_categorytableid = @i_tableid and pss_program_datacode = @i_datacode and pss_program_datasubcode=@v_datasubcode)
							begin
									DECLARE @catid int
									Select @catid = objectid from CategoryEx_Title_Program_SubCategory where pss_Program_categorytableid = @i_tableid and pss_program_datacode = @i_datacode and pss_program_datasubcode=@v_datasubcode
									
									DECLARE @typeid int, 
											@pageurl nvarchar(255),
											@updated_date datetime,
											@created_date datetime,
											@IsInherited bit,
											@Code nvarchar(50)
									
									if exists (Select * FROM Category where categoryid = @catid)
													Begin

														Select @typeid = Typeid, @pageurl = PageUrl, 
															@updated_date = Updated, 
															@created_date = Created,@IsInherited = IsInherited,
															@Code = Code FROM Category where categoryid = @catid

														exec CategoryUpdate
														@catid,				--@CategoryId int = NULL output,
														@v_categorydesc,	--@Name nvarchar(50),
														@i_sortorder,		--@Ordering int = NULL,
														1,					--@IsVisible bit = NULL,
														@parent_categoryid,	--@ParentCategoryId int = NULL,
														@i_categorytemplateid,--@CategoryTemplateId int = NULL,
														@typeid,			--@TypeId int = NULL,
														@pageurl,			--@PageUrl nvarchar(255) = null,	
														1,					--@ObjectLanguageId int = NULL output,
														1,					--@LanguageId int,
														@i_metaclassid,		--@MetaClassId int = NULL,
														0,					--@ObjectGroupId int = 0,
														@updated_date,		--@Updated datetime = NULL,
														@created_date,		--@Created datetime = NULL,
														@IsInherited,		--@IsInherited bit = 0
														@Code				--@Code nvarchar(50)
													end
							
							end
						else --must be new subject category but check to make sure this name doesn't exist in category table
							if not exists (Select * from category 
												where parentcategoryid = @parent_categoryid
		   											and name = @v_categorydesc)
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
									1,					--@IsInherited bit = 0
									null				--@code nvarchar
								
									Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

									exec dbo.mdpsp_avto_CategoryEx_Title_Program_SubCategory_Update
									@Current_ObjectID,			 --@ObjectId INT, 
									1,							 --@CreatorId INT, 
									@d_datetime,				 --@Created DATETIME, 
									1,							 --@ModifierId INT, 
									@d_datetime,				 --@Modified DATETIME, 
									null,						 --@Retval INT OUT, 
									@i_tableid,						 --@pss_subject_categorytableid int, 
									@i_datacode,					 --@pss_subject_datacode int, 
									@v_datasubcode				 --@pss_subject_datasubcode int 

								end	

					end
				
      end

	  FETCH NEXT FROM c_pss_unpsubcategories
		  INTO @v_categorydesc,@v_datasubcode,@i_sortorder, @v_deletestatus
		  
	  select  @unpcategory_fetch_status = @@FETCH_STATUS
    end

  close c_pss_unpsubcategories
  deallocate c_pss_unpsubcategories
END

