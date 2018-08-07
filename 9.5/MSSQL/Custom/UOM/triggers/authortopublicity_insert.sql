/*Created 7-2-03 by AA
insert all author into contact and contactaddress table before
create trigger 
	sir 2071 RUN ON GENMSDEV /UOM
get the max(orgentrykey) first then insert max(orgentrykey) + 1 into all inserts below
	and the triggers authortopublicity_ins_trig 

	select max(orgentrykey) from orgentry */

INSERT INTO ORGENTRY (orgentrykey,orglevelkey,orgentrydesc,orgentryparentkey,orgentryshortdesc,
	deletestatus,lastuserid,lastmaintdate,createtitlesinpomsind,altdesc1,altdesc2)
values (34,2,'Author Business Unit',1,'Authors','N','qsiadmin',getdate(),NULL,NULL,NULL)

delete from contact where lastuserid='QSITRIG'
go

delete from contactaddress where lastuserid='QSITRIG'
go

 /*authors without address */		
insert into contact (contactkey,bucode,nameabbrcode,addresscode,firstname,lastname,
			 middleinit,title,phone1,phone1code,phone2,phone2code,
			phone3,phone3code,notes,activeind,emailaddress,
			lastuserid,lastmaintdate,lastnameserch,firstnameserch)
		select authorkey,34,nameabbrcode,1,firstname,lastname,substring(middlename,1,1) +'.',
			title,substring(phone1,1,30), 1,
			substring(phone2,1,30),1,substring(phone3,1,30),1,
			notes,activeind,emailaddress1,
			'QSITRIG',getdate(),upper(lastname),upper(firstname)
			from author
				where (defaultaddressnumber is null) or (defaultaddressnumber=0)
GO

insert into contactaddress (contactkey,bucode,addresscode,address1,address2,address3,
	city,statecode,countrycode,zip, lastuserid,lastmaintdate)
select authorkey,34,1,address1,address1line2,address1line3,city,statecode,countrycode,
	substring(zip,1,10),'QSITRIG',getdate()
		from author
		where (defaultaddressnumber is null) or (defaultaddressnumber=0)
GO

/*authors with default address 1*/
insert into contact (contactkey,bucode,nameabbrcode,addresscode,firstname,lastname,
			 middleinit,title,phone1,phone1code,phone2,phone2code,
			phone3,phone3code,notes,activeind,emailaddress,
			lastuserid,lastmaintdate,lastnameserch,firstnameserch)
		select authorkey,34,nameabbrcode,1,firstname,lastname,substring(middlename,1,1) +'.',
			title,substring(phone1,1,30), 1,
			substring(phone2,1,30),1,substring(phone3,1,30),1,
			notes,activeind,emailaddress1,
			'QSITRIG',getdate(),upper(lastname),upper(firstname)
			from author
				where defaultaddressnumber =1
GO

insert into contactaddress (contactkey,bucode,addresscode,address1,address2,address3,
	city,statecode,countrycode,zip,lastuserid,lastmaintdate)
select authorkey,34,addresstypecode1,address1,address1line2,address1line3,city,statecode,countrycode,
	substring(zip,1,10),'QSITRIG',getdate()
		from author
		where defaultaddressnumber =1 and addresstypecode1 is not null
GO

/*null addresstypecode1 = 1*/
insert into contactaddress (contactkey,bucode,addresscode,address1,address2,address3,
	city,statecode,countrycode,zip,lastuserid,lastmaintdate)
select authorkey,34,1,address1,address1line2,address1line3,city,statecode,countrycode,
	substring(zip,1,10),'QSITRIG',getdate()
		from author
		where defaultaddressnumber =1 and addresstypecode1 is null
GO
/*authors with default number = 2*/
insert into contact (contactkey,bucode,nameabbrcode,addresscode,firstname,lastname,
			 middleinit,title,phone1,phone1code,phone2,phone2code,
			phone3,phone3code,notes,activeind,emailaddress,
			lastuserid,lastmaintdate,lastnameserch,firstnameserch)
		select authorkey,34,nameabbrcode,1,firstname,lastname,substring(middlename,1,1) +'.',
			title,substring(phone1,1,30), 1,
			substring(phone2,1,30),1,substring(phone3,1,30),1,
			notes,activeind,emailaddress1,
			'QSITRIG',getdate(),upper(lastname),upper(firstname)
			from author
				where defaultaddressnumber =2 
GO

insert into contactaddress (contactkey,bucode,addresscode,address1,address2,address3,
	city,statecode,countrycode,zip, lastuserid,lastmaintdate)
select authorkey,34,addresstypecode2,address2line1,address2line2,address2line3,city2,statecode2,countrycode2,
	substring(zip2,1,10),'QSITRIG',getdate()
		from author
		where defaultaddressnumber =2 and addresstypecode2 is not null

GO

/*authors with default number = 2*/
insert into contactaddress (contactkey,bucode,addresscode,address1,address2,address3,
	city,statecode,countrycode,zip, lastuserid,lastmaintdate)
select authorkey,34,2,address2line1,address2line2,address2line3,city2,statecode2,countrycode2,
	substring(zip2,1,10),'QSITRIG',getdate()
		from author
		where defaultaddressnumber =2 and addresstypecode2 is null

GO

/*authors with default number = 3*/
insert into contact (contactkey,bucode,nameabbrcode,addresscode,firstname,lastname,
			 middleinit,title,phone1,phone1code,phone2,phone2code,
			phone3,phone3code,notes,activeind,emailaddress,
			lastuserid,lastmaintdate,lastnameserch,firstnameserch)
		select authorkey,34,nameabbrcode,1,firstname,lastname,substring(middlename,1,1) +'.',
			title,substring(phone1,1,30), 1,
			substring(phone2,1,30),1,substring(phone3,1,30),1,
			notes,activeind,emailaddress1,
			'QSITRIG',getdate(),upper(lastname),upper(firstname)
			from author
				where defaultaddressnumber =3
GO

insert into contactaddress (contactkey,bucode,addresscode,address1,address2,address3,
	city,statecode,countrycode,zip, lastuserid,lastmaintdate)
select authorkey,34,addresstypecode3,address3line1,address3line2,address3line3,city3,statecode3,countrycode3,
	substring(zip3,1,10),'QSITRIG',getdate()
		from author
		where defaultaddressnumber =3 and addresstypecode2 is not null

GO

insert into contactaddress (contactkey,bucode,addresscode,address1,address2,address3,
	city,statecode,countrycode,zip, lastuserid,lastmaintdate)
select authorkey,34,3,address3line1,address3line2,address3line3,city3,statecode3,countrycode3,
	substring(zip3,1,10),'QSITRIG',getdate()
		from author
		where defaultaddressnumber =3 and addresstypecode2 is null


GO

update contact
set phone1code = null
where phone1 is null and lastuserid='QSITRIG'
go

update contact
set phone2code = null
where phone2 is null and lastuserid='QSITRIG'
go


update contact
set phone3code = null
where phone3 is null and lastuserid='QSITRIG'
go

update contactaddress 
set zipcode =  convert(int,substring(zip,1,5)) 
where 
UPPER(zip) not like ('%A%') AND
UPPER(zip) not like ('%B%') AND
UPPER(zip) not like ('%C%') AND 
UPPER(zip) not like ('%D%') AND
UPPER(zip) not like ('%E%') AND
UPPER(zip) not like ('%F%') AND
UPPER(zip) not like ('%G%') AND
UPPER(zip) not like ('%H%') AND
UPPER(zip) not like ('%I%') AND
UPPER(zip) not like ('%J%') AND
UPPER(zip) not like ('%K%') AND
UPPER(zip) not like ('%L%') AND
UPPER(zip) not like ('%M%') AND
UPPER(zip) not like ('%N%') AND
UPPER(zip) not like ('%O%') AND
UPPER(zip) not like ('%P%') AND
UPPER(zip) not like ('%Q%') AND
UPPER(zip) not like ('%R%') AND
UPPER(zip) not like ('%S%') AND
UPPER(zip) not like ('%T%') AND
UPPER(zip) not like ('%U%') AND
UPPER(zip) not like ('%V%') AND
UPPER(zip) not like ('%W%') AND
UPPER(zip) not like ('%X%') AND
UPPER(zip) not like ('%Y%') AND
UPPER(zip) not like ('%Z%') AND
UPPER(zip) not like ('%-%') AND
ZIP NOT LIKE '0%' 
AND LASTUSERID ='QSITRIG' 
AND convert(int,substring(zip,1,5))>0
go
