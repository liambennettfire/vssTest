PRINT 'STORED PROCEDURE : dbo.datawarehouse_xpo'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_xpo') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_xpo
end

GO

create proc dbo.datawarehouse_xpo
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
DECLARE @d_warehousedate datetime
DECLARE @i_prodcontact int
DECLARE @d_daterequired datetime
DECLARE @i_vendorkey int
DECLARE @i_sectionkey int
DECLARE @i_sectiontype tinyint
DECLARE @i_key1 int
DECLARE @i_key2 int
DECLARE @i_key3 int
DECLARE @i_quantity int
DECLARE @c_description varchar(100)
DECLARE @i_xpostatus int

DECLARE warehousexpo INSENSITIVE CURSOR
   FOR
	select g.gponumber,g.gpochangenum,g.gpodate,g.gpostatus,
         g.warehousedate,g.prodcontact,g.daterequired,g.vendorkey,
         gp.sectionkey,gp.sectiontype,gp.key1,gp.key2,gp.key3,
	   gp.quantity,gp.description 
  	 	from gpo g,gposection gp
		   where g.gpokey = gp.gpokey
			and gp.key1 = @ware_bookkey
			and gp.key2 = @ware_printingkey

 FOR READ ONLY

   OPEN  warehousexpo

	FETCH NEXT FROM warehousexpo
		INTO @i_gponumber,@i_gpochangenum,@d_gpodate,@c_gpostatus,@d_warehousedate,
			@i_prodcontact,@d_daterequired,@i_vendorkey,@i_sectionkey,@i_sectiontype,
			@i_key1,@i_key2,@i_key3,@i_quantity,@c_description

	select @i_xpostatus = @@FETCH_STATUS

	if @i_xpostatus  <> 0 /** NO xPO **/
	    begin
		close warehousexpo
		deallocate warehousexpo
		RETURN
	   end
	 while (@i_xpostatus <>-1 )
	   begin
	
		IF (@i_xpostatus<>-2)
		  begin
			select @ware_ponumber = convert(varchar,@i_gponumber)  + convert(varchar,@i_gpochangenum)
			select @ware_vendorname  = ''
			select @ware_vendorshort = ''
			select @ware_count = 0
			select @ware_count = count(*)
				from vendor
					where vendorkey = @i_vendorkey

			if  @ware_count > 0 
			  begin
				select @ware_vendorname = name, @ware_vendorshort = shortdesc
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
					select @ware_compdesc = 'Jacket'
				end 
BEGIN tran
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
	          errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
			'No vendorkey for compkey on printing',
			('Warning/data error bookkey ' + convert(varchar,@ware_bookkey) + ' and printingkey ' +
			 convert(varchar,@ware_printingkey) + ' and compkey ' + @ware_compdesc),
			'Stored procedure datawarehouse_xpo','@ware_STORED_PROC', @ware_system_date)
commit tran
		close warehousexpo
		deallocate warehousexpo

		RETURN

	end

		if @ware_compkey = 2 or @ware_fgind = 'Y' 
		  begin
BEGIN tran
			update whprinting
				set bindponumber = @ware_ponumber,
		 		 bindpodate = @d_gpodate,
				 bindpostatus =  @c_gpostatus,
				 finalbindqty = @ware_tentative,
				 bindvendorlong = @ware_vendorname,
		 		 bindvendorshort = @ware_vendorshort
					where bookkey = @ware_bookkey
					and printingkey = @ware_printingkey

commit tran
		  end
		if @ware_compkey = 3 
		  begin
BEGIN tran
			update whprinting
				set printdue =  convert(char,@d_daterequired,110),
				 printponumber = @ware_ponumber,
				 printpodate = @d_gpodate,
			 	 printpostatus = @c_gpostatus,
				 printvendorlong = @ware_vendorname,
				 printvendorshort	= @ware_vendorshort
					where bookkey = @ware_bookkey
					and printingkey = @ware_printingkey
commit tran
		  end
		if @ware_compkey = 4 
		  begin
BEGIN tran
			update whprinting
				set coverdue =  convert(char,@d_daterequired,110),
					 coverponumber = @ware_ponumber,
			 		 coverpostatus = @c_gpostatus,
					 coverqty = @i_quantity,
					 covervendorlong = @ware_vendorname,
					 covervendorshort	= @ware_vendorshort
						where bookkey = @ware_bookkey
						and printingkey = @ware_printingkey
commit tran
		 end
   end /*<>*/
	FETCH NEXT FROM warehousexpo
		INTO @i_gponumber,@i_gpochangenum,@d_gpodate,@c_gpostatus,@d_warehousedate,
			@i_prodcontact,@d_daterequired,@i_vendorkey,@i_sectionkey,@i_sectiontype,
			@i_key1,@i_key2,@i_key3,@i_quantity,@c_description

	select @i_xpostatus = @@FETCH_STATUS
end

close warehousexpo
deallocate warehousexpo


GO