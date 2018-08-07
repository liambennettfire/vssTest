/****** Object:  StoredProcedure [dbo].[qpl_sync_configitems2tables]    Script Date: 01/06/2015 10:23:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_sync_configitems2tables]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_sync_configitems2tables]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[qpl_sync_configitems2tables] (@i_tablename VARCHAR(100), @i_projectkey int,@i_taqversionkey int,  @v_userid varchar(50))  
AS
BEGIN
	DECLARE 
	@v_update nvarchar(1000),
	@v_insert nvarchar(1000),
	@i_specitemcategory int,
	@i_specitemcode int,
	@v_tablename nvarchar(50),
	@v_column nvarchar(255),
	@v_datatype varchar(255),
	@v_specitemtype varchar(255),
	@i_itemtype int,
	@i_usageclass int,
	@v_tablenamekeycode1 nvarchar(255),
	@v_tablenamekeycode2 nvarchar(255),
	@v_tablenamekeycode3 nvarchar(255),
	@v_tablenamekeycolumnconcat nvarchar(255),	
	@i_mappingkey int,
	@i_multicomptypekey int,
	@i_exceptioncode int,
	@i_parentspecitemcategory int,
	@i_parenttaqversionpecategorykey int,
	@i_firstprintonly int,
	@i_defaultuomvalue int,
	@i_key1 int,
	@i_key2 int,
	@i_key3 int,
	@i_qtyvalue int,
	@i_qtyvalue2 int,	
	@i_projectformatkey int,
	@v_targetvalue nvarchar(1000),
	@i_targetdecimalvalue float,
    @i_targetdetailvalue int,
	@i_targetqtyvalue int,
	@v_targetqtyvalue nvarchar(50),
	@v_targetdetailvalue nvarchar(255),
	@i_syncfromspecsind int,
	@i_synctospecsind int,
	@i_syncspecs int,
	@i_bookkey int,
	@i_printingkey int,
	@i_qsiconfigspecsynckey int,
	@v_count nvarchar(1000),
	@i_count int,
	@i_selectedversionkey int,
	@v_type nvarchar(2),
	@i_taqversionspecategorykey int,
	--@i_taqversionkey int,
	@i_versionformatkey int,
	--@i_projectkey int,
	@i_NumberRecords int,
	@i_RowCount int,
	@v_key1 nvarchar(255),
	@v_key2 nvarchar(255),
	@v_params nvarchar(1000),
	@v_debug nvarchar(2),
	@v_errordesc nvarchar(1000),
	@i_targetlength int,
	@o_error_code int,
	@o_error_desc varchar(2000),
	@v_printing_projectrole int,
	@v_printing_title_titlerole int ,	
	@i_targetmediaformatvalue int,
	@v_targetmediaformatvalue nvarchar (255),
	@v_min_printing_key INT,
	@v_qtydesc VARCHAR(40),
	@v_count_booklock int
	
	IF COALESCE(@i_tablename, '') = '' BEGIN
		RETURN
	END
	
	DECLARE @syncspeclist TABLE (rowid int identity (1,1),qsiconfigspecsynckey int)
	
	set @v_debug = 'N'
	SET @i_NumberRecords=0
	SET @v_min_printing_key = -1
	
    SET @v_min_printing_key = dbo.qproject_get_minprintingkey(@i_projectkey) 
  
    IF @v_min_printing_key IS NULL OR @v_min_printing_key < 0 BEGIN
		RETURN
    END	
	
	--get the selected version - compare it to the version key being passed in, if they don't match, don't continue, it is just a version that shouldn't update actual spec tables
	-- if there is not passed version key, then use the selectedversion for when run standalone
	select @i_selectedversionkey = [dbo].[qpl_get_selected_version] (@i_projectkey)
	
	IF coalesce(@i_taqversionkey,@i_selectedversionkey) = @i_selectedversionkey
	BEGIN	
		set nocount on
		--get the itemtype and usagecalss for the projectkey and use to determine if any specs to copy
		select @i_itemtype = searchitemcode from coreprojectinfo where projectkey = @i_projectkey
		select @i_usageclass = usageclasscode from coreprojectinfo where projectkey = @i_projectkey
				
		select @i_syncspecs = COUNT(*) from qsiconfigspecsync where COALESCE(specitemcode, 0)= 0 and COALESCE(specitemcategory, 0) = 0 
		and usageclass = @i_usageclass and itemtype = @i_itemtype and syncfromspecsind=1 and activeind=1 and LTRIM(RTRIM(LOWER(tablename)))= LTRIM(RTRIM(LOWER(@i_tablename))) 
		and COALESCE(specitemcategory, 0) = 0 and COALESCE(specitemcode, 0) = 0
					
		--if theres a spec config then continue 
		IF coalesce(@i_syncspecs,0)>0
		BEGIN --2
							
			--get the bookkey and printingkey for the printing projectkey, there may be other keys we'll need but these are for sure
			select @v_printing_projectrole = datacode from gentables where tableid = 604 and qsicode = 3
			select @v_printing_title_titlerole = datacode from gentables where tableid = 605 and qsicode = 7
			
			select @i_bookkey = tpt.bookkey, @i_printingkey  = tpt.printingkey 
			from taqprojecttitle tpt where tpt.taqprojectkey = @i_projectkey and projectrolecode = @v_printing_projectrole and titlerolecode = @v_printing_title_titlerole -- from the printing project, this may need to change
			
			--get the taqprojectformatkey
			select @i_versionformatkey =taqprojectformatkey from taqversionformat where taqprojectkey = @i_projectkey and taqversionkey=@i_selectedversionkey
			
			--for now hardcoding these keys to bookkey, printingkey
			select @i_key1=@i_bookkey
			select @i_key2=@i_printingkey
	
			--cast keys to varchar for dynmaic sql
			select @v_key1 = CAST(@i_key1 as varchar(50))
			select @v_key2 = CAST(@i_key2 as varchar(50))
			
			--set userid if empty
			select @v_userid = coalesce(@v_userid,'QSISYNC')
			--there may be multiple rows for a category,code, item type and class, so loop through them to be safe			
			
			--lock the table so the trigger doesn't fire while updating - the trigger will check the booklock table to see if the book is locked
			select @v_count_booklock = 0
			select @v_count_booklock = COUNT(*) from booklock where bookkey = @i_key1 and printingkey = @i_key2
			if @v_count_booklock = 0 begin
				insert into booklock (bookkey,printingkey,userid,locktimestamp,locktypecode,lastuserid,lastmaintdate,systemind)
				select @i_key1,@i_key2,'FBTSYNC',GETDATE(),1,@v_userid,GETDATE(),'TMMW'
			end
									
			INSERT INTO @syncspeclist (qsiconfigspecsynckey)
			select qsiconfigspecsynckey from qsiconfigspecsync where COALESCE(specitemcode, 0)= 0 and COALESCE(specitemcategory, 0) = 0 
			and synctospecsind=1 and activeind=1 and tablename=@i_tablename
							
			SET @i_NumberRecords = @@ROWCOUNT
			SET @i_RowCount = 1
			
			WHILE @i_rowcount <= @i_numberrecords
			BEGIN--3
			 SELECT @i_qsiconfigspecsynckey = qsiconfigspecsynckey
			 FROM @syncspeclist
			 WHERE rowid = @i_rowcount			
			
				--get the sync definition
				select 	
				@i_syncfromspecsind = q.syncfromspecsind,
				@i_synctospecsind = q.synctospecsind,
				@i_specitemcategory = q.specitemcategory,
				@i_specitemcode = q.specitemcode,
				@v_tablename = q.tablename,
				@v_column = q.columnname,
				@v_datatype =q.datatype,
				@v_specitemtype = q.specitemtype,
				@i_itemtype = q.itemtype,
				@i_usageclass = q.usageclass,
				@v_tablenamekeycode1 = q.keycolumn1,
				@v_tablenamekeycode2 = q.keycolumn2,
				@v_tablenamekeycode3 = q.keycolumn3,
				@v_tablenamekeycolumnconcat = q.keycolumnconcat,
				@i_mappingkey = q.mappingkey,
				@i_multicomptypekey = q.multicomptypekey,
				@i_exceptioncode = q.exceptioncode,
				@i_parentspecitemcategory = q.parentspecitemcategory,
				@i_firstprintonly = q.firstprintonly,
				@i_defaultuomvalue = q.defaultuomvalue
				from qsiconfigspecsync q 
				where q.qsiconfigspecsynckey = @i_qsiconfigspecsynckey 
								
				/*now determine if there are any special circumstances for the row: 
				NOTE: BAL 12/11/14:  Printing only for HNA.  This comment below will potentially need to be implemented for other clients, refer to the logic in qpl_sync_tables2specitems to see how to handle multiple row for the same component type
				-multicomptypekey: this is where the same spec category is used for multiple compkeys, for instance the spec category = 'cover' is used for cover, secondcover, and coverinsert old comp types
				-exceptioncode: these are spec items that need special attention, so far:
				1 = colors.  there are multiple color tables like bindcolor, covercolor, jackcolor, etc that can have multiple rows so they need to be handled differently
				2 = materialspecs. can have multiple papers for text and insert
				3 = inserts. can have multiple inserts
				4 = case specs.  multiple tables involved here
				*/					
				
				select @i_qtyvalue = null
								
				--get the table target values and compare to  the new values
				---init the target values
				set @i_targetdetailvalue = null				
				set @v_targetvalue = null
				set @i_targetdecimalvalue = null
												
				--GET THE TARGET VALUE
				IF coalesce(@v_specitemtype,'') <>'' and coalesce(@i_exceptioncode,0) not in (2,3)  -- papers and inserts
				BEGIN --9						
						IF coalesce(@v_datatype,'') <> 'decimal' 
						BEGIN --10
							--get the target value based on the number of key columns, then convert the target value to whatever type you need
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) <>0
								select @v_update = N'Select @v_targetvalue = <@v_column> from <tablename> where <@v_tablenamekeycode1> = @i_key1 and <@v_tablenamekeycode2> = @i_key2 and <@v_tablenamekeycode3> = @i_key3'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) =0
								select @v_update = N'Select @v_targetvalue = <@v_column> from <tablename> where <@v_tablenamekeycode1> = @i_key1 and <@v_tablenamekeycode2> = @i_key2'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) = 0 and coalesce(@i_key3,0) =0
								select @v_update = N'Select @v_targetvalue = <@v_column> from <tablename> where <@v_tablenamekeycode1> = @i_key1'
						END --10

						IF coalesce(@v_datatype,'') = 'decimal' 
						BEGIN --11
							--get the target value based on the number of key columns, then convert the target value to whatever type you need
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) <>0
								select @v_update = N'Select @i_targetdecimalvalue = <@v_column> from <tablename> where <@v_tablenamekeycode1> = @i_key1 and <@v_tablenamekeycode2> = @i_key2 and <@v_tablenamekeycode3> = @i_key3'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) =0
								select @v_update = N'Select @i_targetdecimalvalue = <@v_column> from <tablename> where <@v_tablenamekeycode1> = @i_key1 and <@v_tablenamekeycode2> = @i_key2'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) = 0 and coalesce(@i_key3,0) =0
								select @v_update = N'Select @i_targetdecimalvalue = <@v_column> from <tablename> where @v_tablenamekeycode1> = @i_key1'
						END --11
							
						    IF @v_debug='Y'
							begin	
								 print '@v_update'
								 print  @v_update	
							end	
						--for some reason, parameters not working for table and column name
						select @v_update = replace(@v_update,'<tablename>',@v_tablename)
						select @v_update = replace(@v_update,'<@v_column>',@v_column)

						IF coalesce(@i_key1,0) <> 0
							select @v_update = replace(@v_update,'<@v_tablenamekeycode1>',@v_tablenamekeycode1)
						IF coalesce(@i_key2,0) <> 0
							select @v_update = replace(@v_update,'<@v_tablenamekeycode2>',@v_tablenamekeycode2)
						IF coalesce(@i_key3,0) <> 0
							select @v_update = replace(@v_update,'<@v_tablenamekeycode3>',@v_tablenamekeycode3)
						
										
						--if values, then execute dynamic sql
						IF coalesce(@v_update,'')<>''
						BEGIN --12
							select @i_key3 = coalesce(@i_key3,null)
							
							select @v_params = 
									N'@i_key1 int,
									@i_key2 int,
									@i_key3 int, 
									@v_targetvalue nvarchar(255) OUTPUT, 
									@i_targetdecimalvalue FLOAT OUTPUT'

							exec sp_executesql @v_update, @v_params, 
									@i_key1, 
									@i_key2, 
									@i_key3, 
									@v_targetvalue = @v_targetvalue OUTPUT, 
									@i_targetdecimalvalue = @i_targetdecimalvalue OUTPUT
								
							IF @v_debug='Y'
							begin	
										print @v_params
										print '@v_targetvalue'
										print @v_targetvalue
										print '@i_targetdecimalvalue'
										print @i_targetdecimalvalue
										print '@v_specitemtype'
										print @v_specitemtype
							end
						END--12
												
					--TAQVERSIONFORMAT
					IF coalesce(@v_specitemtype,'') = 'VF'  and @i_printingkey = @v_min_printing_key
					BEGIN -- 13
							select @i_targetqtyvalue =0
							select @i_qtyvalue =0
																						
							IF @v_column='mediatypecode'
							BEGIN	
								select @i_targetqtyvalue = mediatypecode from bookdetail where bookkey=@i_bookkey
								select @i_qtyvalue = mediatypecode from taqversionformat where taqprojectformatkey=@i_versionformatkey										
							
							print '@i_bookkey'
							print @i_bookkey
							print '@i_versionformatkey'
							print @i_versionformatkey
							print '@i_qtyvalue'
							print @i_qtyvalue
							print '@i_targetqtyvalue'
							print @i_targetqtyvalue
							
							select * from booklock where bookkey=@i_bookkey
					
						   IF 	coalesce(@i_qtyvalue,0) <> coalesce(@i_targetqtyvalue,0)
								begin	
									update bookdetail
									set mediatypecode = @i_qtyvalue
									where bookkey = @i_bookkey
									
									SET  @v_qtydesc = ltrim(rtrim(dbo.get_gentables_desc(312,convert(int,@i_qtyvalue),'long'))) 
									
									EXEC dbo.qtitle_update_titlehistory @v_tablename,@v_column, @i_key1, @i_key2, 0, @v_qtydesc,
									'update', @v_userid, NULL, NULL, @o_error_code OUTPUT, @o_error_desc OUTPUT 
									
									print 'titlehistory written for media'
								end 	
									
							END	

							IF @v_column='mediatypesubcode' --mediasubcode 
							BEGIN
								select @i_targetqtyvalue = mediatypesubcode from bookdetail where bookkey=@i_bookkey
								select @i_qtyvalue = mediatypecode from taqversionformat where taqprojectformatkey=@i_versionformatkey	
								select @i_qtyvalue2 = mediatypesubcode from taqversionformat where taqprojectformatkey=@i_versionformatkey
					
								IF 	coalesce(@i_qtyvalue2,0) <> coalesce(@i_targetqtyvalue,0)
								begin
									update bookdetail
									set mediatypesubcode = @i_qtyvalue2
									where bookkey = @i_bookkey
									
									SET  @v_qtydesc = ltrim(rtrim(dbo.get_subgentables_desc(312, @i_qtyvalue, @i_qtyvalue2, 'long')))
									
									print @v_qtydesc
									
									EXEC dbo.qtitle_update_titlehistory @v_tablename,@v_column, @i_key1, @i_key2, 0, @v_qtydesc,
									'update', @v_userid, NULL, NULL, @o_error_code OUTPUT, @o_error_desc OUTPUT 
									
									print 'titlehistory written for format'
								end	
							END			
					END	-- 13														
				END--9				
										    
				SET @i_RowCount = @i_RowCount + 1
		
			END--3
		END --2
												
		delete from booklock where bookkey=@i_key1 and printingkey=@i_key2 and userid='FBTSYNC'
		
	set nocount off	
	END	--1	
END --0

GO

GRANT EXEC ON [qpl_sync_configitems2tables] to PUBLIC
go
	