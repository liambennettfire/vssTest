SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.import_request_email_procedure') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.import_request_email_procedure
end
go

create PROCEDURE dbo.import_request_email_procedure
AS

-- Set up variables.
DECLARE @status INT,
@v_lane int,
@v_webrequestkey int,
@v_division varchar(10),
@v_role2_externalid varchar(30),
@v_phone2_externalid varchar(30),
@v_phone2 varchar(30),
@v_note varchar(20),
@v_book varchar(100),
@v_author varchar(100),
@v_schoolphonenumber varchar(100),
@v_reqopttext varchar(8000),
@v_special  varchar(8000),
@v_coursenumber varchar(100),
@v_coursename varchar(100),
@v_studentlevel1 varchar(100),
@v_StartMonth varchar(100),
@v_StartYear varchar(100),
@v_enrollment varchar(100),
@v_bookstore varchar(100),
@v_syllabus varchar(100),
@v_studentlevel2 varchar(100),
@v_refcode varchar(100),
@message_part VARCHAR(255),
@msg_id VARCHAR(255),
@message_length INT,
@skip_bytes INT,
@message VARCHAR(8000), 
@v_pos int,
@v_start int,
@v_newkey int,
@v_pos_break int,
@v_text_line VARCHAR(8000),
@v_lastname varchar(100),
@v_col varchar(100),
@v_firstname  varchar(100),
@v_address varchar(100),
@v_address1 varchar(100),
@v_address2 varchar(100),
@v_city varchar(100),
@v_state varchar(100),
@v_zipcode varchar(100),
@v_zipcode4 varchar(100),
@v_Country varchar(100),
@v_countrypostalcode varchar(100),
@v_apparently_from varchar(100),
@v_daytimephone varchar(100),
@v_school varchar(100),
@v_institutiontype varchar(100),
@v_department varchar(100),
@v_lastnameInstructor varchar(100),
@v_firstnameInstructor varchar(100),
@v_emailInstructor varchar(100),
@v_book1 varchar(100),
@v_isbn1 varchar(100),
@v_currenttext1 varchar(100),
@v_coursetitle1 varchar(100),
@v_StartMonth1 varchar(100),
@v_StartYear1 varchar(100),
@v_adoptiondate1 varchar(100),
@v_enrollment1 varchar(100),
@v_syllabus1 varchar(100),
@v_book2 varchar(100),
@v_isbn2 varchar(100),
@v_currenttext2 varchar(100),
@v_position varchar(100),
@v_coursetitle2 varchar(100),
@v_StartMonth2 varchar(100),
@v_StartYear2 varchar(100),
@v_adoptiondate2 varchar(100),
@v_enrollment2 varchar(100),
@v_syllabus2 varchar(100),
@v_moreinfo varchar(8000),
@v_subject varchar(500),
@v_usageclassqsicode int,
@v_Projecttype_externalid varchar(20),
@v_key_parent int,
@v_Orgentry2 int,
@v_Orgentry3 int



declare c_import cursor for
select webrequestkey, subjectline, emailbody
from webrequest
where processind = 0
--where webrequestkey in (935399, 935402)
BEGIN

 OPEN c_import
  FETCH c_import INTO	@v_webrequestkey, @v_subject, @message
  while (@@FETCH_STATUS = 0) 
    begin 

set @status = null
set @v_lane = null
set @v_division= null
set @v_role2_externalid= null
set @v_phone2_externalid= null
set @v_phone2= null
set @v_note= null
set @v_book= null
set @v_author= null
set @v_schoolphonenumber= null
set @v_reqopttext= null
set @v_special = null
set @v_coursenumber= null
set @v_coursename= null
set @v_studentlevel1= null
set @v_StartMonth= null
set @v_StartYear= null
set @v_enrollment= null
set @v_bookstore= null
set @v_syllabus= null
set @v_studentlevel2= null
set @v_refcode= null
set @message_part= null
set @msg_id= null
set @message_length = null
set @skip_bytes = null
set @v_pos = null
set @v_start = null
set @v_newkey = null
set @v_pos_break = null
set @v_text_line= null
set @v_lastname= null
set @v_col= null
set @v_firstname = null
set @v_address= null
set @v_address1= null
set @v_address2= null
set @v_city= null
set @v_state= null
set @v_zipcode= null
set @v_zipcode4= null
set @v_Country= null
set @v_countrypostalcode= null
set @v_apparently_from= null
set @v_daytimephone= null
set @v_school= null
set @v_institutiontype= null
set @v_department= null
set @v_lastnameInstructor= null
set @v_firstnameInstructor= null
set @v_emailInstructor= null
set @v_book1= null
set @v_isbn1= null
set @v_currenttext1= null
set @v_coursetitle1= null
set @v_StartMonth1= null
set @v_StartYear1= null
set @v_adoptiondate1= null
set @v_enrollment1= null
set @v_syllabus1= null
set @v_book2= null
set @v_isbn2= null
set @v_currenttext2= null
set @v_position= null
set @v_coursetitle2= null
set @v_StartMonth2= null
set @v_StartYear2= null
set @v_adoptiondate2= null
set @v_enrollment2= null
set @v_syllabus2= null
set @v_moreinfo= null
set @v_usageclassqsicode = null
set @v_Projecttype_externalid = null
set @v_key_parent = null
set @v_Orgentry2 = null
set @v_Orgentry3= null

set @v_subject = replace (@v_subject,char(13),'')
set @v_subject = replace (@v_subject,char(10),'')


if @v_subject = 'UMP_Exam_Copy_Request' begin
	exec import_request_column_procedure 'lastname:', 'firstname:', @message, @v_lastname output
	exec import_request_column_procedure 'firstname:', 'address:', @message, @v_firstname output
	exec import_request_column_procedure 'address:', 'address1:', @message, @v_address output
	exec import_request_column_procedure 'address1:', 'address2:',@message, @v_address1 output
	exec import_request_column_procedure 'address2:', 'city:', @message, @v_address2 output
	exec import_request_column_procedure 'city:', 'state:', @message, @v_city output
	exec import_request_column_procedure 'state:', 'zipcode:', @message, @v_state output
	exec import_request_column_procedure 'zipcode:', 'zipcode4:', @message, @v_zipcode output
	exec import_request_column_procedure 'zipcode4:', 'Country:', @message, @v_zipcode4 output
	exec import_request_column_procedure 'Country:', 'countrypostalcode:', @message, @v_Country output
	exec import_request_column_procedure 'countrypostalcode:', 'apparently-from:', @message, @v_countrypostalcode output
	exec import_request_column_procedure 'apparently-from:', 'daytimephone:', @message, @v_apparently_from output
	exec import_request_column_procedure 'daytimephone:', 'school:', @message, @v_daytimephone output
	exec import_request_column_procedure 'school:', 'institutiontype:', @message, @v_school output
	exec import_request_column_procedure 'institutiontype:', 'department:', @message, @v_institutiontype output
	exec import_request_column_procedure 'department:', 'lastnameInstructor:', @message, @v_department output
	exec import_request_column_procedure 'lastnameInstructor:', 'firstnameInstructor:',@message, @v_lastnameInstructor output
	exec import_request_column_procedure 'firstnameInstructor:','emailInstructor:', @message, @v_firstnameInstructor output
	exec import_request_column_procedure 'emailInstructor:', 'book1:',@message, @v_emailInstructor output
	exec import_request_column_procedure 'book1:', 'isbn1:',@message, @v_book1 output
	exec import_request_column_procedure 'isbn1:', 'currenttext1:',@message, @v_isbn1 output
	exec import_request_column_procedure 'currenttext1:', 'coursetitle1:',@message, @v_currenttext1 output
	exec import_request_column_procedure 'coursetitle1:', 'studentlevel1:',@message, @v_coursetitle1 output
	exec import_request_column_procedure 'studentlevel1:', 'StartMonth1:',@message, @v_studentlevel1 output 
	exec import_request_column_procedure 'StartMonth1:', 'StartYear1:',@message, @v_StartMonth1 output
	exec import_request_column_procedure 'StartYear1:', 'adoptiondate1:',@message, @v_StartYear1 output
	exec import_request_column_procedure 'adoptiondate1:', 'enrollment1:', @message, @v_adoptiondate1 output
	exec import_request_column_procedure 'enrollment1:', 'syllabus1:' ,@message, @v_enrollment1 output
	exec import_request_column_procedure 'syllabus1:' , 'book2:',@message, @v_syllabus1 output
	exec import_request_column_procedure 'book2:', 'isbn2:',@message, @v_book2 output
	exec import_request_column_procedure 'isbn2:', 'currenttext2:',@message, @v_isbn2 output
	exec import_request_column_procedure 'currenttext2:','coursetitle2:', @message, @v_currenttext2 output
	exec import_request_column_procedure 'coursetitle2:', 'studentlevel2:',@message, @v_coursetitle2 output
	exec import_request_column_procedure 'studentlevel2:', 'StartMonth2:',@message, @v_studentlevel2 output
	exec import_request_column_procedure 'StartMonth2:', 'StartYear2:', @message, @v_StartMonth2 output
	exec import_request_column_procedure 'StartYear2:', 'adoptiondate2:',@message, @v_StartYear2 output
	exec import_request_column_procedure 'adoptiondate2:', 'enrollment2:', @message, @v_adoptiondate2 output
	exec import_request_column_procedure 'enrollment2:', 'syllabus2:',@message, @v_enrollment2 output
	exec import_request_column_procedure 'syllabus2:','moreinfo:',  @message, @v_syllabus2 output
	exec import_request_column_procedure 'moreinfo:', 'refcode:', @message, @v_moreinfo output
	exec import_request_column_procedure 'refcode:', null, @message, @v_refcode output
end


if @v_subject = 'UMP_Desk_Copy_Request' begin
	exec import_request_column_procedure 'lastname:', 'firstname:', @message, @v_lastname output
	exec import_request_column_procedure 'firstname:', 'address:', @message, @v_firstname output
	exec import_request_column_procedure 'address:', 'address1:', @message, @v_address output
	exec import_request_column_procedure 'address1:', 'address2:',@message, @v_address1 output
	exec import_request_column_procedure 'address2:', 'city:', @message, @v_address2 output
	exec import_request_column_procedure 'city:', 'state:', @message, @v_city output
	exec import_request_column_procedure 'state:', 'zipcode:', @message, @v_state output
	exec import_request_column_procedure 'zipcode:', 'zipcode4:', @message, @v_zipcode output
	exec import_request_column_procedure 'zipcode4:', 'Country:', @message, @v_zipcode4 output
	exec import_request_column_procedure 'Country:', 'countrypostalcode:', @message, @v_Country output
	exec import_request_column_procedure 'countrypostalcode:', 'apparently-from:', @message, @v_countrypostalcode output
	exec import_request_column_procedure 'apparently-from:', 'daytimephone:', @message, @v_apparently_from output
	exec import_request_column_procedure 'daytimephone:', 'school:', @message, @v_daytimephone output
	exec import_request_column_procedure 'school:', 'institutiontype:', @message, @v_school output
	exec import_request_column_procedure 'institutiontype:', 'department:', @message, @v_institutiontype output
	exec import_request_column_procedure 'department:', 'lastnameInstructor:', @message, @v_department output
	exec import_request_column_procedure 'lastnameInstructor:', 'firstnameInstructor:',@message, @v_lastnameInstructor output
	exec import_request_column_procedure 'firstnameInstructor:','emailInstructor:', @message, @v_firstnameInstructor output
	exec import_request_column_procedure 'emailInstructor:', 'schoolphonenumber:',@message, @v_emailInstructor output
	exec import_request_column_procedure 'schoolphonenumber:', 'book1:',@message, @v_schoolphonenumber output
	exec import_request_column_procedure 'book1:', 'isbn1:',@message, @v_book1 output
	exec import_request_column_procedure 'isbn1:', 'reqopttext:',@message, @v_isbn1 output
	exec import_request_column_procedure 'reqopttext:', 'coursename:',@message, @v_reqopttext output 
	exec import_request_column_procedure 'coursename:', 'StartMonth:',@message, @v_coursename output 
	exec import_request_column_procedure 'StartMonth:', 'StartYear:',@message, @v_StartMonth output
	exec import_request_column_procedure 'StartYear:', 'enrollment:',@message, @v_StartYear output
	exec import_request_column_procedure 'enrollment:', 'bookstore:' ,@message, @v_enrollment output
	exec import_request_column_procedure 'bookstore:', 'syllabus:' ,@message, @v_bookstore output
	exec import_request_column_procedure 'syllabus:' , 'moreinfo:',@message, @v_syllabus output 
	exec import_request_column_procedure 'moreinfo:', 'special:',@message, @v_moreinfo output
	exec import_request_column_procedure 'special:', null,@message, @v_special output
end
if @v_subject = 'ESL_Desk_Copy_Request' begin
	exec import_request_column_procedure 'lastname:', 'firstname:', @message, @v_lastname output
	exec import_request_column_procedure 'firstname:', 'position:', @message, @v_firstname output
	exec import_request_column_procedure 'position:', 'address:', @message, @v_position output --this
	exec import_request_column_procedure 'address:', 'address1:', @message, @v_address output
	exec import_request_column_procedure 'address1:', 'address2:',@message, @v_address1 output
	exec import_request_column_procedure 'address2:', 'city:', @message, @v_address2 output
	exec import_request_column_procedure 'city:', 'state:', @message, @v_city output
	exec import_request_column_procedure 'state:', 'zipcode:', @message, @v_state output
	exec import_request_column_procedure 'zipcode:', 'zipcode4:', @message, @v_zipcode output
	exec import_request_column_procedure 'zipcode4:', 'Country:', @message, @v_zipcode4 output
	exec import_request_column_procedure 'Country:', 'countrypostalcode:', @message, @v_Country output
	exec import_request_column_procedure 'countrypostalcode:', 'apparently-from:', @message, @v_countrypostalcode output
	exec import_request_column_procedure 'apparently-from:', 'daytimephone:', @message, @v_apparently_from output
	exec import_request_column_procedure 'daytimephone:', 'school:', @message, @v_daytimephone output
	exec import_request_column_procedure 'school:', 'institutiontype:', @message, @v_school output
	exec import_request_column_procedure 'institutiontype:', 'department:', @message, @v_institutiontype output
	exec import_request_column_procedure 'department:', 'lastnameInstructor:', @message, @v_department output
	exec import_request_column_procedure 'lastnameInstructor:', 'firstnameInstructor:',@message, @v_lastnameInstructor output
	exec import_request_column_procedure 'firstnameInstructor:','emailInstructor:', @message, @v_firstnameInstructor output
	exec import_request_column_procedure 'emailInstructor:', 'schoolphonenumber:',@message, @v_emailInstructor output
	exec import_request_column_procedure 'schoolphonenumber:', 'book:',@message, @v_schoolphonenumber output
	exec import_request_column_procedure 'book:', 'author:',@message, @v_book output
	exec import_request_column_procedure 'author:', 'isbn1:',@message, @v_author output
	exec import_request_column_procedure 'isbn1:', 'reqopttext:',@message, @v_isbn1 output
	exec import_request_column_procedure 'reqopttext:', 'coursenumber:',@message, @v_reqopttext output 
	exec import_request_column_procedure 'coursenumber:', 'coursename:',@message, @v_coursenumber output
	exec import_request_column_procedure 'coursename:', 'studentlevel1:',@message, @v_coursename output 
	exec import_request_column_procedure 'studentlevel1:', 'StartMonth:',@message, @v_studentlevel1 output
	exec import_request_column_procedure 'StartMonth:', 'StartYear:',@message, @v_StartMonth output
	exec import_request_column_procedure 'StartYear:', 'enrollment:',@message, @v_StartYear output
	exec import_request_column_procedure 'enrollment:', 'bookstore:' ,@message, @v_enrollment output
	exec import_request_column_procedure 'bookstore:', 'syllabus:' ,@message, @v_bookstore output
	exec import_request_column_procedure 'syllabus:' , 'moreinfo:',@message, @v_syllabus output
	exec import_request_column_procedure 'moreinfo:', 'refcode:',@message, @v_moreinfo output
	exec import_request_column_procedure 'refcode:', null,@message, @v_special output
end 

if @v_subject = 'ESL_Exam_Copy_Request' begin
exec import_request_column_procedure 'lastname:', 'firstname:', @message, @v_lastname output
	exec import_request_column_procedure 'firstname:', 'address:', @message, @v_firstname output
	exec import_request_column_procedure 'address:', 'address1:', @message, @v_address output
	exec import_request_column_procedure 'address1:', 'address2:',@message, @v_address1 output
	exec import_request_column_procedure 'address2:', 'city:', @message, @v_address2 output
	exec import_request_column_procedure 'city:', 'state:', @message, @v_city output
	exec import_request_column_procedure 'state:', 'zipcode:', @message, @v_state output
	exec import_request_column_procedure 'zipcode:', 'zipcode4:', @message, @v_zipcode output
	exec import_request_column_procedure 'zipcode4:', 'Country:', @message, @v_zipcode4 output
	exec import_request_column_procedure 'Country:', 'countrypostalcode:', @message, @v_Country output
	exec import_request_column_procedure 'countrypostalcode:', 'apparently-from:', @message, @v_countrypostalcode output
	exec import_request_column_procedure 'apparently-from:', 'daytimephone:', @message, @v_apparently_from output
	exec import_request_column_procedure 'daytimephone:', 'school:', @message, @v_daytimephone output
	exec import_request_column_procedure 'school:', 'institutiontype:', @message, @v_school output
	exec import_request_column_procedure 'institutiontype:', 'department:', @message, @v_institutiontype output
	exec import_request_column_procedure 'department:', 'lastnameInstructor:', @message, @v_department output
	exec import_request_column_procedure 'lastnameInstructor:', 'firstnameInstructor:',@message, @v_lastnameInstructor output
	exec import_request_column_procedure 'firstnameInstructor:','emailInstructor:', @message, @v_firstnameInstructor output
	exec import_request_column_procedure 'emailInstructor:', 'book1:',@message, @v_emailInstructor output
	exec import_request_column_procedure 'book1:', 'isbn1:',@message, @v_book1 output
	exec import_request_column_procedure 'isbn1:', 'currenttext1:',@message, @v_isbn1 output
	exec import_request_column_procedure 'currenttext1:', 'coursetitle1:',@message, @v_currenttext1 output
	exec import_request_column_procedure 'coursetitle1:', 'studentlevel1:',@message, @v_coursetitle1 output
	exec import_request_column_procedure 'studentlevel1:', 'StartMonth1:',@message, @v_studentlevel1 output
	exec import_request_column_procedure 'StartMonth1:', 'StartYear1:',@message, @v_StartMonth1 output
	exec import_request_column_procedure 'StartYear1:', 'adoptiondate1:',@message, @v_StartYear1 output
	exec import_request_column_procedure 'adoptiondate1:', 'enrollment1:', @message, @v_adoptiondate1 output
	exec import_request_column_procedure 'enrollment1:', 'syllabus1:' ,@message, @v_enrollment1 output
	exec import_request_column_procedure 'syllabus1:' , 'book2:',@message, @v_syllabus1 output
	exec import_request_column_procedure 'book2:', 'isbn2:',@message, @v_book2 output
	exec import_request_column_procedure 'isbn2:', 'currenttext2:',@message, @v_isbn2 output
	exec import_request_column_procedure 'currenttext2:','coursetitle2:', @message, @v_currenttext2 output
	exec import_request_column_procedure 'coursetitle2:', 'studentlevel2:',@message, @v_coursetitle2 output
	exec import_request_column_procedure 'studentlevel2:', 'StartMonth2:',@message, @v_studentlevel2 output
	exec import_request_column_procedure 'StartMonth2:', 'StartYear2:', @message, @v_StartMonth2 output
	exec import_request_column_procedure 'StartYear2:', 'adoptiondate2:',@message, @v_StartYear2 output
	exec import_request_column_procedure 'adoptiondate2:', 'enrollment2:', @message, @v_adoptiondate2 output
	exec import_request_column_procedure 'enrollment2:', 'syllabus2:',@message, @v_enrollment2 output
	exec import_request_column_procedure 'syllabus2:','moreinfo:',  @message, @v_syllabus2 output
	exec import_request_column_procedure 'moreinfo:', 'refcode:', @message, @v_moreinfo output
	exec import_request_column_procedure 'refcode:', null, @message, @v_refcode output
end 




if CHARINDEX ('desk' , @v_subject) > 0 begin
	set @v_usageclassqsicode = 13
end
if CHARINDEX ('exam' , @v_subject) > 0 begin
	set @v_usageclassqsicode = 18
end

if @v_subject = 'ESL_Desk_Copy_Request' begin
	set @v_Projecttype_externalid = 'esldsk'
	set @v_division = 'ESL'
end
if @v_subject = 'UMP_Desk_Copy_Request' begin
	set @v_Projecttype_externalid = 'umpdsk'
	set @v_division = 'UMP'
end

if @v_subject = 'ESL_Exam_Copy_Request' begin
	set @v_Projecttype_externalid = 'eslexm'
	set @v_division = 'ESL'
end
if @v_subject = 'UMP_Exam_Copy_Request' begin
	set @v_Projecttype_externalid = 'umpexm'
	set @v_division = 'UMP'
end
if CHARINDEX ('UMP' , @v_subject) > 0 begin
	set @v_Orgentry2 = 3
	set @v_Orgentry3 = 4
end
if CHARINDEX ('ESL' , @v_subject) > 0 begin
	set @v_Orgentry2 = 5
	set @v_Orgentry3 = 6
end


exec get_next_key 'qsidba', @v_key_parent output


insert into project_import( projectimportkey, createdate, createfrom, Processedind, Projectname, Itemtypecode, usageclass_qsicode,
			Projecttype_externalid, Projectstatus_externalid, Usedefaultemplateind, Orgentry1, Orgentry2, Orgentry3, Comment_externalid1,
			Comment1, Comment_externalid2, Comment2, Task1_externalid, Task1_actualind, Lastmaintdate, Lastmaintuser)
values(@v_key_parent, getdate(), 'request email', 0, @v_lastname + '/' + IsNull(IsNull(substring(@v_book1, 1,30), substring(@v_book, 1, 30)), '') + '/' + CONVERT(VARCHAR(8), GETDATE(), 10), 3, @v_usageclassqsicode, 
	   @v_Projecttype_externalid , 'pending', 1, 1, @v_Orgentry2, @v_Orgentry3, 'furtherinfo',
	   @v_moreinfo, 'special', @v_special, 'createdate', 1, getdate(), 'email import')
		


 --If requestor = instructor and schoolphonenumber <> daytimephonenumber, set to 'school', else null
 --if requestor = instructor and schoolphonenumber <> daytimephonenumber, set to  schoolphonenumber, else null
 if @v_lastname = @v_lastnameInstructor and @v_firstname = @v_firstnameinstructor and @v_schoolphonenumber <> @v_daytimephone begin
	set @v_phone2_externalid = 'school'
	set @v_phone2 = @v_schoolphonenumber
 end else begin
	set @v_phone2_externalid = null
	set @v_phone2 = null
 end

 --Set to 'instructor' if requestor and instructor are same name; else null 
 if  @v_lastnameInstructor is null or ltrim(rtrim(@v_lastnameInstructor)) = '' begin
	set @v_role2_externalid = 'instructor'
    set @v_lastnameInstructor = @v_lastname
	set @v_firstnameinstructor = @v_firstname
end else begin
	set @v_role2_externalid = null
end

--Set to 'instructor' if requestor and instructor are same name; else null 
 if @v_lastname = @v_lastnameInstructor and @v_firstname = @v_firstnameinstructor begin
	set @v_role2_externalid = 'instructor'
end else begin
	set @v_role2_externalid = null
end

if @v_position is not null begin
	set @v_position = 'Position: ' + @v_position
end
exec get_next_key 'qsidba', @v_newkey output


insert into globalcontact_import(Individualind, globalcontactrequestkey, relatedprojectimportkey, createdate, createfrom, Processedind, Orgentry1, 
				lastname, firstname, Autodisplayind, address_primaryind, addresstype_externalid, address1, address2, city, state,
				zip, zip4, country, primary_email_externalid, primary_email, primary_phone_externalid, primary_phone, phone2_externalid,
				phone2, role1_externalid, role2_externalid, note, relatedcontact_relationcode1_externalid, relatedcontact_relationcode2_externalid, 
				relatedcontact_individualind, relatedcontact_linktoprimaryaddressind, relatedcontact_linktoprimaryphoneind, relatedcontact_groupname,
				relatedcontact_phone, relatedcontact_notontaq_name2, relatedcontact_notontaq_addtldesc )
values(1, @v_newkey, @v_key_parent, getdate(), 'request email', 0, 1, @v_lastname, @v_firstname, 1, 1, @v_address, @v_address1, @v_address2,
	   @v_City, @v_State, @v_zipcode, @v_zipcode4, @v_country, 'work', @v_apparently_from, 'daytime', @v_daytimephone, @v_phone2_externalid,
	   @v_phone2, 'requestor', @v_role2_externalid, @v_position, 'school', 'requestor', 0, 0, 0, @v_school, @v_schoolphonenumber, @v_school, @v_department + '/' + @v_institutiontype)



if @v_lastname <> @v_lastnameInstructor or @v_firstname <> @v_firstnameinstructor begin

	exec get_next_key 'qsidba', @v_newkey output

	insert into globalcontact_import(Globalcontactrequestkey, Relatedprojectimportkey, createdate, createfrom, Processedind, Orgentry1, Individualind,
					lastname, firstname, Autodisplayind, address_primaryind, addresstype_externalid, address1, address2, city, state,
					zip, zip4, country, primary_email_externalid, primary_email, primary_phone_externalid, primary_phone, role1_externalid,
					relatedcontact_relationcode1_externalid, relatedcontact_relationcode2_externalid, relatedcontact_individualind,
					relatedcontact_linktoprimaryaddressind,	relatedcontact_linktoprimaryphoneind, relatedcontact_lastname, relatedcontact_firstname,
					relatedcontact_phone, relatedcontact_email, relatedcontact2_relationcode1_externalid, relatedcontact2_relationcode2_externalid,
					relatedcontact2_individualind, relatedcontact2_linktoprimaryaddressind, relatedcontact2_linktoprimaryphoneind,relatedcontact2_groupname,
					relatedcontact2_phone, relatedcontact2_name2, relatedcontact2_addtldesc)
	values(@v_newkey, @v_key_parent, getdate(), 'request email', 0, 1, 1, @v_lastnameInstructor, @v_firstnameInstructor, 1, 1,  @v_address, @v_address1,	@v_address2,
	       @v_City, @v_State, @v_Zipcode, @v_zipcode4, @v_country, 'work', @v_emailInstructor, 'school', @v_schoolphonenumber, 'instructor', 'requestor', 'instructor',
	       1, 0, 0,	@v_lastname, @v_firstname, @v_daytimephone, @v_apparently_from, 'school', 'instructor', 0, 0, 0, @v_school, @v_schoolphonenumber,	@v_school, 
	       @v_department + '/' + @v_institutiontype)
end


if @v_reqopttext is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'reqtextopt',null, 0, null, null, @v_reqopttext)
end
if @v_currenttext1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'currenttext1',null, 0, null, null, @v_currenttext1)
end
if @v_coursenumber is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'coursenumber',null, 0, null, null, @v_coursenumber)
end
if @v_coursename is not null begin
	if @v_usageclassqsicode = 13 begin
		insert into project_import_miscitem
		values(@v_key_parent, 'coursetitle1',null, 0, null, null, @v_coursename)
	end
end
if @v_coursetitle1 is not null begin
	if @v_usageclassqsicode = 18 begin
		insert into project_import_miscitem
		values(@v_key_parent, 'coursetitle1',null, 0, null, null, @v_coursetitle1)
	end
end	

if @v_studentlevel1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'studentlevel1',null, 0, null, null, @v_studentlevel1)
end
if @v_startmonth1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'startmonth1',null, 0, null, null, @v_startmonth1)
end
if @v_startmonth is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'startmonth1',null, 0, null, null, @v_startmonth)
end		
if @v_startyear1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'startyear1',null, 0, null, null, @v_startyear1)
end
if @v_startyear is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'startyear1',null, 0, null, null, @v_startyear)
end		
if @v_adoptiondate1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'adoptiondate1',null, 0, null, null, @v_adoptiondate1)
end	
if @v_enrollment1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'enrollment1','enrollment1txt', 0, null, null, @v_enrollment1)
end	
if @v_enrollment is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'enrollment1','enrollment1txt', 0, null, null, @v_enrollment)
end	
if @v_syllabus1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'syllabus1',null, 0, null, null, @v_syllabus1)
end	
if @v_syllabus is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'syllabus1',null, 0, null, null, @v_syllabus)
end	
if @v_bookstore is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'bookstore',null, 0, null, null, @v_bookstore)
end	
if @v_currenttext2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'currenttext2',null, 0, null, null, @v_currenttext2)
end	
if @v_coursetitle2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'coursetitle2',null, 0, null, null, @v_coursetitle2)
end	
if @v_studentlevel2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'studentlevel2',null, 0, null, null, @v_studentlevel2)
end	
if @v_startmonth2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'startmonth2',null, 0, null, null, @v_startmonth2)
end	
if @v_startyear2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'startyear2',null, 0, null, null, @v_startyear2)
end	
if @v_adoptiondate2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'adoptiondate2',null, 0, null, null, @v_adoptiondate2)
end	
if @v_enrollment2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'enrollment2','enrollment2txt', 0, null, null, @v_enrollment2)
end	
if @v_syllabus2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'syllabus2',null, 0, null, null, @v_syllabus2)
end	
if @v_school is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'school',null, 0, null, null, @v_school)
end	
if @v_department is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'department',null, 0, null, null, @v_department)
end	
if @v_Institutiontype is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'Institutiontype',null, 0, null, null, @v_Institutiontype)
end	
if @v_book1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'book1',null, 0, null, null, @v_book1)
end	
if @v_book is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'book1',null, 0, null, null, @v_book) ---xxxxxxxx
end		
if @v_author is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'author',null, 0, null, null, @v_author)
end	
if @v_isbn1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'isbn1',null, 0, null, null, @v_isbn1)
end	
if @v_book2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'book2',null, 0, null, null, @v_book2)
end	
if @v_isbn2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'isbn2',null, 0, null, null, @v_isbn2)
end	
if @v_refcode is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'refcode',null, 0, null, null, @v_refcode)
end	

insert into project_import_miscitem
values(@v_key_parent, 'division',null, 0, null, null, @v_division)


update webrequest
set processind = 1
where webrequestkey = @v_webrequestkey 

FETCH c_import INTO	@v_webrequestkey, @v_subject, @message
END
close c_import
deallocate c_import
END



