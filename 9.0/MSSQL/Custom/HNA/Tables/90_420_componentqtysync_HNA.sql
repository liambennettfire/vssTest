--sync update
update qsiconfigspecsync
set activeind=1, specitemcategory = 2, specitemcode=0, specitemtype='C' where qsiconfigspecsynckey=2
go

insert into qsiconfigspecsync (specitemcategory,specitemcode,itemtype,usageclass,syncfromspecsind,synctospecsind,specitemtype,datatype,tablename,columnname,keycolumn1,keycolumn2,activeind,lastuserid,lastmaintdate)
select specitemcategory,specitemcode,itemtype,usageclass,syncfromspecsind,synctospecsind,specitemtype,datatype,tablename,'firstprintingqty',keycolumn1,keycolumn2,activeind,lastuserid,GETDATE()
from qsiconfigspecsync where qsiconfigspecsynckey=2
go

update printing
set tentativeqty = t.quantity
from printing p 
inner join taqprojecttitle tt on p.bookkey=tt.bookkey and p.printingkey=tt.printingkey and tt.titlerolecode= 9 and tt.projectrolecode=5
inner join taqversionspeccategory t on t.taqprojectkey=tt.taqprojectkey and t.itemcategorycode=2 --5 bind
left outer join whtitleinfo w on p.bookkey=w.bookkey
where t.quantity is not null  and p.tentativeqty is null 
go

update printing
set firstprintingqty = t.quantity
from printing p 
inner join taqprojecttitle tt on p.bookkey=tt.bookkey and p.printingkey=tt.printingkey and tt.titlerolecode= 9 and tt.projectrolecode=5
inner join taqversionspeccategory t on t.taqprojectkey=tt.taqprojectkey and t.itemcategorycode=2 --5 bind
left outer join whtitleinfo w on p.bookkey=w.bookkey
where t.quantity is not null  and p.firstprintingqty is null 
go
