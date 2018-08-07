
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_SkuEx_Title_By_Format]    Script Date: 02/02/2011 10:39:19 ******/
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
		@i_PrimaryImage int, 
		@i_LargeImage int,
		@v_Journal_ISSN varchar(20),
		@v_SubsidyCreditLine varchar(max),
		--@m_promotionalprice money,
		@m_fullprice money,
		--@v_Awards varchar(max),
		@v_Web_Page varchar(255),
		@v_Author_Web_Page varchar(255),
		--@v_Society_Web_Site varchar(255),
		@v_Web_Document varchar(255),
		--@v_Citation_Author varchar(80),
		--@v_Citation_Source varchar(80),
		--@v_Citation_Text varchar(max),
		--@v_Praise varchar(max),
		--@i_citation_fetchstatus int,
		@i_bisactatuscode int,
		@i_sendtoeloind int,
		@v_authorfirstname varchar(120),
		@v_authorlastname varchar(120),
		@v_authorbylineprepro varchar(max),
		@v_authortype varchar(255),
		--@v_neverdiscountflag int,
		--@v_isdiscounted int,
		@d_pubdate datetime,
		@v_bisacstatusdesc varchar (255),
		--@v_awardscomment varchar(max),
		--@v_author_events varchar(max),
		--new for aph
		@v_copyright varchar (255),
		--@v_childformat varchar (255),
		@n_agencynote_comment varchar (max),
		@n_toc_comment varchar (max),
		@v_orgentry varchar(255),
		@v_itemnumber varchar(255),
		--@v_agencyaddress varchar (255),
		@v_contactinfo varchar (max),
		@v_search_format varchar (255),
		@v_product_specs varchar (max),
		@v_addtl_isbns varchar (max),
		@v_volumenumber varchar (255),
		@i_isproduct int,
		@v_graderange varchar (max),
		@v_agerange varchar (max),
		@v_publisher varchar (255),
		@i_aph_logo int,
		@v_original_publisher varchar (255),
--		@v_earlystartyear varchar (255),
--		@v_stateedition varchar (255),
--		@i_stateeditionind  int,
		@i_downloadind int,
		@v_efile_path varchar (255),
		@v_efile_path_raw varchar (255),
		@v_sourcecode varchar(20),
		@v_orgentryext varchar (275),
		@v_orgentry3 varchar(255),
		@v_gradelevel varchar(max),
		@v_membership_statement varchar(max),
		@v_sku_hidden_terms varchar(max),
		@v_sku_file_ext varchar(255),
		@v_sku_migel_full_text_link varchar(max)
		
	

BEGIN
--
--	DECLARE c_qweb_citations INSENSITIVE CURSOR
--	FOR
--
--	select q.commenthtmllite, c.citationauthor, c.citationsource
--	from pss..citation c, pss..qsicomments q
--	where c.webind=1
--	and c.qsiobjectkey=q.commentkey
--	and bookkey = @i_bookkey
--	order by sortorder
--
--	FOR READ ONLY
--			
--	OPEN c_qweb_citations 
--
--	FETCH NEXT FROM c_qweb_citations 
--		INTO @v_Citation_Text, @v_Citation_Author, @v_Citation_Source
--
--	select  @i_citation_fetchstatus  = @@FETCH_STATUS
--
--	 while (@i_citation_fetchstatus >-1 )
--		begin
--		IF (@i_citation_fetchstatus <>-2) 
--		begin
--
--		--Select @v_Praise =  ISNULL(@v_Praise,'')  + @v_Citation_Text + ' -' + ISNULL(@v_Citation_Author,'') + ', ' + ISNULL(@v_Citation_Source,'') + '<BR><BR>'
--		Select @v_Praise =  ISNULL(@v_Praise,'')  + @v_Citation_Text + '<BR>'
--
--		end
--
--	FETCH NEXT FROM c_qweb_citations
--		INTO @v_Citation_Text, @v_Citation_Author, @v_Citation_Source
--	        select  @i_citation_fetchstatus  = @@FETCH_STATUS
--		end
--
--	close c_qweb_citations
--	deallocate c_qweb_citations
		

				Select @v_title = pss.dbo.qweb_get_Title(@i_bookkey,'s')
				Select @d_datetime = getdate()
				Select @i_skuid = dbo.qweb_ecf_get_sku_id(@i_bookkey)
				Select @v_subtitle =  pss.dbo.qweb_get_SubTitle(@i_bookkey)
--				IF @v_subtitle =''
--					begin
--						select @v_subtitle = null
--					end
				Select @v_fulltitle = pss.dbo.qweb_get_Title(@i_bookkey,'f')
				--print @v_fulltitle
				Select @v_fullauthordisplayname = fullauthordisplayname from pss..bookdetail where bookkey = @i_bookkey
				--Select @v_fullauthordisplayname = pss.dbo.[qweb_get_Author_by_type](@i_bookkey,12,'C')
--
--												  pss.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
--												  pss.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
--												  pss.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')

				--Select @v_ISBN = pss.dbo.qweb_get_ISBN(@i_bookkey,'13') + ',' + pss.dbo.qweb_get_ISBN(@i_bookkey,'16') + ',' + 					pss.dbo.qweb_get_ISBN(@i_bookkey,'10') + ',' + pss.dbo.qweb_get_ISBN(@i_bookkey,'17')
				--Select @v_ISBN = pss.dbo.qweb_get_ISBN(@i_bookkey,'10')
				Select @v_ISBN = commenttext from pss..bookcomments where commenttypecode=1 and commenttypesubcode=45 and bookkey=@i_bookkey
				Select @v_EAN = pss.dbo.qweb_get_ISBN(@i_bookkey,'17') 
				Select @v_Display = ''
				Select @v_Format = pss.dbo.qweb_get_Format(@i_bookkey,'1')
				IF @v_Format = ''
					BEGIN
						Select @v_Format = pss.dbo.qweb_get_Format(@i_bookkey,'2')
					END
				IF @v_Format = ''
					BEGIN
						Select @v_Format = null
					END

				Select @i_pagecount =''
				Select @i_pagecount = coalesce(pss.dbo.qweb_get_BestPageCount(@i_bookkey,1),'')
				IF @i_Pagecount =''
					begin
					select @i_Pagecount = pss.dbo.qweb_get_BestInsertIllus(@i_bookkey,1)
					end
				
				Select @v_season = seasondesc from pss..coretitleinfo where printingkey = 1 and bookkey = @i_bookkey																
				Select @v_Discount = pss.dbo.qweb_get_Discount(@i_bookkey,'d')				
				select @v_sourcecode = rtrim(pss.dbo.qweb_get_GroupLevel2(@i_bookkey,'S'))
				Select @i_bisactatuscode = bisacstatuscode from pss..bookdetail where bookkey = @i_bookkey
				
				Select @i_sendtoeloind = releasetoeloquenceind from pss..bookcomments where commenttypecode = 3 and (commenttypesubcode = 8 or commenttypesubcode = 10) and bookkey = @i_bookkey
				select @v_orgentry = pss.dbo.qweb_get_GroupLevel2 (@i_bookkey,'1')
				select @v_orgentryext = @v_sourcecode+' '+@v_orgentry  
				select @v_orgentry3 =pss.dbo.qweb_get_GroupLevel3 (@i_bookkey,'1')
				--select @v_itemnumber = pss.dbo.qweb_get_Isbn (@i_bookkey,'22')
				Select @v_Series = pss.dbo.qweb_get_series(@i_bookkey,'1')
				select @v_itemnumber = textvalue from pss..bookmisc where bookkey=@i_bookkey and misckey=28 
				select @v_itemnumber = @v_itemnumber --+' Location: '+ textvalue from pss..bookmisc where bookkey=@i_bookkey and misckey=27
				
				select @v_volumenumber = volumenumber from pss..bookdetail where bookkey=@i_bookkey
				select @v_product_specs = pss.dbo.get_aph_migel_specs(@i_bookkey) 				
				select @v_search_format = pss.dbo.qweb_get_Format(@i_bookkey,'2')
				--select @v_agencyaddress = pss.dbo.qweb_get_contact_address (@i_bookkey,54,1)
				
				select @v_copyright = substring(convert(varchar(20),activedate,101),7,10) from pss..bookdates where bookkey =@i_bookkey and datetypecode=484
				begin
				IF @v_copyright ='' or @v_copyright is null
					select @v_copyright = textvalue from pss..bookmisc where bookkey=@i_bookkey and misckey=45
				IF @v_copyright ='' or @v_copyright is null
					Select @v_PubYear =  substring(convert(varchar(20),activedate,101),7,10) from pss..bookdates where bookkey =@i_bookkey and datetypecode=8
				Else Select @v_PubYear = @v_copyright
				end
				
				Select @v_authorbylineprepro =''
				Select @v_authorbylineprepro = commenthtmllite from pss..bookcomments where commenttypecode = 3 and commenttypesubcode = 73 and bookkey = @i_bookkey
				
				Select @v_authortype = pss.dbo.qweb_get_Authortype(@i_bookkey,1,'D')
				begin
				If not exists (select * 
						   from pss..gentables 
						   where tableid = 134 
							 and datacode in (57,59,61,71,73,74,75,76,77,78) 
							 and datadesc = @v_authortype)

					begin
					Select @v_authorfirstname = pss.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') + ',' +
					pss.dbo.[qweb_get_Author](@i_bookkey,2,0,'F') + ',' +
					pss.dbo.[qweb_get_Author](@i_bookkey,3,0,'F') + ',' +
					pss.dbo.[qweb_get_Author](@i_bookkey,4,0,'F') + ',' +
					pss.dbo.[qweb_get_Author](@i_bookkey,5,0,'F') + ',' +
					pss.dbo.[qweb_get_Author](@i_bookkey,6,0,'F') 

					Select @v_authorlastname = pss.dbo.[qweb_get_Author](@i_bookkey,1,0,'L') + ',' +
					pss.dbo.[qweb_get_Author](@i_bookkey,2,0,'L') + ',' +
					pss.dbo.[qweb_get_Author](@i_bookkey,3,0,'L') + ',' +
					pss.dbo.[qweb_get_Author](@i_bookkey,4,0,'L') + ',' +
					pss.dbo.[qweb_get_Author](@i_bookkey,5,0,'L') + ',' +
					pss.dbo.[qweb_get_Author](@i_bookkey,6,0,'L') 
					end

				Else 
					begin
					Select @v_authorfirstname = ''
					Select @v_authorlastname = ''
					end
				end	

--				If @i_bisactatuscode in (4,10) and coalesce (@i_sendtoeloind,0) <> 1
--					begin
--					 Select @n_Description_Comment = ''
--					 Select @n_About_Author_Comment = ''
--					end		
--				Else 
				--begin
				
				select @v_sku_migel_full_text_link = commenttext from pss..bookcomments where commenttypecode = 3 and commenttypesubcode = 59 and bookkey = @i_bookkey
				Select @n_Description_Comment = commenthtmllite from pss..bookcomments where commenttypecode = 3 and commenttypesubcode = 7 and bookkey = @i_bookkey
				Select @n_About_Author_Comment = commenthtmllite from pss..bookcomments where commenttypecode = 3 and commenttypesubcode = 10 and bookkey = @i_bookkey
--				select @v_earlystartyear = coalesce (longvalue,'') from pss..bookmisc where misckey=17 and bookkey=@i_bookkey   
--				select @i_stateeditionind = coalesce (longvalue,0) from pss..bookmisc where misckey=18 and bookkey=@i_bookkey and longvalue=1
--				select @v_stateedition = 'Yes' where @i_stateeditionind = 1
--				select @v_stateedition ='N' where @i_stateeditionind = 0
				Select @n_agencynote_comment =''
				Select @n_agencynote_comment = cast(commenthtmllite as varchar(max)) from pss..bookcomments where commenttypecode = 1 and commenttypesubcode = 35 and bookkey = @i_bookkey
				select @v_membership_statement =''
				select @v_membership_statement = cast(commenthtmllite as varchar(max)) from pss..bookcomments where commenttypecode = 1 and commenttypesubcode = 52 and bookkey = @i_bookkey
				IF 	coalesce(@v_membership_statement,'')<>''
					begin
						select @n_agencynote_comment = @n_agencynote_comment + ' Membership Statement: '+ @v_membership_statement
					end		
				
				--Select @n_agencynote_comment = coalesce(@n_agencynote_comment,'') + '<Div> Early Start Year: '+ coalesce(@v_earlystartyear,'') + ', ' + 'State Edition: '+coalesce(@v_stateedition,'')+ '</div>'
				Select @n_toc_comment = commenthtmllite from pss..bookcomments where commenttypecode = 3 and commenttypesubcode = 52 and bookkey = @i_bookkey
--				Select @v_addtl_isbns = commenthtmllite from pss..bookcomments where commenttypecode = 1 and commenttypesubcode = 45 and bookkey = @i_bookkey
--				Select @v_addtl_isbns = replace(@v_addtl_isbns,'-','')
--				--end
						

				Select @i_PrimaryImage = 0
				Select @i_LargeImage = 0
				Select @v_Journal_ISSN = textvalue from pss..bookmisc where bookkey = @i_bookkey and misckey=42
				--Select @v_SubsidyCreditLine = commenthtmllite from pss..bookcomments where commenttypecode = 3 and commenttypesubcode = 58 and bookkey = @i_bookkey
				--Select @m_promotionalprice = finalprice from pss..bookprice where pricetypecode = 10 and currencytypecode = 6 and bookkey = @i_bookkey
				Select @m_fullprice = finalprice from pss..bookprice where pricetypecode = 8 and currencytypecode = 6 and bookkey = @i_bookkey

				--Select @v_Awards = dbo.qweb_ecf_get_sku_awards(@i_bookkey)
				--select @v_awardscomment = pss.dbo.get_Comment_HTMLLITE (@i_bookkey,1,30)
				Select @v_Web_Page = pathname from pss..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
				--Select @v_Author_Web_Page = pathname from pss..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
				--Select @v_Society_Web_Site = pathname from pss..filelocation where filetypecode = 9 and bookkey = @i_bookkey and printingkey = 1
				--Select @v_Web_Document = pathname from pss..filelocation where filetypecode = 6 and bookkey = @i_bookkey and printingkey = 1
				Select @v_efile_path_raw =''
				Select @v_efile_path_raw = pathname from pss..filelocation where filetypecode in (11,12) and bookkey = @i_bookkey and printingkey = 1
				Select @v_efile_path = '~/efiles/' + replace(substring (@v_efile_path_raw,4,len(@v_efile_path_raw)),'\','/')
				select @i_downloadind = 0
				Select @i_downloadind = 1 from pss..filelocation where filetypecode = (11) and bookkey = @i_bookkey and printingkey = 1
				Select @i_downloadind = 2 from pss..filelocation where filetypecode = (12) and bookkey = @i_bookkey and printingkey = 1
				
--				If exists (Select * from pss..bookprice where 
--		                           (bookkey=@i_bookkey
--		                           and finalprice is not null 
--		                           and pricetypecode in (10,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27) 
--                                           and activeind = 1)
--		                           OR
--		                           (bookkey=@i_bookkey 
--                                           and bookkey in 
--                                           (Select bookkey from pss..bookorgentry where orglevelkey = 3 and orgentrykey = 15)))
--
--					begin							 
--					Select @v_neverdiscountflag = 1
--					end
--				Else
--					begin
--					Select @v_neverdiscountflag = 0
--					end	
--
--				If exists (Select * from pss..bookprice 
--					   where (finalprice is not null 
--                             		   and pricetypecode in (10) and activeind = 1)
--					   and bookkey=@i_bookkey)
--
--					begin							 
--					Select @v_isdiscounted = 1
--					end
--				Else
--					begin
--					Select @v_isdiscounted = 0
--					end

				select @d_pubdate = pss.dbo.qweb_get_BestPubDate_datetime (@i_bookkey,1)
				select @v_bisacstatusdesc = pss.dbo.qweb_get_bisacstatus  (@i_bookkey,'1')
				--select @v_author_events = pss.dbo.qweb_get_www_events (@i_bookkey)
				select @i_isproduct = 0
				select @i_isproduct = 1 where @v_orgentry3 ='APH Products'
--				select @v_publisher = pss.dbo.qweb_get_GroupLevel2	(@i_bookkey,'1')
--				select @v_original_publisher = pss.dbo.qweb_get_Author_by_type (@i_bookkey,58,'l')
				select @v_publisher = textvalue from pss..bookmisc where bookkey=@i_bookkey and misckey=30
				select @v_original_publisher = textvalue from pss..bookmisc where bookkey=@i_bookkey and misckey=30
				select @i_aph_logo = 1 where @v_publisher ='American Printing House for the Blind'
				select @v_contactinfo = pss.dbo.qweb_get_agency_contact_info (@i_bookkey)
				
				select @v_sku_hidden_terms = pss.dbo.qweb_ecf_get_sku_hidden_terms (@i_bookkey) 
				select @v_sku_file_ext= substring(itemnumber,len(itemnumber)-1,len(itemnumber))
										from skuex_title_by_format where sku_efile_path is not null
										and pss_sku_bookkey=@i_bookkey



				/*for RFBD titles, check for comment first, if empty then proceed as normal*/


				select @v_Series = cast(commenttext as varchar(512)) from pss..bookcomments where commenttypecode = 3 and commenttypesubcode = 45 and bookkey = @i_bookkey 
				IF coalesce(@v_Series,'')=''
					begin
						select @v_Series =pss.dbo.qweb_get_series(@i_bookkey,'1')
					end		
				--print @v_Series

				select @v_original_publisher = cast(commenttext as varchar(max)) from pss..bookcomments where commenttypecode = 1 and commenttypesubcode = 62 and bookkey = @i_bookkey 
				IF coalesce(@v_original_publisher,'')=''
					begin
						select @v_original_publisher = pss.dbo.qweb_get_Author_by_type (@i_bookkey,58,'l')
					end		
				--print @v_original_publisher


				select @v_edition = ''
				select @v_edition = cast(commenthtmllite as varchar(max)) from pss..bookcomments where commenttypecode = 1 and commenttypesubcode = 61 and bookkey = @i_bookkey 
				IF coalesce(@v_edition,'')=''
					begin
						--Select @v_edition = pss.dbo.qweb_get_edition(@i_bookkey,'d')
						 Select @v_edition = editiondescription from pss..bookdetail where bookkey=@i_bookkey	
					end		
				--print @v_edition
				select @v_agerange =''
				select @v_agerange = cast(commenthtmllite as varchar(max)) from pss..bookcomments where commenttypecode = 1 and commenttypesubcode = 59 and bookkey = @i_bookkey 
				IF coalesce(@v_agerange,'')=''
					begin
						select @v_agerange = pss.dbo.get_best_age(@i_bookkey)
					end		
				
				select @v_graderange =''
				select @v_graderange = cast(commenthtmllite as varchar(max)) from pss..bookcomments where commenttypecode = 1 and commenttypesubcode = 58 and bookkey = @i_bookkey
				select @v_gradelevel =''
				select @v_gradelevel = cast(commenthtmllite as varchar(max)) from pss..bookcomments where commenttypecode = 1 and commenttypesubcode = 51 and bookkey = @i_bookkey
				IF coalesce(@v_gradelevel,'')<>''
					begin
						select @v_graderange = @v_graderange + ' Grade Level: '+ @v_gradelevel
					end						
				
				IF coalesce(@v_graderange,'')=''
					begin
						select @v_graderange = pss.dbo.get_best_grade(@i_bookkey)						
					end
				
				
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
				@v_bisacstatusdesc,		--@sku_titlestatus nvarchar (512)
				null,--@v_Praise,				  --@Praise ntext, 
				@v_authorfirstname,		  --@author_first nvarchar(       512) ,
				null,--@v_isdiscounted,		--@isdicounted,
				@v_original_publisher,  --@sku_original_pubisher_II
				@v_volumenumber,		--sku_volume nvarchar(512)
				@v_sku_hidden_terms,	--sku_hidden_terms (ntext)
				@m_fullprice, 			--@sku_fullprice,
				@v_authorlastname,		  --@author_last nvarchar(       512) , 
				Null,  			          --@Web_Page nvarchar(       512) ,
				null,--@v_author_events,			--@sku_author_events
				NULL,--@v_Awards,				  --@SKU_Awards ntext,
				--@v_awardscomment, 		--@SKU_Awards ntext,
				@v_ISBN,				  --@SKU_ISBN nvarchar(       512) , 
				@v_EAN,					  --@SKU_EAN nvarchar(       512) , 
				null,--@v_SubsidyCreditLine,     --@SKU_SubsidyCreditLine ntext, 
				@v_authorbylineprepro,	  --@AuthorBylinePrePro ntext, 
				NULL,--@v_Author_Web_Page,		  --@Author_Web_Page nvarchar(       512) , 
				@d_pubdate,			--@sku_pubdate datetime,
				@v_sku_file_ext,		--sku_file_ext nvarchar(512)
				NULL,--@v_Society_Web_Site,	  --@Society_Web_Site nvarchar(       512) ,
				null,--@v_neverdiscountflag,	  --@never_discount int,	 
				null,--@m_promotionalprice,      --@Journal_PromotionalPrice money, 
				@v_Display,		          --@SKU_Display nvarchar(       512) , 
				@v_title,			      --@SKU_Title nvarchar(       512) , 
				NULL,--@v_Web_Document,		  --@Web_Document nvarchar(       512) , 
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
				NULL,					  --@sku_largetomediumimage
				@v_copyright,			  --@copyrightyear			 nvarchar512
				@v_orgentryext,			  --@orgentry3
				@n_agencynote_comment,	  --@agencynotehtml
				@n_toc_comment,			  --@tableofcontents
				@v_itemnumber,			  --@itemnumber	
				@v_addtl_isbns,			  --@sku_addtl_isbns
				null,--@v_agencyaddress,		  --@sku_agencyaddress	
				@v_product_specs,		  --@sku_specifications	
				@v_contactinfo,					 --future contact info
				@v_search_format,		  --@sku_search_format	
				@i_isproduct,			  --@isproduct	
				@v_publisher,
				@v_agerange, 
				@v_graderange, 
				@i_aph_logo,
				@v_original_publisher,--@v_original_publisher,
				@i_downloadind, 
				@v_efile_path,
				@v_sku_migel_full_text_link				

				end
	
END













