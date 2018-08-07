ALTER TABLE globalcontact ADD conversionkey INT NULL
GO

update globalcontact
set conversionkey = externalcode1
where isnumeric(externalcode1)=1 
and globalcontactkey in (select globalcontactkey from globalcontactrole where rolecode=33)
GO