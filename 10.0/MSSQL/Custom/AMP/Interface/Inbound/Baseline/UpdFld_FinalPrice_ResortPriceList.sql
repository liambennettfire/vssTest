
IF OBJECT_ID('dbo.UpdFld_FinalPrice_ResortPriceList') IS NOT NULL DROP PROCEDURE dbo.UpdFld_FinalPrice_ResortPriceList
GO

CREATE PROCEDURE dbo.UpdFld_FinalPrice_ResortPriceList   -- Re-order the TM pricelist after having inserted new price
@bookkey int,
@userid  varchar(30)
AS
BEGIN

select	pricekey,
		row_num = Row_Number() over(order by pricetypecode, currencytypecode, activeind desc, effectivedate desc)
into	#tmp
from	bookprice
where	bookkey = @bookkey

declare @dtstamp datetime
set		@dtstamp = getdate()

update	bookprice
set		bookprice.sortorder = #tmp.row_num,
		bookprice.lastuserid = @userid,
		bookprice.lastmaintdate = @dtstamp
from	bookprice
		inner join #tmp on #tmp.pricekey = bookprice.pricekey

drop table #tmp

END
GO
