PRINT 'STORED PROCEDURE : dbo.datawarehouse_bisac'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_bisac') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_bisac
end

GO

CREATE  proc dbo.datawarehouse_bisac
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

DECLARE @ware_count int

DECLARE @ware_tempcate   varchar(120) 
DECLARE @ware_bisaccategory1  varchar(160) 
DECLARE @ware_bisaccategorycode1 varchar(25) 

DECLARE @ware_bisaccategory2  varchar(160) 
DECLARE @ware_bisaccategorycode2 varchar(25) 

DECLARE @ware_bisaccategory3  varchar(160) 
DECLARE @ware_bisaccategorycode3 varchar(25) 

DECLARE @ware_bisaccategory4  varchar(160) 
DECLARE @ware_bisaccategorycode4 varchar(25) 

DECLARE @ware_bisaccategory5  varchar(160) 
DECLARE @ware_bisaccategorycode5 varchar(25) 
DECLARE @i_bisaccode int
DECLARE @i_bisacsubcode int
DECLARE @i_bisacstatus int
DECLARE @i_sortorder int

DECLARE warehousebisac INSENSITIVE CURSOR
FOR
	SELECT bisaccategorycode,bisaccategorysubcode,sortorder
		    FROM bookbisaccategory 
		   	WHERE  bookkey = @ware_bookkey
				ORDER BY  sortorder
FOR READ ONLY

select @ware_count = 1 

OPEN warehousebisac

FETCH NEXT FROM warehousebisac
INTO @i_bisaccode, @i_bisacsubcode,@i_sortorder

select @i_bisacstatus = @@FETCH_STATUS

 while (@i_bisacstatus<>-1 )
   begin

	IF (@i_bisacstatus<>-2)
	  begin
		if @i_bisaccode is null
		 begin
			select @i_bisaccode = 0
		 end
		if @i_bisacsubcode is null
		 begin
			select @i_bisacsubcode = 0
		 end
		if @i_sortorder is null
		 begin
			select @i_sortorder = 0
		 end


	if  @i_sortorder = 1 
	  begin
		if @i_bisaccode > 0 
		  begin
			exec gentables_longdesc 339,@i_bisaccode,@ware_bisaccategory1 OUTPUT
		  end
		else
		  begin
			select @ware_bisaccategory1 = ''
		  end

		if @i_bisaccode > 0 and @i_bisacsubcode > 0 
		  begin
			select @ware_tempcate = ''
			exec subgent_longdesc 339,@i_bisaccode,@i_bisacsubcode, @ware_tempcate OUTPUT
			if datalength(@ware_tempcate) > 0 
			  begin
				select @ware_bisaccategory1  = ltrim(rtrim(@ware_bisaccategory1)) 
				select @ware_tempcate = ltrim(rtrim(@ware_tempcate)) /*6-14-04 remove spaces*/
				select @ware_bisaccategory1 = @ware_bisaccategory1  + ' / ' + @ware_tempcate
			  end
			exec subgent_bisac 339,@i_bisaccode,@i_bisacsubcode, @ware_bisaccategorycode1 OUTPUT
		  end
		else
		  begin
			select @ware_bisaccategorycode1 = ''
		 end
	  end
	 if @i_sortorder= 2 
	  begin
		if @i_bisaccode > 0 
		  begin
			exec gentables_longdesc 339,@i_bisaccode,@ware_bisaccategory2 OUTPUT
		  end
		else
		  begin
			select @ware_bisaccategory2 = ''
		  end

		if @i_bisaccode > 0 and @i_bisacsubcode > 0 
		  begin
			select @ware_tempcate = ''
			exec subgent_longdesc 339,@i_bisaccode,@i_bisacsubcode,@ware_tempcate OUTPUT
			if datalength(@ware_tempcate) > 0 
			  begin
				select @ware_bisaccategory2  = ltrim(rtrim(@ware_bisaccategory2)) 
				select @ware_tempcate = ltrim(rtrim(@ware_tempcate)) /*6-14-04 remove spaces*/
				select @ware_bisaccategory2 = @ware_bisaccategory2  + ' / ' + @ware_tempcate
			  end
			exec subgent_bisac 339,@i_bisaccode,@i_bisacsubcode,@ware_bisaccategorycode2 OUTPUT
		  end
		else
		  begin
			select @ware_bisaccategorycode2 = ''
		  end
	  end
	if @i_sortorder = 3 
	  begin
		if @i_bisaccode > 0 
		  begin
			exec gentables_longdesc 339,@i_bisaccode,@ware_bisaccategory3 OUTPUT
		  end 
		else
		  begin
			select @ware_bisaccategory3 = ''
		  end

		if @i_bisaccode > 0 and @i_bisacsubcode > 0 
		  begin
			select @ware_tempcate = ''
			exec subgent_longdesc 339,@i_bisaccode,@i_bisacsubcode, @ware_tempcate OUTPUT

			if datalength(@ware_tempcate) > 0 
			  begin
				select @ware_bisaccategory3  = ltrim(rtrim(@ware_bisaccategory3)) 
				select @ware_tempcate = ltrim(rtrim(@ware_tempcate)) /*6-14-04 remove spaces*/
				select @ware_bisaccategory3 = @ware_bisaccategory3  + ' / ' + @ware_tempcate
			  end
			exec  subgent_bisac 339,@i_bisaccode,@i_bisacsubcode,@ware_bisaccategorycode3 OUTPUT
		  end
		else
		  begin
			select @ware_bisaccategorycode3 = ''
		 end
	 end
	
if @i_sortorder = 4 
	   begin
		if @i_bisaccode > 0 
		  begin
			exec gentables_longdesc 339,@i_bisaccode,@ware_bisaccategory4 OUTPUT
		  end
		else
		  begin
			select @ware_bisaccategory4 = ''
		  end

		if @i_bisaccode > 0 and @i_bisacsubcode > 0 
		  begin
			select @ware_tempcate = ''
			exec subgent_longdesc 339,@i_bisaccode,@i_bisacsubcode, @ware_tempcate OUTPUT
			if datalength(@ware_tempcate) > 0 
			  begin
				select @ware_bisaccategory4  = ltrim(rtrim(@ware_bisaccategory4)) 
				select @ware_tempcate = ltrim(rtrim(@ware_tempcate)) /*6-14-04 remove spaces*/
				select @ware_bisaccategory4 = @ware_bisaccategory4  + ' / ' + @ware_tempcate
			  end
			exec subgent_bisac 339,@i_bisaccode,@i_bisacsubcode,@ware_bisaccategorycode4 OUTPUT
		  end
		else
		  begin
			select @ware_bisaccategorycode4 = ''
		  end
	 end
	if @i_sortorder = 5 
	  begin 
		if @i_bisaccode > 0 
		  begin
			exec gentables_longdesc 339,@i_bisaccode,@ware_bisaccategory5 OUTPUT
		  end
		else
		  begin
			select @ware_bisaccategory5 = ''
		  end

		if @i_bisaccode > 0 and @i_bisacsubcode > 0 
		  begin
			select @ware_tempcate = ''
			exec  subgent_longdesc 339,@i_bisaccode,@i_bisacsubcode,@ware_tempcate OUTPUT
			if datalength(@ware_tempcate) > 0 
			  begin
				select @ware_bisaccategory5  = ltrim(rtrim(@ware_bisaccategory5)) 
				select @ware_tempcate = ltrim(rtrim(@ware_tempcate)) /*6-14-04 remove spaces*/
				select @ware_bisaccategory5 = @ware_bisaccategory5  + ' / ' + @ware_tempcate
			  end
			exec subgent_bisac 339,@i_bisaccode,@i_bisacsubcode,@ware_bisaccategorycode5 OUTPUT
		  end
		else
		  begin
			select @ware_bisaccategorycode5 = ''
		 end
	  break
	end
	
end	/*<>2*/

	FETCH NEXT FROM warehousebisac
	INTO @i_bisaccode, @i_bisacsubcode,@i_sortorder

	select @i_bisacstatus = @@FETCH_STATUS
end

BEGIN tran
UPDATE  whtitleclass
	set bisaccategory1 = @ware_bisaccategory1,
	    bisaccategorycode1 = @ware_bisaccategorycode1,
	    bisaccategory2 = @ware_bisaccategory2,
	    bisaccategorycode2 = @ware_bisaccategorycode2, 
	    bisaccategory3 = @ware_bisaccategory3,  
	    bisaccategorycode3 = @ware_bisaccategorycode3,
	    bisaccategory4 = @ware_bisaccategory4, 
	    bisaccategorycode4 = @ware_bisaccategorycode4,
	    bisaccategory5 = @ware_bisaccategory5,  
	    bisaccategorycode5 = @ware_bisaccategorycode5
			where bookkey = @ware_bookkey
commit tran
/**
if SQL%ROWCOUNT > 0 then 
	INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc, 
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(ware_logkey)  ,to_char(ware_warehousekey),
		'Unable to update whtitleclass table - for book bisac',
		('Warning/data error bookkey'||to_char(ware_bookkey)),
		'Stored procedure datawarehouse_bisac','WARE_STORED_PROC', ware_system_date); 
	commit;
end if;
**/

close warehousebisac
deallocate warehousebisac


GO