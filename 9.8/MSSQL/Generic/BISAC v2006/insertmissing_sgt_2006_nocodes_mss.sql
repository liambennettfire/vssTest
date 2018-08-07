declare

  @bisacdatacode  varchar(120),
  @datadesc  varchar(120),
  @gentabledatacode  int,
  @subgentabledatacode  int


  declare missingcodes cursor for 
    select code,literal
      from temp_sgt_bisaccodes_29_nocodes
       

  open missingcodes 

  fetch missingcodes into @bisacdatacode,@datadesc

  if @@fetch_status = -1
      goto exitloop

  while @@fetch_status = 0
    begin

       select @gentabledatacode  = max(datacode)
         from gentables
         where datadesc = @bisacdatacode and tableid=339

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
           (339,'BISAC SUBJECT',@gentabledatacode,@subgentabledatacode,@datadesc,NULL,'N',
            1,1,0,0,NULL,getdate(),'qsi-sql-V2006')

       fetch missingcodes into @bisacdatacode,@datadesc

       if @@fetch_status = -1
           goto exitloop 

     end

  exitloop:

  close missingcodes 
  deallocate missingcodes 
