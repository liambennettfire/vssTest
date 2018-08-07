/*Add Vendor Misc Fields to Bookmiscitems*/  --note: will need to update wherever qsicodes are stored for these new items

IF not exists (select misckey from bookmiscitems where miscname ='Vendor Division')
BEGIN
--insert new misc item 
declare @i_misckey int
declare @i_datacode int
declare @i_configobjectkey int,
@i_usageclasscode int,
@i_columnnumber int,
@i_itemposition int,
@i_updateind int,
@i_itemtypecode int

select @i_misckey = max(misckey)+1 from bookmiscitems
select @i_datacode = max(datacode)+1 from gentables where tableid=525 
select @i_configobjectkey = configobjectkey from qsiconfigobjects where configobjectid='VendorandShippingInformation'
select @i_usageclasscode = 0
select @i_itemtypecode = 2 -- contact
select @i_columnnumber = 1
select @i_itemposition =1
select @i_updateind = 1

insert into bookmiscitems (misckey,miscname,misctype,activeind,lastuserid,lastmaintdate,datacode,taqtotmmind,sendtoeloquenceind,defaultsendtoeloqvalue,titlecriteriaind,projectcriteriaind,contactcriteriaind,journalcriteriaind,misclabel,qsicode)
select @i_misckey,'Vendor Division',5,1,'bal',GETDATE(),@i_datacode,0,0,0,0,0,0,0,'Vendor Division',21

--insert dropdown values
insert into gentables (tableid,datacode,datadesc,deletestatus,tablemnemonic,lastuserid,lastmaintdate,lockbyqsiind,lockbyeloquenceind)
select 525,@i_datacode,'Vendor Division','N','MISCTABLES','bal', GETDATE(),0,0

insert into subgentables (tableid,datacode,datasubcode,datadesc,deletestatus,sortorder,tablemnemonic,datadescshort,numericdesc1,lastuserid,lastmaintdate,subgen1ind,subgen2ind,subgen3ind,subgen4ind,lockbyqsiind,lockbyeloquenceind)
select 525,@i_datacode,1,'Domestic','N',1,'MISCTABLES','Domestic',01,'bal',GETDATE(),0,0,0,0,0,0

insert into subgentables (tableid,datacode,datasubcode,datadesc,deletestatus,sortorder,tablemnemonic,datadescshort,numericdesc1,lastuserid,lastmaintdate,subgen1ind,subgen2ind,subgen3ind,subgen4ind,lockbyqsiind,lockbyeloquenceind)
select 525,@i_datacode,2,'Foreign','N',2,'MISCTABLES','Foreign',02,'bal',GETDATE(),0,0,0,0,0,0

--place on tab

IF NOT EXISTS (SELECT * FROM miscitemsection WHERE configobjectkey = @i_configobjectkey and  misckey = @i_misckey) 
  BEGIN

  select @i_columnnumber = 3	
  --select @i_itemposition = max(@i_itemposition)+1 from miscitemsection where configobjectkey = @i_configobjectkey and columnnumber=@i_columnnumber
  select @i_itemposition = 2
       
  INSERT into miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
  VALUES (@i_misckey,@i_configobjectkey,@i_usageclasscode,@i_itemtypecode,@i_columnnumber,@i_itemposition,@i_updateind,'QSIDBA',GETDATE())
     
  END

END
go

/*insert vendordivision*/
declare @i_misckey int
select @i_misckey = misckey from bookmiscitems where qsicode=21
IF NOT EXISTS (SELECT * FROM globalcontactmisc WHERE misckey = @i_misckey and  globalcontactkey in (select globalcontactkey from globalcontact where conversionkey is not null)) 
  BEGIN
	insert into globalcontactmisc (globalcontactkey,misckey,longvalue,floatvalue,textvalue,lastuserid,lastmaintdate,sendtoeloquenceind)
	select g.globalcontactkey,@i_misckey,v.vendordivision,null,null,'QSIDBA',GETDATE(),0
	from globalcontact g
	inner join vendor v on g.conversionkey=v.vendorkey
	and v.vendordivision is not null
  END		
go

