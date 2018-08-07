declare @i_maxplusone int
select @i_maxplusone = max(datacode)+1 from gentables where tableid=613

IF NOT EXISTS (select * from gentables where tableid=613 and datadesc='Pages Per Inch')
begin

insert into gentables (tableid,datacode,datadesc,deletestatus,sortorder,tablemnemonic,externalcode,datadescshort,lastuserid,lastmaintdate,gen1ind,acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind)
select 613,@i_maxplusone,'Pages Per Inch', 'N',@i_maxplusone,'BisacUnitofMeasure',null,'PPI','FBTCONV',GETDATE(),1,0,0,0,0

end

go
