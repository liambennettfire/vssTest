--BL: turn off most columns that are syncing from the specitems down to the old tables
update qsiconfigspecsync
set syncfromspecsind=0
where tablename not in ('printing','bindingspecs','bookdetail','booksimon')
and specitemtype not in ('VF')
go