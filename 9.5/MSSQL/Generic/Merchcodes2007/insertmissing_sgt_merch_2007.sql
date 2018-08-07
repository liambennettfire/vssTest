declare

  @bisacdatacode  varchar(15),
  @datadesc  varchar(120),
  @gentabledatacode  int,
  @subgentabledatacode  int


  declare missingcodes cursor for 
    select code,literal
      from temp_sgt_merchcodes_2007
      where code not in 
        (select bisacdatacode from subgentables 
           where temp_sgt_merchcodes_2007.code=subgentables.bisacdatacode
             and tableid=558) 

  open missingcodes 

  fetch missingcodes into @bisacdatacode, @datadesc

  if @@fetch_status = -1
      goto exitloop

  while @@fetch_status = 0
    begin

       select @gentabledatacode  = max(datacode)
         from gentables
         where substring(bisacdatacode,1,2) = substring(@bisacdatacode,1,2) and tableid=558

       
       select @subgentabledatacode = max(datasubcode)+1
         from subgentables
         where datacode=@gentabledatacode and tableid=558

       if @subgentabledatacode is null
         set @subgentabledatacode = 1

       insert into subgentables
           (tableid,tablemnemonic,datacode,datasubcode,datadesc,bisacdatacode,deletestatus,
            acceptedbyeloquenceind,exporteloquenceind,lockbyqsiind,lockbyeloquenceind,eloquencefieldtag,
            lastmaintdate,lastuserid)
         values
           (558,'MerchandisingTheme',@gentabledatacode,@subgentabledatacode,@datadesc,@bisacdatacode,'N',
            1,1,0,0,@bisacdatacode,getdate(),'qsi-sql-V2007')

       fetch missingcodes into @bisacdatacode,@datadesc

       if @@fetch_status = -1
           goto exitloop 

     end

  exitloop:

  close missingcodes 
  deallocate missingcodes 
