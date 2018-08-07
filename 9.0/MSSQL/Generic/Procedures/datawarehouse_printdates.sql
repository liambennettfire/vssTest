
PRINT 'STORED PROCEDURE : dbo.datawarehouse_printdates'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_printdates') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_printdates
end

GO
create proc dbo.datawarehouse_printdates
@ware_bookkey int,@ware_printingkey int,
@ware_logkey int, @ware_warehousekey int, @ware_system_date datetime 
AS 

DECLARE @ware_count int
DECLARE @ware_dateline  int
DECLARE @estdate  datetime
DECLARE @actdate  datetime
DECLARE @bestdate  datetime

DECLARE @ware_est1  datetime
DECLARE @ware_act1  datetime
DECLARE @ware_best1 datetime
DECLARE @ware_est2  datetime
DECLARE @ware_act2  datetime
DECLARE @ware_best2 datetime
DECLARE @ware_est3  datetime
DECLARE @ware_act3  datetime
DECLARE @ware_best3 datetime
DECLARE @ware_est4  datetime
DECLARE @ware_act4  datetime
DECLARE @ware_best4 datetime
DECLARE @ware_est5  datetime
DECLARE @ware_act5  datetime
DECLARE @ware_best5 datetime
DECLARE @ware_est6  datetime
DECLARE @ware_act6  datetime
DECLARE @ware_best6 datetime
DECLARE @ware_est7  datetime
DECLARE @ware_act7  datetime
DECLARE @ware_best7 datetime
DECLARE @ware_est8  datetime
DECLARE @ware_act8  datetime
DECLARE @ware_best8 datetime
DECLARE @ware_est9  datetime
DECLARE @ware_act9  datetime
DECLARE @ware_best9 datetime
DECLARE @ware_est10  datetime
DECLARE @ware_act10  datetime
DECLARE @ware_best10 datetime
DECLARE @ware_est11  datetime
DECLARE @ware_act11  datetime
DECLARE @ware_best11 datetime
DECLARE @ware_est12  datetime
DECLARE @ware_act12  datetime
DECLARE @ware_best12 datetime
DECLARE @ware_est13  datetime
DECLARE @ware_act13  datetime
DECLARE @ware_best13 datetime
DECLARE @ware_est14  datetime
DECLARE @ware_act14  datetime
DECLARE @ware_best14 datetime
DECLARE @ware_est15  datetime
DECLARE @ware_act15  datetime
DECLARE @ware_best15 datetime
DECLARE @ware_est16  datetime
DECLARE @ware_act16  datetime
DECLARE @ware_best16 datetime
DECLARE @ware_est17  datetime
DECLARE @ware_act17  datetime
DECLARE @ware_best17 datetime
DECLARE @ware_est18  datetime
DECLARE @ware_act18  datetime
DECLARE @ware_best18 datetime
DECLARE @ware_est19  datetime
DECLARE @ware_act19  datetime
DECLARE @ware_best19 datetime
DECLARE @ware_est20  datetime
DECLARE @ware_act20  datetime
DECLARE @ware_best20 datetime
DECLARE @i_datetypecode int
DECLARE @d_activedate datetime
DECLARE @d_estdate datetime
DECLARE @i_datestatus int

DECLARE @temp_actdate datetime

DECLARE warehouseprintdates INSENSITIVE CURSOR
FOR
	SELECT b.datetypecode, activedate,estdate
		    FROM bookdates b
		   	WHERE  bookkey = @ware_bookkey
				AND printingkey = @ware_printingkey
				ORDER BY  datetypecode


FOR READ ONLY

OPEN warehouseprintdates

FETCH NEXT FROM warehouseprintdates
INTO @i_datetypecode,@d_activedate,@d_estdate

select @i_datestatus = @@FETCH_STATUS

 while (@i_datestatus<>-1 )
   begin
	IF (@i_datestatus<>-2)
	  begin

		select @ware_count = 0
		select @ware_count = count(*)
			from whcprintingdates
				where datetypecode = @i_datetypecode
		if @ware_count > 0 
		  begin
			select  @ware_dateline = min(linenumber)
				from whcprintingdates
					where datetypecode = @i_datetypecode

			if @ware_dateline > 0 
		 		 begin
					select @estdate = @d_estdate
					select @actdate = @d_activedate
					select @temp_actdate = @d_activedate

			if @temp_actdate is null
			  begin
				select @bestdate =@estdate
			  end
			else
			  begin
				select @bestdate = @actdate
			  end
			end
			if @ware_dateline = 1 
			  begin
				select @ware_est1 = @estdate
				select @ware_act1  = @actdate
				select @ware_best1 = @bestdate
			  end
			if @ware_dateline = 2 
			  begin
				select @ware_est2 = @estdate
				select @ware_act2  = @actdate
				select @ware_best2 = @bestdate
			  end
			if @ware_dateline = 3 
			  begin
				select @ware_est3 = @estdate
				select @ware_act3  = @actdate
				select @ware_best3 = @bestdate
			  end
			if @ware_dateline = 4 
			  begin
				select @ware_est4 = @estdate
				select @ware_act4  = @actdate
				select @ware_best4 = @bestdate
			  end
			if @ware_dateline = 5 
			  begin
				select @ware_est5 = @estdate
				select @ware_act5  = @actdate
				select @ware_best5 = @bestdate
			  end
			if @ware_dateline = 6
			  begin
				select @ware_est6 = @estdate
				select @ware_act6  = @actdate
				select @ware_best6 = @bestdate
			  end
			if @ware_dateline = 7 
			  begin
				select @ware_est7 = @estdate
				select @ware_act7  = @actdate
				select @ware_best7 = @bestdate
			  end
			if @ware_dateline = 8 	
			  begin
				select @ware_est8 = @estdate
				select @ware_act8  = @actdate
				select @ware_best8 = @bestdate
			  end
			if @ware_dateline = 9 
			  begin
				select @ware_est9 = @estdate
				select @ware_act9  = @actdate
				select @ware_best9 = @bestdate
			  end
			if @ware_dateline = 10 
			  begin
				select @ware_est10 = @estdate
				select @ware_act10  = @actdate
				select @ware_best10 = @bestdate
			  end
			if @ware_dateline = 11 
			  begin
				select @ware_est11 = @estdate
				select @ware_act11  = @actdate
				select @ware_best11 = @bestdate
			  end
			if @ware_dateline = 12 		
			  begin
				select @ware_est12 = @estdate
				select @ware_act12  = @actdate
				select @ware_best12 = @bestdate
			  end
			if @ware_dateline = 13 
			  begin
				select @ware_est13 = @estdate
				select @ware_act13  = @actdate
				select @ware_best13 = @bestdate
			  end
			if @ware_dateline = 14 
			  begin
				select @ware_est14 = @estdate
				select @ware_act14  = @actdate
				select @ware_best14 = @bestdate
			  end
			if @ware_dateline = 15 	
			  begin
				select @ware_est15 = @estdate
				select @ware_act15  = @actdate
				select @ware_best15 = @bestdate
			  end
			if @ware_dateline = 16 
			  begin
				select @ware_est16 = @estdate
				select @ware_act16  = @actdate
				select @ware_best16 = @bestdate
			  end
			if @ware_dateline = 17 	
			  begin
				select @ware_est17 = @estdate
				select @ware_act17  = @actdate
				select @ware_best17 = @bestdate
			  end
			if @ware_dateline = 18 
			  begin
				select @ware_est18 = @estdate
				select @ware_act18  = @actdate
				select @ware_best18 = @bestdate
			  end
			if @ware_dateline = 19 	
			  begin
				select @ware_est19 = @estdate
				select @ware_act19  = @actdate
				select @ware_best19 = @bestdate
			  end
			if @ware_dateline = 20 	
			   begin
				select @ware_est20 = @estdate
				select @ware_act20  = @actdate
				select @ware_best20 = @bestdate
			  end
		  end
	end	/*<>2*/

	FETCH NEXT FROM warehouseprintdates
		INTO @i_datetypecode,@d_activedate,@d_estdate

	select @i_datestatus = @@FETCH_STATUS
 end
close warehouseprintdates
deallocate warehouseprintdates

BEGIN tran
INSERT INTO  whprintingkeydates
	(bookkey,printingkey,estdate1 ,actdate1 ,bestdate1,estdate2,actdate2,bestdate2,
	estdate3,actdate3,bestdate3,estdate4,actdate4,bestdate4,estdate5,
	actdate5,bestdate5,estdate6,actdate6,bestdate6,estdate7,actdate7,
	bestdate7,estdate8,actdate8,bestdate8,estdate9,actdate9,bestdate9,
	estdate10,actdate10,bestdate10,estdate11,actdate11,bestdate11,
	estdate12,actdate12,bestdate12,estdate13,actdate13,bestdate13,
	estdate14,actdate14,bestdate14,estdate15,actdate15,bestdate15,
	estdate16,actdate16,bestdate16,estdate17,actdate17,bestdate17,
	estdate18,actdate18,bestdate18,estdate19,actdate19,bestdate19,
	estdate20,actdate20,bestdate20,lastuserid,lastmaintdate)
VALUES (@ware_bookkey,@ware_printingkey,@ware_est1,@ware_act1 ,@ware_best1,@ware_est2 ,@ware_act2,
	@ware_best2 ,@ware_est3,@ware_act3,@ware_best3,@ware_est4,@ware_act4,
	@ware_best4,@ware_est5,@ware_act5,@ware_best5,@ware_est6,@ware_act6,
	@ware_best6,@ware_est7,@ware_act7,@ware_best7,@ware_est8,@ware_act8,
	@ware_best8,@ware_est9,@ware_act9 ,@ware_best9,@ware_est10,@ware_act10,
	@ware_best10,@ware_est11,@ware_act11 ,@ware_best11,@ware_est12,@ware_act12,
	@ware_best12,@ware_est13,@ware_act13,@ware_best13,@ware_est14,@ware_act14,
	@ware_best14 ,@ware_est15,@ware_act15,@ware_best15,@ware_est16,@ware_act16,
	@ware_best16,@ware_est17,@ware_act17,@ware_best17,@ware_est18,@ware_act18,
	@ware_best18,@ware_est19,@ware_act19,@ware_best19,@ware_est20,@ware_act20,
	@ware_best20,'WARE_STORED_PROC',@ware_system_date)
commit tran
GO
/**if SQL%ROWCOUNT > 0 begin
	commit
else
	INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(ware_logkey)  ,to_char(ware_warehousekey),
		'Unable to insert whtitledates table - for book dates',
		('Warning/data error bookkey '||to_char(ware_bookkey)),'Stored procedure datawarehouse_bookdates',
		'WARE_STORED_PROC', ware_system_date)
	commit
end if
**/

GO