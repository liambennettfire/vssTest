SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO









ALTER  proc dbo.yupupdatereleasedate
AS

	DECLARE @v_bookkey		    int
	DECLARE @v_printingkey		    int
	DECLARE @i_bookkey		    int
	DECLARE @i_count		    int
	DECLARE @c_lastuserid               varchar(30)
	DECLARE @d_releasedate_est	    datetime
	DECLARE @d_releasedate_actual	    datetime
	DECLARE @d_warehousedate_est        datetime
	DECLARE @d_warehousedate_actual     datetime
	DECLARE @d_warehousedate_in_actual  datetime
	DECLARE @d_warehousedate_in_est     datetime
	DECLARE @d_releasedate_out_actual   datetime
	DECLARE @d_releasedate_out_est      datetime

BEGIN 

	DECLARE cursor_dates INSENSITIVE CURSOR
	FOR
			select  bookkey,
				printingkey,
				estdate,
				activedate
			from  bookdates
			where  datetypecode = 47 and
			      bookkey + printingkey in (select bookkey + printingkey from yupwhforecastkeys)
			     	
				


	FOR READ ONLY

	OPEN cursor_dates 

		FETCH NEXT FROM cursor_dates INTO @v_bookkey, @v_printingkey,
							@d_warehousedate_est,
							@d_warehousedate_actual
							

		select @i_bookkey  = @@FETCH_STATUS

		 while (@i_bookkey>-1 )
	begin
			IF (@i_bookkey<>-2)
		begin

		Select @d_warehousedate_in_actual = @d_warehousedate_actual
      		Select @d_warehousedate_in_est =    @d_warehousedate_est			
		
		/* Set release date to the first Monday after the warehouse date */
		Select 	@d_releasedate_out_actual =
			CASE
			 WHEN DatePart(dw,@d_warehousedate_in_actual) = 1 THEN DateAdd(day,1,@d_warehousedate_in_actual)
			 WHEN DatePart(dw,@d_warehousedate_in_actual) = 2 THEN DateAdd(day,7,@d_warehousedate_in_actual)
			 WHEN DatePart(dw,@d_warehousedate_in_actual) = 3 THEN DateAdd(day,6,@d_warehousedate_in_actual)
			 WHEN DatePart(dw,@d_warehousedate_in_actual) = 4 THEN DateAdd(day,5,@d_warehousedate_in_actual)
			 WHEN DatePart(dw,@d_warehousedate_in_actual) = 5 THEN DateAdd(day,4,@d_warehousedate_in_actual)
			 WHEN DatePart(dw,@d_warehousedate_in_actual) = 6 THEN DateAdd(day,3,@d_warehousedate_in_actual)
			 WHEN DatePart(dw,@d_warehousedate_in_actual) = 7 THEN DateAdd(day,2,@d_warehousedate_in_actual)
			END

		/* Set release date to the first Monday after the warehouse date */
		Select 	@d_releasedate_out_est =
			CASE
			 WHEN DatePart(dw,@d_warehousedate_in_est) = 1 THEN DateAdd(day,1,@d_warehousedate_in_est)
			 WHEN DatePart(dw,@d_warehousedate_in_est) = 2 THEN DateAdd(day,7,@d_warehousedate_in_est)
			 WHEN DatePart(dw,@d_warehousedate_in_est) = 3 THEN DateAdd(day,6,@d_warehousedate_in_est)
			 WHEN DatePart(dw,@d_warehousedate_in_est) = 4 THEN DateAdd(day,5,@d_warehousedate_in_est)
			 WHEN DatePart(dw,@d_warehousedate_in_est) = 5 THEN DateAdd(day,4,@d_warehousedate_in_est)
			 WHEN DatePart(dw,@d_warehousedate_in_est) = 6 THEN DateAdd(day,3,@d_warehousedate_in_est)
			 WHEN DatePart(dw,@d_warehousedate_in_est) = 7 THEN DateAdd(day,2,@d_warehousedate_in_est)
			END
		
		
		/* Test to see if this Title has a Release Date */
		Select @i_count = 0

		Select @i_count = count(*) from bookdates 
			where datetypecode =32 and
			      bookkey = @v_bookkey and
			      printingkey = @v_printingkey

		/* If a title doesn't have Release Date, create a row for it */


		If @i_count = 0 and @d_warehousedate_actual is not null
		   begin /* Insert actual date */
			insert into bookdates
			Select @v_bookkey, @v_printingkey, 32, @d_releasedate_out_actual, NULL, NULL, 'qsiupd', getdate(), NULL, NULL, NULL, NULL
		   end
		Else if @i_count = 0 and @d_warehousedate_est is not null
		   begin /* Insert est date */
			insert into bookdates
			Select @v_bookkey, @v_printingkey, 32, NULL, NULL, NULL, 'qsiupd', getdate(), @d_releasedate_out_est, NULL, NULL, NULL		
		   end

		If @i_count > 0
		  select @c_lastuserid = lastuserid 
			from bookdates 
			where datetypecode =32 
			and bookkey = @v_bookkey
			and printingkey = @v_printingkey


		/* If title already has a Release Date, update it*/

		If @i_count > 0 and @d_warehousedate_actual is not null -- and @c_lastuserid = 'qsiupd' MANUAL OVERRRIDE
		   begin /* Update acutal date */
			update bookdates 
				set activedate = @d_releasedate_out_actual,
				    lastmaintdate = getdate(),
				    lastuserid = 'qsiupd'
				where bookkey = @v_bookkey and
				      printingkey = @v_printingkey and
				      datetypecode = 32

		   end
		If @i_count > 0 and @d_warehousedate_est is not null  -- and @c_lastuserid = 'qsiupd' MANUAL OVERRRIDE
		   begin /* Update est date */
			update bookdates 
				set estdate = @d_releasedate_out_est,
				    lastmaintdate = getdate(),
				    lastuserid = 'qsiupd'
				where bookkey = @v_bookkey and
				      printingkey = @v_printingkey and
				      datetypecode = 32

		   end
		end
		
			
 		FETCH NEXT FROM cursor_dates
			INTO @v_bookkey, 
			     @v_printingkey,
				@d_warehousedate_est,
				@d_warehousedate_actual
	
	    	  select @i_bookkey  = @@FETCH_STATUS
	
	      end /*bookkey status status 1*/

close cursor_dates
deallocate cursor_dates
end






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

