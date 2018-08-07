/****** Object:  StoredProcedure [dbo].[qpl_sync_specitems2tables]    Script Date: 01/06/2015 10:23:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_sync_specitems2tables]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_sync_specitems2tables]
GO


/****** Object:  StoredProcedure [dbo].[qpl_sync_specitems2tables]    Script Date: 01/06/2015 10:23:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************
**  Name: qpl_sync_specitems2tables
**  Desc: 
**  Auth: 
**  Date: 
*******************************************************************************
**  Change History
*******************************************************************************
**  Date:        Author:     Description:
*   --------     --------    -------------------------------------------
**  07/08/2016   UK          Case 38816 - Task 002
*******************************************************************************/

CREATE procedure [dbo].[qpl_sync_specitems2tables] (@i_taqversionspecitemkey int, @i_projectkey int,@i_taqversionkey int,  @v_userid varchar(50))  
AS
BEGIN
	DECLARE 
	@v_update nvarchar(1000),
	@v_insert nvarchar(1000),
	@v_select nvarchar(1000),
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
	@v_descvalue nvarchar(255),
	@v_desc2value nvarchar(255),
	@i_detailvalue int,
	@i_detail2value int,
	@i_uomvalue int,
	@i_decimalvalue decimal(15,4),
	@i_qtydecimalind int,
	@i_projectformatkey int,
	@v_targetvalue nvarchar(1000),
	@i_targetqtyvalue int,
	@v_targetdescvalue nvarchar(1000), 
	@v_targetdesc2value nvarchar (1000),
	@i_targetdetailvalue int,
	@i_targetdetail2value int,
	@i_targetuomvalue int,
	@i_targetdecimalvalue float,
	@v_targetqtyvalue nvarchar(50),
	@v_targetdetailvalue nvarchar(255),
	@v_targetdetail2value nvarchar(255),
	@v_targetuomvalue nvarchar (255),
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
	@v_key3 nvarchar(255),
	@v_params nvarchar(1000),
	@v_debug nvarchar(2),
	@v_errordesc nvarchar(1000),
	@i_targetlength int,
	@o_error_code int,
	@o_error_desc varchar(2000),
	@v_printing_projectrole int,
	@v_printing_title_titlerole int,
	@v_count_booklock int 
	
/********************************************************************************************************
**    Change History
**********************************************************************************************************
**    Date:       Author:      Case #:   Description:
**    --------    --------     -------   --------------------------------------
**   03/28/2016   Kusum        31327     Barcode is written out to title history every time a spec item is updated
**********************************************************************************************************/
	
	DECLARE @syncspeclist TABLE (rowid int identity (1,1),qsiconfigspecsynckey int)
	
	set @v_debug = 'N'
	SET @i_NumberRecords=0
	
	--BAL 12/11/14:  Doing for Printing only for HNA.  This will potentially need to be enhanced for other implementations
	
	--get the taqversionspeccategory and the taqversionkey for the updated specitem
	select @i_taqversionspecategorykey = taqversionspecategorykey, @i_specitemcode = itemcode 
	from taqversionspecitems where taqversionspecitemkey = @i_taqversionspecitemkey
	
	IF coalesce(@i_taqversionspecitemkey,0)<>0
		select @i_taqversionkey = taqversionkey, @i_projectkey = taqprojectkey, @i_specitemcategory = itemcategorycode 
		from taqversionspeccategory where taqversionspecategorykey =@i_taqversionspecategorykey
	
	--get the selected version - compare it to the version key being passed in, if they don't match, don't continue, it is just a version that shouldn't update actual spec tables
	-- if there is not passed version key, then use the selectedversion for when run standalone
	select @i_selectedversionkey = [dbo].[qpl_get_selected_version] (@i_projectkey)
	
	IF coalesce(@i_taqversionkey,@i_selectedversionkey) = @i_selectedversionkey
	BEGIN	
		set nocount on
		--get the itemtype and usagecalss for the projectkey and use to determine if any specs to copy
		select @i_itemtype = searchitemcode from coreprojectinfo where projectkey = @i_projectkey
		select @i_usageclass = usageclasscode from coreprojectinfo where projectkey = @i_projectkey
		
		select @i_syncspecs = COUNT(*) from qsiconfigspecsync where specitemcode= @i_specitemcode and specitemcategory = @i_specitemcategory 
		and usageclass = @i_usageclass and itemtype = @i_itemtype and syncfromspecsind=1 and activeind=1 
		--and tablename in ('printing','bindingspecs')
		
	
	
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
			select qsiconfigspecsynckey from qsiconfigspecsync where specitemcode= @i_specitemcode and specitemcategory = @i_specitemcategory 
			and synctospecsind=1 and activeind=1 
			--and tablename in ('printing','bindingspecs')
			
							
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
				--init source values
				select @i_qtyvalue = null,
				@v_descvalue = null,
				@v_desc2value = null,
				@i_detailvalue = null,
				@i_detail2value = null,
				@i_uomvalue = null,
				@i_decimalvalue = null
				
				--get the taqversionspecitem values 
				select @i_qtyvalue = tvsi.quantity,
				@v_descvalue = tvsi.description,
				@v_desc2value = tvsi.description2,
				@i_detailvalue = tvsi.itemdetailcode,
				@i_detail2value = tvsi.itemdetailsubcode,
				@i_uomvalue = tvsi.unitofmeasurecode,
				@i_decimalvalue = coalesce(tvsi.decimalvalue,0)
				from taqversionspecitems tvsi where taqversionspecitemkey = @i_taqversionspecitemkey
				
				--get the table target values and compare to  the new values
				---init the target values
				set @i_targetdetailvalue = null
				set @i_targetdetail2value = null
				set @i_targetqtyvalue = null
				set @v_targetdescvalue = null
				set @v_targetdesc2value = null
				set @i_targetdecimalvalue = null
				set @i_targetuomvalue = null
				set @v_targetvalue = null
				
        IF @v_tablenamekeycode3 IS NOT NULL
        BEGIN
          PRINT '@v_tablenamekeycode3=' + convert(varchar, @v_tablenamekeycode3)
	
          SET @v_select = N'SELECT TOP 1 @v_keyvalue=' + @v_tablenamekeycode3 + ' FROM ' + @v_tablename + ' WHERE ' + @v_tablenamekeycode1 + '=@i_key1 AND ' + @v_tablenamekeycode2 + '=@i_key2'
          SET @v_params = N'@i_key1 INT, @i_key2 INT, @v_keyvalue INT OUTPUT'

          PRINT @v_select

          EXEC sp_executesql @v_select, @v_params, @i_key1, @i_key2, @v_keyvalue = @i_key3 OUTPUT			
				
          PRINT 'retrieved key3 value:'
          PRINT @i_key3

          IF @i_key3 IS NULL
          BEGIN
            EXEC get_next_key 'QSIADMIN', @i_key3 OUTPUT  

            PRINT 'generated key3 value:'
            PRINT @i_key3  
          END
        END
										
				--GET THE TARGET VALUE
				IF coalesce(@v_specitemtype,'') <>'' and coalesce(@i_exceptioncode,0) not in (2,3)  -- papers and inserts
				BEGIN --9						
						IF coalesce(@v_datatype,'') <> 'decimal' 
						BEGIN --10
							--get the target value based on the number of key columns, then convert the target value to whatever type you need
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) <>0
								select @v_update = N'SELECT @v_targetvalue=' + @v_column + ' FROM ' + @v_tablename + ' WHERE ' + @v_tablenamekeycode1 + '=@i_key1 AND ' + @v_tablenamekeycode2 + '=@i_key2 AND ' + @v_tablenamekeycode3 + '=@i_key3'
							ELSE IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) =0
								select @v_update = N'SELECT @v_targetvalue=' + @v_column + ' FROM ' + @v_tablename + ' WHERE ' + @v_tablenamekeycode1 + '=@i_key1 AND ' + @v_tablenamekeycode2 + '=@i_key2'
							ELSE IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) = 0 and coalesce(@i_key3,0) =0
								select @v_update = N'SELECT @v_targetvalue=' + @v_column + ' FROM ' + @v_tablename + ' WHERE ' + @v_tablenamekeycode1 + '=@i_key1'
						END --10

						IF coalesce(@v_datatype,'') = 'decimal' 
						BEGIN --11
							--get the target value based on the number of key columns, then convert the target value to whatever type you need
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) <>0
								select @v_update = N'SELECT @i_targetdecimalvalue=' + @v_column + ' FROM ' + @v_tablename + ' WHERE ' + @v_tablenamekeycode1 + '=@i_key1 AND ' + @v_tablenamekeycode2 + '=@i_key2 AND ' + @v_tablenamekeycode3 + '=@i_key3'
							ELSE IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) =0
								select @v_update = N'SELECT @i_targetdecimalvalue=' + @v_column + ' FROM ' + @v_tablename + ' WHERE ' + @v_tablenamekeycode1 + '=@i_key1 AND ' + @v_tablenamekeycode2 + '=@i_key2'
							ELSE IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) = 0 and coalesce(@i_key3,0) =0
								select @v_update = N'SELECT @i_targetdecimalvalue=' + @v_column + ' FROM ' + @v_tablename + ' WHERE ' + @v_tablenamekeycode1 + '=@i_key1'
						END --11
							
						  IF @v_debug='Y'
							begin	
								 print '@v_update'
								 print  @v_update	
							end	
										
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
						--now take the generated values, evaluate, transform, and set
						IF coalesce(@v_specitemtype,'') in ('Q','CK') and coalesce(@v_datatype,'') = 'int'  -- Quantity and component vendor
						BEGIN--13
							select @v_targetqtyvalue = @v_targetvalue
							
							IF isnumeric(@v_targetqtyvalue)=1 
								select @i_targetqtyvalue = CAST(@v_targetqtyvalue as INT)
								
							ELSE select @v_errordesc = 'target qty value is not numeric'
							
							IF @v_debug='Y'
							begin
								 print '@i_targetqtyvalue'
								 print @i_targetqtyvalue
								 print '@v_targetdetailvalue'
								 print @v_targetdetailvalue
							end
						END --13
						
						IF coalesce(@v_specitemtype,'') ='DT' and coalesce(@v_datatype,'') = 'int'  -- detailcode
						BEGIN --14
								select @v_targetdetailvalue = @v_targetvalue
								--check mappings and transform
								IF coalesce(@i_mappingkey,0)<>0
									select @i_targetdetailvalue = m.specitemvalue from qsiconfigspecsyncmapping m where @i_mappingkey = m.mappingkey and @v_targetdetailvalue = m.tablevalue
								ELSE IF isnumeric(@v_targetdetailvalue)=1
									select @i_targetdetailvalue = CAST(@v_targetdetailvalue as INT)

								ELSE select @v_errordesc = 'target detail value is not numeric or no mapping found'
								IF @v_debug='Y'
								begin
								print '@i_targetdetailvalue' 	
								print @i_targetdetailvalue
								end 
						END	--14
						
						IF coalesce(@v_specitemtype,'') ='T2' and coalesce(@v_datatype,'') = 'int'  -- detailcode
						BEGIN --14A
								select @v_targetdetail2value = @v_targetvalue
								--check mappings and transform
								IF coalesce(@i_mappingkey,0)<>0
									select @i_targetdetail2value = m.specitemvalue from qsiconfigspecsyncmapping m where @i_mappingkey = m.mappingkey and @v_targetdetail2value = m.tablevalue
								ELSE IF isnumeric(@v_targetdetailvalue)=1
									select @i_targetdetail2value = CAST(@v_targetdetail2value as INT)

								ELSE select @v_errordesc = 'target detail value is not numeric or no mapping found'
								IF @v_debug='Y'
								begin
								print '@i_targetdetail2value' 	
								print @i_targetdetail2value
								end 
						END	--14A

						IF coalesce(@v_specitemtype,'') ='U' and coalesce(@v_datatype,'') = 'int'  -- unit of measure
						BEGIN --15
							select @v_targetuomvalue = @v_targetvalue
								
								IF coalesce(@i_mappingkey,0)<>0
									select @i_targetuomvalue = m.specitemvalue from qsiconfigspecsyncmapping m where @i_mappingkey = m.mappingkey and @v_targetuomvalue = m.tablevalue
							
								IF isnumeric(@v_targetuomvalue)=1 
									select @i_targetuomvalue = CAST(@v_targetuomvalue as INT)
								
								ELSE select @v_errordesc = 'target uom value is not numeric'
								IF @v_debug='Y'
								begin
									print '@i_targetuomvalue'		
									print @i_targetuomvalue
								end
						END --15
						
						IF coalesce(@v_specitemtype,'')  in ('D','CD') and coalesce(@v_datatype,'') = 'varchar'  -- description and component description
						BEGIN --16
					
								IF coalesce(@i_exceptioncode,0) = 1 and coalesce(@v_specitemtype,'') <>'CD'
								begin
										--print 'qpl_sync_get_concatcolors_fn start'
										select @v_targetdescvalue = [dbo].qpl_sync_get_concatcolors_fn (@i_bookkey, @i_printingkey, @v_tablename, ',')
										--print 'qpl_sync_get_concatcolors_fn end'
								end
								IF coalesce(@i_exceptioncode,0) <>1 or coalesce(@v_specitemtype,'') = 'CD'
								begin			
									select @v_targetdescvalue = @v_targetvalue
								end
								IF @v_debug='Y'
								begin
									print '@v_targetdescvalue'
									print @v_targetdescvalue
								end
						END --16

						IF coalesce(@v_specitemtype,'') ='D2' and coalesce(@v_datatype,'') = 'varchar'  -- description2
						BEGIN --17
								IF coalesce(@i_exceptioncode,0) = 1
								begin
									  select @v_targetdesc2value =[dbo].qpl_sync_get_concatcolors_fn (@i_bookkey, @i_printingkey, @v_tablename, ',')
								end
								IF coalesce(@i_exceptioncode,0) <> 1
									select @v_targetdesc2value = @v_targetvalue
								IF @v_debug='Y'
							 	print @v_targetdesc2value
						END --17
				
						--HAVE THE target VALUES, NOW INSERT OR UPDATE
									
						--update for each type
					    IF coalesce(@i_decimalvalue,-1) <> -1
						begin ---20
						--compare target to target value, if different, update
							IF coalesce(@i_decimalvalue,0) <> coalesce(@i_targetdecimalvalue,0) and coalesce(@v_specitemtype,'')='Q' and coalesce(@v_datatype,'')='decimal'
							begin
							--check to see if decimal and has a value, if yes then set the ind=1 
							select @i_qtydecimalind = 1
							--ELSE select @i_qtydecimalind = 0	
																
							exec dbo.qpl_sync_specitems2tables_update @v_tablename,@v_tablenamekeycode1,@v_tablenamekeycode2,@v_tablenamekeycode3,@i_key1,@i_key2,@i_key3,@v_column,null,@i_decimalvalue,null,null,null,null,null,@v_specitemtype,@i_qtydecimalind,@v_userid
							
							end							
							IF @v_debug='Y'
							print 'decimal update complete'
						end	 --20

						IF coalesce(@i_qtyvalue,-1) <> -1 and coalesce(@v_specitemtype,'')='Q'
						begin --21
						--compare target to target value, if different, update
							IF coalesce(@i_qtyvalue,0) <> coalesce(@i_targetqtyvalue,0)
								exec dbo.qpl_sync_specitems2tables_update @v_tablename,@v_tablenamekeycode1,@v_tablenamekeycode2,@v_tablenamekeycode3,@i_key1,@i_key2,@i_key3,@v_column,@i_qtyvalue,null,null,null,null,null,null,@v_specitemtype,@i_qtydecimalind,@v_userid
															
						    IF @v_debug='Y'
								print 'qty update complete'
						end	--21

						IF coalesce(@i_detailvalue,-1) <> -1 and coalesce(@v_specitemtype,'')='DT'
						begin --22
						--compare target to target value, if different, update
							IF coalesce(@i_detailvalue,0) <> coalesce(@i_targetdetailvalue,0)
								exec dbo.qpl_sync_specitems2tables_update @v_tablename,@v_tablenamekeycode1,@v_tablenamekeycode2,@v_tablenamekeycode3,@i_key1,@i_key2,@i_key3,@v_column,null,null,@i_detailvalue,null,null,null,null,@v_specitemtype,@i_qtydecimalind,@v_userid	
									
							IF @v_debug='Y'
								print 'detailcode update complete'
						end	 --22
						
						IF coalesce(@i_detail2value,-1) <> -1 and coalesce(@v_specitemtype,'')='T2'
						begin --22
						--compare target to target value, if different, update
							IF coalesce(@i_detail2value,0) <> coalesce(@i_targetdetail2value,0)
								exec dbo.qpl_sync_specitems2tables_update @v_tablename,@v_tablenamekeycode1,@v_tablenamekeycode2,@v_tablenamekeycode3,@i_key1,@i_key2,@i_key3,@v_column,null,null,null,@i_detail2value,null,null,null,@v_specitemtype,@i_qtydecimalind,@v_userid	
									
							IF @v_debug='Y'
								print 'detailcode update complete'
						end	
							
						IF coalesce(@i_uomvalue,-1) = -1 and coalesce(@v_specitemtype,'')='U'
						--set to default value
							select @i_uomvalue = coalesce(@i_defaultuomvalue,-1)
														
						IF coalesce(@i_targetuomvalue,-1) <> coalesce(@i_uomvalue,-1) and coalesce(@v_specitemtype,'')='U'
						begin --23
						--compare target to target value, if different, update
							IF 	coalesce(@i_uomvalue,0) <> coalesce(@i_targetuomvalue,0)
								exec dbo.qpl_sync_specitems2tables_update @v_tablename,@v_tablenamekeycode1,@v_tablenamekeycode2,@v_tablenamekeycode3,@i_key1,@i_key2,@i_key3,@v_column,null,null,null,null,null,null,@i_uomvalue,@v_specitemtype,@i_qtydecimalind,@v_userid		
									
							IF @v_debug='Y'
								print 'uom update complete'
						end --23		

						IF coalesce(@v_desc2value,'zemptyz') <> 'zemptyz' and coalesce(@v_specitemtype,'')='D2'
						begin --24
						-- trim new source value down to size so can compare to existing table value, determine the target column length
						select @i_targetlength = character_maximum_length from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @v_tablename and COLUMN_NAME = @v_column
			
						--trim the value to fit	the target
						select @v_desc2value = SUBSTRING(@v_desc2value,1,@i_targetlength)
										
						--compare target to target value, if different, update
							IF 	coalesce(@v_desc2value,'') <> coalesce(@v_targetdesc2value,'')
								exec dbo.qpl_sync_specitems2tables_update @v_tablename,@v_tablenamekeycode1,@v_tablenamekeycode2,@v_tablenamekeycode3,@i_key1,@i_key2,@i_key3,@v_column,null,null,null,null,null,@v_desc2value,null,@v_specitemtype,@i_qtydecimalind,@v_userid			
											
							IF @v_debug='Z'	
							begin
								print 'desc2target'
								print @v_targetdesc2value
								print 'desc2'
								print @v_desc2value
								print 'desc2 update complete'
							end	
						end	--24					
						
						-- UK Case 38816 - Task 002 - removed the change for preventing NULL to be updated for Description 							
						IF coalesce(@v_specitemtype,'')='D'
						begin --25
						-- trim new source value down to size so can compare to existing table value, determine the target column length
						select @i_targetlength = character_maximum_length from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = @v_tablename and COLUMN_NAME = @v_column
			
						--trim the value to fit	the target
						select @v_descvalue = SUBSTRING(@v_descvalue,1,@i_targetlength)	
						--compare target to target value, if different, update
							IF 	coalesce(@v_descvalue,'') <> coalesce(@v_targetdescvalue,'')
								exec dbo.qpl_sync_specitems2tables_update @v_tablename,@v_tablenamekeycode1,@v_tablenamekeycode2,@v_tablenamekeycode3,@i_key1,@i_key2,@i_key3,@v_column,null,null,null,null,@v_descvalue,null,null,@v_specitemtype,@i_qtydecimalind,@v_userid			
										
						    IF @v_debug='Z'
							begin
								print 'desc1target'
								print @v_targetdescvalue	
								print 'desc1'
								print @v_descvalue
								print 'desc update complete'
							end	
						end	--25
						
											
						

						----COMPONENT LEVEL
						--IF coalesce(@v_specitemtype,'') = 'CK' and isnull(@i_targetqtyvalue,1)<>1  --,'CD') --do the component update for vendor
						--	BEGIN--26
						--		select @i_targetqtyvalue = globalcontactkey from globalcontact where conversionkey= @i_targetqtyvalue
						
						--		IF coalesce(@i_vendorkey,0) <> coalesce(@i_targetqtyvalue,'')
									
						--			--need logic here
									
						--	END	--26

						--IF coalesce(@v_specitemtype,'') = 'CD' and coalesce(@v_targetdescvalue,'zemptyz')<>'zemptyz'  --,'CD') --do the component update for  description
						--	BEGIN--26
						--		select @v_targetdescvalue = @v_specitemcategorydesc + '-' + @v_targetdescvalue								
						--		IF coalesce(@v_specitemcategorydesc,'') <> coalesce(@v_targetdescvalue,'')
									
						--			--need logic here
									
						--	END	--26

			
				END--9
				
				--print 'specitemkey'
				--print @i_taqversionspecitemkey
				--print 'numrecs'
				--print @i_NumberRecords
				--print 'synckey'
				--print @i_qsiconfigspecsynckey
				--print 'rowcount'
				--print @i_RowCount	
										    
				SET @i_RowCount = @i_RowCount + 1
		
			END--3
		END --2
		
			
		delete from booklock where bookkey=@i_key1 and printingkey=@i_key2 and userid='FBTSYNC'
		
		--now update the media\format
	    exec [dbo].[qpl_sync_configitems2tables] 'bookdetail',@i_projectkey,@i_taqversionkey,@v_userid				
		
	set nocount off	
	END	--1
END --0

GO

GRANT EXEC ON [qpl_sync_specitems2tables] to PUBLIC
go
