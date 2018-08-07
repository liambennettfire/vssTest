PRINT 'STORED PROCEDURE : dbo.datawarehouse_component'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_component') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_component
end

GO

create proc dbo.datawarehouse_component
@ware_bookkey int,@ware_printingkey int,@ware_tentative int,
@ware_logkey int, @ware_warehousekey int, @ware_system_date datetime 
AS 

DECLARE @ware_count int
DECLARE @ware_compdesc  varchar(80)
DECLARE @ware_potype  int
DECLARE @ware_finishedgoodind varchar(1) 
DECLARE @ware_componenttype1 varchar(80) 
DECLARE @ware_componenttype2 varchar(80) 
DECLARE @ware_componenttype3 varchar(80) 
DECLARE @ware_componenttype4 varchar(80) 
DECLARE @ware_componenttype5 varchar(80) 
DECLARE @ware_componenttype6 varchar(80) 
DECLARE @ware_componenttype7 varchar(80) 
DECLARE @ware_componenttype8 varchar(80) 
DECLARE @ware_componenttype9 varchar(80) 
DECLARE @ware_componenttype10 varchar(80) 
DECLARE @ware_usprice  float
DECLARE @ware_ukprice float
DECLARE @ware_canadaprice float
DECLARE @i_compkey int 
DECLARE @c_compdesc varchar(32) 
DECLARE @c_potypeshortdesc varchar(10)
DECLARE @c_finishedgoodind varchar(1)
DECLARE @c_potype varchar(1)
DECLARE @i_compstatus int
DECLARE @ware_ponumber varchar(20)
DECLARE @ware_vendorname varchar(80) 
DECLARE @ware_vendorshort varchar(8) 
DECLARE @ware_pochangenum varchar(20) 
DECLARE @ware_compkey_finished int
DECLARE @ware_count_two int
DECLARE @c_ponumber varchar(20) 
DECLARE @c_gpostatus varchar(20) 
DECLARE @d_gpodate  datetime
DECLARE @i_vendorkey int
DECLARE @i_changenum int
DECLARE @i_potypekey int

/* 12-6-04 CRM 2188 : add finished goods columns 
  1-19-05 put at end so get finishedgoods no matter where at */

select @ware_count = 1

DECLARE warehousecomponent INSENSITIVE CURSOR
FOR
		select cp.compkey,cp.compdesc,p.potypeshortdesc,c.finishedgoodind,p.potype
  			from compspec c,comptype cp,potype p
				where  c.compkey = cp.compkey
					and  c.potypekey = p.potypekey
					and c.bookkey = @ware_bookkey
					and c.printingkey = @ware_printingkey
					and  c.activeind = 1 

FOR READ ONLY

OPEN warehousecomponent 

FETCH NEXT FROM warehousecomponent 
INTO  @i_compkey,@c_compdesc,@c_potypeshortdesc,@c_finishedgoodind,@c_potype


	select @i_compstatus = @@FETCH_STATUS

	if @i_compstatus <> 0 /** NO PRINTING **/
	  begin
		close warehousecomponent
		deallocate warehousecomponent

	  	RETURN
	   end
	 while (@i_compstatus<>-1 )
	   begin

		IF (@i_compstatus<>-2)
		  begin

			if @ware_count > 0 and @ware_count < 11 
			  begin
				if @ware_count = 1 
				  begin
					select @ware_componenttype1 = @c_compdesc
				  end
				if @ware_count  = 2 
				  begin
					select @ware_componenttype2 = @c_compdesc
				  end
				if @ware_count  = 3 
				  begin
					select @ware_componenttype3 = @c_compdesc
				  end
				if @ware_count  = 4 
				  begin
					select @ware_componenttype4 = @c_compdesc	
				  end
				if @ware_count  = 5 
				  begin
					select @ware_componenttype5 = @c_compdesc
				  end
				if @ware_count  = 6 
				  begin
					select @ware_componenttype6 = @c_compdesc
				  end
				if @ware_count = 7 
				  begin
					select @ware_componenttype7 = @c_compdesc
				  end
				if @ware_count  = 8 
				  begin
					select @ware_componenttype8 = @c_compdesc
				  end
				if @ware_count  = 9 
				  begin
					select @ware_componenttype9 = @c_compdesc
				  end
				if @ware_count  = 10 
				  begin
					select @ware_componenttype10 = @c_compdesc
				  end

				select @ware_count = @ware_count  + 1 
BEGIN tran
				update whprinting
					set componenttype1 = @ware_componenttype1,
						componenttype2 = @ware_componenttype2,
						componenttype3 = @ware_componenttype3,
						componenttype4 = @ware_componenttype4,
						componenttype5 = @ware_componenttype5,
						componenttype6 = @ware_componenttype6,
						componenttype7 = @ware_componenttype7,
						componenttype8 = @ware_componenttype8,
						componenttype9 = @ware_componenttype9,
						componenttype10 = @ware_componenttype10
					WHERE  bookkey = @ware_bookkey
						AND printingkey = @ware_printingkey
commit tran
			if @c_potype = 'P' 
			  begin
				exec datawarehouse_po @ware_bookkey,@ware_printingkey,@i_compkey,
					@c_finishedgoodind,@ware_tentative,@ware_logkey,@ware_warehousekey,@ware_system_date  /*whprinting*/
			  end
			if @c_potype = 'C' 
			  begin
				exec datawarehouse_cfpo_print @ware_bookkey,@ware_printingkey,@i_compkey,
					@c_finishedgoodind,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprinting*/

				exec datawarehouse_cfpo_bind @ware_bookkey,@ware_printingkey,@i_compkey,
					@c_finishedgoodind,@ware_tentative,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprinting*/
			  end
			if @c_potype = 'X' 
			  begin
				exec datawarehouse_xpo @ware_bookkey,@ware_printingkey,@i_compkey,
					@c_finishedgoodind,@ware_tentative,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprinting*/
			  end
			if @c_potype = 'A' 
			  begin
				exec datawarehouse_aopo @ware_bookkey,@ware_printingkey,@i_compkey,
					@c_finishedgoodind,@ware_tentative,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprinting*/
			  end
			if @c_potype = 'G' 	
			  begin
				exec datawarehouse_aopo @ware_bookkey,@ware_printingkey,@i_compkey,
					@c_finishedgoodind,@ware_tentative,@ware_logkey,@ware_warehousekey,@ware_system_date /*whprinting*/
			  end
		end
	end  /*<>*/

   	FETCH NEXT FROM warehousecomponent 
		INTO  @i_compkey,@c_compdesc,@c_potypeshortdesc,@c_finishedgoodind,@c_potype

	select @i_compstatus = @@FETCH_STATUS
   end

select @ware_count = count(*)  
	from whtitleinfo
		where bookkey = @ware_bookkey
if  @ware_count > 0 
  begin
	select @ware_canadaprice = canadianpricebest,@ware_ukprice = ukpricebest,@ware_usprice = uspricebest
			from whtitleinfo
				where bookkey = @ware_bookkey
BEGIN tran
	update whprinting
		set usretailprice = @ware_usprice,
			canadianretailprice = @ware_canadaprice ,
			ukretailprice = @ware_ukprice
				WHERE  bookkey = @ware_bookkey
					AND printingkey = @ware_printingkey
commit tran
end

/*crm 2188: add finish good columns picks up which ever component has finishedgoods*/
select @ware_pochangenum = ''
select @ware_ponumber = ''
select @ware_count = 0
select @ware_vendorname = ''
select @ware_vendorshort = ''
select @c_ponumber = ''
select @i_changenum = 0
select @d_gpodate = ''
select @c_gpostatus = ''
select @i_vendorkey = 0


/*get compkey for finishedgood component*/

	select @ware_count = count(*)
	  from compspec cs
	 where cs.bookkey = @ware_bookkey
		and cs.printingkey = @ware_printingkey
		and cs.activeind = 1
		and cs.finishedgoodind = 'Y'

	if @ware_count > 0 
	 begin
	 	/*Determine whether PO is a single title PO ,an XPO or CF */
		select @i_potypekey = cs.potypekey, @ware_compkey_finished=cs.compkey
		  from compspec cs
		 where cs.bookkey = @ware_bookkey
			and cs.printingkey = @ware_printingkey
			and cs.finishedgoodind = 'Y'
			and cs.activeind = 1
	
		IF @ware_compkey_finished > 0 
		begin		
			IF @i_potypekey = 2  /* XPO  */
			begin
            select @ware_count_two = 0

				select @ware_count_two = count(*)
				   from compspec cs, gpo g, gposection s
				  where s.key1 = cs.bookkey 
					 and s.key2 = cs.printingkey
                and s.key3 = @ware_compkey_finished
				    and cs.bookkey = @ware_bookkey
					 and cs.compkey = @ware_compkey_finished
					 and cs.printingkey = @ware_printingkey
					 and g.gpostatus in ('P','F')
					 and g.gpokey = s.gpokey
				
				IF @ware_count_two > 0
				begin	
					select distinct @c_ponumber = gponumber,  @i_changenum = gpochangenum,
					  @d_gpodate = gpodate, @c_gpostatus = gpostatus,@i_vendorkey = vendorkey
						from compspec cs, gpo g, gposection s
							where  s.key1 = cs.bookkey 
							 and s.key2 = cs.printingkey
                      and s.key3 = @ware_compkey_finished
								and cs.bookkey = @ware_bookkey
								and cs.compkey = @ware_compkey_finished
								and cs.printingkey = @ware_printingkey
								 and g.gpostatus in ('P','F')
								 and g.gpokey = s.gpokey
					
					select @ware_ponumber = rtrim(@c_ponumber)
					select @ware_pochangenum = ''
					if @i_changenum > 0
					  begin
						select @ware_pochangenum = rtrim(@c_ponumber) + convert(varchar(10),@i_changenum)
					  end
					else
					  begin
						select @ware_pochangenum = rtrim(@c_ponumber)
					  end
			
					select @ware_vendorname  = ''
					select @ware_vendorshort = ''
					select @ware_count = 0
					select @ware_count = count(*)
						  from vendor
						where vendorkey = @i_vendorkey
			
					if @ware_count > 0 
					  begin
						select @ware_vendorname = name, @ware_vendorshort = shortdesc
							from vendor
							where vendorkey = @i_vendorkey
					  end
					BEGIN tran
					update whprinting
						set finishedgoodponumber = @c_ponumber,
						 finishedgoodpostatus = @c_gpostatus,
						 finishedgoodpodate = @d_gpodate,
						 finishedgoodvendorlong = @ware_vendorname,
						 finishedgoodvendorshort = @ware_vendorshort,
						 finishedpochangenum = @ware_pochangenum
							where bookkey = @ware_bookkey
							and printingkey = @ware_printingkey
					commit tran
		 		end
			end

			IF @i_potypekey = 2  /* PO  */
			begin

				select @ware_count_two = 0
			
				select @ware_count_two = count(*)
				  from gpo g, gposection s
				 where s.key1 = @ware_bookkey
				   and s.key3 = @ware_compkey_finished
				   and s.key2 = @ware_printingkey
				   and g.gpostatus in ('P','F')
				   and g.gpokey = s.gpokey

				IF @ware_count_two > 0
				begin
					select distinct @c_ponumber = gponumber,  @i_changenum = gpochangenum,
						  @d_gpodate = gpodate, @c_gpostatus = gpostatus,@i_vendorkey = vendorkey
					  from gpo g, gposection s
					 where s.key1 = @ware_bookkey 
						and s.key2 = @ware_printingkey
						and s.key3 = @ware_compkey_finished
						and g.gpostatus in ('P','F')
						and g.gpokey = s.gpokey

					select @ware_ponumber = rtrim(@c_ponumber)
					select @ware_pochangenum = ''
					if @i_changenum > 0
					  begin
						select @ware_pochangenum = rtrim(@c_ponumber) + convert(varchar(10),@i_changenum)
					  end
					else
					  begin
						select @ware_pochangenum = rtrim(@c_ponumber)
					  end
			
					select @ware_vendorname  = ''
					select @ware_vendorshort = ''
					select @ware_count = 0
					select @ware_count = count(*)
						  from vendor
						where vendorkey = @i_vendorkey
			
					if @ware_count > 0 
					  begin
						select @ware_vendorname = name, @ware_vendorshort = shortdesc
							from vendor
							where vendorkey = @i_vendorkey
					  end
					BEGIN tran
					update whprinting
						set finishedgoodponumber = @c_ponumber,
						 finishedgoodpostatus = @c_gpostatus,
						 finishedgoodpodate = @d_gpodate,
						 finishedgoodvendorlong = @ware_vendorname,
						 finishedgoodvendorshort = @ware_vendorshort,
						 finishedpochangenum = @ware_pochangenum
							where bookkey = @ware_bookkey
							and printingkey = @ware_printingkey
					commit tran
				end
			end

			IF @i_potypekey = 3  /* CF  */
			begin

				select @ware_count_two = 0

				select @ware_count_two = count(*)
				   from compspec cs, gpo g, gposection s
				  where s.key1 = cs.bookkey 
					 and s.key2 = cs.printingkey
				    and cs.bookkey = @ware_bookkey
					 and cs.compkey = @ware_compkey_finished
					 and cs.printingkey = @ware_printingkey
					 and g.gpostatus in ('P','F')
					 and g.gpokey = s.gpokey

				IF @ware_count_two > 0
            begin
					select distinct @c_ponumber = gponumber,  @i_changenum = gpochangenum,
						  @d_gpodate = gpodate, @c_gpostatus = gpostatus,@i_vendorkey = vendorkey
					  from gpo g, gposection s
					 where s.key1 = @ware_bookkey 
						and s.key2 = @ware_printingkey
						and s.key3 = @ware_compkey_finished
						and g.gpostatus in ('P','F')
						and g.gpokey = s.gpokey

					select @ware_ponumber = rtrim(@c_ponumber)
					select @ware_pochangenum = ''
					if @i_changenum > 0
					  begin
						select @ware_pochangenum = rtrim(@c_ponumber) + convert(varchar(10),@i_changenum)
					  end
					else
					  begin
						select @ware_pochangenum = rtrim(@c_ponumber)
					  end
			
					select @ware_vendorname  = ''
					select @ware_vendorshort = ''
					select @ware_count = 0
					select @ware_count = count(*)
						  from vendor
						where vendorkey = @i_vendorkey
			
					if @ware_count > 0 
					  begin
						select @ware_vendorname = name, @ware_vendorshort = shortdesc
							from vendor
							where vendorkey = @i_vendorkey
					  end
					BEGIN tran
					update whprinting
						set finishedgoodponumber = @c_ponumber,
						 finishedgoodpostatus = @c_gpostatus,
						 finishedgoodpodate = @d_gpodate,
						 finishedgoodvendorlong = @ware_vendorname,
						 finishedgoodvendorshort = @ware_vendorshort,
						 finishedpochangenum = @ware_pochangenum
							where bookkey = @ware_bookkey
							and printingkey = @ware_printingkey
					commit tran
				end
			end
		end
	end

close warehousecomponent
deallocate warehousecomponent


GO