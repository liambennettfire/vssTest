
/****** Object:  StoredProcedure [dbo].[qpl_sync_multirow2specitems]    Script Date: 12/15/2014 13:20:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_sync_multirow2specitems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_sync_multirow2specitems]
GO


/****** Object:  StoredProcedure [dbo].[qpl_sync_multirow2specitems]    Script Date: 12/15/2014 13:20:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--note: make sure that the materialspecs config runs after the textspecs to ensure the textspec row to link to, illus should be fine as it is running first lower
--select * from qpl_multicomponent
CREATE PROCEDURE [dbo].[qpl_sync_multirow2specitems] 
@i_key1 int, 
@i_key2 int, 
@i_projectkey int, 
@i_selectedversionkey int,
@i_versionformatkey int,
@i_synctospecsind int,
@i_syncfromspecsind int,
@i_syncspecs int,
@i_specitemcode int, 
@i_specitemcategory int, 
@v_specitemcategorydesc varchar(255),
@i_sourcecompkey int,
@i_sourcecompqty int, 
@v_table  varchar(255),
@v_column varchar(255),
@v_tablekeycode1 varchar(255),
@v_tablekeycode2 varchar(255),
@v_tablekeycode3 varchar(255),
@v_tablekeycolumnconcat varchar(255),
@v_specitemtype varchar(255),
@v_datatype varchar(255),
@i_mappingkey int,
@i_qsiconfigspecsynckey int,
@i_itemtype int,
@i_usageclass int,
@i_multicomptypekey int,
@i_exceptioncode int,
@v_userid varchar(50),
@i_firstprintonly int,
@i_defaultuomvalue int

AS
DECLARE
@i_key3 int,
@v_key1 nvarchar(50),
@v_key2 nvarchar (50),
@v_key3 nvarchar (50),
@i_multirowkey int,
@i_numkeys int,
@i_taqversionspeccategorykey int,
@i_hasparentcomponent int,
@i_parenttaqversionpecategorykey int,
@v_papertype nvarchar(50),
@i_parentspecitemcategory int,
@i_qtyvalue int,
@v_descvalue nvarchar(255),
@v_desc2value nvarchar(255),
@i_detailvalue int,
@i_uomvalue int,
@i_decimalvalue float,
@v_sourcevalue nvarchar(255),
@v_sourceqtyvalue nvarchar(50),
@i_sourceqtyvalue int,
@v_sourcedescvalue nvarchar(1000), 
@v_sourcedesc2value nvarchar (1000),
@i_sourcedetailvalue int,
@v_sourcedetailvalue nvarchar(255),
@i_sourceuomvalue int,
@v_sourceuomvalue nvarchar (255),
@i_sourcedecimalvalue float,
@i_taqversionspecategoryrelatedcategorykey int,
@i_taqversionspecitemkey int,
@v_fgind nvarchar (2),
@i_externalcode int,
@i_fgind int,
@i_vendorkey int,
@i_pokey int,
@v_errordesc nvarchar(255),
@v_params nvarchar(255),
@v_select nvarchar(255),
@v_debug nvarchar(10),
@v_update nvarchar(1000),
@v_insert nvarchar(1000),
@i_isinsert int,
@i_count int,
@i_illuscount int,				  
@i_papercount int,
@i_illuspapercount int,
@i_tablelinkingkey int,
@v_specitemcategorydescmulti varchar(255)

BEGIN
	set @v_debug = 'N'

	--create the dynamic sql statement to get the multiple key for cursor based on the number of key columns
	IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 
	begin	
		--set @v_select = 'select @v_tablekeycode3 from @v_tablename where @v_tablekeycode1 = @i_key1 and @v_tablekeycode2 = @i_key2'
		set @v_select = 'select top 1 @i_multirowkey = <@v_tablekeycode3> from <@v_table> where <@v_tablekeycode3> > @i_multirowkey and <@v_tablekeycode1> = @i_key1 
						and <@v_tablekeycode2> = @i_key2 order by <@v_tablekeycode3>'
		set @i_numkeys = 2
	end	
	IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) = 0 and coalesce(@i_key3,0) =0
	begin	
		--set @v_select = 'select @v_tablekeycode2 from @v_tablename where @v_tablekeycode1 = @i_key1'
		set @v_select = 'select top 1 @i_multirowkey =  <@v_tablekeycode2> from <@v_table> where <@v_tablekeycode2> > @i_multirowkey and <@v_tablekeycode1> = @i_key1 order by <@v_tablekeycode2>'	
		set @i_numkeys = 1
		set @i_key2 = null
	end
	
	--for some reason, parameters not working for table and column name
	select @v_select = replace(@v_select,'<@v_table>',@v_table)
	select @v_select = replace(@v_select,'<@v_column>',@v_column)

	IF coalesce(@v_tablekeycode1,'')<>''
		select @v_select = replace(@v_select,'<@v_tablekeycode1>',@v_tablekeycode1)
	IF coalesce(@v_tablekeycode2,'')<>''
		select @v_select = replace(@v_select,'<@v_tablekeycode2>',@v_tablekeycode2)
	IF coalesce(@v_tablekeycode3,'')<>''
		select @v_select = replace(@v_select,'<@v_tablekeycode3>',@v_tablekeycode3)
			
	select @i_illuscount = 0				  
	select @i_papercount = 0
	select @i_illuspapercount = 0
	select @i_count = 0
	select @i_multirowkey = 0
	select @i_fgind=0

	BEGIN--2 
			--Now process each key1,key2 to get the multiple key3 values
		IF coalesce(@v_select,'')<>''			
			WHILE (1 = 1) 
			BEGIN  
			-- Get next multi value
								
				--set params for dynamic sql execution
				 select @v_params =  N'@i_key1 int,
				 @i_key2 int,
				 @i_multirowkey int OUTPUT'
				   	
				 exec sp_executesql @v_select, @v_params, @i_key1, @i_key2,@i_multirowkey = @i_multirowkey OUTPUT   

				  -- Exit loop if no more templates
				IF @@ROWCOUNT = 0 BREAK			
								
				IF @i_numkeys = 2 and coalesce(@i_multirowkey,0)<>0 
				BEGIN	
					set @i_key3=@i_multirowkey
				--get source information now that we have the key
					IF @v_table = 'illus'  -- it is an insert, no parent
						begin
						select @i_hasparentcomponent =0
						select @i_illuscount = @i_illuscount + 1
						select @v_specitemcategorydescmulti = @v_specitemcategorydesc +' '+CAST(@i_illuscount as varchar(5))
						select @i_tablelinkingkey = materialkey from illus where bookkey = @i_key1 and printingkey = @i_key2 and groupnum = @i_key3
						select @i_vendorkey = illusvendorkey from textspecs where bookkey = @i_key1 and printingkey = @i_key2
						select @i_vendorkey = globalcontactkey from globalcontact where conversionkey = @i_vendorkey
						end	
					IF @v_table = 'materialspecs'  -- it is a paper (could also be an insert paper)
						begin
						select @i_hasparentcomponent =1									
						end	
					ELSE 
						select @i_hasparentcomponent =0
						select @i_count = 1

					IF coalesce(@i_hasparentcomponent,0)=1  
						BEGIN
						--determine if a textpaper or an insert paper
						select @i_isinsert = count(*) from illus where materialkey = @i_key3 
						IF coalesce(@i_isinsert,0)>0  --right now only dealing with papers with parents
						BEGIN
							select @i_illuspapercount = @i_illuspapercount +1			
							select @v_papertype = 'Insert'+' '+CAST(@i_illuspapercount as varchar(5))
							select @v_specitemcategorydescmulti = @v_specitemcategorydesc +'-'+@v_papertype							
							select @i_parentspecitemcategory = datacode from gentables where externalcode = '8' and tableid=616 
							
							--this works because the illus row will already be there with the same groupnum of the paper because illus table will be done first --!!!!!!!!! maybe not
							select @i_parenttaqversionpecategorykey = coalesce(t.taqversionspecategorykey,0) from taqversionspeccategory t 
							inner join qpl_multicomponent q on t.taqversionspecategorykey = q.taqversionspecategorykey 
							where t.taqprojectkey = @i_projectkey and t.taqversionkey = @i_selectedversionkey and t.itemcategorycode = @i_parentspecitemcategory 
							and  q.key1 = @i_key1 and q.key2 = @i_key2 and q.tablelinkingkey=@i_key3 and q.specitemcategorycode = @i_parentspecitemcategory
																										
						END
						IF coalesce(@i_isinsert,0)=0 
						BEGIN
							select @i_papercount = @i_papercount +1		
							select @v_papertype = 'Text Paper'+' '+CAST(@i_papercount as varchar(5))
							select @v_specitemcategorydescmulti = @v_specitemcategorydesc +'-'+@v_papertype		
							select @i_parentspecitemcategory = datacode from gentables where externalcode = '3' and tableid=616
							--this works because there is only one text specs component to link the papers to for now, if multiple print components are added, there will be trouble
							select @i_parenttaqversionpecategorykey = coalesce(taqversionspecategorykey,0) from taqversionspeccategory where 
							taqprojectkey = @i_projectkey and taqversionkey = @i_selectedversionkey and itemcategorycode = @i_parentspecitemcategory
													
						END
						END
					--for each @i_key3, see if there is already a @i_taqversionspeccategorykey for it on the qpl_multicomponent
					select @i_taqversionspeccategorykey = 0	  --init	
					
					--look for the correct taqversionspeccategorykey for the key1, key2, key3 combination
					select @i_taqversionspeccategorykey = coalesce(t.taqversionspecategorykey,0) from taqversionspeccategory t 
					inner join qpl_multicomponent q on t.taqversionspecategorykey = q.taqversionspecategorykey 
					where t.taqprojectkey = @i_projectkey and t.taqversionkey = @i_selectedversionkey and t.itemcategorycode = @i_specitemcategory 
					and  q.key1 = @i_key1 and q.key2 = @i_key2 and q.key3=@i_key3 and q.specitemcategorycode = @i_specitemcategory

				END

				IF @i_numkeys = 1 and coalesce(@i_multirowkey,0)<>0 
				BEGIN
					set @i_key2 = @i_multirowkey
					--look for the correct taqversionspeccategorykey for the key1, key2, key3 combination
					select @i_taqversionspeccategorykey = coalesce(t.taqversionspecategorykey,0) from taqversionspeccategory t 
					inner join qpl_multicomponent q on t.taqversionspecategorykey = q.taqversionspecategorykey 
					where t.taqprojectkey = @i_projectkey and t.taqversionkey = @i_selectedversionkey and t.itemcategorycode = @i_specitemcategory 
					and  q.key1 = @i_key1 and q.key2 = @i_key2 and q.specitemcategorycode = @i_specitemcategory
				END

				--now that we've checked for existing, if not there, insert it
				IF coalesce(@i_taqversionspeccategorykey,0) = 0  -- we know the source has this component because we have a key in hand proving it
				BEGIN 				
					exec dbo.get_next_key @v_userid,@i_taqversionspeccategorykey OUTPUT
					
					IF @i_hasparentcomponent =0	--illus	
					begin	
																						
						INSERT into taqversionspeccategory (taqversionspecategorykey,taqprojectkey,plstagecode,taqversionkey,taqversionformatkey,itemcategorycode,speccategorydescription,scaleprojecttype,
						vendorcontactkey,lastuserid,lastmaintdate,quantity,finishedgoodind)
						select @i_taqversionspeccategorykey,@i_projectkey,5,@i_selectedversionkey,@i_versionformatkey,@i_specitemcategory,@v_specitemcategorydescmulti,0,@i_vendorkey,@v_userid,getdate(),@i_sourcecompqty,@i_fgind
						
						exec dbo.taqversionspecnotes_insert_from_note @i_key1, @i_key2, 8, @i_taqversionspeccategorykey
						
					end
					IF @i_hasparentcomponent =1 and coalesce(@v_papertype,'')<>''
					begin
						IF coalesce(@i_parenttaqversionpecategorykey,0)<>0
						begin
							select @v_papertype =speccategorydescription from taqversionspeccategory where taqversionspecategorykey = @i_parenttaqversionpecategorykey
						end
						
						--get the vendor and qty from parent
						select @i_vendorkey = vendorcontactkey from taqversionspeccategory where taqversionspecategorykey = @i_parenttaqversionpecategorykey
						select @i_sourcecompqty = quantity from taqversionspeccategory where taqversionspecategorykey = @i_parenttaqversionpecategorykey
						
						
						INSERT into taqversionspeccategory (taqversionspecategorykey,taqprojectkey,plstagecode,taqversionkey,taqversionformatkey,itemcategorycode,speccategorydescription,scaleprojecttype,
						vendorcontactkey,lastuserid,lastmaintdate,quantity,finishedgoodind,taqversionparentspecategorykey)
						select @i_taqversionspeccategorykey,@i_projectkey,5,@i_selectedversionkey,@i_versionformatkey,@i_specitemcategory,@v_specitemcategorydescmulti,0,@i_vendorkey,@v_userid,getdate(),@i_sourcecompqty,@i_fgind,@i_parenttaqversionpecategorykey
					end			
					INSERT into qpl_multicomponent (taqversionspecategorykey,key1,key2,key3,multicomptypekey,specitemcategorycode,tablelinkingkey,lastuserid,lastmaintdate)
					select @i_taqversionspeccategorykey,@i_key1,@i_key2,@i_key3,@i_sourcecompkey,@i_specitemcategory,@i_tablelinkingkey,@v_userid,getdate()
					
				END
				--might have to do vendor and qty here if the actual spec items don't do it

				--now we have the component row, we can start doing specs

				--init the specitemkey	
				select @i_taqversionspecitemkey = 0
			
				IF coalesce(@i_selectedversionkey,0)<>0
				BEGIN 
					--get the taqversionspecitem values 
					select @i_qtyvalue = tvsi.quantity,
					@v_descvalue = tvsi.description,
					@v_desc2value = tvsi.description2,
					@i_detailvalue = tvsi.itemdetailcode,
					@i_uomvalue = tvsi.unitofmeasurecode,
					@i_decimalvalue = coalesce(tvsi.decimalvalue,0),
					@i_taqversionspecitemkey = tvsi.taqversionspecitemkey
					from taqversionspecitems tvsi inner join taqversionspeccategory tvsc on tvsi.taqversionspecategorykey = tvsc.taqversionspecategorykey 
					and tvsc.taqversionspecategorykey=@i_taqversionspeccategorykey 
					and tvsc.taqversionkey=@i_selectedversionkey 
					and tvsc.taqprojectkey = @i_projectkey
					and tvsi.itemcode = @i_specitemcode
					and tvsc.itemcategorycode = @i_specitemcategory
									
					---init the source values
					set @i_sourcedetailvalue = null
					set @i_sourceqtyvalue = null
					set @v_sourcedescvalue = null
					set @v_sourcedesc2value = null
					set @i_sourcedecimalvalue = null
					set @i_sourceuomvalue = null
					
					--GET THE SOURCE VALUE
					IF coalesce(@v_specitemtype,'') <>'' 
					BEGIN 						
						IF coalesce(@v_datatype,'') <> 'decimal' 
						BEGIN
							--get the source value based on the number of key columns, then convert the source value to whatever type you need
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) <>0
								set @v_update = N'Select @v_sourcevalue = <@v_column> from <@v_table> where <@v_tablekeycode1> = @i_key1 and <@v_tablekeycode2> = @i_key2 and <@v_tablekeycode3> = @i_key3'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) =0
								set @v_update = N'Select @v_sourcevalue = <@v_column> from <@v_table> where <@v_tablekeycode1> = @i_key1 and <@v_tablekeycode2> = @i_key2'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) = 0 and coalesce(@i_key3,0) =0
								set @v_update = N'Select @v_sourcevalue = <@v_column> from <@v_table> where <@v_tablekeycode1> = @i_key1'
						END 

						IF coalesce(@v_datatype,'') = 'decimal' 
						BEGIN 
							--get the source value based on the number of key columns, then convert the source value to whatever type you need
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) <>0
								set @v_update = N'Select @i_sourcedecimalvalue = <@v_column> from <@v_table> where <@v_tablekeycode1> = @i_key1 and <@v_tablekeycode2> = @i_key2 and <@v_tablekeycode3> = @i_key3'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) =0
								set @v_update = N'Select @i_sourcedecimalvalue = <@v_column> from <@v_table> where <@v_tablekeycode1> = @i_key1 and <@v_tablekeycode2> = @i_key2'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) = 0 and coalesce(@i_key3,0) =0
								set @v_update = N'Select @i_sourcedecimalvalue = <@v_column> from <@v_table> where <@v_tablekeycode1> = @i_key1'
						END 
						
						--for some reason, parameters not working for table and column name
						select @v_update = replace(@v_update,'<@v_table>',@v_table)
						select @v_update = replace(@v_update,'<@v_column>',@v_column)
						
						IF coalesce(@v_tablekeycode1,'')<>''
							select @v_update = replace(@v_update,'<@v_tablekeycode1>',@v_tablekeycode1)
						IF coalesce(@v_tablekeycode2,'')<>''
							select @v_update = replace(@v_update,'<@v_tablekeycode2>',@v_tablekeycode2)
						IF coalesce(@v_tablekeycode3,'')<>''
							select @v_update = replace(@v_update,'<@v_tablekeycode3>',@v_tablekeycode3)
												
						--if values, then execute dynamic sql
						IF coalesce(@v_update,'')<>''
						BEGIN
								set @v_params =  N'@i_key1 int,
										@i_key2 int,
										@i_key3 int,
										@v_sourcevalue nvarchar(255) OUTPUT,
										@i_sourcedecimalvalue FLOAT OUTPUT'										
						
								IF coalesce(@v_datatype,'') <> 'decimal' 
								exec sp_executesql @v_update, @v_params, @i_key1, @i_key2, @i_key3, @v_sourcevalue = @v_sourcevalue OUTPUT, @i_sourcedecimalvalue = @i_sourcedecimalvalue  OUTPUT
								
								
						END
					END
					--now take the generated values, evaluate, transform, and set
					IF coalesce(@v_sourcevalue,'')<>''
					BEGIN
					
						IF coalesce(@v_specitemtype,'') in ('Q','CK') and coalesce(@v_datatype,'') = 'int'  -- Quantity and component vendor
							select @v_sourceqtyvalue = @v_sourcevalue
						
							IF isnumeric(@v_sourceqtyvalue)=1 
								select @i_sourceqtyvalue = CAST(@v_sourceqtyvalue as INT)
							ELSE select @v_errordesc = 'source qty value is not numeric'
						
							IF @v_debug='Y'
								begin
								print @i_sourceqtyvalue
								print 'DT starts here for this synckey'
								print  @i_qsiconfigspecsynckey
								print  'spectype ' + @v_specitemtype
								print  'source value: '+ @v_sourcevalue
								print  @i_sourcedetailvalue
								end


						IF coalesce(@v_specitemtype,'') ='DT' and coalesce(@v_datatype,'') = 'int'  -- detailcode
							select @v_sourcedetailvalue = @v_sourcevalue
							--check mappings and transform
							IF coalesce(@i_mappingkey,0)<>0
								select @i_sourcedetailvalue = m.specitemvalue from qsiconfigspecsyncmapping m where @i_mappingkey = m.mappingkey and @v_sourcedetailvalue = m.tablevalue
							ELSE IF isnumeric(@v_sourcedetailvalue)=1
								select @i_sourcedetailvalue = CAST(@v_sourcedetailvalue as INT)
							ELSE select @v_errordesc = 'source detail value is not numeric or no mapping found'
							IF @v_debug='Y'
								print @i_sourcedetailvalue
						
						IF coalesce(@v_specitemtype,'') ='U' and coalesce(@v_datatype,'') = 'int'  -- unit of measure
							select @v_sourceuomvalue = @v_sourcevalue
							
							IF coalesce(@i_mappingkey,0)<>0
								select @i_sourceuomvalue = m.specitemvalue from qsiconfigspecsyncmapping m where @i_mappingkey = m.mappingkey and @v_sourceuomvalue = m.tablevalue
						
							IF isnumeric(@v_sourceuomvalue)=1 
								select @i_sourceuomvalue = CAST(@v_sourceuomvalue as INT)
							
							ELSE select @v_errordesc = 'source uom value is not numeric'
							IF @v_debug='Y'
								print @i_sourceuomvalue
						
						IF coalesce(@v_specitemtype,'')  in ('D','CD') and coalesce(@v_datatype,'') = 'varchar'  -- description and component description
							BEGIN --16
								IF coalesce(@i_exceptioncode,0) = 1
									begin
									select @v_table = ''''+@v_table+''''
									select @v_sourcedescvalue = [dbo].qpl_sync_get_concatcolors_fn (@i_key1, @i_key2, @v_table, ',')
									end
								IF coalesce(@i_exceptioncode,0) <>1
									select @v_sourcedescvalue = @v_sourcevalue
							 IF @v_debug='Y'
								print @v_sourcedescvalue
							END --16

						IF coalesce(@v_specitemtype,'') ='D2' and coalesce(@v_datatype,'') = 'varchar'  -- description2
							BEGIN --17
								IF @i_exceptioncode = 1
									begin
									select @v_table = ''''+@v_table+''''
										IF @v_debug='Y'
											print @v_table
									select @v_sourcedescvalue =[dbo].qpl_sync_get_concatcolors_fn (@i_key1, @i_key2, @v_table, ',')
									end
								IF coalesce(@i_exceptioncode,0) <> 1
									select @v_sourcedesc2value = @v_sourcevalue
							 IF @v_debug='Y'	
								print @v_sourcedesc2value
							END --17
					END
												
					--HAVE THE SOURCE VALUES, NOW INSERT OR UPDATE
					--check for taqversionspecitem row
					IF coalesce(@i_taqversionspecitemkey,0) =0
					BEGIN
					--insert a new row,else update
							exec dbo.get_next_key @v_userid,@i_taqversionspecitemkey OUTPUT
							
							insert into taqversionspecitems (taqversionspecitemkey,taqversionspecategorykey,itemcode,itemdetailcode,quantity,validforprtgscode,[description],description2,decimalvalue,unitofmeasurecode,lastuserid,lastmaintdate)
							select @i_taqversionspecitemkey,@i_taqversionspeccategorykey,@i_specitemcode,@i_sourcedetailvalue,@i_sourceqtyvalue,3,@v_sourcedescvalue,@v_sourcedesc2value,@i_sourcedecimalvalue,@i_sourceuomvalue,@v_userid,getdate()		
					END					
					--update for each type
					IF coalesce(@i_taqversionspecitemkey,0) <>0 --update
					BEGIN
							IF coalesce(@i_sourcedecimalvalue,-1) <> -1
								--compare source to target value, if different, update
									IF coalesce(@i_decimalvalue,0) <> @i_sourcedecimalvalue
										update taqversionspecitems
										set decimalvalue = @i_sourcedecimalvalue, lastuserid = @v_userid, lastmaintdate = getdate()
										where taqversionspecitemkey = @i_taqversionspecitemkey	
									IF @v_debug='Y'
										print 'decimal update complete'
								
							IF coalesce(@i_sourceqtyvalue,-1) <> -1
								--compare source to target value, if different, update
									IF 	coalesce(@i_qtyvalue,0) <> @i_sourceqtyvalue
										update taqversionspecitems
										set quantity = @i_sourceqtyvalue
										where taqversionspecitemkey = @i_taqversionspecitemkey	
									 IF @v_debug='Y'
										print 'qty update complete'
							
							IF coalesce(@i_sourcedetailvalue,-1) <> -1
								--compare source to target value, if different, update
									IF 	coalesce(@i_detailvalue,0) <> @i_sourcedetailvalue
										update taqversionspecitems
										set itemdetailcode = @i_sourcedetailvalue, lastuserid = @v_userid, lastmaintdate = getdate()
										where taqversionspecitemkey = @i_taqversionspecitemkey	
									IF @v_debug='Y'
										print 'detailcode update complete'
																	
							IF coalesce(@i_sourceuomvalue,-1) = -1
								--set to default value
									select @i_sourceuomvalue = coalesce(@i_defaultuomvalue,-1)
							IF coalesce(@i_sourceuomvalue,-1) <> -1		
								--compare source to target value, if different, update
									IF 	coalesce(@i_uomvalue,0) <> @i_sourceuomvalue
										update taqversionspecitems
										set unitofmeasurecode = @i_sourceuomvalue, lastuserid = @v_userid, lastmaintdate = getdate()
										where taqversionspecitemkey = @i_taqversionspecitemkey	
									IF @v_debug='Y'
										print 'uom update complete'
							IF coalesce(@v_sourcedesc2value,'zemptyz') <> 'zemptyz'
								--compare source to target value, if different, update
									IF 	coalesce(@v_desc2value,'') <> @v_sourcedesc2value
										update taqversionspecitems
										set [description2] = @v_sourcedesc2value, lastuserid = @v_userid, lastmaintdate = getdate()
										where taqversionspecitemkey = @i_taqversionspecitemkey	
									IF @v_debug='Y'	
										print 'desc2 update complete'
							IF coalesce(@v_sourcedescvalue,'zemptyz') <> 'zemptyz'
								--compare source to target value, if different, update
									IF 	coalesce(@v_descvalue,'') <> @v_sourcedescvalue
										update taqversionspecitems
										set [description] = @v_sourcedescvalue, lastuserid = @v_userid, lastmaintdate = getdate()
										where taqversionspecitemkey = @i_taqversionspecitemkey	
									IF @v_debug='Y'	
										print 'desc update complete'
							--COMPONENT LEVEL
							IF coalesce(@v_specitemtype,'') = 'CK' and isnull(@i_sourceqtyvalue,1)<>1  --,'CD') --do the component update for vendorkey and description
							begin
									select @i_sourceqtyvalue = globalcontactkey from globalcontact where conversionkey= @i_sourceqtyvalue
									IF @v_table = 'illus'
										select @i_sourceqtyvalue =@i_vendorkey
							
									IF coalesce(@i_vendorkey,0) <> @i_sourceqtyvalue
										update taqversionspeccategory
										set vendorcontactkey = @i_sourceqtyvalue
										where taqversionspecategorykey = @i_taqversionspeccategorykey
							end	
							IF coalesce(@v_specitemtype,'') = 'CD' and coalesce(@v_sourcedescvalue,'zemptyz')<> 'zemptyz' --,'CD') --do the component update for vendorkey and description
							begin
									select @v_sourcedescvalue = @v_specitemcategorydescmulti + '-' + @v_sourcedescvalue 								
									IF coalesce(@v_specitemcategorydesc,'') <> @v_sourcedescvalue
										update taqversionspeccategory
										set speccategorydescription = @v_sourcedescvalue
										where taqversionspecategorykey = @i_taqversionspeccategorykey
							end			
					END
				 
				END	
			   -- FETCH NEXT FROM c_multirowkey into @i_multirowkey
			   --END		
			END
		 --close c_multirowkey
		 --deallocate c_multirowkey	
	END		
END	


GO

