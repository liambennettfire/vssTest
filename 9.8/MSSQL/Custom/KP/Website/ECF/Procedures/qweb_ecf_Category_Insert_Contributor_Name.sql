if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Category_Insert_Contributor_Name]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Category_Insert_Contributor_Name]

GO


CREATE procedure [dbo].[qweb_ecf_Category_Insert_Contributor_Name] as

DECLARE @contrib_fetch_status int,
		@i_globalcontactkey int,
        @displayname varchar(255),
		@parent_categoryid int,
		@d_datetime datetime,
		@i_metaclassid int,
		@v_lastname varchar(75),
		@v_firstname varchar(75),
		@v_displayname varchar(255),
		@Current_ObjectID int,
		@i_Categorytemplateid int

BEGIN

	DECLARE c_pss_contributor_names INSENSITIVE CURSOR
	FOR

	Select distinct g.globalcontactkey, displayname
	from cbd..globalcontact g, cbd..bookauthor ba
	where ba.authorkey = g.globalcontactkey
	and ba.bookkey IN (Select bookkey from cbd..bookdetail where publishtowebind = 1)
	order by 2

	FOR READ ONLY
			
	OPEN c_pss_contributor_names

	/* Get next bookkey that has more than one citation row */	
	FETCH NEXT FROM c_pss_contributor_names
		INTO @i_globalcontactkey, @displayname

	select  @contrib_fetch_status  = @@FETCH_STATUS

	 while (@contrib_fetch_status >-1 )
		begin
		IF (@contrib_fetch_status <>-2) 
		begin


			Select @parent_categoryid = dbo.qweb_ecf_get_Category_ID('Contributors')
			Select @i_metaclassid = dbo.qweb_ecf_get_MetaClassID ('Contributor')
			Select @d_datetime = getdate()
			Select @i_Categorytemplateid  = categorytemplateid from categorytemplate where name = 'Category Simple Template'
			Select @v_lastname = lastname,
				   @v_firstname = firstname,
				   @v_displayname = displayname
			FROM cbd..globalcontact
					WHERE globalcontactkey = @i_globalcontactkey
			
			exec CategoryInsert
			NULL,				--@CategoryId int = NULL output,
			@displayname,		--@Name nvarchar(50),
			0,					--@Ordering int = NULL,
			1,					--@IsVisible bit = NULL,
			@parent_categoryid,	--@ParentCategoryId int = NULL,
			@i_Categorytemplateid, --@CategoryTemplateId int = NULL,
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

			exec dbo.mdpsp_avto_CategoryEx_Contributor_Update
			@Current_ObjectID,			 --@ObjectId INT, 
			1,							--@CreatorId INT, 
			@d_datetime,				--@Created DATETIME, 
			1,							--@ModifierId INT, 
			@d_datetime,				--@Modified DATETIME, 
			NULL,						--@Retval INT OUT, 
			@i_globalcontactkey,		--@pss_globalcontactkey int, 
			@v_firstname,				--@Contributor_First_Name nvarchar(       512) , 
			null,						--@Contributor_Middle_Name nvarchar(       512) , 
			@v_lastname,				--@Contributor_Last_Name nvarchar(       512) , 
			@v_displayname,				--@Contributor_Display_Name nvarchar(       512) , 
			0,							--@Contributor_Primary_Ind int, 
			0							--@Contributor_Sort_Order int 

	end

	FETCH NEXT FROM c_pss_contributor_names
		INTO @i_globalcontactkey, @displayname
	        select  @contrib_fetch_status = @@FETCH_STATUS
		end

close c_pss_contributor_names
deallocate c_pss_contributor_names


END

GO
Grant execute on dbo.qweb_ecf_Category_Insert_Contributor_Name to Public
GO