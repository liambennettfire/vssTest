if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_Insert_Products_Authors]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_Insert_Products_Authors]
GO

CREATE procedure [dbo].[qweb_ecf_Insert_Products_Authors] (@i_bookkey int, @v_importtype varchar(1)) as

DECLARE @v_contactkey int,
		@v_fetchstatus int,
		@i_MetaClassID int,
		@v_displayname nvarchar(50),
		@v_lastname nvarchar(512),
		@v_firstname nvarchar(512),
		@v_middlename nvarchar(512),
		@d_datetime datetime,
		@d_createdate datetime,
		@pss_publishtowebind int,
		@product_id int,
		@i_template_id int,
		@i_pubtoweb_count int
		
BEGIN

  DECLARE c_pss_authors CURSOR fast_forward FOR
	  Select authorkey, displayname, c.firstname, c.middlename, c.lastname
  	  from cbd..bookauthor b, cbd..bookdetail bd, cbd..globalcontact c
	   where b.bookkey = bd.bookkey
	     and b.authorkey = c.globalcontactkey
	 	   and b.bookkey = @i_bookkey
	 	   and bd.publishtowebind=1
				
	OPEN c_pss_authors
	
	FETCH NEXT FROM c_pss_authors
		INTO @v_contactkey, @v_displayname, @v_firstname, @v_middlename, @v_lastname

	select  @v_fetchstatus  = @@FETCH_STATUS

	while (@v_fetchstatus >-1) begin
	  IF (@v_fetchstatus <>-2) begin

--			Select @v_displayname = Substring(@v_displayname,1,50)
			SELECT @v_displayname =  
						CASE 
							  WHEN @v_firstname IS  NULL THEN ''
						ELSE @v_firstname
	     				END
				         
					 +CASE 
			 				  WHEN @v_middlename IS NULL and @v_firstname is NOT NULL THEN ' '
								WHEN @v_middlename IS NULL and @v_firstname is NULL THEN ''
								WHEN @v_middlename is NOT NULL and @v_firstname is NOT NULL THEN ' '+@v_middlename+ ' '
        				ELSE ''
					END

					 + @v_lastname


			Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Contributors')
			Select @d_datetime = getdate()
			Select @i_template_id = ProductTemplateID from producttemplate where name = 'Author Template'
						
			If not exists (Select * from product where code = cast(@v_contactkey as varchar)) 
			begin
				exec dbo.ProductInsert
				NULL,					--@ProductId
				@v_displayname,				--@Name
				1,	--@Visible
				@i_template_id,			--@ProductTemplateId  --using book template for now
				@i_MetaClassID,			--@MetaClassId
				@d_datetime,			--@Updated
				@d_datetime,			--@Created
				1,						--@ObjectLanguageId
				1,						--@LanguageId
				0,						--@ObjectGroupId
				0,						--@IsInherited
				@v_contactkey				--@Code (bookkey)
			end

			If exists (Select * from product where code = cast(@v_contactkey as varchar))
			begin

				Select @product_id = dbo.qweb_ecf_get_product_id(@v_contactkey)	
				Select @d_createdate = created from product where code = cast(@v_contactkey as varchar)

				exec dbo.ProductUpdate
				@product_id,			--@ProductId int,
				@v_displayname,				--@Name nvarchar(50),
				NULL,					--@Description ntext = NULL,
				NULL,					--@Features ntext = NULL,
				1,	--@Visible bit = NULL,
				@i_template_id,			--@ProductTemplateId int = NULL,
				@i_MetaClassID,		    --@MetaClassId int = NULL,
				@d_datetime,			--@Updated datetime = NULL,	
				@d_createdate,			--@Created datetime = NULL,
				1,						--@ObjectLanguageId int = NULL,
				1,						--@LanguageId int,
				0,						--@ObjectGroupId int = 0,
				0,						--@IsInherited bit = 0,
				@v_contactkey				--@Code nvarchar(50) = NULL
			end
							
--			IF @pss_publishtowebind=0 
--			begin
--
--				Select @v_title = Substring(UNL.dbo.qweb_get_Title(@i_bookkey,'f'),1,50)
--				Select @i_MetaClassID = dbo.qweb_ecf_get_MetaClassID('Titles')
--				Select @d_datetime = getdate()
--				Select @i_template_id = ProductTemplateID from producttemplate where name = 'Book Template'
--				
--				If exists (Select * from product where code = cast(@i_bookkey as varchar))
--				begin
--
--					Select @product_id = dbo.qweb_ecf_get_product_id(@i_bookkey)	
--					Select @d_createdate = created from product where code = cast(@i_bookkey as varchar)
--
--					exec dbo.ProductUpdate
--
--					@product_id,			--@ProductId int,
--					@v_title,				--@Name nvarchar(50),
--					NULL,					--@Description ntext = NULL,
--					NULL,					--@Features ntext = NULL,
--					0,	                      --@Visible bit = NULL,
--					@i_template_id,			--@ProductTemplateId int = NULL,
--					@i_MetaClassID,		    --@MetaClassId int = NULL,
--					@d_datetime,			--@Updated datetime = NULL,	
--					@d_createdate,			--@Created datetime = NULL,
--					1,						--@ObjectLanguageId int = NULL,
--					1,						--@LanguageId int,
--					0,						--@ObjectGroupId int = 0,
--					0,						--@IsInherited bit = 0,
--					@i_bookkey				--@Code nvarchar(50) = NULL
--				end
--				
--			end -- @i_bookkey <> @i_workkey

	    FETCH NEXT FROM c_pss_authors
		    INTO @v_contactkey, @v_displayname, @v_firstname, @v_middlename, @v_lastname

	    select  @v_fetchstatus  = @@FETCH_STATUS
	  END
	END
	
  close c_pss_authors
  deallocate c_pss_authors
END

GO
Grant execute on dbo.qweb_ecf_Insert_Products_Authors to Public
GO