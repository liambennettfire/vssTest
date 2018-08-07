create table dbo.feedouttitles
(
	isbn varchar(13) not null,
	title varchar(80) null,
	subtitle varchar(255) null,
	edition varchar(40) null,
	series varchar(255) null,
	authortype1 varchar(40) null,
	authorfirstname1 varchar(75) null,
	authorlastname1 varchar(75) null,
	authortype2 varchar(40) null,
	authorfirstname2 varchar(75) null,
	authorlastname2 varchar(75) null,
	authortype3 varchar(40) null,
	authorfirstname3 varchar(75) null,
	authorlastname3 varchar(75) null,
	editorfirstname1 varchar(12) null,
	editorlastname1 varchar(20) null,
	mktmgrlastname1 varchar(20) null,
	mktmgrfirstname1 varchar(12) null,
	format varchar(40) null,
	pubestdate datetime null,
	pubactdate datetime null,
	uspriceest numeric(10, 2) null,
	uspriceact numeric(10, 2) null,
	pagecount numeric(10, 0) null,
	trimsizeest varchar(25) null,
	trimsizeact varchar(25) null,
	insertillusest varchar(255) null,
	insertillusact varchar(255) null,
	tipkeysellingpt varchar(4000) null,
	catsubright varchar(4000) null,
	catauthorinfo varchar(4000) null,
	catquotes varchar(4000) null,
	catbodycopy varchar(4000) null,
	cattoc varchar(4000) null,
	catcontributor varchar(4000) null
)

go
alter table dbo.feedouttitles
   add constraint sys_c0024712
      primary key ( isbn )
go
GRANT ALL on feedouttitles to PUBLIC 
go