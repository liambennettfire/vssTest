if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_ecf_redeemed_rev_by_discount') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].qweb_ecf_redeemed_rev_by_discount
GO

CREATE view [dbo].[qweb_ecf_redeemed_rev_by_discount]
as
select 
discountid,
sum(price) "total_revenue" from qweb_ecf_redeemed_revenue_raw  
group by (discountid)