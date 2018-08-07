UPDATE qsiconfigdetail
SET labeldesc = 'Content Services and eloquence Dashboard'
WHERE configobjectkey IN 
  (SELECT configobjectkey 
   FROM qsiconfigobjects 
   WHERE defaultlabeldesc = 'Content Services and eloquence At a Glance')
go

UPDATE qsiconfigdetail
SET labeldesc = 'Management Dashboard'
WHERE configobjectkey IN 
  (SELECT configobjectkey 
   FROM qsiconfigobjects 
   WHERE defaultlabeldesc = 'Management At a Glance')
go
