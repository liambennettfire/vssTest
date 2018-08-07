
update printing
set printingnum = cast(printingkey as varchar)
where coalesce(printingnum,'') = ''
and printingkey > 0
go
