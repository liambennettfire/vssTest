PRINT 'STORED PROCEDURE : dbo.datawarehouse_cce'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_cce') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_cce
end

GO

create proc dbo.datawarehouse_cce 
(@ware_bookkey int,@ware_printingkey int,@ware_tentative int,@ware_ccestatus varchar,
@ware_dateccefinalized datetime,@ware_illuspapchgcode int,
@ware_textpapchgcode int,@ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime)

AS

DECLARE @ware_count int
DECLARE @ware_company  varchar(20) 
DECLARE @ware_potype  int
DECLARE @ware_compkey int
DECLARE @ware_finishedgoodind varchar(1) 
DECLARE @ware_activegpo varchar(8)  
DECLARE @ware_includecode varchar(8) 
DECLARE @ware_defaultonrep varchar(8)  
DECLARE @ware_externalcode  varchar(100) 
DECLARE @ware_updateoncceind  varchar(1) 
DECLARE @ware_estkey int
DECLARE @ware_rmc varchar(40) 
DECLARE @ware_allocation int
DECLARE @ware_groupnum int
DECLARE @ware_currpaperprice float
DECLARE @ware_ccestatus2 varchar(10)
DECLARE @ware_materialkey  int
DECLARE @c_externaldesc varchar(30)
DECLARE @c_cceind varchar(1)
DECLARE @c_costtype varchar(1)
DECLARE @c_externalcode varchar(6)
DECLARE @i_internalcode int
DECLARE @c_tag1 varchar(8)
DECLARE @c_tag2 varchar(8)
DECLARE @i_compkey int
DECLARE @c_stockind varchar(1)
DECLARE @c_defaultonscreenind  varchar(1)
DECLARE @c_defaultonreportind varchar(1)
DECLARE @c_includeoncce varchar(1)
DECLARE @i_sortorder int
DECLARE @c_compdesc varchar(32)
DECLARE @i_ccestatus int

select @ware_count = 1
select @ware_activegpo  = 'false'
select @ware_includecode = 'false'
select  @ware_defaultonrep = 'false'

select @ware_company = upper(orgleveldesc)
		from orglevel
			where orglevelkey= 1

/*ids_16 get finished goods not using so comment and if I am only get with 'Y'*/
SELECT @ware_count = count(*)  
	   from compspec c,potype p
		   where c.potypekey = p.potypekey
			and c.bookkey = @ware_bookkey
			and c.printingkey = @ware_printingkey
			and c.activeind = 1
			and c.finishedgoodind ='Y'

if  @ware_count >0 
  begin
/* don't need just need to set activegpo to true*/
/*	SELECT @ware_potype = p.potypekey,@ware_compkey = c.compkey,@ware_finishedgoodind =c.finishedgoodind
		   from compspec c,potype p
			   where c.potypekey = p.potypekey
				and c.bookkey = @ware_bookkey
				and c.printingkey = @ware_printingkey
				and c.activeind = 1
				and c.finishedgoodind ='Y' 
 */

			select @ware_activegpo = 'true'
  end

DECLARE warehousecce INSENSITIVE CURSOR
FOR
/* ids_9*/
SELECT c.externaldesc,c.cceind,c.costtype,c.externalcode,c.internalcode,
      c.tag1,c.tag2,c.compkey,c.stockind,c.defaultonscreenind,
      c.defaultonreportind,c.includeoncce,c.sortorder,cp.compdesc
   		from cdlist c,comptype cp
   where c.compkey = cp.compkey
		and c.includeoncce = 'Y'
		and ((c.defaultonscreenind = 'Y' ) or
      	   ( c.defaultonreportind = 'Y' ) )
	order by c.externaldesc asc
FOR READ ONLY

OPEN warehousecce

FETCH NEXT FROM warehousecce
INTO  @c_externaldesc ,@c_cceind,@c_costtype,@c_externalcode,
@i_internalcode,@c_tag1,@c_tag2,@i_compkey,@c_stockind,
@c_defaultonscreenind,@c_defaultonreportind,@c_includeoncce,
@i_sortorder,@c_compdesc

select @i_ccestatus = @@FETCH_STATUS

if @i_ccestatus <> 0 /** NO CCE **/
    begin
	close warehousecce
	deallocate warehousecce

	RETURN
   end

while (@i_ccestatus <>-1 )
   begin

	IF (@i_ccestatus <>-2)
	  begin

	if @c_externaldesc is null
	  begin
		select @c_externaldesc = ''
	  end 
	if @c_cceind is null
	  begin
		select @c_cceind  = '' 
	  end
	if @c_costtype is null
	  begin
		select @c_costtype = ''
	  end
	if @c_externalcode is null
	   begin
		select @c_externalcode = ''
	  end 
	if @i_internalcode is null
	  begin
		select @i_internalcode  = 0
	  end
	if @c_tag1 is null
	  begin
		select @c_tag1 = ''
	  end
	if @c_tag2 is null
	  begin
		select @c_tag2 = ''
	  end
	if  @i_compkey is null
	  begin
		select @i_compkey = 0
	  end
	if @c_stockind is null
	  begin
		select @c_stockind = ''
	  end
	if @c_defaultonscreenind is null
	  begin
		select @c_defaultonscreenind = ''
	  end
	if @c_defaultonreportind is null
	  begin
		select @c_defaultonreportind = ''
	  end 
	if @c_includeoncce is null
	  begin
		select @c_includeoncce = ''
	  end
	 if @i_sortorder is null
	  begin
		select @i_sortorder = 0
	  end
	if @c_compdesc is null
	  begin
		select  @c_compdesc = ''
	  end
		
		select @ware_includecode = 'false'
		if @c_defaultonreportind='Y' 
		  begin
			select @ware_includecode = 'true'	
		  end

		if @ware_includecode = 'true' 
		  begin
			if @ware_company = 'CONSUMER' 
		    	  begin
				select @ware_externalcode = substring(@c_externalcode,(datalength(@c_externalcode)-2),3)
			  end
			else
			  begin
				select @ware_externalcode = @c_externalcode
			  end

			if @c_defaultonreportind ='Y' 
			  begin
				select @ware_updateoncceind = @c_defaultonreportind
			   end
			else
			  begin
				select @ware_updateoncceind = 'N'
			  end
			if rtrim(@ware_ccestatus) = 'XXX' 
			  begin
				select @ware_ccestatus2 = 'None'
			  end
			 if rtrim(@ware_ccestatus) = '' 
			  begin
				select @ware_ccestatus2 = 'None'
			  end
			if rtrim(@ware_ccestatus) = 'P' 
			 begin
				select @ware_ccestatus2 = 'Proforma'
			  end	
			else
			  begin
				select @ware_ccestatus2 = 'Final'
			  end

			if @c_costtype = 'E' 
			  begin
				insert into whfinalcostest
					(bookkey,printingkey,chargecodekey,chargecode,comptype,
		    			costtype,ccestatus,datefinalized,lastuserid,lastmaintdate)
				VALUES (@ware_bookkey,@ware_printingkey,@i_internalcode,
					(@ware_externalcode + '/' +  @c_externaldesc),
					@c_compdesc,'E',@ware_ccestatus2,@ware_dateccefinalized,
					'WARE_STORED_PROC', @ware_system_date)

				if @i_internalcode= @ware_textpapchgcode 
				  begin
					select @ware_count = 0
					select @ware_count = count(*)
						 FROM MATERIALSPECS m,MATSUPPLIER ma
							   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
								and  m.bookkey = @ware_bookkey
								and m.printingkey = @ware_printingkey
								and ma.nonpocostind = 'Y'
					if @ware_count>1 
					  begin
						select @ware_materialkey = 0
						SELECT  @ware_materialkey = max(materialkey)
	 						   FROM MATERIALSPECS m,MATSUPPLIER ma
								   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
									and  m.bookkey = @ware_bookkey
									and m.printingkey = @ware_printingkey
									and ma.nonpocostind = 'Y'
									and m.rmc is not null and datalength(rtrim(m.rmc))>0 /*11-21-00 added */
	
					if @ware_materialkey > 0  
					  begin
						SELECT @ware_rmc = m.RMC, @ware_allocation = m.ALLOCATION,
     					  	  @ware_currpaperprice = m.CURRPAPERPRICE,@ware_groupnum = m.GROUPNUM
	 						   FROM MATERIALSPECS m,MATSUPPLIER ma
								   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
									and  m.bookkey = @ware_bookkey
									and m.printingkey = @ware_printingkey
									and ma.nonpocostind = 'Y'
									and m.materialkey = @ware_materialkey  /*althea add to get distinct row*/
						if @ware_groupnum is null
						  begin
							select @ware_groupnum = 0
						  end
						if  @ware_groupnum=0 
						  begin
BEGIN tran
							update whfinalcostest
								set papertype = @ware_rmc,
									allocation = @ware_allocation
										WHERE bookkey = @ware_bookkey
											and printingkey = @ware_printingkey
commit tran
								
						  end
					     end
				   end
 				if  @ware_count=1 
				  begin
					SELECT @ware_rmc = m.RMC						
	 					   FROM MATERIALSPECS m,MATSUPPLIER ma
							   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
								and  m.bookkey = @ware_bookkey
								and m.printingkey = @ware_printingkey
								and ma.nonpocostind = 'Y'
					SELECT @ware_allocation = m.ALLOCATION
	 					   FROM MATERIALSPECS m,MATSUPPLIER ma
							   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
								and  m.bookkey = @ware_bookkey
								and m.printingkey = @ware_printingkey
								and ma.nonpocostind = 'Y'
					SELECT  @ware_currpaperprice = m.CURRPAPERPRICE
	 					   FROM MATERIALSPECS m,MATSUPPLIER ma
							   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
								and  m.bookkey = @ware_bookkey
								and m.printingkey = @ware_printingkey
								and ma.nonpocostind = 'Y'

					SELECT @ware_groupnum = m.GROUPNUM
	 					   FROM MATERIALSPECS m,MATSUPPLIER ma
							   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
								and  m.bookkey = @ware_bookkey
								and m.printingkey = @ware_printingkey
								and ma.nonpocostind = 'Y'
/* org. sql for above
					SELECT @ware_rmc = m.RMC,@ware_allocation = m.ALLOCATION,
     				  	  @ware_currpaperprice = m.CURRPAPERPRICE, @ware_groupnum = m.GROUPNUM
	 					   FROM MATERIALSPECS m,MATSUPPLIER ma
							   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
								and  m.bookkey = @ware_bookkey
								and m.printingkey = @ware_printingkey
								and ma.nonpocostind = 'Y'
*/
					if @ware_groupnum is null
					  begin
						select @ware_groupnum = 0
					  end
	
					if @ware_groupnum=0 
					  begin
BEGIN tran
						update whfinalcostest
							set papertype = @ware_rmc,
								allocation = @ware_allocation
									WHERE bookkey = @ware_bookkey
									and printingkey = @ware_printingkey
commit tran
					  end 
				  end

			end
			if @i_internalcode= @ware_illuspapchgcode 
			  begin
				select @ware_count = 0
				select @ware_count = count(*) 
					FROM MATERIALSPECS m,MATSUPPLIER ma
					   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
						and  m.bookkey = @ware_bookkey
						and m.printingkey = @ware_printingkey
						and ma.nonpocostind = 'Y'
						and m.groupnum >0

				if  @ware_count>1 
				  begin
					select @ware_materialkey = 0
					SELECT @ware_materialkey = max(materialkey)
 						   FROM MATERIALSPECS m,MATSUPPLIER ma
							   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
								and  m.bookkey = @ware_bookkey
								and m.printingkey = @ware_printingkey
								and ma.nonpocostind = 'Y'
								and m.groupnum >0
								and m.rmc is not null and datalength(rtrim(m.rmc))>0 /*11-21-00 added */

					if @ware_materialkey > 0
					  begin
						SELECT @ware_rmc = m.RMC, @ware_allocation= m.ALLOCATION,
     					 	   @ware_currpaperprice =m.CURRPAPERPRICE, @ware_groupnum=m.GROUPNUM
	 						   FROM MATERIALSPECS m,MATSUPPLIER ma
								   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
									and  m.bookkey = @ware_bookkey
									and m.printingkey = @ware_printingkey
									and ma.nonpocostind = 'Y'
									and m.groupnum >0
									and m.materialkey = @ware_materialkey   /*althea add to get distinct row*/
						if @ware_groupnum is null
					 	 begin
							select @ware_groupnum = 0
					 	 end

						if @ware_groupnum>0 
						  begin
BEGIN tran
							update whfinalcostest
								set papertype = @ware_rmc,
									allocation = @ware_allocation
										WHERE bookkey = @ware_bookkey
										and printingkey = @ware_printingkey
commit tran
						  end
					  end
				  end
				if  @ware_count=1 
				  begin
					SELECT @ware_rmc = m.RMC, @ware_allocation = m.ALLOCATION,
     					    @ware_currpaperprice = m.CURRPAPERPRICE, @ware_groupnum =m.GROUPNUM
 						   FROM MATERIALSPECS m,MATSUPPLIER ma
							   WHERE  m.MATSUPPLIERCODE = ma.MATSUPPLIERCODE
								and  m.bookkey = @ware_bookkey
								and m.printingkey = @ware_printingkey
								and ma.nonpocostind = 'Y'
								and m.groupnum >0
					if @ware_groupnum is null
					 begin
						select @ware_groupnum = 0
					  end

					if @ware_groupnum>0 
					  begin
BEGIN tran
						update whfinalcostest
							set papertype = @ware_rmc,
								allocation = @ware_allocation
									WHERE bookkey = @ware_bookkey
									and printingkey = @ware_printingkey
commit tran
					  end
				  end
			     else
		 	 	 begin
BEGIN tran
					insert into whfinalcostest
					(bookkey,printingkey,chargecodekey,chargecode,comptype,
	    				costtype,ccestatus,datefinalized,lastuserid,lastmaintdate)
					VALUES (@ware_bookkey,@ware_printingkey,@i_internalcode,
						(@ware_externalcode + '/' + @c_externaldesc),
						@c_compdesc,'P',@ware_ccestatus2,@ware_dateccefinalized,
						'WARE_STORED_PROC', @ware_system_date)
commit tran
				  end 
	  		end
		end
	  end
	end /*<>2*/

	FETCH NEXT FROM warehousecce
	INTO  @c_externaldesc ,@c_cceind,@c_costtype,@c_externalcode,
	@i_internalcode,@c_tag1,@c_tag2,@i_compkey,@c_stockind,
	@c_defaultonscreenind,@c_defaultonreportind,@c_includeoncce,
	@i_sortorder,@c_compdesc

	select @i_ccestatus = @@FETCH_STATUS
end


if @ware_activegpo = 'true' 
  begin
	exec datawarehouse_gpocost_sect @ware_bookkey,@ware_printingkey,
	@ware_tentative,11,@ware_estkey,@ware_company,
	@c_compdesc,@ware_ccestatus2,@ware_dateccefinalized,@ware_logkey,
	@ware_warehousekey,@ware_system_date /*whprinting*/

	exec datawarehouse_gpocost_sect @ware_bookkey,@ware_printingkey,
	@ware_tentative,12,@ware_estkey,@ware_company,
	@c_compdesc,@ware_ccestatus2,@ware_dateccefinalized,@ware_logkey,
	@ware_warehousekey,@ware_system_date /*whprinting*/

	exec datawarehouse_gpocost_sect @ware_bookkey,@ware_printingkey,
	@ware_tentative,13,@ware_estkey,@ware_company,
	@c_compdesc,@ware_ccestatus2,@ware_dateccefinalized,@ware_logkey,
	@ware_warehousekey,@ware_system_date /*whprinting*/

 end
select @ware_count = 0
SELECT @ware_count = count(*) 
    	FROM ESTBOOK
	   WHERE bookkey = @ware_bookkey
		AND  printingkey = @ware_printingkey
if @ware_count >0
  begin
	SELECT @ware_estkey = estkey 
    		FROM ESTBOOK
		   WHERE bookkey = @ware_bookkey
			AND  printingkey = @ware_printingkey
	if @ware_estkey is null
	  begin
		select @ware_estkey = 0
	  end

	if @ware_estkey > 0 
	  begin
		if @ware_estkey>0 
		  begin
			exec datawarehouse_gpocost_sect @ware_bookkey,@ware_printingkey,
			@ware_tentative,3,@ware_estkey,@ware_company,
			@c_compdesc,@ware_ccestatus2,@ware_dateccefinalized,
			@ware_logkey,@ware_warehousekey,@ware_system_date /*whprinting*/
		  end 
	 end
  end

close  warehousecce
deallocate warehousecce


GO