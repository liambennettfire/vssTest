PRINT 'STORED PROCEDURE : dbo.datawarehouse_materialspecs'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_materialspecs') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_materialspecs
end

GO

create proc dbo.datawarehouse_materialspecs
@ware_bookkey int,@ware_printingkey int,
@ware_logkey int, @ware_warehousekey int, @ware_system_date datetime 
AS 

DECLARE @ware_count int
DECLARE @ware_stocktype_long varchar(40) 
DECLARE @ware_basisweight_long varchar(40) 
DECLARE @ware_paperstatus varchar(10) 
DECLARE @i_materialkey int
DECLARE @i_stocktypecode int
DECLARE @i_basisweight int
DECLARE @i_caliper int
DECLARE @i_paperbulk int
DECLARE @i_allocation int 
DECLARE @c_requeststatus varchar(1) 
DECLARE @i_matstatus int

DECLARE warehousematerial INSENSITIVE CURSOR
FOR
	SELECT  m.materialkey, m.stocktypecode, m.basisweight,
         m.caliper, m.paperbulk, m.allocation ,mq.requeststatus
     FROM {oj materialspecs m  left outer join
			matrequest mq on m.materialkey=mq.materialkey}
			where m.bookkey = @ware_bookkey
			AND m.printingkey = @ware_printingkey

FOR READ ONLY

OPEN warehousematerial

FETCH NEXT FROM warehousematerial
INTO @i_materialkey ,@i_stocktypecode ,@i_basisweight,@i_caliper,@i_paperbulk,@i_allocation ,
	@c_requeststatus

select @i_matstatus = @@FETCH_STATUS

if @i_matstatus <> 0 /** NO PRINTING **/
    begin
	close warehousematerial
	deallocate warehousematerial

	RETURN
   end
 select @ware_count = 1

 while (@i_matstatus<>-1 )
   begin

	IF (@i_matstatus<>-2)
	  begin
		if @ware_count < 3  
		  begin
			
			if @i_stocktypecode is null
			  begin
				select @i_stocktypecode  = 0
			  end
			if @i_basisweight is null
			  begin
				select @i_basisweight  = 0
			  end

		if @i_stocktypecode > 0 
		  begin
			exec gentables_longdesc 27,@i_stocktypecode,@ware_stocktype_long OUTPUT
		  end
		else
		  begin
			select @ware_stocktype_long  = ''
		  end
		if @i_basisweight > 0 
		  begin
			exec gentables_longdesc 47,@i_basisweight,@ware_basisweight_long OUTPUT
		  end
		else
		  begin
			select @ware_basisweight_long  = ''
		  end

		select @ware_paperstatus =
			case @c_requeststatus 
			  when 'A' then 'A'
			  when 'R' then 'R'
			  when 'C' then 'C'
			else	''
		    end
		if @ware_count = 1 
		  begin
BEGIN tran
			update whprinting
				set papertype1 = @ware_stocktype_long,
				  paperallocation1 = @i_allocation,
				  paperstatus1 = @ware_paperstatus,
				  basisweight1 = @ware_basisweight_long,
				  caliper1 = @i_caliper,
				  ppi1 = @i_paperbulk
					where bookkey= @ware_bookkey
					and printingkey= @ware_printingkey
commit tran
		  end
		else
		  begin

BEGIN tran
			update whprinting
				set papertype2 = @ware_stocktype_long,
				  paperallocation2 = @i_allocation,
				  paperstatus2 = @ware_paperstatus,
				  basisweight2 = @ware_basisweight_long,
				  caliper2 = @i_caliper,
				  ppi2 = @i_paperbulk
					where bookkey= @ware_bookkey
					and printingkey= @ware_printingkey
commit tran
		  end
		select @ware_count = @ware_count + 1
	  end
	end	/*<>2*/

	FETCH NEXT FROM warehousematerial
	INTO @i_materialkey ,@i_stocktypecode ,@i_basisweight,@i_caliper,@i_paperbulk,@i_allocation ,
	@c_requeststatus

	select @i_matstatus = @@FETCH_STATUS

end

close warehousematerial
deallocate warehousematerial


GO