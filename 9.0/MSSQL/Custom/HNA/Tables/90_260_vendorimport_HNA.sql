/*check for any vendors that aren't yet on globalcontact*/
--select * from vendor where vendorkey not in (Select conversionkey from globalcontact)
--note, there will be some on live, probably easiest to just re-enter them

/*update groupname from lastname, remove lastname*/
update globalcontact
set groupname=lastname 
where coalesce(conversionkey,0) <>0
and groupname is null
go
update globalcontact
set lastname=null
where groupname is not null
and coalesce(conversionkey,0) <>0
go

/*insert a group type*/ 
insert into gentables (tableid,datacode,datadesc,deletestatus,sortorder,tablemnemonic,datadescshort,lastuserid,lastmaintdate,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind)
select 520,4,'Vendor','N',2,'ContactGroup','Vendor','qsidba',GETDATE(),0,0,0,0
go


/*update group type*/
update globalcontact
set individualind=0, grouptypecode =4
where groupname is not null
and coalesce(conversionkey,0) <>0
go


/*clear out existing vendor roles*/
--first remove the vendor role from existing globalcontact, ensure that we leave any that are being used as part of contracts
delete from globalcontactrole where rolecode=33
and globalcontactkey not in (select globalcontactkey from taqprojectcontact)
go
delete from globalcontactrole where globalcontactkey in (select globalcontactkey from globalcontact where conversionkey is not null)
and globalcontactkey not in (select globalcontactkey from taqprojectcontact)
go


/*set correct roles based on vendor types and whether ship to locations*/
--mapping key:
--vendor.papervendind = maps to nothing
--vendor.foreignvendind = qsicode 19
--vendor.agentvendind = qsicode 20
--vendor.bookvendorind = qsicode 15
--vendor.merchvendind = qsicode 15
--vendor.audvidvendind = qsicode 15
--vendor.publisherind = maps to nothing
--vendor.printerind = qsicode 15

DECLARE 
@i_foreignvendind int,
@i_agentvendind int,
@i_bookvendorind int,
@i_audvidvendind int,
@i_merchvendind int,
@i_printerind int,
@i_shiplocation int,
@i_shiplocationrare int,
@i_foreignvendindcount int,
@i_agentvendindcount int,
@i_bookvendorindcount int,
@i_shiplocationcount int,
@i_shiplocationrarecount int

--get the rolecode based on the qsicode for each

select @i_foreignvendind  = datacode from gentables where tableid=285 and qsicode=19
select @i_agentvendind = datacode from gentables where tableid=285 and qsicode=20
select @i_bookvendorind = datacode from gentables where tableid=285 and qsicode=15
select @i_audvidvendind = datacode from gentables where tableid=285 and qsicode=15
select @i_merchvendind = datacode from gentables where tableid=285 and qsicode=15
select @i_printerind = datacode from gentables where tableid=285 and qsicode=15
select @i_shiplocation = datacode from gentables where tableid=285 and qsicode=17
select @i_shiplocationrare = datacode from gentables where tableid=285 and qsicode=18


--insert into globalcontactrole from vendor for each

--foreign
INSERT INTO [dbo].[globalcontactrole]
           ([globalcontactkey]
           ,[rolecode]
           ,[keyind]
           ,[lastuserid]
           ,[lastmaintdate]
           ,[sortorder]
           ,[ratetypecode]
           ,[workrate])

SELECT     globalcontactkey
           ,@i_foreignvendind 
           ,1 
           ,'vendor_conv' 
           ,GETDATE() 
           ,1  
           ,null
           ,null
FROM globalcontact g
inner join vendor v on g.conversionkey=v.vendorkey and v.foreignvendind = 'Y'
and g.globalcontactkey not in (select globalcontactkey from globalcontactrole where rolecode= @i_foreignvendind)

--forwarding agent
INSERT INTO [dbo].[globalcontactrole]
           ([globalcontactkey]
           ,[rolecode]
           ,[keyind]
           ,[lastuserid]
           ,[lastmaintdate]
           ,[sortorder]
           ,[ratetypecode]
           ,[workrate])

SELECT     globalcontactkey
           ,@i_agentvendind 
           ,1 
           ,'vendor_conv' 
           ,GETDATE() 
           ,2  
           ,null
           ,null
FROM globalcontact g
inner join vendor v on g.conversionkey=v.vendorkey and v.agentvendind = 'Y'           
and g.globalcontactkey not in (select globalcontactkey from globalcontactrole where rolecode= @i_agentvendind) 


--Vendor
INSERT INTO [dbo].[globalcontactrole]
           ([globalcontactkey]
           ,[rolecode]
           ,[keyind]
           ,[lastuserid]
           ,[lastmaintdate]
           ,[sortorder]
           ,[ratetypecode]
           ,[workrate])

SELECT     globalcontactkey
           ,@i_bookvendorind 
           ,1 
           ,'vendor_conv' 
           ,GETDATE() 
           ,1  
           ,null
           ,null
FROM globalcontact g
inner join vendor v on g.conversionkey=v.vendorkey
where (v.bookvendind ='Y' or v.audvidvendind ='Y' or v.merchvendind ='Y' or v.printerind='Y')
and g.globalcontactkey not in (select globalcontactkey from globalcontactrole where rolecode= @i_bookvendorind) 


--ship location: for any vendor appearing in the gposhiptovendor.shiptovendorkey column >5 times
INSERT INTO [dbo].[globalcontactrole]
           ([globalcontactkey]
           ,[rolecode]
           ,[keyind]
           ,[lastuserid]
           ,[lastmaintdate]
           ,[sortorder]
           ,[ratetypecode]
           ,[workrate])

SELECT     globalcontactkey
           ,@i_shiplocation 
           ,1 
           ,'vendor_conv'
           ,GETDATE() 
           ,1  
           ,null
           ,null
FROM globalcontact g
where g.conversionkey in (select shiptovendorkey from gposhiptovendor 
group by shiptovendorkey
having count(*)>10)
and g.globalcontactkey not in (select globalcontactkey from globalcontactrole where rolecode= @i_shiplocation) 


--ship location (rarely used): for any vendor appearing in the gposhiptovendor.shiptovendorkey column <=50 times
INSERT INTO [dbo].[globalcontactrole]
           ([globalcontactkey]
           ,[rolecode]
           ,[keyind]
           ,[lastuserid]
           ,[lastmaintdate]
           ,[sortorder]
           ,[ratetypecode]
           ,[workrate])

SELECT     globalcontactkey
           ,@i_shiplocationrare 
           ,1 
           ,'vendor_conv'
           ,GETDATE() 
           ,1  
           ,null
           ,null
FROM globalcontact g
where g.conversionkey in (select shiptovendorkey from gposhiptovendor 
group by shiptovendorkey
having count(*)<=10)
and g.globalcontactkey not in (select globalcontactkey from globalcontactrole where rolecode= @i_shiplocationrare or rolecode =@i_shiplocation) 


select @i_foreignvendindcount = count(*) from globalcontactrole r inner join globalcontact g on r.globalcontactkey = g.globalcontactkey and g.conversionkey is not null and r.rolecode = @i_foreignvendind and g.activeind=1
select @i_agentvendindcount = count(*) from globalcontactrole r inner join globalcontact g on r.globalcontactkey = g.globalcontactkey and g.conversionkey is not null and r.rolecode = @i_agentvendind and g.activeind=1
select @i_bookvendorindcount = count(*) from globalcontactrole r inner join globalcontact g on r.globalcontactkey = g.globalcontactkey and g.conversionkey is not null and r.rolecode = @i_bookvendorind and g.activeind=1
select @i_shiplocationcount = count(*) from globalcontactrole r inner join globalcontact g on r.globalcontactkey = g.globalcontactkey and g.conversionkey is not null and r.rolecode = @i_shiplocation and g.activeind=1
select @i_shiplocationrarecount = count(*) from globalcontactrole r inner join globalcontact g on r.globalcontactkey = g.globalcontactkey and g.conversionkey is not null and r.rolecode =  @i_shiplocationrare and g.activeind=1

print 'foreign =' + cast(@i_foreignvendindcount as varchar (10))
print 'agent =' + cast(@i_agentvendindcount as varchar (10))
print 'vendor =' + cast(@i_bookvendorindcount as varchar (10))
print 'ship location =' + cast(@i_shiplocationcount as varchar (10))
print 'ship locationrare =' + cast(@i_shiplocationrarecount as varchar (10))
GO

--foreign =180
--agent =32
--vendor =143
--ship location =89
--ship locationrare =123

/*TAXID to SSN*/
update globalcontact 
set ssn=v.taxid
from vendor v, globalcontact g
where v.vendorkey = g.conversionkey
and v.taxid is not null
go

/*insert SAN*/
declare @i_misckey int
select @i_misckey = misckey from bookmiscitems where qsicode=18
IF NOT EXISTS (SELECT * FROM globalcontactmisc WHERE misckey = @i_misckey and  globalcontactkey in (select globalcontactkey from globalcontact where conversionkey is not null)) 
  BEGIN
	insert into globalcontactmisc (globalcontactkey,misckey,longvalue,floatvalue,textvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
	select g.globalcontactkey,@i_misckey,null,null,v.san,'QSIDBA',GETDATE(),0
	from globalcontact g
	inner join vendor v on g.conversionkey=v.vendorkey
	and v.san is not null
  END		
go


/*insert vendorid*/
declare @i_misckey int
select @i_misckey = misckey from bookmiscitems where qsicode=13
IF NOT EXISTS (SELECT * FROM globalcontactmisc WHERE misckey = @i_misckey and  globalcontactkey in (select globalcontactkey from globalcontact where conversionkey is not null)) 
  BEGIN
	insert into globalcontactmisc (globalcontactkey,misckey,longvalue,floatvalue,textvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
	select g.globalcontactkey,@i_misckey,null,null,v.vendorid,'QSIDBA',GETDATE(),0
	from globalcontact g
	inner join vendor v on g.conversionkey=v.vendorkey
	and v.vendorid is not null
  END
GO



/*insert shipping instructions contact commenttype*/
IF NOT EXISTS (SELECT qsicode FROM gentables WHERE tableid=528 and qsicode=10)
BEGIN 
insert into gentables (tableid,datacode,datadesc,deletestatus,sortorder,tablemnemonic,datadescshort,lastuserid,lastmaintdate,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,qsicode)
select 528,10,'PO Shipping Instructions','N',10,'ContactNoteTypes','PO Ship Instr.','qsidba', GETDATE(), 0,0,1,0,'N/A',10
END
go

/*insert shipping instructions*/
declare @i_commentcode int,
@i_commentsubcode int

select @i_commentcode = datacode from gentables where tableid=528 and qsicode=10
select @i_commentsubcode = 0
IF NOT EXISTS (SELECT commentkey FROM qsicomments WHERE commentkey in (select globalcontactkey from globalcontact where conversionkey is not null) and commenttypecode=@i_commentcode and commenttypesubcode=@i_commentsubcode)
  BEGIN
	insert into qsicomments (commentkey,commenttypecode,commenttypesubcode,commenttext,commenthtml,commenthtmllite,lastuserid,lastmaintdate,invalidhtmlind,releasetoeloquenceind)
	select g.globalcontactkey,@i_commentcode,@i_commentsubcode,v.shippinginstructions,'<DIV>'+v.shippinginstructions+'</DIV>','<DIV>'+v.shippinginstructions+'</DIV>','QSIDBA',GETDATE(),0,0
	from globalcontact g
	inner join vendor v on g.conversionkey=v.vendorkey
	and coalesce(v.shippinginstructions,'') <>''
  END
GO



/*establish relationships from vendor to employees for attn field%'*/
--first just insert into globalcontact notes to make the creation easier
update globalcontact
set globalcontactnotes = v.attention 
from vendor v
inner join globalcontact g on v.vendorkey=g.conversionkey
where coalesce(v.attention,'') <>''
go
--now insert the globalcontact for the employee
--employee - tableid 519 qsicode 2
--ok this starts getting a little complicated, leaving it for now


--/*update vendor columns*/  -- because such a small number, will be just dealing with this manually in the app
----make sure not to update any of the remaining vendors when doing updates as they could be newer over in globalcontact
--updated on vendor since conversion
--select g.globalcontactkey from globalcontact g
--inner join vendor v on g.conversionkey=v.vendorkey
--where v.lastmaintdate > g.lastmaintdate
--
----updated on globalcontact since conversion 
--select g.globalcontactkey from globalcontact g
--inner join vendor v on g.conversionkey=v.vendorkey
--where g.lastmaintdate > '2013-08-22'



/*conversion
--fields
--master purchase order number = --not used
--name = globalcontact.groupname, searchname,displayname  makesure to sent individualind=0 and groutypecode=4
--address = globalcontactaddress.address1 also make sure to set addresstypecode = 'company mailing' =1 and set primaryind=1
--address2 = globalcontactaddress.address2
--city = globalcontactaddress.city
--state = globalcontactaddress.statecode
--zip = globalcontactaddress.zipcode
--country = globalcontactaddress.countrycode
--telephone = globalcontactmethod.contactmethodvalue, set contactmethodcode= 1, contactmethodsubcode=2 and primaryind=1  -phone work
--fax = globalcontactmethod.contactmethodvalue, set contactmethodcode= 2, contactmethodsubcode=1 and primaryind=1  - fax work
attention = turn this into a full contact themselves and then link to the vendor in contactrelationships
--vendor id = create a misc field  --kusum created a field
--short description =  globalcontact.shortname
--division = globalcontactorgentry
--fob = create a misc field --barely used, text entry  -- Kusum insert it, make it inactive for Abrams
--pay to vendor = globalcontactrelationship if used	--not used
--net days = misc field --kusum inserts it, change label to 'Payment Terms'
--discount days = misc field --not used
--discount amount = misc field  --not used
--discount percent = misc field --not used
--tax id = globalcontact.ssn --not really used
--san = misc field
--shipping instructions = comment


select * from globalcontact where ssn is not null order by lastmaintdate desc
select * from globalcontactaddress
select * from globalcontactmethod
select * from globalcontactmisc
select * from globalcontactrole
select * from vendor where masterponumber is not null
select fob,discountamount,discountdays,discountpercent,netdays,san from vendor where netdays is not null
select vendordivision,vendorkey,name,paytovendorkey,san,fob,discountamount,discountdays,discountpercent,netdays,san from vendor where vendordivision is not null 
select * from vendor where vendorkey in(39,
18)
select * from globalcontactmisc
select * from bookmiscitems where misckey=125
select * from bookmiscdefaults
select * from miscitemtab
select * from miscitemsection where misckey=125  --configobjectkey=10287112, usageclasscode=0,itemtypecode=2
select * from gentablesdesc where tabledesclong like '%item%'
select * from subgentables where tableid=550 -- contact = 2
--contract name misckey=125
*/



