SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[feed_out_primac_data]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[feed_out_primac_data]
GO


create proc dbo.feed_out_primac_data
AS

/** Returns:
0 Transaction completed successfully
-1 Generic SQL Error
-2 Required field not available - transaction rolled back
**/

DECLARE @err_msg varchar (100)
DECLARE @feed_system_date datetime

DECLARE @feedout_bookkey  int
DECLARE @feedout_estkey  int
DECLARE @feedout_versionkey  int
DECLARE @feedout_finishedgoodqty  int
DECLARE @feedout_pagecount int
DECLARE @feedout_trimfamilycode int
DECLARE @feedout_trim varchar(20)  /*tableid=29*/
DECLARE @feedout_jobnumber varchar(50)

DECLARE @feedout_compbreak  int
DECLARE @feedout_compqty int
DECLARE @feedout_compsigsiz int	
DECLARE @feedout_compsigs  varchar(20) /*tableid =48*/
DECLARE @feedout_compdesc  varchar(255)
DECLARE @feedout_compkey int

DECLARE @feedout_textproof  varchar(40)
DECLARE @feedout_textpaper  varchar(40)
DECLARE @feedout_textmr  int
DECLARE @feedout_textrun  int
DECLARE @feedout_textrunlbs  int
DECLARE @feedout_textaddlbs  varchar(15)
DECLARE @feedout_bindproof  varchar(40)
DECLARE @feedout_bindcomp  varchar(255)
DECLARE @feedout_bindbroad  varchar(40)
DECLARE @feedout_endproof  varchar(255)
DECLARE @feedout_endpaper  varchar(40)
DECLARE @feedout_coverproof  varchar(255) 
DECLARE @feedout_coverpaper  varchar(40) 
DECLARE @feedout_pricetextprep  float
DECLARE @feedout_pricetextproof  float
DECLARE @feedout_pricetextplates   float
DECLARE @feedout_pricetextpaper   float
DECLARE @feedout_pricetextmr  float
DECLARE @feedout_pricetextrun   float
DECLARE @feedout_pricebindmr  float	
DECLARE @feedout_pricebindrun   float	
DECLARE @feedout_pricejacket   float /*cover??*/
DECLARE @feedout_pricemiscbind   float	
DECLARE @feedout_pricemiscover   float
DECLARE @feedout_pricespecstock   float	
DECLARE @feedout_priceendmr   float	
DECLARE @feedout_priceendrun  float	
DECLARE @feedout_matsupplier int

DECLARE @feedout_count int
DECLARE @i_bookkey int
DECLARE @i_compkey int
DECLARE @i_sigskey int

BEGIN tran 

SELECT @feed_system_date = getdate()

DECLARE feed_estimates INSENSITIVE CURSOR
FOR

select  t.bookkey,
	i.estkey,
	i.versionkey,
	i.finishedgoodqty,
	i.jobnumber

from estbook t, estversion i
where  t.estkey=i.estkey
	/*and t.lastmaintdate> getdate() -50 do not know if a cut will be needed??
 	and t.estkey=60045 testing*/
	order by t.bookkey,t.estkey

FOR READ ONLY
		
OPEN feed_estimates 

FETCH NEXT FROM feed_estimates 
INTO @feedout_bookkey, 
	@feedout_estkey,
	@feedout_versionkey , 
	@feedout_finishedgoodqty, 
	@feedout_jobnumber


select @i_bookkey  = @@FETCH_STATUS

if @i_bookkey <> 0 /*no titles  not likely though*/
 begin	
	insert into feederror 										
		(batchnumber,processdate,errordesc)
		values ('20',@feed_system_date,'NO ROWS to PROCESS FOR PRIMAC DATA FEED')
 end
else
  begin
	delete from FEEDOUTPRIMACDATA;
 end

while (@i_bookkey<>-1 )  /* sttus 1*/
begin
	IF (@i_bookkey<>-2) /* status 2*/
	  begin

	  select @feedout_count = 0
	  select @feedout_trimfamilycode = 0
	  select @feedout_trim  = ''
	  select @feedout_pricetextprep  = 0
 	  select @feedout_pricetextproof  = 0
	 select @feedout_pricetextplates   = 0
	 select @feedout_pricetextpaper   = 0
	 select @feedout_pricetextmr  = 0
	 select @feedout_pricetextrun   = 0
	 select @feedout_pricebindmr  = 0		
	 select @feedout_pricebindrun   = 0	
	 select @feedout_pricejacket   = 0 	
	 select @feedout_pricemiscbind   = 0	
	 select @feedout_pricemiscover   = 0
	 select @feedout_pricespecstock   = 0	
	 select @feedout_priceendmr   = 0	
	 select @feedout_priceendrun  = 0		
	select @feedout_compdesc = ''
	
/*------------- intialize data ---------*/

/*trimfamily and pagecount*/
	select @feedout_count = 0

	select @feedout_trimfamilycode = trimfamilycode, @feedout_pagecount = pagecount
		from estspecs
		  where estkey = @feedout_estkey
		   and versionkey= @feedout_versionkey

	if @feedout_trimfamilycode  is null  
	 begin
		select @feedout_trimfamilycode  = 0
	 end 
	if @feedout_trimfamilycode > 0 
   	  begin
		select @feedout_trim  = datadesc
		  from gentables
			where datacode = @feedout_trimfamilycode
				and tableid=29 
	  end
	else
	  begin
		select @feedout_trim = ''
	  end

/*component INFO and signiture size*/
	select @feedout_compqty = 0		
	select @feedout_compsigsiz  = 0
	select @feedout_compdesc = ''
	select @feedout_compsigs = ''

	DECLARE feed_component INSENSITIVE CURSOR
	  FOR

		select  t.compkey
			from estcomp t
			where  t.estkey = @feedout_estkey
				and t.versionkey = @feedout_versionkey
				order by t.compkey

	FOR READ ONLY
		

	OPEN feed_component

	FETCH NEXT FROM feed_component
		INTO @feedout_compkey

	select @i_compkey  = @@FETCH_STATUS

	 while (@i_compkey<>-1 )  /* sttus 1*/
	  begin
      	IF (@i_compkey<>-2) /* status 2*/
		  begin

			select  @feedout_compqty = t.compqty
				from estcomp t
					where t.compkey= @feedout_compkey
						and t.estkey = @feedout_estkey
						and t.versionkey = @feedout_versionkey
			
			select @feedout_compsigsiz  = 0
			select @feedout_compsigs = ''
			select @feedout_compqty = 0

			DECLARE feed_component_sigs INSENSITIVE CURSOR
			  FOR

				select   i.signaturesize,i.numsignatures
					from estmaterialspecsigs i
						where   i.compkey= @feedout_compkey
							and i.estkey = @feedout_estkey
							and i.versionkey = @feedout_versionkey

			   FOR READ ONLY
		

			    OPEN feed_component_sigs

				FETCH NEXT FROM feed_component_sigs
				INTO @feedout_compsigsiz,@feedout_compqty  

			 	select @i_sigskey  = @@FETCH_STATUS

				 while (@i_sigskey<>-1 )  /* sttus 1*/
				  begin
			      	IF (@i_sigskey<>-2) /* status 2*/
					  begin
			
						if @feedout_compsigsiz > 0
			 			 begin
							select @feedout_compsigs = ''
							select @feedout_compsigs   =  datadesc
					 			 from gentables
									where datacode = @feedout_compsigsiz
										and tableid=48 
						 end  
						if datalength(@feedout_compsigs) > 0 or @feedout_compqty > 0 
						  begin
							select @feedout_compdesc = @feedout_compdesc + convert(varchar,@feedout_compqty) + ' - ' + @feedout_compsigs + ','
						  end
					end
			 	 FETCH NEXT FROM feed_component_sigs
	     		  	INTO  @feedout_compsigsiz,@feedout_compqty 

	    	  select @i_sigskey  = @@FETCH_STATUS
		end
		close feed_component_sigs
		deallocate feed_component_sigs

		 if @feedout_compkey = 2 /*bind specs*/
			  begin
				select @feedout_bindproof = datadesc from estcomp e, gentables
					where estkey = @feedout_estkey
					   	and versionkey = @feedout_versionkey
						and compkey= @feedout_compkey
						and methodcode = datacode
						and tableid=3

				EXEC feed_out_primac_misc @feedout_estkey,@feedout_versionkey ,@feedout_compkey,51,@feedout_bindcomp OUTPUT
				
				select @feedout_bindbroad = ''
				select @feedout_bindbroad=datadesc 
					from estmiscspecs e, misctypetable m, gentables g
						where estkey = @feedout_estkey
						   and versionkey = @feedout_versionkey
							and compkey= @feedout_compkey
							and e.datacode = g.datacode 
							and e.tableid = m.datacode    
         						and m.tablecode = g.tableid   
	         					and e.misctypetableid = m.tableid 
							and e.misctypetableid = 51
							and e.tableid = 6
							and g.tableid = 12
			  end

		       if @feedout_compkey = 3 /*text= print specs*/
			  begin
				select @feedout_textproof = datadesc from estcomp e, gentables
					where estkey = @feedout_estkey
					   	and versionkey = @feedout_versionkey
						and compkey= @feedout_compkey
						and methodcode = datacode
						and tableid=20
			
				select  @feedout_textmr = 0
				select @feedout_textrun   = 0
				select @feedout_textrunlbs  = 0

				select @feedout_textmr = allocationmr, @feedout_textrun = allocation,
				 	@feedout_textrunlbs  = allocationper1000,@feedout_matsupplier= matsuppliercode
						from estmaterialspecs  e
					where estkey = @feedout_estkey
					   	and versionkey = @feedout_versionkey
						and compkey= @feedout_compkey
						
				if @feedout_textrun > 0 and @feedout_textmr > 0
				  begin
					select @feedout_textrun  = @feedout_textrun - @feedout_textmr
				  end
				
				select @feedout_textpaper = datadesc 
					from estmaterialspecs  e,  gentables g
						where estkey = @feedout_estkey
						   and versionkey = @feedout_versionkey
							and g.tableid=27
							and e.stocktypecode = g.datacode 
							and compkey= @feedout_compkey
			 end
 			if @feedout_compkey = 4 /*cover specs*/
			  begin
				EXEC feed_out_primac_misc @feedout_estkey,@feedout_versionkey ,@feedout_compkey,78, @feedout_coverproof  OUTPUT
				select @feedout_coverpaper = datadesc 
					from estcomp  e,  gentables g
						where estkey = @feedout_estkey
						   and versionkey = @feedout_versionkey
							and g.tableid=26
							and e.stockcode = g.datacode 
							and compkey= @feedout_compkey
			 end

 			if @feedout_compkey = 7 /*endpaper--sheet specs*/
			  begin
				EXEC feed_out_primac_misc @feedout_estkey,@feedout_versionkey ,@feedout_compkey,78, @feedout_endproof  OUTPUT
				select @feedout_endpaper = datadesc 
					from estcomp  e,  gentables g
						where estkey = @feedout_estkey
						   and versionkey = @feedout_versionkey
							and g.tableid=26
							and e.stockcode = g.datacode 

			 end
		end
		  FETCH NEXT FROM feed_component
	       	INTO  @feedout_compkey

	      select @i_compkey  = @@FETCH_STATUS
	end
	close feed_component
	deallocate feed_component

/* prices chargecode do you want unitcost or total cost, 8-15-02 they want unitcost*/

	/*Text Prep  chargecode = 22*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,22 ,@feedout_pricetextprep OUTPUT
	
	/*Text Proof  chargecode = 61016*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,61016 ,@feedout_pricetextproof OUTPUT
	
	/*Text Plate chargecode = 25*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,25 ,@feedout_pricetextplates OUTPUT
	
	/*Text mr chargecode = 18*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,18 ,@feedout_pricetextmr OUTPUT
	
	/*Text RUN chargecode = 21*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,21 ,@feedout_pricetextrun OUTPUT

	/*Bind MR chargecode = 13*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,13 ,@feedout_pricebindmr  OUTPUT

	/*Bind Run chargecode = 11*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,11 ,@feedout_pricebindrun  OUTPUT

	/*Jacket chargecode = 5*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,5,@feedout_pricejacket  OUTPUT
	
	/*Misc. Bind Charge = 61642*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,61642,@feedout_pricemiscbind   OUTPUT
	
	/*Misc. Cover Charge = 61645*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,61645,@feedout_pricemiscover   OUTPUT

	/*Special Order Stock = 61646*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,61646,@feedout_pricespecstock    OUTPUT

	/*Endsheet MR = 60462*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,60462,@feedout_priceendmr    OUTPUT
	
	/*Endsheet Run = 60463*/
	EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,60463,@feedout_priceendrun   OUTPUT

	/*Text Paper - Printer or RES = 16 or 19 ?????*/
	if  @feedout_matsupplier = 4 /* res*/
	  begin
		EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,16,@feedout_pricetextpaper  OUTPUT
	   end
	if @feedout_matsupplier = 0 /* printer*/
	  begin
		EXEC feed_out_primac_cost @feedout_estkey,@feedout_versionkey ,19,@feedout_pricetextpaper  OUTPUT
	  end

/* write row here before get next row*/
 	if datalength(@feedout_compdesc) > 0
	  begin
		select @feedout_count = datalength(@feedout_compdesc) - 1
 		select @feedout_compdesc = substring(@feedout_compdesc ,1,@feedout_count)
 	  end
	
     insert into FEEDOUTPRIMACDATA (ESTKEY,VERSIONKEY,TRIMSIZE,QUANTITY,PAGECOUNT, 
		COMPONENTBREAKDOWN,TEXTPROOF,TEXTPAPER,TEXTMR,TEXTRUN, TEXTADDLBS,
		BINDPROOF,BINDCOMPONENT,BINDBOARD,ENDPROOF,ENDPAPER,COVERPROOF,
		COVERPAPER,PRICETEXTPREP,PRICETEXTPROOF,PRICETEXTPLATES,PRICETEXTPAPER,
		PRICETEXTMR,PRICETEXTRUN,PRICEBINDMR,PRICEBINDRUN,PRICEJACKET,PRICEMISCBIND,PRICEMISCOVER,
		PRICESPECSTOCK,PRICEENDMR,PRICEENDRUN,JOBNUMBER) 	
	values (@feedout_estkey,@feedout_versionkey,@feedout_trim,@feedout_finishedgoodqty,
		@feedout_pagecount,@feedout_compdesc,@feedout_textproof,@feedout_textpaper,@feedout_textmr,
		@feedout_textrun,@feedout_textaddlbs,@feedout_bindproof,@feedout_bindcomp, @feedout_bindbroad,
		@feedout_endproof,@feedout_endpaper,@feedout_coverproof,@feedout_coverpaper,@feedout_pricetextprep,
		@feedout_pricetextproof,@feedout_pricetextplates,@feedout_pricetextpaper,@feedout_pricetextmr,
		@feedout_pricetextrun, @feedout_pricebindmr,@feedout_pricebindrun,@feedout_pricejacket,
		@feedout_pricemiscbind,@feedout_pricemiscover,@feedout_pricespecstock,@feedout_priceendmr,
		@feedout_priceendrun, @feedout_jobnumber)

    end  /*bookkey status <> 1*/

 	FETCH NEXT FROM feed_estimates 
		INTO @feedout_bookkey, 
			@feedout_estkey,
			@feedout_versionkey , 
			@feedout_finishedgoodqty, 
			@feedout_jobnumber


		select @i_bookkey  = @@FETCH_STATUS

end  /*bookkey status <> 2*/ 


close feed_estimates
deallocate feed_estimates

commit tran
return 0


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[feed_out_primac_data]  TO [public]
GO

