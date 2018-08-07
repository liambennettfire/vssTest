PRINT 'STORED PROCEDURE : dbo.datawarehouse_aopo'
GO


if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_aopo') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_aopo 
end

GO

create proc dbo.datawarehouse_aopo
@ware_bookkey int,@ware_printingkey int,
@ware_compkey int, @ware_fgind varchar,@ware_tentative int,
@ware_logkey int, @ware_warehousekey int, @ware_system_date datetime 
AS 

DECLARE @c_dummy varchar (25)
DECLARE @ware_count int
DECLARE @ware_ponumber varchar (80)
DECLARE @ware_compdesc varchar (10)
DECLARE @ware_vendorname varchar (80)
DECLARE @ware_vendorshort varchar (8)
DECLARE @ware_proof_long varchar (40)
DECLARE @i_gponumber int
DECLARE @i_gpochangenum int
DECLARE @d_gpodate datetime
DECLARE @c_gpostatus  varchar (1)
DECLARE @d_daterequired datetime
DECLARE @i_vendorkey int
DECLARE @i_quantity int
DECLARE @i_key1 int
DECLARE @i_key2 int
DECLARE @i_key3 int
DECLARE @i_prooftype int
DECLARE @i_aopostatus int

DECLARE warehouseaopo INSENSITIVE CURSOR
FOR
	select g.gponumber, g.gpochangenum,g.gpodate,g.gpostatus,
         	g.daterequired,g.vendorkey,gps.quantity,gs.key1,
                gs.key2,gs.key3,gps.prooftype
    			from gpo g,gposection gs,gposectionsource gps
			   where  g.gpokey = gs.gpokey and
				gs.gpokey = gps.gpokey
				and gs.sectionkey = gps.sectionkey
				and gs.key1 = @ware_bookkey
				and  gs.key2 = @ware_printingkey
				and  gs.key3 = @ware_compkey
				and  g.gpostatus in ('P','F','I')
				and gps.sourcecode = 1 
FOR READ ONLY

OPEN warehouseaopo

FETCH NEXT FROM warehouseaopo
INTO @i_gponumber,@i_gpochangenum,@d_gpodate,
	@c_gpostatus,@d_daterequired,@i_vendorkey,@i_quantity,
	@i_key1,@i_key2,@i_key3,@i_prooftype

select @i_aopostatus = @@FETCH_STATUS

if @i_aopostatus <> 0 /** NO AOPO **/
    begin
	select @c_dummy=''
	RETURN
   end
 while (@i_aopostatus<>-1 )
   begin

	IF (@i_aopostatus<>-2)
	  begin
	BEGIN tran 

		if @i_gponumber is null
	 	  begin
			select @i_gponumber = 0
		  end
		if @i_gpochangenum is null
  		  begin
			select @i_gpochangenum = 0
		  end
		if @d_gpodate is null
		  begin
			select @d_gpodate = ''
		  end
		if @c_gpostatus is null
	   	  begin
			select @c_gpostatus = ''
		  end 
		if @d_daterequired is null
		  begin
			select @d_daterequired =''
		  end
		if @i_vendorkey is null
		  begin
			select @i_vendorkey = 0
		  end 
		if @i_quantity is null
 		   begin
			select @i_quantity = 0
		    end	
		if @i_key1 is null
 		   begin
			select @i_key1 = 0
		    end	
		if @i_key2 is null
 		   begin
			select @i_key2 = 0
		    end	
		if @i_key3 is null
 		   begin
			select @i_key3 = 0
		    end	
		if @i_prooftype is null
 		   begin
			select @i_prooftype = 0
		    end	

		select @ware_ponumber = rtrim(@i_gponumber)  + convert(varchar, @i_gpochangenum)
		select @ware_vendorname  = ''
		select @ware_vendorshort = ''
		select @ware_count = 0
		select @ware_count = count(*)
			from vendor
				where vendorkey = @i_vendorkey

		if  @ware_count > 0 
		  begin
			select @ware_vendorname = name, @ware_vendorshort= shortdesc
				from vendor
					where vendorkey = @i_vendorkey
		  end
		else
		  begin
		    select @ware_compdesc =
			case @ware_compkey
			  when  1 then 'Misc'
			  when  2 then 'Bind'
			  when  3 then 'Print'
			  when  4 then 'Cover'
			  when  5 then 'Jacket'
			end
	
			INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
	         		errorseverity, errorfunction,lastuserid, lastmaintdate)
			 VALUES (convert(varchar, @ware_logkey)  ,convert(varchar,@ware_warehousekey),
				'No vendorkey for compkey on printing',
				('Warning/data error bookkey ' + convert(varchar,@ware_bookkey) + ' and printingkey ' + convert(varchar,@ware_printingkey) +
				 ' and compkey ' + @ware_compdesc),'Stored procedure datawarehouse_aopo',
				'WARE_STORED_PROC',@ware_system_date);
			RETURN
	 	  end

	if @ware_compkey = 2 or @ware_fgind = 'Y' 
	  begin
		update whprinting
			set bindponumber = @ware_ponumber,
		 	 bindpodate = @d_gpodate,
			 bindpostatus =  @c_gpostatus,
			 finalbindqty = @ware_tentative,
			 bindvendorlong = @ware_vendorname,
		 	 bindvendorshort = @ware_vendorshort
				where bookkey = @ware_bookkey
				and printingkey = @ware_printingkey
	  end
	if @ware_compkey = 3 
	  begin
		if @i_prooftype > 0 
		  begin
			exec @ware_proof_long = gentables_longdesc 22,@i_prooftype
		  end
		else
	        begin
		   select @ware_proof_long  =  ''
		  end

		update whprinting
			set textprooftype = @ware_proof_long,
				printdue =  convert(varchar,@d_daterequired),
				 printponumber = @ware_ponumber,
				 printpodate = @d_gpodate,
			 	 printpostatus = @c_gpostatus,
				 printvendorlong = @ware_vendorname,
				 printvendorshort	= @ware_vendorshort
					where bookkey = @ware_bookkey
						and printingkey = @ware_printingkey
	  end
	if @ware_compkey = 4 
	  begin
		if @i_prooftype > 0 
		  begin
			exec @ware_proof_long  = gentables_longdesc 22,@i_prooftype
		  end
		else
		  begin
			select @ware_proof_long  =  ''
		  end

		update whprinting
			set coverprooftype = @ware_proof_long,
				coverdue =  convert(varchar,@d_daterequired),
				 coverponumber = @ware_ponumber,
			 	 coverpostatus = @c_gpostatus,
				 coverqty = @i_quantity,
				 covervendorlong = @ware_vendorname,
				 covervendorshort	= @ware_vendorshort
					where bookkey = @ware_bookkey
						and printingkey = @ware_printingkey
	 end
	if @ware_compkey = 5 
	  begin
		if @i_prooftype > 0 
		  begin
			exec @ware_proof_long  = gentables_longdesc 22,@i_prooftype
		  end
		else
		  begin
			select @ware_proof_long  =  ''
		  end

		update whprinting
			set jacketprooftype = @ware_proof_long,
			 jacketdue =  convert(varchar,@d_daterequired),
			 jacketponumber = @ware_ponumber,
		 	 jacketpostatus = @c_gpostatus,
			 jacketqty = @i_quantity,
			 jacketvendorlong = @ware_vendorname,
			 jacketvendorshort = @ware_vendorshort
				where bookkey = @ware_bookkey
					and printingkey = @ware_printingkey
	
	   end 
commit tran

	end	/*<>2*/

	FETCH NEXT FROM warehouseaopo
	INTO @i_gponumber,@i_gpochangenum,@d_gpodate,
	@c_gpostatus,@d_daterequired,@i_vendorkey,@i_quantity,
	@i_key1,@i_key2,@i_key3,@i_prooftype

	select @i_aopostatus = @@FETCH_STATUS
end

close warehouseaopo
deallocate warehouseaopo

GO