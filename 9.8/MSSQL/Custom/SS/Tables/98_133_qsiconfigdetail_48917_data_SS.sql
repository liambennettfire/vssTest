/*
Remove the old project relationships section from Express PO Summary
*/

update qsiconfigdetail
set visibleind = 0
where labeldesc like 'Purchase Order Relationships' and qsiwindowviewkey in (select qsiwindowviewkey from qsiwindowview where qsiwindowviewname like 'Express PO Summary Default View')
GO