/****************************************************************************************************************
**  Name: Table SQL for story TM-155 ( https://jira.netgalley.com/browse/TM-155 )
**  Desc: This SQL sets 'Section Icon name' on gentablesdesc.gentext2label for 
**        tableid's 440 and 583               
**
**    Auth: Jon Hess
**    Date: 12/6/2017
**   For the Related Title tab (tableid 440) and the Related Web Tabs (tableid 583) use gentables_ext.gentext2 to store the icon name. 
**   Set the gentablesdesc.gentext2label for both these tableids to "Section Icon name"..
**
*****************************************************************************************************************/

ALTER TABLE qsiconfigobjects ADD sectionimage varchar(100)

update gentablesdesc set gentext2label = 'Section Icon name' where tableid in ( 440,583 )

-- Sample SQL to setup and configure an icon for a given tab:
--update gentables_ext set gentext2 = 'fa-pie-chart' where tableid = 440 and datacode = 1
--update gentables_ext set gentext2 = 'fa-heart-o' where tableid = 440 and datacode = 2
--update gentables_ext set gentext2 = 'fa-paw' where tableid = 583 and datacode = 28