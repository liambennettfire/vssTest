IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qweb_ecf_SkuEx_Journal_By_Price]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qweb_ecf_SkuEx_Journal_By_Price]
go

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
		@v_SubsidyCreditLine varchar(max),
		@m_promotionalprice money,
		@v_Awards varchar(max),
		@v_SKU_title varchar (512),
		@v_journalsubscriptionlocation varchar(255),
		@v_journalsubsrcriptionlength varchar(255),
		@v_authorbylineprepro varchar(max)

BEGIN

------------------------------------------------------
-------  START JOURNAL PRICE TYPE CURSOR -------------
------------------------------------------------------
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

				Select @v_title = barb.dbo.qweb_get_Title(@i_bookkey,'s')
				-- This is the Journal price type without the title
				Select @v_SKU_title = Substring(@v_sku_name,len(@v_title)+3,len(@v_sku_name))
				Select @v_SKU_title = Substring(@v_SKU_title,1,len(@v_SKU_title) -1)
				PRINT '@v_SKU_title' 
				PRINT @v_SKU_title 
				Select @d_datetime = getdate()
				Select @v_subtitle =  barb.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fulltitle = barb.dbo.qweb_get_Title(@i_bookkey,'f')
				Select @v_fullauthordisplayname = barb.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
												  barb.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
												  barb.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')
				Select @v_ISBN = barb.dbo.qweb_get_ISBN(@i_bookkey,'13')
				Select @v_EAN = barb.dbo.qweb_get_ISBN(@i_bookkey,'16')
				Select @v_Display = ''
				Select @v_Format = barb.dbo.qweb_get_Format(@i_bookkey,'D')
				Select @i_pagecount = barb.dbo.qweb_get_BestPageCount(@i_bookkey,1)
				Select @v_season = s.seasondesc
									from barb..printing p
									Left outer join barb..season s on p.seasonkey = s.seasonkey
									where printingkey = 1
									and bookkey = @i_bookkey
				
				Select @v_PubYear = barb.dbo.qweb_get_Pubmonth(@i_bookkey,1,'Y')
				Select @v_Discount = barb.dbo.qweb_get_Discount(@i_bookkey,'d')
				Select @v_Series = barb.dbo.qweb_get_series(@i_bookkey,'d')
				Select @v_edition = barb.dbo.qweb_get_edition(@i_bookkey,'d')
				Select @n_Description_Comment = commenthtmllite from barb..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey
				Select @n_About_Author_Comment = commenthtmllite from barb..bookcomments where commenttypecode = 3 and commenttypesubcode = 10 and bookkey = @i_bookkey
				Select @i_PrimaryImage = 0
				Select @i_LargeImage = 0
				Select @v_Journal_ISSN = itemnumber from barb..isbn i where i.bookkey = @i_bookkey
				Select @v_SubsidyCreditLine = commenthtmllite from barb..bookcomments where commenttypecode = 3 and commenttypesubcode = 58 and bookkey = @i_bookkey
				Select @m_promotionalprice = finalprice from barb..bookprice where pricetypecode = 10 and currencytypecode = 6 and bookkey = @i_bookkey
				Select @v_Awards = barb.dbo.qweb_ecf_get_sku_awards(@i_bookkey)
				Select @v_journalsubscriptionlocation = alternatedesc1 from barb..gentables where datacode = @i_pricetypecode and tableid = 306
				Select @v_journalsubsrcriptionlength = alternatedesc2 from barb..gentables where datacode = @i_pricetypecode and tableid = 306
				Select @v_authorbylineprepro = commenthtmllite from barb..bookcomments where commenttypecode = 3 and commenttypesubcode = 73 and bookkey = @i_bookkey
			

				
				exec dbo.mdpsp_avto_SkuEx_Journal_by_PriceType_Update 
				@i_skuid,			           --@ObjectId INT, 
				1,					           --@CreatorId INT, 
				@d_datetime,		           --@Created DATETIME, 
				1,					           --@ModifierId INT, 
				@d_datetime,		           --@Modified DATETIME, 
				0,					           --@Retval INT OUT, 
				@i_bookkey,			           --@pss_sku_bookkey int, 
				0,						       --@JournalsSingleIssues int, 
				NULL,					       --@JournalAdvertisingLink ntext,
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
				0,							   --@never_discount int, @author_last nvarchar(       512) ,  
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


	FETCH NEXT FROM c_qweb_journalskupricetypes
		INTO @i_skuid, @v_sku_name, @i_pricetypecode
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end
end
			

close c_qweb_journalskupricetypes
deallocate c_qweb_journalskupricetypes


END




