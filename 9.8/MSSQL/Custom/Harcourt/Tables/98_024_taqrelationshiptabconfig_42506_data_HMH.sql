/*
Update default sort order for Campaing tab that appears on marketing plan
*/

update taqrelationshiptabconfig
set defaultsortorder = 'miscitem2sortvalue asc, otherprojectdisplayname asc'
where relationshiptabcode = 36
go