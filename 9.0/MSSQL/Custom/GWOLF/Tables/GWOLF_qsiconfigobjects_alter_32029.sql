update qsiconfigobjects
set initialeditmode = 2 -- 1 is View and 2 is edit
where windowid = (select windowid from qsiwindows where windowname = 'Elements')
and configobjectid = 'shElements'
GO