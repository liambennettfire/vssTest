PRINT 'STORED PROCEDURE : dbo.datawarehouse_estimate'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_estimate') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_estimate
end

GO

CREATE  proc dbo.datawarehouse_estimate 
(@ware_company varchar,@ware_logkey int, @ware_warehousekey int,@ware_system_date datetime)

AS

DECLARE @ware_count int
DECLARE @i_bookkey int
DECLARE @i_printingkey int
DECLARE @i_estkey int
DECLARE @i_eststatus int

select @ware_count = 1

DECLARE warehouseestimate INSENSITIVE CURSOR
FOR
	SELECT bookkey,printingkey, estkey
    		  FROM estbook

FOR READ ONLY

OPEN warehouseestimate

FETCH NEXT FROM warehouseestimate
	INTO @i_bookkey,@i_printingkey,@i_estkey

select @i_eststatus= @@FETCH_STATUS

if @i_eststatus <> 0 /** NO estimates **/
    	  begin
BEGIN tran
		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
     	   		 errorfunction,lastuserid, lastmaintdate)
		 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
			'No Estimate rows','Stored procedure datawarehouse_estimate','WARE_STORED_PROC',
			 @ware_system_date)
commit tran
   	end

 while (@i_eststatus<>-1 )
   begin
	IF (@i_eststatus<>-2)
	  begin
		exec datawarehouse_estversion @i_bookkey,@i_printingkey,@i_estkey,
		@ware_company,@ware_logkey,@ware_warehousekey,@ware_system_date /*whest*/
	  end
	
FETCH NEXT FROM warehouseestimate
	INTO @i_bookkey,@i_printingkey,@i_estkey

select @i_eststatus= @@FETCH_STATUS
end

close warehouseestimate
deallocate warehouseestimate

GO