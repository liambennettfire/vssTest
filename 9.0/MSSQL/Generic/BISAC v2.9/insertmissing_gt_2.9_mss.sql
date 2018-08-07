declare

  @bisacdatacode  varchar(15),
  @datadesc  varchar(120),
  @gentabledatacode  int

  declare missingcodes cursor for 
    select code,Literal
      from temp_gt_bisaccodes_29
      where code not in 
        (select bisacdatacode from gentables 
           where temp_gt_bisaccodes_29.code=gentables.bisacdatacode
             and tableid=339) 

  open missingcodes 

  fetch missingcodes into @bisacdatacode, @datadesc

  if @@fetch_status = -1
      goto exitloop

  while @@fetch_status = 0
    begin

       select @gentabledatacode  = max(datacode)+1
         from gentables
         where tableid=339

       if @gentabledatacode is null
         set @gentabledatacode = 1

       insert into gentables
           (tableid,tablemnemonic,datacode,datadesc,bisacdatacode,deletestatus,
            acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,
            lastmaintdate,lastuserid)
         values
           (339,'BISAC SUBJECT',@gentabledatacode,@datadesc,@bisacdatacode,'N',1,1,0,0,@bisacdatacode,getdate(),'qsi-sql-V2.9')

       fetch missingcodes into @bisacdatacode,@datadesc

       if @@fetch_status = -1
           goto exitloop 

     end

  exitloop:

  close missingcodes 
  deallocate missingcodes 
