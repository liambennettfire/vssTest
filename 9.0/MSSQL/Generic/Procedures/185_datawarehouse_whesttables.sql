if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[datawarehouse_whesttables]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[datawarehouse_whesttables]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE  proc dbo.datawarehouse_whesttables
@ware_estkey int,
@ware_bookkey int,
@ware_printingkey int,
@ware_logkey int,
@ware_warehousekey int,
@ware_system_date datetime

AS

DECLARE @ware_count int

DECLARE @i_estkey int
DECLARE @i_versionkey int
DECLARE @i_finishedgoodqty int
DECLARE @i_finishedgoodvendorcode int
DECLARE @c_description varchar(100)
DECLARE @i_scaleorgentrykey int
DECLARE @i_selectedversionind smallint
DECLARE @d_requestdatetime datetime
DECLARE @c_requestedbyname varchar(100)
DECLARE @c_requestid varchar(30)
DECLARE @c_requestcomment varchar(255)
DECLARE @c_requestbatchid varchar(30)
DECLARE @i_approvedind  int
DECLARE @i_statuscode  int
DECLARE @d_creationdate datetime
DECLARE @c_createdbyuserid varchar(30)
DECLARE @c_jobnumber varchar(50)
DECLARE @c_specialinstructions1 varchar(300)
DECLARE @c_specialinstructions2 varchar(300)
DECLARE @c_specialinstructions3 varchar(300)
DECLARE @i_versiontypecode smallint
DECLARE @c_lastuserid varchar(30)
DECLARE @d_lastmaintdate datetime
DECLARE @i_sortorder smallint

DECLARE @i_eststatus2 int

DECLARE @ware_charge_unitcost1 float
DECLARE @ware_charge_totalcost1 float
DECLARE @ware_charge_unitcost2 float
DECLARE @ware_charge_totalcost2 float
DECLARE @ware_chargedesc varchar(40) 
DECLARE @ware_externalcode varchar(6) 
DECLARE @ware_tag1 varchar(8) 
DECLARE @ware_tag2 varchar(8) 
DECLARE @ware_costtype varchar(25) 
DECLARE @ware_compdesc varchar(32) 
DECLARE @ware_compkey smallint
DECLARE @ware_runcostper1000 float
DECLARE @ware_manualentryind   varchar(1) 

DECLARE @ware_paperprice float
DECLARE @ware_basiswtcode smallint
DECLARE @ware_basiswtdesc varchar(100) 
DECLARE @ware_stocktypecode smallint
DECLARE @ware_stocktype varchar(100) 
DECLARE @ware_allocationmr int
DECLARE @ware_allocationper1000 int
DECLARE @ware_allocation	int
DECLARE @ware_royaltyper1 float
DECLARE @ware_royaltyper2 float
DECLARE @ware_royaltyper3 float
DECLARE @ware_royaltyqty1 float
DECLARE @ware_royaltyqty2 int
DECLARE @ware_royaltyqty3 int
DECLARE @ware_statusdesc varchar(100)
DECLARE @ware_statusshortdesc varchar(20)
DECLARE @ware_lastusername varchar(100) 
DECLARE @ware_compkey_ck  int
DECLARE @ware_matkey int
DECLARE @i_royaltypercent float 
DECLARE @i_royaltyquantity int
DECLARE @ware_description varchar(100) /*11-17-04 CRM 2047 Add Version Description to whestfields tables */


DECLARE @i_lastestversionkey int
DECLARE @i_linenumber int
DECLARE @nc_sqlstring NVARCHAR(1000)
DECLARE @nc_sqlparameters NVARCHAR (1000)

DECLARE @i_roystatus int
DECLARE @i_coststatus int
DECLARE @i_chgcodecode int
DECLARE @ware_costcount int
DECLARE  @ware_count_royal  int

DECLARE @ware_cartonqty int
DECLARE @ware_printqty int
DECLARE @ware_coverqty int
DECLARE @ware_jacketqty int
DECLARE @ware_insertqty int
DECLARE @ware_endpapqty int

	DECLARE cur_whesttables INSENSITIVE CURSOR
	FOR
		SELECT estkey,versionkey,finishedgoodqty,finishedgoodvendorcode,description,
		scaleorgentrykey,selectedversionind,requestdatetime,requestedbyname,
		requestid,requestcomment,requestbatchid,approvedind,statuscode,creationdate,createdbyuserid,
		jobnumber,specialinstructions1,specialinstructions2,specialinstructions3,
		versiontypecode,lastuserid,lastmaintdate,sortorder, description
		    FROM estversion
		   	WHERE estkey = @ware_estkey
				and reportind = 1 
				 ORDER BY estkey, sortorder
	FOR READ ONLY

	select @ware_count = 1

	OPEN cur_whesttables 
 
		FETCH NEXT FROM cur_whesttables
			INTO @i_estkey,@i_versionkey,@i_finishedgoodqty,@i_finishedgoodvendorcode,@c_description, 
				@i_scaleorgentrykey,@i_selectedversionind,@d_requestdatetime,@c_requestedbyname,
				@c_requestid,@c_requestcomment,@c_requestbatchid,@i_approvedind,@i_statuscode,
				@d_creationdate,@c_createdbyuserid,@c_jobnumber,@c_specialinstructions1,
				@c_specialinstructions2,@c_specialinstructions3,@i_versiontypecode,
				@c_lastuserid, @d_lastmaintdate,@i_sortorder,@ware_description

		select @i_eststatus2 = @@FETCH_STATUS
		IF @i_eststatus2 <> 0 
		  begin
			close cur_whesttables
			deallocate cur_whesttables
			RETURN
		  end

		while (@i_eststatus2 <>-1 )
		   begin

			IF (@i_eststatus2<>-2)
			  begin
				if @i_finishedgoodqty is null 
				  begin
					select @i_finishedgoodqty = 0
				  end
				if @i_finishedgoodvendorcode is null 
				  begin
					select @i_finishedgoodvendorcode = 0
				  end
				if @c_description is null 
				  begin 
					select @c_description = ''
				  end
				if @i_scaleorgentrykey is null 
				  begin
					select @i_scaleorgentrykey = ''
				  end
				if @i_selectedversionind is null
				  begin
					select @i_selectedversionind = 0
				  end
				if @d_requestdatetime is null 
				  begin
					select @d_requestdatetime = ''
				  end
				if @c_requestedbyname is null 
				  begin
					select @c_requestedbyname = ''
				  end
				if @c_requestid is null 
				  begin
					select @c_requestid = ''
				  end
				if @c_requestcomment is null 
				  begin
					select @c_requestcomment = ''
				  end
				if @c_requestbatchid is null 
				  begin
					select @c_requestbatchid = ''
				  end
				if @i_approvedind is null 
				  begin
					select @i_approvedind = 0
				  end
				if @i_statuscode is null 
				  begin
					select @i_statuscode = 0
				  end
				if @d_creationdate is null 
				  begin
					select @d_creationdate = ''
				  end
				if @c_createdbyuserid is null 
				  begin
					select @c_createdbyuserid = ''
				  end
				if @c_jobnumber is null 
				  begin
					select @c_jobnumber = ''
				  end
				if @c_specialinstructions1 is null 
				  begin
					select @c_specialinstructions1 = ''
				  end
				if @c_specialinstructions2 is null 
				  begin
					select @c_specialinstructions2 = ''
				  end
				if @c_specialinstructions3 is null 
				  begin
					select @c_specialinstructions3 = ''
				  end
				if @i_versiontypecode is null 
				  begin
					select @i_versiontypecode = 0
				  end
				if @c_lastuserid is null 
				  begin
					select @c_lastuserid = ''
				  end
				if @d_lastmaintdate is null 
				  begin
					select @d_lastmaintdate = ''
				  end
				if @i_sortorder is null 
				  begin
					select @i_sortorder = 0
				  end
				
				select @ware_charge_unitcost1 = 0
				select  @ware_charge_totalcost1 = 0
				select @ware_charge_unitcost2 = 0
				select @ware_charge_totalcost2 = 0
				select @ware_chargedesc = '' 
				select @ware_externalcode = '' 
				select @ware_tag1 = '' 
				select @ware_tag2 = '' 
				select @ware_costtype = ''
				select @ware_compdesc = ''
				select @ware_compkey = 0
				select @ware_runcostper1000 = 0
				select @ware_manualentryind = '' 
				select @ware_paperprice = 0
				select @ware_basiswtcode = 0
				select @ware_basiswtdesc = ''
				select @ware_stocktypecode = 0
				select @ware_stocktype = ''
				select @ware_allocationmr = 0
				select @ware_allocationper1000 = 0
				select @ware_allocation	= 0
				select @ware_royaltyper1 = 0
				select @ware_royaltyper2 = 0
				select @ware_royaltyper3 = 0
				select @ware_royaltyqty1 = 0
				select @ware_royaltyqty2 = 0
				select @ware_royaltyqty3 = 0
				select @ware_statusdesc = ''
				select @ware_statusshortdesc = ''
				select @ware_lastusername = ''

/* 5-25-04 add quantities -- print, coverqty,jacketqty,insertqty,endpapqty */
	
				select @ware_printqty = 0
				select @ware_coverqty  = 0
				select @ware_jacketqty = 0
				select @ware_insertqty  = 0
				select @ware_endpapqty  = 0
				select @ware_cartonqty = 0

				select @ware_count = 0
				
				select @ware_count = count(*) from estcomp
				where estkey = @ware_estkey 
				and versionkey = @i_versionkey
				and compkey = 2

				if @ware_count > 0 
				  begin
					Select @ware_cartonqty = cartonqty from estcomp 
					where estkey = @ware_estkey 
					and versionkey = @i_versionkey
					and compkey = 2
				  end

				select @ware_count = 0

				select @ware_count = count(*) from estmaterialspecs
					where  estkey = @ware_estkey and versionkey = @i_versionkey
				if @ware_count > 0 
				  begin
					
					select @ware_compkey_ck = 0
					select @ware_matkey = 0

					select @ware_compkey_ck =min(compkey) from estmaterialspecs
						where  estkey = @ware_estkey and versionkey = @i_versionkey
	
					select @ware_matkey = min(materialkey)  from estmaterialspecs
						where  estkey = @ware_estkey and versionkey = @i_versionkey
							and compkey = @ware_compkey_ck
	
					select @ware_paperprice = paperprice,@ware_basiswtcode=basisweightcode,
						@ware_stocktypecode=stocktypecode,@ware_allocationmr=allocationmr,
						@ware_allocationper1000= allocationper1000,@ware_allocation=allocation
			 			 from estmaterialspecs
							where  estkey = @ware_estkey and versionkey = @i_versionkey
								and compkey= @ware_compkey_ck and materialkey = @ware_matkey

				  end				
	
				if @ware_basiswtcode is null 
				  begin
					select @ware_basiswtcode = 0
			  	  end

				if @ware_basiswtcode > 0 
				  begin
					select @ware_basiswtdesc = datadesc from gentables where tableid=47
						and datacode = @ware_basiswtcode
				  end
				if @ware_stocktypecode is null 
				  begin
					select @ware_stocktypecode = 0
				  end

				if @ware_stocktypecode > 0 
				  begin
					select @ware_stocktype = datadesc from gentables where tableid=27
						and datacode = @ware_stocktypecode
				  end
/* royalty loop*/
				select @ware_count_royal = 0
				SELECT @ware_count_royal = count(*) 
	  			  FROM estroyal
					where estkey = @ware_estkey and versionkey = @i_versionkey
				if  @ware_count_royal > 0 
				  begin
					select @ware_count = 1

					DECLARE cur_whestroyalty INSENSITIVE CURSOR
					  FOR 
						SELECT royaltypercent, royaltyquantity
		  					  FROM estroyal
								where estkey = @ware_estkey and versionkey = @i_versionkey
   							 ORDER BY royaltypercent
					FOR READ ONLY
				
					OPEN cur_whestroyalty
 	
					FETCH NEXT FROM cur_whestroyalty
					INTO @i_royaltypercent, @i_royaltyquantity
	
					select @i_roystatus = @@FETCH_STATUS
					IF @i_roystatus <> 0 
		 			 begin
						close cur_whestroyalty
						deallocate cur_whestroyalty
					  end
					while (@i_roystatus  <>-1 )
					   begin
			
					IF (@i_roystatus <>-2)
					  begin
	
					    if @ware_count = 1 
					      begin
						select @ware_royaltyper1 = @i_royaltypercent
						select @ware_royaltyqty1 = @i_royaltyquantity
					      end
	
					   if @ware_count = 2 
					    begin
						select @ware_royaltyper2 = @i_royaltypercent
						select @ware_royaltyqty2 = @i_royaltyquantity
					      end
				
					   if @ware_count = 3 
					    begin
						select @ware_royaltyper3 = @i_royaltypercent
						select @ware_royaltyqty3 = @i_royaltyquantity
					     end

						select @ware_count = @ware_count + 1
					end /*<>2*/
		
					FETCH NEXT FROM cur_whestroyalty
					INTO @i_royaltypercent, @i_royaltyquantity
	
					select @i_roystatus = @@FETCH_STATUS
				end
				close cur_whestroyalty
				deallocate cur_whestroyalty
			end
/*status*/
		if @i_statuscode > 0 
		  begin
			select @ware_statusdesc =datadesc,@ware_statusshortdesc = datadescshort
				from gentables where tableid=429 and datacode= @i_statuscode 
		  end

		if datalength(@c_lastuserid) > 0 
		  begin
			select @ware_count = 0

			select @ware_count = count(*)
				from qsiusers where upper(userid) = upper(@c_lastuserid)
			if @ware_count > 0 
			  begin
				select @ware_lastusername = firstname + ' ' + lastname
					from qsiusers where upper(userid) = upper(@c_lastuserid)
			  end
			else
			  begin
				select @ware_lastusername = upper(@c_lastuserid)
			  end
		  end
		
/* 5-10-04 add quantities -- print, coverqty,jacketqty,insertqty,endpapqty */

	select @ware_count = 0
	select @ware_count = count(*) from estcomp where estkey = @ware_estkey and versionkey = @i_versionkey
			and  compkey = 3
	if @ware_count > 0
	  begin
		select @ware_printqty = compqty  from estcomp where estkey = @ware_estkey and versionkey = @i_versionkey
			and  compkey = 3
	 end


	select @ware_count = 0
	select @ware_count = count(*) from estcomp where estkey = @ware_estkey and versionkey = @i_versionkey
			and  compkey = 4

	if @ware_count > 0 
	  begin
		select @ware_coverqty = compqty from estcomp where estkey = @ware_estkey and versionkey = @i_versionkey
			and  compkey = 4
	  end


	select @ware_count = 0
	select @ware_count = count(*) from estcomp where estkey = @ware_estkey and versionkey = @i_versionkey
			and  compkey = 5

	if @ware_count > 0 
	  begin
		select @ware_jacketqty = compqty from estcomp where estkey = @ware_estkey and versionkey = @i_versionkey
			and  compkey = 5
	  end

	select @ware_count = 0
	select @ware_count = count(*) from estcomp where estkey = @ware_estkey and versionkey = @i_versionkey
			and  compkey = 7

	if @ware_count > 0 
	  begin
		select @ware_endpapqty = compqty  from estcomp where estkey = @ware_estkey and versionkey = @i_versionkey
			and  compkey = 7
	  end


	select @ware_count = 0 /* get first row of insert */
	select @ware_count = min(groupnum)  from estcomp where estkey = @ware_estkey and versionkey = @i_versionkey
			and  compkey = 8

	if @ware_count > 0 
	  begin
		select @ware_insertqty  = compqty from estcomp where estkey = @ware_estkey and versionkey = @i_versionkey
			and  compkey = 8 and groupnum = @ware_count
	  end

		select @ware_count = 0

		exec datawarehouse_estupd @ware_estkey,@i_versionkey,@ware_bookkey,@ware_printingkey,
		@i_sortorder,@ware_paperprice,@ware_basiswtdesc,@ware_stocktype,@ware_allocationmr,
		@ware_allocationper1000,@ware_allocation,@ware_royaltyper1,@ware_royaltyper2,
		@ware_royaltyper3,@ware_royaltyqty1,@ware_royaltyqty2,@ware_royaltyqty3,@ware_statusdesc,
		@ware_statusshortdesc,@ware_lastusername,@ware_cartonqty,@ware_printqty,@ware_coverqty,@ware_jacketqty,
		@ware_insertqty,@ware_endpapqty, @ware_count OUTPUT

		select @ware_count_royal = 0
		SELECT @ware_count_royal = count(*) 
		  	FROM whcestcostfields w, estcost c
				WHERE estkey = @ware_estkey and 
				versionkey = @i_versionkey
				and c.chgcodecode =  w.chgcodecode 

		if  @ware_count_royal > 0 
		  begin
			DECLARE cur_whestcost INSENSITIVE CURSOR
				FOR 
				SELECT linenumber,w.chgcodecode 
			  		FROM whcestcostfields w, estcost c
					WHERE estkey = @ware_estkey and 
					versionkey = @i_versionkey
					and c.chgcodecode =  w.chgcodecode 
   					ORDER BY linenumber
			FOR READ ONLY
			
			OPEN cur_whestcost 
				FETCH NEXT FROM cur_whestcost 
					INTO @i_linenumber, @i_chgcodecode
	
					select @i_coststatus = @@FETCH_STATUS
					IF @i_coststatus <> 0 
		 			 begin
						close cur_whestcost 
						deallocate cur_whestcost 
					  end
					while (@i_coststatus <>-1 )
					   begin
		
					IF (@i_coststatus<>-2)
					  begin
 	
						select @ware_charge_totalcost1 = 0
						select @ware_charge_unitcost1 = 0
						select @ware_charge_totalcost2 = 0
						select @ware_charge_unitcost2 = 0
						select @ware_externalcode = ''
						select @ware_chargedesc = ''
						select @ware_tag1 = ''
						select @ware_tag2 = ''
						select @ware_costtype = ''
						select @ware_compdesc = ''
						select @ware_compkey = 0
						select @ware_costcount = 0

						select @ware_chargedesc = externaldesc,@ware_externalcode = externalcode,
							  @ware_tag1 = tag1,@ware_tag2 = tag2, @ware_costtype = costtype
								from cdlist where internalcode = @i_chgcodecode

	
						select @ware_costcount = count(*) 
							from estcost
					 			 where estkey = @ware_estkey and versionkey = @i_versionkey
									and chgcodecode =  @i_chgcodecode 
					
						if @ware_costcount > 0
						  begin

/* 3-1-04 multiple compkeys then use min, usually bind*/
	
							select @ware_compkey = min(compkey)
								from estcost
				 			where estkey = @ware_estkey and versionkey = @i_versionkey
								and chgcodecode =  @i_chgcodecode


							select @ware_charge_totalcost1 = totalcost, @ware_charge_unitcost1 = unitcost,
							@ware_runcostper1000 = runcostper1000,@ware_manualentryind = manualentryind,
							@ware_compkey = compkey
								from estcost
				 				 where estkey = @ware_estkey and versionkey = @i_versionkey
									and chgcodecode =  @i_chgcodecode 

						if @ware_compkey > 0
						  begin
							select @ware_compdesc = compdesc   
								from comptype 
								where compkey = @ware_compkey
						  end
				
						if @i_sortorder = 1 	
						  begin

		
						if @i_linenumber <= 41
						begin
							set @nc_sqlstring = 'update whestcostfields1 set ' +
							'chargecodedesc' + convert (varchar (10),@i_linenumber) + '= @ware_chargedesc,'+
							'chargecodeexternalcode' + convert (varchar (10),@i_linenumber) + ' = @ware_externalcode,'+
							'chargecodetag1_' + convert (varchar (10),@i_linenumber) + ' = @ware_tag1,'+
							'chargecodetag2_' + convert (varchar (10),@i_linenumber) + ' = @ware_tag2,'+
							'compdesc' + convert (varchar (10),@i_linenumber) + ' = @ware_compdesc,'+
							'costtype' + convert (varchar (10),@i_linenumber) + '= @ware_costtype,'+
							'unitcost' + convert (varchar (10),@i_linenumber) + ' = @ware_charge_unitcost1,'+
							'totalcost' + convert (varchar (10),@i_linenumber) + ' = @ware_charge_totalcost1,'+	
							'runcostper1000_' + convert (varchar (10),@i_linenumber) + ' =@ware_runcostper1000,'+
							'manualyesno' + convert (varchar (10),@i_linenumber) + ' =@ware_manualentryind' +
							' where estkey = @ware_estkey and estversionkey = @i_versionkey
								and bookkey = @ware_bookkey
								and printingkey = @ware_printingkey'

				
							set @nc_sqlparameters = '@ware_estkey INT, @i_versionkey INT, @ware_bookkey INT,@ware_printingkey INT,
								@ware_chargedesc varchar (40),@ware_externalcode varchar(6),
								@ware_tag1 varchar(8),@ware_tag2 varchar(8), @ware_compdesc varchar(32), 
								@ware_costtype varchar(25),@ware_charge_unitcost1 float,@ware_charge_totalcost1 float,
			 					 @ware_runcostper1000 float,@ware_manualentryind   varchar(1)' 

							EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_estkey, @i_versionkey, @ware_bookkey,@ware_printingkey,
								@ware_chargedesc,@ware_externalcode,@ware_tag1,@ware_tag2, @ware_compdesc ,
								@ware_costtype ,@ware_charge_unitcost1,@ware_charge_totalcost1,
 								 @ware_runcostper1000,@ware_manualentryind 
					end /* End If rowcount */
				end /*sortorder*/

				if @i_sortorder = 2 	
				  begin
	
				if @i_linenumber <= 41
					begin
					set @nc_sqlstring = 'update whestcostfields2 set ' +
					'chargecodedesc' + convert (varchar (10),@i_linenumber) + '= @ware_chargedesc,'+
					'chargecodeexternalcode' + convert (varchar (10),@i_linenumber) + ' = @ware_externalcode,'+
					'chargecodetag1_' + convert (varchar (10),@i_linenumber) + ' = @ware_tag1,'+
					'chargecodetag2_' + convert (varchar (10),@i_linenumber) + ' = @ware_tag2,'+
					'compdesc' + convert (varchar (10),@i_linenumber) + ' = @ware_compdesc,'+
					'costtype' + convert (varchar (10),@i_linenumber) + '= @ware_costtype,'+
					'unitcost' + convert (varchar (10),@i_linenumber) + ' = @ware_charge_unitcost1,'+
					'totalcost' + convert (varchar (10),@i_linenumber) + ' = @ware_charge_totalcost1,'+	
					'runcostper1000_' + convert (varchar (10),@i_linenumber) + ' =@ware_runcostper1000,'+
					'manualyesno' + convert (varchar (10),@i_linenumber) + ' =@ware_manualentryind' +
					' where estkey = @ware_estkey and estversionkey = @i_versionkey
							and bookkey = @ware_bookkey
							and printingkey = @ware_printingkey'
				
					set @nc_sqlparameters = '@ware_estkey INT, @i_versionkey INT, @ware_bookkey INT,@ware_printingkey INT,
						@ware_chargedesc varchar (40),@ware_externalcode varchar(6),
						@ware_tag1 varchar(8),@ware_tag2 varchar(8), @ware_compdesc varchar(32), 
						@ware_costtype varchar(25),@ware_charge_unitcost1 float,@ware_charge_totalcost1 float,
 						 @ware_runcostper1000 float,@ware_manualentryind   varchar(1)' 

					EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_estkey, @i_versionkey, @ware_bookkey,@ware_printingkey,
						@ware_chargedesc,@ware_externalcode,@ware_tag1,@ware_tag2, @ware_compdesc ,
						@ware_costtype ,@ware_charge_unitcost1,@ware_charge_totalcost1,
 						 @ware_runcostper1000,@ware_manualentryind 
		
				end /* End If rowcount */
			end /*sortorder*/
			if @i_sortorder = 3 	
			  begin
	
		
				if @i_linenumber <= 41
					begin
					set @nc_sqlstring = 'update whestcostfields3 set ' +
					'chargecodedesc' + convert (varchar (10),@i_linenumber) + '= @ware_chargedesc,'+
					'chargecodeexternalcode' + convert (varchar (10),@i_linenumber) + ' = @ware_externalcode,'+
					'chargecodetag1_' + convert (varchar (10),@i_linenumber) + ' = @ware_tag1,'+
					'chargecodetag2_' + convert (varchar (10),@i_linenumber) + ' = @ware_tag2,'+
					'compdesc' + convert (varchar (10),@i_linenumber) + ' = @ware_compdesc,'+
					'costtype' + convert (varchar (10),@i_linenumber) + '= @ware_costtype,'+
					'unitcost' + convert (varchar (10),@i_linenumber) + ' = @ware_charge_unitcost1,'+
					'totalcost' + convert (varchar (10),@i_linenumber) + ' = @ware_charge_totalcost1,'+	
					'runcostper1000_' + convert (varchar (10),@i_linenumber) + ' =@ware_runcostper1000,'+
					'manualyesno' + convert (varchar (10),@i_linenumber) + ' =@ware_manualentryind' +
					' where estkey = @ware_estkey and estversionkey = @i_versionkey
							and bookkey = @ware_bookkey
							and printingkey = @ware_printingkey'
					
					set @nc_sqlparameters = '@ware_estkey INT, @i_versionkey INT, @ware_bookkey INT,@ware_printingkey INT,
						@ware_chargedesc varchar (40),@ware_externalcode varchar(6),
						@ware_tag1 varchar(8),@ware_tag2 varchar(8), @ware_compdesc varchar(32), 
						@ware_costtype varchar(25),@ware_charge_unitcost1 float,@ware_charge_totalcost1 float,
 						 @ware_runcostper1000 float,@ware_manualentryind   varchar(1)' 

					EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_estkey, @i_versionkey, @ware_bookkey,@ware_printingkey,
						@ware_chargedesc,@ware_externalcode,@ware_tag1,@ware_tag2, @ware_compdesc ,
						@ware_costtype ,@ware_charge_unitcost1,@ware_charge_totalcost1,
 						 @ware_runcostper1000,@ware_manualentryind 
		
				end /* End If rowcount */
			end /*sortorder*/
			if @i_sortorder = 4 	
			  begin
				if @i_linenumber <= 41
					begin
					set @nc_sqlstring = 'update whestcostfields4 set ' +
					'chargecodedesc' + convert (varchar (10),@i_linenumber) + '= @ware_chargedesc,'+
					'chargecodeexternalcode' + convert (varchar (10),@i_linenumber) + ' = @ware_externalcode,'+
					'chargecodetag1_' + convert (varchar (10),@i_linenumber) + ' = @ware_tag1,'+
					'chargecodetag2_' + convert (varchar (10),@i_linenumber) + ' = @ware_tag2,'+
					'compdesc' + convert (varchar (10),@i_linenumber) + ' = @ware_compdesc,'+
					'costtype' + convert (varchar (10),@i_linenumber) + '= @ware_costtype,'+
					'unitcost' + convert (varchar (10),@i_linenumber) + ' = @ware_charge_unitcost1,'+
					'totalcost' + convert (varchar (10),@i_linenumber) + ' = @ware_charge_totalcost1,'+	
					'runcostper1000_' + convert (varchar (10),@i_linenumber) + ' =@ware_runcostper1000,'+
					'manualyesno' + convert (varchar (10),@i_linenumber) + ' =@ware_manualentryind' +
					' where estkey = @ware_estkey and estversionkey = @i_versionkey
							and bookkey = @ware_bookkey
							and printingkey = @ware_printingkey'
				
					set @nc_sqlparameters = '@ware_estkey INT, @i_versionkey INT, @ware_bookkey INT,@ware_printingkey INT,
						@ware_chargedesc varchar (40),@ware_externalcode varchar(6),
						@ware_tag1 varchar(8),@ware_tag2 varchar(8), @ware_compdesc varchar(32), 
						@ware_costtype varchar(25),@ware_charge_unitcost1 float,@ware_charge_totalcost1 float,
 						 @ware_runcostper1000 float,@ware_manualentryind   varchar(1)' 

					EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_estkey, @i_versionkey, @ware_bookkey,@ware_printingkey,
						@ware_chargedesc,@ware_externalcode,@ware_tag1,@ware_tag2, @ware_compdesc ,
						@ware_costtype ,@ware_charge_unitcost1,@ware_charge_totalcost1,
 						 @ware_runcostper1000,@ware_manualentryind 
		
				end /* End If rowcount */
			end /*sortorder*/
		
			if @i_sortorder = 5 	
			  begin
	
				if @i_linenumber <= 41
					begin
					set @nc_sqlstring = 'update whestcostfields5 set ' +
					'chargecodedesc' + convert (varchar (10),@i_linenumber) + '= @ware_chargedesc,'+
					'chargecodeexternalcode' + convert (varchar (10),@i_linenumber) + ' = @ware_externalcode,'+
					'chargecodetag1_' + convert (varchar (10),@i_linenumber) + ' = @ware_tag1,'+
					'chargecodetag2_' + convert (varchar (10),@i_linenumber) + ' = @ware_tag2,'+
					'compdesc' + convert (varchar (10),@i_linenumber) + ' = @ware_compdesc,'+
					'costtype' + convert (varchar (10),@i_linenumber) + '= @ware_costtype,'+
					'unitcost' + convert (varchar (10),@i_linenumber) + ' = @ware_charge_unitcost1,'+
					'totalcost' + convert (varchar (10),@i_linenumber) + ' = @ware_charge_totalcost1,'+	
					'runcostper1000_' + convert (varchar (10),@i_linenumber) + ' =@ware_runcostper1000,'+
					'manualyesno' + convert (varchar (10),@i_linenumber) + ' =@ware_manualentryind' +
					' where estkey = @ware_estkey and estversionkey = @i_versionkey
							and bookkey = @ware_bookkey
							and printingkey = @ware_printingkey'
				
					set @nc_sqlparameters = '@ware_estkey INT, @i_versionkey INT, @ware_bookkey INT,@ware_printingkey INT,
						@ware_chargedesc varchar (40),@ware_externalcode varchar(6),
						@ware_tag1 varchar(8),@ware_tag2 varchar(8), @ware_compdesc varchar(32), 
						@ware_costtype varchar(25),@ware_charge_unitcost1 float,@ware_charge_totalcost1 float,
 						 @ware_runcostper1000 float,@ware_manualentryind   varchar(1)' 

					EXEC sp_executesql @nc_sqlstring, @nc_sqlparameters,@ware_estkey, @i_versionkey, @ware_bookkey,@ware_printingkey,
						@ware_chargedesc,@ware_externalcode,@ware_tag1,@ware_tag2, @ware_compdesc ,
						@ware_costtype ,@ware_charge_unitcost1,@ware_charge_totalcost1,
 						 @ware_runcostper1000,@ware_manualentryind 
		
				end /* End If rowcount */
			end /*sortorder*/
		end /*cost >0*/
		end /*<>2*/

		FETCH NEXT FROM cur_whestcost 
			INTO @i_linenumber, @i_chgcodecode

		select @i_coststatus = @@FETCH_STATUS
	end
		close cur_whestcost 
		deallocate cur_whestcost 
	end /* cost mapping table*/
    end /*<>*/

	FETCH NEXT FROM cur_whesttables
		INTO @i_estkey,@i_versionkey,@i_finishedgoodqty,@i_finishedgoodvendorcode,@c_description, 
			@i_scaleorgentrykey,@i_selectedversionind,@d_requestdatetime,@c_requestedbyname,
			@c_requestid,@c_requestcomment,@c_requestbatchid,@i_approvedind,@i_statuscode,
			@d_creationdate,@c_createdbyuserid,@c_jobnumber,@c_specialinstructions1,
			@c_specialinstructions2,@c_specialinstructions3,@i_versiontypecode,
			@c_lastuserid, @d_lastmaintdate,@i_sortorder,@c_description

	select @i_eststatus2 = @@FETCH_STATUS
end

close cur_whesttables
deallocate cur_whesttables


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

