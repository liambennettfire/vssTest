UPDATE bookmiscitems
SET searchurl = '../../Search/ProjectSearch.aspx?ItemType=3&UsageClass=1&ProjStat=10&Tmplt=0&BasicCrit=1&TrigFind=1'
WHERE miscname = 'Idea Phase Acquisitions'
go

UPDATE bookmiscitems
SET searchurl = '../../Search/ProjectSearch.aspx?ItemType=3&UsageClass=1&ProjStat=9&Tmplt=0&BasicCrit=1&TrigFind=1'
WHERE miscname = 'Acquisitions Currently Active'
go

UPDATE bookmiscitems
SET searchurl = '../../Search/ContractSearch.aspx?ItemType=10&ProjStat=32&Tmplt=0&BasicCrit=1&TrigFind=1'
WHERE miscname = 'Contracts Pending'
go

UPDATE bookmiscitems
SET searchurl = '../../Search/Search.aspx?ItemType=1&PubDate=today&PubDateEND=today.adddays(30)&TmpltStr=N&BasicCrit=1&TrigFind=1'
WHERE miscname = 'Titles Publishing in next 30 days'
go

UPDATE bookmiscitems
SET searchurl = '../../Search/CSOutbox.aspx?EloCust=-2&MetadataAsset=3&BasicCrit=1&TrigFind=1'
WHERE miscname = 'Titles in Outbox'
go

UPDATE bookmiscitems
SET searchurl = '../../Search/ProjectSearch.aspx?ItemType=3&UsageClass=1&ProjStat=1&LastMaintDt=today.adddays(-30)&BasicCrit=1&TrigFind=1'
WHERE miscname = 'Acquisitions Approved in last 30 days'
go

UPDATE bookmiscitems
SET searchurl = '../../Search/ContractSearch.aspx?ItemType=10&ProjStat=33&Tmplt=0&LastMaintDt=today.adddays(-30)&BasicCrit=1&TrigFind=1'
WHERE miscname = 'Contracts Signed in last 30 days'
go

UPDATE bookmiscitems
SET searchurl = '../../Search/Search.aspx?ItemType=1&VerType=5&VerStat=8&CSApprvl=1&BasicCrit=1&TrigFind=1'
WHERE miscname = 'Cloud Approved Titles failing Verification'
go
