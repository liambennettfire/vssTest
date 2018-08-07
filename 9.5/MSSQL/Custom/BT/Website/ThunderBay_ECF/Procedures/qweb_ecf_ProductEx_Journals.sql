USE [BT_TB_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_ProductEx_Journals]    Script Date: 01/27/2010 16:52:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER procedure [dbo].[qweb_ecf_ProductEx_Journals] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @i_workkey int,
		@i_titlefetchstatus int,
		@i_productid int,
		@v_fulltitle nvarchar(255),
		@v_subtitle nvarchar(255),
		@v_title nvarchar(255),
		@v_fullauthordisplayname nvarchar(255),
		@d_datetime datetime,
		@m_usretailprice money,
		@i_publishtowebind int,
		@v_metakeywords varchar(512),
		@v_MostRecentIssue_bookkey int,
		@d_dummy_datetime datetime,
		@v_toc varchar(max),
		@v_jstore_ind varchar(max),
		@v_IntructionsToContrib varchar(max),
		@v_MostRecent_VolIssue varchar(max),
		@v_SingleIssueAvail int,
		@v_Journal_Advertising varchar(max),
		@v_Journal_Website varchar(255),
		@v_Online_Journal_Link varchar(255),
		@i_Journals_Single_Issues int,
		@v_Journal_interval varchar(255),
		@v_publisher varchar(255),
		@v_price_text varchar (max),
		@n_Description_Comment varchar(max),
		@i_journal_muse_ind int,
		@v_authormetakeywords varchar(255),
		@v_unformat_fullauthordisplayname varchar(255)

BEGIN

		Select @i_workkey = b.workkey, 
			   @i_publishtowebind = bd.publishtowebind
		from BT..book b, BT..bookdetail bd
		where b.bookkey = bd.bookkey
		and b.bookkey = @i_bookkey
		and mediatypecode = 6 and mediatypesubcode = 1

		IF @i_publishtowebind = 1
		begin
			print 'bookkey'
			print @i_bookkey
			print 'workkey'
			print @i_workkey
	
				Select @v_fulltitle = BT.dbo.qweb_get_Title(@i_bookkey,'F')
				Select @v_title = BT.dbo.qweb_get_Title(@i_bookkey,'T')
				Select @v_subtitle = BT.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fullauthordisplayname = BT.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') + ' ' + 
												  BT.dbo.[qweb_get_Author](@i_bookkey,1,0,'M') + ' ' + 
												  BT.dbo.[qweb_get_Author](@i_bookkey,1,0,'L')
				Select @d_datetime = getdate()
				Select @i_productid = dbo.qweb_ecf_get_product_id(@i_workkey)
				Select @v_metakeywords = BT.dbo.qweb_ecf_get_product_metakeywords(@i_workkey)
				Select @v_jstore_ind = BT.dbo.get_Tab_Journals_JSTOR(@i_bookkey)
				Select @v_IntructionsToContrib = commenthtmllite from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 50 and bookkey = @i_bookkey 
				Select @v_SingleIssueAvail = CASE BT.dbo.[get_Tab_Journals_Single_Issues_Available?](@i_bookkey)
															 WHEN 'Y' Then 1
															 ELSE 0 END
			
				Select @v_MostRecentIssue_bookkey = bookkey 
					from BT..book where bookkey in (Select top 1 d.bookkey
												from BT..bookdates d, BT..bookdetail bd
												where d.bookkey = bd.bookkey 
													and bd.publishtowebind = 1
													and d.datetypecode = 47
													and d.bookkey in (Select childbookkey 
																	  from BT..bookfamily 
																	   where parentbookkey = @i_bookkey)
												order by d.bookkey desc)

				Select @v_MostRecent_VolIssue = commenttext from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 53 and bookkey = @v_MostRecentIssue_bookkey 
				Select @v_toc = commenthtmllite from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 52 and bookkey = @v_MostRecentIssue_bookkey 
				Select @v_Journal_Advertising = commenthtml from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 54 and bookkey = @i_bookkey 
				Select @v_Journal_Website = pathname from BT..filelocation where filetypecode = 8 and bookkey = @i_bookkey 
				Select @v_Online_Journal_Link = pathname from BT..filelocation where filetypecode = 10 and bookkey = @i_bookkey 
				Select @i_Journals_Single_Issues = BT.dbo.[get_Tab_Journals_Single_Issues_Available?] (@i_bookkey)
				Select @v_Journal_interval = BT.dbo.get_Tab_Journals_Journal_Interval (@i_bookkey)
				Select @v_publisher = BT.dbo.qweb_get_GroupLevel3(@i_bookkey,'1')
				select @v_price_text = commenthtmllite from BT..bookcomments where commenttypecode = 1 and commenttypesubcode = 49 and bookkey = @i_bookkey
				Select @n_Description_Comment = commenthtmllite from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey
				select @i_journal_muse_ind = longvalue from BT..bookmisc where misckey=31 and bookkey= @i_bookkey
                                select @v_unformat_fullauthordisplayname = BT.dbo.replace_xchars(@v_fullauthordisplayname)
				select @v_authormetakeywords = @v_fullauthordisplayname + ', ' + @v_unformat_fullauthordisplayname
								
				

				exec dbo.mdpsp_avto_ProductEx_Journals_Update 
				@i_productid,              --@ObjectId INT, 
				1,                         --@CreatorId INT, 
				@d_datetime,               --@ALTERd DATETIME, 
				1,                         --@ModifierId INT, 
				@d_datetime,               --@Modified DATETIME, 
				NULL,                      --@Retval INT OUT, 
				@i_bookkey,                --@pss_product_bookkey int, 
				@n_Description_Comment,	   --@Journal_Description_Comment
				@v_Journal_Advertising,    --@Journal_Adveritising ntext, 
				@v_Journal_interval,	   --@JournalInterval nvarchar(       512) , 
				@v_price_text,		    --@price_text
				@i_journal_muse_ind,   --@journal_muse_ind int	
				@v_Journal_Website,	       --@Journal_WebSite nvarchar(       512), 
				@v_publisher,			   --@Publisher nvarchar(       512) , 
				@v_title,                  --@Product_Title nvarchar(512) ,				
				@v_fulltitle,              --@Product_Full_Title nvarchar(512) ,
				NULL,                      --@JournalLibraryRecommendationForm_File INT
				NULL,    --REMOVED PER BROCK ON 8/8/07 @Online_Journal_Link nvarchar(       512) ,  
				1,						   --@IsJournal int, 
				@v_subtitle,               --@Product_Subtitle nvarchar(512) , 
				@v_fullauthordisplayname,  --@Product_Fullauthordisplayname nvarchar(512) , 
				0,                         --@Product_LargeToThumbImage int, 
				0,                         --@Product_LargeToMediumImage int, 
				@v_metakeywords,           --@MetaKeywords nvarchar(512) , 
				@v_authormetakeywords,  --@AuthorMetaKeywords nvarchar(512) , 				
				@v_toc,                    --@Journal_TOC ntext, 
				@v_jstore_ind,             --@Journal_Jstor_Ind int, 
				@v_fullauthordisplayname,  --@Journal_JournalEditor nvarchar(512) , 
				@v_IntructionsToContrib,   --@Journal_SubmissionGuidelines ntext, 
				@v_MostRecent_VolIssue,    --@Journal_MostRecentVolIssue nvarchar(512) , 
				0						   --@Journal_SingleIssueAvail int,
				
					
				
			 
					



			end
			
END




