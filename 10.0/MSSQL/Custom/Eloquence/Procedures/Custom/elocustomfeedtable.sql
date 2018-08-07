
drop table elocustombookkeys
create table elocustombookkeys (bookkey int null)
grant all on elocustombookkeys to public
go

if exists (select * from sysobjects where id = object_id(N'dbo.elocustomfeed') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table dbo.elocustomfeed
GO

CREATE TABLE dbo.elocustomfeed (
	bookkey int NOT NULL,
	status varchar (6) NULL,
	isbn10 varchar (10) NULL ,	
	ean varchar (50) NULL,
	pubdateYYYYMMDD varchar (8) NULL,
	uslistprice decimal (10,2) NULL ,
	canadalistprice decimal (10,2) NULL ,

	
)
GO
grant all on elocustomfeed to public
go
