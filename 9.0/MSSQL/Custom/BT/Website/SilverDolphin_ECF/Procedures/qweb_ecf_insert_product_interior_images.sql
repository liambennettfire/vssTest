USE [BT_SD_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_insert_product_interior_images]    Script Date: 01/27/2010 16:25:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[qweb_ecf_insert_product_interior_images] (@i_bookkey int, @v_filepath varchar(255)) as

DECLARE @i_product_id int,
		@i_metaclass_id int,
		@i_prodlarge_metafieldid int,
		--@i_prodthumb_metafieldid int,
		@i_c_bookkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_productfetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40),
		@i_fileexists_flag int,
		@i_maxsubbookkey int

BEGIN


		delete from metafilevalue where metakey in (Select metakey 
														from metakey m, product p
														where m.metaobjectid = p.productid
														  and metafieldid = 2154 -- Product_InteriorArt_LargeToMediumImage
														  and p.code = cast(@i_bookkey as varchar))
		
		delete from metakey where metakey in (Select metakey 
														from metakey m, product p
														where m.metaobjectid = p.productid
														  and metafieldid = 2154 -- Product_InteriorArt_LargeToMediumImage
														  and p.code = cast(@i_bookkey as varchar))


	DECLARE c_ecf_products INSENSITIVE CURSOR
	FOR

	Select productid, 
	dbo.qweb_ecf_get_metaclassid('Titles'),
	dbo.qweb_ecf_get_MetaFieldID('Product_InteriorArt_LargeToMediumImage'),
	--dbo.qweb_ecf_get_MetaFieldID('Product_LargeToThumbImage'),
	code
	from product
	where code = cast(@i_bookkey as varchar)
	/*and code in (Select cast(bookkey as varchar) from BT..bookdetail where publishtowebind = 1)*/

	FOR READ ONLY
			
	OPEN c_ecf_products

	FETCH NEXT FROM c_ecf_products
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prodlarge_metafieldid,
			--@i_prodthumb_metafieldid,
			@i_c_bookkey

	select  @i_productfetchstatus  = @@FETCH_STATUS

	 while (@i_productfetchstatus >-1 )
		begin
		IF (@i_productfetchstatus <>-2) 
		begin

--		print 'cursor'
--		print @i_product_id 
--		print @i_metaclass_id
--		print @i_prodlarge_metafieldid
--		print @i_prodthumb_metafieldid
--		print @i_c_bookkey


		/** BEGIN PRODUCT LARGE IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_prodlarge_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT         --@Retval	INT	OUT
		

		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @v_mediatype = BT.dbo.qweb_get_Media(@i_c_bookkey, 'D')
		Select @d_datetime = getdate()
		select @i_maxsubbookkey=coalesce(BT.dbo.qweb_get_subordinate_max_web(@i_c_bookkey),0)
		
		IF coalesce(@i_maxsubbookkey,0)<>0 and @i_maxsubbookkey in (select bookkey from BT..filelocation where printingkey=1 and filetypecode=12)
			begin
			select @i_maxsubbookkey = @i_maxsubbookkey
			end

		IF coalesce(@i_maxsubbookkey,0)<>0 and @i_maxsubbookkey not in (select bookkey from BT..filelocation where printingkey=1 and filetypecode=12)
			begin
			select @i_maxsubbookkey = @i_c_bookkey 
			end

		IF coalesce(@i_maxsubbookkey,0)=0
			begin
			select @i_maxsubbookkey = @i_c_bookkey
			end

--		print @i_maxsubbookkey	

		
		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		Select @v_file = @v_filepath + Substring(pathname,len(pathname)-18,len(pathname)) 
		from BT..filelocation 
		where printingkey = 1 and filetypecode = 12 and bookkey = @i_maxsubbookkey

--		print 'v_file'
--		print @v_file

		-- Will insert or update row based on metakey

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'image/pjpeg',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME

		begin
			update productex_titles
			set Product_InteriorArt_LargeToMediumImage = @i_current_metakey
			where objectid = @i_product_id
			end


		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0
--
--		print 'file exists'
--		print @i_fileexists_flag

		begin
		Select @v_file = @v_filepath + 'SD_InteriorArtDefault.jpg'
		end 


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file


		/** END PRODUCT LARGE IMAGE **************************************************/

	end

FETCH NEXT FROM c_ecf_products
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prodlarge_metafieldid,
			--@i_prodthumb_metafieldid,
			@i_c_bookkey

	        select  @i_productfetchstatus  = @@FETCH_STATUS
		end

close c_ecf_products
deallocate c_ecf_products


		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update productex_titles
		set   Product_InteriorArt_LargeToMediumImage = Null
		where Product_InteriorArt_LargeToMediumImage in (Select metakey from #tempmetakeydeletes)




		drop table #tempmetakeydeletes


END



