update taqrelationshiptabconfig
set alloweditablefieldsind = 1, defaultsortorder = 'projecttypedesc asc'
where relationshiptabcode in (select datacode from gentables where tableid = 583 and datadesc = 'Publicity (Publ Campgn)')
GO