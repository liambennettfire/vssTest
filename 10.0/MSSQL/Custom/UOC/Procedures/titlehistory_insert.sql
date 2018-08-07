PRINT 'STORED PROCEDURE : dbo.titlehistory_insert'
GO


if exists (select * from dbo.sysobjects where id = Object_id('dbo.titlehistory_insert') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.titlehistory_insert
end

GO

create proc dbo.titlehistory_insert
@columnkey int,
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

/*2-19-04 change parameter from columnname,tablename to columnkey*/
/*1-11-05 CRM 2289  test edistatuscode before changing to send*/

DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime

DECLARE @c_tablename  varchar(100)
DECLARE @c_columnname  varchar(100)
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
DECLARE @lv_table_to_upd  varchar(1)
DECLARE @nextkey int
DECLARE @i_gen1ind int

BEGIN tran 

	SELECT @feed_system_date = getdate()

	if @triggereloind <> 1  /*update eloquence tables if 1 only*/
	    begin
		select @triggereloind = 0
	   end

	select @feedin_count = 0	
 	
	select @feedin_count =count(*)  
		from titlehistorycolumns 
			where  columnkey = @columnkey


	if  @feedin_count > 0 
	  begin
		select @feedin_datatype = datatype, @c_columnname=columnname,
			@feedin_fielddesc =columndescription,@c_tablename=tablename
			from titlehistorycolumns 
				where columnkey = @columnkey
	end
	else
	 begin
		insert into feederror 							
			(isbn,batchnumber,processdate,errordesc)
		values (convert(char,10,@bookkey),'3',@feed_system_date,('There is no titlehistory column for this value ' + @c_tablename +' '+@c_columnname))
		RETURN 0
	 end


	if  @feedin_count > 0 
	  begin
		select @lv_table_to_upd = ''

 	/*possible values pubmonth taken care off with pub date; bookweigth */
		if @feedin_datatype = 'i'
		  begin
		  if upper(rtrim(@c_tablename)) ='PRINTING' and @c_columnname = 'PUBMONTHCODE'
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
		if upper(rtrim(@c_tablename)) = 'BINDINGSPECS' and upper(rtrim(@c_columnname)) = 'CARTONQTY1'  /*cartonqty1*/
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

 		if upper(rtrim(@c_tablename)) ='BOOK' and @c_columnname = 'TERRITORIESCODE'
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

 		if upper(rtrim(@c_tablename)) ='BOOKSIMON' and @c_columnname = 'BOOKWEIGHT'
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

	 	   if upper(rtrim(@c_tablename)) ='BOOKDETAIL' and @c_columnname = 'BISACSTATUSCODE' /*BISAC*/
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

			 if upper(rtrim(@c_tablename)) ='BOOKDATES' and  upper(rtrim(@otherinfo)) ='8'  /*pubdate*/
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

			   if upper(rtrim(@c_tablename)) ='BOOKDATES' and  upper(rtrim(@otherinfo)) ='47' /*ware date*/
				begin
				  select @feedin_count2 = 0

				 select @lv_table_to_upd = 'D'

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

			   /*12-23-03 add task date*/			
			   if upper(rtrim(@c_tablename)) ='TASK' and  upper(rtrim(@otherinfo)) ='8' /*schedule pub date*/
				begin
				   select @currentvalue_date = actualdate
						   from TASK
						  	where datetypecode=8
								and taskkey = @printingkey /*this is task key*/

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

 			  if upper(rtrim(@c_tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='8' /*retail price*/
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

			 if upper(rtrim(@c_tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='13' /*future price*/
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
			  
 			if upper(rtrim(@c_tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='11' /*canada price*/
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
				select @stringvalue = convert(varchar,@currentvalue_numeric)
			      end 
     		          end 
			  
			if upper(rtrim(@c_tablename)) ='PRINTING' and @c_columnname = 'FIRSTPRINTINGQTY' /*ACTUAL QUANTITY*/
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
					select @stringvalue = convert(varchar,@currentvalue_int)
				  end
			end
	 	end  /*	end alpha description*/
	

		if rtrim(@stringvalue) <> rtrim(@newvalue)
		    begin
			if upper(rtrim(@c_tablename)) ='BOOKDETAIL' and @c_columnname = 'BISACSTATUSCODE' 
			   begin
			      if @stringvalue <> '(Not Present)' 
				  begin
			    		   select @stringvalue = datadesc from gentables where tableid=314 and 
						    datacode = convert(int,rtrim(@stringvalue))
				  end
				select @newvalue = datadesc from gentables where tableid=314 and 
				    datacode = convert(int,rtrim(@newvalue))
			   end
			if upper(rtrim(@c_tablename)) ='BOOK' and @c_columnname = 'TERRITORIESCODE' 
			   begin
			      if @stringvalue <> '(Not Present)' 
				  begin
			    		   select @stringvalue = datadesc from gentables where tableid=131 and 
						    datacode = convert(int,rtrim(@stringvalue))
				  end
				select @newvalue = datadesc from gentables where tableid=131 and 
				    datacode = convert(int,rtrim(@newvalue))
			   end

		  	   if upper(rtrim(@c_tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='8' /*retail price*/
			     begin
				select @newvalue = @newvalue + ' USDL'
			     end
			if upper(rtrim(@c_tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='13' /*FUTURE price*/
			     begin
				select @newvalue = @newvalue + ' USDL'
			     end

			    if upper(rtrim(@c_tablename)) ='BOOKPRICE' and  upper(rtrim(@otherinfo)) ='11' /*retail price*/
			     begin
				select @newvalue = @newvalue + ' CAN'
			     end

			/* 3-30-04 datehistory added for onsale date update*/
			if  @lv_table_to_upd  = 'D' 
			  begin /*update datehistory dateprior will be entered in trigger*/
				/*p_printingkey , pass stagecode here*/

				UPDATE keys SET generickey = generickey+1, 
				 lastuserid = 'QSIADMIN', 
				lastmaintdate = getdate()

				select @nextkey = generickey from Keys

				insert into datehistory (bookkey,datetypecode,datekey,
					printingkey,datechanged,datestagecode,dateprior,lastuserid,lastmaintdate)
				values (@bookkey,47,@nextkey,1,convert(datetime,@newvalue),
					@printingkey,@currentvalue_date,'FEEDIN_UOC',@feed_system_date);
			  end	
			else
			  begin
	
				insert into titlehistory (bookkey,printingkey,columnkey,lastmaintdate,stringvalue,lastuserid,
					currentstringvalue,fielddesc)
				values (@bookkey,1,@columnkey,@feed_system_date,@stringvalue,'FEEDIN_UOC',
					@newvalue,@feedin_fielddesc)
		   	  end
	
			if @triggereloind = 1 /* 11-11-03 update eloquence tables only if this is 1*/
			  begin
/** Resend title to Eloquence-set bookedistatus.edistatuscode to Resend (3)**/
/*1-11-05 edistatuscode update
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
					  	lastuserid='FEEDIN_UOC',
					 	 lastmaintdate = @feed_system_date
						   	 where printingkey =1 and bookkey = @bookkey

						update bookedistatus
						set edistatuscode = 3,
						   lastuserid='FEEDIN_UOC',
						  lastmaintdate = @feed_system_date
						    	where printingkey =1 and bookkey = @bookkey
					  end
				  end
			  end
			else/* no rows present insert values */
	 	 	  begin
				if @feedin_count2 > 0 and @i_gen1ind <> 1 
				  begin
					update bookedistatus
					  set edistatuscode = 3,
					   lastuserid='FEEDIN_UOC',
					  	lastmaintdate = @feed_system_date
					    	where printingkey =1 and bookkey = @bookkey

					insert into bookedistatus (EDIPARTNERKEY,BOOKKEY,PRINTINGKEY,EDISTATUSCODE,
						LASTUSERID,LASTMAINTDATE)
					select edipartnerkey,bookkey,1,3,'FEEDIN_UOC',@feed_system_date
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
				values  (@bookkey,getdate(),'FEEDIN_UOC')
			  end
	 end /* compare old and new */
end /*count > 0*/
commit tran
return 0

GO