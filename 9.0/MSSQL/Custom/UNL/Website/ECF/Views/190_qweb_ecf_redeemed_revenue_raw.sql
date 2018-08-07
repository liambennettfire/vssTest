if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_ecf_redeemed_revenue_raw') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].qweb_ecf_redeemed_revenue_raw
GO

CREATE view [dbo].[qweb_ecf_redeemed_revenue_raw]
as
select 
d.discountid,
o.price from discounthistory d, ordersku o
where d.orderskuid=o.orderskuid