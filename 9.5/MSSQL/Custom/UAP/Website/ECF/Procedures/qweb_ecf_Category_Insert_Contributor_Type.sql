if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Category_Insert_Contributor_Type]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Category_Insert_Contributor_Type]

GO


CREATE procedure [dbo].[qweb_ecf_Category_Insert_Contributor_Type] as

DECLARE @contrib_fetch_status int,
		@i_globalcontactkey int,
        @authortype varchar(40),
		@authortypecode varchar(40),
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@Current_ObjectID int,
		@i_categorytemplateid int

BEGIN

	DECLARE c_pss_contributor_types INSENSITIVE CURSOR
	FOR

	Select distinct g.globalcontactkey, UAP.dbo.get_gentables_desc(134,ba.authortypecode,''),ba.authortypecode
	from UAP..globalcontact g, UAP..bookauthor ba
	where ba.authorkey = g.globalcontactkey
	and ba.bookkey IN (Select bookkey from UAP..bookdetail where publishtowebind = 1)

	FOR READ ONLY
			
	OPEN c_pss_contributor_types

	/* Get next bookkey that has more than one citation row */	
	FETCH NEXT FROM c_pss_contributor_types
		INTO @i_globalcontactkey, @authortype, @authortypecode

	select  @contrib_fetch_status  = @@FETCH_STATUS	

	 while (@contrib_fetch_status >-1 )
		begin
		IF (@contrib_fetch_status <>-2) 
		begin


			Select @parent_categoryid = objectid from CategoryEx_Contributor where pss_globalcontactkey = @i_globalcontactkey
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Contributor_Type_Category')
			Select @d_datetime = getdate()
			Select @i_categorytemplateid  = categorytemplateid from categorytemplate where name = 'Category Simple Template'
			
			exec CategoryInsert
			NULL,				--@CategoryId int = NULL output,
			@authortype,		--@Name nvarchar(50),
			0,					--@Ordering int = NULL,
			1,					--@IsVisible bit = NULL,
			@parent_categoryid,	--@ParentCategoryId int = NULL,
			@i_categorytemplateid,--@CategoryTemplateId int = NULL,
			0,					--@TypeId int = NULL,
			Null,				--@PageUrl nvarchar(255) = null,	
			1,					--@ObjectLanguageId int = NULL output,
			1,					--@LanguageId int,
			@i_metaclassid,		--@MetaClassId int = NULL,
			0,					--@ObjectGroupId int = 0,
			@d_datetime,		--@Updated datetime = NULL,
			@d_datetime,		--@Created datetime = NULL,
			1					--@IsInherited bit = 0

			Select @Current_ObjectID = IDENT_CURRENT('Category')

			exec [mdpsp_avto_CategoryEx_Contributor_Type_Category_Update]
			@Current_ObjectID,	 --@ObjectId INT, 
			1,					 --@CreatorId INT, 
			@d_datetime,		 --@Created DATETIME, 
			1,					 --@ModifierId INT, 
			@d_datetime,		 --@Modified DATETIME, 
			NULL,				 --@Retval INT OUT, 
			@authortype,		 --@Contributor_Type nvarchar(512) , 
			@authortypecode		 --@pss_roletypecode int 

		end

	FETCH NEXT FROM c_pss_contributor_types
		INTO @i_globalcontactkey, @authortype, @authortypecode
	        select  @contrib_fetch_status = @@FETCH_STATUS
		end

close c_pss_contributor_types
deallocate c_pss_contributor_types


END

GO
Grant execute on dbo.qweb_ecf_Category_Insert_Contributor_Type to Public
GO