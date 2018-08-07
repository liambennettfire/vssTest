/*
rename expired Project Status to 'Pending Reversion'
*/

update gentables 
set datadesc = 'Expired, Pending Reversion', datadescshort = 'Expired' 
where tableid = 522 and qsicode = 23
GO