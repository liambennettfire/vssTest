if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Category_Insert_Author_WebFeature]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Category_Insert_Author_WebFeature]


CREATE procedure [dbo].[qweb_ecf_Category_Insert_Author_WebFeature] as

DECLARE @WebFeature_fetch_status int,
		@v_categorydesc varchar(40),
		@v_datacode int,
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int,
		@v_tableid int

BEGIN
  set @v_tableid = 431

	DECLARE c_pss_WebFeature INSENSITIVE CURSOR
	FOR
	  Select datadesc, datacode
	  from uap..gentables
	  where tableid = @v_tableid
	  and deletestatus<>'Y'
	  --and datacode <> 4  -- Do not import publish to web category Publish to web

	FOR READ ONLY
			
	OPEN c_pss_WebFeature

	FETCH NEXT FROM c_pss_WebFeature
		INTO @v_categorydesc,@v_datacode

	select  @WebFeature_fetch_status  = @@FETCH_STATUS

  while (@WebFeature_fetch_status >-1 )
	begin
		IF (@WebFeature_fetch_status <>-2) 
		begin

			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Author Web Feature')
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

	  FETCH NEXT FROM c_pss_WebFeature
		INTO @v_categorydesc,@v_datacode
		
	  select  @WebFeature_fetch_status = @@FETCH_STATUS
  end

  close c_pss_WebFeature
  deallocate c_pss_WebFeature

END

GO
Grant execute on dbo.qweb_ecf_Category_Insert_Author_WebFeature to Public
GO