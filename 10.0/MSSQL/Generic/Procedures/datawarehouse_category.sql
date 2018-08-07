PRINT 'STORED PROCEDURE : dbo.datawarehouse_category'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_category') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_category
end

GO

CREATE  proc dbo.datawarehouse_category 
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

DECLARE @ware_count int

DECLARE @ware_internalcategory1  varchar(40)
DECLARE @ware_internalcategory2 varchar(40) 
DECLARE @ware_internalcategory3 varchar(40) 
DECLARE @ware_internalcategory4 varchar(40) 
DECLARE @ware_internalcategory5 varchar(40) 
DECLARE @ware_internalcategoryshort1  varchar(20) 
DECLARE @ware_internalcategoryshort2  varchar(20) 
DECLARE @ware_internalcategoryshort3  varchar(20) 
DECLARE @ware_internalcategoryshort4  varchar(20) 
DECLARE @ware_internalcategoryshort5  varchar(20) 
DECLARE @i_categorycode int 
DECLARE @i_catstatus int 
DECLARE @ware_internalcategory6  varchar(40) 
DECLARE @ware_internalcategory7 varchar(40) 
DECLARE @ware_internalcategory8 varchar(40) 
DECLARE @ware_internalcategory9 varchar(40) 
DECLARE @ware_internalcategory10 varchar(40) 
DECLARE @ware_internalcategoryshort6  varchar(20) 
DECLARE @ware_internalcategoryshort7  varchar(20) 
DECLARE @ware_internalcategoryshort8  varchar(20) 
DECLARE @ware_internalcategoryshort9  varchar(20) 
DECLARE @ware_internalcategoryshort10  varchar(20) 

DECLARE warehousecategory INSENSITIVE CURSOR
FOR
	SELECT categorycode
		    FROM bookcategory
		   	WHERE  bookkey = @ware_bookkey
				ORDER BY  sortorder

FOR READ ONLY


select @ware_count = 1
OPEN warehousecategory

FETCH NEXT FROM warehousecategory
INTO @i_categorycode

select @i_catstatus = @@FETCH_STATUS

 while (@i_catstatus<>-1 )
   begin

	IF (@i_catstatus<>-2)
	  begin
		if @ware_count = 1 
		  begin
			if @i_categorycode > 0 
			  begin
				 exec gentables_longdesc 317,@i_categorycode,@ware_internalcategory1 OUTPUT 
				 exec gentables_shortdesc 317,@i_categorycode, @ware_internalcategoryshort1 OUTPUT
			  end
			else
			  begin
				select @ware_internalcategory1 = ''
				select @ware_internalcategoryshort1  = ''
		 	 end
		  end
	 	if @ware_count = 2 
		  begin
			if @i_categorycode > 0 
			  begin
				exec gentables_longdesc 317,@i_categorycode,@ware_internalcategory2 OUTPUT
				exec gentables_shortdesc 317,@i_categorycode, @ware_internalcategoryshort2 OUTPUT

			  end
			else
			  begin
				select @ware_internalcategory2 = ''
				select @ware_internalcategoryshort2  = ''
			end
		  end
		if @ware_count = 3 
		  begin
			if @i_categorycode > 0 
			  begin
				exec gentables_longdesc 317,@i_categorycode,@ware_internalcategory3 OUTPUT
				exec gentables_shortdesc 317,@i_categorycode, @ware_internalcategoryshort3 OUTPUT
			  end
			else
				select @ware_internalcategory3 = ''
				select @ware_internalcategoryshort3  = ''
			  end	
		  end
		if @ware_count = 4 
		  begin
			if @i_categorycode > 0 
		 	 begin
				exec gentables_longdesc 317,@i_categorycode,@ware_internalcategory4 OUTPUT
				 exec gentables_shortdesc 317,@i_categorycode, @ware_internalcategoryshort4 OUTPUT
		  	end
		  else
		    begin
			select @ware_internalcategory4 = ''
			select @ware_internalcategoryshort4  = ''
		  end
		end
		if @ware_count = 5 
		  begin
			if @i_categorycode > 0
			  begin
				 exec gentables_longdesc 317,@i_categorycode, @ware_internalcategory5 OUTPUT 
				 exec gentables_shortdesc 317,@i_categorycode, @ware_internalcategoryshort5 OUTPUT
			  end
			else
			  begin
				select @ware_internalcategory5 = ''
				select @ware_internalcategoryshort5  = ''
			  end
			end
		if @ware_count = 6
		  begin
			if @i_categorycode > 0
			  begin
				 exec gentables_longdesc 317,@i_categorycode, @ware_internalcategory6 OUTPUT 
				 exec gentables_shortdesc 317,@i_categorycode, @ware_internalcategoryshort6 OUTPUT
			  end
			else
			  begin
				select @ware_internalcategory6 = ''
				select @ware_internalcategoryshort6  = ''
			  end
			end
		if @ware_count = 7 
		  begin
			if @i_categorycode > 0
			  begin
				 exec gentables_longdesc 317,@i_categorycode, @ware_internalcategory7 OUTPUT 
				 exec gentables_shortdesc 317,@i_categorycode, @ware_internalcategoryshort7 OUTPUT
			  end
			else
			  begin
				select @ware_internalcategory7 = ''
				select @ware_internalcategoryshort7  = ''
			  end
			end
		if @ware_count = 8 
		  begin
			if @i_categorycode > 0
			  begin
				 exec gentables_longdesc 317,@i_categorycode, @ware_internalcategory8 OUTPUT 
				 exec gentables_shortdesc 317,@i_categorycode, @ware_internalcategoryshort8 OUTPUT
			  end
			else
			  begin
				select @ware_internalcategory8 = ''
				select @ware_internalcategoryshort8  = ''
			  end
			end
		if @ware_count = 9
		  begin
			if @i_categorycode > 0
			  begin
				 exec gentables_longdesc 317,@i_categorycode, @ware_internalcategory9 OUTPUT 
				 exec gentables_shortdesc 317,@i_categorycode, @ware_internalcategoryshort9 OUTPUT
			  end
			else
			  begin
				select @ware_internalcategory9 = ''
				select @ware_internalcategoryshort9  = ''
			  end
			end
		if @ware_count = 10
		  begin
			if @i_categorycode > 0
			  begin
				 exec gentables_longdesc 317,@i_categorycode, @ware_internalcategory10 OUTPUT 
				 exec gentables_shortdesc 317,@i_categorycode, @ware_internalcategoryshort10 OUTPUT
			  end
			else
			  begin
				select @ware_internalcategory10 = ''
				select @ware_internalcategoryshort10  = ''
			 	break
			  end
			end

		select @ware_count = @ware_count + 1
	FETCH NEXT FROM warehousecategory
	INTO @i_categorycode

	select @i_catstatus = @@FETCH_STATUS
end

BEGIN tran

UPDATE whtitleclass
	set internalcategory1 = @ware_internalcategory1,
	    internalcategory2 = @ware_internalcategory2,
	    internalcategory3 = @ware_internalcategory3,
	    internalcategory4 = @ware_internalcategory4,
	    internalcategory5 = @ware_internalcategory5,
	    internalcategoryshort1 = @ware_internalcategoryshort1,
	    internalcategoryshort2 = @ware_internalcategoryshort2,
	    internalcategoryshort3 = @ware_internalcategoryshort3,
	    internalcategoryshort4 = @ware_internalcategoryshort4,
	    internalcategoryshort5 = @ware_internalcategoryshort5,
	    internalcategory6 = @ware_internalcategory6,
	    internalcategory7 = @ware_internalcategory7,
	    internalcategory8 = @ware_internalcategory8,
	    internalcategory9 = @ware_internalcategory9,
	    internalcategory10 = @ware_internalcategory10,
	    internalcategoryshort6 = @ware_internalcategoryshort6,
	    internalcategoryshort7 = @ware_internalcategoryshort7,
	    internalcategoryshort8 = @ware_internalcategoryshort8,
	    internalcategoryshort9 = @ware_internalcategoryshort9,
	    internalcategoryshort10 = @ware_internalcategoryshort10
			where bookkey = @ware_bookkey

commit tran
/**if SQL%ROWCOUNT > 0 then
	commit
else
	INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
		'Unable to update whtitleclass table - for bookcategory',
		'Warning/data error',
		'Stored procedure datawarehouse_category','WARE_STORED_PROC', @ware_system_date)
	commit
end if
**/
close warehousecategory
deallocate warehousecategory

GO