USE [TAMU_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_SkuEx_Title_By_Format]    Script Date: 01/26/2010 10:41:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
		@v_ExpectedShipDate nvarchar(512)




BEGIN

	DECLARE c_qweb_citations INSENSITIVE CURSOR
	FOR

	select q.commenthtmllite, c.citationauthor, c.citationsource
	from TAMU..citation c, TAMU..qsicomments q
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
		

				Select @v_title = TAMU.dbo.qweb_get_Title(@i_bookkey,'f')
				Select @d_datetime = getdate()
				Select @i_skuid = dbo.qweb_ecf_get_sku_id(@i_bookkey)
				Select @v_subtitle =  TAMU.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fulltitle = TAMU.dbo.qweb_get_Title(@i_bookkey,'f')
				
				-- add subtitle to end of title
				if @v_subtitle is not null and ltrim(rtrim(@v_subtitle)) <> '' begin
				  set @v_fulltitle = @v_fulltitle + ': ' +  @v_subtitle
				end
				
--				Select @v_fullauthordisplayname = TAMU.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
--												  TAMU.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
--												  TAMU.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')

--        Select @v_fullauthordisplayname = fullauthordisplayname,
--               @v_fullauthordisplaykey = COALESCE(fullauthordisplaykey,0),
--               @v_volumenumber = COALESCE(volumenumber,0)
--          from TAMU..bookdetail
--         where bookkey = @i_bookkey

        Select @v_fullauthordisplayname = commenthtml from TAMU..bookcomments where commenttypecode = 3 and commenttypesubcode = 57 and bookkey = @i_bookkey
                                          
--        if ((@v_fullauthordisplayname is null OR ltrim(rtrim(@v_fullauthordisplayname)) = '') AND @v_fullauthordisplaykey > 0) begin
--          Select @v_fullauthordisplayname = commenttext 
--            from TAMU..qsicomments
--           where commentkey = @v_fullauthordisplaykey
--             and commenttypecode = 3
--             and commenttypesubcode = 1
--        end
      
				-- add series and volumenumber to end of title
        if @v_volumenumber > 0 
		begin
  				Select @v_Series_for_title = TAMU.dbo.qweb_get_series(@i_bookkey,'1')

  				if @v_Series_for_title is null OR ltrim(rtrim(@v_Series_for_title)) = '' 
					begin
  					Select @v_Series_for_title = TAMU.dbo.qweb_get_series(@i_bookkey,'1')
  					end
				if @v_Series_for_title is not null and ltrim(rtrim(@v_Series_for_title)) <> '' 
					begin
				    set @v_fulltitle = @v_fulltitle+ '-' +' #' + cast(@v_volumenumber as varchar)+' '+ @v_Series_for_title 
					end
        end
         
				Select @v_ISBN = TAMU.dbo.qweb_get_ISBN(@i_bookkey,'13') + ',' + TAMU.dbo.qweb_get_ISBN(@i_bookkey,'16') + ',' + 					TAMU.dbo.qweb_get_ISBN(@i_bookkey,'10') + ',' + TAMU.dbo.qweb_get_ISBN(@i_bookkey,'17')
				Select @v_EAN = TAMU.dbo.qweb_get_ISBN(@i_bookkey,'16') 
				IF coalesce(@v_EAN,'')=''
					begin
						Select @v_EAN = TAMU.dbo.qweb_get_ISBN(@i_bookkey,'22')
					end
				Select @v_Display = ''
				Select @v_Format = TAMU.dbo.qweb_get_Format(@i_bookkey,'2')
				Select @v_season = s.seasondesc
									from TAMU..printing p
									Left outer join TAMU..season s on p.seasonkey = s.seasonkey
									where printingkey = 1
									and bookkey = @i_bookkey

				Select @v_PubYear = TAMU.dbo.qweb_get_Pubmonth(@i_bookkey,1,'Y')
				Select @v_Discount = TAMU.dbo.qweb_get_Discount(@i_bookkey,'d')
				Select @v_Series = TAMU.dbo.qweb_get_series(@i_bookkey,'1')
				Select @v_edition = TAMU.dbo.qweb_get_edition(@i_bookkey,'d')
				Select @i_bisactatuscode = bisacstatuscode from TAMU..bookdetail where bookkey = @i_bookkey
				Select @i_sendtoeloind = releasetoeloquenceind from TAMU..bookcomments where commenttypecode = 3 and (commenttypesubcode = 8 or commenttypesubcode = 10) and bookkey = @i_bookkey
				select @v_bookcategory = TAMU.dbo.qweb_get_BookCategory_List(@i_bookkey,'D')
				
				Select @v_authorbylineprepro = commenthtmllite from TAMU..bookcomments where commenttypecode = 3 and commenttypesubcode = 57 and bookkey = @i_bookkey

				Select @v_authortype = TAMU.dbo.qweb_get_Authortype(@i_bookkey,1,'D')
				
			If not exists (select * 
						   from TAMU..gentables 
						   where tableid = 134 
							 and datacode in (57,59,61,71,73,74,75,76,77,78) 
							 and datadesc = @v_authortype)

				begin
				Select @v_authorfirstname = TAMU.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') + ',' +
				TAMU.dbo.[qweb_get_Author](@i_bookkey,2,0,'F') + ',' +
				TAMU.dbo.[qweb_get_Author](@i_bookkey,3,0,'F') + ',' +
				TAMU.dbo.[qweb_get_Author](@i_bookkey,4,0,'F') + ',' +
				TAMU.dbo.[qweb_get_Author](@i_bookkey,5,0,'F') + ',' +
				TAMU.dbo.[qweb_get_Author](@i_bookkey,6,0,'F') 

				Select @v_authorlastname = TAMU.dbo.[qweb_get_Author](@i_bookkey,1,0,'L') + ',' +
				TAMU.dbo.[qweb_get_Author](@i_bookkey,2,0,'L') + ',' +
				TAMU.dbo.[qweb_get_Author](@i_bookkey,3,0,'L') + ',' +
				TAMU.dbo.[qweb_get_Author](@i_bookkey,4,0,'L') + ',' +
				TAMU.dbo.[qweb_get_Author](@i_bookkey,5,0,'L') + ',' +
				TAMU.dbo.[qweb_get_Author](@i_bookkey,6,0,'L') 
				end

			Else 
				begin
				Select @v_authorfirstname = ''
				Select @v_authorlastname = ''
				end
					

				If @i_bisactatuscode in (4,10) and coalesce (@i_sendtoeloind,0) <> 1
					begin
					 Select @n_Description_Comment = ''
					 Select @n_About_Author_Comment = ''
					 Select @n_Headline_Copy = '';
					end		
				Else 
					begin
					Select @n_Description_Comment = commenthtmllite from TAMU..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey
					Select @n_About_Author_Comment = commenthtmllite from TAMU..bookcomments where commenttypecode = 3 and commenttypesubcode = 10 and bookkey = @i_bookkey
					IF coalesce(@n_About_Author_Comment,'') =''
						begin
						select @n_About_Author_Comment = tamu.dbo.qweb_get_author_contact_bios (@i_bookkey)
						end
					Select @n_Headline_Copy = commenthtmllite from TAMU..bookcomments where commenttypecode = 1 and commenttypesubcode = 36 and bookkey = @i_bookkey
					end
						

				Select @i_PrimaryImage = 0
				Select @i_LargeImage = 0
				Select @v_Journal_ISSN = itemnumber from TAMU..isbn i, TAMU..bookfamily bf where i.bookkey = bf.parentbookkey and bf.childbookkey = @i_bookkey
				Select @v_SubsidyCreditLine = commenthtmllite from TAMU..bookcomments where commenttypecode = 3 and commenttypesubcode = 58 and bookkey = @i_bookkey
				Select @m_promotionalprice = finalprice from TAMU..bookprice where pricetypecode = 10 and currencytypecode = 6 and bookkey = @i_bookkey
				Select @m_fullprice = finalprice from TAMU..bookprice where pricetypecode = 8 and currencytypecode = 6 and bookkey = @i_bookkey

				Select @v_Awards = dbo.qweb_ecf_get_sku_awards(@i_bookkey)
				select @v_awardscomment = TAMU.dbo.get_Comment_HTMLLITE (@i_bookkey,1,30)
				Select @v_Web_Page = pathname from TAMU..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Author_Web_Page = pathname from TAMU..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Society_Web_Site = pathname from TAMU..filelocation where filetypecode = 9 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Web_Document = pathname from TAMU..filelocation where filetypecode = 6 and bookkey = @i_bookkey and printingkey = 1

				If exists (Select * from TAMU..bookprice where 
		                           (bookkey=@i_bookkey
		                           and finalprice is not null 
		                           and pricetypecode in (10,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27) 
                                           and activeind = 1)
		                           OR
		                           (bookkey=@i_bookkey 
                                           and bookkey in 
                                           (Select bookkey from TAMU..bookorgentry where orglevelkey = 3 and orgentrykey = 15)))

					begin							 
					Select @v_neverdiscountflag = 1
					end
				Else
					begin
					Select @v_neverdiscountflag = 0
					end	

				If exists (Select * from TAMU..bookprice 
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
				
				select @d_pubdate = TAMU.dbo.qweb_get_BestPubDate_datetime (@i_bookkey,1)
				select @v_ExpectedShipDate = bestdate from TAMU.dbo.bookdates where datetypecode = 446 and bookkey = @i_bookkey 	
				select @v_bisacstatusdesc = TAMU.dbo.qweb_get_BisacStatus_SubGentableLevel( @i_bookkey,'2')
				select @v_author_events = TAMU.dbo.qweb_get_www_events (@i_bookkey)

--				Select @i_pagecount = TAMU.dbo.qweb_get_BestPageCount(@i_bookkey,1) +', ' + TAMU.dbo.qweb_get_BestInsertIllus( @i_bookkey,1 )
--				select @v_product_specs = TAMU.dbo.qweb_get_BestTrimSize(@i_bookkey,1) + ', ' + TAMU.dbo.qweb_get_BestPageCount (@i_bookkey,1) +' pp.' 

				select @i_pagecount = TAMU.dbo.qweb_get_BestTrimSize(@i_bookkey,1) + ', ' + TAMU.dbo.qweb_get_BestPageCount (@i_bookkey,1) +' pp.' 
				Select @v_product_specs = TAMU.dbo.qweb_get_BestInsertIllus( @i_bookkey,1 )
									

        SET @v_IsSaleable = 1
				If exists (Select * 
						   from TAMU..bookdetail 
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
				@d_datetime,				--@Created DATETIME, 
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
				@v_ExpectedShipDate,		--@ExpectedShipDate( DATETIME ) 
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
				@n_Headline_Copy			--@SKU_Web_Headline_Copy
				
				
				
				

				end
	
END






