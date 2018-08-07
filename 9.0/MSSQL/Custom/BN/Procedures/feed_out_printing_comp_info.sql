if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_out_printing_comp_info]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_out_printing_comp_info]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



create proc dbo.feed_out_printing_comp_info
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back

**/

DECLARE @titlestatusmessage varchar (255)
DECLARE @statusmessage varchar (255)
DECLARE @c_outputmessage varchar (255)
DECLARE @c_output varchar (255)
DECLARE @titlecount int
DECLARE @titlecountremainder int
DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime
DECLARE @i_key int
DECLARE @i_key2 int

DECLARE @feed_count int
DECLARE @feed_tablename varchar(100)
DECLARE @feed_vendorkey int
DECLARE @feed_compspeckey int
DECLARE @feed_pokey int

DECLARE @feedout_bookkey  int
DECLARE @feedout_printingkey int
DECLARE @feedout_printingnumber varchar (25) 
DECLARE @feedout_jobnumberalpha varchar (40) 
DECLARE @feedout_componenttypekey   int 
DECLARE @feedout_component	varchar (40) 
DECLARE @feedout_componentqty	int 
DECLARE @feedout_comphonebookkey  varchar (40) 
DECLARE @feedout_componentvendor  varchar (40) 
DECLARE @feedout_compdesc VARCHAR(4000)

DECLARE @nc_sqlstring NVARCHAR(4000)
DECLARE @nc_sqlparameters NVARCHAR(4000)
DECLARE @c_message  varchar(255)

/*2/10/05 CRM 2440: add note.text field*/

select @statusmessage = 'BEGIN TMM FEED OUT Printings Comp AT ' + convert (char,getdate())
print @statusmessage


select @titlecount=0
select @titlecountremainder=0

SELECT @feed_system_date = getdate()

truncate table bnmitsprintingcomponentfeed

DECLARE feedout_printings_comp INSENSITIVE CURSOR
FOR

select distinct bookkey,printingkey from bnpubprintingfeedkeys

/* table above created in job scheduler*/
	
FOR READ ONLY
	
select @feed_count = 0

OPEN feedout_printings_comp
FETCH NEXT FROM feedout_printings_comp
	INTO @feedout_bookkey, @feedout_printingkey
 
select @i_key  = @@FETCH_STATUS

if @i_key <> 0 /*no printings*/
begin	
  begin tran
	insert into feederror 										
		(batchnumber,processdate,errordesc)
		values ('2',@feed_system_date,'NO ROWS to PROCESS - Printings-Component')
  commit tran
end

while (@i_key<>-1 )  /* status 1*/
begin
	IF (@i_key<>-2) /* status 2*/
	begin

	/** Increment Title Count, Print Status every 500 rows **/
	select @titlecount=@titlecount + 1
	select @titlecountremainder=0
	select @titlecountremainder = @titlecount % 500
	if(@titlecountremainder = 0)
	begin
		select @titlestatusmessage =  convert (varchar (50),getdate()) + '   ' + convert (varchar (10),@titlecount) + '   Rows Processed'
		print @titlestatusmessage
	end 

	select @feedout_printingnumber = ''
	select @feedout_jobnumberalpha = ''
	select @feedout_componenttypekey = 0
	select @feedout_component = '' 
	select @feedout_componentqty = 0 

	select @feed_count = 0
	select @feed_count  = count(*)
		from printing where
		 bookkey =  @feedout_bookkey and printingkey = @feedout_printingkey
	
	if @feed_count > 0
	  begin
		select @feedout_printingnumber = printingnum
			from printing where
			  bookkey =  @feedout_bookkey and printingkey = @feedout_printingkey

		select @feedout_jobnumberalpha = jobnumberalpha
			FROM printing
			 WHERE bookkey = @feedout_bookkey
			AND  printingkey = @feedout_printingkey 


/* do all components in cursor   for multiple rows pull max pokey*/

		DECLARE feedout_comp INSENSITIVE CURSOR
		  FOR		
			select distinct co.compkey,compdesc,cs.compspeckey
			 from comptype co,compspec cs,component c
			  where co.compkey=cs.compkey and cs.compkey=c.compkey
				and cs.bookkey=c.bookkey and cs.printingkey=c.printingkey
			   	and c.bookkey = @feedout_bookkey and c.printingkey= @feedout_printingkey
				order by cs.compspeckey,co.compkey
		FOR READ ONLY

		OPEN feedout_comp
			FETCH NEXT FROM feedout_comp
				INTO  @feedout_componenttypekey,@feedout_component,@feed_compspeckey
					
 		select @i_key2  = @@FETCH_STATUS

		while (@i_key2<>-1 )  /* status 1*/
		  begin
			IF (@i_key2<>-2) /* status 2*/
			  begin

				select @feedout_comphonebookkey  = '' 
				select @feedout_componentvendor  = ''
				select @feed_vendorkey = 0
	
			
				select @feed_pokey = max(c.pokey)
				 from comptype co,compspec cs,component c
			 	 where co.compkey=cs.compkey and cs.compkey=c.compkey
					and cs.bookkey=c.bookkey and cs.printingkey=c.printingkey
			   		and c.bookkey = @feedout_bookkey and c.printingkey= @feedout_printingkey
					and co.compkey = @feedout_componenttypekey
					
				 if @feedout_componenttypekey = 3 
				  begin  /*print*/
					select @feed_vendorkey = vendorkey ,@feedout_componentqty = quantity
					from gpo g, component c
						where g.gpokey =c.pokey and gpokey = @feed_pokey
					 and  c.compkey = @feedout_componenttypekey
				 end 
				else
				  begin
					  select @feedout_componentqty = quantity
					 from comptype co,compspec cs,component c
					  where co.compkey=cs.compkey and cs.compkey=c.compkey
						and cs.bookkey=c.bookkey and cs.printingkey=c.printingkey
					   	and c.bookkey = @feedout_bookkey and c.printingkey= @feedout_printingkey
						and co.compkey = @feedout_componenttypekey and c.pokey=  @feed_pokey
				  end
				
				if @feed_vendorkey is null 
				  begin
					select @feed_vendorkey = 0
				  end
				
				if @feed_vendorkey = 0
				  begin
/*no pokey just use value here */
						select @feed_tablename = name from dbo.sysobjects where name like  (
						select  replace(replace(replace(compdesc,'/',''),'-',''),' ','') +'%spec%'  
						  from comptype where compkey= @feedout_componenttypekey) 
						   and OBJECTPROPERTY(id, N'IsUserTable') = 1
				
/* only 3 that does not match up picks up wrong table printpackagingspecs/endpapers/wholebook purchase-- goes to gpo.vendorname*/

						if @feedout_componenttypekey = 3  or @feedout_componenttypekey = 7 or @feedout_componenttypekey = 9
 				 		 begin
							select @feed_tablename = null
						  end
  						if @feed_tablename is null and @feedout_componenttypekey <> 9
						  begin
							select @feed_tablename = upper(replace(replace(replace(compdesc,'/',''),'-',''),' ',''))  
							   from comptype where compkey= @feedout_componenttypekey
						
							if substring(@feed_tablename,1,4) = 'ACET'  
							  begin
								select @feed_tablename = 'transparencyspecs'
							  end 
					
							if substring(@feed_tablename,1,4) = 'BIND'  
							  begin
								select @feed_tablename = 'bindingspecs'
							  end 
							if substring(@feed_tablename,1,4) = 'MISC'  
							  begin
								select @feed_tablename = 'misccompspecs'
							  end 
							if substring(@feed_tablename,1,14) = 'PACKAGINGPRINT'  
							  begin
								select @feed_tablename = 'printpackagingspecs'
							  end 	
							if substring(@feed_tablename,1,6) = 'SECOND'  
							  begin
								select @feed_tablename = 'secondcoverspecs'
							  end 
	
							if substring(@feed_tablename,1,5) = 'PRINT'  
							  begin
								select @feed_tablename = 'textspecs'
							  end 

							if substring(@feed_tablename,1,8) = 'ENDPAPER'  
							  begin
								select @feed_tablename = 'endpapers'
						 	end
						end
				
						if @feed_tablename is not null and @feedout_componenttypekey <> 8  /*inserts*/
	 					  begin	
							select @nc_sqlstring = ''
		
							set @nc_sqlstring = N'select @feed_vendorkey = vendorkey from '  + @feed_tablename + 
						   	 ' where bookkey= @feedout_bookkey and printingkey = @feedout_printingkey'
					
							EXEC sp_executesql @nc_sqlstring, N'@feedout_bookkey INT, @feedout_printingkey INT,@feed_vendorkey INT OUTPUT',
							  @feedout_bookkey, @feedout_printingkey,@feed_vendorkey OUTPUT
						 end


						if @feed_tablename is not null and @feedout_componenttypekey = 8  /*inserts*/
 						  begin
							select @nc_sqlstring = ''
		
							select @feed_vendorkey = illusvendorkey from textspecs
						   	 where bookkey= @feedout_bookkey and printingkey = @feedout_printingkey
						 end

/*11-1-04  whole book purchase get from gpo.vendorname no spec table*/
						if @feed_tablename is null and @feedout_componenttypekey = 9  /*wholebook*/
	 					  begin
							select @feed_vendorkey = vendorkey from gpo g, gposection gp
						   	 where key1= @feedout_bookkey and key2 = @feedout_printingkey
								and g.gpokey=gp.gpokey and key3=9
						  end
				end  /*vendorkey*/

				if @feed_vendorkey is not null
				  begin
			 		select @feedout_comphonebookkey  =  vendorid, @feedout_componentvendor = name
						from vendor where vendorkey = @feed_vendorkey
				  end
/*add note.detail*/
			select @feed_count = 0
			select @feed_count = count(*) 
				from note 
				  where bookkey =@feedout_bookkey and printingkey= @feedout_printingkey 
					and compkey=@feedout_componenttypekey and detaillinenbr=1

			if @feed_count > 0 
			  begin
				select @feedout_compdesc = text 
				from note 
				  where bookkey =@feedout_bookkey and printingkey= @feedout_printingkey 
					and compkey=@feedout_componenttypekey and detaillinenbr=1
			  end


/***************************   warning messages  comment for now   
begin tran

				if @feedout_printingnumber is null  
				  begin
					select @feedout_printingnumber = ''
	 			 end
				if datalength(@feedout_printingnumber) = 0
				  begin
					insert into feederror 										
					(isbn,batchnumber,processdate,errordesc)
					  values (@feedout_isbn10,'2',@feed_system_date,'Printing Comp-- warning printingnumber missing')
				  end
	
				if @feedout_jobnumberalpha is null  
	 			 begin
					select @feedout_jobnumberalpha = ''
	 			 end

				if datalength(@feedout_jobnumberalpha) = 0
				  begin
					insert into feederror 										
					(isbn,batchnumber,processdate,errordesc)
					  values (@feedout_isbn10,'2',@feed_system_date,'Printing Comp-- warning jobnumberalpha missing')
				  end
	
commit tran

***************************/
	
/*insert into temporary table*/
			
begin tran
				insert into bnmitsprintingcomponentfeed (bookkey,printingkey,printingnumber,
					jobnumberalpha,componenttypekey,component,componentqty,comphonebookkey,
					componentvendor,compdesc)
				values (@feedout_bookkey ,@feedout_printingkey,@feedout_printingnumber,
				  @feedout_jobnumberalpha,@feedout_componenttypekey,@feedout_component,@feedout_componentqty,
			 		@feedout_comphonebookkey,@feedout_componentvendor,@feedout_compdesc)
commit tran

		end /*comp status 2*/

			FETCH NEXT FROM feedout_comp
				INTO  @feedout_componenttypekey,@feedout_component,@feed_compspeckey

 		select @i_key2  = @@FETCH_STATUS
	    end  /*comp status 1*/

		close feedout_comp
		deallocate feedout_comp
  
	  end /*printing >0*/

	end /*print comp status 2*/
	 
	FETCH NEXT FROM feedout_printings_comp
		INTO @feedout_bookkey, @feedout_printingkey
 
	select @i_key  = @@FETCH_STATUS
	
end /*print comp 1*/

begin tran

/* 8-24-04 move all deletes before count*/

select @feed_count = 0

select @feed_count = count(*) from bnmitsprintingcomponentfeed
if @feed_count > 0
  begin
	insert into bnmitsprintingcomponentfeed(bookkey,printingkey,printingnumber)
	  values (0,0,'Total Records '+ convert(varchar,@feed_count))
  end

insert into feederror (batchnumber,processdate,errordesc)
 values ('2',@feed_system_date,'Printings Component Completed')

commit tran

close feedout_printings_comp
deallocate feedout_printings_comp

select @statusmessage = 'END TMM FEED OUT Printings Comp AT ' + convert (char,getdate())
print @statusmessage

return 0

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO