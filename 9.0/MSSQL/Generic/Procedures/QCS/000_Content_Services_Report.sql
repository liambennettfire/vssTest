/****** Object:  StoredProcedure [dbo].[Content_Services_Report]    Script Date: 10/06/2011 14:48:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Content_Services_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Content_Services_Report]
go

CREATE procedure Content_Services_Report          
    (@i_reportinstancekey int)          
as          
Declare @bookkey int          
Declare @assetkey int          
Declare @partnercontactkey int          
Declare @Displayname varchar (30)          
Declare @StatusCode varchar (30)          
Declare @Status varchar (30)          
Declare @ElementTypeCode int          
Declare @Date datetime          
Declare @Displayname_Counter varchar (30)          
Select @Displayname_Counter=''          
Declare @bookkey_counter int          
Select @bookkey_counter=0          
Declare @MetaData_Count int          
Declare @ePub_Count int          
Declare @Kindle_Count int          
Declare @Web_Ready_PDF_Count int          
Declare @Print_Ready_PDF_Count int          
Declare @Cover_Art_High_Count int          
Declare @Cover_Art_Low_Count int          
Declare @Cover_Art_Thumb_Count int          
Declare @Other_Date datetime          
Declare @Other_Status varchar (50)          
          
Create Table #Test          
(bookkey int,          
assetkey int,          
partnercontactkey int,          
Displayname varchar (30),          
StatusCode int,          
[Status] varchar (30),          
elementtypecode int,          
MetaData varchar (30),          
epub varchar(30),          
MetaData_Date datetime,          
epub_Date datetime,          
MetaData_Status varchar (30),          
ePub_Status varchar (30),          
kindle_Status varchar (30),          
kindle_date datetime,          
Web_Ready_PDF_Status varchar (30),          
Web_Ready_PDF_date datetime,          
Print_Ready_PDF_Status varchar (30),          
Print_Ready_PDF_date datetime,          
Cover_Art_High_Status varchar (30),          
Cover_Art_High_date datetime,          
Cover_Art_Low_Status varchar (30),          
Cover_Art_Low_date datetime,          
Cover_Art_Thumb_Status varchar (30),          
Cover_Art_Thumb_date datetime,          
Title varchar (250),          
ISBN varchar (20),          
Format varchar (50),          
PubDate Datetime,          
BisacStatus varchar (25)          
)          
          
DECLARE curMain CURSOR for           
select cd.bookkey, cd.assetkey, cd.partnercontactkey, gc.displayname, cd.statuscode, gs.datadesc ,           
te.taqelementtypecode,   max(tpt.activedate)            
from taqprojectelement te            
join csdistribution cd            
on cd.assetkey = te.taqelementkey           
left outer join taqprojecttask tpt           
on te.taqelementkey = tpt.taqelementkey           
left outer join globalcontact gc           
on gc.globalcontactkey = cd.partnercontactkey           
left outer join gentables gs           
on gs.datacode = cd.statuscode           
and gs.tableid = 576           
left outer join gentables ga           
on ga.datacode = te.taqelementtypecode           
and ga.tableid = 287           
--and cd.bookkey in(Select key1 from qsrpt_instance_item where instancekey=@i_reportinstancekey)           
where  cd.bookkey in(Select key1 from qsrpt_instance_item where instancekey=@i_reportinstancekey)  and          
cd.lastmaintdate = (select max(lastmaintdate) from csdistribution cdx where cdx.assetkey = cd.assetkey and cdx.bookkey = cd.bookkey and cdx.partnercontactkey = cd.partnercontactkey)            
group by  cd.bookkey, cd.assetkey, cd.partnercontactkey, gc.displayname, cd.statuscode, gs.datadesc, te.taqelementtypecode, ga.datadesc           
order by cd.bookkey,Displayname          
          
FOR READ ONLY          
Open curMain          
fetch next from curmain into @bookkey,@assetkey ,@partnercontactkey ,@Displayname,@StatusCode ,@Status ,@ElementTypeCode ,@Date           
while @@FETCH_STATUS = 0          
begin          
          
If @Status='Requested'          
BEGIN          
 Select @Status='REQ'          
END          
          
If @Status='Completed'          
Begin          
 Select @Status='DONE'          
END          
          
 If @bookkey <> @bookkey_counter          
 BEGIN          
  Select @Displayname_counter=''          
 END          
           
 If @Displayname_Counter <> @Displayname          
 BEGIN          
           
 Insert Into #Test(bookkey,assetkey,partnercontactkey,Displayname,statuscode,[Status],elementtypecode,Title,ISBN,Format,PubDate,BisacStatus)          
 values (@bookkey,@assetkey ,@partnercontactkey ,@Displayname,@StatusCode ,@Status ,@ElementTypeCode,dbo.rpt_get_title(@bookkey,'F'),dbo.rpt_get_isbn(@bookkey,17),dbo.rpt_get_format(@bookkey,'D'),dbo.rpt_get_best_pub_date(@bookkey,1),dbo.rpt_get_bisac_status(@bookkey,'D'))          
 END          
           
--1          
 If @ElementTypeCode=20001          
 BEGIN          
  Update #Test Set MetaData_Status=@Status,MetaData_Date=@Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
 END          
--2          
 If @ElementTypeCode=20010          
 BEGIN          
  Update #Test Set epub_Status=@Status,epub_Date=@Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
 END          
--3          
 If @ElementTypeCode=20006          
 BEGIN          
  Update #Test Set kindle_Status=@Status,kindle_Date=@Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
 END          
--4          
 If @ElementTypeCode=20013          
 BEGIN          
  Update #Test Set Web_Ready_PDF_Status=@Status,Web_Ready_PDF_Date=@Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
 END          
--5          
 If @ElementTypeCode=20016          
 BEGIN          
  Update #Test Set Print_Ready_PDF_Status=@Status,Print_Ready_PDF_Date=@Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
 END          
--6          
 If @ElementTypeCode=20003          
 BEGIN          
  Update #Test Set Cover_Art_High_Status=@Status,Cover_Art_High_Date=@Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
 END          
          
--7          
 If @ElementTypeCode=20008          
 BEGIN          
            
  Update #Test Set Cover_Art_Low_Status=@Status,Cover_Art_Low_Date=@Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
 END          
--8          
 If @ElementTypeCode=20009          
 BEGIN          
  Update #Test Set Cover_Art_Thumb_Status=@Status,Cover_Art_Thumb_Date=@Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
 END          
          
--Check if the assettypecode exist for the particular partner          
--1          
Select @MetaData_Count=(Select count (*) from customerpartnerassets where partnercontactkey=@partnercontactkey and assettypecode=20001)          
          
If @MetaData_Count=0          
BEGIN          
Update #Test Set MetaData_Status='N/A'  where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
END          
          
--2          
Select @ePub_Count=(Select count (*) from customerpartnerassets where partnercontactkey=@partnercontactkey and assettypecode=20010)          
          
If @ePub_Count=0          
BEGIN          
Update #Test Set epub_Status='N/A'  where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
END          
          
--3          
Select @Kindle_Count=(Select count (*) from customerpartnerassets where partnercontactkey=@partnercontactkey and assettypecode=20006)          
          
If @Kindle_Count=0          
BEGIN          
Update #Test Set kindle_Status='N/A'  where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
END          
          
          
--4          
Select @Web_Ready_PDF_Count=(Select count (*) from customerpartnerassets where partnercontactkey=@partnercontactkey and assettypecode=20013)          
          
If @Web_Ready_PDF_Count=0          
BEGIN          
Update #Test Set Web_Ready_PDF_Status='N/A'  where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
END          
          
--5          
Select @Print_Ready_PDF_Count=(Select count (*) from customerpartnerassets where partnercontactkey=@partnercontactkey and assettypecode=20016)          
          
If @Print_Ready_PDF_Count=0          
BEGIN          
Update #Test Set Print_Ready_PDF_Status='N/A'  where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
END          
          
--6          
Select @Cover_Art_High_Count=(Select count (*) from customerpartnerassets where partnercontactkey=@partnercontactkey and assettypecode=20003)          
          
If @Cover_Art_High_Count=0          
BEGIN          
Update #Test Set Cover_Art_High_Status='N/A'  where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
END          
          
--7          
Select @Cover_Art_Low_Count=(Select count (*) from customerpartnerassets where partnercontactkey=@partnercontactkey and assettypecode=20008)          
          
If @Cover_Art_Low_Count=0          
BEGIN          
Update #Test Set Cover_Art_Low_Status='N/A'  where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
END          
          
--8          
Select @Cover_Art_Thumb_Count=(Select count (*) from customerpartnerassets where partnercontactkey=@partnercontactkey and assettypecode=20009)          
          
If @Cover_Art_Thumb_Count=0          
BEGIN          
Update #Test Set Cover_Art_Thumb_Status='N/A'  where bookkey=@bookkey and partnercontactkey=@partnercontactkey          
END          
          
    ---BHP Specific          
--Amazon Kindle          
If @Date is Null    
BEGIN       
          
If @PartnerContactkey=7018135          
BEGIN          
 Select @Other_Date=(Select bestdate from bookdates where bookkey=@bookkey and datetypecode=439 and actualind=1)          
 IF @Other_Date IS NOT NULL          
 BEGIN          
  Update #Test Set MetaData_Status='PRV SEND',MetaData_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and MetaData_Status is null          
  Update #Test Set Kindle_Status='PRV SEND',Kindle_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and Kindle_Status is null          
  Update #Test Set Cover_Art_High_Status='PRV SEND',Cover_Art_High_Date=@Other_Date  where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and Cover_Art_High_Status is null          
 END          
END          
--Apple          
If @PartnerContactkey=7018139           
BEGIN          
 Select @Other_Date=(Select bestdate from bookdates where bookkey=@bookkey and datetypecode=434 and actualind=1)          
 IF @Other_Date IS NOT NULL          
 BEGIN          
  Update #Test Set MetaData_Status='PRV SEND',MetaData_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and MetaData_Status --is null          
  Update #Test Set epub_Status='PRV SEND',epub_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and epub_Status --is null          
  Update #Test Set Cover_Art_High_Status='PRV SEND',Cover_Art_High_Date=@Other_Date  where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and Cover_Art_High_Status is null          
 END          
END          
          
--B&N          
If @PartnerContactkey=7018137          
BEGIN          
 Select @Other_Date=(Select bestdate from bookdates where bookkey=@bookkey and datetypecode=437 and actualind=1)          
 IF @Other_Date IS NOT NULL          
 BEGIN          
  Update #Test Set MetaData_Status='PRV SEND',MetaData_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and MetaData_Status is null          
  Update #Test Set epub_Status='PRV SEND',epub_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and epub_Status is null          
  Update #Test Set Cover_Art_High_Status='PRV SEND',Cover_Art_High_Date=@Other_Date  where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and Cover_Art_High_Status is null          
 END          
END          
--Blio          
If @PartnerContactkey=7018131          
BEGIN          
 Select @Other_Date=(Select bestdate from bookdates where bookkey=@bookkey and datetypecode=448 and actualind=1)          
 IF @Other_Date IS NOT NULL          
 BEGIN          
  Update #Test Set MetaData_Status='PRV SEND',MetaData_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and MetaData_Status is null          
  Update #Test Set epub_Status='PRV SEND',epub_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and epub_Status is null          
  Update #Test Set Cover_Art_High_Status='PRV SEND',Cover_Art_High_Date=@Other_Date  where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and Cover_Art_High_Status is null          
 END          
END          
--CBD          
If @PartnerContactkey=7018136          
BEGIN          
 Select @Other_Date=(Select bestdate from bookdates where bookkey=@bookkey and datetypecode=438 and actualind=1)          
 IF @Other_Date IS NOT NULL          
 BEGIN          
  Update #Test Set MetaData_Status='PRV SEND',MetaData_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and MetaData_Status is null          
  Update #Test Set epub_Status='PRV SEND',epub_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and epub_Status is null          
  Update #Test Set Cover_Art_High_Status='PRV SEND',Cover_Art_High_Date=@Other_Date  where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and Cover_Art_High_Status is null          
 END          
END          
--eBooks          
If @PartnerContactkey=7018134          
BEGIN          
 Select @Other_Date=(Select bestdate from bookdates where bookkey=@bookkey and datetypecode=446 and actualind=1)          
 IF @Other_Date IS NOT NULL          
 BEGIN          
  Update #Test Set MetaData_Status='PRV SEND',MetaData_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and MetaData_Status is null          
  Update #Test Set epub_Status='PRV SEND',epub_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and epub_Status is null          
  Update #Test Set Cover_Art_High_Status='PRV SEND',Cover_Art_High_Date=@Other_Date  where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and Cover_Art_High_Status is null          
 END          
END          
          
--Kobo          
If @PartnerContactkey=7018133          
BEGIN          
 Select @Other_Date=(Select bestdate from bookdates where bookkey=@bookkey and datetypecode=435 and actualind=1)          
 IF @Other_Date IS NOT NULL          
 BEGIN          
  Update #Test Set MetaData_Status='PRV SEND',MetaData_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and MetaData_Status is null          
  Update #Test Set epub_Status='PRV SEND',epub_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and epub_Status is null          
  Update #Test Set Cover_Art_High_Status='PRV SEND',Cover_Art_High_Date=@Other_Date  where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and Cover_Art_High_Status is null          
 END          
END          
          
--Overdrive          
If @PartnerContactkey=7018138          
BEGIN          
 Select @Other_Date=(Select bestdate from bookdates where bookkey=@bookkey and datetypecode=445 and actualind=1)          
 IF @Other_Date IS NOT NULL          
 BEGIN          
  Update #Test Set MetaData_Status='PRV SEND',MetaData_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and MetaData_Status is null          
  Update #Test Set epub_Status='PRV SEND',epub_Date=@Other_Date where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and epub_Status is null          
  Update #Test Set Cover_Art_High_Status='PRV SEND',Cover_Art_High_Date=@Other_Date  where bookkey=@bookkey and partnercontactkey=@partnercontactkey --and Cover_Art_High_Status is null          
 END          
END          
END          
           
 Select @Displayname_Counter=@Displayname          
 Select @bookkey_counter=@bookkey          
           
          
 fetch next from curmain into @bookkey,@assetkey ,@partnercontactkey ,@Displayname,@StatusCode ,@Status ,@ElementTypeCode ,@Date           
end           
close curmain          
deallocate curmain          
          
Update #Test set MetaData_Status='Not Sent' where MetaData_Status is null          
Update #Test set epub_Status='Not Sent' where epub_Status is null          
Update #Test set kindle_Status='Not Sent' where kindle_Status is null          
Update #Test set Web_Ready_PDF_Status='Not Sent' where Web_Ready_PDF_Status is null          
Update #Test set Print_Ready_PDF_Status='Not Sent' where Print_Ready_PDF_Status is null          
Update #Test set Cover_Art_High_Status='Not Sent' where Cover_Art_High_Status is null          
Update #Test set Cover_Art_Low_Status='Not Sent' where Cover_Art_Low_Status is null          
Update #Test set Cover_Art_Thumb_Status='Not Sent' where Cover_Art_Thumb_Status is null          
          
Select  * from #Test order by bookkey,Displayname          
          
Drop Table #Test          
          
GRANT ALL ON Content_Services_Report TO Public 