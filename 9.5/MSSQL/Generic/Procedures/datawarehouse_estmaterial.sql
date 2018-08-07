PRINT 'STORED PROCEDURE : dbo.datawarehouse_estmaterial'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_estmaterial') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_estmaterial
end

GO

create proc dbo.datawarehouse_estmaterial
@ware_estkey  int, @ware_versionkey int, @ware_compkey int,@ware_logkey int,
@ware_warehousekey int,@ware_specstring  varchar(2000) OUTPUT
AS

DECLARE @ware_count int
DECLARE @ware_compspecs varchar(255) 
DECLARE @ware_string varchar(2000) 
DECLARE @ware_stock_long varchar(40) 
DECLARE @ware_basis_long   varchar(40) 
DECLARE @ware_sheetsize_long varchar(40) 
DECLARE @ware_rollsize_long varchar(40)
DECLARE @ware_color_long  varchar(40) 
DECLARE @ware_paperstring varchar(255) 
DECLARE @i_materialkey int
DECLARE @i_basisweightcode int
DECLARE @i_allocation int
DECLARE @i_paperbulk int
DECLARE @i_sheetsizecode int
DECLARE @i_rollsizecode int
DECLARE @i_paperprice int
DECLARE @i_stocktypecode int
DECLARE @i_matsuppliercode int
DECLARE @c_rmc varchar(30)
DECLARE @c_reserveind varchar(1)
DECLARE @c_stockdesc varchar(20)
DECLARE @i_color int
DECLARE @d_requireddate datetime
DECLARE @i_allocationmr int
DECLARE @i_allocationunit int
DECLARE @i_currpaperpriceunit int
DECLARE @i_mweightfactor int
DECLARE @c_supplierdesc varchar(30)
DECLARE @i_estmatstatus int

select @ware_count = 1
DECLARE warehouseestmat INSENSITIVE CURSOR
   FOR
	select e.materialkey,e.basisweightcode,e.allocation,e.paperbulk,
      	    e.sheetsizecode,e.rollsizecode, e.paperprice,e.stocktypecode,
      	    e.matsuppliercode, e.rmc,e.reserveind,e.stockdesc,
      	    e.color,e.requireddate,e.allocationmr,e.allocationunit,
      	    e.currpaperpriceunit,e.mweightfactor,m.supplierdesc
			    from estmaterialspecs e,  matsupplier m
				   where  e.matsuppliercode = m.matsuppliercode
					and  e.estkey = @ware_estkey
					and e.versionkey = @ware_versionkey
					and e.compkey = @ware_compkey

FOR READ ONLY

   OPEN  warehouseestmat

	FETCH NEXT FROM warehouseestmat
		INTO @i_materialkey,@i_basisweightcode,@i_allocation ,@i_paperbulk ,@i_sheetsizecode ,
		@i_rollsizecode,@i_paperprice,@i_stocktypecode,@i_matsuppliercode, @c_rmc,
		@c_reserveind,@c_stockdesc,@i_color,@d_requireddate,@i_allocationmr,
		@i_allocationunit,@i_currpaperpriceunit,@i_mweightfactor,@c_supplierdesc


	select @i_estmatstatus = @@FETCH_STATUS

	if @i_estmatstatus <> 0 /** NOne **/
    	  begin
		close warehouseestmat
		deallocate warehouseestmat
		RETURN ''
   	end
	 while (@i_estmatstatus<>-1 )
	   begin

		IF (@i_estmatstatus <>-2)
		  begin
			if @i_stocktypecode  is null
			  begin
				select @i_stocktypecode = 0
			  end
			if @i_basisweightcode  is null
			  begin
				select @i_basisweightcode = 0
			  end
			if @i_paperbulk is null
			  begin
				select @i_paperbulk = 0
			  end
			if @i_rollsizecode is null
			  begin
				select  @i_rollsizecode = 0
			  end
			if @i_sheetsizecode  is null
			  begin
				select @i_sheetsizecode = 0
			  end
			if @i_color  is null
			  begin
				select @i_color = 0
			  end
			if @i_allocation   is null
			  begin
				select @i_allocation = 0
			  end
			if @i_paperprice is null
			  begin
				select @i_paperprice = 0
			  end

			if @ware_compkey = 3 
			  begin
				select @ware_compspecs = @ware_compspecs + '~r' +  '--TEXT MATERIAL SPECS--' + '~r'
			  end
			else
			  begin
				select @ware_compspecs = @ware_compspecs  + '~r' + '--INSERT MATERIAL SPECS--' + '~r'
		  	  end

			if @ware_count > 1 
			  begin
				select @ware_paperstring = @ware_paperstring  + '-r'
			  end
			select @ware_count = @ware_count  + 1
			select @ware_paperstring = @ware_paperstring + @c_supplierdesc + ', '

			if datalength(LTRIM(RTRIM(@c_rmc)))  = 0 
			  begin
				if @i_stocktypecode > 0 
				  begin
					exec gentables_longdesc 27,@i_stocktypecode, @ware_stock_long OUTPUT
					select @ware_paperstring = @ware_paperstring + @ware_stock_long + ', '
				  end
				if @i_basisweightcode > 0 
				  begin
					 exec gentables_longdesc 47,@i_basisweightcode,@ware_basis_long  OUTPUT
					select @ware_paperstring = @ware_paperstring + 'Basis Weight-' + @ware_basis_long + ', '
				  end
				if @i_paperbulk > 0 
				  begin
					select @ware_paperstring = @ware_paperstring + 'Paper Bulk-' + convert(varchar,@i_paperbulk) + ', '
				  end
				if @i_rollsizecode <> 0 or @i_sheetsizecode <> 0 
				  begin
					if  @i_rollsizecode = 0 
					  begin
						exec  gentables_longdesc 46,@i_sheetsizecode, @ware_sheetsize_long  OUTPUT
						select @ware_paperstring = @ware_paperstring + 'Sheet Size-' + @ware_sheetsize_long + ', '
					  end
					else
					  begin
						exec gentables_longdesc 45,@i_rollsizecode, @ware_rollsize_long OUTPUT
						select @ware_paperstring = @ware_paperstring + 'Roll Size-' + @ware_rollsize_long + ', '
					  end
				  end
				if @i_color > 0 
				  begin
					exec  gentables_longdesc 66, @i_color, @ware_color_long OUTPUT
					select @ware_paperstring = @ware_paperstring + 'Color-' + @ware_color_long + ', '
				  end
				else
				  begin
					select @ware_paperstring = @c_rmc + ' '
				  end
			  end
			if @i_allocation > 0 
			  begin
				select @ware_paperstring = @ware_paperstring + 'Alloc- ' + convert(varchar,@i_allocation) + ', '
			  end
			if @i_paperprice > 0 
			  begin
				select @ware_paperstring = @ware_paperstring + 'Price- ' + convert(varchar,@i_paperprice) + ' '
			  end
			select @ware_string = ''
			exec datawarehouse_estsigs @ware_estkey,@ware_versionkey,@ware_compkey,@ware_logkey,@ware_warehousekey, @ware_string OUTPUT /*whest*/
			if datalength(@ware_string) > 0 
			  begin
				select @ware_paperstring = @ware_paperstring + @ware_string
			  end 
		end /*<>*/
	FETCH NEXT FROM warehouseestmat
		INTO @i_materialkey,@i_basisweightcode,@i_allocation ,@i_paperbulk ,@i_sheetsizecode ,
		@i_rollsizecode,@i_paperprice,@i_stocktypecode,@i_matsuppliercode, @c_rmc,
		@c_reserveind,@c_stockdesc,@i_color,@d_requireddate,@i_allocationmr,
		@i_allocationunit,@i_currpaperpriceunit,@i_mweightfactor,@c_supplierdesc


	select @i_estmatstatus = @@FETCH_STATUS
end

close warehouseestmat
deallocate warehouseestmat

RETURN 


GO