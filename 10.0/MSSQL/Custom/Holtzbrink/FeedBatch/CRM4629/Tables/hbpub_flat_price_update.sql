create table dbo.hbpub_flat_price_update
(
	isbn varchar(10) not null,
	price numeric(7, 2) null,
	pricetypecode integer null,
	currencytypecode integer null
)
go

GRANT ALL on hbpub_flat_price_update to PUBLIC 
go


