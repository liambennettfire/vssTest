if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].qweb_ecf_redeemed') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].qweb_ecf_redeemed
GO

CREATE view [dbo].[qweb_ecf_redeemed]
as
select 
discountid,
count (discountid)"redeemed",
sum(amount) "total_discount" from discounthistory 
group by (discountid)
