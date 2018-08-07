if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Category_Insert_MajorPressSubject_Category]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Category_Insert_MajorPressSubject_Category]

GO


CREATE procedure [dbo].[qweb_ecf_Category_Insert_MajorPressSubject_Category] as

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
		@rowcount int,
		@alternatedesc1 varchar(255),
		@v_cnt int,
		@v_tableid int,
		@MaxSort int,
		@increment int



BEGIN

	SET @v_tableid = 413

	SET @increment = 1

	Select @MaxSort = Max(sortorder) from  UAP..gentables
	where tableid = @v_tableid

	/*if no sorting is set in TMM set maxsort to 10, 
	assign maxsort + (increment+1)*10 to each element
	this should work when part of the items have sortorder assigned

	*/	
	If @MaxSort is null
		SET @MaxSort = 10


	DECLARE c_pss_uapcategories INSENSITIVE CURSOR
	FOR

	Select datadesc, datacode, sortorder, deletestatus, alternatedesc1
	from UAP..gentables
	where tableid = @v_tableid
	Order By sortorder, alternatedesc1
	--and deletestatus<>'Y'
	--and sortorder is not null



	FOR READ ONLY
			
	OPEN c_pss_uapcategories

	/* get the next one*/	
	FETCH NEXT FROM c_pss_uapcategories
		INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus, @alternatedesc1

	select  @unpcategory_fetch_status  = @@FETCH_STATUS

	 while (@unpcategory_fetch_status >-1 )
		begin
		IF (@unpcategory_fetch_status <>-2) 
		begin

			If @i_sortorder is null
				begin
					SET @increment = @increment + 1
					SET @i_sortorder = @MaxSort + @increment*10
				end

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('MajorPressSubjects')
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Title_MajorPressSubject')
			Select @d_datetime = getdate()
			Select @i_categorytemplateid = categorytemplateid from categorytemplate where name = 'Category Simple Template'
		
			select @rowcount = count(*) from category 
						where parentcategoryid = @parent_categoryid
			   		    and name = @v_categorydesc

			
			IF @rowcount>0 and @v_deletestatus='Y'
				begin
				update category set isvisible=0 where parentcategoryid=@parent_categoryid  and [name] = @v_categorydesc
				--delete from categoryex_title_subject where pss_subject_datacode=@v_datacode
				end	
			
			ELSE IF @v_deletestatus='N'
		
					begin 
						If @alternatedesc1 is not null --use alternatedesc
							SET @v_categorydesc = @alternatedesc1
							-- if a title subject record already exists just update the category table
							-- this will update name field with alternate desc in category table
							-- also, if the user changes the description or alternatedesc field in TMM 
							-- we will be changing the existing record in category table rather than inserting a new one
						If exists (select * from CategoryEx_Title_MajorPressSubject where pss_subject_categorytableid = @v_tableid and pss_subject_datacode = @v_datacode)
							begin
									DECLARE @catid int
									Select @catid = objectid from CategoryEx_Title_MajorPressSubject where pss_subject_categorytableid = @v_tableid and pss_subject_datacode = @v_datacode
									
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
						else --must be new subject category but check to make sure this name doesn't exist in category
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
											
								exec dbo.mdpsp_avto_CategoryEx_Title_MajorPressSubject_Update
								@Current_ObjectID,			 --@ObjectId INT, 
								1,							 --@CreatorId INT, 
								@d_datetime,				 --@Created DATETIME, 
								1,							 --@ModifierId INT, 
								@d_datetime,				 --@Modified DATETIME, 
								null,						 --@Retval INT OUT, 
								@v_tableid,						 --@pss_subject_categorytableid int, 
								@v_datacode,					 --@pss_subject_datacode int, 
								0							 --@pss_subject_datasubcode int 

							end			

					end
		end

	--This is where we insert the subcategories if they exist
--	Select @v_cnt = count(*)
--	from UAP..subgentables
--	where tableid = @v_tableid
--	  and datacode = @v_datacode
--	  
--	if @v_cnt > 0 begin
--    exec dbo.qweb_ecf_Category_Insert_UNP_SubCategory @v_tableid, @v_datacode
--  end

	FETCH NEXT FROM c_pss_uapcategories
		INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus, @alternatedesc1
	        select  @unpcategory_fetch_status = @@FETCH_STATUS
	end

close c_pss_uapcategories
deallocate c_pss_uapcategories


END


GO
Grant execute on dbo.qweb_ecf_Category_Insert_MajorPressSubject_Category to Public
GO