if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[datawarehouse_bookprice_prtg]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[datawarehouse_bookprice_prtg]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE  proc dbo.datawarehouse_bookprice_prtg
@ware_bookkey int, @ware_printingkey int, @ware_logkey int, 
@ware_warehousekey int, @ware_system_date datetime

AS

DECLARE @ware_count int

DECLARE @ware_overrideus  float
DECLARE @ware_overrideuk  float
DECLARE @ware_overridecan  float
DECLARE @error_var    INT
DECLARE @rowcount_var INT

DECLARE @ware_pricecode int
DECLARE @ware_currencycode int

select @ware_count = 0

select @ware_count = count(*) 
  from filterpricetype
 where filterkey = 5 /*currency and price types*/

if @ware_count > 0 begin
  select @ware_pricecode = pricetypecode, @ware_currencycode = currencytypecode
    from filterpricetype
   where filterkey = 5 /*currency and price types*/
end
else begin
  BEGIN tran
  INSERT INTO wherrorlog (logkey, warehousekey,errordesc,
        		  errorseverity, errorfunction,lastuserid, lastmaintdate)
  VALUES (convert(varchar,@ware_logkey) ,convert(varchar,@ware_warehousekey),
	  'No row on filterpricetype - for bookprice',
	 ('Warning/data error bookkey ' + convert(varchar,@ware_bookkey)),
	  'Stored procedure datawarehouse_bookprice_prtg','WARE_STORED_PROC',@ware_system_date)
  commit tran
  return
end

/*us price*/    
SELECT @ware_count = count(*)
  FROM bookprice
 WHERE bookkey = @ware_bookkey
   AND pricetypecode = @ware_pricecode
   AND currencytypecode = 6
   AND activeind = 1 
   AND overrideprintingkey > 0 
   AND overrideprintingkey = @ware_printingkey

if @ware_count > 0 begin
  SELECT @ware_overrideus = overrideprice
    FROM bookprice
   WHERE bookkey = @ware_bookkey
     AND pricetypecode = @ware_pricecode
     AND currencytypecode = 6
     AND activeind = 1 
     AND overrideprintingkey > 0 
     AND overrideprintingkey = @ware_printingkey
end

/*uk price*/    
SELECT @ware_count = count(*)
  FROM bookprice
 WHERE bookkey = @ware_bookkey
   AND pricetypecode = @ware_pricecode
   AND currencytypecode = 37
   AND activeind = 1 
   AND overrideprintingkey > 0 
   AND overrideprintingkey = @ware_printingkey

if @ware_count > 0 begin
  SELECT @ware_overrideuk = overrideprice
    FROM bookprice
   WHERE bookkey = @ware_bookkey
     AND pricetypecode = @ware_pricecode
     AND currencytypecode = 37
     AND activeind = 1 
     AND overrideprintingkey > 0 
     AND overrideprintingkey = @ware_printingkey
end

/*canadian price*/    
SELECT @ware_count = count(*)
  FROM bookprice
 WHERE bookkey = @ware_bookkey
   AND pricetypecode = @ware_pricecode
   AND currencytypecode = 11
   AND activeind = 1 
   AND overrideprintingkey > 0 
   AND overrideprintingkey = @ware_printingkey

if @ware_count > 0 begin
  SELECT @ware_overridecan = overrideprice
    FROM bookprice
   WHERE bookkey = @ware_bookkey
     AND pricetypecode = @ware_pricecode
     AND currencytypecode = 11
     AND activeind = 1 
     AND overrideprintingkey > 0 
     AND overrideprintingkey = @ware_printingkey
end

if @ware_overrideus > 0 OR @ware_overrideuk > 0 OR @ware_overridecan > 0 begin
  BEGIN tran
  UPDATE whprinting
     set overrideusprice = @ware_overrideus,
         overrideukprice = @ware_overrideuk,
         overridecanadianprice = @ware_overridecan
   where bookkey = @ware_bookkey
     and printingkey = @ware_printingkey
  commit tran
end

/**

if SQL%ROWCOUNT > 0 then
	commit
else
	INSERT INTO qsidba.wherrorlog (logkey, warehousekey,errordesc,
          errorseverity, errorfunction,lastuserid, lastmaintdate)
	 VALUES (to_char(@ware_logkey)  ,to_char(@ware_warehousekey),
		'Unable to update whtitleinfo table - for bookprice',
		('Warning/data error bookkey '||to_char(@ware_bookkey)),
		'Stored procedure datawarehouse_bookprice_prtg','WARE_STORED_PROC',@ware_system_date)
	commit
end if
**/

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

