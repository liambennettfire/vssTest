/****************************************************************************************************************
**  Name: Table SQL for story TM-217 ( https://jira.netgalley.com/browse/TM-217 )
**  Desc: This SQL updates all Sort Order fields to say Order 
**                     
**
**    Auth: Olivia Asaro
**    Date: 1/10/2018
**
*****************************************************************************************************************/

update subgentables
set datadesc = 'Order'
where tableid = 636 and datadesc = 'Sort'
GO