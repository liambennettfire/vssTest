PRINT 'STORED PROCEDURE : dbo.datawarehouse_cfpo_print'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_cfpo_print') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_cfpo_print
end

GO

create proc dbo.datawarehouse_cfpo_print
@ware_bookkey int,@ware_printingkey int,
@ware_compkey int, @ware_fgind varchar,
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
DECLARE @i_printpostatus int


DECLARE warehousecfpoprint INSENSITIVE CURSOR
   FOR
	select g.gponumber,g.gpochangenum,g.gpodate,g.gpostatus,
         g.daterequired,g.vendorkey,sum(gps.quantity) 
  		  from gpo g,gposection gp,gposubsection gps
			where g.gpokey = gp.gpokey
		          	and gp.sectionkey = gps.sectionkey
				and  gp.gpokey = gps.gpokey
				and gps.key1 = @ware_bookkey
				and gps.key2 = @ware_printingkey
				and g.gpostatus in ('F','P','I')
				and gp.sectiontype = 4
					group by g.gponumber,g.gpochangenum,g.gpodate,
        				   g.gpostatus,g.daterequired,g.vendorkey
   FOR READ ONLY

   OPEN  warehousecfpoprint

	FETCH NEXT FROM warehousecfpoprint
		INTO @i_gponumber,@i_gpochangenum,@d_gpodate,@c_gpostatus,@d_daterequired,@i_vendorkey,
			@i_quantity

	select @i_printpostatus = @@FETCH_STATUS

	if @i_printpostatus  <> 0 /** NO PrintPO **/
   begin
		close warehousecfpoprint
      deallocate warehousecfpoprint
		RETURN
   end


	while (@i_printpostatus <>-1 )
	   begin
	
		IF (@i_printpostatus <>-2)
		  begin
			select @ware_count = 0
			select @ware_count = count(*)
			    from gpo g,gposection gp,gposubsection gps
		  		where g.gpokey = gp.gpokey
	      	    		and gp.sectionkey = gps.sectionkey
					and  gp.gpokey = gps.gpokey
					and gps.key1 = @ware_bookkey
					and gps.key2 = @ware_printingkey
					and g.gpostatus in ('F','P','I')
					and gp.sectiontype = 4

			if @ware_count = 1 
			  begin
				select @ware_ponumber = convert(varchar,@i_gponumber) + convert(varchar,@i_gpochangenum)
				select @ware_vendorname  = ''
				select @ware_vendorshort = ''
				select @ware_count = 0
				select @ware_count= count(*)
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
						'No vendorkey for compkey on printing',('Warning/data error bookkey ' + convert(varchar,@ware_bookkey) 
						+ ' and printingkey ' + convert(varchar,@ware_printingkey) +' and compkey ' + @ware_compdesc),
						'Stored procedure datawarehouse_cfpoprint', 'WARE_STORED_PROC', @ware_system_date)
commit tran
               close warehousecfpoprint
               deallocate warehousecfpoprint
					RETURN
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
		end
	    end /*<>2*/
	FETCH NEXT FROM warehousecfpoprint
		INTO @i_gponumber,@i_gpochangenum,@d_gpodate,@c_gpostatus,@d_daterequired,@i_vendorkey,
			@i_quantity

	select @i_printpostatus = @@FETCH_STATUS
end

close warehousecfpoprint
deallocate warehousecfpoprint


GO