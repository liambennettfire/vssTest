if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_insert_journal_reco_forms]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_insert_journal_reco_forms]

GO


CREATE procedure [dbo].[qweb_ecf_insert_journal_reco_forms] (@i_bookkey int,@v_filepath varchar(255)) as

DECLARE @i_product_id int,
		@i_metaclass_id int,
		@i_prod_recoform_metafieldid int,
		@i_c_bookkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_prodfetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40)

BEGIN

	DECLARE c_ecf_journal_prods INSENSITIVE CURSOR
	FOR

	Select p.productid, 
	dbo.qweb_ecf_get_metaclassid('Journals'),
	dbo.qweb_ecf_get_MetaFieldID('JournalLibraryRecommendationForm_File'),
	p.code
	from product p
	where p.code = CAST(@i_bookkey as varchar)
	and p.code in (Select bookkey from UAP..bookdetail where publishtowebind = 1)


	FOR READ ONLY
			
	OPEN c_ecf_journal_prods

	FETCH NEXT FROM c_ecf_journal_prods
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prod_recoform_metafieldid,
			@i_c_bookkey

	select  @i_prodfetchstatus  = @@FETCH_STATUS

	 while (@i_prodfetchstatus >-1 )
		begin
		IF (@i_prodfetchstatus <>-2) 
		begin

		
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_prod_recoform_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT      --@Retval	INT	OUT


	
		Select @d_datetime = getdate()

		--  QSI  -- '\\mcdonald\mediachase\UAP_images\'
		--  UNP  -- '\\unp-muskie\Images\'  
--\\mcdonald\mediachase\UAP_images\e://Mcdonald/mediachase/UAP_IMAGES/Library%20Recommendation%20Forms/Library_recommendation_SAIL.pdf


		Select @v_file = @v_filepath + Substring(pathname,4,len(pathname)) 
		from UAP..filelocation 
		where printingkey = 1 and filetypecode = 13 and bookkey = @i_c_bookkey
print @v_file
print @v_filepath


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

		
		
			update ProductEx_Journals
			set JournalLibraryRecommendationForm_File = @i_current_metakey
			where objectid = @i_product_id


		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file

		

		end

FETCH NEXT FROM c_ecf_journal_prods
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prod_recoform_metafieldid,
			@i_c_bookkey

	        select  @i_prodfetchstatus  = @@FETCH_STATUS
		end

		close c_ecf_journal_prods
		deallocate c_ecf_journal_prods

		-- get rid of missing image rows in metakey and metafilevalue
		-- was causing error
	
		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update ProductEx_Journals
		set JournalLibraryRecommendationForm_File = Null
		where JournalLibraryRecommendationForm_File in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes




END

GO
Grant execute on dbo.qweb_ecf_insert_journal_reco_forms to Public
GO