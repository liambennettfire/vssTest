USE [BT_TB_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_Category_Insert_UNP_SubCategory]    Script Date: 01/27/2010 16:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[qweb_ecf_Category_Insert_UNP_SubCategory] (@i_tableid int,@i_datacode int,@i_parent_datadesc varchar(40)) as

DECLARE @unpcategory_fetch_status int,
		@v_categorydesc varchar(40),
		@v_datasubcode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@i_sortorder int

BEGIN

	DECLARE c_pss_unpsubcategories INSENSITIVE CURSOR
	FOR

	Select datadesc, datasubcode, COALESCE(sortorder,0)
	from BT..subgentables
	where tableid = @i_tableid
	and datacode = @i_datacode
	and len(isnull(datadesc,'')) > 0
	and deletestatus<>'Y'
	
	FOR READ ONLY
			
	OPEN c_pss_unpsubcategories

	/* get the next one*/	
	FETCH NEXT FROM c_pss_unpsubcategories
		INTO @v_categorydesc,@v_datasubcode,@i_sortorder

	select  @unpcategory_fetch_status  = @@FETCH_STATUS

	while (@unpcategory_fetch_status >-1 )
	begin
	  IF (@unpcategory_fetch_status <>-2) 
	  begin
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
		
			--print 	@parent_categoryid
			--print  @i_metaclassid
			--print  @i_categorytemplateid

		  If not exists (Select * 
						from category 
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
		    @d_datetime,		--@ALTERd datetime = NULL,
		    1					--@IsInherited bit = 0
	

		    Select @Current_ObjectID = IDENT_CURRENT( 'Category' )

		    exec dbo.mdpsp_avto_CategoryEx_Title_Subject_SubCategory_Update
		    @Current_ObjectID,			 --@ObjectId INT, 
		    1,							 --@CreatorId INT, 
		    @d_datetime,				 --@ALTERd DATETIME, 
		    1,							 --@ModifierId INT, 
		    @d_datetime,				 --@Modified DATETIME, 
		    null,						 --@Retval INT OUT, 
		    @i_tableid,						 --@pss_subject_categorytableid int, 
		    @i_datacode,					 --@pss_subject_datacode int, 
		    @v_datasubcode				 --@pss_subject_datasubcode int 

		  end
    end

	  FETCH NEXT FROM c_pss_unpsubcategories
		  INTO @v_categorydesc,@v_datasubcode,@i_sortorder
		  
	  select  @unpcategory_fetch_status = @@FETCH_STATUS
  end

  close c_pss_unpsubcategories
  deallocate c_pss_unpsubcategories
END



