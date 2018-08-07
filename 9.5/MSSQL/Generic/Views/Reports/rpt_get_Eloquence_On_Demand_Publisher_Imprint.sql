 IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_Eloquence_On_Demand_Publisher_Imprint]'))
DROP VIEW [dbo].[rpt_get_Eloquence_On_Demand_Publisher_Imprint]
GO

CREATE VIEW rpt_get_Eloquence_On_Demand_Publisher_Imprint
 AS
 select b.bookkey,b.title,o1.orgentrydesc as 'eloquence publisher' , o2.orgentrydesc as 'eloquencce imprint' from customer c
join book b on b.elocustomerkey=c.customerkey

join bookorgentry bo1 on bo1.bookkey=b.bookkey and bo1.orglevelkey=c.elopublisherorglevelkey
join bookorgentry bo2 on bo2.bookkey=b.bookkey  and bo2.orglevelkey=c.eloimprintorglevelkey
join orgentry o2 on o2.orgentrykey=bo2.orgentrykey
join  orgentry o1 on o1.orgentrykey=bo1.orgentrykey

Go
Grant all on rpt_get_Eloquence_On_Demand_Publisher_Imprint to Public