/****** Object:  StoredProcedure [dbo].[qpl_sync_tables2specitems]    Script Date: 08/31/2015 15:49:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[qpl_sync_tables2specitems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[qpl_sync_tables2specitems]
GO

/****** Object:  StoredProcedure [dbo].[qpl_sync_tables2specitems]    Script Date: 08/31/2015 15:49:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[qpl_sync_tables2specitems] @i_bookkey int, @i_printingkey int, @v_sourcetable varchar(50), @v_userid varchar(50)
AS
DECLARE 
@i_projectkey int,
@i_selectedversionkey int,
@v_update nvarchar(1000),
@v_insert nvarchar(1000),
@i_specitemcategory int,
@i_specitemcode int,
@v_tablename nvarchar(50),
@v_column nvarchar(255),
@v_tablenamekeycode1 nvarchar(255),
@v_tablenamekeycode2 nvarchar(255),
@v_tablenamekeycode3 nvarchar(255),
@v_tablenamekeycolumnconcat nvarchar(255),
@i_key1 int,
@i_key2 int,
@i_key3 int,
@v_key1 varchar(50),
@v_key2 varchar (50),
@v_key3 varchar (50),
@i_exceptioncode int,
@i_multicomptypekey int,
@v_specitemtype varchar(255),
@v_datatype varchar(255),
@i_mappingkey int,
@i_syncfromspecsind int,
@i_synctospecsind int,
@i_syncspecs int,
@i_bestid int,
@i_qsiconfigspecsynckey int,
@i_itemtype int,
@i_usageclass int,
@i_qtyvalue int,
@v_descvalue nvarchar(255),
@v_desc2value nvarchar(255),
@i_detailvalue int,
@i_detail2value int,
@i_uomvalue int,
@i_decimalvalue decimal(15,4),
@i_projectformatkey int,
@v_sourcevalue nvarchar(500),
@v_sourceqtyvalue nvarchar(50),
@i_sourceqtyvalue int,
@v_sourcedescvalue nvarchar(1000), 
@v_sourcedesc2value nvarchar (1000),
@i_sourcedetailvalue int,
@i_sourcedetail2value int,
@v_sourcedetailvalue nvarchar(255),
@v_sourcedetail2value nvarchar(255),
@i_sourceuomvalue int,
@v_sourceuomvalue nvarchar (255),
@i_sourcedecimalvalue float,
@v_specitemcategorydesc nvarchar(255),
@i_taqversionspecategoryrelatedcategorykey int,
@i_taqversionspeccategorykey int,
@i_taqversionspecitemkey int,
@i_mediatypecode int,
@i_mediatypesubcode int,
@i_versionformatkey int,
@i_maxversionkey int,
@i_versionformatyearkey int,
@i_sourcecompkey int,
@i_sourcecompqty int,
@v_fgind nvarchar (2),
@i_externalcode int,
@i_fgind int,
@i_vendorkey int,
@i_pokey int,
@v_errordesc varchar(255),
@v_params nvarchar(1000),
@v_multicompdesc nvarchar(25),
@v_debug nvarchar(10),
@i_parentspecitemcategory int,
@i_parenttaqversionpecategorykey int,
@i_firstprintonly int,
@i_defaultuomvalue int,
@v_gponumber varchar(255),
@i_maxchangenum int,
@i_maxgpokey int,
@i_numberrecords int, 
@i_rowcount int,
@i_fgtype int,
@i_ishardcover int,
@i_hasmedia int,
@v_count INT,
@v_sel_versionkey INT,
@i_mostrecentplstagecode INT,
@v_count_taqversion INT,
@i_printingnum int,
@i_hassummary int,
@i_addcomponent int

BEGIN --1	

--debugger
select @v_debug='N'
--get the printingnum from the printingkey
select @i_printingnum = coalesce(printingnum,0) from printing where bookkey=@i_bookkey and printingkey=@i_printingkey


--check for specconfig then continue - check the tablename 
select @i_syncspecs =  count(*) from  qsiconfigspecsync 
where tablename= @v_sourcetable and synctospecsind=1 and activeind=1

		IF @v_debug = 'Y'
			begin	
				print @v_sourcetable
			end

--if there are specs to sync, proceed	
	IF coalesce(@i_syncspecs,0)>0
	BEGIN--2 
		set nocount on
		
		DECLARE @specsynclist TABLE (rowid int identity (1,1), qsiconfigspecsynckey int)
		
		IF coalesce(@v_userid,'') <> 'FBTINITCONV'
		begin
		INSERT INTO @specsynclist (qsiconfigspecsynckey)
		select qsiconfigspecsynckey from qsiconfigspecsync where tablename= @v_sourcetable and synctospecsind=1 and activeind=1 
		order by qsiconfigspecsynckey
		end
		
		select 	@i_NumberRecords = count(*) from @specsynclist
		IF @v_debug = 'Y'
			begin	
				print '1' + @i_NumberRecords
			end
		
		--Include SUMMARY in initial conversion
		--BL: 2/4/15 Removed the always include of summary spec items and handled later to resolve a copy project issue
		IF coalesce(@v_userid,'') = 'FBTINITCONV'
		begin
			INSERT INTO @specsynclist (qsiconfigspecsynckey)
			select qsiconfigspecsynckey from qsiconfigspecsync where tablename= @v_sourcetable and synctospecsind=1 and activeind=1 
			UNION -- added to include the summary spec items so that they are processed and added even if empty so they show on new titles (first printing only) if summary doesn't already exist
			select qsiconfigspecsynckey from qsiconfigspecsync where specitemcategory=1 and synctospecsind=1 and activeind=1 
			order by qsiconfigspecsynckey
		end	
		
		select 	@i_NumberRecords = count(*) from @specsynclist
		IF @v_debug = 'Y'
			begin	
				print '2' + @i_NumberRecords
			end
			
		--SET @i_NumberRecords = @@ROWCOUNT
		SET @i_RowCount = 1

		WHILE @i_rowcount <= @i_numberrecords
		BEGIN--3
		 SELECT @i_qsiconfigspecsynckey = qsiconfigspecsynckey
		 FROM @specsynclist
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
			@i_defaultuomvalue = q.defaultuomvalue,
			@i_bestid = q.bestid
			from qsiconfigspecsync q 
			where q.qsiconfigspecsynckey = @i_qsiconfigspecsynckey 

			IF @v_debug = 'Y'
				begin
					print 'start'
					print @v_tablename
					print @i_qsiconfigspecsynckey
					print '@i_specitemcategory'
					print @i_specitemcategory
					print '@i_specitemcode'
					print @i_specitemcode
					print '@v_specitemtype'
					print @v_specitemtype
					print '@i_exceptioncode'
					print @i_exceptioncode
					print '@i_itemtype'
					print @i_itemtype
					print '@i_usageclass'
					print @i_usageclass
				end
			
			--we now have the whole config row, determine if an exception - if not, then process normally
			--IF coalesce(@i_exceptioncode,0) not in (2,3) and coalesce(@i_multicomptypekey,0) =0
							--IF @v_tablenamekeycode3 = 'materialkey' select @i_key3 = 
							--IF @v_tablenamekeycode3 = 'groupnum' select @i_key3 =
							--select @v_key3 = CAST(@i_key3 as varchar(50))
							
			--get the projectkey from taqprojecttile select * from taqprojecttitle - this is important for the Title acq approval so that we can get media and format after the add
			select @i_projectkey = tpt.taqprojectkey, @i_projectformatkey = tpt.taqprojectformatkey, @i_mediatypecode = tpt.mediatypecode, @i_mediatypesubcode = tpt.mediatypesubcode
			from taqprojecttitle tpt inner join taqproject t on t.taqprojectkey = tpt.taqprojectkey and t.searchitemcode = @i_itemtype and t.usageclasscode=@i_usageclass 
			where tpt.bookkey = @i_bookkey and tpt.printingkey=@i_printingkey
			
			select @i_hassummary = coalesce(count(*),0) from taqversionspeccategory where itemcategorycode=1 and taqprojectkey=@i_projectkey
					
			IF @v_debug = 'Y'
				begin
					print @i_projectkey
				end
			--more work to do here but for now set to bookkey,printingkey
			IF @v_tablenamekeycode1 = 'bookkey' select @i_key1 = @i_bookkey				
			IF @v_tablenamekeycode2 = 'printingkey' select @i_key2 = @i_printingkey
			IF @v_tablenamekeycode2 = 'printingkey' and @i_firstprintonly =1 select @i_key2=1 -- for fields that are only on 1st printing
		
			--cast keys to varchar for dynmaic sql
			select @v_key1 = CAST(@i_key1 as varchar(50))
			select @v_key2 = CAST(@i_key2 as varchar(50))
			
			--get media and format if filled in on bookdetail, get those directly from book (new titles won't have a coretitleinfo row yet)
			select @i_hasmedia =  COUNT(*) from bookdetail where bookkey=@i_bookkey and coalesce(mediatypecode,0)<>0
			
			IF coalesce (@i_hasmedia,0)>0
				select @i_mediatypecode = mediatypecode, @i_mediatypesubcode = mediatypesubcode  from bookdetail where bookkey = @i_bookkey 
			
			--set userid if empty
			select @v_userid = coalesce(@v_userid,'QSISYNC')
			
			--get the component desc -- will need to concat this with source desc in some cases later on
			select @v_specitemcategorydesc = datadesc, @i_fgtype = coalesce(gen2ind,0)  from gentables where tableid= 616 and datacode = @i_specitemcategory
						
			--collect some title\printing component data that will be useful
			select @i_externalcode = coalesce(externalcode,null), @v_specitemcategorydesc = datadesc from gentables where tableid=616 and datacode = @i_specitemcategory and isnumeric(externalcode)=1

			select @v_gponumber = max(gponumber) from gpo where gpokey in (select pokey from component where bookkey = @i_bookkey and printingkey=@i_printingkey and compkey =@i_externalcode)
			select @i_maxchangenum = coalesce(max(gpochangenum),0) from gpo where gponumber=@v_gponumber and gpochangenum is not null
			select @i_maxgpokey = coalesce(gpokey,0) from gpo where gponumber= @v_gponumber and coalesce(gpochangenum,0)=coalesce(@i_maxchangenum ,0)

			select @i_sourcecompkey = null

			select @i_sourcecompkey = c.compkey,@i_sourcecompqty=coalesce(ct.quantity,0),@v_fgind = c.finishedgoodind, @i_pokey = ct.pokey 
			from compspec c inner join component ct on c.compkey=ct.compkey and c.bookkey=ct.bookkey and c.printingkey=ct.printingkey and ct.pokey = coalesce(@i_maxgpokey,0)
			and c.bookkey = @i_bookkey and c.printingkey = @i_printingkey and c.compkey = @i_externalcode
			
			IF coalesce(@i_sourcecompkey,0)=0 and @i_exceptioncode = 5 -- binding spec endpaper fields.  would not necessarily have an endpaper component on source, but we need to create one later (and not duplicate)
				select @i_sourcecompkey = @i_externalcode				

			IF @v_tablenamekeycode3 = 'compkey' select @i_key3 = @i_sourcecompkey
				
			--get the vendorkey if it exists on the table
			IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @v_sourcetable AND COLUMN_NAME = 'vendorkey')
				begin
				select @i_vendorkey = null
				select @v_update = ''
				select @v_update = 'select @i_vendorkey = vendorkey from '+@v_sourcetable+' where bookkey = '+@v_key1+' and printingkey= '+ @v_key2
				exec sp_executesql @statement = @v_update, @v_params = N'@i_vendorkey int OUTPUT',@i_vendorkey = @i_vendorkey OUTPUT
					
				--now convert it to the globalcontatkey, this will need to change for other clients but HNA has conversionkey
				select @i_vendorkey = globalcontactkey from globalcontact where conversionkey= @i_vendorkey
				end 

				IF @v_debug = 'Y'
					begin
						print @v_update
						print @i_vendorkey
						print 'sourcecompkey'
						print @i_sourcecompkey
					end

			IF @v_fgind = 'Y' and coalesce(@i_specitemcategory,0) not in (1,16,17) 
				select @i_fgind = 1
			ELSE 
				select @i_fgind = 0
		
			IF @v_debug = 'Y'
					begin
						print 'fgind done'
					end
					
			/*NOTE --If there isn't a project -- need to discuss whether this is a real case or not*/
			--print '5'
			IF coalesce(@i_projectkey,0) <> 0
			BEGIN--5

		 -- Get the most recent active stage on this project that has a selected version
			SELECT @i_mostrecentplstagecode = dbo.qpl_get_most_recent_stage(@i_projectkey)
  
			IF @i_mostrecentplstagecode <= 0	--error occurred or no selected version exists for any active stage on this project
			BEGIN	
          -- Get the most recent stage existing on this project (regardless of whether it has a selected version)
			SELECT TOP(1) @i_mostrecentplstagecode = g.datacode 
			FROM gentablesitemtype gi, gentables g, taqplstage p
			WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus = 'N'
            AND p.plstagecode = g.datacode AND p.taqprojectkey = @i_projectkey
            AND gi.tableid = 562 AND gi.itemtypecode = @i_itemtype 
            AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
			ORDER BY gi.sortorder DESC, g.sortorder DESC
    
			IF @i_mostrecentplstagecode <= 0	--no stages exist on this project
			BEGIN
            -- Get the first active stage for this project's Item Type and Usage Class
            SELECT TOP(1) @i_mostrecentplstagecode = g.datacode FROM gentablesitemtype gi, gentables g
            WHERE g.tableid = gi.tableid AND g.datacode = gi.datacode AND g.deletestatus = 'N'
              AND gi.tableid = 562 AND gi.itemtypecode = @i_itemtype
              AND (gi.itemtypesubcode = @i_usageclass OR gi.itemtypesubcode = 0)
            ORDER BY gi.sortorder ASC, g.sortorder ASC
      
            IF @i_mostrecentplstagecode IS NULL
              SET @i_mostrecentplstagecode = 0
			END
			END
  
			-- Get the selected version for the most recent active stage on the project
			SELECT @i_selectedversionkey = selectedversionkey 
			FROM taqplstage 
			WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_mostrecentplstagecode
        
  
			IF @i_selectedversionkey IS NULL OR @i_selectedversionkey = 0	--no selected version exist for any active stage on this project
			BEGIN
          -- Get the next versionkey to use for this stage
                  
			SELECT @i_selectedversionkey = MAX(taqversionkey) + 1 
			FROM taqversion 
			WHERE taqprojectkey = @i_projectkey
			END
					IF @v_debug = 'Y'
						begin
							print '@i_selectedversionkey'
							print @i_selectedversionkey
						end
									

			IF coalesce(@i_selectedversionkey,0)= 0 -- if it still 0 then we need to add all the tables
			BEGIN--6
				--print '6'
				--if there isn't selected version, need to insert one 
					select @i_selectedversionkey = 1
						
					--print @i_selectedversionkey
					INSERT into taqversion (taqprojectkey,plstagecode,taqversionkey,taqversiondesc,plstatuscode,pltypecode,pltypesubcode,releasestrategycode,quantitytypecode,grosssalesunitind,
					generatedetailsalesunitsind,avgroyaltyenteredind,maxyearcode,lastuserid,lastmaintdate,totalchangedind,copiedfromprojectkey,copiedfromstage,copiedfromversion,prodqtyentrytypecode,generatecostsautoind,taqversiontype)
					SELECT @i_projectkey,@i_mostrecentplstagecode,@i_selectedversionkey,'systemgenerated',4,4,0,5,null,0,0,0,1,@v_userid,getdate(),0,0,0,0,1,0,0
					
					-- Make sure taqplstage record exists for plstagecode = @i_mostrecentplstagecode, with selectedversionkey = @i_selectedversionkey 
				    -- Add taqplstage record if it doesn't exist.
				    SELECT @v_count = 0
				    
				    SELECT @v_count = COUNT(*)
				      FROM taqplstage
				     WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_mostrecentplstagecode 
					 
					--print '@v_count'
					--print @v_count
					IF @v_count > 0 
					BEGIN
						SELECT @v_sel_versionkey = selectedversionkey
						FROM taqplstage
						WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_mostrecentplstagecode

						IF @v_sel_versionkey <> @i_selectedversionkey
						  UPDATE taqplstage
						  SET selectedversionkey = @i_selectedversionkey
						  WHERE taqprojectkey = @i_projectkey AND plstagecode = @i_mostrecentplstagecode
					 END
					 ELSE BEGIN
					  --print '@i_selectedversionkey'
					  --print @i_selectedversionkey
					  --print '@i_projectkey'
					  --print @i_projectkey
					  
						INSERT into taqplstage (taqprojectkey,plstagecode,selectedversionkey,lastuserid,lastmaintdate,exchangerate,exchangeratelockind)
						VALUES( @i_projectkey,@i_mostrecentplstagecode,@i_selectedversionkey,@v_userid,getdate(),0,0)
					END
				   --END 
				END --6
				--select * from taqversionspeccategory
				--lastly we need the @i_taqversionspeccategorykey from the taqversioncategory table 
				--where the itemcategorycode = @i_specitemcategory and the taqprojectkey=@i_projectkey and the taqversionkey = @i_selectedversionkey
				--if it isn't there we need to insert it
				
				IF @v_debug = 'Y'
					begin	
					 print '@i_specitemcategory'
					 print @i_specitemcategory
					end

				--init
				select @i_taqversionspeccategorykey = 0	
				
				IF coalesce(@i_multicomptypekey,0)=0 and coalesce(@i_exceptioncode,0) not in (2,3)
				begin	
					select @i_taqversionspeccategorykey = coalesce(taqversionspecategorykey,0) from taqversionspeccategory where 
					taqprojectkey = @i_projectkey and taqversionkey = @i_selectedversionkey and itemcategorycode = @i_specitemcategory 
				end
				--multiplecomptypekey  check to see if the component has already been created for this component
				IF coalesce(@i_multicomptypekey,0)<>0 and coalesce(@i_exceptioncode,0) not in (2,3)
				begin
				--look for the correct taqversionspeccategorykey for components: coverspecs,secondcoverspecs,coverinserts, and for special effects for covers,jackets,2ndcovers
					select @i_taqversionspeccategorykey = coalesce(t.taqversionspecategorykey,0) from taqversionspeccategory t 
					inner join qpl_multicomponent q on t.taqversionspecategorykey = q.taqversionspecategorykey 
					where t.taqprojectkey = @i_projectkey and t.taqversionkey = @i_selectedversionkey and t.itemcategorycode = @i_specitemcategory 
					and q.multicomptypekey = @i_multicomptypekey and q.specitemcategorycode = @i_specitemcategory
				end
				IF @v_debug = 'Y'
					begin
						print '@i_taqversionspeccategorykey --this should be zero' 
						print @i_taqversionspeccategorykey					
					end

				select @i_versionformatkey = taqprojectformatkey 
				from taqversionformat 
				where taqprojectkey=@i_projectkey and taqversionkey=@i_selectedversionkey and plstagecode=@i_mostrecentplstagecode
				
				IF coalesce(@i_versionformatkey,0) = 0
				BEGIN --6.5
					exec dbo.get_next_key @v_userid,@i_versionformatkey OUTPUT	
				
					INSERT into taqversionformat (taqprojectformatkey,taqprojectkey,plstagecode,taqversionkey,mediatypecode,mediatypesubcode,lastuserid,lastmaintdate)
					select @i_versionformatkey,@i_projectkey,@i_mostrecentplstagecode,@i_selectedversionkey,@i_mediatypecode,@i_mediatypesubcode,@v_userid, getdate() 
					from coretitleinfo c where c.bookkey = @i_bookkey and c.printingkey=@i_printingkey
					
				END --6.5
				
				--select @i_mediatypecode = mediatypecode, @i_mediatypesubcode= mediatypesubcode from taqversionformat where taqprojectformatkey =@i_versionformatkey and taqversionkey = @i_selectedversionkey
				
				-- if the format is a hardcover format	
				IF coalesce(@i_mediatypesubcode,0) in (select datasubcode from subgentables where subgen1ind=1 and tableid=312 and datacode=@i_mediatypecode)
					select @i_ishardcover=1 
				 
				select @i_versionformatyearkey = taqversionformatyearkey from taqversionformatyear 
				where taqprojectkey=@i_projectkey and taqversionkey=@i_selectedversionkey and plstagecode=@i_mostrecentplstagecode and taqprojectformatkey = @i_projectformatkey
				
				IF @v_debug = 'Y'
					begin
						print '@i_versionformatyearkey'
						print @i_versionformatyearkey
					end

				IF coalesce(@i_versionformatyearkey,0) = 0
				BEGIN --6.75
					exec dbo.get_next_key @v_userid,@i_versionformatyearkey OUTPUT	
				
					INSERT into taqversionformatyear (taqversionformatyearkey,taqprojectkey,plstagecode,taqversionkey,taqprojectformatkey,yearcode,printingnumber,prodcostgeneratekey,quantity,
					percentage,lastuserid,lastmaintdate,templatechangedind)
					select @i_versionformatyearkey,@i_projectkey,@i_mostrecentplstagecode,@i_selectedversionkey,@i_projectformatkey,1,c.printingnum,null,1,null,@v_userid, getdate(),0 
					from printing c where c.bookkey = @i_bookkey and c.printingkey=@i_printingkey
				END --6.75

				IF @v_debug = 'Y'
					begin
						print @i_taqversionspeccategorykey
						print '@i_sourcecompkey'
						print @i_sourcecompkey
						print 'right before'
						print @v_specitemtype
						print @i_exceptioncode
					end

				--Do paper and insert exceptions here, inserts first then papers so there is something to attach the paper to
				-- also still need to deal with notes (both component and summary)
				
				IF coalesce(@i_exceptioncode,0) in (2,3) and (coalesce(@v_specitemtype,'') <> 'CK' or coalesce(@v_specitemtype,'') <> 'CD' or coalesce(@v_specitemtype,'') <> 'VF')  --papers - materialspecs
					begin
					 --print 'starting multirow sub'
						IF @v_debug = 'Y'
							begin
							 print 'starting multirow sub'
							end
				
						exec [dbo].[qpl_sync_multirow2specitems] @i_key1,@i_key2,@i_projectkey,@i_selectedversionkey,@i_versionformatkey,@i_synctospecsind,@i_syncfromspecsind,
						@i_syncspecs,@i_specitemcode,@i_specitemcategory,@v_specitemcategorydesc,@i_sourcecompkey,@i_sourcecompqty,@v_tablename,@v_column,@v_tablenamekeycode1,@v_tablenamekeycode2,
						@v_tablenamekeycode3,@v_tablenamekeycolumnconcat,@v_specitemtype,@v_datatype,@i_mappingkey,@i_qsiconfigspecsynckey,@i_itemtype,@i_usageclass,@i_multicomptypekey,
						@i_exceptioncode,@v_userid,@i_firstprintonly,@i_defaultuomvalue 

						IF @v_debug = 'Y'
							begin
							 print 'ending multirow sub'
							end
					
					end
				IF @v_debug = 'Y'
					begin
					 print 'right after'
					 print 'compkey'
					 print @i_sourcecompkey				
					 print 'categorykey'
					 print @i_specitemcategory
					 print 'multicompkey'
					 print @i_multicomptypekey
					 print 'exception'
					 print @i_exceptioncode
					end
				
				--print @i_taqversionspeccategorykey
				--print @i_sourcecompkey
				--print @i_exceptioncode
				--print @i_multicomptypekey
				--print @i_specitemcategory
				--print @v_userid
				
				select @i_addcomponent = 0
				
				-- determine whether to create a new component or not												
				IF coalesce(@i_taqversionspeccategorykey,0) = 0
				and @i_specitemcategory =1 
				and coalesce(@v_userid,'') = 'FBTINITCONV'
				begin
					select @i_addcomponent = 1
				end
						
				
				IF coalesce(@i_taqversionspeccategorykey,0) = 0 
				and ((coalesce(@i_sourcecompkey,-1) <> -1)) --check that the source actually has this component
				and coalesce(@i_exceptioncode,0) not in (2,3,4) 
				and coalesce(@i_multicomptypekey,0)<>4  -- and is not a case(4), and not a cover
				and @i_specitemcategory <>1   --and not the summary (summary only on initial conversion to hangle copy project issues)
				begin
					select @i_addcomponent =1
				end	
				
				IF coalesce(@i_addcomponent,0)=1
				BEGIN --7										
										
					exec dbo.get_next_key @v_userid,@i_taqversionspeccategorykey OUTPUT
					
					--get the parent specitemcategorykey based on @i_parentspecitemcategory - 
					IF coalesce(@i_parentspecitemcategory,'')<>''
						begin
						select @i_parenttaqversionpecategorykey = coalesce(t.taqversionspecategorykey,0) from taqversionspeccategory t 
						where t.taqprojectkey = @i_projectkey and t.taqversionkey = @i_selectedversionkey and t.itemcategorycode = @i_parentspecitemcategory 
						end
								
					IF coalesce(@i_multicomptypekey,0)=0  
						begin
						INSERT into taqversionspeccategory (taqversionspecategorykey,taqprojectkey,plstagecode,taqversionkey,taqversionformatkey,itemcategorycode,speccategorydescription,scaleprojecttype,
						vendorcontactkey,lastuserid,lastmaintdate,quantity,finishedgoodind,taqversionparentspecategorykey)
						select @i_taqversionspeccategorykey,@i_projectkey,@i_mostrecentplstagecode,@i_selectedversionkey,@i_versionformatkey,@i_specitemcategory,@v_specitemcategorydesc,0,@i_vendorkey,@v_userid,getdate(),@i_sourcecompqty,@i_fgind,@i_parenttaqversionpecategorykey
						
						exec dbo.taqversionspecnotes_insert_from_note @i_bookkey, @i_printingkey, @i_sourcecompkey, @i_taqversionspeccategorykey
						
						end				
	
					IF coalesce(@i_multicomptypekey,0)<>0 
						begin
						select @v_multicompdesc = compdesc from comptype where compkey = @i_multicomptypekey
						
						--for multi comp types, check to make sure the comptype actually exists on the title - this works because these are all existing component types
						IF EXISTS (select * from compspec where bookkey=@i_bookkey and printingkey=@i_printingkey and compkey = @i_multicomptypekey)
						BEGIN
											
						INSERT into taqversionspeccategory (taqversionspecategorykey,taqprojectkey,plstagecode,taqversionkey,taqversionformatkey,itemcategorycode,speccategorydescription,scaleprojecttype,
						vendorcontactkey,lastuserid,lastmaintdate,quantity,finishedgoodind)
						select @i_taqversionspeccategorykey,@i_projectkey,@i_mostrecentplstagecode,@i_selectedversionkey,@i_versionformatkey,@i_specitemcategory,(@v_specitemcategorydesc+'-'+@v_multicompdesc),0,@i_vendorkey,@v_userid,getdate(),@i_sourcecompqty,@i_fgind
						
						exec dbo.taqversionspecnotes_insert_from_note @i_bookkey, @i_printingkey, @i_sourcecompkey, @i_taqversionspeccategorykey
						
						INSERT into qpl_multicomponent (taqversionspecategorykey,key1,key2,key3,multicomptypekey,specitemcategorycode,tablelinkingkey,lastuserid,lastmaintdate)
						select @i_taqversionspeccategorykey,@i_key1,@i_key2,@i_key3,@i_multicomptypekey,@i_specitemcategory,null,@v_userid,getdate()
						END
						end
						
					IF @v_debug = 'Y'
						begin
							print 'post taqversionspeccategory insert '
						end
				END --7
				
				--CASE and COVER SPECS	
						
				IF coalesce(@i_taqversionspeccategorykey,0) = 0 and (coalesce(@i_exceptioncode,0) = 4 or coalesce(@i_multicomptypekey,0)=4) and (coalesce(@v_specitemtype,'') <> 'CK' or coalesce(@v_specitemtype,'') <> 'CD' or coalesce(@v_specitemtype,'') <> 'VF')
				begin
					--print 'in case loop'
					exec dbo.get_next_key @v_userid,@i_taqversionspeccategorykey OUTPUT	
				
					IF coalesce(@i_ishardcover,0) = 1 and coalesce(@i_multicomptypekey,0)<>4 -- it is a case, do not worry about the cover specs, they won't get inserted
					begin					
						--get the parent specitemcategorykey based on @i_parentspecitemcategory - 
							IF coalesce(@i_parentspecitemcategory,'')<>''
								begin
								select @i_parenttaqversionpecategorykey = coalesce(t.taqversionspecategorykey,0) from taqversionspeccategory t 
								where t.taqprojectkey = @i_projectkey and t.taqversionkey = @i_selectedversionkey and t.itemcategorycode = @i_parentspecitemcategory 
								end
												
							INSERT into taqversionspeccategory (taqversionspecategorykey,taqprojectkey,plstagecode,taqversionkey,taqversionformatkey,itemcategorycode,speccategorydescription,scaleprojecttype,
							vendorcontactkey,lastuserid,lastmaintdate,quantity,finishedgoodind,taqversionparentspecategorykey)
							select @i_taqversionspeccategorykey,@i_projectkey,@i_mostrecentplstagecode,@i_selectedversionkey,@i_versionformatkey,@i_specitemcategory,@v_specitemcategorydesc,0,@i_vendorkey,@v_userid,getdate(),@i_sourcecompqty,@i_fgind,@i_parenttaqversionpecategorykey
							
							exec dbo.taqversionspecnotes_insert_from_note @i_bookkey, @i_printingkey, @i_sourcecompkey, @i_taqversionspeccategorykey
					end
						
					IF coalesce(@i_ishardcover,0) = 0 and coalesce(@i_multicomptypekey,0)=4 --it isn't a hardcover so insert the cover component
					begin
						IF @v_debug = 'Y'
						begin
							print 'in the cover loop'
							print 'compkey'
							print @i_sourcecompkey				
							print 'categorykey'
							print @i_specitemcategory
							print 'multicompkey'
							print @i_multicomptypekey
							print 'exception'
							print @i_exceptioncode
						end
						select @v_multicompdesc = compdesc from comptype where compkey = @i_multicomptypekey
					
						--for multi comp types, check to make sure the comptype actually exists on the title - this works because these are all existing component types
							IF EXISTS (select * from compspec where bookkey=@i_bookkey and printingkey=@i_printingkey and compkey = @i_multicomptypekey)
								BEGIN											
									INSERT into taqversionspeccategory (taqversionspecategorykey,taqprojectkey,plstagecode,taqversionkey,taqversionformatkey,itemcategorycode,speccategorydescription,scaleprojecttype,
									vendorcontactkey,lastuserid,lastmaintdate,quantity,finishedgoodind)
									select @i_taqversionspeccategorykey,@i_projectkey,@i_mostrecentplstagecode,@i_selectedversionkey,@i_versionformatkey,@i_specitemcategory,(@v_specitemcategorydesc+'-'+@v_multicompdesc),0,@i_vendorkey,@v_userid,getdate(),@i_sourcecompqty,@i_fgind
									
									exec dbo.taqversionspecnotes_insert_from_note @i_bookkey, @i_printingkey, @i_sourcecompkey, @i_taqversionspeccategorykey

									INSERT into qpl_multicomponent (taqversionspecategorykey,key1,key2,key3,multicomptypekey,specitemcategorycode,tablelinkingkey,lastuserid,lastmaintdate)
									select @i_taqversionspeccategorykey,@i_key1,@i_key2,@i_key3,@i_multicomptypekey,@i_specitemcategory,null,@v_userid,getdate()
								END
					end									
				end
				
			
				IF coalesce(@i_taqversionspeccategorykey,0) >0 
				BEGIN --7.5
					IF coalesce(@i_vendorkey,0)<>0
					BEGIN
						update taqversionspeccategory set vendorcontactkey = @i_vendorkey where taqversionspecategorykey = @i_taqversionspeccategorykey
					END
					IF coalesce(@i_sourcecompqty,0)<>0
					BEGIN
						update taqversionspeccategory set quantity =  @i_sourcecompqty where taqversionspecategorykey = @i_taqversionspeccategorykey
					END
					IF  coalesce(@i_fgind,0)<>0 and @i_fgtype = 1  --make sure it can be a fg
					BEGIN
						update taqversionspeccategory set finishedgoodind= @i_fgind where taqversionspecategorykey = @i_taqversionspeccategorykey
					END
				END --7.5

					IF @v_debug = 'Y'
						begin
							print 'post taqversionspeccategory update' 
						end		
				
				--init the specitemkey	
				select @i_taqversionspecitemkey = 0
				
				--now have project and version key, start updating\inserting taqversionspecitems
				IF coalesce(@i_selectedversionkey,0)<>0
				BEGIN --8
				--get the taqversionspecitem values for that row
				select @i_qtyvalue = tvsi.quantity,
				@v_descvalue = tvsi.description,
				@v_desc2value = tvsi.description2,
				@i_detailvalue = tvsi.itemdetailcode,
				@i_detail2value = tvsi.itemdetailsubcode,
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
				set @i_sourcedetail2value = null
				set @i_sourceqtyvalue = null
				set @v_sourcedescvalue = null
				set @v_sourcedesc2value = null
				set @i_sourcedecimalvalue = null
				set @i_sourceuomvalue = null
				set @v_sourcevalue = null
				
						
				--GET THE SOURCE VALUE
				IF coalesce(@v_specitemtype,'') <>'' and coalesce(@i_exceptioncode,0) not in (2,3)  -- papers and inserts
					BEGIN --9						
						IF coalesce(@v_datatype,'') <> 'decimal' 
							BEGIN --10
							--get the source value based on the number of key columns, then convert the source value to whatever type you need
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) <>0
								select @v_update = N'Select @v_sourcevalue = <@v_column> from <tablename> where <@v_tablenamekeycode1> = @i_key1 and <@v_tablenamekeycode2> = @i_key2 and <@v_tablenamekeycode3> = @i_key3'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) =0
								select @v_update = N'Select @v_sourcevalue = <@v_column> from <tablename> where <@v_tablenamekeycode1> = @i_key1 and <@v_tablenamekeycode2> = @i_key2'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) = 0 and coalesce(@i_key3,0) =0
								select @v_update = N'Select @v_sourcevalue = <@v_column> from <tablename> where <@v_tablenamekeycode1> = @i_key1'
							END --10

						IF coalesce(@v_datatype,'') = 'decimal' 
							
							BEGIN --11
							--get the source value based on the number of key columns, then convert the source value to whatever type you need
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) <>0
								select @v_update = N'Select @i_sourcedecimalvalue = <@v_column> from <tablename> where <@v_tablenamekeycode1> = @i_key1 and <@v_tablenamekeycode2> = @i_key2 and <@v_tablenamekeycode3> = @i_key3'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) <> 0 and coalesce(@i_key3,0) =0
								select @v_update = N'Select @i_sourcedecimalvalue = <@v_column> from <tablename> where <@v_tablenamekeycode1> = @i_key1 and <@v_tablenamekeycode2> = @i_key2'
							IF coalesce(@i_key1,0) <> 0 and coalesce(@i_key2,0) = 0 and coalesce(@i_key3,0) =0
								select @v_update = N'Select @i_sourcedecimalvalue = <@v_column> from <tablename> where @v_tablenamekeycode1> = @i_key1'
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
									@v_sourcevalue nvarchar(255) OUTPUT, 
									@i_sourcedecimalvalue FLOAT OUTPUT'

								exec sp_executesql @v_update, @v_params, 
									@i_key1, 
									@i_key2, 
									@i_key3, 
									@v_sourcevalue = @v_sourcevalue OUTPUT, 
									@i_sourcedecimalvalue = @i_sourcedecimalvalue OUTPUT
								
								IF @v_debug='Y'
									begin	
										print @v_params
										print '@v_sourcevalue'
										print @v_sourcevalue
										print '@i_sourcedecimalvalue'
										print @i_sourcedecimalvalue
										print '@v_specitemtype'
										print @v_specitemtype
									end
							END--12
						
						--BL 1/7/15: certain values require 'best' logic, take the @i_bestid and get the source value 	
						IF coalesce(@i_bestid,0)<>0
							begin
								--pagecount
								IF @i_bestid = 1 and @v_tablenamekeycode1 = 'bookkey' and @v_tablenamekeycode2 = 'printingkey' 
									select @v_sourcevalue = dbo.get_BestPageCount (@i_key1,@i_key2)
								
								--ins\illus
								IF @i_bestid = 2 and @v_tablenamekeycode1 = 'bookkey' and @v_tablenamekeycode2 = 'printingkey' 
									select @v_sourcevalue = dbo.get_BestInsertIllus (@i_key1,@i_key2)	
								
								--trim size length
								IF @i_bestid = 3 and @v_tablenamekeycode1 = 'bookkey' and @v_tablenamekeycode2 = 'printingkey' 
									select @v_sourcevalue = [dbo].[rpt_get_best_trim_dimension] (@i_key1,@i_key2,'L')	
								
								--trim size width
								IF @i_bestid = 4 and @v_tablenamekeycode1 = 'bookkey' and @v_tablenamekeycode2 = 'printingkey' 
									select @v_sourcevalue = [dbo].[rpt_get_best_trim_dimension] (@i_key1,@i_key2,'W')			
							end
							
						--now take the generated values, evaluate, transform, and set
						IF coalesce(@v_specitemtype,'') in ('Q','CK','VF') and coalesce(@v_datatype,'') = 'int'  -- Quantity and component vendor and version format
							BEGIN--13
								select @v_sourceqtyvalue = @v_sourcevalue
							
								IF isnumeric(@v_sourceqtyvalue)=1 
									select @i_sourceqtyvalue = CAST(@v_sourceqtyvalue as INT)
								
								ELSE select @v_errordesc = 'source qty value is not numeric'
							
							IF @v_debug='Y'
								begin
								 print '@i_sourceqtyvalue'
								 print @i_sourceqtyvalue
								 print '@v_sourcedetailvalue'
								 print @v_sourcedetailvalue
								end
							END --13
						
						IF coalesce(@v_specitemtype,'') ='DT' and coalesce(@v_datatype,'') = 'int'  -- detailcode
							BEGIN --14
								select @v_sourcedetailvalue = @v_sourcevalue
								--check mappings and transform
								IF coalesce(@i_mappingkey,0)<>0
									select @i_sourcedetailvalue = m.specitemvalue from qsiconfigspecsyncmapping m where @i_mappingkey = m.mappingkey and @v_sourcedetailvalue = m.tablevalue
								ELSE IF isnumeric(@v_sourcedetailvalue)=1
									select @i_sourcedetailvalue = CAST(@v_sourcedetailvalue as INT)

								ELSE select @v_errordesc = 'source detail value is not numeric or no mapping found'
							 IF @v_debug='Y'
							 begin
							  print '@i_sourcedetailvalue' 	
							  print @i_sourcedetailvalue
							 end 
							END	--14
							
						IF coalesce(@v_specitemtype,'') ='T2' and coalesce(@v_datatype,'') = 'int'  -- detailsubcode
							BEGIN --14
								select @v_sourcedetail2value = @v_sourcevalue
								--check mappings and transform
								IF coalesce(@i_mappingkey,0)<>0
									select @i_sourcedetail2value = m.specitemvalue from qsiconfigspecsyncmapping m where @i_mappingkey = m.mappingkey and @v_sourcedetail2value = m.tablevalue
								ELSE IF isnumeric(@v_sourcedetail2value)=1
									select @i_sourcedetail2value = CAST(@v_sourcedetail2value as INT)

								ELSE select @v_errordesc = 'source detail value is not numeric or no mapping found'
							 IF @v_debug='Y'
							 begin
							  print '@i_sourcedetailvalue' 	
							  print @i_sourcedetailvalue
							 end 
							END	--14	
							

						IF coalesce(@v_specitemtype,'') ='U' and coalesce(@v_datatype,'') = 'int'  -- unit of measure
							BEGIN --15
								select @v_sourceuomvalue = @v_sourcevalue
								
								IF coalesce(@i_mappingkey,0)<>0
									select @i_sourceuomvalue = m.specitemvalue from qsiconfigspecsyncmapping m where @i_mappingkey = m.mappingkey and @v_sourceuomvalue = m.tablevalue
							
								IF isnumeric(@v_sourceuomvalue)=1 
									select @i_sourceuomvalue = CAST(@v_sourceuomvalue as INT)
								
								ELSE select @v_errordesc = 'source uom value is not numeric'
							 IF @v_debug='Y'
								begin
									print '@i_sourceuomvalue'		
									print @i_sourceuomvalue
								end
							END --15
						
						IF coalesce(@v_specitemtype,'')  in ('D','CD') and coalesce(@v_datatype,'') = 'varchar'  -- description and component description
							BEGIN --16
								
								IF coalesce(@i_exceptioncode,0) = 1 and coalesce(@v_specitemtype,'') <>'CD'
									begin
										--print 'qpl_sync_get_concatcolors_fn start'
										select @v_sourcedescvalue = [dbo].qpl_sync_get_concatcolors_fn (@i_bookkey, @i_printingkey, @v_tablename, ',')
										--print 'qpl_sync_get_concatcolors_fn end'
									end
								IF coalesce(@i_exceptioncode,0) <>1 or coalesce(@v_specitemtype,'') = 'CD'
									begin			
										select @v_sourcedescvalue = @v_sourcevalue
									end
							 IF @v_debug='Y'
								begin
									print '@v_sourcedescvalue'
									print @v_sourcedescvalue
								end
							END --16

						IF coalesce(@v_specitemtype,'') ='D2' and coalesce(@v_datatype,'') = 'varchar'  -- description2
							BEGIN --17
								IF coalesce(@i_exceptioncode,0) = 1
									begin
									  select @v_sourcedesc2value =[dbo].qpl_sync_get_concatcolors_fn (@i_bookkey, @i_printingkey, @v_tablename, ',')
									end
								IF coalesce(@i_exceptioncode,0) <> 1
									select @v_sourcedesc2value = @v_sourcevalue
							 IF @v_debug='Y'
							 	print @v_sourcedesc2value
							END --17
						
						--HAVE THE SOURCE VALUES, NOW INSERT OR UPDATE
						--check for taqversionspecitem row
						IF coalesce(@i_taqversionspecitemkey,0) =0 and (coalesce(@i_sourcedetailvalue ,-1)<>-1 or coalesce(@i_sourcedetail2value ,-1)<>-1 or coalesce(@i_sourceqtyvalue ,-1)<>-1 or coalesce(@i_sourcedecimalvalue ,-1)<>-1 
						or coalesce(@v_sourcedescvalue ,'zemptyz')<>'zemptyz' or coalesce(@v_sourcedesc2value ,'zemptyz')<>'zemptyz')  -- this way we don't insert a row for the default uom if there isn't a real value
						--insert a new row,else update
							BEGIN --18
								exec dbo.get_next_key @v_userid,@i_taqversionspecitemkey OUTPUT
							
								insert into taqversionspecitems (taqversionspecitemkey,taqversionspecategorykey,itemcode,itemdetailcode,itemdetailsubcode,quantity,validforprtgscode,[description],description2,decimalvalue,unitofmeasurecode,lastuserid,lastmaintdate)
								select @i_taqversionspecitemkey,@i_taqversionspeccategorykey,@i_specitemcode,@i_sourcedetailvalue,@i_sourcedetail2value,@i_sourceqtyvalue,3,@v_sourcedescvalue,@v_sourcedesc2value,cast(@i_sourcedecimalvalue as decimal(15,4)),@i_sourceuomvalue,@v_userid,getdate()		

							END --18
						
						-- if it is the summary component, then insert all fields for the item type you are doing if there isn't a row already 
						IF @i_specitemcategory = 1 and coalesce(@i_taqversionspecitemkey,0) =0 
							BEGIN 
								exec dbo.get_next_key @v_userid,@i_taqversionspecitemkey OUTPUT
							
								insert into taqversionspecitems (taqversionspecitemkey,taqversionspecategorykey,itemcode,itemdetailcode,itemdetailsubcode,quantity,validforprtgscode,[description],description2,decimalvalue,unitofmeasurecode,lastuserid,lastmaintdate)
								select @i_taqversionspecitemkey,@i_taqversionspeccategorykey,@i_specitemcode,@i_sourcedetailvalue,@i_sourcedetail2value,@i_sourceqtyvalue,3,@v_sourcedescvalue,@v_sourcedesc2value,cast(@i_sourcedecimalvalue as decimal(15,4)),@i_sourceuomvalue,@v_userid,getdate()		

							END --18.5				
						
						--update for each type
						IF coalesce(@i_taqversionspecitemkey,0) <>0 --update
						BEGIN  --19
								IF coalesce(@i_sourcedecimalvalue,-1) <> -1
									begin ---20
									--compare source to target value, if different, update
										IF coalesce(@i_decimalvalue,-1) <> coalesce(@i_sourcedecimalvalue,-1)
											update taqversionspecitems
											set decimalvalue = cast(@i_sourcedecimalvalue as decimal(15,4)), lastuserid = @v_userid, lastmaintdate = getdate()
											where taqversionspecitemkey = @i_taqversionspecitemkey	
									 IF @v_debug='Y'
										print 'decimal update complete'
									end	 --20

								IF coalesce(@i_sourceqtyvalue,-1) <> -1
									begin --21
									--compare source to target value, if different, update
										IF 	coalesce(@i_qtyvalue,-1) <> coalesce(@i_sourceqtyvalue,-1)
											update taqversionspecitems
											set quantity = @i_sourceqtyvalue
											where taqversionspecitemkey = @i_taqversionspecitemkey	
									 IF @v_debug='Y'
										print 'qty update complete'
									end	--21

								IF coalesce(@i_sourcedetailvalue,-1) <> -1
									begin --22
									--compare source to target value, if different, update
										IF 	coalesce(@i_detailvalue,-1) <> coalesce(@i_sourcedetailvalue,-1)
											update taqversionspecitems
											set itemdetailcode = @i_sourcedetailvalue, lastuserid = @v_userid, lastmaintdate = getdate()
											where taqversionspecitemkey = @i_taqversionspecitemkey	
									 IF @v_debug='Y'
										print 'detailcode update complete'
									end	 --22
									
								IF coalesce(@i_sourcedetail2value,-1) <> -1
									begin --22
									--compare source to target value, if different, update
										IF 	coalesce(@i_detail2value,-1) <> coalesce(@i_sourcedetail2value,-1)
											update taqversionspecitems
											set itemdetailsubcode = @i_sourcedetail2value, lastuserid = @v_userid, lastmaintdate = getdate()
											where taqversionspecitemkey = @i_taqversionspecitemkey	
									 IF @v_debug='Y'
										print 'detailcode update complete'
									end	 --22	
									
								IF coalesce(@i_sourceuomvalue,-1) = -1
								--set to default value
									select @i_sourceuomvalue = coalesce(@i_defaultuomvalue,-1)
																
								IF coalesce(@i_sourceuomvalue,-1) <> -1
									begin --23
									--compare source to target value, if different, update
										IF 	coalesce(@i_uomvalue,-1) <> coalesce(@i_sourceuomvalue,-1)
											update taqversionspecitems
											set unitofmeasurecode = @i_sourceuomvalue, lastuserid = @v_userid, lastmaintdate = getdate()
											where taqversionspecitemkey = @i_taqversionspecitemkey	
									 IF @v_debug='Y'
										print 'uom update complete'
									end --23		

								IF coalesce(@v_sourcedesc2value,'zemptyz') <> 'zemptyz'
								--IF isnull(@v_sourcedesc2value,1) <> 1
									begin --24
									--compare source to target value, if different, update
										IF 	coalesce(@v_desc2value,'zemptyz') <> coalesce(@v_sourcedesc2value,'zemptyz')
											update taqversionspecitems
											set [description2] = @v_sourcedesc2value, lastuserid = @v_userid, lastmaintdate = getdate()
											where taqversionspecitemkey = @i_taqversionspecitemkey	
									 IF @v_debug='Y'	
										print 'desc2 update complete'
									end	--24					
															
								IF coalesce(@v_sourcedescvalue,'zemptyz') <> 'zemptyz'
								--IF isnull(@v_sourcedescvalue,1) <> 1
									begin --25
									--compare source to target value, if different, update
										IF 	coalesce(@v_descvalue,'zemptyz') <> coalesce(@v_sourcedescvalue,'zemptyz')
											update taqversionspecitems
											set [description] = @v_sourcedescvalue, lastuserid = @v_userid, lastmaintdate = getdate()
											where taqversionspecitemkey = @i_taqversionspecitemkey	
									 IF @v_debug='Y'	
										print 'desc update complete'
									end	--25

								--COMPONENT LEVEL
								IF coalesce(@v_specitemtype,'') = 'CK' and isnull(@i_sourceqtyvalue,1)<>1  --,'CD') --do the component update for vendorkey and description
									BEGIN--26
										select @i_sourceqtyvalue = globalcontactkey from globalcontact where conversionkey= @i_sourceqtyvalue
								
										IF coalesce(@i_vendorkey,-1) <> coalesce(@i_sourceqtyvalue,-1)
											update taqversionspeccategory
											set vendorcontactkey = @i_sourceqtyvalue
											where taqversionspecategorykey = @i_taqversionspeccategorykey
									END	--26

								IF coalesce(@v_specitemtype,'') = 'CD' and coalesce(@v_sourcedescvalue,'zemptyz')<>'zemptyz'  --,'CD') --do the component update for vendorkey and description
									BEGIN--26
										select @v_sourcedescvalue = @v_specitemcategorydesc + '-' + @v_sourcedescvalue								
										IF coalesce(@v_specitemcategorydesc,'zemptyz') <> coalesce(@v_sourcedescvalue,'zemptyz')
											update taqversionspeccategory
											set speccategorydescription = @v_sourcedescvalue
											where taqversionspecategorykey = @i_taqversionspeccategorykey
									END	--26
						END--19
								
						--print '@i_versionformatkey'
						--print @i_versionformatkey
						--print '@i_mediatypecode'
						--print @i_mediatypecode
						--print '@v_specitemtype'
						--print @v_specitemtype
								
																													
						--TAQVERSIONFORMAT
						IF coalesce(@v_specitemtype,'') = 'VF'  and @i_printingkey=1  --mediacode 
						--print 'in the format loop'
						BEGIN
							select @i_sourceqtyvalue =0
							select @i_qtyvalue =0
							
							IF @v_column='mediatypecode'
							BEGIN	
								select @i_sourceqtyvalue = @i_mediatypecode--mediatypecode from bookdetail where bookkey=@i_bookkey
								select @i_qtyvalue = mediatypecode from taqversionformat where taqprojectformatkey=@i_versionformatkey										
								
								--print '@i_sourceqtyvalue'
								--print @i_sourceqtyvalue
								--print '@i_qtyvalue'
								--print @i_qtyvalue
																		
								IF 	coalesce(@i_qtyvalue,-1) <> coalesce(@i_sourceqtyvalue,-1)
									update taqversionformat
									set mediatypecode = @i_sourceqtyvalue
									where taqprojectformatkey = @i_versionformatkey
							END									
						
							IF @v_column='mediatypesubcode' --mediasubcode 
							BEGIN
								select @i_sourceqtyvalue = @i_mediatypesubcode --mediatypesubcode from bookdetail where bookkey=@i_bookkey
								select @i_qtyvalue = mediatypesubcode from taqversionformat where taqprojectformatkey=@i_versionformatkey
					
								IF 	coalesce(@i_qtyvalue,-1) <> coalesce(@i_sourceqtyvalue,-1)
									update taqversionformat
									set mediatypesubcode = @i_sourceqtyvalue
									where taqprojectformatkey = @i_versionformatkey
							END	--27			
						END					
						
					END--9
				END--8
			END--5
			--print 'end'
			--print @i_qsiconfigspecsynckey
         SET @i_RowCount = @i_RowCount + 1
		END--3
	set nocount off	 
	END--2	
END --1

GO

GRANT EXEC ON [dbo].[qpl_sync_tables2specitems] to PUBLIC
go


