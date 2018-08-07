
if exists (select * from dbo.sysobjects where id = Object_id('dbo.datawarehouse_estupd') and (type = 'P' or 
type = 'RF'))
begin
 drop proc dbo.datawarehouse_estupd
end

GO
 
CREATE  proc dbo.datawarehouse_estupd
@ware_estkey int ,
@ware_estversion int,
@ware_bookkey int,
@ware_printingkey int,
@ware_sortorder int,
@f_paperprice float,
@c_basiswtdesc varchar(100) ,
@c_stocktype varchar(100) ,
@i_allocationmr int,
@i_allocationper1000 int,
@i_allocation int,
@f_royaltyper1 float,
@f_royaltyper2 float,
@f_royaltyper3 float,
@i_royaltyqty1 int,
@i_royaltyqty2 int,
@i_royaltyqty3 int,
@c_statusdesc varchar(100) ,
@c_statusshortdesc varchar(100) ,
@c_lastusername varchar(100) ,
@ware_cartonqty int,
@ware_printqty int,
@ware_coverqty int,
@ware_jacketqty int,
@ware_insertqty int,
@ware_endpapqty int,
@yesno  varchar(20) OUTPUT

AS

DECLARE @insert_count int

Begin Tran
	if @ware_sortorder = 1 
	  begin
		select @insert_count = 0

		select @insert_count = count(*) from whestfields1 where estkey= @ware_estkey
		if @insert_count > 0
		  begin
			delete from whestfields1 where estkey= @ware_estkey
		  end
		insert into whestfields1 
			(estkey,estversion,bookkey,printingkey,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			pagecount,trimfamily,film,bluesind,mediatype,mediasubtype,colorcount,foilamt,
			covertype,firstprinting,plateavailind,filmavailind,retailprice,
			avgpricerecd,returnrate,remainderprice,discountpct,netcopiessold,remainderqty,
			editioncost,editionfgunit,editionnetunit,editionpct,plantcost,plantfgunit,
			plantnetunit,plantpct,prodcost,prodfgunit,prodnetunit,prodpct,royaltycost,
			royaltyfgunit,royaltynetunit,royaltypct,overhead,overheadfgunit,overheadnetunit,
			overheadpct,advertising,advertisingfgunit,advertisingnetunit,advertisingpct,
			totalcost,totalfgunit,totalnetunit,totalpct,revenue,revenuefgunit,revenuenetunit,
			profitloss,profitlossfgunit,profitlossnetunit,profitmargin,estspecs,versiondesc)
		(select estkey,estversion,bookkey,printingkey,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			pagecount,trimfamily,film,bluesind,mediatype,mediasubtype,colorcount,foilamt,
			covertype,firstprinting,plateavailind,filmavailind,retailprice,
			avgpricerecd,returnrate,remainderprice,discountpct,netcopiessold,remainderqty,
			editioncost,editionfgunit,editionnetunit,editionpct,plantcost,plantfgunit,
			plantnetunit,plantpct,prodcost,prodfgunit,prodnetunit,prodpct,royaltycost,
			royaltyfgunit,royaltynetunit,royaltypct,overhead,overheadfgunit,overheadnetunit,
			overheadpct,advertising,advertisingfgunit,advertisingnetunit,advertisingpct,
			totalcost,totalfgunit,totalnetunit,totalpct,revenue,revenuefgunit,revenuenetunit,
			profitloss,profitlossfgunit,profitlossnetunit,profitmargin,estspecs,versiondesc
				from whest w
					where w.estkey= @ware_estkey and w.estversion =  @ware_estversion 
						and w.bookkey = @ware_bookkey
						and w.printingkey=@ware_printingkey)
						
		 update whestcostfields1
			set estversionkey = @ware_estversion 
			 where estkey = @ware_estkey 

		update whestfields1
			set paperprice = @f_paperprice,
			    paperbasisweight = @c_basiswtdesc,
			    paperstocktype = @c_stocktype,
			    paperallocationmr = @i_allocationmr,
			    paperallocationper1000 = @i_allocationper1000,
			    paperallocation = @i_allocation,
			    royaltypercent1 = @f_royaltyper1,
			    royaltyquantity1 = @i_royaltyqty1,
  			    royaltypercent2 = @f_royaltyper2,
			    royaltyquantity2 = @i_royaltyqty2,
			    royaltypercent3 = @f_royaltyper3,
			    royaltyquantity3 = @i_royaltyqty3,
			    estimatestatusdesc = @c_statusdesc,
			    estimatestatusshortdesc = @c_statusshortdesc,
			    lastuserid ='WAREEST_STORED_PROC',
			    lastusername = @c_lastusername,
			    lastmaintdate =getdate(),
			   printqty = @ware_printqty,
			    coverqty = @ware_coverqty,
			    jacketqty = @ware_jacketqty, 
			    insertqty = @ware_insertqty, 
			    endpaperqty = @ware_endpapqty,
			    cartonqty = @ware_cartonqty
				where  estkey= @ware_estkey and estversion = @ware_estversion 
	end

	if @ware_sortorder = 2 
	  begin
		select @insert_count = 0

		select @insert_count = count(*) from whestfields2 where estkey= @ware_estkey
		if @insert_count > 0
		  begin
			delete from whestfields2 where estkey= @ware_estkey
		  end
		insert into whestfields2 
			(estkey,estversion,bookkey,printingkey,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			pagecount,trimfamily,film,bluesind,mediatype,mediasubtype,colorcount,foilamt,
			covertype,firstprinting,plateavailind,filmavailind,retailprice,
			avgpricerecd,returnrate,remainderprice,discountpct,netcopiessold,remainderqty,
			editioncost,editionfgunit,editionnetunit,editionpct,plantcost,plantfgunit,
			plantnetunit,plantpct,prodcost,prodfgunit,prodnetunit,prodpct,royaltycost,
			royaltyfgunit,royaltynetunit,royaltypct,overhead,overheadfgunit,overheadnetunit,
			overheadpct,advertising,advertisingfgunit,advertisingnetunit,advertisingpct,
			totalcost,totalfgunit,totalnetunit,totalpct,revenue,revenuefgunit,revenuenetunit,
			profitloss,profitlossfgunit,profitlossnetunit,profitmargin,estspecs,versiondesc)
		(select estkey,estversion,bookkey,printingkey,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			pagecount,trimfamily,film,bluesind,mediatype,mediasubtype,colorcount,foilamt,
			covertype,firstprinting,plateavailind,filmavailind,retailprice,
			avgpricerecd,returnrate,remainderprice,discountpct,netcopiessold,remainderqty,
			editioncost,editionfgunit,editionnetunit,editionpct,plantcost,plantfgunit,
			plantnetunit,plantpct,prodcost,prodfgunit,prodnetunit,prodpct,royaltycost,
			royaltyfgunit,royaltynetunit,royaltypct,overhead,overheadfgunit,overheadnetunit,
			overheadpct,advertising,advertisingfgunit,advertisingnetunit,advertisingpct,
			totalcost,totalfgunit,totalnetunit,totalpct,revenue,revenuefgunit,revenuenetunit,
			profitloss,profitlossfgunit,profitlossnetunit,profitmargin,estspecs,versiondesc
				from whest w
					where w.estkey= @ware_estkey and w.estversion =  @ware_estversion 
						and w.bookkey = @ware_bookkey
						and w.printingkey=@ware_printingkey)

		 update whestcostfields2
			set estversionkey = @ware_estversion 
			 where estkey = @ware_estkey 

		update whestfields2
			set paperprice = @f_paperprice,
			    paperbasisweight = @c_basiswtdesc,
			    paperstocktype = @c_stocktype,
			    paperallocationmr = @i_allocationmr,
			    paperallocationper1000 = @i_allocationper1000,
			    paperallocation = @i_allocation,
			    royaltypercent1 = @f_royaltyper1,
			    royaltyquantity1 = @i_royaltyqty1,
  			    royaltypercent2 = @f_royaltyper2,
			    royaltyquantity2 = @i_royaltyqty2,
			    royaltypercent3 = @f_royaltyper3,
			    royaltyquantity3 = @i_royaltyqty3,
			    estimatestatusdesc = @c_statusdesc,
			    estimatestatusshortdesc = @c_statusshortdesc,
			    lastuserid ='WAREEST_STORED_PROC',
			    lastusername = @c_lastusername,
			    lastmaintdate =getdate(),
			    printqty = @ware_printqty,
			    coverqty = @ware_coverqty,
			    jacketqty = @ware_jacketqty, 
			    insertqty = @ware_insertqty, 
			    endpaperqty = @ware_endpapqty,
   			    cartonqty = @ware_cartonqty
			
				where  estkey= @ware_estkey and estversion = @ware_estversion 
	end
	if @ware_sortorder = 3
	  begin
			select @insert_count = 0

		select @insert_count = count(*) from whestfields3 where estkey= @ware_estkey
		if @insert_count > 0
		  begin
			delete from whestfields3 where estkey= @ware_estkey
		  end
		insert into whestfields3 
			(estkey,estversion,bookkey,printingkey,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			pagecount,trimfamily,film,bluesind,mediatype,mediasubtype,colorcount,foilamt,
			covertype,firstprinting,plateavailind,filmavailind,retailprice,
			avgpricerecd,returnrate,remainderprice,discountpct,netcopiessold,remainderqty,
			editioncost,editionfgunit,editionnetunit,editionpct,plantcost,plantfgunit,
			plantnetunit,plantpct,prodcost,prodfgunit,prodnetunit,prodpct,royaltycost,
			royaltyfgunit,royaltynetunit,royaltypct,overhead,overheadfgunit,overheadnetunit,
			overheadpct,advertising,advertisingfgunit,advertisingnetunit,advertisingpct,
			totalcost,totalfgunit,totalnetunit,totalpct,revenue,revenuefgunit,revenuenetunit,
			profitloss,profitlossfgunit,profitlossnetunit,profitmargin,estspecs,versiondesc)
		(select estkey,estversion,bookkey,printingkey,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			pagecount,trimfamily,film,bluesind,mediatype,mediasubtype,colorcount,foilamt,
			covertype,firstprinting,plateavailind,filmavailind,retailprice,
			avgpricerecd,returnrate,remainderprice,discountpct,netcopiessold,remainderqty,
			editioncost,editionfgunit,editionnetunit,editionpct,plantcost,plantfgunit,
			plantnetunit,plantpct,prodcost,prodfgunit,prodnetunit,prodpct,royaltycost,
			royaltyfgunit,royaltynetunit,royaltypct,overhead,overheadfgunit,overheadnetunit,
			overheadpct,advertising,advertisingfgunit,advertisingnetunit,advertisingpct,
			totalcost,totalfgunit,totalnetunit,totalpct,revenue,revenuefgunit,revenuenetunit,
			profitloss,profitlossfgunit,profitlossnetunit,profitmargin,estspecs,versiondesc
				from whest w
					where w.estkey= @ware_estkey and w.estversion =  @ware_estversion 
						and w.bookkey = @ware_bookkey
						and w.printingkey=@ware_printingkey)

		 update whestcostfields3
			set estversionkey = @ware_estversion 
			 where estkey = @ware_estkey 

		update whestfields3
			set paperprice = @f_paperprice,
			    paperbasisweight = @c_basiswtdesc,
			    paperstocktype = @c_stocktype,
			    paperallocationmr = @i_allocationmr,
			    paperallocationper1000 = @i_allocationper1000,
			    paperallocation = @i_allocation,
			    royaltypercent1 = @f_royaltyper1,
			    royaltyquantity1 = @i_royaltyqty1,
  			    royaltypercent2 = @f_royaltyper2,
			    royaltyquantity2 = @i_royaltyqty2,
			    royaltypercent3 = @f_royaltyper3,
			    royaltyquantity3 = @i_royaltyqty3,
			    estimatestatusdesc = @c_statusdesc,
			    estimatestatusshortdesc = @c_statusshortdesc,
			    lastuserid ='WAREEST_STORED_PROC',
			    lastusername = @c_lastusername,
			    lastmaintdate =getdate(),
			    printqty = @ware_printqty,
			    coverqty = @ware_coverqty,
			    jacketqty = @ware_jacketqty, 
			    insertqty = @ware_insertqty, 
			    endpaperqty = @ware_endpapqty,
			    cartonqty = @ware_cartonqty
				where  estkey= @ware_estkey and estversion = @ware_estversion 

	end

	if @ware_sortorder = 4
	  begin
		select @insert_count = 0

		select @insert_count = count(*) from whestfields4 where estkey= @ware_estkey
		if @insert_count > 0
		  begin
			delete from whestfields4 where estkey= @ware_estkey
		  end
		insert into whestfields4 
			(estkey,estversion,bookkey,printingkey,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			pagecount,trimfamily,film,bluesind,mediatype,mediasubtype,colorcount,foilamt,
			covertype,firstprinting,plateavailind,filmavailind,retailprice,
			avgpricerecd,returnrate,remainderprice,discountpct,netcopiessold,remainderqty,
			editioncost,editionfgunit,editionnetunit,editionpct,plantcost,plantfgunit,
			plantnetunit,plantpct,prodcost,prodfgunit,prodnetunit,prodpct,royaltycost,
			royaltyfgunit,royaltynetunit,royaltypct,overhead,overheadfgunit,overheadnetunit,
			overheadpct,advertising,advertisingfgunit,advertisingnetunit,advertisingpct,
			totalcost,totalfgunit,totalnetunit,totalpct,revenue,revenuefgunit,revenuenetunit,
			profitloss,profitlossfgunit,profitlossnetunit,profitmargin,estspecs,versiondesc)
		(select estkey,estversion,bookkey,printingkey,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			pagecount,trimfamily,film,bluesind,mediatype,mediasubtype,colorcount,foilamt,
			covertype,firstprinting,plateavailind,filmavailind,retailprice,
			avgpricerecd,returnrate,remainderprice,discountpct,netcopiessold,remainderqty,
			editioncost,editionfgunit,editionnetunit,editionpct,plantcost,plantfgunit,
			plantnetunit,plantpct,prodcost,prodfgunit,prodnetunit,prodpct,royaltycost,
			royaltyfgunit,royaltynetunit,royaltypct,overhead,overheadfgunit,overheadnetunit,
			overheadpct,advertising,advertisingfgunit,advertisingnetunit,advertisingpct,
			totalcost,totalfgunit,totalnetunit,totalpct,revenue,revenuefgunit,revenuenetunit,
			profitloss,profitlossfgunit,profitlossnetunit,profitmargin,estspecs,versiondesc
				from whest w
					where w.estkey= @ware_estkey and w.estversion =  @ware_estversion 
						and w.bookkey = @ware_bookkey
						and w.printingkey=@ware_printingkey)

		 update whestcostfields4
			set estversionkey = @ware_estversion 
			 where estkey = @ware_estkey 

		
		update whestfields4
			set paperprice = @f_paperprice,
			    paperbasisweight = @c_basiswtdesc,
			    paperstocktype = @c_stocktype,
			    paperallocationmr = @i_allocationmr,
			    paperallocationper1000 = @i_allocationper1000,
			    paperallocation = @i_allocation,
			    royaltypercent1 = @f_royaltyper1,
			    royaltyquantity1 = @i_royaltyqty1,
  			    royaltypercent2 = @f_royaltyper2,
			    royaltyquantity2 = @i_royaltyqty2,
			    royaltypercent3 = @f_royaltyper3,
			    royaltyquantity3 = @i_royaltyqty3,
			    estimatestatusdesc = @c_statusdesc,
			    estimatestatusshortdesc = @c_statusshortdesc,
			    lastuserid ='WAREEST_STORED_PROC',
			    lastusername = @c_lastusername,
			    lastmaintdate =getdate(),
			    printqty = @ware_printqty,
			    coverqty = @ware_coverqty,
			    jacketqty = @ware_jacketqty, 
			    insertqty = @ware_insertqty, 
			    endpaperqty = @ware_endpapqty,
			    cartonqty = @ware_cartonqty
				where  estkey= @ware_estkey and estversion = @ware_estversion 


	end
	if @ware_sortorder = 5 
	  begin
		
		select @insert_count = 0

		select @insert_count = count(*) from whestfields5 where estkey= @ware_estkey
		if @insert_count > 0
		  begin
			delete from whestfields5 where estkey= @ware_estkey
		  end
		insert into whestfields5 
			(estkey,estversion,bookkey,printingkey,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			pagecount,trimfamily,film,bluesind,mediatype,mediasubtype,colorcount,foilamt,
			covertype,firstprinting,plateavailind,filmavailind,retailprice,
			avgpricerecd,returnrate,remainderprice,discountpct,netcopiessold,remainderqty,
			editioncost,editionfgunit,editionnetunit,editionpct,plantcost,plantfgunit,
			plantnetunit,plantpct,prodcost,prodfgunit,prodnetunit,prodpct,royaltycost,
			royaltyfgunit,royaltynetunit,royaltypct,overhead,overheadfgunit,overheadnetunit,
			overheadpct,advertising,advertisingfgunit,advertisingnetunit,advertisingpct,
			totalcost,totalfgunit,totalnetunit,totalpct,revenue,revenuefgunit,revenuenetunit,
			profitloss,profitlossfgunit,profitlossnetunit,profitmargin,estspecs,versiondesc)
		(select estkey,estversion,bookkey,printingkey,requestdatetime,requestedbyname,
			requestid,requestcomment,requestbatchid,finishedgoodqty,finishedgoodvendor,
			pagecount,trimfamily,film,bluesind,mediatype,mediasubtype,colorcount,foilamt,
			covertype,firstprinting,plateavailind,filmavailind,retailprice,
			avgpricerecd,returnrate,remainderprice,discountpct,netcopiessold,remainderqty,
			editioncost,editionfgunit,editionnetunit,editionpct,plantcost,plantfgunit,
			plantnetunit,plantpct,prodcost,prodfgunit,prodnetunit,prodpct,royaltycost,
			royaltyfgunit,royaltynetunit,royaltypct,overhead,overheadfgunit,overheadnetunit,
			overheadpct,advertising,advertisingfgunit,advertisingnetunit,advertisingpct,
			totalcost,totalfgunit,totalnetunit,totalpct,revenue,revenuefgunit,revenuenetunit,
			profitloss,profitlossfgunit,profitlossnetunit,profitmargin,estspecs,versiondesc
				from whest w
					where w.estkey= @ware_estkey and w.estversion =  @ware_estversion 
						and w.bookkey = @ware_bookkey
						and w.printingkey=@ware_printingkey)
		
		update whestfields5
			set paperprice = @f_paperprice,
			    paperbasisweight = @c_basiswtdesc,
			    paperstocktype = @c_stocktype,
			    paperallocationmr = @i_allocationmr,
			    paperallocationper1000 = @i_allocationper1000,
			    paperallocation = @i_allocation,
			    royaltypercent1 = @f_royaltyper1,
			    royaltyquantity1 = @i_royaltyqty1,
  			    royaltypercent2 = @f_royaltyper2,
			    royaltyquantity2 = @i_royaltyqty2,
			    royaltypercent3 = @f_royaltyper3,
			    royaltyquantity3 = @i_royaltyqty3,
			    estimatestatusdesc = @c_statusdesc,
			    estimatestatusshortdesc = @c_statusshortdesc,
			    lastuserid ='WAREEST_STORED_PROC',
			    lastusername = @c_lastusername,
			    lastmaintdate =getdate(),
			    printqty = @ware_printqty,
			    coverqty = @ware_coverqty,
			    jacketqty = @ware_jacketqty, 
			    insertqty = @ware_insertqty, 
			    endpaperqty = @ware_endpapqty,
			    cartonqty = @ware_cartonqty
				where  estkey= @ware_estkey and estversion = @ware_estversion 
	end

commit Tran
return 0

RETURN 


GO
