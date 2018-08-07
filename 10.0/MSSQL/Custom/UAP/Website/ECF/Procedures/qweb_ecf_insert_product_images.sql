if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_insert_product_images]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_insert_product_images]

GO


CREATE procedure [dbo].[qweb_ecf_insert_product_images] (@i_bookkey int, @v_filepath varchar(255)) as

DECLARE @i_product_id int,
		@i_metaclass_id int,
		@i_prodlarge_metafieldid int,
		@i_prodthumb_metafieldid int,
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
														  and p.code = cast(@i_bookkey as varchar))
		
		delete from metakey where metakey in (Select metakey 
														from metakey m, product p
														where m.metaobjectid = p.productid
														  and p.code = cast(@i_bookkey as varchar))


	DECLARE c_ecf_products INSENSITIVE CURSOR
	FOR

	Select productid, 
	dbo.qweb_ecf_get_metaclassid('Titles'),
	dbo.qweb_ecf_get_MetaFieldID('Product_LargeToMediumImage'),
	dbo.qweb_ecf_get_MetaFieldID('Product_LargeToThumbImage'),
	code
	from product
	where code = cast(@i_bookkey as varchar)
	/*and code in (Select cast(bookkey as varchar) from UAP..bookdetail where publishtowebind = 1)*/

	FOR READ ONLY
			
	OPEN c_ecf_products

	FETCH NEXT FROM c_ecf_products
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prodlarge_metafieldid,
			@i_prodthumb_metafieldid,
			@i_c_bookkey

	select  @i_productfetchstatus  = @@FETCH_STATUS

	 while (@i_productfetchstatus >-1 )
		begin
		IF (@i_productfetchstatus <>-2) 
		begin

		/** BEGIN PRODUCT LARGE IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_prodlarge_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT         --@Retval	INT	OUT
		

		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @v_mediatype = UAP.dbo.qweb_get_Media(@i_c_bookkey, 'D')
		Select @d_datetime = getdate()
		select @i_maxsubbookkey=UAP.dbo.qweb_get_subordinate_max_web(@i_c_bookkey)

		
		--  QSI  -- '\\mcdonald\mediachase\UAP_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		Select @v_file = @v_filepath + Substring(pathname,1,len(pathname)) 
		from UAP..filelocation 
		where printingkey = 1 and filetypecode = 2 and bookkey = @i_maxsubbookkey

		

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

--		If @v_mediatype <> 'Journal'
			begin
			update productex_titles
			set Product_LargeToMediumImage = @i_current_metakey
			where objectid = @i_product_id
			end
--		Else
--			begin
--			update ProductEx_Journals
--			set Product_LargeToMediumImage = @i_current_metakey
--			where objectid = @i_product_id
--			end

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0
		begin
		Select @v_file = @v_filepath + 'cover_placeholder.jpg'
		end 


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file


		/** END PRODUCT LARGE IMAGE **************************************************/

		/** BEGIN PRODUCT THUMBNAIL IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,           --@MetaObjectId INT
		@i_metaclass_id,	     --@MetaClassId	INT,
		@i_prodthumb_metafieldid,--@MetaFieldId	INT,
		@i_current_metakey OUTPUT						 --@Retval	INT	


		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @v_mediatype = UAP.dbo.qweb_get_Media(@i_c_bookkey, 'D')
		Select @d_datetime = getdate()
		select @i_maxsubbookkey=UAP.dbo.qweb_get_subordinate_max_web(@i_c_bookkey)

	
		--  QSI  -- '\\mcdonald\mediachase\UAP_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		Select @v_file = @v_filepath + Substring(pathname,1,len(pathname)) 
		from UAP..filelocation 
		where printingkey = 1 and filetypecode = 2 and bookkey = @i_maxsubbookkey


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


--		If @v_mediatype <> 'Journal'
			begin
			update productex_titles
			set Product_LargeToThumbImage = @i_current_metakey
			where objectid = @i_product_id
			end
--		Else
--			begin
--			update ProductEx_Journals
--			set Product_LargeToThumbImage = @i_current_metakey
--			where objectid = @i_product_id
--			end

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0
		begin
		Select @v_file = @v_filepath + 'cover_placeholder.jpg'
		end  


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		/** END PRODUCT THUMBNAIL IMAGE **************************************************/

	end

FETCH NEXT FROM c_ecf_products
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prodlarge_metafieldid,
			@i_prodthumb_metafieldid,
			@i_c_bookkey

	        select  @i_productfetchstatus  = @@FETCH_STATUS
		end

close c_ecf_products
deallocate c_ecf_products


		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update productex_titles
		set Product_LargeToMediumImage = Null
		where Product_LargeToMediumImage in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes


END


GO
Grant execute on dbo.qweb_ecf_insert_product_images to Public
GO