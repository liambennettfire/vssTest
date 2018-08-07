if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_ProductEx_Authors]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_ProductEx_Authors]
GO

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
		@v_audio_clip int,
		@v_externalcode1 nvarchar(512)

BEGIN

  DECLARE c_pss_authors CURSOR fast_forward FOR
	  Select ba.authorkey, c.displayname, c.firstname, c.middlename, c.lastname,
	         ba.primaryind, ba.sortorder, c.externalcode1
  	  from cbd..bookauthor ba, cbd..bookdetail bd, cbd..globalcontact c
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
      
			SELECT @v_displayname = NULL
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
				 --Select @v_website = NULL
			   --   select @v_website = gcm.contactmethodvalue
			   --     from cbd..globalcontactmethod gcm
			   --    where gcm.globalcontactkey = @v_contactkey and
			   --          gcm.contactmethodcode = 4 and   -- Website
			   --          gcm.contactmethodsubcode = 2    -- Approved Author Website
			   Select @v_website = NULL
			   
			   -- Revised 01/25/2011  - 14184 - include as a csv line all websites for given globalcontact.
         SELECT @v_website = (SELECT STUFF((SELECT ',' + gcm.contactmethodvalue
         FROM cbd..globalcontactmethod gcm
         WHERE gcm.globalcontactkey  = t.globalcontactkey
              and gcm.contactmethodcode = 4       -- Website
              and gcm.contactmethodsubcode = 2    -- Approved Author Website     
         FOR XML PATH('')),1,1,''))
         FROM cbd..globalcontactmethod t 
         where globalcontactkey = @v_contactkey
         and primaryind = 1
			
			     -- use primary email address
				 Select @v_email = null
			     select @v_email = gcm.contactmethodvalue
			       from cbd..globalcontactmethod gcm
			      where gcm.globalcontactkey = @v_contactkey and
			            gcm.primaryind = 1 and
			            gcm.contactmethodcode = 3       -- Email
			
			     -- About the Author Comment
				 Select @v_about_comment = null
			     select @v_about_comment = q.commenthtmllite
			       from cbd..qsicomments q
			      where q.commentkey = @v_contactkey and
			            q.commenttypecode = 2 and q.commenttypesubcode = 0 
            
		  exec dbo.mdpsp_avto_ProductEx_Contributors_Update 
				@i_productid,			 --@ObjectId INT, 
				1,						 --@CreatorId INT, 
				@d_datetime,			 --@Created DATETIME, 
				1,						 --@ModifierId INT, 
				@d_datetime,			 --@Modified DATETIME, 
				NULL,					 --@Retval INT OUT, 
				NULL,					--@SKU_About_Author_Comment			

				@v_contactkey,			--@pss_globalcontactkey int, 
				@v_firstname,			--@Contributor_First_Name nvarchar(512),
				@v_website,					--@Author_WEb_Page nvarchar(512),
				NULL,					-- @Contributor_Sort_Order0
				@v_middlename,			--@Contributor_Middle_Name nvarchar(512), 
				@v_lastname,			--@Contributor_Last_Name nvarchar(512), 
				@v_displayname,			--@Contributor_Display_Name nvarchar(512), 
				@v_primaryind,			--@Contributor_Primary_Ind int,
				@v_about_comment,		--@Contributor_About_Comment ntext 					
				@v_website,				--@Contributor_WebSite nvarchar(512), 				
				@v_email,				--@Contributor_Email nvarchar(512), 
				0,						 --@Audio_Clip
				@v_sortorder,			-- @Contributor_Sort_Order				
				1,						--@IsAuthor,
				@v_externalcode1,		--@Contributor_ExternalCode nvarchar(512)
				@v_metakeywords,		 --@AuthorMetaKeywords
				0,						 --@Contributor_MediumToThumbImage int, 
				0						 --@Contributor_LargeToMediumImage int,

			-- try to add author image
			--exec qweb_ecf_insert_author_images @v_contactkey,  '\\qsiweb002\uap_images\AUthorPics\'
			exec qweb_ecf_insert_author_images @v_contactkey,  '\\merv\mediachase\kp_images\Authorpics\'

	    FETCH NEXT FROM c_pss_authors
		    INTO @v_contactkey, @v_displayname, @v_firstname, @v_middlename, @v_lastname,
		         @v_primaryind, @v_sortorder, @v_externalcode1

	    select  @v_fetchstatus  = @@FETCH_STATUS
    END
  END
  
  close c_pss_authors
  deallocate c_pss_authors  
END

GO
Grant execute on dbo.qweb_ecf_ProductEx_Authors to Public
GO