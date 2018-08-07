PRINT 'STORED PROCEDURE : dbo.datawarehouse_camspec'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_camspec') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_camspec
end

GO

CREATE PROCEDURE datawarehouse_camspec
@ware_estkey  int, @ware_versionkey int,@ware_logkey int,
@ware_warehousekey int, @ware_specstring varchar(2000) OUTPUT
AS


DECLARE @ware_camera_long  varchar(40) 
DECLARE @i_cameraitemcode int
DECLARE @i_quantity int
DECLARE @i_camstatus int

DECLARE warehousecamspec INSENSITIVE CURSOR
   FOR
	 SELECT CAMERAITEMCODE,QUANTITY
    		FROM ESTCAMERASPECS
   			WHERE estkey = @ware_estkey
				AND versionkey = @ware_versionkey

FOR READ ONLY

   OPEN  warehousecamspec

	FETCH NEXT FROM warehousecamspec
		INTO @i_cameraitemcode,@i_quantity

	select @i_camstatus = @@FETCH_STATUS

	if @i_camstatus <> 0 /** NOne **/
    	  begin
		close warehousecamspec
		deallocate warehousecamspec
		RETURN
   	end
	 while (@i_camstatus<>-1 )
	   begin

		IF (@i_camstatus <>-2)
		  begin
		
			if @i_cameraitemcode is null
			  begin
				select @i_cameraitemcode = 0
			  end
			if @i_cameraitemcode > 0 
			  begin
				exec gentables_longdesc 7,@i_cameraitemcode, @ware_camera_long OUTPUT
				if @ware_camera_long is null 
				  begin
					select @ware_camera_long = ''
				  end
				if datalength(@ware_camera_long) > 0 
				  begin
					select @ware_specstring = @ware_specstring + upper(@ware_camera_long) + '- Quantity: ' + convert(varchar,@i_quantity) + ', '
				  end
		 	end
		end /*<>*/
	FETCH NEXT FROM warehousecamspec
		INTO @i_cameraitemcode,@i_quantity

	select @i_camstatus = @@FETCH_STATUS
  end

close warehousecamspec
deallocate warehousecamspec

RETURN 


GO