update gentables
  set datadesc = (COALESCE (
    (select Literal 
       from temp_gt_bisaccodes_27
       where temp_gt_bisaccodes_27.code=gentables.bisacdatacode),
    gentables.datadesc ) )
  where tableid=339
go

update subgentables
  set datadesc = (COALESCE (
    (select literal 
       from temp_sgt_bisaccodes_27
       where temp_sgt_bisaccodes_27.code=subgentables.bisacdatacode),
    subgentables.datadesc ) )
  where tableid=339
go
