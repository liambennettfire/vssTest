USE [BT_TB_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_SkuEx_Title_By_Format]    Script Date: 01/27/2010 16:52:29 ******/
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER procedure [dbo].[qweb_ecf_SkuEx_Title_By_Format] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @i_titlefetchstatus int,
		@i_skuid int,
		@v_title nvarchar(512),
		@v_subtitle nvarchar(512),
		@v_fulltitle nvarchar(512),
        @v_Fullauthordisplayname nvarchar(512),
		@d_datetime datetime,
		@v_ISBN nvarchar(512), 
		@v_EAN nvarchar(50), 
		@v_Display nvarchar,
		@v_Format nvarchar(512) , 
		@i_pagecount nvarchar(512) , 
		@v_season nvarchar(512) , 
		@v_PubYear nvarchar(512) , 
		@v_Discount nvarchar(512) , 
		@v_Series nvarchar(512) ,
		@v_edition nvarchar(512),
		@n_Description_Comment varchar(max),
		@n_About_Author_Comment varchar(max),
		@n_Headline_Copy varchar(max),
		@i_PrimaryImage int, 
		@i_LargeImage int,
		@v_Journal_ISSN varchar(20),
		@v_SubsidyCreditLine varchar(max),
		@m_promotionalprice money,
		@m_fullprice money,
		@v_Awards varchar(max),
		@v_Web_Page varchar(255),
		@v_Author_Web_Page varchar(255),
		@v_Society_Web_Site varchar(255),
		@v_Web_Document varchar(255),
		@v_Citation_Author varchar(80),
		@v_Citation_Source varchar(80),
		@v_Citation_Text varchar(max),
		@v_Praise varchar(max),
		@i_citation_fetchstatus int,
		@i_bisactatuscode int,
		@i_sendtoeloind int,
		@v_authorfirstname varchar(120),
		@v_authorlastname varchar(120),
		@v_authorbylineprepro varchar(max),
		@v_authortype varchar(255),
		@v_neverdiscountflag int,
		@v_isdiscounted int,
		@d_pubdate datetime,
		@v_bisacstatusdesc varchar (255),
		@v_awardscomment varchar(max),
		@v_author_events varchar(max),
		@v_fullauthordisplaykey int,
		@v_bookcategory varchar(512),
		@v_Series_for_title nvarchar(512) ,
		@v_volumenumber varchar(255),
		@v_IsSaleable int,
		@v_product_specs varchar(255),
		@v_Age_Range varchar(255),
		@v_keynote_comment varchar(max)



BEGIN

	DECLARE c_qweb_citations INSENSITIVE CURSOR
	FOR

	select q.commenthtmllite, c.citationauthor, c.citationsource
	from BT..citation c, BT..qsicomments q
	where c.webind=1
	and c.qsiobjectkey=q.commentkey
	and bookkey = @i_bookkey
	order by sortorder

	FOR READ ONLY
			
	OPEN c_qweb_citations 

	FETCH NEXT FROM c_qweb_citations 
		INTO @v_Citation_Text, @v_Citation_Author, @v_Citation_Source

	select  @i_citation_fetchstatus  = @@FETCH_STATUS

	 while (@i_citation_fetchstatus >-1 )
		begin
		IF (@i_citation_fetchstatus <>-2) 
		begin

		--Select @v_Praise =  ISNULL(@v_Praise,'')  + @v_Citation_Text + ' -' + ISNULL(@v_Citation_Author,'') + ', ' + ISNULL(@v_Citation_Source,'') + '<BR><BR>'
		Select @v_Praise =  ISNULL(@v_Praise,'')  + @v_Citation_Text + '<BR>'

		end

	FETCH NEXT FROM c_qweb_citations
		INTO @v_Citation_Text, @v_Citation_Author, @v_Citation_Source
	        select  @i_citation_fetchstatus  = @@FETCH_STATUS
		end

	close c_qweb_citations
	deallocate c_qweb_citations
		

				Select @v_title = BT.dbo.qweb_get_Title(@i_bookkey,'f')
				Select @d_datetime = getdate()
				Select @i_skuid = dbo.qweb_ecf_get_sku_id(@i_bookkey)
				Select @v_subtitle =  BT.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fulltitle = BT.dbo.qweb_get_Title(@i_bookkey,'f')
				
				-- add subtitle to end of title
				if @v_subtitle is not null and ltrim(rtrim(@v_subtitle)) <> '' begin
				  set @v_fulltitle = @v_fulltitle + ': ' +  @v_subtitle
				end
				
--				Select @v_fullauthordisplayname = BT.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
--												  BT.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
--												  BT.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')

--        Select @v_fullauthordisplayname = fullauthordisplayname,
--               @v_fullauthordisplaykey = COALESCE(fullauthordisplaykey,0),
--               @v_volumenumber = COALESCE(volumenumber,0)
--          from BT..bookdetail
--         where bookkey = @i_bookkey

        Select @v_fullauthordisplayname = commenthtml from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 57 and bookkey = @i_bookkey
                                          
--        if ((@v_fullauthordisplayname is null OR ltrim(rtrim(@v_fullauthordisplayname)) = '') AND @v_fullauthordisplaykey > 0) begin
--          Select @v_fullauthordisplayname = commenttext 
--            from BT..qsicomments
--           where commentkey = @v_fullauthordisplaykey
--             and commenttypecode = 3
--             and commenttypesubcode = 1
--        end
      
				-- add series and volumenumber to end of title
        if @v_volumenumber > 0 
		begin
  				Select @v_Series_for_title = BT.dbo.qweb_get_series(@i_bookkey,'1')

  				if @v_Series_for_title is null OR ltrim(rtrim(@v_Series_for_title)) = '' 
					begin
  					Select @v_Series_for_title = BT.dbo.qweb_get_series(@i_bookkey,'1')
  					end
				if @v_Series_for_title is not null and ltrim(rtrim(@v_Series_for_title)) <> '' 
					begin
				    set @v_fulltitle = @v_fulltitle+ '-' +' #' + cast(@v_volumenumber as varchar)+' '+ @v_Series_for_title 
					end
        end
         
				Select @v_ISBN = BT.dbo.qweb_get_ISBN(@i_bookkey,'13') 
				Select @v_EAN = BT.dbo.qweb_get_ISBN(@i_bookkey,'16') 
				IF coalesce(@v_EAN,'')=''
					begin
						Select @v_EAN = BT.dbo.qweb_get_ISBN(@i_bookkey,'22')
					end
				Select @v_Display = ''
				Select @v_Format = BT.dbo.qweb_get_Format(@i_bookkey,'2')
				If @v_Format = ''
				begin
				Select @v_Format = BT.dbo.qweb_get_Format(@i_bookkey,'D')	
				end
				Select @v_season = s.seasondesc
									from BT..printing p
									Left outer join BT..season s on p.seasonkey = s.seasonkey
									where printingkey = 1
									and bookkey = @i_bookkey

				Select @v_PubYear = BT.dbo.qweb_get_Pubmonth(@i_bookkey,1,'Y')
				Select @v_Discount = BT.dbo.qweb_get_Discount(@i_bookkey,'d')
				Select @v_Series = BT.dbo.qweb_get_series(@i_bookkey,'D')
				Select @v_edition = BT.dbo.qweb_get_edition(@i_bookkey,'d')
				Select @i_bisactatuscode = bisacstatuscode from BT..bookdetail where bookkey = @i_bookkey
				Select @i_sendtoeloind = releasetoeloquenceind from BT..bookcomments where commenttypecode = 3 and (commenttypesubcode = 8 or commenttypesubcode = 10) and bookkey = @i_bookkey
				select @v_bookcategory = BT.dbo.qweb_get_BookCategory_List(@i_bookkey,'D')
				
				--Select @v_authorbylineprepro = commenthtmllite from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 57 and bookkey = @i_bookkey
				Select @v_authorbylineprepro = BT.dbo.[bt_author_formatted] (@i_bookkey)

				Select @v_keynote_comment = commenthtmllite from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 56 and bookkey = @i_bookkey

				Select @v_authortype = BT.dbo.qweb_get_Authortype(@i_bookkey,1,'D')
				
			If not exists (select * 
						   from BT..gentables 
						   where tableid = 134 
							 and datacode in (57,59,61,71,73,74,75,76,77,78) 
							 and datadesc = @v_authortype)

				begin
				Select @v_authorfirstname = BT.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') + ',' +
				BT.dbo.[qweb_get_Author](@i_bookkey,2,0,'F') + ',' +
				BT.dbo.[qweb_get_Author](@i_bookkey,3,0,'F') + ',' +
				BT.dbo.[qweb_get_Author](@i_bookkey,4,0,'F') + ',' +
				BT.dbo.[qweb_get_Author](@i_bookkey,5,0,'F') + ',' +
				BT.dbo.[qweb_get_Author](@i_bookkey,6,0,'F') 

				Select @v_authorlastname = BT.dbo.[qweb_get_Author](@i_bookkey,1,0,'L') + ',' +
				BT.dbo.[qweb_get_Author](@i_bookkey,2,0,'L') + ',' +
				BT.dbo.[qweb_get_Author](@i_bookkey,3,0,'L') + ',' +
				BT.dbo.[qweb_get_Author](@i_bookkey,4,0,'L') + ',' +
				BT.dbo.[qweb_get_Author](@i_bookkey,5,0,'L') + ',' +
				BT.dbo.[qweb_get_Author](@i_bookkey,6,0,'L') 
				end

			Else 
				begin
				Select @v_authorfirstname = ''
				Select @v_authorlastname = ''
				end
					

					Select @n_Description_Comment = commenthtmllite from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 48 and bookkey = @i_bookkey
					Select @n_About_Author_Comment = commenthtmllite from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 10 and bookkey = @i_bookkey
					IF coalesce(@n_About_Author_Comment,'') =''
						begin
						select @n_About_Author_Comment = BT.dbo.qweb_get_author_contact_bios (@i_bookkey)
						end
					Select @n_Headline_Copy = commenthtmllite from BT..bookcomments where commenttypecode = 1 and commenttypesubcode = 36 and bookkey = @i_bookkey
					
						

				Select @i_PrimaryImage = 0
				Select @i_LargeImage = 0
				Select @v_Journal_ISSN = itemnumber from BT..isbn i, BT..bookfamily bf where i.bookkey = bf.parentbookkey and bf.childbookkey = @i_bookkey
				Select @v_SubsidyCreditLine = commenthtmllite from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 58 and bookkey = @i_bookkey
				Select @m_promotionalprice = finalprice from BT..bookprice where pricetypecode = 10 and currencytypecode = 6 and bookkey = @i_bookkey
				Select @m_fullprice = finalprice from BT..bookprice where pricetypecode = 8 and currencytypecode = 6 and bookkey = @i_bookkey

				Select @v_Awards = dbo.qweb_ecf_get_sku_awards(@i_bookkey)
				select @v_awardscomment = BT.dbo.get_Comment_HTMLLITE (@i_bookkey,1,30)
				Select @v_Web_Page = pathname from BT..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Author_Web_Page = pathname from BT..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Society_Web_Site = pathname from BT..filelocation where filetypecode = 9 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Web_Document = pathname from BT..filelocation where filetypecode = 6 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Age_Range = CASE 
									  WHEN agelow < 4 THEN 'up to 3'
									  WHEN agehigh < 4 THEN 'up to 3'
									  WHEN agelow > 3 THEN  Cast(agelow as varchar) + ' and up'
									  Else ''
									  END 
									 
				from BT..bookdetail where bookkey = @i_bookkey 


				If exists (Select * from BT..bookprice where 
		                           (bookkey=@i_bookkey
		                           and finalprice is not null 
		                           and pricetypecode in (10,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27) 
                                           and activeind = 1)
		                           OR
		                           (bookkey=@i_bookkey 
                                           and bookkey in 
                                           (Select bookkey from BT..bookorgentry where orglevelkey = 3 and orgentrykey = 15)))

					begin							 
					Select @v_neverdiscountflag = 1
					end
				Else
					begin
					Select @v_neverdiscountflag = 0
					end	

				If exists (Select * from BT..bookprice 
					   where (finalprice is not null 
                             		   and pricetypecode in (10) and activeind = 1)
					   and bookkey=@i_bookkey)

					begin							 
					Select @v_isdiscounted = 1
					end
				Else
					begin
					Select @v_isdiscounted = 0
					end
				
				select @d_pubdate = BT.dbo.qweb_get_BestPubDate_datetime (@i_bookkey,1)
				select @v_bisacstatusdesc = BT.dbo.qweb_get_bisacstatus  (@i_bookkey,'2')
				--select @v_author_events = BT.dbo.qweb_get_www_events (@i_bookkey)

--				Select @i_pagecount = BT.dbo.qweb_get_BestPageCount(@i_bookkey,1) +', ' + BT.dbo.qweb_get_BestInsertIllus( @i_bookkey,1 )
--				select @v_product_specs = BT.dbo.qweb_get_BestTrimSize(@i_bookkey,1) + ', ' + BT.dbo.qweb_get_BestPageCount (@i_bookkey,1) +' pp.' 

				select @i_pagecount = BT.dbo.qweb_get_BestPageCount (@i_bookkey,1) +' pp.' 
				Select @v_product_specs = BT.dbo.qweb_get_BestInsertIllus( @i_bookkey,1 )

				SELECT @v_Journal_ISSN = BT.dbo.qweb_get_BestTrimSize(@i_bookkey,1)
									

        SET @v_IsSaleable = 1
				If exists (Select * 
						   from BT..bookdetail 
						   where (bisacstatuscode not in (1))
 					       and bookkey=@i_bookkey)
					begin
            SET @v_IsSaleable = 0
					end

				if @i_skuid is not null 
				begin
				
			exec dbo.mdpsp_avto_SkuEx_Title_By_Format_Update 
				@i_skuid ,					--@ObjectId INT, 
				0,							--@CreatorId INT, 
				@d_datetime,				--@ALTERd DATETIME, 
				0,							--@ModifierId INT, 
				@d_datetime,				--@Modified DATETIME, 
				0,							--@Retval INT OUT, 
				@v_edition,					--@SKU_Edition nvarchar(       512) , 
				@v_Journal_ISSN,			--@Journal_ISSN nvarchar(       512) , 
				@i_bookkey,					--@pss_sku_bookkey int, 
				@v_Praise,					--@Praise ntext, 
				@v_authorfirstname,			--@author_first nvarchar(       512) , 
				@v_isdiscounted,			--@IsDiscounted int, 
				@v_bisacstatusdesc,			--@TitleStatus nvarchar(       512) , 
				@v_bookcategory,			--@BookCategory nvarchar(       512) , 
				@v_IsSaleable,				--@IsSaleable int, 
				@v_product_specs,			--@SKU_Specification nvarchar(       512) , 
				@v_keynote_comment,		--@KeyNote
				@v_author_events,			--@AuthorEvents ntext, 
				@m_fullprice, 				--@FullPrice money, 
				@v_authorlastname,			--@author_last nvarchar(       512) , 
				Null,						--@Web_Page nvarchar(       512) , 
				@v_awardscomment,			--@SKU_Awards ntext, 
				@v_ISBN,					--@SKU_ISBN nvarchar(       512) , 
				@v_EAN,						--@SKU_EAN nvarchar(       512) , 
				@v_SubsidyCreditLine,		--@SKU_SubsidyCreditLine ntext, 
				@v_authorbylineprepro,		--@AuthorBylinePrePro ntext, 
				@v_Author_Web_Page,			--@Author_Web_Page nvarchar(       512) , 
				@d_pubdate,					--@PubDate datetime, 
				@v_Society_Web_Site,		--@Society_Web_Site nvarchar(       512) , 
				@v_neverdiscountflag,		--@never_discount int, 
				@m_promotionalprice,		--@Journal_PromotionalPrice money, 
				@v_Display,					--@SKU_Display nvarchar(       512) , 
				@v_title,					--@SKU_Title nvarchar(       512) , 
				@v_Web_Document,			--@Web_Document nvarchar(       512) , 
				NULL, 						--@Excerpt int, 
				@v_fulltitle,				--@SKU_Full_Title nvarchar(       512) , 
				@v_subtitle,				--@SKU_Subtitle nvarchar(       512) , 
				NULL,						--@Digital_Press_Kit int, 
				@v_Format,					--@SKU_Format nvarchar(       512) , 
				@i_pagecount,				--@SKU_pagecount nvarchar(       512) , 
				@v_season,					--@SKU_season nvarchar(       512) , 
				@v_PubYear,					--@SKU_PubYear nvarchar(       512) , 
				@v_Discount,				--@SKU_Discount nvarchar(       512) , 
				@v_series,					--@SKU_Series nvarchar(       512) , 
				@v_Fullauthordisplayname,	--@SKU_fullauthordisplayname nvarchar(       512) , 
				@n_Description_Comment,		--@SKU_Description_Comment ntext, 
				@n_About_Author_Comment,	--@SKU_About_Author_Comment ntext, 
				NULL,						--@SKU_LargeToThumbImage int, 
				NULL,						--@SKU_LargeToMediumImage int, 
				@n_Headline_Copy,			--@SKU_Web_Headline_Copy
				@v_Age_Range,				--@Age_Range ntext
				@v_keynote_comment			--@KeyNote

				
				
				
--@ObjectId INT, 
--@CreatorId INT, 
--@Created DATETIME, 
--@ModifierId INT, 
--@Modified DATETIME, 
--@Retval INT OUT, 
--@SKU_Edition nvarchar(       512) , 
--@Journal_ISSN nvarchar(       512) , 
--@pss_sku_bookkey int, 
--@Praise ntext, 
--@author_first nvarchar(       512) , 
--@IsDiscounted int, 
--@TitleStatus nvarchar(       512) , 
--@BookCategory nvarchar(       512) , 
--@IsSaleable int, 
--@SKU_Specification nvarchar(       512) , 
--@Key_Note ntext, 
--@AuthorEvents ntext, 
--@FullPrice money, 
--@author_last nvarchar(       512) , 
--@Web_Page nvarchar(       512) , 
--@SKU_Awards ntext, 
--@SKU_ISBN nvarchar(       512) , 
--@SKU_EAN nvarchar(       512) , 
--@SKU_SubsidyCreditLine ntext, 
--@AuthorBylinePrePro ntext, 
--@Author_Web_Page nvarchar(       512) , 
--@PubDate datetime, 
--@Society_Web_Site nvarchar(       512) , 
--@never_discount int, 
--@Journal_PromotionalPrice money, 
--@SKU_Display nvarchar(       512) , 
--@SKU_Title nvarchar(       512) , 
--@Web_Document nvarchar(       512) , 
--@Excerpt int, 
--@SKU_Full_Title nvarchar(       512) , 
--@SKU_Subtitle nvarchar(       512) , 
--@Digital_Press_Kit int, 
--@SKU_Format nvarchar(       512) , 
--@SKU_pagecount nvarchar(       512) , 
--@SKU_season nvarchar(       512) , 
--@SKU_PubYear nvarchar(       512) , 
--@SKU_Discount nvarchar(       512) , 
--@SKU_Series nvarchar(       512) , 
--@SKU_fullauthordisplayname nvarchar(       512) , 
--@SKU_Description_Comment ntext, 
--@SKU_About_Author_Comment ntext, 
--@SKU_LargeToThumbImage int, 
--@SKU_LargeToMediumImage int, 
--@SKU_Web_Headline_Copy ntext, 
--@Age_Range ntext, 
--@KeyNote ntext
				

				end
	
END









