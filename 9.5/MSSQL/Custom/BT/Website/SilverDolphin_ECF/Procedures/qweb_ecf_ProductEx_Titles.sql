USE [BT_SD_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_ProductEx_Titles]    Script Date: 01/27/2010 16:28:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[qweb_ecf_ProductEx_Titles] (@i_bookkey int, @v_importtype varchar(1)) as
DECLARE @i_workkey int,
		@i_titlefetchstatus int,
		@i_productid int,
		@v_fulltitle nvarchar(255),
		@v_subtitle nvarchar(255),
		@v_title nvarchar(255),
		@v_fullauthordisplayname nvarchar(512),
		@d_datetime datetime,
		@m_usretailprice money,
		@i_publishtowebind int,
		@v_metakeywords varchar(512),
		@v_publisher varchar(255),
		@d_pubdate datetime,
		@v_authormetakeywords varchar(255),
		@v_unformat_fullauthordisplayname varchar(255),
		@v_fullauthordisplaykey int,
		@v_Series_for_title nvarchar(512) ,
		@v_volumenumber int

BEGIN

		Select @i_workkey = b.workkey, 
			   @i_publishtowebind = bd.publishtowebind
		from BT..book b, BT..bookdetail bd
		where b.bookkey = bd.bookkey
		and b.bookkey = @i_bookkey

		Select @i_productid = coalesce (dbo.qweb_ecf_get_product_id(@i_workkey),0)

		
		IF @i_bookkey = @i_workkey /*and @i_publishtowebind = 1*/ and @i_productid <>0
		begin
			/*print 'bookkey'
			print @i_bookkey
			print 'workkey'
			print @i_workkey*/
	
				Select @v_fulltitle = BT.dbo.qweb_get_Title(@i_bookkey,'F')
				Select @v_title = BT.dbo.qweb_get_Title(@i_bookkey,'T')
				Select @v_subtitle = BT.dbo.qweb_get_SubTitle(@i_bookkey)
				
				-- add subtitle to end of title
				if @v_subtitle is not null and ltrim(rtrim(@v_subtitle)) <> '' begin
				  set @v_fulltitle = @v_fulltitle + ': ' +  @v_subtitle
				end
				
--				Select @v_fullauthordisplayname = BT.dbo.[qweb_get_Author](@i_bookkey,0,0,'F') + ' ' + 
--												  BT.dbo.[qweb_get_Author](@i_bookkey,0,0,'M') + ' ' + 
--												  BT.dbo.[qweb_get_Author](@i_bookkey,0,0,'L')
												  
        Select @v_fullauthordisplayname = fullauthordisplayname,
               @v_fullauthordisplaykey = COALESCE(fullauthordisplaykey,0),
               @v_volumenumber = COALESCE(volumenumber,0)
          from BT..bookdetail
         where bookkey = @i_bookkey
                                          
        if ((@v_fullauthordisplayname is null OR ltrim(rtrim(@v_fullauthordisplayname)) = '') AND @v_fullauthordisplaykey > 0) begin
          Select @v_fullauthordisplayname = commenttext 
            from BT..qsicomments
           where commentkey = @v_fullauthordisplaykey
             and commenttypecode = 3
             and commenttypesubcode = 1
        end

				-- add series and volumenumber to end of title
        if @v_volumenumber > 0 
		begin
  				Select @v_Series_for_title = BT.dbo.qweb_get_series(@i_bookkey,'D')

  				if @v_Series_for_title is null OR ltrim(rtrim(@v_Series_for_title)) = '' 
					begin
  					Select @v_Series_for_title = BT.dbo.qweb_get_series(@i_bookkey,'D')
  					end
				if @v_Series_for_title is not null and ltrim(rtrim(@v_Series_for_title)) <> '' 
					begin
				    set @v_fulltitle = @v_fulltitle+ '-' +' #' + cast(@v_volumenumber as varchar)+' '+  @v_Series_for_title 
					end
        end
        												  
				Select @d_datetime = getdate()
				Select @i_productid = dbo.qweb_ecf_get_product_id(@i_workkey)
				Select @v_metakeywords = BT.dbo.qweb_ecf_get_product_metakeywords(@i_workkey)
				Select @v_publisher = BT.dbo.qweb_get_GroupLevel2 (@i_bookkey,'1')
				select @d_pubdate = BT.dbo.qweb_get_BestPubDate_datetime (@i_bookkey,1)
				select @v_unformat_fullauthordisplayname = BT.dbo.replace_xchars(@v_fullauthordisplayname)
				--select @v_authormetakeywords = commenthtmllite from BT..bookcomments where commenttypecode = 3 and commenttypesubcode = 57 and bookkey = @i_bookkey  --@v_fullauthordisplayname + ', ' + @v_unformat_fullauthordisplayname
				select @v_authormetakeywords = replace(BT.dbo.get_comment_htmllite (@i_bookkey,3,57),'<div>','')
				select @v_authormetakeywords = replace(BT.dbo.get_comment_htmllite (@i_bookkey,3,57),'by','')					
				
				exec dbo.mdpsp_avto_ProductEx_Titles_Update 
				@i_productid,			 --@ObjectId INT, 
				1,						 --@CreatorId INT, 
				@d_datetime,			 --@ALTERd DATETIME, 
				1,						 --@ModifierId INT, 
				@d_datetime,			 --@Modified DATETIME, 
				NULL,					 --@Retval INT OUT, 
				@i_bookkey,				 --@pss_product_bookkey int, 
				@v_metakeywords,		 --@MetaKeywords
				0,						 --@IsJournal int, 
				@v_publisher,			 --@Publisher nvarchar(       512) ,
				@d_pubdate,					--@product_pubdate 
				0,						 --@IsAuthor int, 
				0,						-- @Product_InteriorArt_LargeToMedium_Image
				@v_authormetakeywords,            --@AuthorMetaKeywords 
				@v_title,				 --@Product_Title nvarchar(512) , 
				@v_fulltitle,	  		 --@Product_Full_Title nvarchar(512) , 
				@v_subtitle,			 --@Product_Subtitle nvarchar(512) , 
				@v_fullauthordisplayname,        --@Product_Fullauthordisplayname nvarchar(512) , 
				0,						 --@Product_PrimaryImage int, 
				0						 --@Product_LargeImage 
				


			end



END







