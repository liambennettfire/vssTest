PRINT 'STORED PROCEDURE : dbo.datawarehouse_bookdates'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_bookdates') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_bookdates
end

GO

create proc dbo.datawarehouse_bookdates
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS 

DECLARE @i_datetypecode int
DECLARE @d_activedate datetime
DECLARE @d_estdate datetime

DECLARE @ware_count int
DECLARE @ware_dateline int
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
DECLARE @i_datestatus int
DECLARE @ware_est21  datetime
DECLARE @ware_act21  datetime
DECLARE @ware_best21 datetime
DECLARE @ware_est22  datetime
DECLARE @ware_act22  datetime
DECLARE @ware_best22 datetime
DECLARE @ware_est23  datetime
DECLARE @ware_act23  datetime
DECLARE @ware_best23 datetime
DECLARE @ware_est24  datetime
DECLARE @ware_act24  datetime
DECLARE @ware_best24 datetime
DECLARE @ware_est25  datetime
DECLARE @ware_act25  datetime
DECLARE @ware_best25 datetime
DECLARE @ware_est26  datetime
DECLARE @ware_act26  datetime
DECLARE @ware_best26 datetime
DECLARE @ware_est27  datetime
DECLARE @ware_act27  datetime
DECLARE @ware_best27 datetime
DECLARE @ware_est28  datetime
DECLARE @ware_act28  datetime
DECLARE @ware_best28 datetime
DECLARE @ware_est29  datetime
DECLARE @ware_act29  datetime
DECLARE @ware_best29 datetime
DECLARE @ware_est30  datetime
DECLARE @ware_act30  datetime
DECLARE @ware_best30 datetime
DECLARE @ware_est31  datetime
DECLARE @ware_act31  datetime
DECLARE @ware_best31 datetime
DECLARE @ware_est32  datetime
DECLARE @ware_act32  datetime
DECLARE @ware_best32 datetime
DECLARE @ware_est33  datetime
DECLARE @ware_act33  datetime
DECLARE @ware_best33 datetime
DECLARE @ware_est34  datetime
DECLARE @ware_act34  datetime
DECLARE @ware_best34 datetime
DECLARE @ware_est35  datetime
DECLARE @ware_act35  datetime
DECLARE @ware_best35 datetime
DECLARE @ware_est36  datetime
DECLARE @ware_act36  datetime
DECLARE @ware_best36 datetime
DECLARE @ware_est37  datetime
DECLARE @ware_act37  datetime
DECLARE @ware_best37 datetime
DECLARE @ware_est38  datetime
DECLARE @ware_act38  datetime
DECLARE @ware_best38 datetime
DECLARE @ware_est39  datetime
DECLARE @ware_act39  datetime
DECLARE @ware_best39 datetime
DECLARE @ware_est40  datetime
DECLARE @ware_act40  datetime
DECLARE @ware_best40 datetime

DECLARE @temp_actdate datetime

DECLARE warehousedates INSENSITIVE CURSOR
FOR
	SELECT b.datetypecode,b.activedate,	b.estdate
		    FROM bookdates b
		   	WHERE  b.bookkey = @ware_bookkey
				AND b.printingkey = 1
				ORDER BY  datetypecode  
    
select @ware_count = 0

OPEN warehousedates

FETCH NEXT FROM warehousedates
INTO @i_datetypecode, @d_activedate,@d_estdate

select @i_datestatus = @@FETCH_STATUS

if @i_datestatus <> 0  /** NO Bookdates**/
    begin
	INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
	 	errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (convert(varchar, @ware_logkey)  ,convert(varchar,@ware_warehousekey),
		'No  Bookdates rows for this title,  inserting blanks in whtitledates table',
		('Warning/data error bookkey '+ convert(varchar,@ware_bookkey)),
		'Stored procedure datawarehouse_bookdates','WARE_STORED_PROC',@ware_system_date)
   end
 while (@i_datestatus<>-1 )
   begin

	IF (@i_datestatus<>-2)
	  begin

	select @ware_count = 0
	select @ware_count = count(*) 
			from whcdatetype
				where datetypecode = @i_datetypecode
	IF @ware_count>0 
	  begin
		select @ware_dateline = linenumber
				from whcdatetype
					where datetypecode = @i_datetypecode
		IF datalength(@ware_dateline) > 0
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

			if @ware_dateline = 1 
			  begin
				select @ware_est1 = @estdate
				select @ware_act1  =  @actdate
				select @ware_best1 =  @bestdate
			  end
			if @ware_dateline = 2 
			  begin
				select @ware_est2 =  @estdate
				select @ware_act2  =  @actdate
				select @ware_best2 =  @bestdate
			  end
			if @ware_dateline = 3 
			  begin
				select @ware_est3 =  @estdate
				select @ware_act3  =  @actdate
				select @ware_best3 =  @bestdate
			  end
			if @ware_dateline = 4 
			  begin
				select @ware_est4 =  @estdate
				select @ware_act4  =  @actdate
				select @ware_best4 =  @bestdate
			  end
			if @ware_dateline = 5 
			  begin
				select @ware_est5 =  @estdate
				select @ware_act5  =  @actdate
				select @ware_best5 =  @bestdate
			  end
			if @ware_dateline = 6 	
			  begin
				select @ware_est6 =  @estdate
				select @ware_act6  =  @actdate
				select @ware_best6 =  @bestdate
			  end
			if @ware_dateline = 7 
			  begin
				select @ware_est7 =  @estdate
				select @ware_act7  =  @actdate
				select @ware_best7 =  @bestdate
			  end
			if @ware_dateline = 8 
			  begin
				select @ware_est8 =  @estdate
				select @ware_act8  =  @actdate
				select @ware_best8 =  @bestdate
			  end
			if @ware_dateline = 9 
			  begin
				select @ware_est9 =  @estdate
				select @ware_act9  =  @actdate
				select @ware_best9 =  @bestdate
			  end
			if @ware_dateline = 10 	
			  begin
				select @ware_est10 =  @estdate
				select @ware_act10  =  @actdate
				select @ware_best10 =  @bestdate
			  end
			if @ware_dateline = 11 
			  begin
				select @ware_est11 =  @estdate
				select @ware_act11  =  @actdate
				select @ware_best11 =  @bestdate
			  end
			if @ware_dateline = 12 
			  begin
				select @ware_est12 =  @estdate
				select @ware_act12  =  @actdate
				select @ware_best12 =  @bestdate
			  end
			if @ware_dateline = 13 
			  begin
				select @ware_est13 =  @estdate
				select @ware_act13  =  @actdate
				select @ware_best13 =  @bestdate
			  end
			if @ware_dateline = 14 
			  begin
				select @ware_est14 =  @estdate
				select @ware_act14  =  @actdate
				select @ware_best14 =  @bestdate
			  end
			if @ware_dateline = 15 
			  begin
				select @ware_est15 =  @estdate
				select @ware_act15  =  @actdate
				select @ware_best15 =  @bestdate
			  end
			if @ware_dateline = 16 
			  begin
				select @ware_est16 =  @estdate
				select @ware_act16  =  @actdate
				select @ware_best16 =  @bestdate
			  end
			if @ware_dateline = 17 
			  begin
				select @ware_est17 =  @estdate
				select @ware_act17  =  @actdate
				select @ware_best17 =  @bestdate
			  end
			if @ware_dateline = 18 
			  begin
				select @ware_est18 =  @estdate
				select @ware_act18  =  @actdate
				select @ware_best18 =  @bestdate
			  end
			if @ware_dateline = 19 
			  begin
				select @ware_est19 =  @estdate
				select @ware_act19  =  @actdate
				select @ware_best19 =  @bestdate
			  end
			if @ware_dateline = 20 
			  begin
				select @ware_est20 =  @estdate
				select @ware_act20  =  @actdate
				select @ware_best20 =  @bestdate
			 end
			if @ware_dateline = 21 
			  begin
				select @ware_est21 = @estdate
				select @ware_act21  = @actdate
				select @ware_best21 = @bestdate
			  end
			if @ware_dateline = 22 
			 begin
				select @ware_est22 = @estdate
				select @ware_act22  = @actdate
				select @ware_best22 = @bestdate
			  end
			if @ware_dateline = 23 
			  begin
				select @ware_est23 = @estdate
				select @ware_act23  = @actdate
				select @ware_best23 = @bestdate
			  end
			if @ware_dateline = 24 
			  begin
				select @ware_est24 = @estdate
				select @ware_act24  = @actdate
				select @ware_best24 = @bestdate
			  end
			if @ware_dateline = 25 
			  begin
				select @ware_est25 = @estdate
				select @ware_act25  = @actdate
				select @ware_best25 = @bestdate
			  end
			if @ware_dateline = 26 
			  begin
				select @ware_est26 = @estdate
				select @ware_act26  = @actdate
				select @ware_best26 = @bestdate
			  end
			if @ware_dateline = 27 
			  begin
				select @ware_est27 = @estdate
				select @ware_act27  = @actdate
				select @ware_best27 = @bestdate
			  end
			if @ware_dateline = 28 
			  begin
				select @ware_est28 = @estdate
				select @ware_act28  = @actdate
				select @ware_best28 = @bestdate
			  end
			if @ware_dateline = 29 
			  begin
				select @ware_est29 = @estdate
				select @ware_act29  = @actdate
				select @ware_best29 = @bestdate
			  end
			if @ware_dateline = 30
			  begin
				select @ware_est30 = @estdate
				select @ware_act30  = @actdate
				select @ware_best30 = @bestdate
			  end
			if @ware_dateline = 31 
			  begin
				select @ware_est31 = @estdate
				select @ware_act31  = @actdate
				select @ware_best31 = @bestdate
			  end
			if @ware_dateline = 32 
			  begin
				select @ware_est32 = @estdate
				select @ware_act32  = @actdate
				select @ware_best32 = @bestdate
			  end
			if @ware_dateline = 33 
			  begin
				select @ware_est33 = @estdate
				select @ware_act33  = @actdate
				select @ware_best33 = @bestdate
			  end
			if @ware_dateline = 34 
			  begin
				select @ware_est34 = @estdate
				select @ware_act34  = @actdate
				select @ware_best34 = @bestdate
			  end
			if @ware_dateline = 35 
			   begin
				select @ware_est35 = @estdate
				select @ware_act35  = @actdate
				select @ware_best35 = @bestdate
			  end
			if @ware_dateline = 36
			  begin
				select @ware_est36 = @estdate
				select @ware_act36  = @actdate
				select @ware_best36 = @bestdate
			  end
			if @ware_dateline = 37 
			  begin
				select @ware_est37 = @estdate
				select @ware_act37  = @actdate
				select @ware_best37 = @bestdate
			  end
			if @ware_dateline = 38
			  begin
				select @ware_est38 = @estdate
				select @ware_act38  = @actdate
				select @ware_best38 = @bestdate
			  end
			if @ware_dateline = 39 
			  begin
				select @ware_est39 = @estdate
				select @ware_act39  = @actdate
				select @ware_best39 = @bestdate
			  end
			if @ware_dateline = 40 
			  begin
				select @ware_est40 = @estdate
				select @ware_act40  = @actdate
				select @ware_best40 = @bestdate
			  end
		end
	end
end	/*<>2*/

	FETCH NEXT FROM warehousedates
	INTO @i_datetypecode, @d_activedate,@d_estdate

	select @i_datestatus = @@FETCH_STATUS
end

BEGIN tran
INSERT INTO  whtitledates
	(bookkey,estdate1 ,actdate1 ,bestdate1,estdate2,actdate2,bestdate2,
	estdate3,actdate3,bestdate3,estdate4,actdate4,bestdate4,estdate5,
	actdate5,bestdate5,estdate6,actdate6,bestdate6,estdate7,actdate7,
	bestdate7,estdate8,actdate8,bestdate8,estdate9,actdate9,bestdate9,
	estdate10,actdate10,bestdate10,estdate11,actdate11,bestdate11,
	estdate12,actdate12,bestdate12,estdate13,actdate13,bestdate13,
	estdate14,actdate14,bestdate14,estdate15,actdate15,bestdate15,
	estdate16,actdate16,bestdate16,estdate17,actdate17,bestdate17,
	estdate18,actdate18,bestdate18,estdate19,actdate19,bestdate19,
	estdate20,actdate20,bestdate20,lastuserid,lastmaintdate,
	estdate21,actdate21,bestdate21,
	estdate22,actdate22,bestdate22,estdate23,actdate23,bestdate23,
	estdate24,actdate24,bestdate24,estdate25,actdate25,bestdate25,
	estdate26,actdate26,bestdate26,estdate27,actdate27,bestdate27,
	estdate28,actdate28,bestdate28,estdate29,actdate29,bestdate29,
	estdate30,actdate30,bestdate30,estdate31,actdate31,bestdate31,
	estdate32,actdate32,bestdate32,estdate33,actdate33,bestdate33,
	estdate34,actdate34,bestdate34,estdate35,actdate35,bestdate35,
	estdate36,actdate36,bestdate36,estdate37,actdate37,bestdate37,
	estdate38,actdate38,bestdate38,estdate39,actdate39,bestdate39,
	estdate40,actdate40,bestdate40)
VALUES (@ware_bookkey,@ware_est1,@ware_act1 ,@ware_best1,@ware_est2 ,@ware_act2,
	@ware_best2 ,@ware_est3,@ware_act3,@ware_best3,@ware_est4,@ware_act4,
	@ware_best4,@ware_est5,@ware_act5,@ware_best5,@ware_est6,@ware_act6,
	@ware_best6,@ware_est7,@ware_act7,@ware_best7,@ware_est8,@ware_act8,
	@ware_best8,@ware_est9,@ware_act9 ,@ware_best9,@ware_est10,@ware_act10,
	@ware_best10,@ware_est11,@ware_act11 ,@ware_best11,@ware_est12,@ware_act12,
	@ware_best12,@ware_est13,@ware_act13,@ware_best13,@ware_est14,@ware_act14,
	@ware_best14 ,@ware_est15,@ware_act15,@ware_best15,@ware_est16,@ware_act16,
	@ware_best16,@ware_est17,@ware_act17,@ware_best17,@ware_est18,@ware_act18,
	@ware_best18,@ware_est19,@ware_act19,@ware_best19,@ware_est20,@ware_act20,
	@ware_best20,'WARE_STORED_PROC',@ware_system_date,@ware_est21,@ware_act21,
	@ware_best21,@ware_est22,@ware_act22,
	@ware_best22,@ware_est23,@ware_act23,@ware_best23,@ware_est24,@ware_act24,
	@ware_best24 ,@ware_est25,@ware_act25,@ware_best25,@ware_est26,@ware_act26,
	@ware_best26,@ware_est27,@ware_act27,@ware_best27,@ware_est28,@ware_act28,
	@ware_best28,@ware_est29,@ware_act29,@ware_best29,@ware_est30,@ware_act30,
	@ware_best30,@ware_est31,@ware_act31 ,@ware_best31,@ware_est32,@ware_act32,
	@ware_best32,@ware_est33,@ware_act33,@ware_best33,@ware_est34,@ware_act34,
	@ware_best34 ,@ware_est35,@ware_act35,@ware_best35,@ware_est36,@ware_act36,
	@ware_best36,@ware_est37,@ware_act37,@ware_best37,@ware_est38,@ware_act38,
	@ware_best38,@ware_est39,@ware_act39,@ware_best39,@ware_est40,@ware_act40,
	@ware_best40);

commit tran
/**if >0 begin 
	INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc, 
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
		'Unable to insert whtitledates table - for book dates',
		('Warning/data error bookkey '||to_char(@ware_bookkey)),
		'Stored procedure datawarehouse_bookdates','WARE_STORED_PROC',@ware_system_date); 
end if
**/
close warehousedates
deallocate warehousedates


GO