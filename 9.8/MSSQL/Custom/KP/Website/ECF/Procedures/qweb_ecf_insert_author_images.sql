if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qweb_ecf_insert_author_images]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qweb_ecf_insert_author_images]

GO
CREATE  procedure [dbo].[qweb_ecf_insert_author_images] (@i_contactkey int, @v_filepath varchar(255)) as

DECLARE @i_product_id int,
		@i_metaclass_id int,
		@i_prodthumb_metafieldid int,
		@i_c_contactkey int,
		@i_current_metakey int,
		@v_filename varchar(255),
		@d_datetime datetime,
		@i_productfetchstatus int,
		@v_file varchar(255),
		@v_mediatype varchar(40),
		@i_fileexists_flag int,
		@i_maxsubbookkey int

BEGIN

		SELECT @i_prodthumb_metafieldid = dbo.qweb_ecf_get_MetaFieldID('Contributor_MediumToThumbImage')

		delete from metafilevalue where metakey in (Select metakey 
														from metakey m, product p
														where m.metaobjectid = p.productid
														  and p.code = cast(@i_contactkey as varchar)
                              and (m.metafieldid = @i_prodthumb_metafieldid))

		
		delete from metakey where metakey in (Select metakey 
														from metakey m, product p
														where m.metaobjectid = p.productid
														  and p.code = cast(@i_contactkey as varchar)
                              and (m.metafieldid = @i_prodthumb_metafieldid))


  DECLARE c_ecf_products CURSOR fast_forward FOR

	Select productid, 
	dbo.qweb_ecf_get_metaclassid('Contributors'),
	dbo.qweb_ecf_get_MetaFieldID('Contributor_MediumToThumbImage'),
	code
	from product
	where code = cast(@i_contactkey as varchar)
	/*and code in (Select cast(bookkey as varchar) from UNL..bookdetail where publishtowebind = 1)*/
			
	OPEN c_ecf_products

	FETCH NEXT FROM c_ecf_products
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prodthumb_metafieldid,
			@i_c_contactkey

	select  @i_productfetchstatus  = @@FETCH_STATUS

	 while (@i_productfetchstatus >-1 )
		begin
		IF (@i_productfetchstatus <>-2) 
		begin

		/** BEGIN PRODUCT MEDIUM IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_prodthumb_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT         --@Retval	INT	OUT
		

		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @d_datetime = getdate()
		
		--  QSI  -- '\\mcdonald\mediachase\uap_images\AuthorImages\'
		--  GO LIVE -- '\\qsiweb002\AUthorPics\' Update lenght to 24 from 47
		

		Select @v_file = @v_filepath + Substring(commenttext,47,datalength(commenttext)) 
		from cbd..qsicomments 
		where commenttypecode = 9 and commentkey = @i_c_contactkey

--print @v_file
--print cast(@i_product_id as varchar)
--print cast(@i_current_metakey as varchar)

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

	  update productex_contributors
	  set Contributor_LargeToMediumImage = @i_current_metakey
	  where objectid = @i_product_id

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0

		begin
		Select @v_file = @v_filepath + 'author_placeholder.jpg'
		end 

		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file
		/** END PRODUCT MEDIUM IMAGE **************************************************/

		/** BEGIN PRODUCT THUMB IMAGE *********************************************/
		exec [dbo].[mdpsp_sys_GetMetaKey] 
		@i_product_id,      --@MetaObjectId	INT,
		@i_metaclass_id,	--@MetaClassId	INT,
		@i_prodthumb_metafieldid,   --@MetaFieldId	INT,
		@i_current_metakey OUTPUT         --@Retval	INT	OUT
		

		--Select @i_current_metakey = IDENT_CURRENT( 'Metakey' )
		Select @d_datetime = getdate()
		
		--  QSI  -- '\\mcdonald\mediachase\barb_images\AuthorImages\'
		--  UNP  -- '\\unp-muskie\Images\ '  *** NOTE EXTRA SPACE AT END OF PATH AT UNP

		Select @v_file = @v_filepath + Substring(commenttext,47,datalength(commenttext)) 
		from cbd..qsicomments 
		where commenttypecode = 9 and commentkey = @i_c_contactkey

--print @v_file
--print cast(@i_product_id as varchar)
--print cast(@i_current_metakey as varchar)

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

	  update productex_contributors
	  set Contributor_MediumToThumbImage = @i_current_metakey
	  where objectid = @i_product_id

		exec xp_fileexist @v_file, @i_fileexists_flag output

		If @i_fileexists_flag = 0

		begin
		Select @v_file = @v_filepath + 'author_placeholder.jpg'
		end 

		exec  qweb_ecf_UpdateImageData @i_current_metakey, @v_file
		/** END PRODUCT THUMB IMAGE **************************************************/
	end

  FETCH NEXT FROM c_ecf_products
		INTO @i_product_id, 
			@i_metaclass_id,
			@i_prodthumb_metafieldid,
			@i_c_contactkey

  select  @i_productfetchstatus  = @@FETCH_STATUS
  end

  close c_ecf_products
  deallocate c_ecf_products


		Select metakey into #tempmetakeydeletes from metafilevalue where size = 0

		delete from metafilevalue where metakey in (Select metakey from #tempmetakeydeletes)

		delete from metakey where metakey in (Select metakey from #tempmetakeydeletes)
		
		update productex_contributors
		set Contributor_MediumToThumbImage = Null
		where Contributor_MediumToThumbImage in (Select metakey from #tempmetakeydeletes)

		drop table #tempmetakeydeletes


END


GO
Grant execute on dbo.qweb_ecf_insert_author_images to Public
GO