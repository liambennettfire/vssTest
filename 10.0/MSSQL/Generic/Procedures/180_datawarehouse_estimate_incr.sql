if exists (select * from dbo.sysobjects where id = Object_id('dbo.DATAWAREHOUSE_ESTIMATE_INCR') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.datawarehouse_estimate_incr 
end

GO

CREATE PROC dbo.datawarehouse_estimate_incr
  @ware_logkey int,
   @ware_warehousekey int,
   @ware_system_date datetime

AS

DECLARE @v_incr_date datetime
DECLARE @ware_count int
DECLARE @ware_company  varchar(20) 
DECLARE @i_bookkey int
DECLARE @i_printingkey int
DECLARE @i_estkey int
DECLARE @i_eststatus int

select @v_incr_date = max(lastmaintdate) from estwhupdate
 
select @ware_company = upper(orgleveldesc)
   from orglevel
    where orglevelkey= 1
	
if @ware_company <> 'CONSUMER' 
  begin  
	DECLARE warehouseestimate INSENSITIVE CURSOR
	  FOR
		SELECT DISTINCT eb.bookkey,eb.printingkey, we.estkey
		      FROM estbook eb, estwhupdate we
		      where eb.estkey=we.estkey

	FOR READ ONLY
		
	OPEN warehouseestimate 

	FETCH NEXT FROM warehouseestimate
		INTO @i_bookkey,@i_printingkey,@i_estkey 

	select @i_eststatus = @@FETCH_STATUS

	if @i_eststatus <> 0 /*no estimate*/
	  begin	
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,errorfunction,lastuserid, lastmaintdate)
           		 VALUES (convert(varchar,@ware_logkey),convert(varchar,@ware_warehousekey),'No Estimate rows',
		'Stored procedure datawarehouse_estimate','WARE_STORED_PROC',@ware_system_date)
	
	  close warehouseestimate
	  deallocate warehouseestimate
	  
	  RETURN  
	end

	while (@i_eststatus<>-1 )  /* sttus 1*/
	  begin
		IF (@i_eststatus<>-2) /* status 2*/
		  begin
	print 'Here... ' 
		    IF @i_bookkey is null BEGIN
                      SET @i_bookkey = 0
                    END

		    IF @i_printingkey is null BEGIN
                      SET @i_printingkey = 0
                    END

begin tran
		      delete from whest where estkey = @i_estkey
		      delete from whestcost where estkey = @i_estkey
 commit tran
	print 'Here2... ' 
		     exec datawarehouse_estversion @i_bookkey,@i_printingkey,@i_estkey,@ware_company,@ware_logkey,@ware_warehousekey,@ware_system_date /*whest*/

	print 'Here3... ' 
     		     exec datawarehouse_whest_base @i_estkey,@ware_company,@ware_logkey,@ware_warehousekey,@ware_system_date /*incremental P and L*/
		
	   	    end /*status 2*/

		   FETCH NEXT FROM warehouseestimate
			INTO @i_bookkey,@i_printingkey,@i_estkey 

		select @i_eststatus = @@FETCH_STATUS
	   end /*status 1*/

  	delete from estwhupdate where lastmaintdate <= @v_incr_date
end

close warehouseestimate
deallocate warehouseestimate

GO