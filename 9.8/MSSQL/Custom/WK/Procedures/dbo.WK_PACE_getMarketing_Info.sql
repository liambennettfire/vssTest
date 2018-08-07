if exists (select * from dbo.sysobjects where id = object_id(N'dbo.WK_PACE_getMarketing_Info') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.WK_PACE_getMarketing_Info
GO
CREATE PROCEDURE dbo.WK_PACE_getMarketing_Info
AS
/*

EXEC dbo.WK_PACE_getMarketing_Info
ITEMNUMBER	
TMM_MARKETINGINFOID	
AVAILABILITY_RESTRICTION_ID	  
CONTACT_INFO_ID            	  
ACQUISITION_EDITOR         	  
SELL_APART             	  
PUBLISH_TO_MARKETING   	  
PUBLISH_TO_CATALOG     	  
PUBLISH_TO_INDEX       	  
PUBLISH_TO_STORE       	  
ACQ_EDITOR_CODE        	  
PUBLISH_TO_ELOQUENCE      	  
AGENCY_PLAN               	  
BOOK_STORE                	  
DEMO                      	  
PREVIEW_AVAILABILITY      	  
GABPICKLIST               

SElect * FROM WK_ORA.WKDBA.MARKETING_INFO

*/
BEGIN  
Select
dbo.WK_get_itemnumber_withdashes(b.bookkey) as itemnumber,
b.bookkey as TMM_MARKETINGINFOID, 
[dbo].[rpt_get_gentables_field](131, b.territoriescode, 'E') as AVAILABILITY_RESTRICTION_ID,
(Select sg.externalcode FROM bookmisc bm join subgentables sg ON bm.longvalue = sg.datasubcode WHERE bm.bookkey = b.bookkey and bm.misckey = 41 and sg.tableid = 525 and sg.datacode = 6)
as CONTACT_INFO_ID,
[dbo].[rpt_get_bookcontact_name_by_role_min](b.bookkey, 18, 'C') as ACQUISITION_EDITOR,
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 22, 'long') = 'Yes' THEN 1
ELSE 0 END) as SELL_APART,
NULL as PUBLISH_TO_MARKETING,  	  
NULL as PUBLISH_TO_CATALOG,  	  
NULL as PUBLISH_TO_INDEX,
(CASE WHEN [dbo].[wk_isEligibleforLWW](b.bookkey) = 'Y' THEN 1
ELSE 0 END) as PUBLISH_TO_STORE,
NULL as ACQ_EDITOR_CODE,        	  
NULL as PUBLISH_TO_ELOQUENCE,     	  
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 45, 'long') = 'Yes' THEN 1
ELSE 0 END) as AGENCY_PLAN,               	  
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 24, 'long') = 'Yes' THEN 1
ELSE 0 END) as BOOK_STORE,                	  
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 20, 'long') = 'Yes' THEN 1
ELSE 0 END) as DEMO,                      	  
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 21, 'long') = 'Yes' THEN 1
ELSE 0 END) as PREVIEW_AVAILABILITY,      	  
(CASE WHEN [dbo].[rpt_get_misc_value](b.bookkey, 23, 'long') = 'Yes' THEN 1
ELSE 0 END) as GABPICKLIST    
FROM book b
WHERE dbo.WK_get_itemnumber_withdashes(b.bookkey) <> ''

END

