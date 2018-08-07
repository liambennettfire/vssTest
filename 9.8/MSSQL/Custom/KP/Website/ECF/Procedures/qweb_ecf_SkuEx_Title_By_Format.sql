if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_SkuEx_Title_By_Format]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_SkuEx_Title_By_Format]

GO

CREATE procedure [dbo].[qweb_ecf_SkuEx_Title_By_Format] (@i_bookkey int, @v_importtype varchar(1)) as
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
		@v_Insert_Illus varchar(255),
		@n_title_filelocations varchar(max),
		@v_quote varchar(max),
		@v_TrimSize  varchar(512),
		@fullauthordisplayname nvarchar(512),
		@TOC varchar(max),
		@reviews varchar(max),
		@ebook_ranking varchar(255),
		@n_Description_Comment_text varchar(max)





BEGIN

	Select @reviews = ''

	DECLARE c_qweb_citations INSENSITIVE CURSOR
	FOR

	select q.commenthtmllite, c.citationauthor, c.citationsource
	from cbd..citation c, cbd..qsicomments q
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

			DECLARE @authorSource varchar(512)
			Select @authorSource = NULL		
			Select @reviews =  ISNULL(@reviews,'')  + @v_Citation_Text 
		
			IF @v_Citation_Author IS NULL
				Select @authorSource = ' -' + ISNULL(@v_Citation_Source,'') + '<BR><BR>'
			ELSE
				Select @authorSource = ' -' + ISNULL(@v_Citation_Author,'') + ', ' + ISNULL(@v_Citation_Source,'') + '<BR><BR>'

			Select @reviews = ISNULL(@reviews,'') + @authorSource

		end

	FETCH NEXT FROM c_qweb_citations
		INTO @v_Citation_Text, @v_Citation_Author, @v_Citation_Source
	        select  @i_citation_fetchstatus  = @@FETCH_STATUS
		end

	close c_qweb_citations
	deallocate c_qweb_citations


		set @v_Praise = ''
		  		  select @v_quote = cbd.dbo.get_Comment_HTMLLITE (@i_bookkey,3,4)
		        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
		      		Select @v_Praise =  @v_Praise + @v_quote
		        end
		  		  select @v_quote = cbd.dbo.get_Comment_HTMLLITE (@i_bookkey,3,5)
		        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
		      		Select @v_Praise =  @v_Praise + '<BR />' + @v_quote
		        end
		  		  select @v_quote = cbd.dbo.get_Comment_HTMLLITE (@i_bookkey,3,6)
		        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
		      		Select @v_Praise =  @v_Praise + '<BR />' + @v_quote  
		        end
--					select @v_quote = cbd.dbo.get_Comment_HTMLLITE (@i_bookkey,3,45)
--		        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
--		      		Select @v_Praise =  @v_Praise + '<BR />' + @v_quote  
--		        end
--					select @v_quote = cbd.dbo.get_Comment_HTMLLITE (@i_bookkey,3,46)
--		        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
--		      		Select @v_Praise =  @v_Praise + '<BR />' + @v_quote  
--		        end
--					select @v_quote = cbd.dbo.get_Comment_HTMLLITE (@i_bookkey,3,47)
--		        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
--		      		Select @v_Praise =  @v_Praise + '<BR />' + @v_quote  
--		        end
--					select @v_quote = cbd.dbo.get_Comment_HTMLLITE (@i_bookkey,3,48)
--		        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
--		      		Select @v_Praise =  @v_Praise + '<BR />' + @v_quote  
--		        end
--					select @v_quote = cbd.dbo.get_Comment_HTMLLITE (@i_bookkey,3,49)
--		        if @v_quote is not null and ltrim(rtrim(@v_quote)) <> '' begin
--		      		Select @v_Praise =  @v_Praise + '<BR />' + @v_quote  
--        		end
		

				Select @v_title = cbd.dbo.qweb_get_Title(@i_bookkey,'s')
				Select @d_datetime = getdate()
				Select @i_skuid = dbo.qweb_ecf_get_sku_id(@i_bookkey)
				Select @v_subtitle =  cbd.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fulltitle = cbd.dbo.qweb_get_Title(@i_bookkey,'f')
				Select @v_fullauthordisplayname = dbo.qweb_get_AuthorEditorPrimary(@i_bookkey)

--				CASE 
--				  WHEN cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') IS  NULL THEN ''
--					ELSE cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'F')
--	     			END
--				 +CASE 
--						WHEN (cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'M') = '') and 
--						(cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') <> '') THEN ' '
--						WHEN (cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'M') = '') and 
--						(cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') = '') THEN ''
--						WHEN (cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'M') <> '') and 
--						(cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') <> '') THEN ' '+cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'M')+ ' '
--						ELSE ''
--				  END
--				+ cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'L')



--cbd.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
--cbd.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
--cbd.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')

				Select @v_ISBN = cbd.dbo.qweb_get_ISBN(@i_bookkey,'13') + ',' + cbd.dbo.qweb_get_ISBN(@i_bookkey,'16') + ',' + cbd.dbo.qweb_get_ISBN(@i_bookkey,'10') + ',' + cbd.dbo.qweb_get_ISBN(@i_bookkey,'17')
				Select @v_EAN = cbd.dbo.qweb_get_ISBN(@i_bookkey,'16') 
				Select @v_Display = ''
				Select @v_Format = cbd.dbo.qweb_get_Format(@i_bookkey,'2')
				Select @i_pagecount = cbd.dbo.qweb_get_BestPageCount(@i_bookkey,1)
				Select @v_season = s.seasondesc
									from cbd..printing p
									Left outer join cbd..season s on p.seasonkey = s.seasonkey
									where printingkey = 1
									and bookkey = @i_bookkey

				Select @v_PubYear = cbd.dbo.qweb_get_Pubmonth(@i_bookkey,1,'Y')
				Select @v_Discount = cbd.dbo.qweb_get_Discount(@i_bookkey,'d')
				Select @v_Series = cbd.dbo.qweb_get_series(@i_bookkey,'D')
				Select @v_edition = cbd.dbo.qweb_get_edition(@i_bookkey,'d')
				Select @i_bisactatuscode = bisacstatuscode from cbd..bookdetail where bookkey = @i_bookkey
				Select @i_sendtoeloind = releasetoeloquenceind from cbd..bookcomments where commenttypecode = 3 and (commenttypesubcode = 8 or commenttypesubcode = 10) and bookkey = @i_bookkey
				
				Select @v_authorbylineprepro = commenthtmllite from cbd..bookcomments where commenttypecode = 3 and commenttypesubcode = 73 and bookkey = @i_bookkey

				Select @v_authortype = cbd.dbo.qweb_get_Authortype(@i_bookkey,1,'D')
				Select @v_TrimSize =  cbd.dbo.get_BestTrimSize(@i_bookkey, 1)				

			If not exists (select * 
						   from cbd..gentables 
						   where tableid = 134 
							 and datacode not in (12,16,42,46)  -- list for UNP   IN (57,59,61,71,73,74,75,76,77,78) 
							 and datadesc = @v_authortype)

				begin
				Select @v_authorfirstname = cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') + ',' +
				cbd.dbo.[qweb_get_Author](@i_bookkey,2,0,'F') + ',' +
				cbd.dbo.[qweb_get_Author](@i_bookkey,3,0,'F') + ',' +
				cbd.dbo.[qweb_get_Author](@i_bookkey,4,0,'F') + ',' +
				cbd.dbo.[qweb_get_Author](@i_bookkey,5,0,'F') + ',' +
				cbd.dbo.[qweb_get_Author](@i_bookkey,6,0,'F') 

				Select @v_authorlastname = cbd.dbo.[qweb_get_Author](@i_bookkey,1,0,'L') + ',' +
				cbd.dbo.[qweb_get_Author](@i_bookkey,2,0,'L') + ',' +
				cbd.dbo.[qweb_get_Author](@i_bookkey,3,0,'L') + ',' +
				cbd.dbo.[qweb_get_Author](@i_bookkey,4,0,'L') + ',' +
				cbd.dbo.[qweb_get_Author](@i_bookkey,5,0,'L') + ',' +
				cbd.dbo.[qweb_get_Author](@i_bookkey,6,0,'L') 
				end

			Else 
				begin
				Select @v_authorfirstname = ''
				Select @v_authorlastname = ''
				end
					

				If @i_bisactatuscode in (4,12) and coalesce (@i_sendtoeloind,0) <> 1
					begin
					 Select @n_Description_Comment = ''
					 Select @n_About_Author_Comment = ''
					 Select @TOC = ''
					end		
				Else 
					begin
					Select @n_Description_Comment = commenthtmllite from cbd..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey
					Select @n_About_Author_Comment = commenthtmllite from cbd..bookcomments where commenttypecode = 3 and commenttypesubcode = 10 and bookkey = @i_bookkey
					Select @TOC = commenthtmllite from cbd..bookcomments where commenttypecode = 3 and commenttypesubcode = 52 and bookkey = @i_bookkey
					end
						

				Select @i_PrimaryImage = 0
				Select @i_LargeImage = 0
				Select @v_Journal_ISSN = itemnumber from cbd..isbn i, cbd..bookfamily bf where i.bookkey = bf.parentbookkey and bf.childbookkey = @i_bookkey
				--Select @v_SubsidyCreditLine = commenthtmllite from cbd..bookcomments where commenttypecode = 3 and commenttypesubcode = 58 and bookkey = @i_bookkey
				Select @m_promotionalprice = finalprice from cbd..bookprice where pricetypecode = 10 and currencytypecode = 6 and bookkey = @i_bookkey
				Select @m_fullprice = finalprice from cbd..bookprice where 
				((pricetypecode = 8 and currencytypecode = 6) OR
				(pricetypecode = 25 and currencytypecode = 6)) --single issue individual price type
				and bookkey = @i_bookkey

				

				Select @v_Awards = dbo.qweb_ecf_get_sku_awards(@i_bookkey)
				select @v_awardscomment = cbd.dbo.get_Comment_HTMLLITE (@i_bookkey,1,30)
--				Select @v_Web_Page = pathname from cbd..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
--				Select @v_Author_Web_Page = pathname from cbd..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
--				Select @v_Society_Web_Site = pathname from cbd..filelocation where filetypecode = 9 and bookkey = @i_bookkey and printingkey = 1
--				Select @v_Web_Document = pathname from cbd..filelocation where filetypecode = 6 and bookkey = @i_bookkey and printingkey = 1

				If exists (Select * from cbd..bookprice where 
		                           (bookkey=@i_bookkey
		                           and finalprice is not null 
		                           and pricetypecode in (10,12,25)
									and activeind = 1))
									--(10,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27) 
                                           
		                          --Buros Institute of Mental Measurements books for UNP, commentted out for UAP 
								  --OR
		                           --(bookkey=@i_bookkey 
                                   --       and bookkey in 
                                   --        (Select bookkey from cbd..bookorgentry where orglevelkey = 3 and orgentrykey = 15)))

					begin							 
					Select @v_neverdiscountflag = 1
					end
				Else
					begin
					Select @v_neverdiscountflag = 0
					end	

				If exists (Select * from cbd..bookprice 
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

				select @d_pubdate = cbd.dbo.qweb_get_BestPubDate_datetime (@i_bookkey,1)
				select @v_bisacstatusdesc = cbd.dbo.qweb_get_bisacstatus  (@i_bookkey,'D')
				select @v_author_events = cbd.dbo.qweb_get_www_events (@i_bookkey)
				Select @v_Insert_Illus = actualinsertillus from cbd..printing where bookkey = @i_bookkey
				Select @n_title_filelocations = dbo.qweb_ecf_get_title_filelocations(@i_bookkey)
				Select @fullauthordisplayname = dbo.qweb_get_AuthorsPipeSeperated(@i_bookkey)
				Select @ebook_ranking = dbo.qweb_get_subgentables_gen1ind(312, @i_bookkey)
				Select @n_Description_Comment_text = commenttext from cbd..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey


				if @i_skuid is not null 
				begin
				
				exec dbo.mdpsp_avto_SkuEx_Title_By_Format_Update 
				@i_skuid ,				  --@ObjectId INT, 
				0,						  --@CreatorId INT, 
				@d_datetime,			  --@Created DATETIME, 
				0,						  --@ModifierId INT, 
				@d_datetime,			  --@Modified DATETIME, 
				0,						  --@Retval INT OUT,
				@v_edition,				  --@SKU_Edition nvarchar(       512) , 
				@v_Journal_ISSN,		  --@Journal_ISSN nvarchar(       512) , 
				@i_bookkey,				  --@pss_sku_bookkey int,
				@v_Praise,				  --@Praise ntext,
				@v_authorfirstname,		  --@author_first nvarchar(       512) ,
				@v_isdiscounted,		--@isdicounted,
				@v_bisacstatusdesc,		--@sku_titlestatus nvarchar (512)
				@v_Insert_Illus,		--@SKU_Actual_Insert_Illus nvarchar (512 ),
				@v_TrimSize,					--@Trim_Size,
				@v_Awards,				  --@SKU_Awards_Short ntext,
				@v_author_events,			--@sku_author_events,
				@m_fullprice, 			--@sku_fullprice,
				@v_authorlastname,		  --@author_last nvarchar(       512) , 
				Null,  			          --@Web_Page nvarchar(       512) ,
				@v_awardscomment, 		--@SKU_Awards ntext,
				@v_ISBN,				  --@SKU_ISBN nvarchar(       512) , 
				@v_EAN,					  --@SKU_EAN nvarchar(       512) ,
				@v_SubsidyCreditLine,     --@SKU_SubsidyCreditLine ntext,
				@v_authorbylineprepro,	  --@AuthorBylinePrePro ntext, 
				@v_Author_Web_Page,		  --@Author_Web_Page nvarchar(       512) ,
				@d_pubdate,					--@sku_pubdate datetime,
				@v_Society_Web_Site,	  --@Society_Web_Site nvarchar(       512) ,
				@v_neverdiscountflag,	  --@never_discount int,			
				@m_promotionalprice,      --@Journal_PromotionalPrice money, 
				@v_Display,		          --@SKU_Display nvarchar(       512) , 
				@v_title,			      --@SKU_Title nvarchar(       512) , 
				@v_Web_Document,		  --@Web_Document nvarchar(       512) , 
				NULL,                     --@Excerpt int
				@v_fulltitle,		      --@SKU_Full_Title nvarchar(       512) , 
				@v_subtitle,		      --@SKU_Subtitle nvarchar(       512) , 
				NULL,					  --@Digital_Press_Kit int
				@v_Format,			      --@SKU_Format nvarchar(       512) , 
				@i_pagecount,		      --@SKU_pagecount nvarchar(       512) , 
				@v_season,			      --@SKU_season nvarchar(       512) , 
				@v_PubYear,			      --@SKU_PubYear nvarchar(       512) , 
				@v_Discount,		      --@SKU_Discount nvarchar(       512) , 
				@v_series,				  --@SKU_Series nvarchar(       512) , 
				@v_Fullauthordisplayname, --@SKU_fullauthordisplayname nvarchar(       512) , 
				@n_Description_Comment,   --@SKU_Description_Comment ntext, 
				@n_About_Author_Comment,  --@SKU_About_Author_Comment ntext, 
				NULL,					  --@SKU_LargeToThumbImage int, 
				NULL,					  --@SKU_LargeToMediumImage int,
				@n_title_filelocations,	  --File_Location_Links ntext
				@fullauthordisplayname,    --FullAuthorDisplayName
				@TOC,						--TOC ntext
				@reviews,					--Reviews ntext
				@ebook_ranking,				--Ebook_Ranking
				@n_Description_Comment_text  --Description - commenttext
				end
	

END
GO
Grant execute on dbo.qweb_ecf_SkuEx_Title_By_Format to Public
GO
