PRINT 'STORED PROCEDURE : dbo.datawarehouse_gpocost_sect'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_gpocost_sect') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_gpocost_sect
end

GO

create proc dbo.datawarehouse_gpocost_sect
(@ware_bookkey int,@ware_printingkey int,@ware_tentative int,@ware_ds_select int,
@ware_estkey int,@ware_company varchar,@ware_compdesc varchar,
@ware_ccestatus varchar,@ware_dateccefinalized datetime,@ware_logkey int,
@ware_warehousekey int,@ware_system_date datetime)

AS 
	
DECLARE @ware_count int
DECLARE @ware_potype  int
DECLARE @ware_compkey int
DECLARE @ware_finishedgoodind varchar(1)
DECLARE @ware_activegpo varchar(8)  
DECLARE @ware_includecode varchar(8) 
DECLARE @ware_defaultonrep varchar(8) 
DECLARE @ware_externalcode  varchar(100) 
DECLARE @ware_updateoncceind  varchar(1) 
DECLARE @ware_unitcost float
DECLARE @ware_totalcost float
DECLARE @ware_compdesc2 varchar(30) 

DECLARE @c_manualentryind varchar(1)
DECLARE @i_unitcost float
DECLARE @i_totalcost float
DECLARE @c_externalcode varchar(6)
DECLARE @c_costtype varchar(1)
DECLARE @c_cceind varchar(1)
DECLARE @i_internalcode int
DECLARE @c_externaldesc varchar(30)
DECLARE @c_stockind varchar(1)
DECLARE @i_ccestatus3 int
DECLARE @c_includeoncce varchar(1) 
DECLARE @i_editionalloc int
DECLARE @i_plantalloc int
DECLARE @i_estkey int
DECLARE @i_chgcodecode int
DECLARE @c_invoicerecind varchar(1)
DECLARE @c_auditmessage varchar(60)

select @ware_count = 1
select @ware_activegpo = 'false'
select @ware_includecode = 'false' 
select  @ware_defaultonrep = 'false' 

if @ware_ds_select = 11 
  begin
	DECLARE warehousegposect1 INSENSITIVE CURSOR
	  FOR
/*ids_11 po cost always true and allocind = false*/
		SELECT gp.manualentryind,gp.unitcost,gp.totalcost,c.externalcode,
	      	 c.costtype,c.cceind,c.internalcode,c.externaldesc,c.stockind
   			 from gpo g,gpocost gp,gposection gs, cdlist c  
	 			where  g.gpokey = gs.gpokey 
					and gs.gpokey = gp.gpokey
					and gs.sectionkey = gp.sectionkey
					and gp.chgcodecode = c.internalcode
					and g.gpostatus not in ( 'A','V' ) 
					and gs.sectiontype in ( 2,3 )
					and gs.key1 = @ware_bookkey 
					and gs.key2 = @ware_printingkey 
					and c.includeoncce = 'Y'  
	FOR READ ONLY
	OPEN warehousegposect1

	FETCH NEXT FROM warehousegposect1
		INTO  @c_manualentryind,@i_unitcost,@i_totalcost,@c_externalcode,
		@c_costtype,@c_cceind,@i_internalcode,@c_externaldesc,@c_stockind

	select @i_ccestatus3 = @@FETCH_STATUS

	if @i_ccestatus3 <> 0 /** NO gposect **/
	    begin
		close warehousegposect1
		deallocate warehousegposect1

		RETURN
	   end

	while (@i_ccestatus3 <>-1 )
	   begin

		IF (@i_ccestatus3 <>-2)
		  begin
			if @c_manualentryind is null
			  begin
				select @c_manualentryind = ''
			  end
			if @c_externaldesc is null
			  begin
				select @c_externaldesc = ''
			  end 
			if  @i_unitcost is null
			  begin
				select @i_unitcost = 0
			  end
			if  @i_totalcost is null
			  begin
				select @i_totalcost = 0
			  end
			if @c_externalcode is null
			   begin
				select @c_externalcode = ''
			  end 
			if @c_costtype is null
			  begin
				select @c_costtype  = ''
			  end
			if @c_cceind is null
			  begin
				select @c_cceind  = '' 
	 		 end	
			if @i_internalcode is null
			  begin
				select @i_internalcode  = 0
			  end
			if @c_externaldesc is null
	 		 begin
				select  @c_externaldesc = ''
	  		end
			if @c_stockind is null
			  begin
				select @c_stockind = ''
			  end

			if @ware_tentative = 0  
			  begin
				select @i_unitcost  = 0  
			  end
			else
			  begin
				select @i_unitcost =  round(@i_totalcost/@ware_tentative,4)
		 	  end

			if @c_costtype = 'E' 
			  begin
				if @ware_tentative = 0 
				  begin
					select @i_unitcost = 0
				  end	
				else
				  begin
					select @i_unitcost =round((@i_totalcost/@ware_tentative),4)
	 			  end 

				select @ware_count = 0
				select @ware_count = count(*) 
					from whfinalcostest
					where bookkey= @ware_bookkey
						and printingkey = @ware_printingkey
						and chargecodekey = @i_internalcode
				if  @ware_count >0 
				  begin
					select @ware_unitcost = unitcost ,@ware_totalcost= totalcost
							from whfinalcostest
							where bookkey= @ware_bookkey
								and printingkey = @ware_printingkey
								and chargecodekey = @i_internalcode
					if @ware_unitcost  is null
					  begin
						select @ware_unitcost = 0 
					  end 
					if @ware_totalcost  is null
					  begin
						select @ware_totalcost = 0 
					  end 

					if @ware_unitcost > 0 
					   begin	
BEGIN tran	
						update whfinalcostest
							set unitcost = round((@i_unitcost  + @ware_unitcost),4),
								totalcost = round((@i_totalcost + @ware_totalcost),2)
									where bookkey= @ware_bookkey
										and printingkey = @ware_printingkey
										and chargecodekey = @i_internalcode
commit tran
					  end
					else
					  begin
BEGIN tran
						update whfinalcostest
							set unitcost = round(@i_unitcost,4),
								totalcost = round(@i_totalcost,2)
								where bookkey= @ware_bookkey
									and printingkey = @ware_printingkey
									and chargecodekey = @i_internalcode
commit tran
					  end 
					end
				else
				  begin
					if @ware_company = 'CONSUMER' 
					  begin
						select @ware_externalcode =substring(@c_externalcode,(datalength(@c_externalcode)-2),3)
					  end
					else
					  begin
						select @ware_externalcode = @c_externalcode
					  end
					select @ware_count =0
					select @ware_count  = count(*)
						from comptype c, cdlist cd
						where cd.compkey=c.compkey
							and cd.internalcode  = @i_internalcode
					if  @ware_count >0 
					  begin
						select  @ware_compdesc2  = compdesc
							from comptype c, cdlist cd
								where cd.compkey=c.compkey
									and cd.internalcode  = @i_internalcode
					  end
				BEGIN tran
					insert into whfinalcostest
						(bookkey,printingkey,chargecodekey,chargecode,comptype,   
	    					costtype,unitcost,totalcost,ccestatus,datefinalized,lastuserid,lastmaintdate)  
					VALUES (@ware_bookkey,@ware_printingkey,@i_internalcode,
						(@ware_externalcode + '/' + @c_externaldesc),
						@ware_compdesc2,'E',round(@i_unitcost,4),round(@i_totalcost,2),
						@ware_ccestatus,@ware_dateccefinalized,'WARE_STORED_PROC', @ware_system_date)
commit tran
				end
			end
		else
		  begin
/* plant stuff*/
			if @ware_tentative = 0 
			  begin
				select @i_unitcost = 0
			  end
			else
			  begin
				select @i_unitcost = round((@i_totalcost/@ware_tentative),4)
			  end
			select @ware_count = 0
			select @ware_count = count(*)  
				from whfinalcostest
					where bookkey= @ware_bookkey
						and printingkey = @ware_printingkey
						and chargecodekey = @i_internalcode
			if @ware_count >0
			  begin
				select @ware_unitcost = unitcost,@ware_totalcost = totalcost 
						from whfinalcostest
							where bookkey= @ware_bookkey
								and printingkey = @ware_printingkey
								and chargecodekey = @i_internalcode
				if @ware_unitcost  is null
				  begin
					select @ware_unitcost = 0 
				  end 
				if @ware_totalcost  is null
				  begin
					select @ware_totalcost = 0 
				  end 
				if @ware_unitcost > 0 
				  begin
BEGIN tran
					update whfinalcostest
						set totalcost = round(@i_totalcost + @ware_totalcost,2),
							unitcost = round(@i_unitcost + @ware_unitcost,4)
								where bookkey= @ware_bookkey
									and printingkey = @ware_printingkey
									and chargecodekey = @i_internalcode
commit tran
				  end
				else
				    begin
BEGIN tran
						update whfinalcostest
							set totalcost = round(@i_totalcost,2),
								unitcost = round(@i_unitcost,4)
									where bookkey= @ware_bookkey
										and printingkey = @ware_printingkey
										and chargecodekey = @i_internalcode
commit tran
				   end
			  end
		    else
			begin
				if @ware_company = 'CONSUMER' 
				  begin
					select @ware_externalcode =substring(@c_externalcode,(datalength(@c_externalcode)-2),3)
				  end
				else
				  begin
					select @ware_externalcode = @c_externalcode
				  end

				select @ware_count = 0
				select  @ware_count  = count(*)
					from comptype c, cdlist cd
						where cd.compkey=c.compkey
							and cd.internalcode  = @i_internalcode
				if @ware_count >0 
				  begin
					select  @ware_compdesc2 = compdesc
						from comptype c, cdlist cd
							where cd.compkey=c.compkey
								and cd.internalcode  = @i_internalcode
				  end
BEGIN tran
				insert into whfinalcostest
					(bookkey,printingkey,chargecodekey,chargecode,comptype,   
	    				costtype,totalcost,unitcost,ccestatus,datefinalized,lastuserid,lastmaintdate)  
				VALUES (@ware_bookkey,@ware_printingkey,@i_internalcode,
					(@ware_externalcode + '/' +  @c_externaldesc),
					@ware_compdesc2,'E',round(@i_totalcost,2),round(@i_unitcost,4),
					@ware_ccestatus,@ware_dateccefinalized,'WARE_STORED_PROC', @ware_system_date)
commit tran
		    end
	  end	
	
  end /*<>2*/

   FETCH NEXT FROM warehousegposect1
	INTO  @c_manualentryind,@i_unitcost,@i_totalcost,@c_externalcode,
	@c_costtype,@c_cceind,@i_internalcode,@c_externaldesc,@c_stockind

	select @i_ccestatus3 = @@FETCH_STATUS
end

close warehousegposect1
deallocate warehousegposect1

end
if  @ware_ds_select = 12 
  begin
	DECLARE warehousegposect2 INSENSITIVE CURSOR
	  FOR
/*ids_12 po cost always true and allocind = false*/
		SELECT gp.manualentryind,gp.unitcost,gp.totalcost,c.externalcode,  
	  	     c.costtype,c.cceind,c.internalcode,c.externaldesc,c.stockind,includeoncce
   				 from gpo g,gpocost gp,gposubsection gs,   
         				cdlist c  
	 				where  g.gpokey = gs.gpokey 
	 					and gs.gpokey = gp.gpokey
						and gs.subsectionkey = gp.subsectionkey
						and gp.chgcodecode = c.internalcode
						and g.gpostatus not in ( 'A','V' ) 
						and gs.subsectiontype in ( 2,3 )
						and gs.key1 = @ware_bookkey 
						and gs.key2 = @ware_printingkey 
						and c.includeoncce = 'Y'   

	 FOR READ ONLY
	OPEN warehousegposect2

	FETCH NEXT FROM warehousegposect2
		INTO  @c_manualentryind,@i_unitcost,@i_totalcost,@c_externalcode,
		@c_costtype,@c_cceind,@i_internalcode,@c_externaldesc,@c_stockind,@c_includeoncce

	select @i_ccestatus3 = @@FETCH_STATUS

	if @i_ccestatus3 <> 0 /** NO gposect **/
	    begin
		close warehousegposect2
		deallocate warehousegposect2

		RETURN
	   end

	while (@i_ccestatus3 <>-1 )
	   begin

		IF (@i_ccestatus3 <>-2)
		  begin
			if @c_manualentryind is null
			  begin
				select @c_manualentryind = ''
			  end
			if @c_externaldesc is null
			  begin
				select @c_externaldesc = ''
			  end 
			if  @i_unitcost is null
			  begin
				select @i_unitcost = 0
			  end
			if  @i_totalcost is null
			  begin
				select @i_totalcost = 0
			  end
			if @c_externalcode is null
			   begin
				select @c_externalcode = ''
			  end 
			if @c_costtype is null
			  begin
				select @c_costtype  = ''
			  end
			if @c_cceind is null
			  begin
				select @c_cceind  = '' 
	 		 end	
			if @i_internalcode is null
			  begin
				select @i_internalcode  = 0
			  end
			if @c_externaldesc is null
	 		 begin
				select  @c_externaldesc = ''
	  		end
			if @c_stockind is null
			  begin
				select @c_stockind = ''
			  end
			if @c_includeoncce is null
			  begin
				select @c_includeoncce = ''
			  end

			if @ware_tentative = 0  
			  begin
				select @i_unitcost  = 0  
			  end
			else
			  begin
				select @i_unitcost =  round(@i_totalcost/@ware_tentative,4)
		 	  end
	
			if @c_costtype = 'E' 
			  begin
				if @ware_tentative = 0 
				  begin
					select @i_unitcost = 0
				  end	
				else
				  begin
					select @i_unitcost =round((@i_totalcost/@ware_tentative),4)
	 			  end 

				select @ware_count = 0
				select @ware_count = count(*) 
					from whfinalcostest
						where bookkey= @ware_bookkey
							and printingkey = @ware_printingkey
							and chargecodekey = @i_internalcode
				if @ware_count >0 
				  begin
					select @ware_unitcost = unitcost, @ware_totalcost = totalcost 						from whfinalcostest
							where bookkey= @ware_bookkey
								and printingkey = @ware_printingkey
								and chargecodekey = @i_internalcode
					if @ware_unitcost  is null
					  begin
						select @ware_unitcost = 0 
					  end 
					if @ware_totalcost  is null
					  begin
						select @ware_totalcost = 0 
					  end 
					if @ware_unitcost > 0 
					  begin
BEGIN tran
						update whfinalcostest
						set unitcost = @i_unitcost + @ware_unitcost,
							totalcost = @i_totalcost + @ware_totalcost
								where bookkey= @ware_bookkey
								and printingkey = @ware_printingkey
								and chargecodekey = @i_internalcode
commit tran
					end
				   else
				     begin
BEGIN tran
						update whfinalcostest
							set unitcost = @i_unitcost,
								totalcost = @i_totalcost
								where bookkey= @ware_bookkey
									and printingkey = @ware_printingkey
									and chargecodekey = @i_internalcode
commit tran
				  end
		  end
		else
		  begin
			if @ware_company = 'CONSUMER' 
			  begin
				select @ware_externalcode =substring(@c_externalcode,(datalength(@c_externalcode)-2),3)
			  end
			else
			  begin
				select @ware_externalcode = @c_externalcode
			end
				
			select @ware_count = 0
			select @ware_count  = count(*)
				from comptype c, cdlist cd
					where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
			if @ware_count >0 
			  begin
				select @ware_compdesc2 = compdesc
					from comptype c, cdlist cd
						where cd.compkey=c.compkey
							and cd.internalcode  = @i_internalcode
			   end
BEGIN tran
			insert into whfinalcostest
				(bookkey,printingkey,chargecodekey,chargecode,comptype,   
	    			costtype,unitcost,totalcost,ccestatus,datefinalized,lastuserid,lastmaintdate)  
			VALUES (@ware_bookkey,@ware_printingkey,@i_internalcode,
				(@ware_externalcode + '/' + @c_externaldesc),
				@ware_compdesc2,'E',round(@i_unitcost,4),round(@i_totalcost,2),
				@ware_ccestatus,@ware_dateccefinalized,'WARE_STORED_PROC', @ware_system_date)
commit tran
		  end
	   end
	else
        begin
/* plant stuff*/
		if @ware_tentative = 0 
		  begin
			select @i_unitcost = 0
		  end
		else
		  begin
			select @i_unitcost = round((@i_totalcost/@ware_tentative),4)
		  end
		select @ware_count = 0
		select @ware_count  = count(*) 
				from whfinalcostest
					where bookkey= @ware_bookkey
						and printingkey = @ware_printingkey
						and chargecodekey = @i_internalcode
		if @ware_count >0 
		  begin
			select @ware_unitcost = unitcost, @ware_totalcost = totalcost
					from whfinalcostest
						where bookkey= @ware_bookkey
							and printingkey = @ware_printingkey
							and chargecodekey = @i_internalcode
			if @ware_unitcost  is null
			  begin
				select @ware_unitcost = 0 
			  end 
			if @ware_totalcost  is null
			  begin
				select @ware_totalcost = 0 
			  end 

			if @ware_unitcost > 0 
			  begin
BEGIN tran
				update whfinalcostest
					set totalcost = round(@i_totalcost + @ware_totalcost,2),
						unitcost = round(@i_unitcost + @ware_unitcost,4)
							where bookkey= @ware_bookkey
								and printingkey = @ware_printingkey
								and chargecodekey = @i_internalcode
commit tran
		  	  end
	 	    else
		       begin
BEGIN tran
				update whfinalcostest
					set totalcost = round(@i_totalcost,2),
						unitcost = round(@i_unitcost,4)
							where bookkey= @ware_bookkey
							and printingkey = @ware_printingkey
							and chargecodekey = @i_internalcode
commit tran
		       end
		  end
		else
		  begin
			if @ware_company = 'CONSUMER' 
			  begin
				select @ware_externalcode =substring(@c_externalcode,(datalength(@c_externalcode)-2),3)
			  end
			else
			  begin
				select @ware_externalcode = @c_externalcode
			  end

			select @ware_count = 0
			select @ware_count  = count(*)
				from comptype c, cdlist cd
					where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
			if  @ware_count >0 
			  begin
				select @ware_compdesc2 = compdesc
					from comptype c, cdlist cd
					where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
			  end
BEGIN tran
			insert into whfinalcostest
				(bookkey,printingkey,chargecodekey,chargecode,comptype,   
	    			costtype,totalcost,unitcost,ccestatus,datefinalized,lastuserid,lastmaintdate)  
			VALUES (@ware_bookkey,@ware_printingkey,@i_internalcode,
				(@ware_externalcode + '/' + @c_externaldesc),
				@ware_compdesc2,'E',round(@i_totalcost,2),round(@i_unitcost,4),
				@ware_ccestatus,@ware_dateccefinalized,'WARE_STORED_PROC', @ware_system_date)
commit tran
		end
	end	
  end /*<>*/
 FETCH NEXT FROM warehousegposect2
	INTO  @c_manualentryind,@i_unitcost,@i_totalcost,@c_externalcode,
	@c_costtype,@c_cceind,@i_internalcode,@c_externaldesc,@c_stockind,@c_includeoncce

	select @i_ccestatus3 = @@FETCH_STATUS
end
close warehousegposect2
deallocate warehousegposect2
end

if  @ware_ds_select = 13 
  begin
	DECLARE warehousegposect3 INSENSITIVE CURSOR
	  FOR
/*ids_13 po cost always true and allocind = true*/
	SELECT gp.manualentryind,gp.unitcost,gp.totalcost,c.externalcode,  
	       c.costtype,c.cceind,c.internalcode,c.externaldesc,c.stockind, 
		c.includeoncce,gs.editionalloc,gs.plantalloc
   			 from gpo g,gpocost gp,gposubsection gs,   
         			cdlist c  
	 			where  g.gpokey = gs.gpokey 
	 				and gs.gpokey = gp.gpokey
					and gs.sectionkey = gp.sectionkey
					and gp.chgcodecode = c.internalcode
					and (gp.subsectionkey is null OR  
				      gp.subsectionkey = 0) 
					and g.gpostatus not in ( 'A','V' ) 
					and gs.subsectiontype in ( 2,3 )
					and gs.key1 = @ware_bookkey 
					and gs.key2 = @ware_printingkey 
					and c.includeoncce = 'Y'   

 FOR READ ONLY
	OPEN warehousegposect3

	FETCH NEXT FROM warehousegposect3
		INTO  @c_manualentryind,@i_unitcost,@i_totalcost,@c_externalcode,
		@c_costtype,@c_cceind,@i_internalcode,@c_externaldesc,@c_stockind,@c_includeoncce,
		@i_editionalloc,@i_plantalloc

	select @i_ccestatus3 = @@FETCH_STATUS

	if @i_ccestatus3 <> 0 /** NO gposect **/
	    begin
		close warehousegposect3
		deallocate warehousegposect3

		RETURN
	   end

	while (@i_ccestatus3 <>-1 )
	   begin

		IF (@i_ccestatus3 <>-2)
		  begin
			if @c_manualentryind is null
			  begin
				select @c_manualentryind = ''
			  end
			if @c_externaldesc is null
			  begin
				select @c_externaldesc = ''
			  end 
			if  @i_unitcost is null
			  begin
				select @i_unitcost = 0
			  end
			if  @i_totalcost is null
			  begin
				select @i_totalcost = 0
			  end
			if @c_externalcode is null
			   begin
				select @c_externalcode = ''
			  end 
			if @c_costtype is null
			  begin
				select @c_costtype  = ''
			  end
			if @c_cceind is null
			  begin
				select @c_cceind  = '' 
	 		 end	
			if @i_internalcode is null
			  begin
				select @i_internalcode  = 0
			  end
			if @c_externaldesc is null
	 		 begin
				select  @c_externaldesc = ''
	  		end
			if @c_stockind is null
			  begin
				select @c_stockind = ''
			  end
			if @c_includeoncce is null
			  begin
				select @c_includeoncce = ''
			  end
			if @i_editionalloc is null
			  begin
				select @i_editionalloc = 0
			  end
			if @i_plantalloc is null
			  begin
				select @i_plantalloc = 0
			  end

			if @ware_tentative = 0  
			  begin
				select @i_unitcost  = 0  
			  end
			else
			  begin
				select @i_unitcost =  round(@i_totalcost/@ware_tentative,4)
		 	  end
	
			if @c_costtype = 'E' 
			  begin
				if @ware_tentative = 0 
				  begin
					select @i_unitcost = 0
				  end	
				else
				  begin
					select @i_unitcost = round(((@i_totalcost/@ware_tentative)* @i_editionalloc)/100,4)
	 			  end 

				select @ware_count = 0
				select @ware_count = count(*) 
					from whfinalcostest
					where bookkey= @ware_bookkey
						and printingkey = @ware_printingkey
						and chargecodekey = @i_internalcode
				if @ware_count >0 
				  begin
					select @ware_unitcost =unitcost ,@ware_totalcost = totalcost
						from whfinalcostest
						where bookkey= @ware_bookkey
							and printingkey = @ware_printingkey
							and chargecodekey = @i_internalcode
					if @ware_unitcost  is null
					  begin
						select @ware_unitcost = 0 
					  end 
					if @ware_totalcost  is null
					  begin
						select @ware_totalcost = 0 
					  end 
					if @ware_unitcost > 0 
					  begin
BEGIN tran
						update whfinalcostest
							set unitcost = @i_unitcost + @ware_unitcost,
								totalcost = @i_totalcost + @ware_totalcost
									where bookkey= @ware_bookkey
										and printingkey = @ware_printingkey
										and chargecodekey = @i_internalcode
commit tran
					end
				    else
					begin
BEGIN tran
						update whfinalcostest
							set unitcost = round(@i_unitcost,4),
								totalcost = round(@i_totalcost,2)
								where bookkey= @ware_bookkey
									and printingkey = @ware_printingkey
									and chargecodekey = @i_internalcode
commit tran
					end
			  end
			else
			  begin
				if @ware_company = 'CONSUMER' 
				  begin
					select @ware_externalcode =substring(@c_externalcode,(datalength(@c_externalcode)-2),3)
				  end
			     else
				  begin
					select @ware_externalcode = @c_externalcode
				  end

			  	select @ware_count = 0
		 		  select @ware_count  = count(*)
					from comptype c, cdlist cd
					where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
				  if  @ware_count >0 	
				     begin
					select @ware_compdesc2 = compdesc
						from comptype c, cdlist cd
						where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
				     end
BEGIN tran
				  insert into whfinalcostest
					(bookkey,printingkey,chargecodekey,chargecode,comptype,   
	    				costtype,totalcost,unitcost,ccestatus,datefinalized,lastuserid,lastmaintdate)  
				  VALUES (@ware_bookkey,@ware_printingkey,@i_internalcode,
					(@ware_externalcode + '/' + @c_externaldesc),
					@ware_compdesc2,'E',round(@i_totalcost,2),round(@i_unitcost,4),
					@ware_ccestatus,@ware_dateccefinalized,'WARE_STORED_PROC', @ware_system_date)
commit tran
			end
	      end
	else
	  begin
/* plant stuff*/
		if @ware_tentative = 0 
		  begin
			select @i_unitcost = 0
		  end
		else 
		  begin
			select @i_unitcost = round(((@i_totalcost/@ware_tentative)* @i_plantalloc)/100,4)
		  end
		select @ware_count = 0
		select @ware_count = count(*) 
				from whfinalcostest
					where bookkey= @ware_bookkey
						and printingkey = @ware_printingkey
						and chargecodekey = @i_internalcode
		if @ware_count >0 
		  begin
			select @ware_unitcost = unitcost,@ware_totalcost = totalcost 
					from whfinalcostest
						where bookkey= @ware_bookkey
							and printingkey = @ware_printingkey
							and chargecodekey = @i_internalcode
			if @ware_unitcost  is null
			  begin
				select @ware_unitcost = 0 
			  end 
			if @ware_totalcost  is null
			  begin
				select @ware_totalcost = 0 
			  end 

			if @ware_unitcost > 0 
			  begin
BEGIN tran
				update whfinalcostest
					set totalcost = round((@i_totalcost + @ware_totalcost),2),
						unitcost = round((@i_unitcost + @ware_unitcost),4)
						where bookkey= @ware_bookkey
							and printingkey = @ware_printingkey
							and chargecodekey = @i_internalcode
commit tran
			  end
			else
			  begin
BEGIN tran
				update whfinalcostest
					set unitcost = round(@i_unitcost,4),
						totalcost = round(@i_totalcost,2)
						where bookkey= @ware_bookkey
							and printingkey = @ware_printingkey
							and chargecodekey = @i_internalcode
commit tran
				end
		  end
		else
		  begin
			if @ware_company = 'CONSUMER' 
			  begin
				select @ware_externalcode =substring(@c_externalcode,(datalength(@c_externalcode)-2),3)
			  end
			else
			  begin
				select @ware_externalcode = @c_externalcode
			 end
			select @ware_count = 0
			select @ware_count  = count(*)
				from comptype c, cdlist cd
					where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
			if @ware_count >0 
			  begin
				select @ware_compdesc2  = compdesc
						from comptype c, cdlist cd
					where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
			 end
BEGIN tran
			insert into whfinalcostest
				(bookkey,printingkey,chargecodekey,chargecode,comptype,   
	    			costtype,totalcost,unitcost,ccestatus,datefinalized,lastuserid,lastmaintdate)  
			VALUES (@ware_bookkey,@ware_printingkey,@i_internalcode,
				(@ware_externalcode + '/' + @c_externaldesc),
				@ware_compdesc2,'E',round(@i_totalcost,2),round(@i_unitcost,4),
				@ware_ccestatus,@ware_dateccefinalized,'WARE_STORED_PROC', @ware_system_date) 
commit tran
		end
	  end	
	end /*<>*/
	FETCH NEXT FROM warehousegposect3
		INTO  @c_manualentryind,@i_unitcost,@i_totalcost,@c_externalcode,
		@c_costtype,@c_cceind,@i_internalcode,@c_externaldesc,@c_stockind,@c_includeoncce,
		@i_editionalloc,@i_plantalloc

	select @i_ccestatus3 = @@FETCH_STATUS
end
close warehousegposect3
deallocate warehousegposect3
end 

if  @ware_ds_select <> 11 and  @ware_ds_select <> 12 and  @ware_ds_select <> 13  
  begin
	DECLARE warehousegposect4 INSENSITIVE CURSOR
	  FOR
/*ids_3 po cost always false and allocind = false*/
		SELECT  c.externalcode,c.costtype,c.cceind,e.unitcost,
			e.totalcost,e.manualentryind,e.estkey,e.chgcodecode,      	   
		      e.invoicerecind,c.internalcode,c.stockind,e.auditmessage,
			c.externaldesc,c.includeoncce
		  	 from cdlist c, estnonpocost e   
         			where  e.chgcodecode = c.internalcode 
	 				and e.estkey = @ware_estkey
					and c.includeoncce='Y'  

	FOR READ ONLY
	OPEN warehousegposect4

	FETCH NEXT FROM warehousegposect4
		INTO  @c_externalcode,@c_costtype,@c_cceind,@i_unitcost,@i_totalcost,@c_manualentryind,
		@i_estkey,@i_chgcodecode,@c_invoicerecind,@i_internalcode,
		@c_stockind,@c_auditmessage,@c_externaldesc,@c_includeoncce

	select @i_ccestatus3 = @@FETCH_STATUS

	if @i_ccestatus3 <> 0 /** NO gposect **/
	    begin
		close warehousegposect4
		deallocate warehousegposect4

		RETURN
	   end

	while (@i_ccestatus3 <>-1 )
	   begin

		IF (@i_ccestatus3 <>-2)
		  begin
			if @c_manualentryind is null
			  begin
				select @c_manualentryind = ''
			  end
			if @c_externaldesc is null
			  begin
				select @c_externaldesc = ''
			  end 
			if  @i_unitcost is null
			  begin
				select @i_unitcost = 0
			  end
			if  @i_totalcost is null
			  begin
				select @i_totalcost = 0
			  end
			if @c_costtype is null
			  begin
				select @c_costtype  = ''
			  end
			if @c_cceind is null
			  begin
				select @c_cceind  = '' 
	 		 end	
			if @i_internalcode is null
			  begin
				select @i_internalcode  = 0
			  end
			if @c_externaldesc is null
	 		 begin
				select  @c_externaldesc = ''
	  		end
			if @c_stockind is null
			  begin
				select @c_stockind = ''
			  end
			if @c_auditmessage is null
			  begin
				select @c_auditmessage  = ''
			  end
			if @c_includeoncce is null
			  begin
				select @c_includeoncce  = ''
			  end
			if @ware_tentative = 0  
			  begin
				select @i_unitcost  = 0  
			  end
			else
			  begin
				select @i_unitcost =  round(@i_totalcost/@ware_tentative,4)
		 	  end

			if @c_costtype = 'E' 
			  begin
				if @ware_tentative = 0 
				  begin
					select @i_unitcost =0
				  end
				else
				  begin
					select @i_unitcost =round((@i_totalcost/@ware_tentative),4)
				end
				select @ware_count = 0
				select @ware_count  = count(*) 
					from whfinalcostest
						where bookkey= @ware_bookkey
							and printingkey = @ware_printingkey
							and chargecodekey = @i_internalcode
				if @ware_count >0 
				  begin
					select @ware_unitcost = unitcost,@ware_totalcost=totalcost
							from whfinalcostest
								where bookkey= @ware_bookkey
									and printingkey = @ware_printingkey
									and chargecodekey = @i_internalcode
		
					if @ware_unitcost  is null
					  begin
						select @ware_unitcost = 0 
					  end 
					if @ware_totalcost  is null
					  begin
						select @ware_totalcost = 0 
					  end 

					if @ware_unitcost > 0 
					  begin
BEGIN tran
						update whfinalcostest
							set unitcost = round((@i_unitcost +@ware_unitcost),4),
								totalcost = round((@i_totalcost + @ware_totalcost),2)
								where bookkey= @ware_bookkey
									and printingkey = @ware_printingkey
									and chargecodekey = @i_internalcode
commit tran
					  end
					else
					  begin
BEGIN tran
						update whfinalcostest
							set unitcost = round(@i_unitcost,4),
								totalcost = round(@i_totalcost,2)
								where bookkey= @ware_bookkey
									and printingkey = @ware_printingkey
									and chargecodekey = @i_internalcode
commit tran
					  end
		  		end
			else
		 	 begin
			if @ware_company = 'CONSUMER' 
			  begin
				select @ware_externalcode =substring(@c_externalcode,(datalength(@c_externalcode)-2),3)
			  end
			else
			  begin
				select @ware_externalcode = @c_externalcode
			 end

			select @ware_count =0
			select  @ware_count = count(*)
				from comptype c, cdlist cd
					where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
			if @ware_count >0 
			  begin
				select  @ware_compdesc2 = compdesc 
					from comptype c, cdlist cd
					where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
			  end
BEGIN tran
			insert into whfinalcostest
				(bookkey,printingkey,chargecodekey,chargecode,comptype,   
	    			costtype,totalcost,unitcost,ccestatus,datefinalized,lastuserid,lastmaintdate)  
			VALUES (@ware_bookkey,@ware_printingkey,@i_internalcode,
				(@ware_externalcode + '/'+ @c_externaldesc),
				@ware_compdesc2,'E',round(@i_totalcost,2),round(@i_unitcost,4),
				@ware_ccestatus,@ware_dateccefinalized,'WARE_STORED_PROC', @ware_system_date)
commit tran
		end
	  end
	else
	  begin
/* plant stuff*/
		if @ware_tentative = 0 
		  begin
			select @i_unitcost = 0
		  end
		else
		  begin
			select @i_unitcost =round((@i_totalcost/@ware_tentative),4)
		  end
		select @ware_count = 0
		select @ware_count = count(*) 
				from whfinalcostest
					where bookkey= @ware_bookkey
						and printingkey = @ware_printingkey
						and chargecodekey = @i_internalcode
		if @ware_count >0 
		  begin
			select @ware_unitcost = unitcost,@ware_totalcost = totalcost 
					from whfinalcostest
						where bookkey= @ware_bookkey
							and printingkey = @ware_printingkey
							and chargecodekey = @i_internalcode
			if @ware_unitcost  is null
			 begin
				select @ware_unitcost = 0 
			end 
			if @ware_totalcost  is null
			 begin
				select @ware_totalcost = 0 
			end 
			if @ware_unitcost > 0 
			  begin
BEGIN tran
				update whfinalcostest
					set totalcost = round(@i_totalcost +@ware_totalcost,2),
						unitcost = round(@i_unitcost +@ware_unitcost,4)
							where bookkey= @ware_bookkey
								and printingkey = @ware_printingkey
								and chargecodekey = @i_internalcode
commit tran
			  end
			else
			  begin
BEGIN tran
				update whfinalcostest
					set totalcost = round(@i_totalcost,2),
						unitcost = round(@i_unitcost,4)	
						where bookkey= @ware_bookkey
							and printingkey = @ware_printingkey
							and chargecodekey = @i_internalcode
commit tran
			  end
			end
		else
		  begin
			if @ware_company = 'CONSUMER'
			  begin
				select @ware_externalcode =substring(@c_externalcode,(datalength(@c_externalcode)-2),3)
			  end
			else
			  begin
				select @ware_externalcode = @c_externalcode
			  end

			select @ware_count = 0
			select @ware_count  = count(*)
				from comptype c, cdlist cd
					where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
			if  @ware_count >0 
			  begin
				select @ware_compdesc2 = compdesc
					from comptype c, cdlist cd
					where cd.compkey=c.compkey
						and cd.internalcode  = @i_internalcode
			  end
BEGIN tran
			insert into whfinalcostest
				(bookkey,printingkey,chargecodekey,chargecode,comptype,   
	    			costtype,totalcost,unitcost,ccestatus,datefinalized,lastuserid,lastmaintdate)  
			VALUES (@ware_bookkey,@ware_printingkey,@i_internalcode,
				(@ware_externalcode + '/' + @c_externaldesc),
				@ware_compdesc2,'E',round(@i_totalcost,2),round(@i_unitcost,4),
				@ware_ccestatus,@ware_dateccefinalized,'WARE_STORED_PROC', @ware_system_date) 
commit tran
		end
	end	
   end /*<>2*/
   FETCH NEXT FROM warehousegposect4
	INTO  @c_externalcode,@c_costtype,@c_cceind,@i_unitcost,@i_totalcost,@c_manualentryind,
	@i_estkey,@i_chgcodecode,@c_invoicerecind,@i_internalcode,
	@c_stockind,@c_auditmessage,@c_externaldesc,@c_includeoncce

	select @i_ccestatus3 = @@FETCH_STATUS
end
close warehousegposect4
deallocate warehousegposect4

end


GO