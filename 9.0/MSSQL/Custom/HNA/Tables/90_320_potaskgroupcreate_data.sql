IF NOT EXISTS (select taskviewkey from taskview where taskviewdesc='Purchase Order Summary Dates - Component')
begin
declare @i_maxviewkey int,
@i_coverduecode int,
@i_jacketduecode int,
@i_miscduecode int

select @i_maxviewkey = max(taskviewkey)+1 from taskview
select @i_coverduecode = datetypecode from datetype where qsicode=25
select @i_jacketduecode = datetypecode from datetype where qsicode=26
select @i_miscduecode = datetypecode from datetype where qsicode=27

insert into taskview (taskviewkey,taskviewdesc,userkey,lastuserid,lastmaintdate,taskgroupind,detaildescription,taqprojecttypecode,templateind,itemtypecode,usageclasscode,orgentrykey,orglevelkey,alldatetypesind,keydatecheckedind)
select @i_maxviewkey,'Purchase Order Summary Dates - Component',-1,'FBTCONV',GETDATE(),1,'PO Specific Due Dates',14,0,15,1,1,1,0,0

insert into taskviewdatetype (taskviewkey,datetypecode,sortorder,lastuserid,lastmaintdate,scheduleind,rolecode,rolecode2,keyind)
select @i_maxviewkey,@i_coverduecode,1,'fbtconv',GETDATE(),0,0,0,1

insert into taskviewdatetype (taskviewkey,datetypecode,sortorder,lastuserid,lastmaintdate,scheduleind,rolecode,rolecode2,keyind)
select @i_maxviewkey,@i_jacketduecode,2,'fbtconv',GETDATE(),0,0,0,1

insert into taskviewdatetype (taskviewkey,datetypecode,sortorder,lastuserid,lastmaintdate,scheduleind,rolecode,rolecode2,keyind)
select @i_maxviewkey,@i_miscduecode,3,'fbtconv',GETDATE(),0,0,0,1
end
go

