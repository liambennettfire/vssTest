PRINT 'STORED PROCEDURE : dbo.datawarehouse_estcomp'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_estcomp') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_estcomp
end

GO

create proc dbo.datawarehouse_estcomp
@ware_bookkey int,@ware_printingkey int,
@ware_estkey int, @ware_versionkey int,
@ware_logkey int, @ware_warehousekey int, @ware_system_date datetime 
AS 

DECLARE @ware_count int
DECLARE @ware_count2 int
DECLARE @ware_count3 int
DECLARE @ware_vendorname varchar(80) 
DECLARE @ware_vendorshort varchar(8) 
DECLARE @ware_compspecs varchar(2000) 
DECLARE @ware_specstring varchar(8000)  /*AA-4-15-03 only need first 2000 but could be longer*/ 
DECLARE @ware_method_long varchar(40) 
DECLARE @ware_ink_long varchar(40) 
DECLARE @ware_finish_long varchar(40) 
DECLARE @ware_stock_long varchar(40) 
DECLARE @ware_string varchar(2000) 
DECLARE @ware_trimfamilycode smallint 
DECLARE @ware_trim_long   varchar(40) 
DECLARE @ware_mediacode  smallint 
DECLARE @ware_media_long varchar(40)
DECLARE @ware_mediasubcode  int
DECLARE @ware_mediasub_long varchar(40) 
DECLARE @ware_colorcount  int 
DECLARE @ware_endpapertype  varchar(40) 
DECLARE @ware_foilamt  float
DECLARE @ware_covercode  smallint
DECLARE @ware_cover_long varchar(40) 
DECLARE @ware_film smallint
DECLARE @ware_film_long  varchar(40) 
DECLARE @ware_bluesind varchar(1) 
DECLARE @ware_firstprinting varchar(1) 
DECLARE @ware_plateavailind varchar(1) 
DECLARE @ware_filmavailind varchar(1) 
DECLARE @ware_endpapertypedesc varchar(40) 
DECLARE @i_compkey int 
DECLARE @i_comptypecode int 
DECLARE @i_compvendorcode  int
DECLARE @i_compqty int 
DECLARE @i_methodcode int 
DECLARE @i_inks int
DECLARE @i_finishcode int
DECLARE @i_stockcode int
DECLARE @c_comments varchar(255)
DECLARE @c_calcspoilage varchar(1)
DECLARE @i_cartonqty int
DECLARE @c_compdesc varchar(32)
DECLARE @i_estcompstatus int

set @ware_count = 1
set @ware_count2 = 1
set @ware_count3 = 1
set @ware_vendorname = ''
set @ware_vendorshort = ''
set @ware_compspecs = ''
set @ware_specstring = ''
set @ware_method_long  = ''
set @ware_ink_long  = ''
set @ware_finish_long  = ''
set @ware_stock_long  = ''
set @ware_string = ''
set @ware_trimfamilycode = 0
set @ware_trim_long   = ''
set @ware_mediacode = 0
set @ware_media_long = ''
set @ware_mediasubcode = 0
set @ware_mediasub_long  = ''
set @ware_colorcount = 0
set @ware_endpapertype   = ''
set @ware_foilamt = 0
set @ware_covercode = 0
set @ware_cover_long  = ''
set @ware_film = 0
set @ware_film_long  = ''
set @ware_bluesind = ''
set @ware_firstprinting  = ''
set @ware_plateavailind  = ''
set @ware_filmavailind  = ''
set @ware_endpapertypedesc = ''


DECLARE warehousecomp INSENSITIVE CURSOR
   FOR
	select e.compkey,e.comptypecode,e.compvendorcode,e.compqty,
         e.methodcode,e.inks,e.finishcode,e.stockcode,e.comments,
         e.calcspoilage,e.cartonqty,c.compdesc
		    from estcomp e,comptype c
 			  where e.compkey = c.compkey
				and  e.estkey = @ware_estkey
				and e.versionkey = @ware_versionkey
FOR READ ONLY

   OPEN  warehousecomp

	FETCH NEXT FROM warehousecomp
		INTO @i_compkey,@i_comptypecode,@i_compvendorcode,@i_compqty,@i_methodcode,
			@i_inks,@i_finishcode,@i_stockcode,@c_comments,@c_calcspoilage,
			@i_cartonqty,@c_compdesc

	select @i_estcompstatus = @@FETCH_STATUS

	if @i_estcompstatus <> 0 /** NO PO **/
    	  begin
		close warehousecomp
		deallocate warehousecomp
		RETURN
   	end
	 while (@i_estcompstatus <>-1 )
	   begin

		IF (@i_estcompstatus <>-2)
		  begin
			if @i_compkey is null
			  begin
				select @i_compkey = 0
			  end
			if @i_comptypecode is null
			  begin
				select @i_comptypecode = 0
			  end
			if @i_compvendorcode is null
			  begin
				select @i_compvendorcode= 0
			  end
			if @i_compqty is null
			  begin
				select @i_compqty = 0
			  end
			if @i_methodcode is null
			  begin
				select @i_methodcode = 0
			  end
			if  @i_inks is null
			  begin
				select @i_inks = 0
			  end
			 if @i_finishcode is null
			  begin
				select @i_finishcode = 0
			  end
			if  @i_stockcode is null
			  begin
				select @i_stockcode = 0
			  end
			if  @i_cartonqty is null
			  begin
				select @i_cartonqty = 0
			  end


/* remove ', ' from specstring */
			select @ware_string = ''
			select @ware_count3 = 0
			select @ware_count3 = datalength(@ware_specstring)
			select @ware_string = substring(@ware_specstring,(@ware_count3 -2),2)
			if @ware_string = ', ' 
			  begin
				select @ware_string = substring(@ware_specstring,1,(@ware_count3 -2))
	      		select  @ware_specstring = @ware_string
			  end
			if @ware_count > 1 
			  begin
				select @ware_compspecs = @ware_compspecs  + '-r' 
			end
			select @ware_count2 = 0
			if @i_compvendorcode > 0 
			  begin
				select @ware_compspecs = @ware_compspecs + '--' + upper(@c_compdesc) + '-'
				select @ware_count2 = count(*)
					from vendor
						where vendorkey = @i_compvendorcode
				if  @ware_count2 > 0 
			  	  begin
					select @ware_vendorname = name, @ware_vendorshort =shortdesc
						from vendor
							where vendorkey = @i_compvendorcode
					select @ware_compspecs = @ware_compspecs +  @ware_vendorname + '~r'
				  end
				else
				  begin
					select @ware_compspecs = @ware_compspecs + '--' + upper(@c_compdesc) + '-'
				  end
			  end
			if @i_compqty > 0 
			  begin
				select @ware_specstring = @ware_specstring + 'Quantity: ' + convert (varchar,@i_compqty) + ', '
			  end
			if @i_cartonqty > 0 
			  begin
				select @ware_specstring = @ware_specstring + 'Carton Qty: ' + convert(varchar,@i_cartonqty) + ', '
			  end
/*methodcode*/
			if @i_methodcode > 0 
			  begin
				exec gentables_longdesc 1004,@i_methodcode, @ware_method_long OUTPUT
			  end
			else
			  begin
				select @ware_method_long  =  ''
			  end
			if datalength(@ware_method_long)> 0 
			  begin
				select @ware_specstring = @ware_specstring + 'Shipping Method: ' + @ware_method_long + ', '
			  end
/*INKS*/
			if @i_inks > 0 
			  begin
				exec  gentables_longdesc 1014,@i_inks, @ware_ink_long  OUTPUT
			  end
			else
			  begin
				select @ware_ink_long   =  ''
			  end
			if datalength(@ware_ink_long)> 0 
			  begin
				select @ware_specstring = @ware_specstring + 'Inks: ' + @ware_ink_long + ', '
			  end
/*finishedcode*/
			if @i_finishcode > 0 
			  begin
				exec gentables_longdesc 15,@i_finishcode, @ware_finish_long OUTPUT
			  end
			else
			  begin
				select @ware_finish_long   =  ''
			  end
			if datalength(@ware_ink_long )> 0 
			  begin
				select @ware_specstring = @ware_specstring + 'Finish: ' + @ware_finish_long  + ', '
			   end
/*stockcode*/
			if @i_stockcode > 0 
			  begin
				exec gentables_longdesc 26,@i_stockcode,@ware_stock_long OUTPUT
			  end
			else
			  begin
				select @ware_stock_long   =  ''
			  end
			if datalength(@ware_stock_long)> 0 
			  begin
				select @ware_specstring = @ware_specstring + 'Stock: ' + @ware_stock_long  + ', '
			  end
/* camperspecs values */
			select @ware_string = ''
			exec  datawarehouse_camspec @ware_estkey,@ware_versionkey,@ware_logkey,@ware_warehousekey, @ware_string OUTPUT /*whest*/
			if datalength(@ware_string) > 0 
			  begin
				select @ware_specstring = @ware_specstring + @ware_string
			  end
/*misc spec call function to get all rows for this estkey,versionkey*/
			select @ware_string = ''
			exec datawarehouse_miscspec @ware_estkey,@ware_versionkey,@i_compkey,@ware_logkey,@ware_warehousekey,@ware_string OUTPUT
			if datalength(@ware_string) > 0 
			  begin
				select @ware_specstring = @ware_specstring + @ware_string
			  end
/* remove ', ' from specstring */
			select @ware_string = ''
			select @ware_count3 = 0
			select @ware_count3 = datalength(@ware_specstring)
			select @ware_string = substring(@ware_specstring,(@ware_count3 -2),2)
			if @ware_string = ', ' 
			  begin
				select @ware_string = substring(@ware_specstring,1,(@ware_count3 -2))
	      	 	select @ware_specstring = @ware_string
			  end
/*materiaspec */
		 if @i_compkey = 8 or @i_compkey = 3 
		   begin
			select @ware_count2 = 0
			select @ware_count2 = count(*)
				from estmaterialspecs e,  matsupplier m
					where  e.matsuppliercode = m.matsuppliercode
					and  e.estkey = @ware_estkey
					and e.versionkey = @ware_versionkey
						and e.compkey = @i_compkey
	  		if  @ware_count2 > 0 
			  begin
				exec datawarehouse_estmaterial @ware_estkey,@ware_versionkey,@i_compkey,@ware_logkey,@ware_warehousekey, @ware_string  OUTPUT /*whest*/
			  end
			if datalength(@ware_string) > 0 
			  begin
				select @ware_specstring = @ware_specstring + @ware_string
			  end
		end

/* remove ', ' from specstring */
		select @ware_string = ''
		select @ware_count3 = 0
		select @ware_count3 = datalength(@ware_specstring)
		select @ware_string = substring(@ware_specstring,(@ware_count3 -2),2)
		if @ware_string = ', ' 
		  begin
			select @ware_string = substring(@ware_specstring,1,(@ware_count3 -2))
	       	select @ware_specstring = @ware_string
	 	  end
		if Rtrim(@ware_specstring) <> '' 
		  begin
/* parse @ware_specstring to 45 characters per line */
			exec parse_string @ware_specstring,@ware_specstring OUTPUT
			select @ware_compspecs = @ware_compspecs +@ware_specstring
		  end 
	end /*<>*/

	FETCH NEXT FROM warehousecomp
		INTO @i_compkey,@i_comptypecode,@i_compvendorcode,@i_compqty,@i_methodcode,
			@i_inks,@i_finishcode,@i_stockcode,@c_comments,@c_calcspoilage,
			@i_cartonqty,@c_compdesc

	select @i_estcompstatus = @@FETCH_STATUS
end
BEGIN tran

 update whest
	set estspecs = substring(@ware_specstring,1,2000)
	   where estkey =@ware_estkey
		and bookkey =@ware_bookkey
			and printingkey =@ware_printingkey
			and estversion = @ware_versionkey

commit tran
close warehousecomp
deallocate warehousecomp


GO
