IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rpt_get_Marketing_Dump_Info_Modified]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[rpt_get_Marketing_Dump_Info_Modified]
GO
/****** Object:  StoredProcedure [dbo].[rpt_get_Marketing_Dump_Info_Modified]    Script Date: 08/09/2011 11:08:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec rpt_get_marketing_dump_info 810408    
--exec rpt_get_marketing_dump_info 809851    
--exec rpt_get_marketing_dump_info 807023    
--exec rpt_get_Marketing_Dump_Info_Modified 1184    
  
CREATE procedure [dbo].[rpt_get_Marketing_Dump_Info_Modified]  
    (@i_Reportinstancekey int)          
as          
  
       
Create Table #Contributor_Info            
(bookkey int,            
lastname1 varchar (500),    
Firstname1 varchar (500),    
MiddleName1 varchar (500),    
Suffix1 varchar (500),    
DisplayName1 varchar (500),    
Type1 varchar (500),    
MaintTitle1 varchar (500),    
MainDepartment1 varchar (500),    
MainOrganization1 varchar (500),  
Author_bio1 varchar (8000),    
lastname2 varchar (500),    
Firstname2 varchar (500),    
MiddleName2 varchar (500),    
Suffix2 varchar (500),    
DisplayName2 varchar (500),    
Type2 varchar (500),    
MaintTitle2 varchar (500),    
MainDepartment2 varchar (500),    
MainOrganization2 varchar (500),   
Author_bio2 varchar (8000),   
lastname3 varchar (500),    
Firstname3 varchar (500),    
MiddleName3 varchar (500),    
Suffix3 varchar (500),    
DisplayName3 varchar (500),    
Type3 varchar (500),    
MaintTitle3 varchar (500),    
MainDepartment3 varchar (500),    
MainOrganization3 varchar (500),  
Author_bio3 varchar (8000),    
lastname4 varchar (500),    
Firstname4 varchar (500),    
MiddleName4 varchar (500),    
Suffix4 varchar (500),    
DisplayName4 varchar (500),    
Type4 varchar (500),    
MaintTitle4 varchar (500),    
MainDepartment4 varchar (500),    
MainOrganization4 varchar (500),   
Author_bio4 varchar (8000),   
lastname5 varchar (500),    
Firstname5 varchar (500),    
MiddleName5 varchar (500),    
Suffix5 varchar (500),    
DisplayName5 varchar (500),    
Type5 varchar (500),    
MaintTitle5 varchar (500),    
MainDepartment5 varchar (500),    
MainOrganization5 varchar (500),   
Author_bio5 varchar (8000),   
lastname6 varchar (500),    
Firstname6 varchar (500),    
MiddleName6 varchar (500),    
Suffix6 varchar (500),    
DisplayName6 varchar (500),    
Type6 varchar (500),    
MaintTitle6 varchar (500),    
MainDepartment6 varchar (500),    
MainOrganization6 varchar (500),  
Author_bio6 varchar (8000),    
CitationComment1 varchar (8000),    
Author_Of_Citation1 varchar (500),    
Source_Of_Citation1 varchar (500),    
CitationComment2 varchar (8000),    
Author_Of_Citation2 varchar (500),    
Source_Of_Citation2 varchar (500),    
CitationComment3 varchar (8000),    
Author_Of_Citation3 varchar (500),    
Source_Of_Citation3 varchar (500),    
CitationComment4 varchar (8000),    
Author_Of_Citation4 varchar (500),    
Source_Of_Citation4 varchar (500),    
CitationComment5 varchar (8000),    
Author_Of_Citation5 varchar (500),    
Source_Of_Citation5 varchar (500),    
CitationComment6 varchar (8000),    
Author_Of_Citation6 varchar (500),    
Source_Of_Citation6 varchar (500),    
Rup_Category1 varchar (500),    
Rup_Category2 varchar (500),    
Rup_Category3 varchar (500),   
Bisac_Subject1 varchar (500),    
Bisac_Subject2 varchar (500),    
Bisac_Subject3 varchar (500), 
AuthorSalesTrackISBN1 varchar (25),    
ComparitiveTitleISBN1 varchar (25),    
CompetitivetitleISBN1 varchar (25),    
AuthorSalesTrackISBN2 varchar (25),    
ComparitiveTitleISBN2 varchar (25),    
CompetitivetitleISBN2 varchar (25),
Discount_Code varchar (10),
ISBN_No_Dashes varchar(25) 
          
)    
    
Declare @bookkey int    
Declare @Lastname varchar (500)    
Declare @FirstName varchar (500)    
Declare @middlename varchar (500)    
Declare @Suffix varchar (500)    
Declare @DisplayName varchar (500)    
Declare @Type varchar (500)    
Declare @globalcontactkey int    
Declare @iCounter int    
Select  @iCounter=1       
--Cursor2 variables    
Declare @i_Citation_key int    
Declare @str_CitationSource varchar (500)    
Declare @str_citationAuthor varchar (500)    
Declare @iCounter_2 int    
Select @iCounter_2=1    
--Cursor3 variables    
Declare @Rup_Category varchar (500)    
Declare @iCounter_3 int    
Select @iCounter_3=1   
--Cursor3a variables 
Declare @bookkey3a int
Declare @sortorder3a int
Declare @iCounter_3a int    
Select @iCounter_3a=1     
--Cursor4 variables    
Declare @Author_ISBN varchar (100)    
Declare @iCounter_4 int    
Select @iCounter_4=1    
--Cursor5 variables    
Declare @ComparativetitleISBN varchar (100)    
Declare @iCounter_5 int    
Select @iCounter_5=1    
--Cursor6 variables    
Declare @CompetitiveTitleISBN varchar (100)    
Declare @iCounter_6 int    
Select @iCounter_6=1    
    
    
Declare @i_Bookkey int    
DECLARE curMain0 CURSOR for             
Select key1 from qsrpt_instance_item where instancekey=@i_reportinstancekey     
            
FOR READ ONLY            
Open curMain0            
fetch next from curMain0 into @i_Bookkey             
while @@FETCH_STATUS = 0            
begin         
  
--Initial Insert  
Insert Into #Contributor_Info (bookkey)    
values (@i_Bookkey)    
  
  
    
DECLARE curMain CURSOR for             
Select Top 6 bookkey,globalcontactkey ,lastname,Firstname,middlename,suffix,DisplayName,dbo.rpt_get_gentables_desc(134,ba.authortypecode,'D')     
from bookAuthor ba    
inner join globalcontact gc    
on ba.authorkey=gc.globalcontactkey    
where ba.Authortypecode in(12,16,33,32,27,15)    
and ba.bookkey=@i_Bookkey order by sortorder-- in(Select key1 from qsrpt_instance_item where instancekey=@i_reportinstancekey)    
           
            
FOR READ ONLY            
Open curMain            
fetch next from curmain into @bookkey,@globalcontactkey,@Lastname ,@FirstName ,@middlename,@Suffix ,@DisplayName ,@Type             
while @@FETCH_STATUS = 0            
begin              
    
If @iCounter=1    
BEGIN    
Update #Contributor_Info Set lastname1=@LastName,FirstName1=@FirstName,MiddleName1=@MiddleName,    
 Suffix1=@Suffix,DisplayName1=@DisplayName,Type1=@Type,MaintTitle1=dbo.rpt_Get_Contact_Comments(@globalcontactkey,9,0),    
 MainDepartment1=dbo.rpt_Get_Contact_Comments(@globalcontactkey,14,0),MainOrganization1=dbo.rpt_Get_Contact_Comments(@globalcontactkey,11,0),  
Author_Bio1=dbo.rpt_Get_Contact_Comments(@globalcontactkey,3,10)  
 where bookkey=@bookkey   
END    
If @iCounter=2    
BEGIN    
 Update #Contributor_Info Set lastname2=@LastName,FirstName2=@FirstName,MiddleName2=@MiddleName,    
 Suffix2=@Suffix,DisplayName2=@DisplayName,Type2=@Type,MaintTitle2=dbo.rpt_Get_Contact_Comments(@globalcontactkey,9,0),    
 MainDepartment2=dbo.rpt_Get_Contact_Comments(@globalcontactkey,14,0),MainOrganization2=dbo.rpt_Get_Contact_Comments(@globalcontactkey,11,0),  
Author_Bio2=dbo.rpt_Get_Contact_Comments(@globalcontactkey,3,10)  
 where bookkey=@bookkey    
END    
If @iCounter=3    
BEGIN    
 Update #Contributor_Info Set lastname3=@LastName,FirstName3=@FirstName,MiddleName3=@MiddleName,    
 Suffix3=@Suffix,DisplayName3=@DisplayName,Type3=@Type,MaintTitle3=dbo.rpt_Get_Contact_Comments(@globalcontactkey,9,0),    
 MainDepartment3=dbo.rpt_Get_Contact_Comments(@globalcontactkey,14,0),MainOrganization3=dbo.rpt_Get_Contact_Comments(@globalcontactkey,11,0),  
Author_Bio3=dbo.rpt_Get_Contact_Comments(@globalcontactkey,3,10)  
 where bookkey=@bookkey    
END    
If @iCounter=4    
BEGIN    
 Update #Contributor_Info Set lastname4=@LastName,FirstName4=@FirstName,MiddleName4=@MiddleName,    
 Suffix4=@Suffix,DisplayName4=@DisplayName,Type4=@Type,MaintTitle4=dbo.rpt_Get_Contact_Comments(@globalcontactkey,9,0),    
 MainDepartment4=dbo.rpt_Get_Contact_Comments(@globalcontactkey,14,0),MainOrganization4=dbo.rpt_Get_Contact_Comments(@globalcontactkey,11,0),  
Author_Bio4=dbo.rpt_Get_Contact_Comments(@globalcontactkey,3,10)  
 where bookkey=@bookkey    
END    
If @iCounter=5    
BEGIN    
 Update #Contributor_Info Set lastname5=@LastName,FirstName5=@FirstName,MiddleName5=@MiddleName,    
 Suffix5=@Suffix,DisplayName5=@DisplayName,Type5=@Type,MaintTitle5=dbo.rpt_Get_Contact_Comments(@globalcontactkey,9,0),    
 MainDepartment5=dbo.rpt_Get_Contact_Comments(@globalcontactkey,14,0),MainOrganization5=dbo.rpt_Get_Contact_Comments(@globalcontactkey,11,0),  
Author_Bio5=dbo.rpt_Get_Contact_Comments(@globalcontactkey,3,10)  
 where bookkey=@bookkey    
END    
If @iCounter=6    
BEGIN    
 Update #Contributor_Info Set lastname6=@LastName,FirstName6=@FirstName,MiddleName6=@MiddleName,    
 Suffix6=@Suffix,DisplayName6=@DisplayName,Type6=@Type,MaintTitle6=dbo.rpt_Get_Contact_Comments(@globalcontactkey,9,0),    
MainDepartment6=dbo.rpt_Get_Contact_Comments(@globalcontactkey,14,0),MainOrganization6=dbo.rpt_Get_Contact_Comments(@globalcontactkey,11,0),  
Author_Bio6=dbo.rpt_Get_Contact_Comments(@globalcontactkey,3,10)  
 where bookkey=@bookkey    
END    
             
Select @iCounter=@iCounter + 1            
 fetch next from curmain into @bookkey,@globalcontactkey,@Lastname ,@FirstName ,@middlename,@Suffix ,@DisplayName ,@Type      
end             
close curmain            
deallocate curmain            
    
  
  
--2nd Cursor Citation    
DECLARE curMain2 CURSOR for             
Select Top 6 Citationkey,citationsource,citationAuthor from citation where bookkey=@i_Bookkey order by sortorder-- in(Select key1 from qsrpt_instance_item where instancekey=@i_reportinstancekey)    
           
            
FOR READ ONLY            
Open curMain2            
fetch next from curmain2 into @i_Citation_key,@str_CitationSource,@str_citationAuthor              
while @@FETCH_STATUS = 0            
begin              
    
    
If @iCounter_2=1    
BEGIN    
 Update #Contributor_Info     
 Set CitationComment1=(Select Commenthtmllite from qsicomments where commentkey=@i_Citation_key and commenttypecode=1 and commenttypesubcode=1), Author_of_Citation1=@str_citationAuthor,Source_Of_Citation1=@str_CitationSource    
 where bookkey=@i_bookkey    
END    
    
If @iCounter_2=2    
BEGIN    
 Update #Contributor_Info     
 Set CitationComment2=(Select Commenthtmllite from qsicomments where commentkey=@i_Citation_key and commenttypecode=1 and commenttypesubcode=1), Author_of_Citation2=@str_citationAuthor,Source_Of_Citation2=@str_CitationSource    
 where bookkey=@i_bookkey    
END    
    
If @iCounter_2=3    
BEGIN    
 Update #Contributor_Info     
 Set CitationComment3=(Select Commenthtmllite from qsicomments where commentkey=@i_Citation_key and commenttypecode=1 and commenttypesubcode=1), Author_of_Citation3=@str_citationAuthor,Source_Of_Citation3=@str_CitationSource    
 where bookkey=@i_bookkey    
END    
    
If @iCounter_2=4    
BEGIN    
 Update #Contributor_Info     
 Set CitationComment4=(Select Commenthtmllite from qsicomments where commentkey=@i_Citation_key and commenttypecode=1 and commenttypesubcode=1), Author_of_Citation4=@str_citationAuthor,Source_Of_Citation4=@str_CitationSource    
 where bookkey=@i_bookkey    
END    
    
If @iCounter_2=5    
BEGIN    
 Update #Contributor_Info     
 Set CitationComment5=(Select Commenthtmllite from qsicomments where commentkey=@i_Citation_key and commenttypecode=1 and commenttypesubcode=1), Author_of_Citation5=@str_citationAuthor,Source_Of_Citation5=@str_CitationSource    
 where bookkey=@i_bookkey    
END    
    
If @iCounter_2=6    
BEGIN    
 Update #Contributor_Info     
 Set CitationComment6=(Select Commenthtmllite from qsicomments where commentkey=@i_Citation_key and commenttypecode=1 and commenttypesubcode=1), Author_of_Citation6=@str_citationAuthor,Source_Of_Citation6=@str_CitationSource    
 where bookkey=@i_bookkey    
END    
             
Select @iCounter_2=@iCounter_2 + 1            
 fetch next from curmain2 into @i_Citation_key,@str_CitationSource,@str_citationAuthor     
end             
close curmain2            
deallocate curmain2         
    
    
--Cursor3    
DECLARE curMain3 CURSOR for             
Select Top 3 dbo.rpt_get_gentables_desc(categorytableid,categorycode,'D')     
from booksubjectcategory where bookkey=@i_bookkey  order by sortorder         
            
FOR READ ONLY            
Open curMain3            
fetch next from curMain3 into @Rup_Category             
while @@FETCH_STATUS = 0            
begin              
    
    
If @iCounter_3=1    
BEGIN    
 Update #Contributor_Info     
 Set Rup_Category1=@Rup_Category    
 where bookkey=@i_bookkey    
END    
    
If @iCounter_3=2    
BEGIN    
 Update #Contributor_Info     
 Set Rup_Category2=@Rup_Category    
 where bookkey=@i_bookkey    
END    
    
If @iCounter_3=3    
BEGIN    
 Update #Contributor_Info     
 Set Rup_Category3=@Rup_Category    
 where bookkey=@i_bookkey    
END    
    
Select @iCounter_3=@iCounter_3 + 1            
 fetch next from curMain3 into @Rup_Category    
end             
close curMain3            
deallocate curMain3       


--Cursor3a    
DECLARE curMain3a CURSOR for             
Select Top 3 bookkey,sortorder
from bookbisaccategory where bookkey=@i_bookkey  order by sortorder         
            
FOR READ ONLY            
Open curMain3a            
fetch next from curMain3a into @bookkey3a,@sortorder3a           
while @@FETCH_STATUS = 0            
begin              
    
    
If @iCounter_3a=1    
BEGIN    
 Update #Contributor_Info     
 Set Bisac_Subject1=dbo.rpt_get_bisac_subject(@bookkey3a,@sortorder3a,'D')         
 where bookkey=@i_bookkey    
END    
    
If @iCounter_3a=2    
BEGIN    
 Update #Contributor_Info     
 Set Bisac_Subject2=dbo.rpt_get_bisac_subject(@bookkey3a,@sortorder3a,'D')     
 where bookkey=@i_bookkey    
END    
    
If @iCounter_3a=3    
BEGIN    
 Update #Contributor_Info     
 Set Bisac_Subject3=dbo.rpt_get_bisac_subject(@bookkey3a,@sortorder3a,'D')     
 where bookkey=@i_bookkey    
END    
    
Select @iCounter_3a=@iCounter_3a + 1            
 fetch next from curMain3a into  @bookkey3a,@sortorder3a     
end             
close curMain3a            
deallocate curMain3a       
    
    
--Cursor4    
--AuthorSalesISBN    
    
DECLARE curMain4 CURSOR for             
Select  Top 2 dbo.rpt_get_isbn(associatetitlebookkey,17) from associatedtitles where bookkey=@i_bookkey    
and associationTypecode=3 order by sortorder       
            
FOR READ ONLY            
Open curMain4            
fetch next from curMain4 into @Author_ISBN             
while @@FETCH_STATUS = 0            
begin              
    
    
If @iCounter_4=1    
BEGIN    
 Update #Contributor_Info     
 Set AuthorSalesTrackISBN1=@Author_ISBN    
 where bookkey=@i_bookkey    
END    
    
If @iCounter_4=2    
BEGIN    
 Update #Contributor_Info     
 Set AuthorSalesTrackISBN2=@Author_ISBN    
 where bookkey=@i_bookkey    
END    
    
    
    
Select @iCounter_4=@iCounter_4 + 1            
 fetch next from curMain4 into @Author_ISBN    
end             
close curMain4            
deallocate curMain4      
    
    
--Cursor5    
--ComparativetitleISBN    
    
DECLARE curMain5 CURSOR for             
Select Top 2 dbo.rpt_get_isbn(associatetitlebookkey,17) from associatedtitles where bookkey=@i_bookkey    
and associationTypecode=2 order by sortorder       
            
FOR READ ONLY            
Open curMain5            
fetch next from curMain5 into @ComparativetitleISBN             
while @@FETCH_STATUS = 0            
begin              
    
    
If @iCounter_5=1    
BEGIN    
 Update #Contributor_Info     
 Set ComparitiveTitleISBN1=@ComparativetitleISBN    
 where bookkey=@i_bookkey    
END    
    
If @iCounter_4=2    
BEGIN    
 Update #Contributor_Info     
 Set ComparitiveTitleISBN2=@ComparativetitleISBN    
 where bookkey=@i_bookkey    
END    
    
    
    
Select @iCounter_5=@iCounter_5 + 1            
 fetch next from curMain5 into @ComparativetitleISBN    
end             
close curMain5            
deallocate curMain5      
    
--Cursor6    
--CompetitiveTitleISBN    
    
DECLARE curMain6 CURSOR for             
Select Top 2 dbo.rpt_get_isbn(associatetitlebookkey,17) from associatedtitles where bookkey=@i_bookkey    
and associationTypecode=1 order by sortorder       
            
FOR READ ONLY            
Open curMain6            
fetch next from curMain6 into @CompetitiveTitleISBN             
while @@FETCH_STATUS = 0            
begin              
    
    
If @iCounter_6=1    
BEGIN    
 Update #Contributor_Info     
 Set CompetitiveTitleISBN1=@CompetitiveTitleISBN    
 where bookkey=@i_bookkey    
END    
    
If @iCounter_4=2    
BEGIN    
 Update #Contributor_Info     
 Set CompetitiveTitleISBN2=@CompetitiveTitleISBN    
 where bookkey=@i_bookkey    
END    
    
    
    
Select @iCounter_6=@iCounter_6 + 1            
 fetch next from curMain6 into @CompetitiveTitleISBN    
end             
close curMain6            
deallocate curMain6      
    
Select @iCounter=1    
Select @iCounter_2=1    
Select @iCounter_3=1
Select @iCounter_3a=1
Select @iCounter_4=1    
Select @iCounter_5=1    
Select @iCounter_6=1    

Update #Contributor_Info set Discount_Code=dbo.rpt_get_discount(@i_bookkey,'D') where bookkey=@i_bookkey
Update #Contributor_Info set ISBN_No_Dashes=dbo.rpt_get_ISBN(@i_bookkey,17) where bookkey=@i_bookkey

    
fetch next from curMain0 into @i_bookkey    
end             
close curMain0            
deallocate curMain0      
    
    
             
            
Select  * from #Contributor_Info            
            
Drop Table #Contributor_Info 


GO

GRANT ALL ON rpt_get_Marketing_Dump_Info_Modified TO PUBLIC

