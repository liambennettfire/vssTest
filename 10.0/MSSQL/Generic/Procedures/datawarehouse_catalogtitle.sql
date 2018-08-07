PRINT 'STORED PROCEDURE : dbo.datawarehouse_catalogtitle'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_catalogtitle') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_catalogtitle
end

GO

create proc dbo.datawarehouse_catalogtitle
(@ware_logkey int, @ware_warehousekey int,@ware_system_date datetime)

AS

/*DECLARE @ware_weight_long varchar(40) 
DECLARE @ware_weight_short  varchar(20) 
DECLARE @ware_position_long  varchar(40) 
DECLARE @ware_position_short  varchar(20) 

DECLARE @c_description  varchar(100) 
DECLARE @i_startingpagenumber int
DECLARE @i_catalogweightcode int
DECLARE @i_catalogpositioncode int
DECLARE @i_catalogpagenumber int
DECLARE @c_finalizedind varchar(1)
DECLARE @i_sortorder int
DECLARE @i_bookkey int
DECLARE @i_sectionkey int
DECLARE @i_printingkey int
DECLARE @i_catalogkey int
DECLARE @i_catalogheading int
DECLARE @ware_heading_long  varchar(40)    /* added 12-4-03*/
DECLARE @ware_heading_short varchar(20)   

DECLARE @i_cattitlestatus int

DECLARE warehousecatalogtit INSENSITIVE CURSOR
FOR
	SELECT c.description,c.startingpagenumber,b.catalogweightcode,b.catalogpositioncode,
		b.catalogpagenumber,b.finalizedind,b.sortorder,b.bookkey,b.printingkey,
		b.sectionkey,c.catalogkey,b.catalogheading 
		    FROM bookcatalog b ,catalogsection c
				WHERE b.sectionkey = c.sectionkey
FOR READ ONLY

OPEN warehousecatalogtit

FETCH NEXT FROM warehousecatalogtit
INTO  @c_description,@i_startingpagenumber,@i_catalogweightcode,@i_catalogpositioncode,
		@i_catalogpagenumber,@c_finalizedind,@i_sortorder,@i_bookkey,@i_printingkey,
		@i_sectionkey,@i_catalogkey,@i_catalogheading 
		
	select @i_cattitlestatus = @@FETCH_STATUS

if @i_cattitlestatus <> 0 /** NO CCE **/
    begin
	close warehousecatalogtit
	deallocate warehousecatalogtit

	RETURN
   end

while (@i_cattitlestatus <>-1 )
   begin

	IF (@i_cattitlestatus <>-2)
	  begin

		select @ware_weight_long = ''
		select @ware_weight_short = ''
		select @ware_position_long = ''
		select @ware_position_short = ''
		select @ware_heading_long = ''  
		select @ware_heading_short = ''  

		if @i_catalogweightcode is null 
		  begin
			select @i_catalogweightcode = 0
		  end
		if @i_catalogpositioncode is null
		  begin
			select @i_catalogpositioncode = 0
		  end
		if @i_catalogweightcode > 0 	
		  begin
			exec gentables_longdesc 290,@i_catalogweightcode,@ware_weight_long OUTPUT
		      exec gentables_shortdesc 290,@i_catalogweightcode, @ware_weight_short OUTPUT
			select @ware_weight_short  = substring(@ware_weight_short,1,8)
		  end
		else
		  begin
			select @ware_weight_long = ''
			select @ware_weight_short = ''
		  end

		if @i_catalogpositioncode > 0
		  begin
			exec gentables_longdesc 291,@i_catalogpositioncode,@ware_position_long OUTPUT
			exec gentables_shortdesc 291,@i_catalogpositioncode, @ware_position_short OUTPUT
			select @ware_position_short  = substring(@ware_position_short,1,8)
		  end
		else
		  begin
			select @ware_position_long = ''
			select @ware_position_short = ''
		  end

		if @i_catalogheading  > 0
		  begin
			exec gentables_longdesc 427,@i_catalogheading, @ware_heading_long  OUTPUT 
			exec gentables_shortdesc 427,@i_catalogheading,@ware_heading_short  OUTPUT 
		   end
		else
		  begin
			select @ware_heading_long = ''
			select @ware_heading_short = ''
		end
BEGIN tran
		INSERT INTO whcatalogtitle (catalogkey,bookkey,printingkey,
			sectionkey,sectiondesc,sectionstartpg,bookweight,bookweightshort,
			bookposition,bookpositionshort,bookpgnumber,bookfinalizeind,booksectionsortorder,
			lastuserid,lastmaintdate,headinglong,headingshort)
		VALUES ( @i_catalogkey,@i_bookkey,@i_printingkey,@i_sectionkey,@c_description,@i_startingpagenumber,
				@ware_weight_long,@ware_weight_short,@ware_position_long,@ware_position_short,
				@i_catalogpagenumber,@c_finalizedind,@i_sortorder,
				'WARE_STORED_PROC',@ware_system_date,@ware_heading_long,@ware_heading_short)
commit tran
	end
		
FETCH NEXT FROM warehousecatalogtit
INTO  @c_description,@i_startingpagenumber,@i_catalogweightcode,@i_catalogpositioncode,
		@i_catalogpagenumber,@c_finalizedind,@i_sortorder,@i_bookkey,@i_printingkey,
		@i_sectionkey,@i_catalogkey,@i_catalogheading 
		
	select @i_cattitlestatus = @@FETCH_STATUS

end

close warehousecatalogtit
deallocate warehousecatalogtit*/
TRUNCATE TABLE whcatalogtitle
 
 INSERT INTO whcatalogtitle
	 (catalogkey, bookkey, printingkey, sectionkey, sectiondesc, 
	 sectionstartpg, bookweight, bookweightshort, bookposition, 
	 bookpositionshort, bookpgnumber, bookfinalizeind, 
	 booksectionsortorder, lastuserid, lastmaintdate, headinglong, 
	 headingshort) 
SELECT cs.catalogkey, bc.bookkey, bc.printingkey,  bc.sectionkey, cs.description, 
            cs.startingpagenumber, isnull(wt.datadesc,''), isnull(substring(wt.datadescshort,1,8),''),  isnull(pos.datadesc,''),
           isnull(substring(pos.datadescshort,1,8),''),  bc.catalogpagenumber, bc.finalizedind, 
           bc.sortorder,  'WARE_STORED_PROC', @ware_system_date, isnull(hd.datadesc,''), 
          isnull(substring(hd.datadescshort,1,8),'') 
FROM bookcatalog bc JOIN catalogsection cs 
	 on cs.sectionkey = bc.sectionkey LEFT JOIN gentables wt on wt.tableid 
	 = 290 and wt.datacode = bc.catalogweightcode LEFT JOIN gentables pos 
	 on pos.tableid = 291 and pos.datacode = bc.catalogpositioncode LEFT 
	 JOIN gentables hd on hd.tableid = 427 and hd.datacode = 
	 bc.catalogheading


GO