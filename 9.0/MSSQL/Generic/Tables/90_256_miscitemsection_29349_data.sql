declare 
@i_configobjectkey int,
@i_itemtypecode int,
@i_usageclasscode int,
@i_columnnumber int,
@i_itemposition int,
@i_updateind int,
@i_vendorid int,
@i_freightterms int,
@i_paymentterms int,
@i_importcountry int

select @i_configobjectkey = (select configobjectkey from qsiconfigobjects where configobjectdesc='Additional Vendor/Import Information')  
select @i_usageclasscode = 0
select @i_itemtypecode = 15 -- Purchase Orders
select @i_columnnumber = 1
select @i_itemposition =1
select @i_updateind = 1
select @i_paymentterms = misckey from bookmiscitems where qsicode= 12
select @i_freightterms = misckey from bookmiscitems where qsicode= 19
select @i_importcountry = misckey from bookmiscitems where qsicode= 20



--put Payment Terms in the first column
IF NOT EXISTS (SELECT * FROM miscitemsection WHERE configobjectkey = @i_configobjectkey and  misckey = @i_paymentterms) 
  BEGIN

  select @i_columnnumber = 1	
  select @i_itemposition = 1
       
  INSERT into miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
  VALUES (@i_paymentterms,@i_configobjectkey,@i_usageclasscode,@i_itemtypecode,@i_columnnumber,@i_itemposition,@i_updateind,'QSIDBA',GETDATE())
     
  END 
  
--put Freight Terms in the second column
IF NOT EXISTS (SELECT * FROM miscitemsection WHERE configobjectkey = @i_configobjectkey and  misckey = @i_freightterms) 
  BEGIN

  select @i_columnnumber = 2	
  select @i_itemposition = 1
       
  INSERT into miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
  VALUES (@i_freightterms,@i_configobjectkey,@i_usageclasscode,@i_itemtypecode,@i_columnnumber,@i_itemposition,@i_updateind,'QSIDBA',GETDATE())
     
  END   

-- put Import Country in the third column
IF NOT EXISTS (SELECT * FROM miscitemsection WHERE configobjectkey = @i_configobjectkey and  misckey = @i_importcountry) 
  BEGIN

  select @i_columnnumber = 3	
  select @i_itemposition = 1
       
  INSERT into miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
  VALUES (@i_importcountry,@i_configobjectkey,@i_usageclasscode,@i_itemtypecode,@i_columnnumber,@i_itemposition,@i_updateind,'QSIDBA',GETDATE())
     
  END  
  

  
GO