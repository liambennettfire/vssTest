if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_ecf_insert_sku_excerpts') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].qweb_ecf_insert_sku_excerpts
GO


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

create procedure qweb_ecf_insert_sku_excerpts (@i_bookkey int,@v_filepath varchar(255)) as

DECLARE @i_sku_id int,
		@i_metaclass_id int,
		@i_sku_excerpt_metafieldid int,
		@i_c_bookkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_skufetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40)

BEGIN

	DECLARE c_ecf_skus INSENSITIVE CURSOR
	FOR

	Select s.skuid, 
	dbo.qweb_ecf_get_metaclassid('title_by_format'),
	dbo.qweb_ecf_get_MetaFieldID('Excerpt'),
	f.pss_sku_bookkey
	from sku s, skuex_title_by_format f
	where s.skuid = f.objectid
	and f.pss_sku_bookkey = @i_bookkey 
	and f.pss_sku_bookkey in (Select bookkey from UNL..bookdetail where publishtowebind = 1)
	


	FOR READ ONLY
			
	OPEN c_ecf_skus

	FETCH NEXT FROM c_ecf_skus
		INTO @i_sku_id, 
			@i_metaclass_id,
			@i_sku_excerpt_metafieldid,
			@i_c_bookkey

	select  @i_skufetchstatus  = @@FETCH_STATUS

	 while (@i_skufetchstatus >-1 )
		begin
		IF (@i_skufetchstatus <>-2) 
		begin

		/** BEGIN SKU EXCERPT *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_sku_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_sku_excerpt_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT      --@Retval	INT	OUT


	
		Select @d_datetime = getdate()

		--  QSI  -- '\\mcdonald\mediachase\unl_images\'
		--  UNP  -- '\\unp-muskie\Images\'  

		Select @v_file = @v_filepath + Substring(pathname,4,len(pathname)) 
		from UNL..filelocation 
		where printingkey = 1 and filetypecode = 11 and bookkey = @i_c_bookkey



	-- Will insert or update row based on metakey

		exec [dbo].[mdpsp_sys_UpdateMetaFile]
		@i_current_metakey,	--@MetaKey	INT,
		@v_file,		    --@FileName	NVARCHAR(256),
		'application/pdf',		--@ContentType	NVARCHAR(256),
		0x0,				--@Data		image,
		0,					--@Size		INT,
		@d_datetime,		--@CreationTime	DATETIME,
		@d_datetime,		--@LastWriteTime 	DATETIME,
		@d_datetime			--@LastReadTime	DATETIME

		
		
			update skuex_title_by_format
			set excerpt = @i_current_metakey
			where objectid = @i_sku_id


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		/** END SKU EXCERPT **************************************************/

		end

FETCH NEXT FROM c_ecf_skus
		INTO @i_sku_id, 
			@i_metaclass_id,
			@i_sku_excerpt_metafieldid,
			@i_c_bookkey

	        select  @i_skufetchstatus  = @@FETCH_STATUS
		end

		close c_ecf_skus
		deallocate c_ecf_skus

		-- get rid of missing image rows in metakey and metafilevalue
		-- was causing error
		
		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update skuex_title_by_format
		set excerpt = Null
		where excerpt in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes




END
