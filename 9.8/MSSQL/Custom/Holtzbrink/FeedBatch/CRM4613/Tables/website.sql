create table dbo.website
(
	websitekey integer not null,
	websitedesclong varchar(80) null,
	websitecatalogkey integer null,
	lastuserid varchar(30) null,
	lastmaintdate datetime null,
	usebisacforwebcategoryind numeric(3, 0) null,
	subjecttablename varchar(255) null,
	subjectmajorcolumnname varchar(255) null,
	subjectminorcolumnname varchar(255) null,
	subjectsortordercolumnname varchar(255) null,
	relationshipfromprojectisbn numeric(38, 0) null,
	maxpubdateoffsetdays numeric(38, 0) null,
	rowid uniqueidentifier not null default (newid())
)

go

create unique index website_p1 on dbo.website (websitekey)
go
grant all on website to public 
go

