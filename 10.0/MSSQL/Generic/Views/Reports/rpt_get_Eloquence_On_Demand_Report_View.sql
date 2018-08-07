IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_Eloquence_On_Demand_Report_View]'))
DROP VIEW [dbo].[rpt_get_Eloquence_On_Demand_Report_View]
GO

CREATE VIEW rpt_get_Eloquence_On_Demand_Report_View  
As  
select dbo.rpt_get_gentables_Desc(539,messagetypecode,'D') as Message_Level,dbo.rpt_get_gentables_Desc(675,messagecategorycode,'D')as Message_Category,bv.message,    
dbo.rpt_Get_Title(b.bookkey,'F') as Title,dbo.rpt_get_isbn(b.bookkey,17) as ean13,b.bookkey, c.bisacstatusdesc,c.formatname,    
c.bestpubdate, c.tmmheaderorg1desc,c.tmmheaderorg2desc,bv.verificationtypecode,messagekey,g.qsicode     
 from bookverificationmessage bv    
inner join bookdetail bd on bd.bookkey=bv.bookkey    
inner join book b on b.bookkey=bv.bookkey --and b.sendtoeloind=1    
inner join isbn i on i.bookkey=b.bookkey    
inner join coretitleinfo c on c.bookkey=b.bookkey    
inner join gentables g  
on g.datacode=bv.verificationtypecode  
and g.tableid=556  

Go
Grant all on rpt_get_Eloquence_On_Demand_Report_View to Public