PRINT 'STORED PROCEDURE : dbo.datawarehouse_cfpo_bind' 
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_cfpo_bind') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_cfpo_bind
end

GO

create proc dbo.datawarehouse_cfpo_bind
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
DECLARE @i_bindpostatus int

DECLARE warehousecfpo_bind INSENSITIVE CURSOR
   FOR
	select g.gponumber, g.gpochangenum,g.gpodate,g.gpostatus,g.daterequired,g.vendorkey,
         	sum(gp.quantity)
		    from  gpo g, gposection gp
			 where  g.gpokey = gp.gpokey
				and gp.key1 = @ware_bookkey
				and gp.key2 = @ware_printingkey
				and g.gpostatus in ('P','F','I')
				and  gp.sectiontype = 3
					group by g.gponumber,g.gpochangenum,
					   g.gpodate,g.gpostatus,g.daterequired,g.vendorkey
  FOR READ ONLY

   OPEN  warehousecfpo_bind

	FETCH NEXT FROM warehousecfpo_bind
		INTO @i_gponumber,@i_gpochangenum,@d_gpodate,@c_gpostatus,@d_daterequired,@i_vendorkey,
			@i_quantity

select @i_bindpostatus = @@FETCH_STATUS

if @i_bindpostatus  <> 0 /** NO bindPO **/
begin
	close warehousecfpo_bind
	deallocate warehousecfpo_bind
	RETURN
end

while (@i_bindpostatus <>-1 )
   begin

	IF (@i_bindpostatus <>-2)
	  begin
		select @ware_count = 0
		select @ware_count = count(*)
		    from  gpo g, gposection gp
			 where  g.gpokey = gp.gpokey
				and gp.key1 = @ware_bookkey
				and gp.key2 = @ware_printingkey
				and g.gpostatus in ('P','F','I')
				and  gp.sectiontype = 3 

		if @ware_count = 1 
		  begin
			select @ware_ponumber = convert(varchar,@i_gponumber) + convert(varchar,@i_gpochangenum)
			select @ware_vendorname  = ''
			select @ware_vendorshort = ''
			select @ware_count = 0
			select @ware_count = count(*)
				from vendor
					where vendorkey = @i_vendorkey

			if   @ware_count > 0 
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
			  end
			  BEGIN tran
					INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
									 errorseverity, errorfunction,lastuserid, lastmaintdate)
							 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
								'No vendorkey for compkey on printing',
								('Warning/data error bookkey '+ convert(varchar,@ware_bookkey) + ' and printingkey '+ 
								convert(varchar,@ware_printingkey) + ' and compkey ' + @ware_compdesc), 
								'Stored procedure data@warehouse_cfpo_bind','WARE_STORED_PROC', @ware_system_date)
				  commit tran
				  close warehousecfpo_bind
				  deallocate warehousecfpo_bind
				  RETURN
			  end

				if @ware_compkey = 2 
				  begin
					BEGIN tran
								update whprinting
									set  bindponumber = @ware_ponumber,
										bindpodate = @d_gpodate,
										 bindpostatus =  @c_gpostatus,
										 finalbindqty = @ware_tentative,
										 bindvendorlong = @ware_vendorname,
										 bindvendorshort = @ware_vendorshort
											where bookkey = @ware_bookkey
												and printingkey = @ware_printingkey
					commit tran
					end
				end
	 end /*<>*/

	FETCH NEXT FROM warehousecfpo_bind
		INTO @i_gponumber,@i_gpochangenum,@d_gpodate,@c_gpostatus,@d_daterequired,@i_vendorkey,
			@i_quantity

	select @i_bindpostatus = @@FETCH_STATUS

end

close warehousecfpo_bind
deallocate warehousecfpo_bind


GO