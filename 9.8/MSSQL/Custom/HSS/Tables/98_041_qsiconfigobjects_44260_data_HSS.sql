
DELETE FROM qsiconfigdetail WHERE configobjectkey IN (
select configobjectkey from qsiconfigobjects where configobjectdesc = 'main relationship group'
and itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 and qsicode = 1))

UPDATE qsiconfigobjects SET defaultvisibleind = 0 
where configobjectdesc = 'main relationship group'
and itemtypecode = (SELECT datacode FROM gentables WHERE tableid = 550 and qsicode = 1)