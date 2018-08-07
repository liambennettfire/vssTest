PRINT 'STORED PROCEDURE : dbo.datawarehouse_estsigs'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_estsigs') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_estsigs
end

GO

create proc dbo.datawarehouse_estsigs
@ware_estkey  int, @ware_versionkey int, @ware_compkey int,@ware_logkey int,
@ware_warehousekey int,@ware_specstring  varchar(2000) OUTPUT
AS

DECLARE @ware_sig_long varchar(40) 
DECLARE @i_signaturesize int
DECLARE @i_numsignatures int
DECLARE @i_estsigstatus int

DECLARE warehousesigs INSENSITIVE CURSOR
   FOR
	SELECT SIGNATURESIZE,NUMSIGNATURES
	    FROM ESTMATERIALSPECSIGS
	   WHERE estkey = @ware_estkey AND
         		versionkey = @ware_versionkey AND
			compkey = @ware_compkey

FOR READ ONLY

   OPEN  warehousesigs 

	FETCH NEXT FROM warehousesigs 
		INTO @i_signaturesize,@i_numsignatures

	select @i_estsigstatus = @@FETCH_STATUS

	if @i_estsigstatus <> 0 /** NOne **/
    	  begin
		close warehousesigs 
		deallocate warehousesigs 
		RETURN
   	end
	 while (@i_estsigstatus<>-1 )
	   begin

		IF (@i_estsigstatus <>-2)
		  begin
	
		if @i_signaturesize > 0 
		  begin
			exec gentables_longdesc 48,@i_signaturesize,@ware_sig_long OUTPUT
			select @ware_specstring = @ware_specstring + 'Signature Size-' + @ware_sig_long + ', '
		  end
		if @i_numsignatures > 0 
		  begin
			select @ware_specstring = @ware_specstring + 'Num. Signatures-' + convert(varchar,@i_numsignatures) + ' '
		  end
	end

	FETCH NEXT FROM warehousesigs 
		INTO @i_signaturesize,@i_numsignatures

	select @i_estsigstatus = @@FETCH_STATUS
end

close warehousesigs 
deallocate warehousesigs 

RETURN 


GO