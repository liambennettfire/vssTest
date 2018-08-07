update qsiconfigobjects
set sectioncontrolname = '~/PageControls/TitleSummary/Sections/ProductionSpecification.ascx'
where windowid in (select windowid from qsiwindows where lower(windowname) = 'titlesummary')
and lower(configobjectid) = 'shspecdetails'
go

delete from qsiconfigdetail
where configobjectkey in (select configobjectkey from qsiconfigobjects
                          where windowid in (select windowid from qsiwindows where lower(windowname) = 'titlesummary')
                          and lower(configobjectid) = 'shprodspecs')
go

delete from qsiconfigobjects
where windowid in (select windowid from qsiwindows where lower(windowname) = 'titlesummary')
and lower(configobjectid) = 'shprodspecs'  
go      

update gentablesitemtype
set sortorder = 0
where tableid = 636
and datacode = 4
and datasubcode = 10
and itemtypecode = 1
go