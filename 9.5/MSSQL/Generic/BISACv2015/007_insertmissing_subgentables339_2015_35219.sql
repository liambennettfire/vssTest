declare

  @bisacdatacode  varchar(15),
  @datadesc  varchar(120),
  @gentabledatacode  int,
  @subgentabledatacode  int


  declare missingcodes cursor for 
    select ltrim(rtrim(code)),ltrim(rtrim(literal))
      from temp_sgt_bisaccodes_2015
      where code not in 
        (select bisacdatacode from subgentables 
           where temp_sgt_bisaccodes_2015.code=subgentables.bisacdatacode
             and tableid=339) 

  open missingcodes 

  fetch missingcodes into @bisacdatacode, @datadesc

  if @@fetch_status = -1
      goto exitloop

  while @@fetch_status = 0 begin
  
       select @gentabledatacode  = max(datacode)
         from gentables
        where substring(bisacdatacode,1,3) = substring(@bisacdatacode,1,3) and tableid=339

       select @subgentabledatacode = max(datasubcode)+1
         from subgentables
        where datacode=@gentabledatacode and tableid=339

       if @subgentabledatacode is null
         set @subgentabledatacode = 1

       insert into subgentables
           (tableid,tablemnemonic,datacode,datasubcode,datadesc,bisacdatacode,deletestatus,
            acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,
            lastmaintdate,lastuserid)
         values
           (339,'BISAC SUBJECT',@gentabledatacode,@subgentabledatacode,@datadesc,@bisacdatacode,'N',
            1,1,1,0,@bisacdatacode,getdate(),'BISAC-sql-V2015')

       fetch missingcodes into @bisacdatacode,@datadesc

       if @@fetch_status = -1
           goto exitloop 

   end

  exitloop:

  close missingcodes 
  deallocate missingcodes 


