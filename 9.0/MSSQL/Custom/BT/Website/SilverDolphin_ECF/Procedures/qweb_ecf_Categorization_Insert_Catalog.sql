USE [BT_SD_ECF]
GO
/****** Object:  StoredProcedure [dbo].[qweb_ecf_Categorization_Insert_Catalog]    Script Date: 01/27/2010 16:20:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[qweb_ecf_Categorization_Insert_Catalog] (@i_bookkey int) as

DECLARE @i_c_bookkey int,
		@v_catalogkey int,
		@catalog_object_id int,
		@i_titlefetchstatus int,
		@productid int,
		@d_datetime datetime

BEGIN

	DECLARE c_pss_catalog CURSOR fast_forward FOR

	Select distinct bc.bookkey, cs.catalogkey
	from BT..bookcatalog bc, BT..catalogsection cs 
	where bc.sectionkey = cs.sectionkey 
	  and cs.catalogkey in (select c.catalogkey from BT..catalog c
	                         where purposetypecode = 4   -- purposetype = online
	                           and catalogstatuscode = 2) -- status = finalized
		and bookkey in (Select bookkey from BT..bookdetail where publishtowebind = 1)
		and bookkey = @i_bookkey
		and exists (Select * from product where code = cast(@i_bookkey as varchar))
			
	OPEN c_pss_catalog

	FETCH NEXT FROM c_pss_catalog
		INTO @i_c_bookkey, @v_catalogkey

	select  @i_titlefetchstatus  = @@FETCH_STATUS

	 while (@i_titlefetchstatus >-1 )
		begin
		IF (@i_titlefetchstatus <>-2) 
		begin

			Select @productid = productid from product where code = cast(@i_c_bookkey as varchar)
			Select @catalog_object_id = objectid from CategoryEx_Title_Catalogs where PSS_CatalogKey = @v_catalogkey
		
			If not exists (Select * from categorization
							where categoryid = 	@catalog_object_id
							 and objectid = @productid)
			begin

			exec CategorizationInsert

			@catalog_object_id,       --@CategoryId int,
			@productid,				--@ObjectId int,
			1,						--@ObjectTypeId int,
			NULL					--@CategorizationId int = NULL output
			
			end          
		end
		
	FETCH NEXT FROM c_pss_catalog
		INTO @i_c_bookkey, @v_catalogkey
	        select  @i_titlefetchstatus  = @@FETCH_STATUS
		end

close c_pss_catalog
deallocate c_pss_catalog


END





