if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rpt_title_history_view]') and OBJECTPROPERTY(id, N'IsView') = 1)
  drop view [dbo].[rpt_title_history_view]
GO

create VIEW [dbo].[rpt_title_history_view]
AS
SELECT     h.bookkey, h.printingkey, t.description as fieldname, t.description AS fielddescription, CAST(CONVERT(char(10), h.dateprior, 101) AS varchar) AS originalvalue, 
                      CAST(CONVERT(char(10), h.datechanged, 101) AS varchar) AS currentvalue, h.lastuserid, h.lastmaintdate, 'Date History' AS source, 
CASE h.datestagecode WHEN 2 THEN 'EST' WHEN 1 THEN 'ACT' ELSE NULL END AS datestage,
dbo.rpt_get_username (h.lastuserid,'C') as lastusername
FROM         dbo.datehistory AS h INNER JOIN
                      dbo.datetype AS t ON h.datetypecode = t.datetypecode
UNION
SELECT     h.bookkey, h.printingkey, c.columndescription as fieldname,h.fielddesc AS fielddescription, h.stringvalue AS originalvalue, h.currentstringvalue AS currentvalue, h.lastuserid, 
                      h.lastmaintdate, 'Field History' AS source, NULL AS datestage, 
dbo.rpt_get_username (h.lastuserid,'C') as lastusername
FROM         dbo.titlehistory AS h INNER JOIN
                      dbo.titlehistorycolumns AS c ON h.columnkey = c.columnkey 

go
grant select on [dbo].[rpt_title_history_view] to public
go