/******************************************************************************************
**  Sets the relationship tab help url
*******************************************************************************************/

BEGIN

  DECLARE
  @v_datacode   integer,
  @v_error_code		 integer,
  @v_error_desc		 varchar(2000) 



  SET @v_datacode = 0
  SET @v_error_code = 0
  SET @v_error_desc	= ' '

exec @v_datacode = qutl_get_gentables_datacode 440, 17,'Competitive Titles'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Competitive Titles' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360000915734-Tab-Competitive-Titles' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitleRelationshipsTabGroup1')) and relationshiptabcode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 440, 3,'Comparative Titles'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Comparative Titles' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360000915794-Tab-Comparative-Titles' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitleRelationshipsTabGroup1')) and relationshiptabcode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 440, 2,'Author Sales Track'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Author Sales Track' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360000903173-Tab-Author-Sales-Track' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitleRelationshipsTabGroup1')) and relationshiptabcode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 440, 1,'Supply Chain'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Supply Chain' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360000903533-Tab-Supply-Chain' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitleRelationshipsTabGroup1')) and relationshiptabcode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 440, 14,'Formats of Work'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Formats of Work' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360000862354-Tab-Formats-of-Work' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitleRelationshipsTabGroup1')) and relationshiptabcode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 440, 15,'Titles in Set'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Titles in Set' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360006795653' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitleRelationshipsTabGroup1')) and relationshiptabcode = @v_datacode
exec @v_datacode = qutl_get_gentables_datacode 440, 16,'Sets'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Sets' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360000915374-Tab-Sets' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitleRelationshipsTabGroup1')) and relationshiptabcode = @v_datacode


exec @v_datacode = qutl_get_gentables_datacode 583, 14,'Projects (Titles)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Projects (Titles)' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360006795033' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitlesTabgroup1')) and relationshiptabcode = @v_datacode	 	 
exec @v_datacode = qutl_get_gentables_datacode 583, 26,'Contracts (Titles)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Contracts (Titles)' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360006765474' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitlesTabgroup1')) and relationshiptabcode = @v_datacode 	 	 
exec @v_datacode = qutl_get_gentables_datacode 583, 31,'Printings (on Titles)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Printings (on Titles)' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360006794153' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitlesTabgroup1')) and relationshiptabcode = @v_datacode	 	 
exec @v_datacode = qutl_get_gentables_datacode 583, NULL,'Catalog Section (Titles)'	IF @v_datacode =  0  print 'There is no datacode found for datadesc = ' + 'Catalog Section (Titles)' 	UPDATE qsiconfigdetailtabs SET  helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360006795013' WHERE configdetailkey in (select configdetailkey from qsiconfigdetail where qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where defaultind = 1) AND configobjectkey in (select configobjectkey from qsiconfigobjects where configobjectid = 'TitlesTabgroup1')) and relationshiptabcode = @v_datacode

END
GO


/*
Marketing (titles) tab has no qsicode code and the datadesc is different on some db's
so this is a separate update statement using the project control ID
*/
update qsiconfigdetailtabs
set helpurl = 'https://firebrandtechsupport.zendesk.com/hc/en-us/articles/360006794633'
where relationshiptabcode in (select datacode from gentables where tableid = 583 and datadesc like 'Marketing%' 
and alternatedesc2 = '~/PageControls/ProjectRelationships/ProjectsTitle.ascx')
GO