PRINT 'STORED PROCEDURE : dbo.datawarehouse_miscspec'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_miscspec') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_miscspec
end

GO

CREATE PROCEDURE  datawarehouse_miscspec
@ware_estkey  int, @ware_versionkey int, @ware_compkey int,@ware_logkey int,
@ware_warehousekey int, @ware_specstring varchar(2000) OUTPUT
AS

DECLARE @ware_camera_long  varchar(40) 
DECLARE @c_tabledesclong varchar(40) 
DECLARE @c_datadesc varchar(40) 
DECLARE @i_quantity int
DECLARE @i_miscstatus int

DECLARE warehousemiscspec INSENSITIVE CURSOR
   FOR
	select gd.tabledesclong,g.datadesc,e.quantity
  	  FROM estmiscspecs e, gentables g, gentablesdesc gd,
    	     misctypetable m
  		 WHERE ( e.datacode = g.datacode ) and
			(e.tableid = m.datacode ) and
	         ( m.tablecode = g.tableid ) and
      	   ( g.tableid = gd.tableid) and
	         ( e.misctypetableid = m.tableid ) and
      	   ( m.tableid in (51,78) ) and
	         e.estkey = @ware_estkey and
      	   e.versionkey = @ware_versionkey and
	         e.compkey = @ware_compkey

FOR READ ONLY

   OPEN  warehousemiscspec

	FETCH NEXT FROM warehousemiscspec
		INTO @c_tabledesclong,@c_datadesc,@i_quantity

	select @i_miscstatus = @@FETCH_STATUS

	if @i_miscstatus<> 0 /** NOne **/
    	  begin
		close warehousemiscspec
		deallocate warehousemiscspec
		RETURN
   	end
	 while (@i_miscstatus<>-1 )
	   begin

		IF (@i_miscstatus<>-2)
		  begin
		
			select @ware_specstring = @ware_specstring + @c_tabledesclong + ': ' + @c_datadesc + ' '   
			if @i_quantity > 0
			  begin
				select @ware_specstring = @ware_specstring + ' - Quantity: ' + convert(varchar,@i_quantity) + ', ' 
			  end
		end /*<>*/

	FETCH NEXT FROM warehousemiscspec
		INTO @c_tabledesclong,@c_datadesc,@i_quantity

	select @i_miscstatus = @@FETCH_STATUS
end

select @ware_specstring = convert(varchar,@ware_specstring)

close warehousemiscspec
deallocate warehousemiscspec

RETURN 


GO