if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Category_Insert_Series]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Category_Insert_Series]

go

CREATE procedure [dbo].[qweb_ecf_Category_Insert_Series] as

DECLARE @category_fetch_status int,
		@v_categorydesc varchar(50),
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
		@v_alternatedesc1 varchar(255),
		@isVisible bit

BEGIN
  SET @v_tableid = 327

  DECLARE c_pss_series CURSOR fast_forward FOR

	Select rtrim(ltrim(datadesc)), datacode, COALESCE(sortorder,0) sortorder, deletestatus, COALESCE(alternatedesc1,'')
	from unl..gentables
	where tableid = @v_tableid
	--and deletestatus<>'Y'
	--and sortorder is not null
				
	OPEN c_pss_series

	/* get the next one*/	
	FETCH NEXT FROM c_pss_series
		INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus, @v_alternatedesc1

	select  @category_fetch_status  = @@FETCH_STATUS

	 while (@category_fetch_status >-1 )
		begin
		IF (@category_fetch_status <>-2) 
		begin

			Declare @v_Description varchar(max)
			SET @v_Description = ''

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Series')
			--print 	@parent_categoryid
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Title_Series')
			--print  @i_metaclassid
			Select @d_datetime = getdate()
			Select @i_categorytemplateid = categorytemplateid from categorytemplate where name = 'Series Category Template'
			--print  @i_categorytemplateid
			--print 'end var'
--			IF @v_deletestatus='Y'
--				delete from category where parentcategoryid = @parent_categoryid and name = @v_categorydesc
--				delete from categoryex_title_subject where pss_subject_datacode=@v_datacode
--			return

			
--      Select @v_Description = GeneralDescription
--      from CategoryEx_Title_Series
--      where pss_subject_categorytableid = @v_tableid
--        and pss_subject_datacode = @v_datacode
--        and pss_subject_datasubcode = 0

		Select @v_Description = '<b><i>'+cast(bb.commenthtmllite as varchar(2000))+'</i></b></br><P>'+cast(b.commenthtmllite as varchar(2000))+'</P>'
		from unl..bookcomments b
		join unl..bookdetail bd
		on b.bookkey = bd.bookkey
		join unl..bookcomments bb
		on bd.bookkey = bb.bookkey
		join unl..bookorgentry bo
		on bd.bookkey = bo.bookkey
		left outer join CategoryEx_Title_Series c
		on bd.seriescode = c.pss_subject_datacode
		where bb.commenttypecode=3 and bb.commenttypesubcode=73
		and b.commenttypecode=3 and b.commenttypesubcode=62
		and bo.orgentrykey=44
		and bd.seriescode= @v_datacode

--		Select @v_Description = '<b><i>'+cast(bb.commenthtmllite as varchar(2000))+'</i></b></br><P>'+cast(b.commenthtmllite as varchar(2000))+'</P>'
--		from unl..bookcomments bb, unl..bookcomments b, unl..bookdetail bd, CategoryEx_Title_Series c, unl..bookorgentry bo
--		where bb.commenttypecode=3 and bb.commenttypesubcode=73
--		and b.commenttypecode=3 and b.commenttypesubcode=62
--		and b.bookkey=bd.bookkey
--		and bb.bookkey=bd.bookkey
--		and bo.bookkey=bd.bookkey
--		and bd.seriescode *= c.pss_subject_datacode
--		and bo.orgentrykey=44
--		and bd.seriescode=@v_datacode
--        and pss_subject_categorytableid = @v_tableid
--        and pss_subject_datacode = @v_datacode
--        and pss_subject_datasubcode = 0
		select @v_Description = coalesce(@v_Description,'')
		
		If @v_deletestatus='N'
			SET @isVisible = 1
		else
			SET @isVisible = 0
			

			
			If not exists (Select * 
							from category 
							where parentcategoryid = @parent_categoryid
							  and [name] = @v_categorydesc)
		
			begin
				
				exec CategoryInsert
				NULL,				--@CategoryId int = NULL output,
				@v_categorydesc,	--@Name nvarchar(50),
				@i_sortorder,		--@Ordering int = NULL,
				@isVisible,			--@IsVisible bit = NULL,
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

				exec dbo.mdpsp_avto_CategoryEx_Title_Series_Update
				@Current_ObjectID,			 --@ObjectId INT, 
				1,							 --@CreatorId INT, 
				@d_datetime,				 --@Created DATETIME, 
				1,							 --@ModifierId INT, 
				@d_datetime,				 --@Modified DATETIME, 
				null,						 --@Retval INT OUT, 
				@v_tableid,		   --@pss_subject_categorytableid int
				@v_datacode,		  --@PSS_subject_datacode int
				0, 		            --@PSS_subject_datasubcode
				@v_Description    --@GeneralDescription
				--print 'title series inserted'
				print 'inserted a new category record for series ' +  @v_categorydesc + '  datacode=' + Cast(@v_datacode as varchar(10))
				print @v_Description
				print ''
			end
		else
			begin
			--already exists just update
				DECLARE @catid int
				Select @catid = CategoryId from category where parentcategoryid = @parent_categoryid and [name] = @v_categorydesc

				DECLARE @typeid int, 
						@pageurl nvarchar(255),
						@updated_date datetime,
						@created_date datetime,
						@IsInherited bit,
						@Code nvarchar(50)
				


						Select @typeid = Typeid, @pageurl = PageUrl, 
							@created_date = Created,@IsInherited = IsInherited,
							@Code = Code FROM Category where categoryid = @catid

						exec CategoryUpdate
						@catid,				--@CategoryId int = NULL output,
						@v_categorydesc,	--@Name nvarchar(50),
						@i_sortorder,		--@Ordering int = NULL,
						@isVisible,			--@IsVisible bit = NULL,
						@parent_categoryid,	--@ParentCategoryId int = NULL,
						@i_categorytemplateid,--@CategoryTemplateId int = NULL,
						@typeid,			--@TypeId int = NULL,
						@pageurl,			--@PageUrl nvarchar(255) = null,	
						1,					--@ObjectLanguageId int = NULL output,
						1,					--@LanguageId int,
						@i_metaclassid,		--@MetaClassId int = NULL,
						0,					--@ObjectGroupId int = 0,
						@d_datetime,		--@Updated datetime = NULL,
						@created_date,		--@Created datetime = NULL,
						@IsInherited,		--@IsInherited bit = 0
						@Code				--@Code nvarchar(50)

						exec dbo.mdpsp_avto_CategoryEx_Title_Series_Update
						@catid,						--@ObjectId INT, 
						1,							 --@CreatorId INT, 
						@d_datetime,				 --@Created DATETIME, 
						1,							 --@ModifierId INT, 
						@d_datetime,				 --@Modified DATETIME, 
						null,						 --@Retval INT OUT, 
						@v_tableid,		   --@pss_subject_categorytableid int
						@v_datacode,		  --@PSS_subject_datacode int
						0, 		            --@PSS_subject_datasubcode
						@v_Description    --@GeneralDescription
						
						print 'updated series ' +  @v_categorydesc + '  datacode=' + Cast(@v_datacode as varchar(10))
						print @v_Description
						print ''

			end
			
	end
  
	FETCH NEXT FROM c_pss_series
		INTO @v_categorydesc,@v_datacode,@i_sortorder,@v_deletestatus, @v_alternatedesc1

	select  @category_fetch_status = @@FETCH_STATUS
end

close c_pss_series
deallocate c_pss_series


END


GO
Grant execute on dbo.qweb_ecf_Category_Insert_Series to Public
GO
