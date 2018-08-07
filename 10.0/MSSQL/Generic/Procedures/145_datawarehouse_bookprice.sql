if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[datawarehouse_bookprice]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[datawarehouse_bookprice]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE  proc dbo.datawarehouse_bookprice
@ware_bookkey int, @ware_logkey int, @ware_warehousekey int,
@ware_system_date datetime

AS

DECLARE @ware_count int

DECLARE @ware_estus  float
DECLARE @ware_actus float
DECLARE @ware_bestus float
DECLARE @ware_estuk  float
DECLARE @ware_actuk float
DECLARE @ware_bestuk float
DECLARE @ware_estcan  float
DECLARE @ware_actcan float
DECLARE @ware_bestcan float
DECLARE @ware_estfpt  float
DECLARE @ware_actfpt float
DECLARE @ware_bestfpt float
DECLARE @ware_netestus  float
DECLARE @ware_netactus float
DECLARE @ware_netbestus float
DECLARE @ware_netestcan  float
DECLARE @ware_netactcan float
DECLARE @ware_netbestcan float


DECLARE @i_pricetypecode int
DECLARE @i_currencytypecode int
DECLARE @f_budgetprice float
DECLARE @f_finalprice float
DECLARE @i_pricestatus int
DECLARE @ware_currencycode int
DECLARE @ware_pricecode int

Select @ware_netestus = 0
Select @ware_netactus = 0
Select @ware_netbestus = 0
Select @ware_netestcan  = 0
Select @ware_netactcan = 0
Select @ware_netbestcan = 0

DECLARE warehousebookprice INSENSITIVE CURSOR
FOR
	SELECT pricetypecode,currencytypecode,budgetprice,
		finalprice
		    FROM bookprice
		   	WHERE  bookkey = @ware_bookkey
				AND activeind = 1 /*10-25-04 added - only active prices*/ 

FOR READ ONLY

select @ware_count = 1
OPEN warehousebookprice
 
FETCH NEXT FROM warehousebookprice 
INTO @i_pricetypecode,@i_currencytypecode,@f_budgetprice,
@f_finalprice

select @i_pricestatus = @@FETCH_STATUS

while (@i_pricestatus <>-1 )
   begin

	IF (@i_pricestatus <>-2)
	  begin

		select @ware_count = 0
		select @ware_count = count(*) from filterpricetype
			where filterkey = 5 /*currency and price types*/

		if @ware_count > 0 
		  begin
			select @ware_pricecode= pricetypecode, @ware_currencycode = currencytypecode
				 from filterpricetype
					where filterkey = 5 /*currency and price types*/
		  end
		else
		   begin
BEGIN tran
			INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
          			errorseverity, errorfunction,lastuserid, lastmaintdate)
			 VALUES (convert(varchar,@ware_logkey)  ,convert(varchar,@ware_warehousekey),
				'No row on filterpricetype - for bookprice',
				('Warning/data error bookkey ' + convert(varchar,@ware_bookkey)),
				'Stored procedure datawarehouse_bookprice','WARE_STORED_PROC',@ware_system_date)
commit tran
		  end

	if @i_pricetypecode = @ware_pricecode and @i_currencytypecode = @ware_currencycode  /*list for holt price*/
	  begin   
		select @ware_estus = @f_budgetprice
		select @ware_actus = @f_finalprice
		if @ware_actus > 0 
		  begin
			select @ware_bestus = @ware_actus
		  end
		else
		  begin
			select @ware_bestus = @ware_estus
		  end
	  end

	if @i_pricetypecode = @ware_pricecode and @i_currencytypecode = 37    /*UK*/
	  begin
		select @ware_estuk = @f_budgetprice
		select @ware_actuk = @f_finalprice
		if @ware_actuk > 0 
		  begin
			select @ware_bestuk = @ware_actuk
		  end
		else
		  begin
			select @ware_bestuk = @ware_estuk
		  end
	  end

	if @i_pricetypecode = @ware_pricecode and @i_currencytypecode = 11    /*CAN*/
	  begin
		select @ware_estcan =@f_budgetprice
		select @ware_actcan = @f_finalprice
		if @ware_actcan > 0 
		  begin
			select @ware_bestcan = @ware_actcan
		  end
		else
		  begin
			select @ware_bestcan = @ware_estcan
		  end
	 end

	if @i_pricetypecode = 9 and @i_currencytypecode = 6    /*US NET PRICE*/
	  begin
		select @ware_netestus =@f_budgetprice
		select @ware_netactus = @f_finalprice
		if @ware_netactus > 0 
		  begin
			select @ware_netbestus = @ware_netactus
		  end
		else
		  begin
			select @ware_netbestus = @ware_netestus
		  end
	 end

	if @i_pricetypecode = 9 and @i_currencytypecode = 11    /*CAN NET PRICE*/
	  begin
		select @ware_netestcan =@f_budgetprice
		select @ware_netactcan = @f_finalprice
		if @ware_netactcan > 0 
		  begin
			select @ware_netbestcan = @ware_netactcan
		  end
		else
		  begin
			select @ware_netbestcan = @ware_netestcan
		  end
	 end

 end /*<>2*/

	FETCH NEXT FROM warehousebookprice 
	INTO @i_pricetypecode,@i_currencytypecode,@f_budgetprice,
	@f_finalprice

	select @i_pricestatus = @@FETCH_STATUS
end
BEGIN tran
UPDATE whtitleinfo
	set uspriceest = @ware_estus,
		uspriceact = @ware_actus,
		uspricebest = @ware_bestus,
		ukpriceest = @ware_estuk,
		ukpriceact = @ware_actuk,
		ukpricebest = @ware_bestuk,
		canadianpriceest = @ware_estcan,
		canadianpriceact = @ware_actcan,
		canadianpricebest = @ware_bestcan,
		fptpriceest = @ware_estfpt,
		fptpriceact = @ware_actfpt,
		fptpricebest = @ware_bestfpt,
		usnetpriceest = @ware_netestus,
		usnetpriceact = @ware_netactus,
		usnetpricebest = @ware_netbestus ,
		canadiannetpriceest = @ware_netestcan,
		canadiannetpriceact = @ware_netactcan,
		canadiannetpricebest = @ware_netbestcan
	where bookkey = @ware_bookkey
commit tran
/**

if SQL%ROWCOUNT > 0 then
	commit
else
	INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
		'Unable to update whtitleinfo table - for bookprice',
		('Warning/data error bookkey '||to_char(@ware_bookkey)),
		'Stored procedure datawarehouse_bookprice','WARE_STORED_PROC',@ware_system_date)
	commit
end if
**/

close warehousebookprice 
deallocate warehousebookprice 



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

