if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_SkuEx_Journal_By_Price]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_SkuEx_Journal_By_Price]

GO


CREATE procedure [dbo].[qweb_ecf_SkuEx_Journal_By_Price] (@i_bookkey int, @v_importtype varchar(1)) as

DECLARE @i_titlefetchstatus int,
		@i_skuid int,
		@v_sku_name varchar(100),
		@i_pricetypecode int,
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
		@v_Journal_IssueInd varchar(255),
		@v_Journals_Brief_Description varchar(255),
		@v_SubsidyCreditLine varchar(max),
		@m_promotionalprice money,
		@v_Awards varchar(max),
		@v_SKU_title varchar (512),
		@v_journalsubscriptionlocation varchar(255),
		@v_journalsubsrcriptionlength varchar(255),
		@v_authorbylineprepro varchar(max),
		@Journal_IssueInd int,
		@Journals_Single_Issues_Available int,
		@masterJournal_bookkey int
BEGIN

------------------------------------------------------
-------  START JOURNAL PRICE TYPE CURSOR -------------
------------------------------------------------------


	SET @Journals_Single_Issues_Available = (CASE Upper(UAP.dbo.[get_Tab_Journals_Single_Issues_Available?](@i_bookkey))
					WHEN 'YES' Then 1
					ELSE 0 END)


	DECLARE c_qweb_journalskupricetypes INSENSITIVE CURSOR
	FOR

	Select skuid, Name, Substring(code,len(code) -3,2) as pricetypecode
	from sku 
	where Substring(code,1,Patindex('%-%',code)-1) = cast(@i_bookkey as varchar)
	and code like '%-%'
	UNION
	Select skuid, Name, '' as pricetypecode
	from sku 
	where code = cast(@i_bookkey as varchar)
	and code not like '%-%'

	FOR READ ONLY
			
	OPEN c_qweb_journalskupricetypes 

	FETCH NEXT FROM c_qweb_journalskupricetypes 
		INTO @i_skuid, @v_sku_name, @i_pricetypecode

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin
			SET @Journal_IssueInd = 0
			--must be a journal special issue if mediatypesubcode <> 1
			if not exists (Select * from UAP..bookdetail where bookkey = @i_bookkey and mediatypecode = 6 and mediatypesubcode = 1)
				begin
					if @i_pricetypecode = 17 OR @i_pricetypecode = 18
						SET @Journal_IssueInd = 1
					else
						--only inst or ind price types allowed for journal single issues
						--if user added other price types for single issues in TMM  don't add to ECF
						Begin
							goto finished 
						End
				end

				If @Journal_IssueInd = 1
					BEGIN
						Select @masterJournal_bookkey = parentbookkey FROM UAP..bookfamily where childbookkey = @i_bookkey and relationcode = 20005
					END

					


				Select @v_title = UAP.dbo.qweb_get_Title(@i_bookkey,'s')
				-- This is the Journal price type without the title
				Select @v_SKU_title = Substring(@v_sku_name,len(@v_title)+3,len(@v_sku_name))
				Select @v_SKU_title = Substring(@v_SKU_title,1,len(@v_SKU_title) -1)
				PRINT '@v_SKU_title' 
				PRINT @v_SKU_title 
				Select @d_datetime = getdate()
				Select @v_subtitle =  UAP.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fulltitle = UAP.dbo.qweb_get_Title(@i_bookkey,'f')

				Select @v_ISBN = UAP.dbo.qweb_get_ISBN(@i_bookkey,'13')
				Select @v_EAN = UAP.dbo.qweb_get_ISBN(@i_bookkey,'16')
				Select @v_Display = ''
				Select @v_Format = UAP.dbo.qweb_get_Format(@i_bookkey,'D')
				Select @i_pagecount = UAP.dbo.qweb_get_BestPageCount(@i_bookkey,1)
				Select @v_season = s.seasondesc
									from UAP..printing p
									Left outer join UAP..season s on p.seasonkey = s.seasonkey
									where printingkey = 1
									and bookkey = @i_bookkey
				
				Select @v_PubYear = UAP.dbo.qweb_get_Pubmonth(@i_bookkey,1,'Y')
				Select @v_Discount = UAP.dbo.qweb_get_Discount(@i_bookkey,'d')
				Select @v_Series = UAP.dbo.qweb_get_series(@i_bookkey,'d')
				Select @v_edition = UAP.dbo.qweb_get_edition(@i_bookkey,'d')
				Select @v_Journals_Brief_Description = commenttext FROM  UAP..bookcomments WHERE commenttypecode = 3 AND commenttypesubcode = 7 AND bookkey = @i_bookkey
				Select @n_About_Author_Comment = commenthtmllite from UAP..bookcomments where commenttypecode = 3 and commenttypesubcode = 10 and bookkey = @i_bookkey
				Select @i_PrimaryImage = 0
				Select @i_LargeImage = 0
				Select @v_Journal_ISSN = itemnumber from UAP..isbn i where i.bookkey = @i_bookkey
				Select @v_SubsidyCreditLine = commenthtmllite from UAP..bookcomments where commenttypecode = 3 and commenttypesubcode = 58 and bookkey = @i_bookkey
				Select @m_promotionalprice = finalprice from UAP..bookprice where pricetypecode = 10 and currencytypecode = 6 and bookkey = @i_bookkey
				Select @v_Awards = UAP.dbo.qweb_ecf_get_sku_awards(@i_bookkey)
				Select @v_journalsubscriptionlocation = alternatedesc1 from UAP..gentables where datacode = @i_pricetypecode and tableid = 306
				Select @v_journalsubsrcriptionlength = alternatedesc2 from UAP..gentables where datacode = @i_pricetypecode and tableid = 306
			

				--if journal special issue use journal bookkey for the following fields
				If @Journal_IssueInd = 1
					Begin
							Select @v_fullauthordisplayname = UAP.dbo.[qweb_get_Author](@masterJournal_bookkey,0,0,'F') + ' ' + 
								  UAP.dbo.[qweb_get_Author](@masterJournal_bookkey,0,0,'M') + ' ' + 
								  UAP.dbo.[qweb_get_Author](@masterJournal_bookkey,0,0,'L')

							Select @n_Description_Comment = commenthtmllite from UAP..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @masterJournal_bookkey
							Select @v_Journal_ISSN = itemnumber from UAP..isbn i where i.bookkey = @masterJournal_bookkey
							Select @v_authorbylineprepro = commenthtmllite from UAP..bookcomments where commenttypecode = 3 and commenttypesubcode = 73 and bookkey = @masterJournal_bookkey


					End
				Else
					Begin
							Select @v_fullauthordisplayname = UAP.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
								  UAP.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
								  UAP.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')

							Select @n_Description_Comment = commenthtmllite from UAP..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey
							Select @v_Journal_ISSN = itemnumber from UAP..isbn i where i.bookkey = @i_bookkey
							Select @v_authorbylineprepro = commenthtmllite from UAP..bookcomments where commenttypecode = 3 and commenttypesubcode = 73 and bookkey = @i_bookkey
					End


				if @i_skuid is not null
				begin
				exec dbo.mdpsp_avto_SkuEx_Journal_by_PriceType_Update 
				@i_skuid,			           --@ObjectId INT, 
				1,					           --@CreatorId INT, 
				@d_datetime,		           --@Created DATETIME, 
				1,					           --@ModifierId INT, 
				@d_datetime,		           --@Modified DATETIME, 
				0,					           --@Retval INT OUT, 
				@i_bookkey,			           --@pss_sku_bookkey int, 
				@Journals_Single_Issues_Available,	--@JournalsSingleIssues int, 
				@Journal_IssueInd,			   --@Journal_IssueInd( nvarchar(512),
				NULL,							--@JournalAdvertisingLink ntext,
				--@v_Journals_Brief_Description, --@Journals_Brief_Description( nvarchar(512),
				@v_SKU_title,		           --@SKU_Title nvarchar(       512) , 
				@v_fulltitle,		           --@SKU_Full_Title nvarchar(       512) , 
				@v_journalsubscriptionlocation,--@JournalSubscriptionLocation nvarchar(       512) , 
				@v_journalsubsrcriptionlength, --@JournalSubscriptionLength nvarchar(       512) ,
				@v_subtitle,		           --@SKU_Subtitle nvarchar(       512) ,  
				@i_pagecount,		           --@SKU_pagecount nvarchar(       512) , 
				NULL,						   --@author_first nvarchar(       512) , 
				NULL,                          --@author_last nvarchar(       512) , 
				@v_season,			           --@SKU_season nvarchar(       512) , 
				@v_PubYear,			           --@SKU_PubYear nvarchar(       512) ,				
				@v_authorbylineprepro,		   --@AuthorBylinePrePro ntext, 
				1,							   --@never_discount int, @author_last nvarchar(       512) ,  
				@v_Discount,		           --@SKU_Discount nvarchar(       512) , 
				@v_series,			           --@SKU_Series nvarchar(       512) , 
				@v_Fullauthordisplayname,      --@SKU_fullauthordisplayname nvarchar(       512) ,
				@n_Description_Comment,        --@SKU_Description_Comment ntext, 
				@n_About_Author_Comment,       --@SKU_About_Author_Comment ntext, 
				NULL,					       --@SKU_LargeToThumbImage int, 
				NULL,					       --@SKU_LargeToMediumImage int, 
				@v_Journal_ISSN,		       --@Journal_ISSN nvarchar(       512) , 
				@v_Awards,   			       --@SKU_Awards ntext, 
				@v_SubsidyCreditLine,	       --@SKU_SubsidyCreditLine ntext, 
				@m_promotionalprice	           --@Journal_PromotionalPrice money 
				--NULL					       --@JournalLibraryRecommendationForm nvarchar(       512) , 
				end
	finished:

	FETCH NEXT FROM c_qweb_journalskupricetypes
		INTO @i_skuid, @v_sku_name, @i_pricetypecode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
	end
end
			

close c_qweb_journalskupricetypes
deallocate c_qweb_journalskupricetypes


END



GO
Grant execute on dbo.qweb_ecf_SkuEx_Journal_By_Price to Public
GO