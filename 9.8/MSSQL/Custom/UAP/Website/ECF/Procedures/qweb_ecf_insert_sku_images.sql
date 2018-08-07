if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_insert_sku_images]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_insert_sku_images]

GO


CREATE procedure [dbo].[qweb_ecf_insert_sku_images] (@i_bookkey int, @v_filepath varchar(255)) as

DECLARE @i_sku_id int,
		@i_metaclass_id int,
		@i_skularge_metafieldid int,
		@i_skuthumb_metafieldid int,
		@i_c_bookkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_skufetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40),
		@i_metakey int,
		@i_fileexists_flag int

BEGIN

	DECLARE c_ecf_skus INSENSITIVE CURSOR
	FOR

	Select s.skuid, 
	dbo.qweb_ecf_get_metaclassid('title_by_format'),
	dbo.qweb_ecf_get_MetaFieldID('SKU_LargeToMediumImage'),
	dbo.qweb_ecf_get_MetaFieldID('SKU_LargeToThumbImage'),
	f.pss_sku_bookkey
	from sku s, skuex_title_by_format f
	where s.skuid = f.objectid
	and f.pss_sku_bookkey = @i_bookkey 
	and f.pss_sku_bookkey in (Select bookkey from UAP..bookdetail where publishtowebind = 1)
	UNION
	Select s.skuid, 
	dbo.qweb_ecf_get_metaclassid('title_by_format'),
	dbo.qweb_ecf_get_MetaFieldID('SKU_LargeToMediumImage'),
	dbo.qweb_ecf_get_MetaFieldID('SKU_LargeToThumbImage'),
	f.pss_sku_bookkey
	from sku s, SkuEx_Journal_by_PriceType f
	where s.skuid = f.objectid
	and f.pss_sku_bookkey = @i_bookkey 
	and f.pss_sku_bookkey in (Select bookkey from UAP..bookdetail where publishtowebind = 1)
	


	FOR READ ONLY
			
	OPEN c_ecf_skus

	FETCH NEXT FROM c_ecf_skus
		INTO @i_sku_id, 
			@i_metaclass_id,
			@i_skularge_metafieldid,
			@i_skuthumb_metafieldid,
			@i_c_bookkey

	select  @i_skufetchstatus  = @@FETCH_STATUS

	 while (@i_skufetchstatus >-1 )
		begin
		IF (@i_skufetchstatus <>-2) 
		begin

		/** BEGIN SKU LARGE IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_sku_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_skularge_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT           --@Retval	INT	OUT

		
		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @v_mediatype = UAP.dbo.qweb_get_Media(@i_c_bookkey, 'D')
		Select @d_datetime = getdate()



		--  QSI  -- '\\mcdonald\mediachase\UAP_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		Select @v_file = @v_filepath + Substring(pathname,1,len(pathname)) 
		from UAP..filelocation 
		where printingkey = 1 and filetypecode = 2 and bookkey = @i_c_bookkey

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

		
		If @v_mediatype <> 'Journal'
			begin
			update skuex_title_by_format
			set SKU_LargeToMediumImage = @i_current_metakey
			where objectid = @i_sku_id
			end
		Else
			begin
			update SkuEx_Journal_by_PriceType
			set SKU_LargeToMediumImage = @i_current_metakey
			where objectid = @i_sku_id
			end

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0

		begin
		Select @v_file = @v_filepath + 'cover_placeholder.jpg'
		end 


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		/** END SKU LARGE IMAGE **************************************************/

		/** BEGIN SKU THUMBNAIL IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_sku_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_skuthumb_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT    --@Retval	INT	OUT



		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @v_mediatype = UAP.dbo.qweb_get_Media(@i_c_bookkey, 'D')
		Select @d_datetime = getdate()


		--  QSI  -- '\\mcdonald\mediachase\UAP_images\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		Select @v_file = @v_filepath + Substring(pathname,1,len(pathname)) 
		from UAP..filelocation 
		where printingkey = 1 and filetypecode = 2 and bookkey = @i_c_bookkey





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

		--print @i_sku_id
		--print @i_metaclass_id
		--print @i_skuthumb_metafieldid
		--print @i_current_metakey

		If @v_mediatype <> 'Journal'
			begin
			update skuex_title_by_format
			set SKU_LargeToThumbImage = @i_current_metakey
			where objectid = @i_sku_id
			end
		Else
			begin
			update SkuEx_Journal_by_PriceType
			set SKU_LargeToThumbImage = @i_current_metakey
			where objectid = @i_sku_id
			end

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0

		begin
		Select @v_file = @v_filepath + 'cover_placeholder.jpg'
		end

		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		/** END SKU THUMBNAIL IMAGE **************************************************/

	end

FETCH NEXT FROM c_ecf_skus
		INTO @i_sku_id, 
			@i_metaclass_id,
			@i_skularge_metafieldid,
			@i_skuthumb_metafieldid,
			@i_c_bookkey

	        select  @i_skufetchstatus  = @@FETCH_STATUS
		end

close c_ecf_skus
deallocate c_ecf_skus

		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update skuex_title_by_format
		set SKU_LargeToMediumImage = Null
		where SKU_LargeToMediumImage in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes




END



GO
Grant execute on dbo.qweb_ecf_insert_sku_images to Public
GO