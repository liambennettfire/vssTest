IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_ProductEx_Authors]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_ProductEx_Authors]
go

CREATE procedure [dbo].[qweb_ecf_ProductEx_Authors] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @v_contactkey int,
		@v_fetchstatus int,
		@i_productid int,
		@v_displayname nvarchar(512),
		@v_lastname nvarchar(512),
		@v_firstname nvarchar(512),
		@v_middlename nvarchar(512),
		@d_datetime datetime,
		@v_primaryind int,
		@i_publishtowebind int,
		@v_metakeywords varchar(512),
		@v_sortorder int,
		@v_about_comment nvarchar(max),
		@v_website nvarchar(512),
		@v_email nvarchar(512),
		@v_blog nvarchar(512),
		@v_audio_clip int,
		@v_externalcode1 nvarchar(512)

BEGIN

  DECLARE c_pss_authors CURSOR fast_forward FOR
	  Select ba.authorkey, c.displayname, c.firstname, c.middlename, c.lastname,
	         ba.primaryind, ba.sortorder, c.externalcode1
  	  from barb..bookauthor ba, barb..bookdetail bd, barb..globalcontact c
	   where ba.bookkey = bd.bookkey
	     and ba.authorkey = c.globalcontactkey
	 	   and ba.bookkey = @i_bookkey
	 	   and bd.publishtowebind=1
				
	OPEN c_pss_authors
	
	FETCH NEXT FROM c_pss_authors
		INTO @v_contactkey, @v_displayname, @v_firstname, @v_middlename, @v_lastname,
		     @v_primaryind, @v_sortorder, @v_externalcode1

	select  @v_fetchstatus  = @@FETCH_STATUS

	while (@v_fetchstatus >-1) begin
	  IF (@v_fetchstatus <>-2) begin
      
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
      
  		Select @d_datetime = getdate()
			Select @i_productid = dbo.qweb_ecf_get_product_id(@v_contactkey)			
			Select @v_metakeywords = @v_displayname

      -- use primary author website
      select @v_website = gcm.contactmethodvalue
        from barb..globalcontactmethod gcm
       where gcm.globalcontactkey = @v_contactkey and
             gcm.primaryind = 1 and
             gcm.contactmethodcode = 4 and   -- Website
             gcm.contactmethodsubcode = 2    -- Approved Author Website

     -- use primary email address
     select @v_email = gcm.contactmethodvalue
       from barb..globalcontactmethod gcm
      where gcm.globalcontactkey = @v_contactkey and
            gcm.primaryind = 1 and
            gcm.contactmethodcode = 3       -- Email

      -- use primary author blog
      select @v_blog = gcm.contactmethodvalue
        from barb..globalcontactmethod gcm
       where gcm.globalcontactkey = @v_contactkey and
             gcm.primaryind = 1 and
             gcm.contactmethodcode = 4 and   -- Website
             gcm.contactmethodsubcode = 4    -- Blog

     -- About the Author Comment
     select @v_about_comment = q.commenthtmllite
       from barb..qsicomments q
      where q.commentkey = @v_contactkey and
            q.commenttypecode = 2 and
            q.commenttypesubcode = 0 
            
		  exec dbo.mdpsp_avto_ProductEx_Contributors_Update 
				@i_productid,			 --@ObjectId INT, 
				1,						 --@CreatorId INT, 
				@d_datetime,			 --@Created DATETIME, 
				1,						 --@ModifierId INT, 
				@d_datetime,			 --@Modified DATETIME, 
				NULL,					 --@Retval INT OUT, 
				@v_contactkey,				 --@pss_globalcontactkey int, 
				@v_blog,         --@Contributor_Blog nvarchar(512), 
				@v_firstname,		  --@Contributor_First_Name nvarchar(512), 
				@v_middlename,		  --@Contributor_Middle_Name nvarchar(512), 
				@v_lastname,		  --@Contributor_Last_Name nvarchar(512), 
				@v_displayname,		  --@Contributor_Display_Name nvarchar(512), 
				@v_primaryind,     --@Contributor_Primary_Ind int,
				@v_about_comment,					--@Contributor_About_Comment ntext 
				@v_website,		  --@Contributor_WebSite nvarchar(512), 
				@v_email,		  --@Contributor_Email nvarchar(512), 
				0,						 --@Contributor_MediumToThumbImage int, 
				0,						 --@Audio_Clip
				@v_sortorder,    -- @Contributor_Sort_Order
				1,              --@IsAuthor,
				@v_externalcode1, --@Contributor_ExternalCode nvarchar(512)
				@v_metakeywords,		 --@AuthorMetaKeywords
				0						 --@Contributor_LargeToMediumImage int, 

			-- try to add author image
		--  QSI  -- '\\mcdonald\mediachase\Barb_images\AuthorImages\'
		--  BARB  -- '\\Fileserver\FS1\All-share\Author Photos\BW JPEG\'  							
			exec qweb_ecf_insert_author_images @v_contactkey,  '\\mcdonald\mediachase\Barb_images\AuthorImages\'

	    FETCH NEXT FROM c_pss_authors
		    INTO @v_contactkey, @v_displayname, @v_firstname, @v_middlename, @v_lastname,
		         @v_primaryind, @v_sortorder, @v_externalcode1

	    select  @v_fetchstatus  = @@FETCH_STATUS
    END
  END
  
  close c_pss_authors
  deallocate c_pss_authors  
END



