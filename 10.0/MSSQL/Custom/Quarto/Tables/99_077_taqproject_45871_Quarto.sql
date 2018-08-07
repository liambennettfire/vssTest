 ALTER TABLE taqproject DISABLE TRIGGER core_taqproject
 go
 ALTER TABLE taqproject DISABLE TRIGGER taqproject_history
 go

 update taqproject
 set autogeneratenameind = 1
 where searchitemcode = 14
 and usageclasscode = 1
 and coalesce(autogeneratenameind,0) = 0
 go

 ALTER TABLE taqproject ENABLE TRIGGER core_taqproject
 go
 ALTER TABLE taqproject ENABLE TRIGGER taqproject_history
 go

