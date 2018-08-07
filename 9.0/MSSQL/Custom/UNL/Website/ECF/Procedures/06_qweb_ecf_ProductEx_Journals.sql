if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_ProductEx_Journals]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_ProductEx_Journals]

GO



CREATE procedure [dbo].[qweb_ecf_ProductEx_Journals] (@i_bookkey int, @v_importtype varchar(1)) as
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
		--@v_SingleIssueAvail int,
		@v_Journal_Advertising varchar(max),
		@v_Journal_Website varchar(255),
		@v_Online_Journal_Link varchar(255),
		--@i_Journals_Single_Issues int,
		@v_Journal_interval varchar(255),
		@v_publisher varchar(255),
		@v_price_text varchar (max),
		@n_Description_Comment varchar(max),
		@i_journal_muse_ind int,
		@v_authormetakeywords varchar(255),
		@v_unformat_fullauthordisplayname varchar(255),
		@i_mediatypesubcode int,
		@Journals_Single_Issues_Available int,
		@Issueind int,
		@isVisible int,
		@Journal_ISSN nvarchar(512),
		@masterJournal_bookkey int,
		@Journal_Brief_description nvarchar(512),
		@d_mostrecentdate datetime,
		@n_title_filelocations varchar(max)





BEGIN

--		Select @i_workkey = b.workkey, 
--			   @i_publishtowebind = bd.publishtowebind
--		from UNL..book b, UNL..bookdetail bd
--		where b.bookkey = bd.bookkey
--		and b.bookkey = @i_bookkey
--		and mediatypecode = 6 and mediatypesubcode = 1

		Select @i_workkey = b.workkey, 
		@i_publishtowebind = bd.publishtowebind,
		@i_mediatypesubcode = mediatypesubcode,
		@Journals_Single_Issues_Available = (CASE Upper(UNL.dbo.[get_Tab_Journals_Single_Issues_Available?](@i_bookkey))
				WHEN 'YES' Then 1
				ELSE 0 END)
		from UNL..book b, UNL..bookdetail bd
		where b.bookkey = bd.bookkey
		and b.bookkey = @i_bookkey
		and bd.mediatypecode=6

		If @i_mediatypesubcode = 1
			SET @Issueind = 0
		else
			SET @Issueind = 1 

		--Make it visible only if publishtoweb and Journals_Single_Issues_Available flags are set to true
		If 	@i_publishtowebind = 1 
			SET @isVisible = 1
		else
			SET @isVisible = 0		

		--IF @i_publishtowebind = 1
		begin
--			print 'bookkey'
--			print @i_bookkey
--			print 'workkey'
--			print @i_workkey

				Select @masterJournal_bookkey = parentbookkey FROM UNL..bookfamily where childbookkey = @i_bookkey and relationcode = 20005

	
				Select @v_fulltitle = UNL.dbo.qweb_get_Title(@i_bookkey,'F')
				Select @v_title = UNL.dbo.qweb_get_Title(@i_bookkey,'T')
				Select @v_subtitle = UNL.dbo.qweb_get_SubTitle(@i_bookkey)
				Select @v_fullauthordisplayname = UNL.dbo.[qweb_get_Author](@i_bookkey,1,0,'F') + ' ' + 
												  UNL.dbo.[qweb_get_Author](@i_bookkey,1,0,'M') + ' ' + 
												  UNL.dbo.[qweb_get_Author](@i_bookkey,1,0,'L')
				Select @d_datetime = getdate()
				Select @i_productid = dbo.qweb_ecf_get_product_id(@i_workkey)
				Select @v_metakeywords = UNL.dbo.qweb_ecf_get_product_metakeywords(@i_workkey)
				Select @v_jstore_ind = UNL.dbo.get_Tab_Journals_JSTOR(@i_bookkey)
				Select @v_IntructionsToContrib = commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 50 and bookkey = @i_bookkey 
--				Select @v_SingleIssueAvail = CASE UNL.dbo.[get_Tab_Journals_Single_Issues_Available?](@i_bookkey)
--															 WHEN 'Y' Then 1
--															 ELSE 0 END
			
				select @d_mostrecentdate = max(bestdate) from unl..bookdates ba, unl..bookdetail bd, unl..bookfamily bf
							where ba.bookkey = bd.bookkey
							and ba.bookkey = bf.childbookkey
							and bd.publishtowebind=1
							and ba.datetypecode=47
							and bf.parentbookkey=@i_bookkey


				Select @v_MostRecentIssue_bookkey = bookkey 
					from unl..book where bookkey in (Select top 1 d.bookkey
												from unl..bookdates d, unl..bookdetail bd
												where d.bookkey = bd.bookkey 
													and bd.publishtowebind = 1
													and d.datetypecode = 47
													and d.bestdate = coalesce(@d_mostrecentdate,null)
													and d.bookkey in (Select childbookkey 
																	  from unl..bookfamily 
																	   where parentbookkey = @i_bookkey)
												order by d.bookkey desc)

				Select @v_MostRecent_VolIssue = commenttext from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 53 and bookkey = @v_MostRecentIssue_bookkey 
				IF @Issueind = 0
					begin
						Select @v_toc = commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 52 and bookkey = @v_MostRecentIssue_bookkey 
					end
				IF @issueind = 1
					begin
						Select @v_toc = commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 52 and bookkey = @i_bookkey 
					end
				Select @v_Journal_Advertising = commenthtml from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 54 and bookkey = @i_bookkey 
				Select @v_Journal_Website = pathname from UNL..filelocation where filetypecode = 8 and bookkey = @i_bookkey 
				Select @v_Online_Journal_Link = pathname from UNL..filelocation where filetypecode = 10 and bookkey = @i_bookkey 
				--Select @i_Journals_Single_Issues = UNL.dbo.[get_Tab_Journals_Single_Issues_Available?] (@i_bookkey)
				Select @v_Journal_interval = UNL.dbo.get_Tab_Journals_Journal_Interval (@i_bookkey)
				Select @v_publisher = UNL.dbo.qweb_get_GroupLevel3(@i_bookkey,'1')
				select @v_price_text = commenthtmllite from UNL..bookcomments where commenttypecode = 1 and commenttypesubcode = 49 and bookkey = @i_bookkey
				Select @n_Description_Comment = commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @i_bookkey
				Select @Journal_Brief_description = commentstring from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 7 and bookkey = @i_bookkey

				select @i_journal_muse_ind = longvalue from UNL..bookmisc where misckey=31 and bookkey= @i_bookkey
                select @v_unformat_fullauthordisplayname = UNL.dbo.replace_xchars(@v_fullauthordisplayname)
				select @v_authormetakeywords = @v_fullauthordisplayname + ', ' + @v_unformat_fullauthordisplayname
				--journal single issues has to have the same issn field as the master record			
				Select @Journal_ISSN = itemnumber from UNL..isbn i where i.bookkey = @i_bookkey
				Select @n_title_filelocations = dbo.qweb_ecf_get_title_filelocations(@i_bookkey)

				
				--If single issue and some of the fields are null use master record info instead			
				If @Issueind = 1
					BEGIN
						If 	@masterJournal_bookkey is not null or @masterJournal_bookkey = ''
							Begin
								If @v_fullauthordisplayname is null or rtrim(@v_fullauthordisplayname) = ''
									begin
												Select @v_fullauthordisplayname = UNL.dbo.[qweb_get_Author](@masterJournal_bookkey,1,0,'F') + ' ' + 
												  UNL.dbo.[qweb_get_Author](@masterJournal_bookkey,1,0,'M') + ' ' + 
												  UNL.dbo.[qweb_get_Author](@masterJournal_bookkey,1,0,'L')
													select @v_unformat_fullauthordisplayname = UNL.dbo.replace_xchars(@v_fullauthordisplayname)
												select @v_authormetakeywords = @v_fullauthordisplayname + ', ' + @v_unformat_fullauthordisplayname
									end 
								if @v_Journal_Advertising is null or @v_Journal_Advertising = ''
									begin
										Select @v_Journal_Advertising = commenthtml from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 54 and bookkey = @masterJournal_bookkey 
									end 
								If @v_Journal_Website is null or @v_Journal_Website = ''
									begin
										Select @v_Journal_Website = pathname from UNL..filelocation where filetypecode = 8 and bookkey = @masterJournal_bookkey 
									end 
								if @v_Journal_interval is null or @v_Journal_interval = ''
									begin
										Select @v_Journal_interval = UNL.dbo.get_Tab_Journals_Journal_Interval (@masterJournal_bookkey)
									end
--								if @v_MostRecent_VolIssue is null or @v_MostRecent_VolIssue = ''
--									begin
--											Select @v_MostRecentIssue_bookkey = bookkey 
--											from UNL..book where bookkey in (Select top 1 d.bookkey
--												from UNL..bookdates d, UNL..bookdetail bd
--												where d.bookkey = bd.bookkey 
--													and bd.publishtowebind = 1
--													and d.datetypecode = 47
--													and d.bestdate is not null
--													and d.bookkey in (Select childbookkey 
--																	  from UNL..bookfamily 
--																	   where parentbookkey = @masterJournal_bookkey)
--												order by d.bookkey desc)
--									
--											Select @v_MostRecent_VolIssue = commenttext from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 53 and bookkey = @v_MostRecentIssue_bookkey 
--									end
								--Don't use most recent issue
								Select @v_MostRecent_VolIssue = commenttext from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 53 and bookkey = @i_bookkey
								

								if @v_IntructionsToContrib is null or @v_IntructionsToContrib = ''
									begin
										Select @v_IntructionsToContrib = commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 50 and bookkey = @masterJournal_bookkey 
									end 
								if @Journal_ISSN is null or @Journal_ISSN = ''
									begin
										Select @Journal_ISSN = itemnumber from UNL..isbn i where i.bookkey = @masterJournal_bookkey
									end
								if @n_Description_Comment is null or @n_Description_Comment = ''
									begin
										Select @n_Description_Comment = commenthtmllite from UNL..bookcomments where commenttypecode = 3 and commenttypesubcode = 8 and bookkey = @masterJournal_bookkey
									end
								if @i_journal_muse_ind is null or @i_journal_muse_ind = ''
									begin
										select @i_journal_muse_ind = longvalue from UNL..bookmisc where misckey=31 and bookkey= @masterJournal_bookkey
									end
							End				
					END
				if @i_productid is not null
				begin
					exec dbo.mdpsp_avto_ProductEx_Journals_Update 
					@i_productid,              --@ObjectId INT, 
					1,                         --@CreatorId INT, 
					@d_datetime,               --@Created DATETIME, 
					1,                         --@ModifierId INT, 
					@d_datetime,               --@Modified DATETIME, 
					NULL,                      --@Retval INT OUT, 
					@i_bookkey,                --@pss_product_bookkey int,
					@n_Description_Comment,	   --@Journal_Description_Comment
					@v_Journal_interval,	   --@JournalInterval nvarchar(       512) , 
					@v_price_text,			   --@price_text
					@i_journal_muse_ind,	   --@journal_muse_ind int
					@Issueind,                  --Journal_IssueInd nvarchar(512)				
					@v_Journal_Advertising,    --@Journal_Adveritising ntext, 
					@v_publisher,			   --@Publisher nvarchar(       512) , 
					@v_Journal_Website,	       --@Journal_WebSite nvarchar(       512), 
					@Journal_ISSN,				--Journal_ISSN nvarchar(512)
					@v_title,                  --@Product_Title nvarchar(512) ,	
					@v_fulltitle,              --@Product_Full_Title nvarchar(512) ,
					NULL,						--REMOVED PER BROCK ON 8/8/07 @Online_Journal_Link nvarchar(       512) ,  
					@Journal_Brief_description,  --Journal_Brief_description nvarchar(512)
					NULL,                      --@JournalLibraryRecommendationForm_File INT
					1,						   --@IsJournal int, 
					@v_subtitle,               --@Product_Subtitle nvarchar(512) , 
					@v_fullauthordisplayname,  --@Product_Fullauthordisplayname nvarchar(512) , 
					0,                         --@Product_LargeToThumbImage int, 
					0,                         --@Product_LargeToMediumImage int, 
					@v_metakeywords,           --@MetaKeywords nvarchar(512) , 
					@v_authormetakeywords,	   --@AuthorMetaKeywords nvarchar(512) , 				
					@v_toc,                    --@Journal_TOC ntext, 
					@v_jstore_ind,             --@Journal_Jstor_Ind int, 
					@v_fullauthordisplayname,  --@Journal_JournalEditor nvarchar(512) , 
					@v_IntructionsToContrib,   --@Journal_SubmissionGuidelines ntext, 
					@v_MostRecent_VolIssue,    --@Journal_MostRecentVolIssue nvarchar(512) , 
					@Journals_Single_Issues_Available, --@Journal_SingleIssueAvail int,
					@n_title_filelocations		--@File_Location_Links
				end
			end
			
END

GO
Grant execute on dbo.qweb_ecf_ProductEx_Journals to Public
GO