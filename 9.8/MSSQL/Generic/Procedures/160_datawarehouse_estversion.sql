PRINT 'STORED PROCEDURE : dbo.datawarehouse_estversion'
GO

if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_estversion') and (type = 'P' or type = 'RF'))
begin
 drop proc dbo.datawarehouse_estversion
end

GO

create proc dbo.datawarehouse_estversion
@ware_bookkey int,@ware_printingkey int,
@ware_estkey int, @ware_company varchar(100),@ware_logkey int, 
@ware_warehousekey int, @ware_system_date datetime 
AS 


DECLARE @ware_count int
DECLARE @ware_count2 int
DECLARE @ware_count3 int
DECLARE @ware_pricecount int
DECLARE @ware_royalcount int
DECLARE @ware_vendorname varchar(80)
DECLARE @ware_vendorshort varchar(8)
DECLARE @ware_pagecount int
DECLARE @ware_trimfamilycode int
DECLARE @ware_trim_long   varchar(40)
DECLARE @ware_mediacode  int
DECLARE @ware_media_long varchar(40)
DECLARE @ware_mediasubcode  int
DECLARE @ware_mediasub_long varchar(120)
DECLARE @ware_colorcount  int
DECLARE @ware_endpapertype  varchar(40)
DECLARE @ware_foilamt  float
DECLARE @ware_covercode  int
DECLARE @ware_cover_long varchar(40)
DECLARE @ware_film int
DECLARE @ware_film_long  varchar(40)
DECLARE @ware_bluesind varchar(1) 
DECLARE @ware_firstprinting varchar(1)
DECLARE @ware_plateavailind varchar(1)
DECLARE @ware_filmavailind varchar(1)
DECLARE @ware_endpapertypedesc varchar(40)
DECLARE @ware_listprice float
DECLARE @ware_discountpercent int
DECLARE @ware_discountpercent1 int
DECLARE @ware_returnrate int
DECLARE @ware_returnrate1 int
DECLARE @ware_royaltypercent1 int
DECLARE @ware_totalroyalty float
DECLARE @ware_returntostock int
DECLARE @ware_returntostock1 int
DECLARE @ware_finishedgoodqty int
DECLARE @ware_advertisingfgqty float
DECLARE @ware_totaladvertising float
DECLARE @ware_advertisingnetcopy int
DECLARE @ware_ratecategorycode  int
DECLARE @ware_saleschannelcode int
DECLARE @ware_saleschannelcode1 int
DECLARE @ware_remainderprice float
DECLARE @ware_remainderprice1 float
DECLARE @ware_remainderqty float
DECLARE @ware_remainderqty1 float
DECLARE @ware_overheadpercent float
DECLARE @ware_overheadpercent1 int
DECLARE @ware_advertisingpercent float
DECLARE @ware_advertisingpercent1 int
DECLARE @ware_columnheadingcode int
DECLARE @ware_userentercode int
DECLARE @ware_columnheadingcode1 int
DECLARE @ware_userentercode1 int
DECLARE @ware_datadescshort varchar(20)
DECLARE @ware_royaltypercent float
DECLARE @ware_royaltyquantity int
DECLARE @c_price_received float
DECLARE @c_net_copies float
DECLARE @ware_costtype varchar(1)
DECLARE @ware_totalcost int
DECLARE @ware_totalplant float
DECLARE @ware_totaledition float
DECLARE @c_edition_fg float
DECLARE @c_plant_fg float
DECLARE @c_total_plant float
DECLARE @c_total_edition float
DECLARE @c_edition_netcopy float
DECLARE @c_percentof float
DECLARE @c_edition_percent float
DECLARE @c_plant_netcopy float
DECLARE @c_plant_percent float
DECLARE @c_total_prod float
DECLARE @c_prod_netcopy float
DECLARE @c_prod_percent float
DECLARE @c_total_royalty float
DECLARE @c_royalty_netcopy float
DECLARE @c_royalty_percent float
DECLARE @c_prod_fg int
DECLARE @c_gross_sales float
DECLARE @c_gross_unit float
DECLARE @c_royalty_fg int
DECLARE @c_gross_percent float
DECLARE @c_edition_unit float
DECLARE @c_inv_wo_unit float
DECLARE @c_inv_wo_percent float
DECLARE @c_prod_unit float
DECLARE @grosssalescost float
DECLARE @c_royalty_unit float
DECLARE @c_total_unit float
DECLARE @c_total_percent float
DECLARE @ware_overheadfgqty int /* zero in pricing select*/
DECLARE @ware_overheadnetcopy int /* zero in pricing select*/
DECLARE @ware_totaloverhead int /* zero in pricing select*/
DECLARE @ware_totaladvertingfg int /* zero in pricing select*/
DECLARE @ware_advertingfgqty int /* zero in pricing select*/
DECLARE @ware_advertingfgnetcopy int /* zero in pricing select*/
DECLARE @c_total_overhead float
DECLARE @c_overhead_fg float
DECLARE @c_overhead_netcopy float
DECLARE @c_overhead_percent float
DECLARE @c_total_advertising float
DECLARE @c_advertising_fg float
DECLARE @c_advertising_netcopy float
DECLARE @c_advertising_percent float
DECLARE @c_total_cost int
DECLARE @c_returned_qty float
DECLARE @c_sales int
DECLARE @c_returns int
DECLARE @c_net_sales int
DECLARE @c_remainder_sales int
DECLARE @c_total_revenue int
DECLARE @c_revenue_per_fgqty float
DECLARE @c_revenue_per_netcopies float
DECLARE @c_profit_loss int
DECLARE @c_profitloss_per_fgqty float
DECLARE @c_profitloss_per_netcopies float
DECLARE @c_profit_margin float
DECLARE @c_netqty  float
DECLARE @c_net_unit float
DECLARE @c_inv_wo float
DECLARE @c_plant_unit float
DECLARE @c_var_gp float
DECLARE @c_var_gp_unit float
DECLARE @i_versionkey int
DECLARE @i_finishedgoodqty int
DECLARE @i_finishedgoodvendorcode int
DECLARE @d_requestdatetime datetime
DECLARE @c_requestedbyname varchar(100)
DECLARE @c_requestid varchar(20)
DECLARE @c_requestcomment varchar(255)
DECLARE @c_requestbatchid varchar(30)
DECLARE @i_estverstatus int

set @ware_count  = 1
set @ware_count2  = 0
set @ware_count3  = 0
set @ware_pricecount  = 0
set @ware_royalcount  = 0
set @ware_vendorname  = ''
set @ware_vendorshort  = ''

set @ware_pagecount  = 0
set @ware_trimfamilycode  = 0
set @ware_trim_long    = ''
set @ware_mediacode   = 0
set @ware_media_long  = ''
set @ware_mediasubcode   = 0
set @ware_mediasub_long  = ''
set @ware_colorcount   = 0

set @ware_endpapertype   = ''
set @ware_foilamt   = 0
set @ware_covercode   = 0
set @ware_cover_long  = ''
set @ware_film  = 0
set @ware_film_long   = ''
set @ware_bluesind  =''
set @ware_firstprinting  = ''
set @ware_plateavailind  = ''
set @ware_filmavailind  = ''
set @ware_endpapertypedesc  = ''
set @ware_listprice  = 0
set @ware_discountpercent  = 0
set @ware_discountpercent1  = 0
set @ware_returnrate  = 0
set @ware_returnrate1  = 0
set @ware_royaltypercent1  = 0
set @ware_totalroyalty  = 0
set @ware_returntostock  = 0
set @ware_returntostock1  = 0
set @ware_finishedgoodqty  = 0
set @ware_advertisingfgqty  = 0
set @ware_totaladvertising  = 0
set @ware_advertisingnetcopy  = 0

set @ware_ratecategorycode   = 0
set @ware_saleschannelcode  = 0
set @ware_saleschannelcode1  = 0

set @ware_remainderprice  = 0
set @ware_remainderprice1  = 0
set @ware_remainderqty  = 0
set @ware_remainderqty1  = 0
set @ware_overheadpercent  = 0
set @ware_overheadpercent1  = 0
set @ware_advertisingpercent  = 0
set @ware_advertisingpercent1  = 0
set @ware_columnheadingcode  = 0
set @ware_userentercode  = 0
set @ware_columnheadingcode1  = 0
set @ware_userentercode1  = 0
set @ware_datadescshort  = ''

set @ware_royaltypercent  = 0
set @ware_royaltyquantity  = 0

set @c_price_received  = 0
set @c_net_copies  = 0

set @ware_costtype  = ''
set @ware_totalcost  = 0
set @ware_totalplant  = 0
set @ware_totaledition  = 0
set @c_edition_fg  = 0
set @c_plant_fg  = 0
set @c_total_plant  = 0
set @c_total_edition  = 0
set @c_edition_netcopy  = 0
set @c_percentof  = 0
set @c_edition_percent  = 0
set @c_plant_netcopy  = 0
set @c_plant_percent  = 0
set @c_total_prod  = 0
set @c_prod_netcopy  = 0
set @c_prod_percent  = 0
set @c_total_royalty  = 0
set @c_royalty_netcopy  = 0
set @c_royalty_percent  = 0
set @c_prod_fg  = 0
set @c_gross_sales  = 0
set @c_gross_unit  = 0
set @c_royalty_fg  = 0
set @c_gross_percent  = 0
set @c_edition_unit  = 0
set @c_inv_wo_unit  = 0
set @c_inv_wo_percent  = 0
set @c_prod_unit  = 0
set @grosssalescost  = 0
set @c_royalty_unit  = 0
set @c_total_unit  = 0
set @c_total_percent  = 0


set @ware_overheadfgqty  = 0 /* zero in pricing select*/
set @ware_overheadnetcopy  = 0 /* zero in pricing select*/
set @ware_totaloverhead  = 0 /* zero in pricing select*/
set @ware_totaladvertingfg  = 0 /* zero in pricing select*/
set @ware_advertingfgqty  = 0 /* zero in pricing select*/
set @ware_advertingfgnetcopy  = 0 /* zero in pricing select*/


set @c_total_overhead  = 0
set @c_overhead_fg  = 0
set @c_overhead_netcopy  = 0
set @c_overhead_percent  = 0
set @c_total_advertising  = 0
set @c_advertising_fg  = 0
set @c_advertising_netcopy  = 0
set @c_advertising_percent  = 0
set @c_total_cost  = 0
set @c_returned_qty  = 0
set @c_sales  = 0
set @c_returns  = 0
set @c_net_sales  = 0
set @c_remainder_sales  = 0
set @c_total_revenue  = 0
set @c_revenue_per_fgqty  = 0
set @c_revenue_per_netcopies  = 0
set @c_profit_loss  = 0
set @c_profitloss_per_fgqty  = 0
set @c_profitloss_per_netcopies  = 0
set @c_profit_margin  = 0
set @c_netqty   = 0
set @c_net_unit  = 0
set @c_inv_wo  = 0
set @c_plant_unit  = 0
set @c_var_gp  = 0
set @c_var_gp_unit  = 0


select @ware_count =  1

DECLARE warehouseversion INSENSITIVE CURSOR
 FOR
	SELECT  versionkey,finishedgoodqty,finishedgoodvendorcode,
         requestdatetime,requestedbyname,requestid,requestcomment,
         requestbatchid
    		from estversion 
  			 WHERE estkey = @ware_estkey
 FOR READ ONLY

   OPEN  warehouseversion

	FETCH NEXT FROM warehouseversion
		INTO @i_versionkey,@i_finishedgoodqty,@i_finishedgoodvendorcode,
			@d_requestdatetime,@c_requestedbyname,@c_requestid,
			@c_requestcomment,@c_requestbatchid

	select @i_estverstatus = @@FETCH_STATUS

	if @i_estverstatus <> 0 /** NO estversion **/
    	  begin
		insert into whest
			(estkey,bookkey,printingkey,estversion,lastuserid,lastmaintdate)
		VALUES (@ware_estkey, @ware_bookkey,@ware_printingkey,0,'WARE_STORED_PROC',@ware_system_date)
		insert into whestcost
			(estkey,estversion,compkey,chargecodekey,lastuserid,lastmaintdate)
		VALUES (@ware_estkey,0,0,0,'WARE_STORED_PROC',@ware_system_date)

		close warehouseversion
		deallocate warehouseversion
		return
   	end

	 while (@i_estverstatus <>-1 )
	   begin
		IF (@i_estverstatus <>-2)
		  begin
			select @ware_count2 = 0
			select @ware_count2 = count(*)
				from vendor
					where vendorkey = @i_finishedgoodvendorcode
	
			if  @ware_count2 > 0
			  begin
				select @ware_vendorname = name, @ware_vendorshort =shortdesc
					from vendor
						where vendorkey = @i_finishedgoodvendorcode
			end 
		insert into whest
			(estkey,bookkey,printingkey,estversion,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			lastuserid,lastmaintdate)
		VALUES (@ware_estkey, @ware_bookkey,@ware_printingkey,@i_versionkey,
			@d_requestdatetime,@c_requestedbyname,@c_requestid,@c_requestcomment,
			@c_requestbatchid,@i_finishedgoodqty,@ware_vendorname,'WARE_STORED_PROC',@ware_system_date)
		
		select @ware_count2 = 0
		select @ware_count2 = count(*) from whest 
			where estkey=@ware_estkey and bookkey= @ware_bookkey and printingkey= @ware_printingkey
		if @ware_count2 > 0
		  begin

		/* 5-26-04 save finishedgoodqty from cursor */
			select @ware_finishedgoodqty = @i_finishedgoodqty

			select @ware_count = @ware_count  + 1
			select @ware_count3 = 0
			select @ware_count3 = count(*)
				from estspecs e, endpaper ed
	  				 where  e.endpapertype = ed.endpapertypekey
						and e.estkey = @ware_estkey
						AND  e.versionkey = @i_versionkey 

			if @ware_count3 > 0 
			  begin
				 SELECT @ware_pagecount = e.pagecount,@ware_trimfamilycode=e.trimfamilycode,
     			   		@ware_film = e.film,@ware_bluesind= e.bluesind,@ware_mediacode =e.mediatypecode,
		      			@ware_mediasubcode = e.mediatypesubcode,@ware_colorcount=e.colorcount,
					@ware_endpapertype=e.endpapertype,@ware_foilamt=e.foilamt,@ware_covercode=e.covertypecode,
					@ware_firstprinting = e.firstprinting,@ware_plateavailind=e.plateavailind ,
					@ware_filmavailind = e.filmavailind, @ware_endpapertypedesc=ed.endpapertypedesc
						from estspecs e, endpaper ed
			  				where  e.endpapertype = ed.endpapertypekey
								and e.estkey = @ware_estkey
								AND  e.versionkey = @i_versionkey 
				 if @ware_trimfamilycode is null
				   begin
					select ware_trimfamilycode = 0
				   end
				if @ware_mediacode is null 
				  begin
					select @ware_mediacode = 0
				  end
				if @ware_mediasubcode is null 
				  begin
					select @ware_mediasubcode = 0
				  end
				if @ware_covercode is null 
				  begin
					select @ware_covercode = 0
				  end
				if @ware_film is null 
				  begin
					select @ware_film = 0
				  end
	
				if @ware_trimfamilycode > 0 
				  begin
					exec gentables_longdesc 29,@ware_trimfamilycode, @ware_trim_long OUTPUT
				  end
				else
				  begin
					select @ware_trim_long  =  ''
				  end
				if @ware_mediacode > 0 
				  begin
					exec gentables_longdesc 258,@ware_mediacode,@ware_media_long OUTPUT 
				  end
				else
				  begin
					select @ware_media_long =  ''
				  end
	
				if @ware_mediasubcode> 0 
				  begin
					exec subgent_longdesc 258,@ware_mediacode,@ware_mediasubcode, @ware_mediasub_long OUTPUT
				  end	
				else
				  begin
					select @ware_mediasub_long =  ''
				  end
	
				if @ware_covercode> 0 
				  begin
					exec gentables_longdesc 11,@ware_covercode,@ware_cover_long OUTPUT
				  end
				else
				  begin
					select @ware_cover_long =  ''
				  end	
				if @ware_film > 0 
				  begin
					 exec gentables_longdesc 50,@ware_film,@ware_film_long  OUTPUT
				  end
				else
				  begin
					select @ware_film_long =  ''
				  
end

BEGIN tran
				update whest
					set pagecount=@ware_pagecount,
						trimfamily = @ware_trim_long,
						film = @ware_film_long,
						bluesind = @ware_bluesind,
						mediatype = @ware_media_long,
						mediasubtype =@ware_mediasub_long,
						colorcount = @ware_colorcount,
						foilamt = @ware_foilamt,
						covertype = @ware_cover_long,
						firstprinting = @ware_firstprinting,
						plateavailind = @ware_plateavailind,
						filmavailind = @ware_filmavailind
						   where estkey =@ware_estkey
							and bookkey =@ware_bookkey
							and printingkey =@ware_printingkey
							and estversion = @i_versionkey	
commit tran
			  end

/*estplspecs pricing and royalty*/
		if @ware_company = 'CONSUMER' 
		  begin
			select @ware_pricecount = 0
			select @ware_pricecount =count(*) 
				FROM estplspecs e,estversion ev,
					estbook eb
   						WHERE e.estkey = ev.estkey
							AND  e.versionkey = ev.versionkey
							AND  ev.estkey = eb.estkey
							AND  e.estkey = @ware_estkey
							AND  e.versionkey = @i_versionkey

			if @ware_pricecount > 0 
			  begin

/*3-26-04 remove estversion from this select-- do not need finishedgoods already gotten in cursor*/

				SELECT @ware_listprice = e.listprice,@ware_discountpercent = e.discountpercent,
	      		  @ware_returnrate =e.returnrate,@ware_totalroyalty=e.royaltypercent,
			        @ware_royaltypercent=e.totalroyalty, @ware_returntostock =e.returntostock,
      			   @ware_ratecategorycode=eb.ratecategorycode,
	      		  @ware_saleschannelcode = e.saleschannelcode
					FROM estplspecs e,estbook eb
   						WHERE   e.estkey = eb.estkey
							AND  e.estkey = @ware_estkey
							AND  e.versionkey = @i_versionkey
			  end
		/* 5-16-02 no estplspecs rows so just case too many write errors
			
				INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
	     	   			 errorseverity, errorfunction,lastuserid, lastmaintdate)
				 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
					'Unable to retrieve estimate pricing information',
					('Warning/data error estkey '|| convert(varchar@ware_estkey)),
					'Stored procedure datawarehouse_estver','WARE_STORED_PROC', @ware_system_date)
			
		  	end */
		else
		  begin
			select @ware_pricecount = 0

			select @ware_pricecount = count(*)
			FROM estplspecs LEFT OUTER JOIN gentables ON estplspecs.columnheadingcode = gentables.datacode,   
				 estversion,   
				 estbook  
			WHERE  estplspecs.estkey = estversion.estkey 
				  AND estplspecs.versionkey = estversion.versionkey
				  AND estversion.estkey = estbook.estkey
				  AND ESTPLSPECS.estkey = @ware_estkey 						
				  AND ESTPLSPECS.versionkey = @i_versionkey
				  AND GENTABLES.tableid = 392    

			if  @ware_pricecount > 0 
			  begin
				SELECT @ware_listprice = ESTPLSPECS.listprice,@ware_discountpercent = ESTPLSPECS.discountpercent,
 		      		@ware_returnrate = ESTPLSPECS.returnrate, @ware_royaltypercent=ESTPLSPECS.royaltypercent,
	  				@ware_finishedgoodqty =ESTVERSION.finishedgoodqty,@ware_remainderprice= ESTPLSPECS.remainderprice,
		    			@ware_remainderqty =ESTPLSPECS.remainderqty,@ware_overheadpercent=ESTPLSPECS.OVERHEADPERCENT,
					@ware_advertisingpercent = ESTPLSPECS.ADVERTISINGPERCENT,@ware_totalroyalty =ESTPLSPECS.totalroyalty,
					@ware_columnheadingcode =ESTPLSPECS.COLUMNHEADINGCODE,@ware_userentercode =ESTPLSPECS.USERENTERCODE,
					@ware_datadescshort = gentables.DATADESCSHORT,@ware_ratecategorycode=ESTBOOK.ratecategorycode
				    FROM estplspecs LEFT OUTER JOIN gentables ON estplspecs.columnheadingcode = gentables.datacode,   
						 estversion,   
						 estbook  
					WHERE  estplspecs.estkey = estversion.estkey 
						  AND estplspecs.versionkey = estversion.versionkey
						  AND estversion.estkey = estbook.estkey
						  AND ESTPLSPECS.estkey = @ware_estkey 						
						  AND ESTPLSPECS.versionkey = @i_versionkey
						  AND GENTABLES.tableid = 392 
		  	  end
			else
			  begin
				INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
     	   				 errorseverity, errorfunction,lastuserid, lastmaintdate)
			 	VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
					'Unable to retrieve estimate pricing information',
					('Warning/data error estkey ' + convert(varchar,@ware_estkey)),
					'Stored procedure datawarehouse_estver','WARE_STORED_PROC', @ware_system_date)
			  end
		end
	end
	if @ware_ratecategorycode is null
	  begin
		select @ware_ratecategorycode  = 0
	  end
	if @ware_company <> 'CONSUMER' 
	  begin
		if @ware_remainderqty = 0 
		  begin
			select @ware_remainderqty =  (@ware_finishedgoodqty * @ware_discountpercent) / 100
		  end
	  end

/* estimate royalty information*/
	select @ware_royalcount = 0
	select @ware_royalcount = count(*)
			FROM ESTROYAL
  		 		WHERE estkey = @ware_estkey AND
			         versionkey = @i_versionkey
		if @ware_royalcount > 0 
		  begin
	 		SELECT @ware_royaltypercent = max(ROYALTYPERCENT), @ware_royaltyquantity = max(ROYALTYQUANTITY)				
	   			FROM ESTROYAL
					WHERE estkey = @ware_estkey AND
      				   versionkey = @i_versionkey
			if @ware_columnheadingcode = 0 and @ware_userentercode = 0 and @ware_ratecategorycode = 0 
			  begin
				select @ware_ratecategorycode = 1
			  end
			select @ware_count2 = 0
			select @ware_count2  = count(*) from DEFAULTPLSPECS

			if @ware_count2 > 0 
			  begin
				SELECT @ware_columnheadingcode1 = columnheadingcode,@ware_userentercode1 =userentercode,					 
					@ware_discountpercent1 = discountpercent, @ware_returnrate1 = returnrate,
					@ware_royaltypercent1= royaltypercentofcode,@ware_returntostock1=returntostockrate,
					@ware_saleschannelcode1 = saleschannelcode,@ware_remainderprice1 = remainderprice,
					@ware_remainderqty1 = remainderqty,@ware_overheadpercent1 =overheadpercent,
					@ware_advertisingpercent1 = advertisingpercent
					   FROM DEFAULTPLSPECS
						WHERE ratecategorycode= @ware_ratecategorycode
				if @ware_columnheadingcode1 is null
				  begin
					select @ware_columnheadingcode1 = 0
				  end
				if @ware_company <> 'CONSUMER' 
				  begin
					/* get columnheading desc from default*/
						select @ware_datadescshort = datadescshort 
							from gentables
								where tableid=392 and datacode = @ware_columnheadingcode1
						select @ware_columnheadingcode = @ware_columnheadingcode1
						select @ware_userentercode = @ware_userentercode1
				  end
				if @ware_pricecount = 0 
				  begin
					select @ware_discountpercent = @ware_discountpercent1
					select @ware_returnrate = @ware_returnrate1
					select @ware_royaltypercent = @ware_royaltypercent1
					if @ware_company = 'CONSUMER' 
					  begin
						select @ware_saleschannelcode = @ware_saleschannelcode1 
						select @ware_returntostock = @ware_returntostock1
					  end
					ELSE
					  begin
						select @ware_remainderprice = @ware_remainderprice1
						select @ware_remainderqty = @ware_remainderqty1
						select @ware_overheadpercent = @ware_overheadpercent1
						select @ware_advertisingpercent = @ware_advertisingpercent1
					  END
				  end
			  end
	  end
	else
	  begin

		INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
     	   		 errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
			'Unable to retrieve estimate royalty information',
			('Warning/data error estkey ' + convert(varchar,@ware_estkey)),
			'Stored procedure datawarehouse_estver','WARE_STORED_PROC', @ware_system_date)
	  end

/* do not see how these values are placed back into pricing? DO NOT CALL FOR NOW*/
/*	if @ware_royalcount = 0 then  royalty from above is zero do defaults*/
/*		if @ware_company = 'CONSUMER' and @ware_bookkey > 0 then */
/*			datawarehouse_estroyalty1 (@ware_bookkey,@ware_saleschannelcode,@ware_ratecategorycode,*/
/*			@ware_company,@ware_estkey,cursor_row.versionkey,@ware_logkey,*/
/*			@ware_warehousekey)*/
/*		else*/
/*			datawarehouse_estroyalty1 (@ware_bookkey,@ware_saleschannelcode,@ware_ratecategorycode,*/
/*			@ware_company,@ware_estkey,cursor_row.versionkey,@ware_logkey,*/
/*			@ware_warehousekey)*/
/*		end if */
/*	end if*/


/* estplspecs  costs */

	/* 05-25-05 PM CRM 2855 Reset @ware_totalplant */
	select @ware_totalplant = 0

	select @ware_count2 = 0
	select @ware_count2 = count(*) 
		FROM cdlist c, estcost e
			WHERE c.internalcode = e.chgcodecode  AND
				e.estkey = @ware_estkey  AND
				 e.versionkey = @i_versionkey
				AND c.costtype='P'


	if @ware_count2 > 0 
	  begin
		SELECT @ware_costtype = c.costtype,@ware_totalplant = SUM(e.totalcost) 
				FROM cdlist c, estcost e
					WHERE c.internalcode = e.chgcodecode  AND
						e.estkey = @ware_estkey  AND
						 e.versionkey = @i_versionkey
						AND c.costtype='P'
					GROUP BY c.costtype

	  end
	select @ware_count3 = 0
	select @ware_count3 = count(*) 
		FROM cdlist c, estcost e
			WHERE c.internalcode = e.chgcodecode  AND
				e.estkey = @ware_estkey  AND
				 e.versionkey = @i_versionkey
				AND c.costtype='E'
	if @ware_count3 > 0 
	  begin
		SELECT  @ware_costtype = c.costtype,@ware_totaledition = SUM(e.totalcost)
				FROM cdlist c, estcost e
					WHERE c.internalcode = e.chgcodecode  AND
						e.estkey = @ware_estkey  AND
						 e.versionkey = @i_versionkey
						AND c.costtype='E'
					GROUP BY c.costtype

	  end

	if @ware_count2 = 0 and @ware_count3 = 0 
	  begin
			INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
     	   		 errorseverity, errorfunction,lastuserid, lastmaintdate)
		 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
			'Error retrieving total costs',
			('Warning/data error estkey ' + convert(varchar,@ware_estkey)),
			'Stored procedure datawarehouse_estver','WARE_STORED_PROC', @ware_system_date)

	  end
	if @ware_totaledition is null
	  begin
		select @ware_totaledition = 0
	  end
	if @ware_totalplant is null
	  begin
		select @ware_totalplant = 0
	  end
	if @ware_finishedgoodqty is null
	  begin
		select @ware_finishedgoodqty = 0
	  end


	select @c_price_received = ( @ware_listprice  * (1- @ware_discountpercent / 100 ))
	select @c_net_copies = ( @ware_finishedgoodqty - ( @ware_finishedgoodqty * @ware_returnrate /100 ))
	select @c_total_edition = @ware_totaledition
	select @c_total_plant = @ware_totalplant


	if @ware_finishedgoodqty > 0 
	  begin
		select @c_edition_fg = ( @c_total_edition / @ware_finishedgoodqty )
		select @c_plant_fg = ( @c_total_plant /@ware_finishedgoodqty )
	  end

	if @c_net_copies > 0 
	  begin
		select @c_edition_netcopy = ( @c_total_edition / @c_net_copies )
	  end 
	if @ware_columnheadingcode = 1 
	  begin
		select @c_percentof = @ware_listprice * @ware_finishedgoodqty
	  end
	else
	  begin
	  	select @c_percentof = (@ware_listprice * ( 1 - @ware_discountpercent / 100 )) * @ware_finishedgoodqty 
	  end
	if @c_percentof > 0 
	  begin
		select @c_edition_percent = ( @ware_totaledition / @c_percentof ) * 100
	  end
	if @c_net_copies > 0
	  begin
		select @c_plant_netcopy = ( @c_total_plant / @c_net_copies )
	  end
	if @c_percentof > 0 
	 begin
		select @c_plant_percent = ( @ware_totalplant / @c_percentof ) * 100
	  end
	select @c_total_prod = (@c_total_edition + @c_total_plant)
	select @c_prod_netcopy = ( @c_edition_netcopy + @c_plant_netcopy )
	if @c_percentof > 0 
	  begin
		select @c_prod_percent  = ( @c_total_prod / @c_percentof ) * 100
	  end
	select @c_total_royalty = @ware_totalroyalty
	if @c_net_copies > 0 
	  begin
		select @c_royalty_netcopy = (@ware_totalroyalty/@c_net_copies )
	  end
	if @c_percentof > 0 
	   begin
		select @c_royalty_percent  = ( @c_total_royalty / @c_percentof ) * 100
	  end
	if @ware_userentercode = 2 AND @ware_overheadfgqty > 0 
	  begin
	      select @c_total_overhead = @ware_overheadfgqty * @ware_finishedgoodqty
	  end
	if @ware_userentercode = 3 AND @ware_overheadnetcopy > 0 
	  begin
      	select @c_total_overhead = @ware_overheadnetcopy * @c_net_copies
	  end
	if @ware_userentercode = 1 AND @ware_totaloverhead > 0 
	  begin
		select @c_total_overhead = @ware_totaloverhead
	  end
	else
	  begin
		select @c_total_overhead = (@ware_overheadpercent/100) * @c_percentof
	  end
	select @ware_totaloverhead =  @c_total_overhead

 	if @ware_userentercode = 1 AND @ware_totaloverhead > 0 
	  begin
      	 select @c_overhead_fg = @ware_totaloverhead / @ware_finishedgoodqty
	  end
  	if @ware_userentercode = 3 AND @ware_overheadnetcopy > 0 
	  begin
		if @ware_finishedgoodqty > 0 
		  begin
		 	select @c_overhead_fg = (@ware_overheadnetcopy * @c_net_copies) / @ware_finishedgoodqty
		  end
	  end
	if @ware_userentercode = 2 AND @ware_overheadfgqty > 0 
	  begin
		select @c_overhead_fg = @ware_overheadfgqty
	  end
	else
	  begin
		if @ware_finishedgoodqty > 0 
		  begin
			select @c_overhead_fg = (@ware_overheadpercent/100 * @c_percentof) / @ware_finishedgoodqty
		  end
	  end

	if @ware_userentercode = 1 AND @ware_totaloverhead > 0 
	  begin
		if @c_net_copies > 0 
		  begin
	      	 select @c_overhead_netcopy = @ware_totaloverhead / @c_net_copies
		 end
	  end
	if @ware_userentercode = 2 AND @ware_overheadfgqty > 0 
	  begin
		if @c_net_copies > 0 
		  begin
			select @c_overhead_netcopy = (@ware_overheadfgqty * @ware_finishedgoodqty) /  @c_net_copies
		  end
	  end
  	if @ware_userentercode = 3 AND @ware_overheadnetcopy > 0 
	  begin
	       select @c_overhead_netcopy = @ware_overheadnetcopy
	  end
	else
	  begin
		if @c_net_copies > 0 
		  begin
			select @c_overhead_netcopy = (@ware_overheadpercent/100 * @c_percentof) / @c_net_copies 
		  end
	  end

	if @ware_userentercode = 1 AND @ware_totaloverhead > 0 AND @c_percentof > 0 
	  begin
     		select @c_overhead_percent = ( @ware_totaloverhead / @c_percentof ) * 100
	  end
	if @ware_userentercode = 2 AND @ware_overheadfgqty > 0 AND @c_percentof > 0 
	  begin
	     select @c_overhead_percent = (( @ware_overheadfgqty * @ware_finishedgoodqty ) / @c_percentof ) * 100
	  end
	if @ware_userentercode = 3 AND @ware_overheadnetcopy > 0 AND @c_percentof > 0 
	  begin
	     select @c_overhead_percent = (( @ware_overheadnetcopy * @c_net_copies ) / @c_percentof ) * 100	
	  end
	else
	  begin
		select @c_overhead_percent = @ware_overheadpercent
	  end

	if @ware_userentercode = 2 AND @ware_advertisingfgqty > 0 
	  begin
       	select @c_total_advertising = @ware_advertisingfgqty * @ware_finishedgoodqty
	  end
	if @ware_userentercode = 3 AND @ware_advertisingnetcopy > 0 
	  begin
       	select @c_total_advertising = @ware_advertisingnetcopy * @c_net_copies
	  end
	if @ware_userentercode = 1 AND @ware_totaladvertising > 0 
	  begin
		select @c_total_advertising = @ware_totaladvertising
	  end
	else
	  begin
      	select @c_total_advertising = (@ware_advertisingpercent/100) * @c_percentof 
	  end
	
	select @ware_totaladvertising =  @c_total_advertising

	if @ware_userentercode = 1 AND @ware_totaladvertising > 0 
	  begin
		if @ware_finishedgoodqty > 0 
		  begin
			select @c_advertising_fg = @ware_totaladvertising / @ware_finishedgoodqty
		  end
	  end
	if @ware_userentercode = 3 AND @ware_advertisingnetcopy > 0 
	  begin
		if @ware_finishedgoodqty > 0 
		  begin
			select @c_advertising_fg = (@ware_advertisingnetcopy * @c_net_copies) / @ware_finishedgoodqty
		  end
	  end
	if @ware_userentercode = 2 AND @ware_advertisingfgqty > 0 	
	  begin
		select @c_advertising_fg = @ware_advertisingfgqty
	  end
	else
	  begin
		if @ware_finishedgoodqty > 0 
		  begin
		     select @c_advertising_fg = (@ware_advertisingpercent/100 * @c_percentof) / @ware_finishedgoodqty
		  end
	  end

	if @ware_userentercode = 1 AND @ware_totaladvertising > 0 
	  begin
		if @c_net_copies > 0 
		  begin
			select @c_advertising_netcopy = @ware_totaladvertising / @c_net_copies
		  end
	  end
	if @ware_userentercode = 2 AND @ware_advertisingfgqty > 0 
	  begin
		if @c_net_copies > 0 
		  begin
		     select @c_advertising_netcopy = (@ware_advertisingfgqty * @ware_finishedgoodqty) /  @c_net_copies
		  end
	  end
	if @ware_userentercode = 3 AND @ware_advertisingnetcopy > 0 
	  begin
		select @c_advertising_netcopy = @ware_advertisingnetcopy
	  end
	else
	  begin
		if @c_net_copies > 0 
		  begin
			select @c_advertising_netcopy = (@ware_advertisingpercent/100 * @c_percentof ) / @c_net_copies 
		  end
	  end
	if @ware_userentercode = 1 AND @ware_totaladvertising > 0 AND @c_percentof > 0 
	  begin
		select @c_advertising_percent = (@ware_totaladvertising / @c_percentof ) * 100
	  end
	if @ware_userentercode = 2 AND @ware_advertisingfgqty > 0 AND @c_percentof > 0
	  begin
		select @c_advertising_percent =  ((@ware_advertisingfgqty * @ware_finishedgoodqty ) / @c_percentof ) * 100
	  end
	if @ware_userentercode = 3 AND @ware_advertisingnetcopy > 0 AND @c_percentof > 0 
	  begin
		select @c_advertising_percent = ((@ware_advertisingnetcopy * @c_net_copies ) / @c_percentof ) * 100
	  end
	else
	  begin
		select @c_advertising_percent =  @ware_advertisingpercent
	  end

	select @c_total_cost = ( round(@ware_totaledition,2) + @ware_totalplant + round(@ware_totalroyalty,2) + @ware_totaloverhead + @ware_totaladvertising )
	select @c_returned_qty = ( @ware_finishedgoodqty * @ware_returnrate/100 )
	select @c_sales = (@ware_finishedgoodqty * @c_price_received )
	select @c_returns = ( @c_returned_qty * @c_price_received )
	select @c_net_sales = ( @c_sales - @c_returns )
	select @c_remainder_sales = ( @ware_remainderprice * @ware_remainderqty )
	select @c_total_revenue = ( @c_net_sales + @c_remainder_sales )
	if @ware_finishedgoodqty > 0 
	  begin
		select @c_revenue_per_fgqty = ( @c_total_revenue / @ware_finishedgoodqty )
	  end
	if @c_net_copies > 0 
	  begin
		select @c_revenue_per_netcopies = ( @c_total_revenue / @c_net_copies )
	  end
	select @c_profit_loss = ( @c_total_revenue - @c_total_cost )
	if @ware_finishedgoodqty > 0 	
	  begin
		select @c_profitloss_per_fgqty = ( @c_profit_loss / @ware_finishedgoodqty )
	  end
	if @c_net_copies > 0 
	  begin
		select @c_profitloss_per_netcopies = ( @c_profit_loss / @c_net_copies )
	  end
	if @c_total_revenue > 0 
	  begin
		select @c_profit_margin = ( @c_profit_loss / @c_total_revenue ) * 100
	  end

	if @ware_company <> 'CONSUMER' 	
	  begin
            if @ware_finishedgoodqty > 0 	
		  begin
			select @c_total_prod = @c_total_prod / @ware_finishedgoodqty
                	select @c_total_royalty = @c_total_royalty/@ware_finishedgoodqty
	    	  end
	BEGIN tran

		UPDATE WHEST
			SET finishedgoodqty = @ware_finishedgoodqty,
			   retailprice = @ware_listprice,
			   avgpricerecd = @c_price_received,
			   returnrate  = @ware_returnrate,
			   remainderprice = @ware_remainderprice,
			   discountpct = @ware_discountpercent,
			   netcopiessold = @c_net_copies,
			   remainderqty = @ware_remainderqty,
			   editioncost = @c_total_edition,
			   editionfgunit = @c_edition_fg,
			   editionnetunit = @c_edition_netcopy,
			   editionpct = @c_edition_percent,
			   plantcost = @c_total_plant,
			   plantfgunit = @c_plant_fg,
			   plantnetunit = @c_plant_netcopy,
			   plantpct = @c_plant_percent,
			   prodcost = @c_total_prod,
			   prodfgunit = @c_prod_unit,
			   prodnetunit = @c_prod_netcopy,
			   prodpct = @c_prod_percent,
			   royaltycost = @c_total_royalty,
			   royaltyfgunit = @c_total_royalty,
			   royaltynetunit = @c_royalty_netcopy,
			   royaltypct = @c_royalty_percent,
			   overhead = @c_total_overhead,
			   overheadfgunit = @c_overhead_fg,
			   overheadnetunit = @c_overhead_netcopy,
			   overheadpct = @c_overhead_percent,
			   advertising = @c_total_advertising,
			   advertisingfgunit = @c_advertising_fg,
			   advertisingnetunit = @c_advertising_netcopy,
			   advertisingpct = @c_advertising_percent,
			   totalcost = @c_total_cost,
			   totalfgunit = ( @c_prod_fg + @c_royalty_fg + @ware_overheadfgqty + @ware_advertisingfgqty ),
			   totalnetunit = ( @c_prod_netcopy + @c_royalty_netcopy + @ware_overheadnetcopy + @ware_advertisingnetcopy ),
			   totalpct = ( @c_prod_percent + @c_royalty_percent + @c_overhead_percent + @c_advertising_percent ),
			   revenue = @c_total_revenue,
			   revenuefgunit = @c_revenue_per_fgqty,
			   revenuenetunit = @c_revenue_per_netcopies,
			   profitloss = @c_profit_loss,
			   profitlossfgunit = @c_profitloss_per_fgqty,
			   profitlossnetunit = @c_profitloss_per_netcopies,
			   profitmargin = @c_profit_margin
/*			   grosssalescost = @c_sales,*/
/*			   grosssalesperunit = @c_gross_unit*/
			     where estkey =@ware_estkey
						and bookkey =@ware_bookkey
						and printingkey =@ware_printingkey
						and estversion = @i_versionkey
commit tran
		end
	  end
	else
	  begin
		select @c_net_unit =  (@ware_listprice  * (1- @ware_discountpercent / 100 ))
		select @c_gross_sales = (@ware_finishedgoodqty * Round( @c_net_unit, 3 ))
		if @ware_finishedgoodqty > 0 
		  begin
			select @c_gross_unit = ( @c_gross_sales /@ware_finishedgoodqty )
		  end
		select @c_gross_percent = 100.0
		select @c_netqty = (@ware_finishedgoodqty * (100 - @ware_returnrate ) / 100 )
		select @c_net_sales = ( @c_netqty * Round( @c_net_unit, 3 ))
		if @c_netqty > 0 	
		  begin
			select @c_edition_unit = ( @ware_totaledition / @c_netqty )
		  end
		if @c_net_sales > 0 
		  begin
			select @c_edition_percent = ( @ware_totaledition / @c_net_sales ) * 100
		  end
		select @c_inv_wo = (@ware_finishedgoodqty - @c_netqty ) * (100 - @ware_returntostock ) / 100  * Round( @c_edition_unit, 3 )
		if @c_netqty > 0 
		  begin
			select @c_inv_wo_unit = ( @c_inv_wo / @c_netqty )
		  end
		if @c_net_sales > 0 
		  begin
			select @c_inv_wo_percent = ( @c_inv_wo / @c_net_sales ) * 100
		  end
		if @c_netqty  > 0 
		  begin
			select @c_plant_unit = ( @ware_totalplant / @c_netqty )
		  end
		if @c_net_sales > 0 
		  begin
			select @c_plant_percent = ( @ware_totalplant / @c_net_sales ) * 100
		  end
		select @c_total_prod = (@ware_totaledition + @c_inv_wo + @ware_totalplant )
		select @c_prod_unit = ( @c_edition_unit + @c_inv_wo_unit + @c_plant_unit )
 		select @c_prod_percent = (@c_edition_percent + @c_inv_wo_percent + @c_plant_percent )
		if @c_netqty > 0 
		  begin
			select @c_royalty_unit = (@ware_totalroyalty / @c_netqty )
		  end
		if @c_net_sales > 0 
		  begin
			select @c_royalty_percent = (@ware_totalroyalty / @c_net_sales ) * 100
		  end
		select @c_total_cost = ( @c_total_prod + round(@ware_totalroyalty,2) )
		select @c_total_unit = ( @c_prod_unit + @c_royalty_unit )
		select @c_total_percent = ( @c_prod_percent + @c_royalty_percent )
		select @c_var_gp = ( @c_net_sales - ( @c_total_cost - @ware_totalplant ))
		if @c_netqty >0 
		  begin
			select @c_var_gp_unit = ( @c_var_gp / @c_netqty )
		  end
BEGIN tran
		UPDATE WHEST
			SET finishedgoodqty = @ware_finishedgoodqty,
			   retailprice = @ware_listprice,
			   avgpricerecd  = @c_price_received,
	/*		   returntostock = @ware_returntostock,*/
			   returnrate  = @ware_returnrate,
			   discountpct = @ware_discountpercent,
  		/*	   grosssalescost	= @c_gross_sales,*/
		/*	   grosssalesperunit = @c_gross_unit,*/
		/*	   grosssalespct = @c_gross_percent,*/
		/*	   netsalescost = @c_net_sales,*/
		/*	   netsalesperunit = @c_net_unit,*/
		/*	   netsalespct = 100.0,*/
			   editioncost = @ware_totaledition,
			   editionnetunit = @c_edition_unit,
			   editionpct = @c_edition_percent ,
	/*		   invwriteoffcost = @c_inv_wo,*/
	/*		   invwriteoffperunit = @c_inv_wo_unit,*/
	/*		   invwriteoffpct = @c_inv_wo_percent,*/
			   plantcost = @ware_totalplant,
			   plantfgunit = @c_plant_unit,
			   plantpct = @c_plant_percent,
			   prodcost = @c_total_prod,
			   prodfgunit = @c_prod_unit,
			   prodpct = @c_prod_percent,
			   royaltycost = @ware_totalroyalty,
			   royaltyfgunit = @c_royalty_unit,
			   royaltypct = @c_royalty_percent,
			   totalcost = @c_total_cost,
			   totalfgunit = @c_total_unit,
			   totalpct = @c_total_percent
 	/*		   vargrossprofitcost = @c_var_gp,*/
	/*		   vargrossprofitperunit = @c_var_gp_unit,*/
	/*		   vargrossprofitpct = (@c_var_gp / @c_net_sales ) * 100*/
				     where estkey =@ware_estkey
						and bookkey =@ware_bookkey
						and printingkey =@ware_printingkey
						and estversion = @i_versionkey
commit tran
	end

	exec datawarehouse_estcomp @ware_bookkey,@ware_printingkey,@ware_estkey,
	@i_versionkey,@ware_logkey,@ware_warehousekey,@ware_system_date /*whest*/

	exec datawarehouse_estcost @ware_estkey,@i_versionkey,
	@ware_logkey,@ware_warehousekey,@ware_system_date /*whestcost*/
   end
else
  begin
BEGIN tran
	INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
		'Unable to insert whest table - for estversion',
		('Warning/data error estkey ' + convert(varchar,@ware_estkey)),
	'Stored procedure datawarehouse_estver','WARE_STORED_PROC',@ware_system_date)
commit tran
  end /*<>2*/
	FETCH NEXT FROM warehouseversion
		INTO @i_versionkey,@i_finishedgoodqty,@i_finishedgoodvendorcode,
			@d_requestdatetime,@c_requestedbyname,@c_requestid,
			@c_requestcomment,@c_requestbatchid

	select @i_estverstatus = @@FETCH_STATUS
end
 if @ware_count = 1 
  begin
BEGIN tran
	insert into whest
			(estkey,bookkey,printingkey,estversion,lastuserid,lastmaintdate)
		VALUES (@ware_estkey, @ware_bookkey,@ware_printingkey,0,'WARE_STORED_PROC',@ware_system_date)
	insert into whestcost
			(estkey,estversion,compkey,chargecodekey,lastuserid,lastmaintdate)
		VALUES (@ware_estkey,0,0,0,'WARE_STORED_PROC',@ware_system_date)
commit tran
  end

close warehouseversion
deallocate warehouseversion


GO

