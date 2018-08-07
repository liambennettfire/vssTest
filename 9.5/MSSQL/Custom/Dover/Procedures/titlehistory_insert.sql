PRINT 'STORED PROCEDURE : dbo.titlehistory_insert'
GO


if exists (select * from dbo.sysobjects where id = Object_id('dbo.titlehistory_insert') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.titlehistory_insert
end

GO

create proc dbo.titlehistory_insert
@columnname  varchar(30),
@tablename varchar(80),
@bookkey int,
@printingkey int,
@otherinfo varchar(20),
@newvalue varchar(100),
@triggereloind tinyint

AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime

DECLARE @feedin_columnkey  int
DECLARE @currentvalue varchar(100)
DECLARE @currentvalue_int  int
DECLARE @currentvalue_date  datetime
DECLARE @currentvalue_numeric float
DECLARE @feedin_datatype varchar(1)
DECLARE @feedin_fielddesc varchar(40)
DECLARE @feedin_count int
DECLARE @feedin_count2 int
DECLARE @feedin_count3 int
DECLARE @stringvalue	varchar(100)
DECLARE @lv_edipartnerkey int
DECLARE @i_gen1ind int


/*1-11-05 CRM 2289  test edistatuscode before changing to send*/

BEGIN tran 

	SELECT @feed_system_date = getdate()

	if @triggereloind <> 1  /*update eloquence tables if 1 only*/
	    begin
		select @triggereloind = 0
	   end

	select @feedin_count = 0	
 	
	select @feedin_count =count(*)  
		from titlehistorycolumns 
			where  tablename= @tablename
			   and columnname=@columnname


	if  @feedin_count > 0 
	  begin
		select @feedin_datatype = datatype, @feedin_columnkey=columnkey,
			@feedin_fielddesc =columndescription 
			from titlehistorycolumns 
				where  tablename = @tablename 
				     and columnname=@columnname
	end
	else
	 begin
		insert into feederror 							
			(isbn,batchnumber,processdate,errordesc)
		values (convert(char,10,@bookkey),'3',@feed_system_date,('There is no titlehistory column for this value ' + @tablename +' '+@columnname))
		RETURN 0
	 end


	if  @feedin_count > 0 
	  begin
 	/*possible values pubmonth taken care off with pub date; bookweigth */
		if @feedin_datatype = 'i'
		  begin
		  if upper(rtrim(@tablename)) ='PRINTING' and @columnname = 'PUBMONTHCODE'
		     begin
			
			select @feedin_count2 = 0

			select @feedin_count2 = count(*) 
				from PRINTING
				  where bookkey = @bookkey
					and printingkey = @printingkey
			if @feedin_count2 > 0 
			  begin
				select @currentvalue_int = pubmonthcode
				from PRINTING
				  where bookkey = @bookkey
					and printingkey = @printingkey
			  end
			  else
			  begin
			    select @currentvalue_int = null
			  end

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(char,@currentvalue_int)
			  end
		     end
		/* cartonqty code */
		if upper(rtrim(@tablename)) = 'BINDINGSPECS' and upper(rtrim(@columnname)) = 'CARTONQTY1'  /*cartonqty1*/
	 	  begin
			select @feedin_count2 = 0

			select @feedin_count2 = count(*)
				from BINDINGSPECS
				 	 where bookkey = @bookkey
						and printingkey = @printingkey
			if @feedin_count2 > 0 
			  begin
				select @currentvalue_int = cartonqty1
					from BINDINGSPECS
				 	 where bookkey = @bookkey
						and printingkey = @printingkey
			  end
			else
			  begin
				select @currentvalue_int = null
			  end


			if @currentvalue_int is null 
			  begin
				select @stringvalue = '(Not Present)'
			  end
			else
			  begin	
				select @stringvalue = convert(char,@currentvalue_int)
			   end
		  end

 		if upper(rtrim(@tablename)) ='BOOK' and @columnname = 'TERRITORIESCODE'
		     begin
			
			select @feedin_count2 = 0

			select @feedin_count2 = count(*) 
				from BOOK
				  where bookkey = @bookkey
			if @feedin_count2 > 0 
			  begin
				select @currentvalue_int = territoriescode
				from BOOK
				  where bookkey = @bookkey
			  end
			  else
			  begin
			    select @currentvalue_int = null
			  end

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(char,@currentvalue_int)
			  end
		     end

 		if upper(rtrim(@tablename)) ='BOOKSIMON' and @columnname = 'BOOKWEIGHT'
		     begin
			
			select @feedin_count2 = 0

			select @feedin_count2 = count(*) 
				from BOOKSIMON
				  where bookkey = @bookkey
			if @feedin_count2 > 0 
			  begin
				select @currentvalue_numeric = bookweight
				from BOOKSIMON
				  where bookkey = @bookkey
			  end
			  else
			  begin
			    select @currentvalue_numeric = null
			  end

			if @currentvalue_numeric is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_numeric = 0
			  end
			else
			  begin
				select @stringvalue = convert(char,@currentvalue_numeric)
			  end
		     end

		end  /* int data*/
  
		if @feedin_datatype = 'a' OR @feedin_datatype = 'd' /*possible values retailprice,pubdate,reldate,canadianprice */
		     begin

	 	   if upper(rtrim(@tablename)) ='BOOKDETAIL' and @columnname = 'BISACSTATUSCODE' /*BISAC*/
		     begin
				select @currentvalue_int = bisacstatuscode
				from BOOKDETAIL
				  where bookkey = @bookkey

			if @currentvalue_int is null
			  begin
				select @stringvalue = '(Not Present)'
				select @currentvalue_int = 0
			  end
			else
			  begin
				select @stringvalue = convert(char,@currentvalue_int)
			  end
			end

			 if upper(rtrim(@tablename)) ='BOOKDATES' and  upper(rtrim(@otherinfo)) ='8'  /*pubdate*/
			   begin
				select @feedin_count2 = 0

				select @feedin_count2 = count(*) 
					from BOOKDATES
				  		where datetypecode=8 
							and printingkey= @printingkey
							and bookkey = @bookkey
				if @feedin_count2 > 0 
			  	  begin
			          select @currentvalue_date = activedate
				      from BOOKDATES
				    	  where datetypecode=8 
						and printingkey= @printingkey
						and bookkey = @bookkey
				  end
				  else
				  begin
			    		select @currentvalue_date = null
			  	  end

     			   if @currentvalue_date is null
			       begin
				  select @stringvalue = '(Not Present)'
				  select @currentvalue_date = ''
			      end
			    else
			      begin
				select @stringvalue = convert(char,@currentvalue_date)
			      end 
			    select @feedin_fielddesc = @feedin_fielddesc + ' pub date'
     		          end

			   if upper(rtrim(@tablename)) ='BOOKDATES' and  upper(rtrim(@otherinfo)) ='47' /*reldate*/
				begin
				  select @feedin_count2 = 0

				 select @feedin_count2 = count(*) 
				   from BOOKDATES
				  	where datetypecode=47
						and printingkey= @printingkey
						and bookkey = @bookkey
				  if @feedin_count2 > 0
				   begin
					  select @currentvalue_date = activedate
						   from BOOKDATES
						  	where datetypecode=47
								and printingkey= @printingkey
								and bookkey = @bookkey
				  end
				  else
				  begin
			    		select @currentvalue_date = null
			  	  end

			     if @currentvalue_date is null
			       begin
				  select @stringvalue = '(Not Present)'
				  select @currentvalue_date = ''
			      end
			    else
			      begin
				select @stringvalue = convert(char,@currentvalue_date)
			      end 
		              select @feedin_fielddesc = @feedin_fielddesc + ' ware date'
     		          end 

			   /*12-23-03 add task date  -- 1/17/05 was using taskey instead of elementkey so history always created*/			
			   if upper(rtrim(@tablename)) ='TASK' and  upper(rtrim(@otherinfo)) ='8' /*schedule pub date*/
				begin
				   select @currentvalue_date = actualdate
						   from TASK
						  	where datetypecode=8
								and elementkey = @printingkey /*this is element key*/

			     if @currentvalue_date is null
			       begin
				  select @stringvalue = '(Not Present)'
				  select @currentvalue_date = ''
			      end
			    else
			      begin
				select @stringvalue = convert(char,@currentvalue_date)
			      end 
		              select @feedin_fielddesc = @feedin_fielddesc + ' task date'
     		          end 

 			  if upper(rtrim(@tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='8' /*retail price*/
			   begin
  				select @feedin_count2 = 0

				 select @feedin_count2 = count(*) 
				   from BOOKPRICE
				  	where pricetypecode=8 and currencytypecode=6
						and bookkey = @bookkey
				if @feedin_count2 > 0 
				  begin
				      select @currentvalue_numeric = finalprice
					   from BOOKPRICE
					  	where pricetypecode=8 and currencytypecode=6
							and bookkey = @bookkey
				end
				else
				begin
			    		select @currentvalue_numeric = null
			  	end

			   if @currentvalue_numeric is null
			       begin
				  select @stringvalue = '(Not Present)'
				  select @currentvalue_numeric = 0
			      end
			    else
			      begin
				select @stringvalue = convert(char,@currentvalue_numeric)
			      end 
     		          end 

			 if upper(rtrim(@tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='13' /*future price*/
			   begin
				select @feedin_count2 = 0

				 select @feedin_count2 = count(*) 
					from BOOKPRICE
				  		where pricetypecode=13 and currencytypecode=6
							and bookkey = @bookkey
				if @feedin_count2 > 0 
				  begin
 					select @currentvalue_numeric = finalprice
					   from BOOKPRICE
					  	where pricetypecode=13 and currencytypecode=6
							and bookkey = @bookkey
				  end 
				  else
				  begin
					select @currentvalue_numeric = null
			  	  end

			if @currentvalue_numeric is null
			       begin
				  select @stringvalue = '(Not Present)'
				  select @currentvalue_numeric = 0
			      end
			    else
			      begin
				select @stringvalue = convert(char,@currentvalue_numeric)
			      end 
     		          end 
			  
 			if upper(rtrim(@tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='11' /*canada price*/
			   begin
				select @feedin_count2 = 0

				 select @feedin_count2 = count(*) 
					from BOOKPRICE
				  		where pricetypecode=8 and currencytypecode=11
							and bookkey = @bookkey
				if @feedin_count2 > 0 
				  begin
 					select @currentvalue_numeric = finalprice
					   from BOOKPRICE
					  	where pricetypecode=8 and currencytypecode=11
							and bookkey = @bookkey
				  end 
				  else
				  begin
					select @currentvalue_numeric = null
			  	  end

			if @currentvalue_numeric is null
			       begin
				  select @stringvalue = '(Not Present)'
				  select @currentvalue_numeric = 0
			      end
			    else
			      begin
				select @stringvalue = convert(char,@currentvalue_numeric)
			      end 
     		          end 
			  
			if upper(rtrim(@tablename)) ='PRINTING' and @columnname = 'FIRSTPRINTINGQTY' /*ACTUAL QUANTITY*/
		  	   begin
				select @currentvalue_int = firstprintingqty
				from PRINTING
				  where bookkey = @bookkey
					and printingkey=1 
	
				if @currentvalue_int is null
				  begin
					select @stringvalue = '(Not Present)'
					select @currentvalue_int = 0
				  end
				else
				  begin
					select @stringvalue = convert(char,@currentvalue_int)
				  end
			end
	 	end  /*	end alpha description*/
	

		if rtrim(@stringvalue) <> rtrim(@newvalue)
		    begin
			if upper(rtrim(@tablename)) ='BOOKDETAIL' and @columnname = 'BISACSTATUSCODE' 
			   begin
			      if @stringvalue <> '(Not Present)' 
				  begin
			    		   select @stringvalue = datadesc from gentables where tableid=314 and 
						    datacode = convert(int,rtrim(@stringvalue))
				  end
				select @newvalue = datadesc from gentables where tableid=314 and 
				    datacode = convert(int,rtrim(@newvalue))
			   end
			if upper(rtrim(@tablename)) ='BOOK' and @columnname = 'TERRITORIESCODE' 
			   begin
			      if @stringvalue <> '(Not Present)' 
				  begin
			    		   select @stringvalue = datadesc from gentables where tableid=131 and 
						    datacode = convert(int,rtrim(@stringvalue))
				  end
				select @newvalue = datadesc from gentables where tableid=131 and 
				    datacode = convert(int,rtrim(@newvalue))
			   end

		  	   if upper(rtrim(@tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='8' /*retail price*/
			     begin
				select @newvalue = @newvalue + ' USDL'
			     end
			if upper(rtrim(@tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='13' /*FUTURE price*/
			     begin
				select @newvalue = @newvalue + ' USDL'
			     end

			    if upper(rtrim(@tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='11' /*retail price*/
			     begin
				select @newvalue = @newvalue + ' CAN'
			     end

			insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
				currentstringvalue,fielddesc)
			values (@bookkey,1,@feedin_columnkey,@feed_system_date,@stringvalue,'TOPSFEED',
				@newvalue,@feedin_fielddesc)
				
			if @triggereloind = 1 /* 11-11-03 update eloquence tables only if this is 1*/
			  begin

		/*	1-11-05 edistatuscode update
			check status before update gentables.gen1ind=1 then do not update to resend */
			
			    select @i_gen1ind = 0
			    select @feedin_count2 = 0
			    select @feedin_count2 = count(*) from bookedipartner
			 		where printingkey = 1 and bookkey = @bookkey
		 			

			    select @feedin_count3 = 0
			    select @feedin_count3 = count(*)  from bookedistatus
			 		where printingkey = 1 and bookkey = @bookkey

			    if @feedin_count3 > 0
			     begin /*rows present on bookedistatus*/
				/*check edistatuscode first*/
				select @i_gen1ind = gen1ind
					from bookedistatus b, gentables g
				  where b.edistatuscode = datacode and tableid=325
					and printingkey = 1 and bookkey = @bookkey

				if @i_gen1ind is null 
				  begin
				   	select @i_gen1ind = 0
				   end

				 if @i_gen1ind <> 1 
				  begin

					if @feedin_count2 > 0
					  begin

						update bookedipartner
						set sendtoeloquenceind = 1,
					  	lastuserid='TOPSFEED',
					 	 lastmaintdate = @feed_system_date
						   	 where printingkey =1 and bookkey = @bookkey

						update bookedistatus
						set edistatuscode = 3,
						   lastuserid='TOPSFEED',
						  lastmaintdate = @feed_system_date
						    	where printingkey =1 and bookkey = @bookkey
					  end
				  end
			  end
			else/* no rows present insert values */
	 	 	  begin
				if @feedin_count2 > 0 and @i_gen1ind <> 1 
				  begin

					insert into bookedistatus (EDIPARTNERKEY,BOOKKEY,PRINTINGKEY,EDISTATUSCODE,
						LASTUSERID,LASTMAINTDATE)
					select edipartnerkey,bookkey,1,3,'TOPSFEED',@feed_system_date
						from bookedipartner where printingkey =1 and bookkey = @bookkey
				    end
			  end	
		end /* eloquence ind update end*/

/* 1-28-03 add bookwhupdate insert for changes only*/
			select @feedin_count3 = 0
			 select @feedin_count3 = count(*) from bookwhupdate
			 	where bookkey = @bookkey
			if @feedin_count3 = 0 /*insert */
			  begin  
				insert into bookwhupdate
					(bookkey,lastmaintdate,lastuserid)
				values  (@bookkey,getdate(),'TOPSFEED')
			  end
	 end /* compare old and new */
end /*count > 0*/
commit tran
return 0

GO