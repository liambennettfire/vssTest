PRINT 'STORED PROCEDURE : dbo.datawarehouse_po'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_po') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_po
end

GO

create proc dbo.datawarehouse_po
@ware_bookkey int,@ware_printingkey int,
@ware_compkey int, @ware_fgind varchar,@ware_tentative int,
@ware_logkey int, @ware_warehousekey int, @ware_system_date datetime 
AS 

DECLARE @ware_count int
DECLARE @ware_ponumber varchar(80) 
DECLARE @ware_compdesc varchar(10) 
DECLARE @ware_vendorname varchar(80) 
DECLARE @ware_vendorshort varchar(8) 
DECLARE @i_gponumber int
DECLARE @i_gpochangenum int
DECLARE @d_gpodate datetime
DECLARE @c_gpostatus  varchar (1)
DECLARE @d_daterequired datetime
DECLARE @i_vendorkey int
DECLARE @i_quantity int
DECLARE @i_prooftype int
DECLARE @c_potype varchar(1)
DECLARE @c_paperdue varchar(100)
DECLARE @ware_proof_long  varchar(40) 
DECLARE @ware_pochangenum varchar(20) 


DECLARE @i_postatus int

/*12-1-04 CRM 2187: add columns ponumandchangenum and remove changenum from current ponumber columns*/

DECLARE warehousepo INSENSITIVE CURSOR
   FOR
	select c.quantity,c.prooftype,g.gponumber,g.gpochangenum,
         g.gpodate,g.gpostatus,g.potype, g.vendorkey,
         c.paperdue,g.daterequired
		    from component c, compspec cs, gpo g
  			 where  c.bookkey = cs.bookkey
				and c.printingkey = cs.printingkey
				and c.compkey = cs.compkey
				and c.pokey = g.gpokey
				and c.bookkey = @ware_bookkey
				and c.compkey = @ware_compkey
				and c.printingkey = @ware_printingkey
				and g.gpostatus not in ('V','A')
				and c.pokey <> 0
				and cs.compkey in (2,3,4,5)
 FOR READ ONLY

   OPEN  warehousepo

	FETCH NEXT FROM warehousepo
		INTO  @i_quantity,@i_prooftype,@i_gponumber,@i_gpochangenum,
         @d_gpodate,@c_gpostatus,@c_potype, @i_vendorkey,@c_paperdue,@d_daterequired

	select @i_postatus = @@FETCH_STATUS

	 if @i_postatus <> 0 /**NO PO **/
    	  begin
		close warehousepo
		deallocate warehousepo
		RETURN
   	end  

	 while (@i_postatus <>-1 )
	   begin

		IF (@i_postatus <>-2)
		  begin

			if @i_prooftype is null
 			  begin
				select @i_prooftype = 0
			  end
			
			select @ware_ponumber = convert(varchar (10),@i_gponumber) 
			select @ware_pochangenum = ''
			
			if @i_gpochangenum > 0
			  begin
				select  @ware_pochangenum = rtrim(@ware_ponumber) + convert(varchar,@i_gpochangenum)
			  end
			else
			  begin
				select  @ware_pochangenum = rtrim(@ware_ponumber)
			  end
				

			select @ware_vendorname  = ''
			select @ware_vendorshort = ''
			select @ware_count = 0
			select @ware_count= count(*)
				from vendor
					where vendorkey = @i_vendorkey
	
			if  @ware_count > 0 
			  begin
				select @ware_vendorname = name,@ware_vendorshort = shortdesc
					from vendor
						where vendorkey = @i_vendorkey
			  end
			else
			  begin
				if @ware_compkey = 1 	
				  begin
					select @ware_compdesc = 'Misc'
				  end
				if @ware_compkey = 2 
				  begin
					select @ware_compdesc = 'Bind'
				  end
				if @ware_compkey = 3 
				  begin
					select @ware_compdesc = 'Print'
				  end
				if @ware_compkey = 4 
				  begin
					select @ware_compdesc = 'Cover'
				  end
				if @ware_compkey = 5 
				  begin
					select  @ware_compdesc = 'Jacket'
				  end
BEGIN tran
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
	          errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
			'No vendorkey for compkey on printing',
			('Warning/data error bookkey ' + convert(varchar,@ware_bookkey) + ' and printingkey ' +
			 convert(varchar,@ware_printingkey) + ' and compkey ' + @ware_compdesc),
			'Stored procedure datawarehouse_po','WARE_STORED_PROC', @ware_system_date)
commit tran	
		close warehousepo
		deallocate warehousepo

		RETURN
	end 
	if @ware_compkey = 2 
	  begin
BEGIN tran
		update whprinting
			set bindponumber = @ware_ponumber,
		 	 bindpodate = @d_gpodate,
			 bindpostatus =  @c_gpostatus,
			 finalbindqty = @ware_tentative,
			 bindvendorlong = @ware_vendorname,
		 	 bindvendorshort = @ware_vendorshort,
			 bindpochangenum= @ware_pochangenum 
				where bookkey = @ware_bookkey
				and printingkey = @ware_printingkey
commit tran
	  end
	if @ware_compkey = 3 
	  begin
		if @i_prooftype > 0 
		  begin
			exec gentables_longdesc 22,@i_prooftype,@ware_proof_long OUTPUT
		  end
		else
		  begin
			select @ware_proof_long  =  ''
		 end
BEGIN tran
		update whprinting
			set textprooftype = @ware_proof_long,
		 	 paperdue = substring(@c_paperdue,1,80),
			 printdue =  convert(char,@d_daterequired,110),
			 printponumber = @ware_ponumber,
			 printpodate = @d_gpodate,
		 	 printpostatus = @c_gpostatus,
			 printvendorlong = @ware_vendorname,
			 printvendorshort	= @ware_vendorshort,
			 printpochangenum = @ware_pochangenum 
				where bookkey = @ware_bookkey
				and printingkey = @ware_printingkey
commit tran
	  end
	if @ware_compkey = 4 
	  begin
		if @i_prooftype > 0 
		  begin
			exec gentables_longdesc 22,@i_prooftype,@ware_proof_long OUTPUT
		  end
		else
		  begin
			select @ware_proof_long  =  ''
		  end
BEGIN tran
		update whprinting
			set coverprooftype = @ware_proof_long,
			 coverdue =  convert(char,@d_daterequired,110),
			 coverponumber = @ware_ponumber,
		 	 coverpostatus = @c_gpostatus,
			 coverqty = @i_quantity,
			 covervendorlong = @ware_vendorname,
			 covervendorshort	= @ware_vendorshort,
			 coverpochangenum = @ware_pochangenum 
				where bookkey = @ware_bookkey
				and printingkey = @ware_printingkey
commit tran
	  end
	if @ware_compkey = 5 
	  begin
		if @i_prooftype > 0 
		  begin
			exec gentables_longdesc 22,@i_prooftype,@ware_proof_long OUTPUT
		  end
		else
		  begin
			select @ware_proof_long  =  ''
		  end
BEGIN tran
		update whprinting
			set jacketprooftype = @ware_proof_long,
			 jacketdue =  convert(char,@d_daterequired,110),
			 jacketponumber = @ware_ponumber,
		 	 jacketpostatus = @c_gpostatus,
			 jacketqty = @i_quantity,
			 jacketvendorlong = @ware_vendorname,
			 jacketvendorshort = @ware_vendorshort,
			 jackpochangenum = @ware_pochangenum 
				where bookkey = @ware_bookkey
				and printingkey = @ware_printingkey
commit tran
	 end
	

	end /*<>*/

	FETCH NEXT FROM warehousepo
		INTO  @i_quantity,@i_prooftype,@i_gponumber,@i_gpochangenum,
         @d_gpodate,@c_gpostatus,@c_potype, @i_vendorkey,@c_paperdue,@d_daterequired

	select @i_postatus = @@FETCH_STATUS
end

close warehousepo
deallocate warehousepo


GO