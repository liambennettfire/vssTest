/*Add Vendor Misc Fields to Bookmiscitems*/  --note: will need to update wherever qsicodes are stored for these new items

DECLARE
  @v_misckey INT,
  @v_datacode INT

BEGIN
   --inactive for Abrams   
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE miscname = 'Master PO Number') 
  BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate,qsicode)
    VALUES
      (@v_misckey, 'Master PO Number', 'Master PO Number', 3, 0, 'QSIDBA', getdate(),14)
  END 
  
 --inactive for Abrams 
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE miscname = 'Discount Days') 
  BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate,qsicode)
    VALUES
      (@v_misckey, 'Discount Days', 'Discount Days', 3, 0, 'QSIDBA', getdate(),15)
  END 
  --inactive for Abrams
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE miscname = 'Discount Amount') 
  BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, fieldformat, activeind, lastuserid, lastmaintdate,qsicode)
    VALUES
      (@v_misckey, 'Discount Amount', 'Discount Amount', 2,'###,###.##', 0, 'QSIDBA', getdate(),16)
  END 
   --inactive for Abrams
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE miscname = 'Discount Percent') 
  BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, fieldformat, activeind, lastuserid, lastmaintdate,qsicode)
    VALUES
      (@v_misckey, 'Discount Percent', 'Discount Percent', 2,'##.##', 0, 'QSIDBA', getdate(),17)
  END 
   --inactive for Abrams
  IF NOT EXISTS (SELECT * FROM bookmiscitems WHERE miscname = 'SAN') 
  BEGIN
    SELECT @v_misckey = COALESCE(MAX(misckey),0) + 1 FROM bookmiscitems
    INSERT INTO bookmiscitems
      (misckey, miscname, misclabel, misctype, activeind, lastuserid, lastmaintdate,qsicode)
    VALUES
      (@v_misckey, 'SAN', 'SAN', 3,1, 'QSIDBA', getdate(),18)
  END 
  
END
go

--updates to existing
-- change Net Days label to Payment Terms and change type to text
update bookmiscitems 
set miscname='Payment Terms', misclabel ='Payment Terms',misctype=3
where qsicode = 12
go
--deactivate fob for abrams
update bookmiscitems
set activeind=0 where qsicode=11
go

/*Now configure the globalcontactmisc tab - for now don't care about usage class*/
declare 
@i_configobjectkey int,
@i_itemtypecode int,
@i_usageclasscode int,
@i_columnnumber int,
@i_itemposition int,
@i_updateind int,
@i_vendorid int,
@i_fob int,
@i_paymentterms int,
@i_masterpo int,
@i_discoutndays int,
@i_discountamount int,
@i_discountpercent int,
@i_san int

select @i_configobjectkey = (select configobjectkey from qsiconfigobjects where configobjectid='VendorandShippingInformation')  
select @i_usageclasscode = 0
select @i_itemtypecode = 2 -- contact
select @i_columnnumber = 1
select @i_itemposition =1
select @i_updateind = 1
select @i_paymentterms = misckey from bookmiscitems where qsicode= 12
select @i_vendorid = misckey from bookmiscitems where qsicode= 13
select @i_fob = misckey from bookmiscitems where qsicode= 11
select @i_masterpo  = misckey from bookmiscitems where qsicode= 14
select @i_discoutndays = misckey from bookmiscitems where qsicode= 15
select @i_discountamount = misckey from bookmiscitems where qsicode= 16
select @i_discountpercent = misckey from bookmiscitems where qsicode= 17
select @i_san = misckey from bookmiscitems where qsicode= 18


--vendorid already added by kusum's scripts, move to column 1, position 1
update miscitemsection
set columnnumber=1, itemposition=1
where configobjectkey = @i_configobjectkey
and misckey = @i_vendorid

--update payment terms back in the 1st column 
update miscitemsection
set columnnumber=1, itemposition=2
where configobjectkey = @i_configobjectkey
and misckey = @i_paymentterms 

--update FOB back in the 1st column 
update miscitemsection
set columnnumber=1, itemposition=3
where configobjectkey = @i_configobjectkey
and misckey = @i_fob 

--put SAN in the second column
IF NOT EXISTS (SELECT * FROM miscitemsection WHERE configobjectkey = @i_configobjectkey and  misckey = @i_san) 
  BEGIN

  select @i_columnnumber = 2	
  --select @i_itemposition = max(@i_itemposition)+1 from miscitemsection where configobjectkey = @i_configobjectkey and columnnumber=@i_columnnumber
  select @i_itemposition = 1
       
  INSERT into miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
  VALUES (@i_san,@i_configobjectkey,@i_usageclasscode,@i_itemtypecode,@i_columnnumber,@i_itemposition,@i_updateind,'QSIDBA',GETDATE())
     
  END 
  
--put masterpo in the thired column
IF NOT EXISTS (SELECT * FROM miscitemsection WHERE configobjectkey = @i_configobjectkey and  misckey = @i_masterpo) 
  BEGIN

  select @i_columnnumber = 3	
  --select @i_itemposition = max(@i_itemposition)+1 from miscitemsection where configobjectkey = @i_configobjectkey and columnnumber=@i_columnnumber
  select @i_itemposition = 1
       
  INSERT into miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
  VALUES (@i_masterpo,@i_configobjectkey,@i_usageclasscode,@i_itemtypecode,@i_columnnumber,@i_itemposition,@i_updateind,'QSIDBA',GETDATE())
     
  END   

-- the discount terms in the second column
IF NOT EXISTS (SELECT * FROM miscitemsection WHERE configobjectkey = @i_configobjectkey and  misckey = @i_discoutndays) 
  BEGIN

  select @i_columnnumber = 2	
  --select @i_itemposition = max(@i_itemposition)+1 from miscitemsection where configobjectkey = @i_configobjectkey and columnnumber=@i_columnnumber
  select @i_itemposition = 2
       
  INSERT into miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
  VALUES (@i_discoutndays,@i_configobjectkey,@i_usageclasscode,@i_itemtypecode,@i_columnnumber,@i_itemposition,@i_updateind,'QSIDBA',GETDATE())
     
  END  
  
IF NOT EXISTS (SELECT * FROM miscitemsection WHERE configobjectkey = @i_configobjectkey and  misckey = @i_discountamount) 
  BEGIN

  select @i_columnnumber = 2	
  --select @i_itemposition = max(@i_itemposition)+1 from miscitemsection where configobjectkey = @i_configobjectkey and columnnumber=@i_columnnumber
  select @i_itemposition = 3
       
  INSERT into miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
  VALUES (@i_discountamount,@i_configobjectkey,@i_usageclasscode,@i_itemtypecode,@i_columnnumber,@i_itemposition,@i_updateind,'QSIDBA',GETDATE())
     
  END  
 
IF NOT EXISTS (SELECT * FROM miscitemsection WHERE configobjectkey = @i_configobjectkey and  misckey = @i_discountpercent) 
  BEGIN

  select @i_columnnumber = 2	
  --select @i_itemposition = max(@i_itemposition)+1 from miscitemsection where configobjectkey = @i_configobjectkey and columnnumber=@i_columnnumber
  select @i_itemposition = 4
       
  INSERT into miscitemsection (misckey,configobjectkey,usageclasscode,itemtypecode,columnnumber,itemposition,updateind,lastuserid,lastmaintdate)
  VALUES (@i_discountpercent,@i_configobjectkey,@i_usageclasscode,@i_itemtypecode,@i_columnnumber,@i_itemposition,@i_updateind,'QSIDBA',GETDATE())
     
  END  
  
GO

    



















