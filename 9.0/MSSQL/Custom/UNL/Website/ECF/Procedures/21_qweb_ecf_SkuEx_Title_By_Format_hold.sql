set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[qweb_ecf_SkuEx_Title_By_Format] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @i_titlefetchstatus int,
		@i_skuid int,
		@v_title nvarchar(512),
		@v_subtitle nvarchar(512),
		@v_fulltitle nvarchar(512),
        @v_Fullauthordisplayname nvarchar(512),
		@d_datetime datetime,
		@v_ISBN nvarchar(13), 
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
		@v_neverdiscountflag int



BEGIN

	DECLARE c_qweb_citations INSENSITIVE CURSOR
	FOR

	select q.commenthtmllite, c.citationauthor, c.citationsource
	from UNL..citation c, UNL..qsicomments q
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
		

				Select @v_title = UNL.dbo.qweb_get_Title(@i_bookkey,'s')
				Select @d_datetime = getdate()
				Select @i_skuid = dbo.qweb_ecf_get_sku_id(@i_bookkey)
				Select @v_subtitle =  UNL.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fulltitle = UNL.dbo.qweb_get_Title(@i_bookkey,'f')
				Select @v_fullauthordisplayname = UNL.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') + ' ' + 
												  UNL.dbo.[qweb_get_Author](@i_bookkey,1,0,'M') + ' ' + 
												  UNL.dbo.[qweb_get_Author](@i_bookkey,1,0,'L')
				Select @v_ISBN = UNL.dbo.qweb_get_ISBN(@i_bookkey,'13')
				Select @v_EAN = UNL.dbo.qweb_get_ISBN(@i_bookkey,'16')
				Select @v_Display = ''
				Select @v_Format = UNL.dbo.qweb_get_Format(@i_bookkey,'D')
				Select @i_pagecount = UNL.dbo.qweb_get_BestPageCount(@i_bookkey,1)
				Select @v_season = s.seasondesc
									from UNL..printing p
									Left outer join UNL..season s on p.seasonkey = s.seasonkey
									where printingkey = 1
									and bookkey = @i_bookkey

				Select @v_PubYear = UNL.dbo.qweb_get_Pubmonth(@i_bookkey,1,'Y')
				Select @v_Discount = UNL.dbo.qweb_get_Discount(@i_bookkey,'d')
				Select @v_Series = UNL.dbo.qweb_get_series(@i_bookkey,'d')
				Select @v_edition = UNL.dbo.qweb_get_edition(@i_bookkey,'d')
				Select @i_bisactatuscode = bisacstatuscode from UNL..bookdetail where bookkey = @i_bookkey
				Select @i_sendtoeloind = sendtoeloind from UNL..book where bookkey = @i_bookkey
				Select @v_authorbylineprepro = commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 73 and bookkey = @i_bookkey

				Select @v_authortype = UNL.dbo.qweb_get_Authortype(@i_bookkey,1,'D')
				
			If not exists (select * 
						   from UNL..gentables 
						   where tableid = 134 
							 and datacode in (57,59,61,71,73,74,75,76,77,78) 
							 and datadesc = @v_authortype)

				begin
				Select @v_authorfirstname = UNL.dbo.[qweb_get_Author](@i_bookkey,1,0,'F')
				Select @v_authorlastname = UNL.dbo.[qweb_get_Author](@i_bookkey,1,0,'L')
				end

			Else 
				begin
				Select @v_authorfirstname = ''
				Select @v_authorlastname = ''
				end
					

				If @i_bisactatuscode <> 4 and @i_sendtoeloind <> 0
					begin
					Select @n_Description_Comment = commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey
					Select @n_About_Author_Comment = commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 10 and bookkey = @i_bookkey
					end
				Else 
					begin
					Select @n_Description_Comment = ''
					Select @n_About_Author_Comment = ''
					end			

				Select @i_PrimaryImage = 0
				Select @i_LargeImage = 0
				Select @v_Journal_ISSN = itemnumber from UNL..isbn i, UNL..bookfamily bf where i.bookkey = bf.parentbookkey and bf.childbookkey = @i_bookkey
				Select @v_SubsidyCreditLine = commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 58 and bookkey = @i_bookkey
				Select @m_promotionalprice = finalprice from UNL..bookprice where pricetypecode = 10 and currencytypecode = 6 and bookkey = @i_bookkey
				Select @v_Awards = UNL.dbo.qweb_ecf_get_sku_awards(@i_bookkey)
				Select @v_Web_Page = pathname from UNL..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Author_Web_Page = pathname from UNL..filelocation where filetypecode = 7 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Society_Web_Site = pathname from UNL..filelocation where filetypecode = 9 and bookkey = @i_bookkey and printingkey = 1
				Select @v_Web_Document = pathname from UNL..filelocation where filetypecode = 6 and bookkey = @i_bookkey and printingkey = 1

				If exists (Select * 
						   from UNL..bookprice 
						   where (finalprice is not null 
                             and pricetypecode in (10,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27)
							 and activeind = 1)
							OR
							bookkey in (Select bookkey from UNL..bookorgentry where orglevelkey = 3 and orgentrykey = 15))

					begin							 
					Select @v_neverdiscountflag = 1
					end
				Else
					begin
					Select @v_neverdiscountflag = 0
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
				@v_Praise,				  --@Praise ntext, 
				@v_authorfirstname,		  --@author_first nvarchar(       512) , 
				@v_authorlastname,		  --@author_last nvarchar(       512) , 				
				Null,  			          --@Web_Page nvarchar(       512) , 				
				@v_Awards,				  --@SKU_Awards ntext, 
				@v_ISBN,				  --@SKU_ISBN nvarchar(       512) , 
				@v_EAN,					  --@SKU_EAN nvarchar(       512) , 
				@v_SubsidyCreditLine,     --@SKU_SubsidyCreditLine ntext, 
				@v_authorbylineprepro,	  --@AuthorBylinePrePro ntext, 
				@v_Author_Web_Page,		  --@Author_Web_Page nvarchar(       512) , 
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
				NULL					  --@SKU_LargeToMediumImage int 

				end
	
END


