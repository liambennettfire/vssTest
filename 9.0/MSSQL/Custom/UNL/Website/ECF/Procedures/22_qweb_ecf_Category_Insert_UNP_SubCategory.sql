if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Category_Insert_UNP_SubCategory]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Category_Insert_UNP_SubCategory]
GO
CREATE procedure [dbo].[qweb_ecf_Category_Insert_UNP_SubCategory] (@i_tableid int,@i_datacode int) as

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
		@rowcount int,
		@MaxSort int,
		@increment int



BEGIN

	SET @increment = 1

	Select @MaxSort = Max(sortorder) from  UNL..subgentables
	where tableid = @i_tableid
	and datacode = @i_datacode

	/*if no sorting is set in TMM set maxsort to 10, 
	assign maxsort + (increment+1)*10 to each element
	this should work when part of the items have sortorder assigned

	*/	
	If @MaxSort is null
		SET @MaxSort = 10
	

	DECLARE c_pss_unpsubcategories INSENSITIVE CURSOR
	FOR

	Select datadesc, datasubcode, sortorder, deletestatus
	from UNL..subgentables
	where tableid = @i_tableid
	and datacode = @i_datacode
	ORDER BY sortorder, datadesc

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

			If @i_sortorder is null
				begin
					SET @increment = @increment + 1
					SET @i_sortorder = @MaxSort + @increment*10
					Print 'Sort order set to ' + Cast(@i_sortorder as varchar(20)) + ' for ' + @v_categorydesc
				end

		  --Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID(@i_parent_datadesc)
		  -- get the parent categoryid using tableid and datacode (not description because there may be a duplicate)
				Select @parent_categoryid = ObjectId
				from CategoryEx_Title_Subject
				where pss_subject_categorytableid = @i_tableid
				and pss_subject_datacode = @i_datacode
				and pss_subject_datasubcode = 0

				Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Title_Subject_SubCategory')
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
						If exists (select * from CategoryEx_Title_Subject_SubCategory where pss_subject_categorytableid = @i_tableid and pss_subject_datacode = @i_datacode and pss_subject_datasubcode=@v_datasubcode)
							begin
									DECLARE @catid int
									Select @catid = objectid from CategoryEx_Title_Subject_SubCategory where pss_subject_categorytableid = @i_tableid and pss_subject_datacode = @i_datacode and pss_subject_datasubcode=@v_datasubcode
									
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

									exec dbo.mdpsp_avto_CategoryEx_Title_Subject_SubCategory_Update
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


GO
Grant execute on dbo.qweb_ecf_Category_Insert_UNP_SubCategory to Public
GO