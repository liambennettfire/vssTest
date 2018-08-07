if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_ProductEx_Titles]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_ProductEx_Titles]

GO


ALTER procedure [dbo].[qweb_ecf_ProductEx_Titles] (@i_bookkey int, @v_importtype varchar(1)) as
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
		@v_publisher varchar(255),
		@d_pubdate datetime,
		@v_authormetakeywords varchar(255),
		@v_unformat_fullauthordisplayname varchar(255),
		@fullauthordisplayname nvarchar(512)

BEGIN

		Select @i_workkey = b.workkey, 
			   @i_publishtowebind = bd.publishtowebind
		from cbd..book b, cbd..bookdetail bd
		where b.bookkey = bd.bookkey
		and b.bookkey = @i_bookkey

		Select @i_productid = coalesce (dbo.qweb_ecf_get_product_id(@i_workkey),0)

		
		IF @i_bookkey = @i_workkey /*and @i_publishtowebind = 1*/ and @i_productid <>0
		begin
			/*print 'bookkey'
			print @i_bookkey
			print 'workkey'
			print @i_workkey*/
	
				Select @v_fulltitle = cbd.dbo.qweb_get_Title(@i_bookkey,'F')
				Select @v_title = cbd.dbo.qweb_get_Title(@i_bookkey,'T')
				Select @v_subtitle = cbd.dbo.qweb_get_SubTitle(@i_bookkey)
				

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



--
--				cbd.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
--				cbd.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
--				cbd.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')

				Select @d_datetime = getdate()
				Select @i_productid = dbo.qweb_ecf_get_product_id(@i_workkey)
				Select @v_metakeywords = cbd.dbo.qweb_ecf_get_product_metakeywords(@i_workkey)
				Select @v_publisher = cbd.dbo.qweb_get_GroupLevel3 (@i_bookkey,'F')
				select @d_pubdate = cbd.dbo.qweb_get_BestPubDate_datetime (@i_bookkey,1)
				select @v_unformat_fullauthordisplayname = cbd.dbo.replace_xchars(@v_fullauthordisplayname)
				select @v_authormetakeywords = @v_fullauthordisplayname + ', ' + @v_unformat_fullauthordisplayname
				Select @fullauthordisplayname = dbo.qweb_get_AuthorsPipeSeperated(@i_bookkey)				
				
				exec dbo.mdpsp_avto_ProductEx_Titles_Update 
				@i_productid,			 --@ObjectId INT, 
				1,						 --@CreatorId INT, 
				@d_datetime,			 --@Created DATETIME, 
				1,						 --@ModifierId INT, 
				@d_datetime,			 --@Modified DATETIME, 
				NULL,					 --@Retval INT OUT, 
				@i_bookkey,				 --@pss_product_bookkey int, 
				@v_metakeywords,		 --@MetaKeywords
				0,						 --@IsJournal int, 
				@v_publisher,			 --@Publisher nvarchar(       512) ,
				@d_pubdate,					--@product_pubdate 
				@v_authormetakeywords,            --@AuthorMetaKeywords 
				@v_title,				 --@Product_Title nvarchar(512) , 
				@v_fulltitle,	  		 --@Product_Full_Title nvarchar(512) , 
				@v_subtitle,			 --@Product_Subtitle nvarchar(512) , 
				@v_fullauthordisplayname,        --@Product_Fullauthordisplayname nvarchar(512) , 
				0,				 --@Product_PrimaryImage int, 
				0,				 --@Product_LargeImage
				0,				 --IsAuthor	
				@fullauthordisplayname    --FullAuthorDisplayName
			end



END

GO
Grant execute on dbo.qweb_ecf_ProductEx_Titles to Public
GO