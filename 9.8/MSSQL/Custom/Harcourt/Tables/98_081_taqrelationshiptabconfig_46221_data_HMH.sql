UPDATE taqrelationshiptabconfig
SET hideparticipantsind = 2
WHERE relationshiptabcode IN (select datacode from gentables where tableid = 583 and datadesc = 'Mktg Projects (Campaign)')
go

UPDATE taqrelationshiptabconfig
SET hideparticipantsind = 2
WHERE relationshiptabcode IN (select datacode from gentables where tableid = 583 and datadesc = 'Mktg Plan (Mktg Campaign)')
go

UPDATE taqrelationshiptabconfig
SET hideparticipantsind = 2
WHERE relationshiptabcode IN (select datacode from gentables where tableid = 583 and datadesc = 'Mktg Campaigns (Mktg Plan)')
go

UPDATE taqrelationshiptabconfig
SET hideparticipantsind = 2
WHERE relationshiptabcode IN (select datacode from gentables where tableid = 583 and datadesc = 'Mktg Campaigns (Mktg Projects)')
go

UPDATE taqrelationshiptabconfig
SET hideparticipantsind = 2
WHERE relationshiptabcode IN (select datacode from gentables where tableid = 583 and datadesc = 'Marketing (Titles)')
go

UPDATE taqrelationshiptabconfig
SET hideparticipantsind = 2
WHERE relationshiptabcode IN (select datacode from gentables where tableid = 583 and datadesc = 'Publicity (Publ Campgn)')
go

UPDATE taqrelationshiptabconfig
SET hideparticipantsind = 2
WHERE relationshiptabcode IN (select datacode from gentables where tableid = 583 and datadesc = 'Publicity Campaign')
go