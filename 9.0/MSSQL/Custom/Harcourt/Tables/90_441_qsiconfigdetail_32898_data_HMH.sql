declare
  @v_new_qsiwindowviewkey int,
  @v_new_configdetailkey int,
  @v_usageclass int,
  @v_count int,
  @v_groupkey int,
  @v_default int


set @v_usageclass = 1

select @v_count = COUNT(*)
from qsiconfigobjects
where lower(configobjectdesc) = 'product detail' and defaultvisibleind = 0

if @v_count > 0 begin
	update qsiconfigobjects
	set defaultvisibleind = 1 
	where lower(configobjectdesc) = 'product detail' and defaultvisibleind = 0
end

select @v_count = COUNT(*)
from qsiconfigdetail
where configobjectkey in (select configobjectkey from qsiconfigobjects where lower(configobjectid) in ('shproductdetail'))
  
if @v_count = 0 begin

exec get_next_key 'qsidba', @v_new_configdetailkey output
set @v_default = 1

insert into qsiconfigdetail (configdetailkey, configobjectkey, usageclasscode, labeldesc, visibleind, minimizedind, lastuserid, lastmaintdate, 
							 position, qsiwindowviewkey, sectioncontrolname, viewcolumnnum)
select @v_new_configdetailkey,configobjectkey,@v_usageclass,defaultlabeldesc,@v_default,defaultminimizedind,'QSIADMIN',
		   getdate(),position,groupkey,sectioncontrolname,@v_new_qsiwindowviewkey
	 from qsiconfigobjects
	 where configobjectkey in (select configobjectkey from qsiconfigobjects
								where lower(configobjectid) = 'shProductDetail'
								  and windowid in (select windowid from qsiwindows
													where lower(windowname) = 'titlesummary'))
end

go