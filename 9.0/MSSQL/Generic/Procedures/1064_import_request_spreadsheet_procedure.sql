/*
delete titlerequest_import
delete project_import
delete globalcontact_import
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.import_request_spreadsheet_procedure') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.import_request_spreadsheet_procedure
end
go

create PROCEDURE dbo.import_request_spreadsheet_procedure
AS

declare
@v_cnt int,
@v_pos int,
@v_note varchar(20),
@v_Orgentry2 tinyint ,
@v_Orgentry3 tinyint,
@v_Projecttype_externalid varchar(20),
@v_usageclas int,
@v_Projectname varchar(100),
@v_role2_externalid varchar(30),
@v_phone2 varchar(30),
@v_key_parent int,
@v_nextkey_child int,
@v_phone2_externalid varchar(30),
@v_division  varchar(100),
@v_class  varchar(100),
@v_lastname  varchar(100),
@v_firstname  varchar(100),
@v_addresstype  varchar(100),
@v_address1  varchar(100),
@v_address2  varchar(100),
@v_city  varchar(100),
@v_state  varchar(100),
@v_zipcode  varchar(100),
@v_zipcode4  varchar(100),
@v_Country  varchar(100),
@v_apparentlyfrom  varchar(100),
@v_daytimephone  varchar(100),
@v_school  varchar(100),
@v_institutiontype  varchar(100),
@v_department  varchar(100),
@v_lastnameInstructor  varchar(100),
@v_firstnameInstructor  varchar(100),
@v_schoolphonenumber  varchar(100),
@v_emailInstructor  varchar(100),
@v_book1  varchar(100),
@v_author  varchar(100),
@v_author2  varchar(100),
@v_isbn1  varchar(100),
@v_reqtextopt  varchar(100),
@v_currenttext1  varchar(100),
@v_coursenumber  varchar(100),
@v_coursetitle1  varchar(100),
@v_studentlevel1  varchar(100),
@v_startmonth1  varchar(100),
@v_startyear1  varchar(100),
@v_adoptiondate1  varchar(100),
@v_enrollment1  varchar(100),
@v_syllabus1  varchar(100),
@v_bookstore  varchar(100),
@v_book2  varchar(100),
@v_isbn2  varchar(100),
@v_currenttext2  varchar(100),
@v_coursetitle2  varchar(100),
@v_studentlevel2  varchar(100),
@v_startmonth2  varchar(100),
@v_startyear2  varchar(100),
@v_adoptiondate2  varchar(100),
@v_enrollment2  varchar(100),
@v_syllabus2  varchar(100),
@v_moreinfo  varchar(100),
@v_special  varchar(100),
@v_refcode  varchar(100),
@v_nextkey int,
@v_class_code int,
@v_lastname_orig varchar(100)


declare c_import cursor for
select *
from import_request_spreadsheet
order by division, lastname, firstname

begin
  OPEN c_import
  FETCH c_import INTO	@v_division,@v_class,@v_lastname,@v_firstname,@v_addresstype,@v_address1,@v_address2,@v_city,@v_state,@v_zipcode,
						@v_zipcode4,@v_Country,@v_apparentlyfrom,@v_daytimephone,@v_school,@v_institutiontype,@v_department,@v_lastnameInstructor,
						@v_firstnameInstructor,@v_schoolphonenumber,@v_emailInstructor,@v_book1,@v_author,@v_isbn1,@v_reqtextopt,@v_currenttext1,
						@v_coursenumber,@v_coursetitle1,@v_studentlevel1,@v_startmonth1,@v_startyear1,@v_adoptiondate1,@v_enrollment1,@v_syllabus1,
						@v_bookstore,@v_book2,@v_author2, @v_isbn2,@v_currenttext2,@v_coursetitle2,@v_studentlevel2,@v_startmonth2,@v_startyear2,@v_adoptiondate2,
						@v_enrollment2,@v_syllabus2,@v_moreinfo,@v_special,@v_refcode
  while (@@FETCH_STATUS = 0) 
    begin 
	
	set @v_lastname = replace(@v_lastname, '"', '')
	set @v_lastname_orig = @v_lastname
	set @v_pos = charindex(',', @v_lastname)
	if @v_pos  > 0 begin
		set @v_lastname = SUBSTRING (@v_lastname ,0, @v_pos)
		if @v_firstname is null begin
			set @v_firstname = ltrim(SUBSTRING (@v_lastname_orig ,@v_pos + 1, 50))
		end 
	end


	set @v_pos = charindex(char(9), @v_refcode)
	if @v_pos > 0 begin
		set @v_refcode = null
	end

	exec get_next_key 'qsidba', @v_key_parent output

	if @v_class = 'DSK' begin
		set @v_class_code = 13
	end else begin
		set @v_class_code = 18
	end

	insert into titlerequest_import
	values(@v_key_parent, 0, null, null, null, @v_class_code, 1, 0, @v_book1, @v_author, @v_isbn1, @v_book2, null, @v_isbn2, @v_moreinfo, 
		   @v_special, @v_refcode, getdate(), 'qsidba')


	 --If requestor = instructor and schoolphonenumber <> daytimephonenumber, set to “school”, else null
	 --if requestor = instructor and schoolphonenumber <> daytimephonenumber, set to  schoolphonenumber, else null
	 if @v_lastname = @v_lastnameInstructor and @v_firstname = @v_firstnameinstructor and @v_schoolphonenumber <> @v_daytimephone begin
		set @v_phone2_externalid = 'school'
		set @v_phone2 = @v_schoolphonenumber
	 end else begin
		set @v_phone2_externalid = null
		set @v_phone2 = null
	 end
	 --Set to “instructor” if requestor and instructor are same name; else null 
	 if @v_lastname = @v_lastnameInstructor and @v_firstname = @v_firstnameinstructor begin
		set @v_role2_externalid = 'instructor'
	end else begin
		set @v_role2_externalid = null
	end

	set @v_note = null
--	if @v_position is not null begin
--		set @v_note = 'position'
--	end

--	select @v_cnt = count(*)
--	from globalcontact_import
--	where lastname = @v_lastname
--	and firstname = @v_firstname
--
--	if @v_cnt = 0 begin

	exec get_next_key 'qsidba', @v_nextkey_child output

	insert into globalcontact_import (  globalcontactrequestkey, relatedprojectimportkey, createdate,
	                                    createfrom, processedind, processdate, processerrormessage,
	                                    orgentry1, orgentry2, orgentry3, globalcontactkey, individualind,
	                                    grouptype_externalid, lastname, firstname, groupname, middlename,
	                                    suffix, degree, accreditationcode_externalid, ssn, autodisplayind,
	                                    displayname, address_primaryind, addresstype_externalid,
                                        Addressdescription, address1, address2, address3, city,
                                        [state], zip, zip4, country, primary_email_externalid,
                                        primary_email, email2_externalid, email2, primary_phone_externalid,
                                        primary_phone, phone2_externalid, phone2, role1_externalid,
                                        role2_externalid, category1_tableid, category1_externalid,
                                        category2_tableid, category2_externalid, note, 
                                        relatedcontact_relationcode1_externalid, 
                                        relatedcontact_relationcode2_externalid,
                                        relatedcontact_individualind,
                                        relatedcontact_linktoprimaryaddressind, 
                                        relatedcontact_linktoprimaryphoneind, 
                                        relatedcontact_lastname, 
                                        relatedcontact_firstname, 
                                        relatedcontact_groupname, 
                                        relatedcontact_phone, 
                                        relatedcontact_email, 
                                        relatedcontact_notontaq_name2,
                                        relatedcontact_notontaq_addtldesc,
                                        relatedcontact2_relationcode1_externalid, 
                                        relatedcontact2_relationcode2_externalid,
                                        relatedcontact2_individualind,
                                        relatedcontact2_linktoprimaryaddressind, 
                                        relatedcontact2_linktoprimaryphoneind, 
                                        relatedcontact2_lastname, 
                                        relatedcontact2_firstname, 
                                        relatedcontact2_groupname, 
                                        relatedcontact2_phone, 
                                        relatedcontact2_email, 
                                        relatedcontact2_name2,
                                        relatedcontact2_addtldesc )
                                                                        
	values(
	@v_nextkey_child, 
	@v_key_parent,
	getdate(),
	'request spreadsheet',
	0,
	null,
	null,
	1, --I believe the org level security for contacts at UMP is the top level so we only need to put in the code for that which there should be only 1.  This needs to be verified,
	null,
	null,
	null,
	1,
	null,
	@v_lastname,
	@v_firstname,
	Null,
	Null,
	Null,
	Null,
	Null,
	Null,
	1,
	Null,
	1,
	@v_addresstype,
	null,
	@v_address1,
	@v_address2,
	Null,
	@v_city,
	@v_state,
	@v_zipcode,
	@v_zipcode4,
	@v_country,
	'work',
	@v_apparentlyfrom,
	null,
	null,
	'daytime',
	@v_daytimephone,
	@v_phone2_externalid, --phone2_externalid	Varchar	If requestor = instructor and schoolphonenumber <> daytimephonenumber, set to “school”, else null
	@v_phone2, --Varchar	if requestor = instructor and schoolphonenumber <> daytimephonenumber, set to  schoolphonenumber, else null
	'requestor',
	@v_role2_externalid, --role2_externalid	Varchar	Set to “instructor” if requestor and instructor are same name; else null 
	null, --category1_tableid	Int	
	null, --category1_externalid	Varchar	
	null, --category2_tableid	Int	
	null, --category2_externalid	Varchar	
	@v_note, --note	Varchar	If position is not null, set to “position:” position
--xxxxx
	'school',
	'requestor',
	0,
	0,
	0,
	null, --relatedcontact_lastname	Varchar	
	null, --relatedcontact_firstname	Varchar	
	@v_school,
	@v_schoolphonenumber,
	null, --relatedcontact_email	Varchar	
	@v_school,
	@v_department + '/' + @v_institutiontype, --relatedcontact_notontaq_addtldesc	Varchar	department”/”institutiontype
	null, --relatedcontact2_relationcode1_externalid	Varchar	
	null, --relatedcontact2_relationcode2_externalid	Varchar	
	null, --relatedcontact2_individualind	Tinyint	
	null, --relatedcontact2_linktoprimaryaddressind	Tinyint	
	0,
	null, --relatedcontact2_lastname	Varchar	
	null, --relatedcontact2_firstname	Varchar	
	null, --relatedcontact2_groupname	Varchar	
	null, --relatedcontact2_phone	Varchar	
	null, --relatedcontact2_email	Varchar	
	null, --relatedcontact2_notontaq_name2	Varchar	
	null --relatedcontact2_notontaq_addtldesc	Varchar	
	)
--end  

--	select @v_cnt = count(*)
--	from globalcontact_import
--	where lastname = @v_lastnameInstructor
--	and firstname = @v_firstnameinstructor

--	if @v_cnt = 0 begin

	exec get_next_key 'qsidba', @v_nextkey_child output
	if @v_lastname <> @v_lastnameInstructor and @v_firstname <> @v_firstnameinstructor begin

	insert into globalcontact_import (  globalcontactrequestkey, relatedprojectimportkey, createdate,
	                                    createfrom, processedind, processdate, processerrormessage,
	                                    orgentry1, orgentry2, orgentry3, globalcontactkey, individualind,
	                                    grouptype_externalid, lastname, firstname, groupname, middlename,
	                                    suffix, degree, accreditationcode_externalid, ssn, autodisplayind,
	                                    displayname, address_primaryind, addresstype_externalid,
                                        Addressdescription, address1, address2, address3, city,
                                        [state], zip, zip4, country, primary_email_externalid,
                                        primary_email, email2_externalid, email2, primary_phone_externalid,
                                        primary_phone, phone2_externalid, phone2, role1_externalid,
                                        role2_externalid, category1_tableid, category1_externalid,
                                        category2_tableid, category2_externalid, note, 
                                        relatedcontact_relationcode1_externalid, 
                                        relatedcontact_relationcode2_externalid,
                                        relatedcontact_individualind,
                                        relatedcontact_linktoprimaryaddressind, 
                                        relatedcontact_linktoprimaryphoneind, 
                                        relatedcontact_lastname, 
                                        relatedcontact_firstname, 
                                        relatedcontact_groupname, 
                                        relatedcontact_phone, 
                                        relatedcontact_email, 
                                        relatedcontact_notontaq_name2,
                                        relatedcontact_notontaq_addtldesc,
                                        relatedcontact2_relationcode1_externalid, 
                                        relatedcontact2_relationcode2_externalid,
                                        relatedcontact2_individualind,
                                        relatedcontact2_linktoprimaryaddressind, 
                                        relatedcontact2_linktoprimaryphoneind, 
                                        relatedcontact2_lastname, 
                                        relatedcontact2_firstname, 
                                        relatedcontact2_groupname, 
                                        relatedcontact2_phone, 
                                        relatedcontact2_email, 
                                        relatedcontact2_name2,
                                        relatedcontact2_addtldesc ) 
	values(
	@v_nextkey_child, 
	@v_key_parent,
	getdate(),
	'request spreadsheet',
	0,
	null,
	null,
	1, --Orgentry1	I believe the org level security for contacts at UMP is the top level so we only need to put in the code for that which there should be only 1.  This needs to be verified
	null, --Orgentry2	I believe this should be null
	null, --Orgentry3	I believe this should be null
	null, --globalcontactkey	The global contact key that is setup for this request; null initially
	--null, --Projectkey	The projectkey that is setup for this request; null initially
	1, --Individualind	Set to 1
	null, --Grouptype_externalid	
	@v_lastnameInstructor, --lastname	lastnameInstructor
	@v_firstnameinstructor, --firstname	firstnameInstructor
	null, --groupname	
	null, --middlename	
	null, --suffix	
	null, --degree	
	null, --accreditationcode_externalid
	null, --ssn	
	1, --Autodisplayind	Set to 1
	Null, --displayname
	1, --address_primaryind	Set to 1
	@v_addresstype, --	addresstype (repeat requestor info for instructor/requested for  address fields)
	null, --addressdescription
	@v_address1, --address1
	@v_address2, --address2
	null, --address3
	@v_city, --	City
	@v_state, -- State
	@v_zipcode, --Zipcode
	@v_zipcode4, --zipcode4
	@v_country, --Country
	'work', --Set to “work”
	@v_emailInstructor, --emailInstructor
	null, --email2_externalid
	null, --email2
	'school', --primary_phone_externalid		Set to “school”
	@v_schoolphonenumber, --schoolphonenumber
	null, --phone2_externalid
	null, --phone2
	'instructor', --role1_externalid Set to “instructor” 
	null, --role2_externalid		
	null, --category1_tableid		
	null, --category1_externalid		
	null, --category2_tableid		
	null, --category2_externalid		
	null, --note		
	'requestor', --relatedcontact_relationcode1_externalid		Set to “instructor”
	'instructor', --Set to “requestor”
	1, --Set to 1
	0, --Set to 0
	0, --Set to 0
	@v_lastname, 
	@v_firstname,
	null, 
	@v_daytimephone,
	@v_apparentlyfrom,
	null, --relatedcontact_name2		
	null, --relatedcontact_addtldesc		
	'school', --relatedcontact2_relationcode1_externalid	Set to “professor”
	'instructor', --relatedcontact2_relationcode2_externalid		Set to “school”
	0, --relatedcontact2_individualind		Set to 0
	0, --relatedcontact2_linktoprimaryaddressind		0
	0, --relatedcontact2_linktoprimaryphoneind		Set to 0
	null, --relatedcontact2_lastname		
	null, --relatedcontact2_firstname		
	@v_school, --relatedcontact2_groupname		school
	@v_schoolphonenumber, --relatedcontact2_phone		schoolphonenumber
	null, --relatedcontact2_email		
	@v_school, --relatedcontact2_name2		School
	@v_department + '/' + @v_institutiontype  --relatedcontact2_addtldesc		department”/”institutiontype
)
--end 
end 



--xxxxx
exec get_next_key 'qsidba', @v_nextkey output
set @v_Projectname = @v_lastname + '/' + IsNull(substring(@v_book1,1, 30), '') + '/' + CONVERT(VARCHAR(8), GETDATE(), 10) 

set @v_usageclas = null
if @v_class = 'DSK' begin set @v_usageclas = 13 end
if @v_class = 'EXM' begin set @v_usageclas = 18 end

set @v_Projecttype_externalid = @v_division + @v_class
if @v_division = 'UMP' begin set @v_Orgentry2 = 3 end
if @v_division = 'ESL' begin set @v_Orgentry2 = 5 end

if @v_division = 'UMP' begin set @v_Orgentry3 = 4 end
if @v_division = 'ESL' begin set @v_Orgentry3 = 6 end


insert into project_import
values(
@v_key_parent,
0,
null,
null,
null,
@v_Projectname, --	Varchar	Set to <lastname>”/”<book1> today’s date
null,	--Varchar	Set to null (we will get this from the template)
3,	--Int	Set to 3 (Project)
@v_usageclas,  --if DSK in class column, set to desk; set to exam if EXM
@v_Projecttype_externalid, --Varchar Set to esldesk, umpdesk, eslexam or esldesk depending on the division and class columns 
'pending', 	--Varchar	Set to pending
1,	--Tinyint	Set to 1
1,	--Int	Set to 1 (University of Michigan)
@v_Orgentry2, 	--Int	Set to 3 if UMP, 5 if ESL
@v_Orgentry3,	--Int	Set to 4 if UMP, 6 if ESL
null,	
null,	
null,	
null,	
null,	
null,	
null,	
null,	
null,	
null,	
null,	
null,	
'furtherinfo',	--Varchar	Set to “furtherinfo”
@v_Moreinfo, 	--Text	Moreinfo
'special',	--Varchar	Set to “special”
@v_special, --Text	special
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
'createdate', --Task1_externalid	Varchar	Set to “createdate”
getdate(), --Task1_date	Datetime	Set to today’s date
1, --Task1_actualind	tinint	Set to 1
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
getdate(), --Lastmaintdate	Datetime	Today’s date
'spreadsheet_import', --Lastmaintuser	Varchar	?  - something to indicate import from spreadheet
getdate(),
'spreadsheet_import'
)




if @v_reqtextopt is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'reqtextopt',null, 0, null, null, @v_reqtextopt)
end
if @v_currenttext1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'currenttext1',null, 0, null, null, @v_currenttext1)
end

if @v_coursenumber is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'coursenumber',null, 0, null, null, @v_coursenumber)
end 
if @v_coursetitle1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'coursetitle1',null, 0, null, null, @v_coursetitle1)
end
if @v_studentlevel1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'studentlevel1',null, 0, null, null, @v_studentlevel1)
end
if @v_startmonth1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'startmonth1',null, 0, null, null, @v_startmonth1)
end
if @v_startyear1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'startyear1',null, 0, null, null, @v_startyear1)
end
if @v_adoptiondate1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'adoptiondate1',null, 0, null, null, @v_adoptiondate1)
end
if @v_enrollment1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'enrollment1','enrollment1txt', 0, null, null, @v_enrollment1)
end
if @v_syllabus1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'syllabus1',null, 0, null, null, @v_syllabus1)
end
if @v_Bookstore is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'Bookstore',null, 0, null, null, @v_Bookstore)
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
	values(@v_key_parent,  'studentlevel2',null, 0, null, null, @v_studentlevel2)
end
if @v_startmonth2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'startmonth2',null, 0, null, null, @v_startmonth2)
end
if @v_startyear2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent,  'startyear2',null, 0, null, null, @v_startyear2)
end
if @v_adoptiondate2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent,  'adoptiondate2',null, 0, null, null, @v_adoptiondate2)
end
if @v_enrollment2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'enrollment2', 'enrollment2txt', 0, null, null, @v_enrollment2)
end
if @v_syllabus2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent,'syllabus2',null, 0, null, null, @v_syllabus2)
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
if @v_Division is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'division',null, 0, null, null, @v_Division)
end
if @v_book1 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'book1',null, 0, null, null, @v_book1)
end
if @v_Author is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'author',null, 0, null, null, @v_Author)
end
if @v_Author2 is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'author2',null, 0, null, null, @v_Author2)
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

set @v_refcode = REPLACE ( @v_refcode , char(9) , '' )
set @v_refcode = ltrim(rtrim(@v_refcode))
if @v_refcode = '' begin
	set @v_refcode = null
end

if @v_refcode is not null begin
	insert into project_import_miscitem
	values(@v_key_parent, 'refcode',null, 0, null, null, @v_refcode)
end










  FETCH c_import INTO	@v_division,@v_class,@v_lastname,@v_firstname,@v_addresstype,@v_address1,@v_address2,@v_city,@v_state,@v_zipcode,
						@v_zipcode4,@v_Country,@v_apparentlyfrom,@v_daytimephone,@v_school,@v_institutiontype,@v_department,@v_lastnameInstructor,
						@v_firstnameInstructor,@v_schoolphonenumber,@v_emailInstructor,@v_book1,@v_author,@v_isbn1,@v_reqtextopt,@v_currenttext1,
						@v_coursenumber,@v_coursetitle1,@v_studentlevel1,@v_startmonth1,@v_startyear1,@v_adoptiondate1,@v_enrollment1,@v_syllabus1,
						@v_bookstore,@v_book2,@v_author2, @v_isbn2,@v_currenttext2,@v_coursetitle2,@v_studentlevel2,@v_startmonth2,@v_startyear2,@v_adoptiondate2,
						@v_enrollment2,@v_syllabus2,@v_moreinfo,@v_special,@v_refcode









end
  CLOSE c_import
  DEALLOCATE c_import
--
end
go
