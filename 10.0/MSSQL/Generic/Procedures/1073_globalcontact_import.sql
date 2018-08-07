SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.globalcontact_import_sp') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.globalcontact_import_sp
end
go

/******************************************************************************
**    Change History
*******************************************************************************
**  Date        Who      Change
**  ----------  -------  ------------------------------------------------------
**  10/11/2017  Colman   Case 47714 - Purge SSN references
*******************************************************************************/

CREATE PROCEDURE [dbo].globalcontact_import_sp (@i_globalcontactrequestkey int, 
                                                @i_newglobalcontactkey int output, 
                                                @v_retcode int output, 
                                                @v_message varchar(8000) output, 
                                                @v_taqprojectcontact_addresskey int output)
AS

BEGIN 
DECLARE
@v_note varchar(200),  
@v_filterorglevelkey int,
@v_import_zip varchar(100),
@v_datacode1_1 int,
@v_datacode2_2 int,
@v_cariadgereturn varchar(10),
@v_errind tinyint,
@v_accreditation_desc varchar(30),
@v_corporate_contributor char(1),
@v_globalcontacthistorykey int,
@v_individualind tinyint,
@v_datacode_state varchar(30),
@v_datacode_country varchar(30),
@v_datacode_addresstype varchar(30),
@v_relatedcontactkey2 int,
@v_relatedcontact_lastname varchar(100),
@v_relatedcontact_firstname varchar(100),
@v_relatedcontact_groupname varchar(100),
@v_relatedcontact_notontaq_addtldesc varchar(100),
@v_relatedcontact2_relationcode1_externalid varchar(100),
@v_relatedcontact2_relationcode2_externalid varchar(100),
@v_relatedcontact2_lastname varchar(100),
@v_relatedcontact2_firstname varchar(100),
@v_relatedcontact2_groupname varchar(100),
@v_relatedcontact_notontaq_name2 varchar(100),
@v_globalcontactmeth_prim int,
@v_relatedcontact_linktoprimaryphoneind tinyint,
@v_relatedcontact2_linktoprimaryphoneind tinyint,
@v_relatedcontact_linktoprimaryaddressind tinyint,
@v_relatedcontact2_linktoprimaryaddressind tinyint,
@v_globalcontactkey_import int,
@v_firstname varchar(100),
@v_globalcontactaddress_prim int,
@v_globalcontactaddress2_prim int,
@v_lastname varchar(100),
@v_groupname varchar(100),
@v_relatedcontact_relationcode1_externalid varchar(30),
@v_relatedcontact_relationcode2_externalid varchar(30),
@v_datasub2code int,
@v_displayname varchar(100),
@v_category1_tableid int,
@v_category2_tableid int,
@v_category1_externalid varchar(30),
@v_category2_externalid varchar(30),
@v_role1_externalid varchar(30),
@v_role2_externalid varchar(30),
@v_primary_phone varchar(50),
@v_phone2 varchar(50),
@v_sortorder int,
@v_email2 varchar(100),
@v_contactmethodvalue varchar(100),
@v_globalcontactmethodkey int,
@v_primary_email varchar(100),
@v_datasubcode int,
@v_datadesc_previous varchar(50),
@v_desc_country varchar(50),
@v_desc_state varchar(50),
@v_globalcontactnotes varchar(8000),
@v_datadesc_prim varchar(100),
@v_datadesc varchar(100),
@v_globalcontactaddresskey int,
@v_datacode varchar(30),
@v_accreditationcode_globalcontact varchar(30),
@v_accreditationcode_import varchar(30),
@v_globalcontactaddresskey_primary int,
@v_cnt1 int,
@v_cnt2 int,
@v_global_contactkey_match int,
@i_newglobalcontactaddresskey int,					 
@i_newglobalcontactaddresskey_relatedlink1 int,		 
@i_newglobalcontactaddresskey_related2link1 int	,	 
@i_globalcontactmethodkey_email1 int,				 
@i_globalcontactmethodkey_email2 int,				 
@i_globalcontactmethodkey_phone1 int,				 
@i_globalcontactmethodkey_phone2 int,				 
@i_globalcontactmethodkey_phone1_relatedlink int,	 
@i_globalcontactmethodkey_phone1_related2link int,    
@i_globalcontactrelationshipkey1 int,				 
@i_globalcontactrelationshipkey2 int,				 
@i_globalcontactkey_related1 int,					 
@i_globalcontactkey_related2 int,					 
@i_globalcontact_related1_code1 int,					 
@i_globalcontact_related1_code2 int,				 
@i_globalcontact_related2_code1 int,					 
@i_globalcontact_related2_code2 int,	
@i_globalcontactmethodkey_addtl1 int,				 
@i_globalcontactmethodkey_addtl2 int,				 
@i_globalcontactmethodkey_addtl3 int,				 
@i_globalcontactmethodkey_addtl4 int,				 
@i_globalcontactmethodkey_addtl5 int,				 	 
@i_externalcode varchar(30),
@i_externalcode_addresstype	 varchar(30),
@i_externalcode_state varchar(30),
@i_externalcode_country	 varchar(30),				 
@i_validexternalcode int,							 
@i_categorytableid int,							     
@v_cnt int,
@v_individual int,
@v_addressdescription  varchar(500),
@v_address1 varchar(100), 
@v_address2 varchar(100),
@v_address3 varchar(100),
@v_city varchar(50),
@v_state varchar(50),
@v_zip varchar(20),
@v_zip4 varchar(20), 
@v_country varchar(100),
@v_address_primaryind int,
@v_relatedcontact_phone varchar(50),
@v_relatedcontact_email varchar(100),
@v_relatedcontact2_phone varchar(50),
@v_relatedcontact2_email varchar(100),
@v_datacode1 int,
@v_datacode2 int,
@v_relatedcontactkey int,
@v_lastname_import varchar(100),  
@v_firstname_import varchar(100),  
@v_groupname_import varchar(50),  
@v_middlename_import varchar(50),  
@v_suffix_import varchar(50),  
@v_degree_import varchar(100),
@v_date varchar(12),
@v_firstname_orig varchar(100),
@v_lastname_orig varchar(100),
@v_middlename_orig varchar(100),
@v_optionvalue int,
@v_orgentry1 int,
@v_orgentry2 int,
@v_orgentry3 int,
@v_contact_method_externalid1 varchar(30),
@v_contact_method_value1 varchar(255),
@v_contact_method_externalid2 varchar(30),
@v_contact_method_value2 varchar(255),
@v_contact_method_externalid3 varchar(30),
@v_contact_method_value3 varchar(255),
@v_contact_method_externalid4 varchar(30),
@v_contact_method_value4 varchar(255),
@v_contact_method_externalid5 varchar(30),
@v_contact_method_value5 varchar(255),
@v_role3_externalid varchar(30),
@v_role4_externalid varchar(30),
@v_role5_externalid varchar(30),
@v_category3_tableid int,
@v_category3_externalid varchar(30),
@v_category4_tableid int,
@v_category4_externalid varchar(30),
@v_category5_tableid int,
@v_category5_externalid varchar(30),
@v_primaryind int	

set @v_date = convert(varchar(30),getdate(), 100)						 

set @v_individual = 0
set @v_sortorder = 0
set @v_errind = 0
set @v_cariadgereturn = '
'
select @v_optionvalue = optionvalue
from clientoptions 
where optionid = 52

/*****************************************************************************************************************
 Load data from the imported data table indicated by the row containing the matching globalcontactrequestkey
******************************************************************************************************************/

select @v_primary_email = primary_email, @v_email2 = email2, @v_primary_phone = primary_phone, 
	   @v_phone2 = phone2, @v_role1_externalid = role1_externalid, @v_role2_externalid = role2_externalid, 
	   @v_category1_externalid = category1_externalid, @v_category2_externalid = category2_externalid,
	   @v_category1_tableid = category1_tableid, @v_category2_tableid = category2_tableid,
	   @v_relatedcontact_relationcode1_externalid = relatedcontact_relationcode1_externalid, 
	   @v_relatedcontact_relationcode2_externalid = relatedcontact_relationcode2_externalid,
	   @v_globalcontactkey_import = globalcontactkey, @v_relatedcontact_phone = relatedcontact_phone,
	   @v_relatedcontact_email = relatedcontact_email, @v_relatedcontact_linktoprimaryaddressind = relatedcontact_linktoprimaryaddressind,
	   @v_relatedcontact2_linktoprimaryaddressind = relatedcontact2_linktoprimaryaddressind,
	   @v_relatedcontact_linktoprimaryphoneind  = relatedcontact_linktoprimaryphoneind ,
	   @v_relatedcontact2_linktoprimaryphoneind  = relatedcontact2_linktoprimaryphoneind ,
	   @v_relatedcontact_notontaq_name2 = relatedcontact_notontaq_name2,
	   @v_relatedcontact_notontaq_addtldesc = relatedcontact_notontaq_addtldesc,
	   @v_relatedcontact_lastname = relatedcontact_lastname,
	   @v_relatedcontact_firstname = relatedcontact_firstname,
	   @v_relatedcontact_groupname = relatedcontact_groupname,
	   @v_relatedcontact2_lastname = relatedcontact2_lastname,
	   @v_relatedcontact2_firstname = relatedcontact2_firstname,
	   @v_relatedcontact2_groupname = relatedcontact2_groupname,
	   @v_relatedcontact2_phone = relatedcontact2_phone,
	   @v_relatedcontact2_email = relatedcontact2_email,
	   @v_lastname_import = lastname,
	   @v_firstname_import = firstname,
	   @v_groupname_import = groupname,
	   @v_middlename_import = middlename,
	   @v_suffix_import = suffix,
	   @v_degree_import = degree,
	   @v_individualind = individualind,
	   @v_displayname = displayname,
	   @v_relatedcontact2_relationcode1_externalid = relatedcontact2_relationcode1_externalid,
	   @v_relatedcontact2_relationcode2_externalid = relatedcontact2_relationcode2_externalid,
	   @v_note = note, @v_orgentry1 = orgentry1, @v_orgentry2 = orgentry2, @v_orgentry3 = orgentry3,
	   @v_contact_method_externalid1 = contact_method_externalid1, @v_contact_method_value1 = contact_method_value1,
	   @v_contact_method_externalid2 = contact_method_externalid2, @v_contact_method_value2 = contact_method_value2,
	   @v_contact_method_externalid3 = contact_method_externalid3, @v_contact_method_value3 = contact_method_value3,
	   @v_contact_method_externalid4 = contact_method_externalid4, @v_contact_method_value4 = contact_method_value4,
	   @v_contact_method_externalid5 = contact_method_externalid5, @v_contact_method_value5 = contact_method_value5,
	   @v_role3_externalid = role3_externalid, @v_role4_externalid = role4_externalid, @v_role5_externalid = role5_externalid,
       @v_category3_tableid = category3_tableid, @v_category3_externalid = category3_externalid,
       @v_category4_tableid = category4_tableid, @v_category4_externalid = category4_externalid,
       @v_category5_tableid = category5_tableid, @v_category5_externalid = category5_externalid

from globalcontact_import
where globalcontactrequestkey = @i_globalcontactrequestkey		

/*****************************************************************************************************************
    Begin validation processing. Check org entries.
******************************************************************************************************************/

    set @v_filterorglevelkey = null
    select @v_filterorglevelkey = filterorglevelkey 
    from filterorglevel where filterkey = 7
    if @v_filterorglevelkey = 1 begin
	    select @v_cnt = count(*)
	    from globalcontact_import
	    where orgentry1 is not null
	    and globalcontactrequestkey = @i_globalcontactrequestkey
    end
    if @v_filterorglevelkey = 2 begin
	    select @v_cnt = count(*)
	    from globalcontact_import
	    where orgentry1 is not null
	    and orgentry2 is not null
	    and globalcontactrequestkey = @i_globalcontactrequestkey
    end
    if @v_filterorglevelkey = 3 begin
	    select @v_cnt = count(*)
	    from globalcontact_import
	    where orgentry1 is not null
	    and orgentry2 is not null
	    and orgentry3 is not null
	    and globalcontactrequestkey = @i_globalcontactrequestkey
    end

    if @v_cnt = 0 begin
	    set @v_message = @v_message + ' Contact cannot be added due to orgentry(s) are missing.'
	    update globalcontact_import
	    set processerrormessage = @v_message,
		    Processdate = getdate(),
		    processedind = 2
	    where globalcontactrequestkey = @i_globalcontactrequestkey
	    return
    end

/*****************************************************************************************************************
    Check if required last and first name is there
******************************************************************************************************************/

    Select @v_cnt = count(*) 
    from globalcontact_import 
    where individualind = 1
    and globalcontactrequestkey = @i_globalcontactrequestkey

    if @v_cnt > 0 
    begin
	    set @v_individual = 1
	    select @v_cnt = count(*)
	    from globalcontact_import
	    where lastname is not null
	    and firstname is not null
	    and globalcontactrequestkey = @i_globalcontactrequestkey

	    if @v_cnt = 0 
	    begin
		    set @v_message = @v_message + ' Contact cannot be added due to last or first name is missing.'
		    update globalcontact_import
		    set processerrormessage = @v_message,
			    Processdate = getdate(),
			    processedind = 2
		    where globalcontactrequestkey = @i_globalcontactrequestkey
		    return
	    end	
    end 
    else 
    begin
	    select @v_cnt = count(*)
	    from globalcontact_import
	    where groupname is not null
	    and globalcontactrequestkey = @i_globalcontactrequestkey

	    if @v_cnt = 0 
	    begin
		    set @v_message = @v_message + ' Contact cannot be added due to groupname is missing.'
		    update globalcontact_import
		    set processerrormessage = @v_message,
			    Processdate = getdate(),
			    processedind = 2
		    where globalcontactrequestkey = @i_globalcontactrequestkey
		    return
	    end
    end	
		
			--chekc if contact exists on globalcontact 
    set @v_global_contactkey_match = null

    -- match first, last or group name
    if @v_individual = 1 begin
	    select @v_global_contactkey_match = globalcontactkey
	    from globalcontact
	    where lastname in(select lastname from globalcontact_import where globalcontactrequestkey = @i_globalcontactrequestkey)
	    and firstname  in(select firstname from globalcontact_import where globalcontactrequestkey = @i_globalcontactrequestkey)
    end else begin
	    select @v_global_contactkey_match = globalcontactkey
	    from globalcontact
	    where groupname in(select groupname from globalcontact_import where globalcontactrequestkey = @i_globalcontactrequestkey)
    end
			
/*****************************************************************************************************************
		--if there is a match on last and first name check if they have same emails or phone numbers 
		--no phones or emails is considered as match
******************************************************************************************************************/

    IF @v_global_contactkey_match > 0 
    BEGIN
        select @v_firstname_orig = firstname, @v_lastname_orig = lastname, @v_middlename_orig = middlename
        from globalcontact 
        where globalcontactkey = @v_global_contactkey_match

        if @v_note is not null 
        begin
	        update globalcontact
	        set globalcontactnotes  = (select isNull(globalcontactnotes, '') + @v_note + @v_cariadgereturn
							           from globalcontact
							           where globalcontactkey = @v_global_contactkey_match) 
	        where globalcontactkey = @v_global_contactkey_match
        end

		if exists (select * from globalcontactmethod where contactmethodcode in(3) and globalcontactkey = @v_global_contactkey_match)
		begin
	        if not exists (select *
				             from globalcontactmethod
				            where contactmethodcode = 3
				            and globalcontactkey = @v_global_contactkey_match
				            and (contactmethodvalue in (select primary_email from globalcontact_import where globalcontactrequestkey = @i_globalcontactrequestkey)
					         or (contactmethodvalue in (select email2 from globalcontact_import where globalcontactrequestkey = @i_globalcontactrequestkey))))
			begin
                update globalcontact
                set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact found with same last name/first name but different phone.' + @v_cariadgereturn
				                           from globalcontact
				                           where globalcontactkey = @v_global_contactkey_match) 
                where globalcontactkey = @v_global_contactkey_match
                set @v_errind = 1
			end
				
            if exists (select *	from globalcontactmethod where contactmethodcode in(1) and globalcontactkey = @v_global_contactkey_match)
			begin
                if not exists (select *
                                 from globalcontactmethod
                                where contactmethodcode = 1
                                  and globalcontactkey = @v_global_contactkey_match
                                  and (contactmethodvalue in (select primary_phone from globalcontact_import where globalcontactrequestkey = @i_globalcontactrequestkey)
                                   or (contactmethodvalue in (select phone2 from globalcontact_import where globalcontactrequestkey = @i_globalcontactrequestkey))))
				begin
                    update globalcontact
                    set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact found with same last name/first name but different email.' + @v_cariadgereturn
					                           from globalcontact
					                           where globalcontactkey = @v_global_contactkey_match) 
                    where globalcontactkey = @v_global_contactkey_match
                    set @v_errind = 1
				end
            end
        end
    END	

--############################################################################################
-- UPDATE GLOBALCONTACT AND GLOBALCONTACTADDRESS
--############################################################################################	
	
    IF @v_global_contactkey_match > 0 
    BEGIN
				select @v_taqprojectcontact_addresskey = globalcontactaddresskey
				from globalcontactaddress 
				where globalcontactkey = @v_global_contactkey_match
				and primaryind = 1

				if @v_individual = 0 begin
					set @i_externalcode = 0
					Select @i_externalcode = Grouptype_externalid
					from globalcontact_import 
					where globalcontactrequestkey = @i_globalcontactrequestkey
					exec dbo.get_gentables_externalcode_datacode 520, @i_externalcode, @v_datacode OUTPUT 

					--update group type
					if @v_datacode > 0 begin
						update globalcontact
						set grouptypecode = @v_datacode
					    where globalcontactkey = @v_global_contactkey_match
					end
				end 

					set @i_externalcode = 0
					Select @i_externalcode = accreditationcode_externalid
					from globalcontact_import 
					where globalcontactrequestkey = @i_globalcontactrequestkey

					exec dbo.get_gentables_externalcode_datacode  210,  @i_externalcode, @v_datacode OUTPUT 
					--update accreditation
					If @v_datacode > 0 begin	
						select @v_accreditationcode_globalcontact = accreditationcode
						from globalcontact
						where globalcontactkey = @v_global_contactkey_match
	
						set @v_accreditationcode_import = @v_datacode
												
						if @v_accreditationcode_import is not null begin
							update globalcontact
							set accreditationcode = @v_accreditationcode_import
							where globalcontactkey = @v_global_contactkey_match
						end
						if @v_accreditationcode_import <> @v_accreditationcode_globalcontact and @v_accreditationcode_globalcontact is not null and @v_accreditationcode_import is not null begin
							update globalcontact
							set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Replaced old accreditationcode ' +  @v_accreditationcode_globalcontact + ' with new ' + @v_accreditationcode_import + @v_cariadgereturn
													   from globalcontact
													   where globalcontactkey = @v_global_contactkey_match) 
							where globalcontactkey = @v_global_contactkey_match
							set @v_errind = 1
							
						end
					end


					if @v_displayname is Null or ltrim(rtrim(@v_displayname)) = ''  begin
						  if @v_optionvalue = 1 begin
								exec globalcontact_displayname 
												@v_individualind,  
												@v_lastname_import, 
												@v_firstname_import, 
												@v_middlename_import,
												@v_suffix_import,
												@v_degree_import,
												@v_displayname output ,
												0,
												''
								update globalcontact
								set displayname = @v_displayname
								where globalcontactkey = @v_global_contactkey_match
						end 
					end

					if @v_displayname is not Null begin
						update globalcontact
						set displayname = @v_displayname
						where globalcontactkey = @v_global_contactkey_match
					end


					if @v_individual = 1 begin

					update globalcontact
					set suffix = @v_suffix_import, degree = @v_degree_import, middlename = @v_middlename_import
					where globalcontactkey = @v_global_contactkey_match

				end

				set @i_externalcode = 0
				Select @i_externalcode = addresstype_externalid
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey
				exec dbo.get_gentables_externalcode_datacode  207, @i_externalcode, @v_datacode OUTPUT 

				-- Check to see if this addresstype exists. 

				if @v_datacode > 0 begin
					select @v_cnt = count(*)
					from globalcontactaddress
					where addresstypecode = @v_datacode
					and globalcontactkey = @v_global_contactkey_match

					--Check to see if the import address is the same as the existing address for this type by comparing addressdescription, 
					--address1, address2, address3, city, statecode, zip and country.
					if @v_cnt > 0 begin
						if  exists (
							select address1, address2, address3, city, state, rtrim(zip), country
							from globalcontact_import
							where address1 in(select address1 
												from globalcontactaddress 
												where globalcontactkey = @v_global_contactkey_match 
												and addresstypecode = @v_datacode)
							and (address2 in(select address2 
											from globalcontactaddress 
											where globalcontactkey = @v_global_contactkey_match 
											and addresstypecode = @v_datacode)  or address2 is null)
							and (address3 in(select address3 
											from globalcontactaddress 
											where globalcontactkey = @v_global_contactkey_match 
											and addresstypecode = @v_datacode)  or address3 is null)
							and (city in(select city 
										from globalcontactaddress 
										where globalcontactkey = @v_global_contactkey_match 
										and addresstypecode = @v_datacode)or city is null)
							and (state in(select externalcode 
										from gentables, globalcontactaddress 
										where tableid = 160 
										and globalcontactkey = @v_global_contactkey_match 
										and addresstypecode = @v_datacode 
										and globalcontactaddress.statecode = gentables.datacode) or state is null)
							and (rtrim(zip) in(select zipcode 
										from globalcontactaddress 
										where globalcontactkey = @v_global_contactkey_match 
										and addresstypecode = @v_datacode) or zip is null)
							and (country in(select externalcode 
											from gentables, globalcontactaddress 
											where tableid = 114 
											and globalcontactkey = @v_global_contactkey_match 
											and addresstypecode = @v_datacode 
											and globalcontactaddress.countrycode = gentables.datacode) or country is null)
							and globalcontactrequestkey = @i_globalcontactrequestkey
							)
						   
						begin

							--If they are the same,	check to see if the address_primaryind = 1
							set @v_cnt = 0
							select @v_cnt = address_primaryind
							from globalcontact_import
							where globalcontactrequestkey = @i_globalcontactrequestkey
							and address_primaryind = 1

							select @v_globalcontactaddresskey = globalcontactaddresskey
							from globalcontactaddress
							where primaryind = 1
							and globalcontactkey = @v_global_contactkey_match 



							-- if not Find the contactaddresstype record with primaryind=1. Set the primaryind on that record to 0
							-- Set the primaryind on the record matching import to 1 and append notes
							if @v_cnt <> 1 begin
								if @v_globalcontactaddresskey > 0 begin
									update globalcontactaddres 
									set primaryind = 0 
									where globalcontactaddresskey = @v_globalcontactaddresskey
									

									select @v_datadesc = datadesc
									from gentables 
									where tableid = 207
									and datacode = @v_datacode

									select @v_datadesc_prim = datadesc
									from gentables, globalcontactaddres
									where tableid = 207
									and globalcontactaddresskey = @v_globalcontactaddresskey
									and globalcontactaddres.addresstypecode = gentables.datacode

									update globalcontact
									set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import changed primary address from ' + @v_datadesc + ' for previous primary to ' + @v_datadesc_prim + ' for import.' + @v_cariadgereturn
															   from globalcontact
															   where globalcontactkey = @v_global_contactkey_match) 
									where globalcontactkey = @v_global_contactkey_match

									update globalcontactaddres 
									set primaryind = 1
									where globalcontactkey = @v_global_contactkey_match 
									and addresstypecode = @v_datacode 
									set @v_errind = 1
								end
							end 
						--import address is different then existing address check linkaddresskey
						end else begin
							select @v_cnt = count(*)
							from globalcontactaddress
							where globalcontactaddresskey = @v_globalcontactaddresskey
							and linkaddresskey = 1

							--if is 1 append notes
							if @v_cnt = 1 begin
								update globalcontact
								set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import tried to change a linked address.  This is not allowed.' + @v_cariadgereturn
														   from globalcontact
														   where globalcontactkey = @v_global_contactkey_match) 
								where globalcontactkey = @v_global_contactkey_match
								set @v_errind = 1

							-- if is not 1 Update the existing record for non null fields
							end else begin

							select @v_globalcontactaddresskey = globalcontactaddresskey
							from globalcontactaddress
							where primaryind = 1
							and globalcontactkey = @v_global_contactkey_match 

								
								select @v_import_zip = isNull(zip, '') + '-' + IsNull(zip4, '')
								from globalcontact_import
								where globalcontactrequestkey = @i_globalcontactrequestkey

								if datalength(@v_import_zip) > 10 begin
									update globalcontact
									set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Zip code ' + @v_import_zip + ' has been trimmed.' + @v_cariadgereturn
															   from globalcontact
															   where globalcontactkey = @v_global_contactkey_match) 
									where globalcontactkey = @v_global_contactkey_match
								end


								select @v_addressdescription = addressdescription, @v_address1 = address1, @v_address2 = address2, @v_address3 = address3, @v_city = city, @v_state = state, @v_zip = substring(rtrim(Zip), 1,5), @v_zip4 = substring(rtrim(zip4),1,4), @v_country = country, @v_address_primaryind = address_primaryind
								from globalcontact_import
								where globalcontactrequestkey = @i_globalcontactrequestkey

								if @v_address1 is not null begin
									update globalcontactaddress
									set address1 = substring(@v_address1, 1, 255)
									where globalcontactaddresskey = @v_globalcontactaddresskey 
									
								end
								if @v_address2 is not null begin
									update globalcontactaddress
									set address2 = substring(@v_address2, 1, 255)
									where globalcontactaddresskey = @v_globalcontactaddresskey 
									
								end
								if @v_address3 is not null begin
									update globalcontactaddress
									set address3 = substring(@v_address3, 1, 255)
									where globalcontactaddresskey = @v_globalcontactaddresskey 
									
								end
								if @v_city is not null begin
									update globalcontactaddress
									set city = substring(@v_city, 1, 25)
									where globalcontactaddresskey = @v_globalcontactaddresskey 
									
								end
								if @v_state is not null begin
									update globalcontactaddress
									set statecode = (select datacode 
												from gentables 
												where tableid = 160
												and datadesc = @v_state)
									where globalcontactaddresskey = @v_globalcontactaddresskey 
									
								end
								if @v_zip is not null begin
									update globalcontactaddress
									set zipcode = rtrim(@v_zip) + '-' + isNull(rtrim(@v_zip4), '')
									where globalcontactaddresskey = @v_globalcontactaddresskey 
									
								end
								if @v_country is not null begin
									update globalcontactaddress
									set countrycode = (select datacode
													   from gentables   
													   where tableid = 114
													   and externalcode = @v_country)
									where globalcontactaddresskey = @v_globalcontactaddresskey 
								end

								
								--update notes 
--								select @v_desc_state = datadesc
--								from globalcontactaddress, gentables
--								where globalcontactaddresskey = 2913091
--								and datacode = statecode
--								and tableid = 160
--
--								select @v_desc_country = datadesc
--								from globalcontactaddress, gentables
--								where globalcontactaddresskey = 2913091
--								and datacode = countrycode
--								and tableid = 114
--																
--								select @v_addressdescription =  + 'Old address was ' + isNull(address1, '') + ' ' +  isNull(address2, '') + ' ' +  isNull(address3, '') + ' ' +  
--								isNull(city, '') + ' ' +  isNull(@v_desc_state, '') + ' ' +  isNull(zipcode, '') + ' ' +  isNull(@v_desc_country, '') 
--								FROM globalcontactaddress 
--								where globalcontactaddresskey = @v_globalcontactaddresskey
--
--								update globalcontact
--								set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' ' + @v_addressdescription
--															from globalcontact
--															where globalcontactkey = @v_global_contactkey_match) 
--								where globalcontactkey = @v_global_contactkey_match
								


								--Set the primaryind on that record to 0
								--Set the primaryind on the record matching import to 1
								if @v_address_primaryind <> 1 begin
									select @v_globalcontactaddresskey_primary = globalcontactaddresskey
									from globalcontactaddress
									where  globalcontactkey = @v_global_contactkey_match 
									and primaryind = 1
								
									update globalcontactaddress
									set primaryind = 0
									where globalcontactaddresskey = @v_globalcontactaddresskey_primary
									

									update globalcontactaddress
									set primaryind = 1
									where globalcontactaddresskey = @v_globalcontactaddresskey
									
									
									set @i_externalcode = 0
									Select @i_externalcode = addresstype_externalid
									from globalcontact_import 
									where globalcontactrequestkey = @i_globalcontactrequestkey
									exec dbo.get_gentables_externalcode_datacode  207, @i_externalcode, @v_datacode OUTPUT 

									select @v_datadesc = datadesc
									from gentables 
									where tableid = 207
									and datacode = @v_datacode

									select @v_datadesc_previous =  datadesc
									from gentables 
									where tableid = 207
									and datacode in (select addresstypecode from globalcontactaddress where globalcontactaddresskey = @v_globalcontactaddresskey_primary)
									
									update globalcontact
									set globalcontactnotes  = (select isNull(globalcontactnotes, '') + 'Import changed primary address from ' + @v_datadesc_previous + ' to ' + @v_datadesc + @v_cariadgereturn
															   from globalcontact
															   where globalcontactkey = @v_global_contactkey_match) 
									where globalcontactkey = @v_global_contactkey_match
									set @v_errind = 1
									
								end
							end
						end					
					end else begin --if addresstype doesnt' exists create row. 

				set @i_externalcode_addresstype  = 0
				Select @i_externalcode_addresstype = addresstype_externalid
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey
				exec dbo.get_gentables_externalcode_datacode  207, @i_externalcode_addresstype, @v_datacode_addresstype OUTPUT 

				set @i_externalcode_state = 0
				Select @i_externalcode_state = state
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey
				exec dbo.get_gentables_externalcode_datacode  160, @i_externalcode_state, @v_datacode_state OUTPUT 

				set @i_externalcode_country = 0
				Select @i_externalcode_country = country
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey
				exec dbo.get_gentables_externalcode_datacode  114, @i_externalcode_country, @v_datacode_country OUTPUT 

				if @v_datacode_addresstype > 0 begin
					exec get_next_key 'qsidba', @i_newglobalcontactaddresskey output

					set @v_import_zip = ''
					select @v_import_zip = isNull(zip, '') + '-' + IsNull(zip4, '')
					from globalcontact_import
					where globalcontactrequestkey = @i_globalcontactrequestkey 

					if datalength(@v_import_zip) > 10 begin
						update globalcontact
						set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Zip code ' + @v_import_zip + ' has been trimmed.' + @v_cariadgereturn
												   from globalcontact
												   where globalcontactkey = @v_global_contactkey_match) 
						where globalcontactkey = @v_global_contactkey_match
					end
					insert into globalcontactaddress (globalcontactaddresskey, 
													  globalcontactkey,
													  addresstypecode,
													  address1,
													  address2,
													  address3,
													  city,
													  statecode,
													  zipcode,
													  countrycode,
													  primaryind,
													  lastuserid,
													  lastmaintdate)
											   Select @i_newglobalcontactaddresskey, 
													  @v_global_contactkey_match, 
													  @v_datacode_addresstype,
													  address1, 
													  address2, 
													  address3, 
													  city, 
													  @v_datacode_state,
													  substring(rtrim(zip),1,5) + CASE WHEN substring(rtrim(zip4),1,4) is not null THEN '-' + substring(rtrim(zip4),1,4) ELSE '' END,
													  @v_datacode_country,
													  address_primaryind,
													  'contact_import',
													  getdate()																									
													  from globalcontact_import
													  where globalcontactrequestkey = @i_globalcontactrequestkey 
						end 
					end

				end 

--########################## GLOBALCONTACTMETHOD - PRIMARY EMAIL UPDATES ################################
		
 			if @v_primary_email is not null begin
				set @i_externalcode = 0
				Select @i_externalcode = primary_email_externalid 
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey

				exec dbo.get_subgentables_externalcode_datacode  517, 3 , @i_externalcode, @v_datasubcode OUTPUT 
				if @v_datasubcode > 0 begin
					--Check to see if a record exists for contactmethod = 3, contactmethodsub code and contactmethodvalue
					select @v_cnt = count(*) 
					from globalcontactmethod
					where globalcontactkey = @v_global_contactkey_match 
					and contactmethodcode = 3
					and contactmethodsubcode = @v_datasubcode
					and contactmethodvalue in(select primary_email
													from globalcontact_import
													where globalcontactrequestkey = @i_globalcontactrequestkey)

					if @v_cnt = 0 begin
					--Find the globalcontactmethod record for contactmethodcode =3 with primaryind = 1
					--Set the primaryind on this record to 0
						select @v_globalcontactmethodkey = globalcontactmethodkey
						from globalcontactmethod
						where globalcontactkey = @v_global_contactkey_match 
						and contactmethodcode = 3
						and primaryind = 1

						if @v_globalcontactmethodkey > 0 begin
							update globalcontactmethod
							set primaryind = 0 
							where globalcontactmethodkey = @v_globalcontactmethodkey
							

							--Append to the Contact Note and Create a new globalcontactmethod record 
							select @v_contactmethodvalue = contactmethodvalue
							from globalcontactmethod
							where globalcontactmethodkey = @v_globalcontactmethodkey

							update globalcontact
							set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import changed primary email from ' +  @v_contactmethodvalue + ' to ' +  @v_primary_email + @v_cariadgereturn
													   from globalcontact
													   where globalcontactkey = @v_global_contactkey_match) 
							where globalcontactkey = @v_global_contactkey_match
							set @v_errind = 1
						end
							
							exec get_next_key 'qsidba', @i_globalcontactmethodkey_email1 output
							set @v_sortorder = @v_sortorder + 1
							insert into globalcontactmethod (globalcontactmethodkey,
															 globalcontactkey,
															 contactmethodcode,
															 contactmethodsubcode,
															 contactmethodvalue,
															 primaryind,
															 sortorder,
															 lastuserid,
															 lastmaintdate)
													  Select @i_globalcontactmethodkey_email1,
															 @v_global_contactkey_match,
															 3,
															 @v_datasubcode,
															 primary_email,
															 1,
															 @v_sortorder,
															 'contact_import',
															 getdate()										 
															from globalcontact_import
															where globalcontactrequestkey = @i_globalcontactrequestkey 
							
							
						
					end else begin

						select @v_cnt = count(*) 
						from globalcontactmethod
						where globalcontactkey = @v_global_contactkey_match 
						and contactmethodcode = 3
						and primaryind <> 1
						and contactmethodsubcode = @v_datasubcode
						and contactmethodvalue in(select primary_email
														from globalcontact_import
														where globalcontactrequestkey = @i_globalcontactrequestkey)

						if @v_cnt > 0 begin
							select @v_globalcontactmethodkey = globalcontactmethodkey
							from globalcontactmethod
							where globalcontactkey = @v_global_contactkey_match
							and contactmethodcode = 3
							and primaryind = 1
			
							if @v_globalcontactmethodkey > 0 begin
								update globalcontactmethod
								set primaryind = 0 
								where globalcontactmethodkey = @v_globalcontactmethodkey
								

								select @v_contactmethodvalue = contactmethodvalue
								from globalcontactmethod
								where globalcontactmethodkey = @v_globalcontactmethodkey

								update globalcontact
								set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import changed primary email from ' +  @v_contactmethodvalue + ' to ' +  @v_primary_email + @v_cariadgereturn
														   from globalcontact
														   where globalcontactkey = @v_global_contactkey_match) 
								where globalcontactkey = @v_global_contactkey_match
								set @v_errind = 1
								

								update globalcontactmethod
								set primaryind = 1
								where globalcontactkey = @v_global_contactkey_match 
								and contactmethodcode = 3
								and contactmethodsubcode = @v_datasubcode
								and contactmethodvalue in(select primary_email
														  from globalcontact_import
														  where globalcontactrequestkey = @i_globalcontactrequestkey)
								
								
							end
						end
					end
				end else begin
					update globalcontact
					set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Primary email type could not be found for external code = ' + IsNull(@i_externalcode, 'null.') + ', email address is ' + isNull(@v_primary_email, 'Null')+ @v_cariadgereturn
											   from globalcontact
											   where globalcontactkey = @v_global_contactkey_match) 
					where globalcontactkey = @v_global_contactkey_match
					set @v_errind = 1
					
				end
			end 
--########################## GLOBALCONTACTMETHOD - EMAIL2 UPDATES ################################
 			if @v_email2 is not null begin
				set @i_externalcode = 0
				Select @i_externalcode = email2_externalid 
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey

				exec dbo.get_subgentables_externalcode_datacode  517, 3 , @i_externalcode, @v_datasubcode OUTPUT 

				if @v_datasubcode > 0 begin

					select @v_cnt = count(*) 
					from globalcontactmethod
					where globalcontactkey = @v_global_contactkey_match 
					and contactmethodcode = 3
					and contactmethodsubcode = @v_datasubcode
					and contactmethodvalue in(select email2
											  from globalcontact_import
											  where globalcontactrequestkey = @i_globalcontactrequestkey)
					if @v_cnt = 0 begin
						exec get_next_key 'qsidba', @i_globalcontactmethodkey_email2 output
						set @v_sortorder = @v_sortorder + 1

								insert into globalcontactmethod (globalcontactmethodkey,
																 globalcontactkey,
																 contactmethodcode,
																 contactmethodsubcode,
																 contactmethodvalue,
																 primaryind,
																 sortorder,
																 lastuserid,
																 lastmaintdate)
														  Select @i_globalcontactmethodkey_email2,
																 @v_global_contactkey_match,
																 3,
																 @v_datasubcode,
																 email2,
																 0,
																 @v_sortorder,
																 'contact_import',
																 getdate()										 
																from globalcontact_import
																where globalcontactrequestkey = @i_globalcontactrequestkey 
							

				end else begin
					update globalcontact
					set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' email2 type could not be found for external code = ' + IsNull(@i_externalcode, 'null.') + ', email address is ' + isNull(@v_email2, 'Null')+ @v_cariadgereturn
											   from globalcontact
											   where globalcontactkey = @v_global_contactkey_match) 
					where globalcontactkey = @v_global_contactkey_match
					set @v_errind = 1
				end	
				end
			end

--########################## GLOBALCONTACTMETHOD - PRIMARY PHONE UPDATES ################################
			if @v_primary_phone is not null begin
				set @i_externalcode = 0
				Select @i_externalcode = primary_phone_externalid 
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey

				exec dbo.get_subgentables_externalcode_datacode  517, 1 , @i_externalcode, @v_datasubcode OUTPUT 

				if @v_datasubcode > 0 begin
					select @v_cnt = count(*) 
					from globalcontactmethod
					where globalcontactkey = @v_global_contactkey_match 
					and contactmethodcode = 1
					and contactmethodsubcode = @v_datasubcode
					and contactmethodvalue in(select primary_phone
											  from globalcontact_import
											  where globalcontactrequestkey = @i_globalcontactrequestkey)

					if @v_cnt = 0 begin
						select @v_globalcontactmethodkey = globalcontactmethodkey
						from globalcontactmethod
						where globalcontactkey = @v_global_contactkey_match 
						and contactmethodcode = 1
						and primaryind = 1

						if @v_globalcontactmethodkey > 0 begin
							update globalcontactmethod
							set primaryind = 0 
							where globalcontactmethodkey = @v_globalcontactmethodkey
							

							select @v_contactmethodvalue = contactmethodvalue
							from globalcontactmethod
							where globalcontactmethodkey = @v_globalcontactmethodkey

							update globalcontact
							set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import changed primary phone from ' +  @v_contactmethodvalue + ' to ' +  @v_primary_phone + @v_cariadgereturn
													   from globalcontact
													   where globalcontactkey = @v_global_contactkey_match) 
							where globalcontactkey = @v_global_contactkey_match
							set @v_errind = 1
							
						end

							exec get_next_key 'qsidba', @i_globalcontactmethodkey_phone1 output
							set @v_sortorder = @v_sortorder + 1
							insert into globalcontactmethod (globalcontactmethodkey,
															 globalcontactkey,
															 contactmethodcode,
															 contactmethodsubcode,
															 contactmethodvalue,
															 primaryind,
															 sortorder,
															 lastuserid,
															 lastmaintdate)
													  Select @i_globalcontactmethodkey_phone1,
															 @v_global_contactkey_match,
															 1,
															 @v_datasubcode,
															 primary_phone,
															 1,
															 @v_sortorder,
															 'contact_import',
															 getdate()										 
															from globalcontact_import
															where globalcontactrequestkey = @i_globalcontactrequestkey 
							

				
				end else begin
						select @v_cnt = count(*) 
						from globalcontactmethod
						where globalcontactkey = @v_global_contactkey_match 
						and contactmethodcode = 1
						and primaryind = 1
						and contactmethodsubcode = @v_datasubcode
						and contactmethodvalue in(select primary_email
														from globalcontact_import
														where globalcontactrequestkey = @i_globalcontactrequestkey)

						if @v_cnt > 0 begin
							select @v_globalcontactmethodkey = globalcontactmethodkey
							from globalcontactmethod
							where globalcontactkey = @v_global_contactkey_match 
							and contactmethodcode = 1
							and primaryind <> 1
			
							if @v_globalcontactmethodkey > 0 begin
								update globalcontactmethod
								set primaryind = 0 
								where globalcontactmethodkey = @v_globalcontactmethodkey
								

								select @v_contactmethodvalue = contactmethodvalue
								from globalcontactmethod
								where globalcontactmethodkey = @v_globalcontactmethodkey

								update globalcontact
								set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import changed primary phone from ' +  @v_contactmethodvalue + ' to ' +  @v_primary_phone+ @v_cariadgereturn 
														   from globalcontact
														   where globalcontactkey = @v_global_contactkey_match) 
								where globalcontactkey = @v_global_contactkey_match
								set @v_errind = 1
								

								update globalcontactmethod
								set primaryind = 1
								where globalcontactkey = @v_global_contactkey_match 
								and contactmethodcode = 1
								and contactmethodsubcode = @v_datasubcode
								and contactmethodvalue in(select primary_phone
														  from globalcontact_import
														  where globalcontactrequestkey = @i_globalcontactrequestkey)
								
								
							end
						end
				end
				
				end else begin
					update globalcontact
					set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Primary email type could not be found for external code = ' + IsNull(@i_externalcode, 'null.') + ', email address is ' + isNull(@v_primary_phone, 'Null') + @v_cariadgereturn
											   from globalcontact
											   where globalcontactkey = @v_global_contactkey_match) 
					where globalcontactkey = @v_global_contactkey_match
					set @v_errind = 1
					
				end
			end

--########################## GLOBALCONTACTMETHOD - PHONE2 UPDATES ################################
 			if @v_phone2 is not null begin
				set @i_externalcode = 0
				Select @i_externalcode = phone2_externalid 
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey

				exec dbo.get_subgentables_externalcode_datacode  517, 1 , @i_externalcode, @v_datasubcode OUTPUT 

				if @v_datasubcode > 0 begin
					select @v_cnt = count(*) 
					from globalcontactmethod
					where globalcontactkey = @v_global_contactkey_match 
					and contactmethodcode = 1
					and contactmethodsubcode = @v_datasubcode
					and contactmethodvalue in(select phone2
											  from globalcontact_import
											  where globalcontactrequestkey = @i_globalcontactrequestkey)
					if @v_cnt = 0 begin

						exec get_next_key 'qsidba', @i_globalcontactmethodkey_phone2 output
						set @v_sortorder = @v_sortorder + 1
								insert into globalcontactmethod (globalcontactmethodkey,
																 globalcontactkey,
																 contactmethodcode,
																 contactmethodsubcode,
																 contactmethodvalue,
																 primaryind,
																 sortorder,
																 lastuserid,
																 lastmaintdate)
														  Select @i_globalcontactmethodkey_phone2,
																 @v_global_contactkey_match,
																 1,
																 @v_datasubcode,
																 phone2,
																 0,
																 @v_sortorder,
																 'contact_import',
																 getdate()										 
																from globalcontact_import
																where globalcontactrequestkey = @i_globalcontactrequestkey 
							
				end

				end else begin
					update globalcontact
					set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' phone2 type could not be found for external code = ' + IsNull(@i_externalcode, 'null.') + ', email address is ' + isNull(@v_phone2, 'Null') + @v_cariadgereturn
											   from globalcontact
											   where globalcontactkey = @v_global_contactkey_match) 
					where globalcontactkey = @v_global_contactkey_match
					set @v_errind = 1
					
				end
			end





--################################# GLOBALCONTACTRELATIONSHIP  UPDATES ##############################################
		select @v_firstname = firstname, @v_lastname = lastname, @v_groupname = groupname
		from globalcontact 
		where globalcontactkey = @v_global_contactkey_match

		if @v_relatedcontact_relationcode1_externalid is not null begin
			exec dbo.get_gentables_externalcode_datacode 519, @v_relatedcontact_relationcode1_externalid, @v_datacode1 OUTPUT 
			exec dbo.get_gentables_externalcode_datacode 519, @v_relatedcontact_relationcode2_externalid, @v_datacode2 OUTPUT 
 
			if @v_datacode1 > 0 and @v_datacode2 > 0 begin
				set @v_relatedcontactkey = 0
				if @v_individual = 1 begin
					select @v_relatedcontactkey = globalcontactkey
					from globalcontact
					where lastname = @v_relatedcontact_lastname
					and firstname = @v_relatedcontact_firstname
				end else begin
					select @v_relatedcontactkey = globalcontactkey
					from globalcontact
					where groupname = @v_relatedcontact_groupname
				end

					if @v_relatedcontactkey > 0 begin
					  if @v_relatedcontact_phone is not null or @v_relatedcontact_email is not null begin
						select @v_cnt = count(*)
						from globalcontactmethod
						where globalcontactkey = @v_relatedcontactkey
						and (contactmethodvalue = @v_relatedcontact_phone
						or contactmethodvalue = @v_relatedcontact_email)
					 end else begin
						set @v_cnt = 1
					end
				
						if @v_cnt > 0 begin
							select @v_cnt = count(*)
							from globalcontactrelationship
							where contactrelationshipcode1 = @v_datacode1
							and contactrelationshipcode2 = @v_datacode2
							--and globalcontactkey1 = @v_globalcontactkey_import
							and globalcontactkey2 = @v_relatedcontactkey
	
							if @v_cnt = 0 begin
								select @v_cnt = count(*)
								from globalcontactrelationship
								where contactrelationshipcode1 = @v_datacode2
								and contactrelationshipcode2 = @v_datacode1
								and globalcontactkey1 = @v_relatedcontactkey
								--and globalcontactkey2 = @v_globalcontactkey_import

								if @v_cnt = 0 begin
									exec get_next_key 'qsidba', @i_globalcontactrelationshipkey1 output
									insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactkey2, Contactrelationshipcode1, Contactrelationshipcode2, Keyind)
									values(@i_globalcontactrelationshipkey1, @v_global_contactkey_match, @v_relatedcontactkey, @v_datacode1, @v_datacode2, 1)
										
								if @v_relatedcontact_linktoprimaryaddressind = 1 begin
									select @v_globalcontactaddress_prim =  globalcontactaddresskey
									from globalcontactaddress
									where globalcontactkey = @v_relatedcontactkey
									and primaryind = 1

									exec get_next_key 'qsidba', @i_newglobalcontactaddresskey_relatedlink1 output
									insert into globalcontactaddress (globalcontactaddresskey, 
																	  globalcontactkey,
																	  addresstypecode,
																	  address1,
																	  address2,
																	  address3,
																	  city,
																	  statecode,
																	  zipcode,
																	  countrycode,
																	  linkaddresskey,
																	  primaryind,
																	  lastuserid,
																	  lastmaintdate)
															   Select @i_newglobalcontactaddresskey_relatedlink1, 
																	  @v_relatedcontactkey, 
																	  addresstypecode,
																	  address1, 
																	  address2, 
																	  address3, 
																	  city, 
																	  statecode,
																	  zipcode,
																	  countrycode,
																	  @v_globalcontactaddress_prim,
																	  CASE WHEN exists(Select * 
																						from globalcontactaddress 
																						where globalcontactkey = @v_relatedcontactkey 
																						  and primaryind = 1) THEN 0 ELSE 1 END,
																	  'contact_import',
																	  getdate()																									
																from globalcontactaddress
																where globalcontactkey = @v_relatedcontactkey
									
								end



								if @v_relatedcontact_linktoprimaryphoneind = 1 begin
									select @v_globalcontactmeth_prim =  globalcontactmethodkey
									from globalcontactmethod
									where globalcontactkey = @v_relatedcontactkey
									and primaryind = 1
									and contactmethodcode = 1
									exec get_next_key 'qsidba', @i_globalcontactmethodkey_phone1_relatedlink output
									insert into globalcontactmethod (globalcontactmethodkey,
																	 globalcontactkey,
																	 contactmethodcode,
																	 contactmethodsubcode,
																	 contactmethodvalue,
																	 primaryind,
																	 sortorder,
																	 linkmethodkey,
																	 lastuserid,
																	 lastmaintdate)
															  Select @i_globalcontactmethodkey_phone1_relatedlink,
																	 @v_relatedcontactkey,
																	 contactmethodcode,
																	 contactmethodsubcode,
																	 contactmethodvalue,
																	 CASE WHEN exists(Select * 
																					  from globalcontactmethod 
																					  where globalcontactkey = @v_relatedcontactkey
																					  and contactmethodcode = 1
																					  and contactmethodsubcode in (1,2,3)
																					  and primaryind = 1) THEN 0 ELSE 1 END,
																	 1,
																	 @v_globalcontactmeth_prim,
																	 'contact_import',
																	 getdate()	 
															from globalcontactmethod
															where globalcontactmethodkey = @i_globalcontactmethodkey_phone1
										
								end 
								end
							end
						end
					end
			if @v_relatedcontactkey is null and len(ltrim(rtrim(@v_relatedcontact_notontaq_name2))) > 0 begin
				select @v_cnt = count(*)
				from globalcontactrelationship
				where contactrelationshipcode1 = @v_datacode1
				and contactrelationshipcode2 = @v_datacode2
				and globalcontactname2 = @v_relatedcontact_notontaq_name2
								
				if @v_cnt > 0 begin	
					exec get_next_key 'qsidba', @i_globalcontactrelationshipkey1 output
					insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactname2, Contactrelationshipcode1, Contactrelationshipcode2, Contactrelationshipaddtldesc, Keyind, Sortorder)
					values(@i_globalcontactrelationshipkey1, @v_global_contactkey_match, @v_relatedcontact_notontaq_name2, @v_datacode1, @v_datacode2, @v_relatedcontact_notontaq_addtldesc, 1, 1)
					
				end
			end
			if @v_relatedcontactkey is null and len(ltrim(rtrim(@v_relatedcontact_notontaq_name2))) = 0 begin
				update globalcontact
				set globalcontactnotes  = (select isNull(globalcontactnotes, '') + 'There is no contact found on the system matching ' + + isnull(@v_firstname, '') + ' ' + isnull(@v_lastname, '') + ' ' + isnull(@v_groupname, '') +  ' with  phone # ' + IsNull(@v_relatedcontact_phone, '') + ' or email ' + IsNull(@v_relatedcontact_email, '') + @v_cariadgereturn
										   from globalcontact
										   where globalcontactkey = @v_global_contactkey_match) 
				where globalcontactkey = @v_global_contactkey_match
				set @v_errind = 1
				
			end
		
			end else begin
			update globalcontact
			set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact Relationship value could not be found for external code ' + @v_relatedcontact_relationcode1_externalid + ' or for ' + @v_relatedcontact_relationcode2_externalid + ' related contact name is ' + isnull(@v_firstname, '') + ' ' + isnull(@v_lastname, '') + ' ' + isnull(@v_groupname, '')  + @v_cariadgereturn
									   from globalcontact
									   where globalcontactkey = @v_global_contactkey_match) 
			where globalcontactkey = @v_global_contactkey_match
			set @v_errind = 1
			
			end

			if @v_datacode1 > 0 and @v_datacode2 > 0 begin
				set @v_relatedcontactkey = 0
				if @v_individual = 1 begin
					select @v_relatedcontactkey = globalcontactkey
					from globalcontact
					where lastname = @v_relatedcontact2_lastname
					and firstname = @v_relatedcontact2_firstname
				end else begin
					select @v_relatedcontactkey = globalcontactkey
					from globalcontact
					where groupname = @v_relatedcontact2_groupname
				end

					if @v_relatedcontactkey > 0 begin
					  if @v_relatedcontact2_phone is not null or @v_relatedcontact2_email is not null begin
						select @v_cnt = count(*)
						from globalcontactmethod
						where globalcontactkey = @v_relatedcontactkey
						and (contactmethodvalue = @v_relatedcontact2_phone
						or contactmethodvalue = @v_relatedcontact2_email)
					 end else begin
						set @v_cnt = 1
					end
				
						if @v_cnt > 0 begin
							select @v_cnt = count(*)
							from globalcontactrelationship
							where contactrelationshipcode1 = @v_datacode1
							and contactrelationshipcode2 = @v_datacode2
							and globalcontactkey1 = @v_globalcontactkey_import
							and globalcontactkey2 = @v_relatedcontactkey
	
							if @v_cnt = 0 begin
								select @v_cnt = count(*)
								from globalcontactrelationship
								where contactrelationshipcode1 = @v_datacode2
								and contactrelationshipcode2 = @v_datacode1
								and globalcontactkey1 = @v_relatedcontactkey
								and globalcontactkey2 = @v_globalcontactkey_import

								if @v_cnt = 0 begin
									exec get_next_key 'qsidba', @i_globalcontactrelationshipkey1 output
									insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactkey2, Contactrelationshipcode1, Contactrelationshipcode2, Keyind)
									values(@i_globalcontactrelationshipkey1, @v_global_contactkey_match, @v_relatedcontactkey, @v_datacode1, @v_datacode2, 1)
										
								if @v_relatedcontact2_linktoprimaryaddressind = 1 begin
									select @v_globalcontactaddress2_prim =  globalcontactaddresskey
									from globalcontactaddress
									where globalcontactkey = @v_relatedcontactkey
									and primaryind = 1

									exec get_next_key 'qsidba', @i_newglobalcontactaddresskey_relatedlink1 output
									insert into globalcontactaddress (globalcontactaddresskey, 
																	  globalcontactkey,
																	  addresstypecode,
																	  address1,
																	  address2,
																	  address3,
																	  city,
																	  statecode,
																	  zipcode,
																	  countrycode,
																	  linkaddresskey,
																	  primaryind,
																	  lastuserid,
																	  lastmaintdate)
															   Select @i_newglobalcontactaddresskey_relatedlink1, 
																	  @v_relatedcontactkey, 
																	  addresstypecode,
																	  address1, 
																	  address2, 
																	  address3, 
																	  city, 
																	  statecode,
																	  zipcode,
																	  countrycode,
																	  @v_globalcontactaddress_prim,
																	  CASE WHEN exists(Select * 
																						from globalcontactaddress 
																						where globalcontactkey = @v_relatedcontactkey 
																						  and primaryind = 1) THEN 0 ELSE 1 END,
																	  'contact_import',
																	  getdate()																									
																from globalcontactaddress
																where globalcontactkey = @v_relatedcontactkey
									
								end



								if @v_relatedcontact2_linktoprimaryphoneind = 1 begin
									select @v_globalcontactmeth_prim =  globalcontactmethodkey
									from globalcontactmethod
									where globalcontactkey = @v_relatedcontactkey
									and primaryind = 1
									and contactmethodcode = 1
									exec get_next_key 'qsidba', @i_globalcontactmethodkey_phone1_relatedlink output
									insert into globalcontactmethod (globalcontactmethodkey,
																	 globalcontactkey,
																	 contactmethodcode,
																	 contactmethodsubcode,
																	 contactmethodvalue,
																	 primaryind,
																	 sortorder,
																	 linkmethodkey,
																	 lastuserid,
																	 lastmaintdate)
															  Select @i_globalcontactmethodkey_phone1_relatedlink,
																	 @v_relatedcontactkey,
																	 contactmethodcode,
																	 contactmethodsubcode,
																	 contactmethodvalue,
																	 CASE WHEN exists(Select * 
																					  from globalcontactmethod 
																					  where globalcontactkey = @v_relatedcontactkey
																					  and contactmethodcode = 1
																					  and contactmethodsubcode in (1,2,3)
																					  and primaryind = 1) THEN 0 ELSE 1 END,
																	 1,
																	 @v_globalcontactmeth_prim,
																	 'contact_import',
																	 getdate()	 
															from globalcontactmethod
															where globalcontactmethodkey = @i_globalcontactmethodkey_phone1
										
								end 
								end
							end
						end
					end
			if @v_relatedcontactkey is null and len(ltrim(rtrim(@v_relatedcontact_notontaq_name2))) > 0 begin
				select @v_cnt = count(*)
				from globalcontactrelationship
				where contactrelationshipcode1 = @v_datacode1
				and contactrelationshipcode2 = @v_datacode2
				and globalcontactname2 = @v_relatedcontact_notontaq_name2
								
				if @v_cnt > 0 begin	
					exec get_next_key 'qsidba', @i_globalcontactrelationshipkey1 output
					insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactname2, Contactrelationshipcode1, Contactrelationshipcode2, Contactrelationshipaddtldesc, Keyind, Sortorder)
					values(@i_globalcontactrelationshipkey1, @v_global_contactkey_match, @v_relatedcontact_notontaq_name2, @v_datacode1, @v_datacode2, @v_relatedcontact_notontaq_addtldesc, 1, 1)
					
				end
			end
			if @v_relatedcontactkey is null and len(ltrim(rtrim(@v_relatedcontact_notontaq_name2))) = 0 begin
				update globalcontact
				set globalcontactnotes  = (select isNull(globalcontactnotes, '') + 'There is no contact found on the system matching ' + + isnull(@v_firstname, '') + ' ' + isnull(@v_lastname, '') + ' ' + isnull(@v_groupname, '') +  ' with  phone # ' + IsNull(@v_relatedcontact_phone, '') + ' or email ' + IsNull(@v_relatedcontact_email, '') + @v_cariadgereturn
										   from globalcontact
										   where globalcontactkey = @v_global_contactkey_match) 
				where globalcontactkey = @v_global_contactkey_match
				set @v_errind = 1
				
			end
		
			end else begin
			update globalcontact
			set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact Relationship value could not be found for external code ' + @v_relatedcontact_relationcode1_externalid + ' or for ' + @v_relatedcontact_relationcode2_externalid + ' related contact name is ' + isnull(@v_firstname, '') + ' ' + isnull(@v_lastname, '') + ' ' + isnull(@v_groupname, '')  + @v_cariadgereturn
									   from globalcontact
									   where globalcontactkey = @v_global_contactkey_match) 
			where globalcontactkey = @v_global_contactkey_match
			set @v_errind = 1
			
			end
		end
			if @v_errind = 0 begin
				update globalcontact
				set globalcontactnotes  = (select 'Import Successful.' + @v_cariadgereturn + isNull(globalcontactnotes, '') + @v_cariadgereturn
										   from globalcontact
										   where globalcontactkey = @v_global_contactkey_match) 
				where globalcontactkey = @v_global_contactkey_match
			end

			update globalcontact
			set globalcontactnotes  = (select  'Contact Updated on ' + @v_date + @v_cariadgereturn + IsNull(globalcontactnotes, '')
									   from globalcontact
									   where globalcontactkey = @v_global_contactkey_match) 
			where globalcontactkey = @v_global_contactkey_match



	if @v_firstname_orig <> @v_firstname_import or @v_lastname_orig <> @v_lastname_import or @v_middlename_orig <> @v_middlename_import begin
		if exists (select *
					from clientoptions 
					where optionid = 52
					and optionvalue = 1)
		begin
		    if ( len(isnull(@v_displayname,'')) > 0 )
		    begin
		        exec get_next_key 'qsidba', @v_globalcontacthistorykey output
		        insert into globalcontacthistory
		        values(@v_globalcontacthistorykey, @v_global_contactkey_match, 4, getdate(), '(Not Present)', 'contact_import', @v_displayname, 'Display Name', null)
		    end
		end
	end
	if @v_firstname_orig <> @v_firstname_import begin
	    if ( len(isnull(@v_firstname,'')) > 0 )
	    begin
		    exec get_next_key 'qsidba', @v_globalcontacthistorykey output
		    insert into globalcontacthistory
		    values(@v_globalcontacthistorykey, @v_global_contactkey_match, 5, getdate(), '(Not Present)', 'contact_import', @v_firstname, 'First Name', null)
		end
	end
	if @v_lastname_orig <> @v_lastname_import begin
	    if ( len(isnull(@v_lastname,'')) > 0 )
	    begin
		    exec get_next_key 'qsidba', @v_globalcontacthistorykey output
		    insert into globalcontacthistory
		    values(@v_globalcontacthistorykey, @v_global_contactkey_match, 6, getdate(), '(Not Present)', 'contact_import', @v_lastname, 'Last Name', null)
		end
	end 
	if @v_middlename_orig <> @v_middlename_import begin
	    if ( len(isnull(@v_middlename_import,'')) > 0 )
	    begin
		    exec get_next_key 'qsidba', @v_globalcontacthistorykey output
		    insert into globalcontacthistory
		    values(@v_globalcontacthistorykey, @v_global_contactkey_match, 7, getdate(), '(Not Present)', 'contact_import', @v_middlename_import, 'Middle Name', null)
		end
	end  

	set @v_accreditation_desc = null
	select @v_accreditation_desc = datadesc
	from gentables 
	where tableid = 210
	and datacode = @v_accreditationcode_import

	if @v_accreditation_desc is not null begin
		exec get_next_key 'qsidba', @v_globalcontacthistorykey output
		insert into globalcontacthistory
		values(@v_globalcontacthistorykey, @i_newglobalcontactkey, 8, getdate(), '(Not Present)', 'contact_import', @v_accreditation_desc, 'Accreditation', null)
	end 

	set @i_newglobalcontactkey = @v_global_contactkey_match

			set @v_retcode = 1

    END 
    
    ELSE 
    
    BEGIN
	
--xxxxxxx	
--################################# GLOBALCONTACT INSERT ##############################################
			if @v_individualind <> 1 begin
				set @v_lastname_import = @v_groupname_import
			end
			exec get_next_key 'qsidba', @i_newglobalcontactkey output

			if @v_note is not null begin
				set @v_note = ' ' + @v_note + @v_cariadgereturn
			end
			
			Insert into globalcontact(globalcontactkey,
									  firstname, 
									  lastname, 
									  individualind, 
									  groupname, 
									  middlename, 
									  searchname,
									  suffix, 
									  degree, 
									  ssn, 
									  autodisplayind,
									  privateind,
									  lastuserid,
									  lastmaintdate,
									  globalcontactnotes)
							   Select @i_newglobalcontactkey, 
									  firstname, 
									  lastname, 
									  individualind, 
									  groupname, 
									  middlename, 
									  CASE WHEN groupname is not null THEN UPPER(groupname) WHEN lastname is not null then upper(lastname) END,
									  suffix, 
									  degree, 
									  NULL, -- ssn
                    autodisplayind,
									  0	,
									  'contact_import',
									  getdate(),
									  @v_note
							   from globalcontact_import 
							   where globalcontactrequestkey = @i_globalcontactrequestkey


		
			if @v_displayname is Null or ltrim(rtrim(@v_displayname)) = ''  begin
				exec globalcontact_displayname 
										@v_individualind,  
										@v_lastname_import, 
										@v_firstname_import, 
										@v_middlename_import,
										@v_suffix_import,
										@v_degree_import,
										@v_displayname output ,
										0,
										''
				if @v_optionvalue = 0 begin
					update globalcontact
					set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Displayname has been auto-generated.' + @v_cariadgereturn
											   from globalcontact
											   where globalcontactkey = @i_newglobalcontactkey) 
					where globalcontactkey = @i_newglobalcontactkey
				end 
			end

			update globalcontact 
			set displayname = @v_displayname
			where globalcontactkey = @i_newglobalcontactkey


				
				set @i_externalcode_addresstype  = 0
				Select @i_externalcode_addresstype = addresstype_externalid
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey
				exec dbo.get_gentables_externalcode_datacode  207, @i_externalcode_addresstype, @v_datacode_addresstype OUTPUT 

				set @i_externalcode_state = 0
				Select @i_externalcode_state = state
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey
				exec dbo.get_gentables_externalcode_datacode  160, @i_externalcode_state, @v_datacode_state OUTPUT 


				set @i_externalcode_country = 0
				Select @i_externalcode_country = country
				from globalcontact_import 
				where globalcontactrequestkey = @i_globalcontactrequestkey
				exec dbo.get_gentables_externalcode_datacode  114, @i_externalcode_country, @v_datacode_country OUTPUT 

				if @v_datacode_addresstype > 0 begin

					select @v_import_zip = isNull(zip, '') + '-' + IsNull(zip4, '')
					from globalcontact_import
					where globalcontactrequestkey = @i_globalcontactrequestkey

					if datalength(@v_import_zip) > 10 begin
						update globalcontact
						set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Zip code ' + @v_import_zip + ' has been trimmed.' + @v_cariadgereturn
												   from globalcontact
												   where globalcontactkey = @i_newglobalcontactkey)
						where globalcontactkey = @v_global_contactkey_match
					end

					exec get_next_key 'qsidba', @i_newglobalcontactaddresskey output
					set @v_taqprojectcontact_addresskey = @i_newglobalcontactaddresskey
					insert into globalcontactaddress (globalcontactaddresskey, 
													  globalcontactkey,
													  addresstypecode,
													  address1,
													  address2,
													  address3,
													  city,
													  statecode,
													  zipcode,
													  countrycode,
													  primaryind,
													  lastuserid,
													  lastmaintdate)
											   Select @i_newglobalcontactaddresskey, 
													  @i_newglobalcontactkey, 
													  @v_datacode_addresstype,
													  substring(address1, 1, 255), 
													  substring(address2, 1, 255), 
													  substring(address3, 1, 255), 
													  substring(city, 1, 25),
													  @v_datacode_state,
													  substring(rtrim(zip), 1,5) + CASE WHEN substring(rtrim(zip4),1,4) is not null THEN '-' + substring(rtrim(zip4),1,4) ELSE '' END,
													  @v_datacode_country,
													  address_primaryind,
													  'contact_import',
													  getdate()																									
													  from globalcontact_import
													  where globalcontactrequestkey = @i_globalcontactrequestkey 
					end
					if @v_datacode_addresstype is null begin
						update globalcontact
						set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Address type could not be found for external code = ' + IsNull(@i_externalcode_addresstype, 'null.')  + @v_cariadgereturn
												   from globalcontact
												   where globalcontactkey = @i_newglobalcontactkey) 
						where globalcontactkey = @i_newglobalcontactkey
						set @v_errind = 1
					end
--					if @v_datacode_state is null begin
--						update globalcontact
--						set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' State could not be found for external code = ' + IsNull(@i_externalcode_state, 'null.') + @v_cariadgereturn
--												   from globalcontact
--												   where globalcontactkey = @i_newglobalcontactkey) 
--						where globalcontactkey = @i_newglobalcontactkey
--						set @v_errind = 1
--					end
--					if @v_datacode_country is null begin
--						update globalcontact
--						set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Country could not be found for external code = ' + IsNull(@i_externalcode_country, 'null.') + @v_cariadgereturn
--												   from globalcontact
--												   where globalcontactkey = @i_newglobalcontactkey) 
--						where globalcontactkey = @i_newglobalcontactkey
--						set @v_errind = 1
--					end
				

--################################# GLOBALCONTACTMETHODS - PRIMARY EMAIL INSERT ##############################################

				select @v_primary_email = primary_email, @v_email2 = email2
				from globalcontact_import
				where globalcontactrequestkey = @i_globalcontactrequestkey 

				if @v_primary_email is not null begin
					set @i_externalcode = 0
					Select @i_externalcode = primary_email_externalid 
					from globalcontact_import 
					where globalcontactrequestkey = @i_globalcontactrequestkey

					exec dbo.get_subgentables_externalcode_datacode  517, 3 , @i_externalcode, @v_datasubcode OUTPUT 

					if @v_datasubcode > 0 begin
					if @v_primary_email is not null and ltrim(rtrim(@v_primary_email)) <> '' begin 
					exec get_next_key 'qsidba', @i_globalcontactmethodkey_email1 output
					insert into globalcontactmethod (globalcontactmethodkey,
													 globalcontactkey,
													 contactmethodcode,
													 contactmethodsubcode,
													 contactmethodvalue,
													 primaryind,
													 sortorder,
													 lastuserid,
													 lastmaintdate)
											  Select @i_globalcontactmethodkey_email1,
													 @i_newglobalcontactkey,
													 3,
													 @v_datasubcode,
													 primary_email,
													 1,
													 1,
													 'contact_import',
													 getdate()										 
													from globalcontact_import
													where globalcontactrequestkey = @i_globalcontactrequestkey	
					end	
					end else begin
						update globalcontact
						set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Primary email type could not be found for external code = ' + IsNull(@i_externalcode, 'null.') + ', email address is ' + isNull(@v_primary_email, 'Null.') + @v_cariadgereturn
												   from globalcontact
												   where globalcontactkey = @i_newglobalcontactkey) 
						where globalcontactkey = @i_newglobalcontactkey
						set @v_errind = 1
						
					end
				end

--################################# GLOBALCONTACTMETHODS - EMAIL 2 INSERT ##############################################
				if @v_email2 is not null begin
					set @i_externalcode = 0
					Select @i_externalcode = email2_externalid 
					from globalcontact_import 
					where globalcontactrequestkey = @i_globalcontactrequestkey

					exec dbo.get_subgentables_externalcode_datacode  517, 3 , @i_externalcode, @v_datasubcode OUTPUT 

					
					if @v_datasubcode > 0 begin
					if @v_email2 is not null and ltrim(rtrim(@v_email2)) <> '' begin 
					exec get_next_key 'qsidba', @i_globalcontactmethodkey_email2 output
					insert into globalcontactmethod (globalcontactmethodkey,
													 globalcontactkey,
													 contactmethodcode,
													 contactmethodsubcode,
													 contactmethodvalue,
													 primaryind,
													 sortorder,
													 lastuserid,
													 lastmaintdate)
											  Select @i_globalcontactmethodkey_email2,
													 @i_newglobalcontactkey,
													 3,
													 @v_datasubcode,
													 email2,
													 0,
													 2,
													 'contact_import',
													 getdate()										 
													from globalcontact_import
													where globalcontactrequestkey = @i_globalcontactrequestkey 
					
					end
					end else begin

						update globalcontact
						set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Primary email type could not be found for external code = ' + IsNull(@i_externalcode, 'null.') + ', email address is ' + isNull(@v_email2, 'Null.') + @v_cariadgereturn
												   from globalcontact
												   where globalcontactkey = @i_newglobalcontactkey) 
						where globalcontactkey = @i_newglobalcontactkey
						set @v_errind = 1
						
					end
			end

--################################# GLOBALCONTACTMETHODS - PRIMARY PHONE INSERT ##############################################
		if @v_primary_phone is not null begin
			set @i_externalcode = 0
			Select @i_externalcode = primary_phone_externalid 
			from globalcontact_import 
			where globalcontactrequestkey = @i_globalcontactrequestkey

			exec dbo.get_subgentables_externalcode_datacode  517, 1 , @i_externalcode, @v_datasubcode OUTPUT 
				if @v_datasubcode > 0 begin
				if @v_primary_phone is not null and ltrim(rtrim(@v_primary_phone)) <> '' begin 

				exec get_next_key 'qsidba', @i_globalcontactmethodkey_phone1 output
				insert into globalcontactmethod (globalcontactmethodkey,
												 globalcontactkey,
												 contactmethodcode,
												 contactmethodsubcode,
												 contactmethodvalue,
												 primaryind,
												 sortorder,
												 lastuserid,
												 lastmaintdate)
										  Select @i_globalcontactmethodkey_phone1,
												 @i_newglobalcontactkey,
												 1,
												 @v_datasubcode,
												 primary_phone,
												 1,
												 1,
												 'contact_import',
												 getdate()										 
												from globalcontact_import
												where globalcontactrequestkey = @i_globalcontactrequestkey 
				end
				end else begin
						update globalcontact
						set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Primary phone type could not be found for external code = ' + IsNull(@i_externalcode, 'null.') + ' , phone # is ' +  @v_primary_phone + '.' + @v_cariadgereturn
												   from globalcontact
												   where globalcontactkey = @i_newglobalcontactkey) 
						where globalcontactkey = @i_newglobalcontactkey
						set @v_errind = 1
					end
			end
				
  --################################# GLOBALCONTACTMETHODS - PHONE2 INSERT ##############################################
		if @v_phone2 is not null begin
			set @i_externalcode = 0
			Select @i_externalcode = phone2_externalid 
			from globalcontact_import 
			where globalcontactrequestkey = @i_globalcontactrequestkey

			exec dbo.get_subgentables_externalcode_datacode  517, 1 , @i_externalcode, @v_datasubcode OUTPUT 

			if @v_datasubcode > 0 begin
			if @v_phone2 is not null or ltrim(rtrim(@v_phone2)) <> '' begin  
				exec get_next_key 'qsidba', @i_globalcontactmethodkey_phone2 output
				insert into globalcontactmethod (globalcontactmethodkey,
												 globalcontactkey,
												 contactmethodcode,
												 contactmethodsubcode,
												 contactmethodvalue,
												 primaryind,
												 sortorder,
												 lastuserid,
												 lastmaintdate)
										  Select @i_globalcontactmethodkey_phone2,
												 @i_newglobalcontactkey,
												 1,
												 @v_datasubcode,
												 phone2,
												 0,
												 2,
												 'contact_import',
												 getdate()										 
											from globalcontact_import 
											where globalcontactrequestkey = @i_globalcontactrequestkey 
			end
			end else begin
						update globalcontact
						set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Phone2 type could not be found for external code = ' + IsNull(@i_externalcode, 'null.') + ' , phone # is ' +  @v_phone2 + '.' + @v_cariadgereturn
												   from globalcontact
												   where globalcontactkey = @i_newglobalcontactkey) 
						where globalcontactkey = @i_newglobalcontactkey
						set @v_errind = 1
						
					end
			end
				

--################################# GLOBALCONTACTRELATIONSHIP INSERT ##############################################
	if @v_relatedcontact_relationcode1_externalid is not null and @v_relatedcontact_relationcode2_externalid is not null begin
		select @v_firstname = firstname, @v_lastname = lastname, @v_groupname = groupname
		from globalcontact_import 
		where globalcontactrequestkey = @i_globalcontactrequestkey 

		exec dbo.get_gentables_externalcode_datacode 519, @v_relatedcontact_relationcode1_externalid, @v_datacode1 OUTPUT 
		exec dbo.get_gentables_externalcode_datacode 519, @v_relatedcontact_relationcode2_externalid, @v_datacode2 OUTPUT 

--	exec get_next_key 'qsidba', @i_globalcontactrelationshipkey2 output
--	insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactname2, Contactrelationshipcode1, Contactrelationshipcode2, Contactrelationshipaddtldesc, Keyind, Sortorder)
--	values(@i_globalcontactrelationshipkey2, @i_newglobalcontactkey, 'universiti', 11, @v_datacode2, @v_relatedcontact_notontaq_addtldesc, 1, 1)
		set @v_cnt = 0
		if @v_datacode1 > 0 and @v_datacode2 > 0 begin

				set @v_relatedcontactkey = 0
				if @v_individual = 1 begin
					select @v_relatedcontactkey = globalcontactkey
					from globalcontact
					where lastname = @v_relatedcontact_lastname
					and firstname = @v_relatedcontact_firstname
				end else begin
					select @v_relatedcontactkey = globalcontactkey
					from globalcontact
					where groupname = @v_relatedcontact_groupname
				end

			if @v_relatedcontactkey > 0 begin
				 if @v_relatedcontact_phone is not null or @v_relatedcontact_email is not null begin
					select @v_cnt = count(*)
					from globalcontactmethod
					where globalcontactkey = @v_relatedcontactkey
					and (contactmethodvalue = @v_relatedcontact_phone
					or contactmethodvalue = @v_relatedcontact_email)
				 end else begin
					set @v_cnt = 1
				 end
				if @v_cnt > 0 begin

					exec get_next_key 'qsidba', @i_globalcontactrelationshipkey1 output
					insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactkey2, Contactrelationshipcode1, Contactrelationshipcode2, Keyind)
					values(@i_globalcontactrelationshipkey1, @i_newglobalcontactkey, @v_relatedcontactkey, @v_datacode1, @v_datacode2, 1)
				end
			end

			if @v_relatedcontactkey is null and len(ltrim(rtrim(@v_relatedcontact_notontaq_name2))) > 0 begin
				exec get_next_key 'qsidba', @i_globalcontactrelationshipkey1 output
				insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactname2, Contactrelationshipcode1, Contactrelationshipcode2, Contactrelationshipaddtldesc, Keyind, Sortorder)
				values(@i_globalcontactrelationshipkey1, @i_newglobalcontactkey, @v_relatedcontact_notontaq_name2, @v_datacode1, @v_datacode2, @v_relatedcontact_notontaq_addtldesc, 1, 1)
			end

			Select @v_relatedcontactkey2 = g.globalcontactkey
				from globalcontact g, globalcontact_import i
				where (i.relatedcontact2_individualind = 1 and g.lastname = i.relatedcontact2_lastname and g.firstname = i.relatedcontact2_firstname)
				   OR (i.relatedcontact2_individualind = 0 and g.groupname = i.relatedcontact2_groupname)
			
			if @v_relatedcontactkey2 > 0 begin
				if @v_relatedcontact_phone is not null or @v_relatedcontact_email is not null begin
					select @v_cnt = count(*)
					from globalcontactmethod
					where globalcontactkey = @v_relatedcontactkey
					and (contactmethodvalue = @v_relatedcontact2_phone
					or contactmethodvalue = @v_relatedcontact2_email)
				 end else begin
					set @v_cnt = 1
				end
			
				if @v_cnt > 0 begin
					exec get_next_key 'qsidba', @i_globalcontactrelationshipkey2 output
					insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactkey2, Contactrelationshipcode1, Contactrelationshipcode2, Keyind)
					values(@i_globalcontactrelationshipkey2, @i_newglobalcontactkey, @v_relatedcontactkey2, @v_datacode1, @v_datacode2, 1)
				end
			end

			if @v_relatedcontactkey2 is null and len(ltrim(rtrim(@v_relatedcontact_notontaq_name2))) > 0 begin
				exec get_next_key 'qsidba', @i_globalcontactrelationshipkey2 output
				insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactname2, Contactrelationshipcode1, Contactrelationshipcode2, Contactrelationshipaddtldesc, Keyind, Sortorder)
				values(@i_globalcontactrelationshipkey2, @i_newglobalcontactkey, @v_relatedcontact_notontaq_name2, @v_datacode1, @v_datacode2, @v_relatedcontact_notontaq_addtldesc, 1, 1)
			end
			
			if @v_relatedcontactkey is null and len(ltrim(rtrim(@v_relatedcontact_notontaq_name2))) = 0 begin
				update globalcontact
				set globalcontactnotes  = (select isNull(globalcontactnotes, '') + 'There is no contact found on the system matching ' + isnull(@v_lastname, '') + ' ' + isnull(@v_firstname, '') + ' ' + isnull(@v_groupname, '') +  ' with  phone # ' + IsNull(@v_relatedcontact_phone, '') + ' or email ' + IsNull(@v_relatedcontact_email, '') + @v_cariadgereturn
										   from globalcontact
										   where globalcontactkey = @i_newglobalcontactkey)
				where globalcontactkey = @i_newglobalcontactkey
				set @v_errind = 1
				 
			end

		end else begin
			update globalcontact
			set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact Relationship value could not be found for external code ' + @v_relatedcontact_relationcode1_externalid + ' or for ' + @v_relatedcontact_relationcode2_externalid + ' related contact name is ' + isnull(@v_firstname, '') + ' ' + isnull(@v_lastname, '') + ' ' + isnull(@v_groupname, '') + '.' +  @v_cariadgereturn
									   from globalcontact
									   where globalcontactkey = @i_newglobalcontactkey) 
			where globalcontactkey = @i_newglobalcontactkey
			set @v_errind = 1
		end
	end


	if @v_relatedcontact2_relationcode1_externalid is not null and @v_relatedcontact2_relationcode2_externalid is not null begin
		select @v_firstname = firstname, @v_lastname = lastname, @v_groupname = groupname
		from globalcontact_import 
		where globalcontactrequestkey = @i_globalcontactrequestkey 

		exec dbo.get_gentables_externalcode_datacode 519, @v_relatedcontact2_relationcode1_externalid, @v_datacode1_1 OUTPUT 
		exec dbo.get_gentables_externalcode_datacode 519, @v_relatedcontact2_relationcode2_externalid, @v_datacode2_2 OUTPUT 

		set @v_cnt = 0
		if @v_datacode1_1 > 0 and @v_datacode2_2 > 0 begin

				set @v_relatedcontactkey = 0
				if @v_individual = 1 begin
					select @v_relatedcontactkey = globalcontactkey
					from globalcontact
					where lastname = @v_relatedcontact_lastname
					and firstname = @v_relatedcontact_firstname
				end else begin
					select @v_relatedcontactkey = globalcontactkey
					from globalcontact
					where groupname = @v_relatedcontact_groupname
				end

			if @v_relatedcontactkey > 0 begin
				 if @v_relatedcontact_phone is not null or @v_relatedcontact_email is not null begin
					select @v_cnt = count(*)
					from globalcontactmethod
					where globalcontactkey = @v_relatedcontactkey
					and (contactmethodvalue = @v_relatedcontact_phone
					or contactmethodvalue = @v_relatedcontact_email)
				 end else begin
					set @v_cnt = 1
				 end
				if @v_cnt > 0 begin

					exec get_next_key 'qsidba', @i_globalcontactrelationshipkey1 output
					--insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactkey2, Contactrelationshipcode1, Contactrelationshipcode2, Keyind)
					--values(@i_globalcontactrelationshipkey1, @i_newglobalcontactkey, @v_relatedcontactkey, @v_datacode1_1, @v_datacode2_2, 1)
				select @v_relatedcontact_notontaq_name2 = globalcontactname2, @v_relatedcontact_notontaq_addtldesc = contactrelationshipaddtldesc 
				from globalcontactrelationship 
				where globalcontactkey1 = @v_relatedcontactkey
				insert into globalcontactrelationship(globalcontactrelationshipkey, Globalcontactkey1, Globalcontactname2, Contactrelationshipcode1, Contactrelationshipcode2, Contactrelationshipaddtldesc, Keyind, Sortorder)
				values(@i_globalcontactrelationshipkey1, @i_newglobalcontactkey, @v_relatedcontact_notontaq_name2, @v_datacode1_1, @v_datacode2_2, @v_relatedcontact_notontaq_addtldesc, 1, 1)

				end
			end

							
			if @v_relatedcontactkey is null and len(ltrim(rtrim(@v_relatedcontact_notontaq_name2))) = 0 begin
				update globalcontact
				set globalcontactnotes  = (select isNull(globalcontactnotes, '') + 'There is no contact found on the system matching ' + isnull(@v_lastname, '') + ' ' + isnull(@v_firstname, '') + ' ' + isnull(@v_groupname, '') +  ' with  phone # ' + IsNull(@v_relatedcontact_phone, '') + ' or email ' + IsNull(@v_relatedcontact_email, '') + @v_cariadgereturn
										   from globalcontact
										   where globalcontactkey = @i_newglobalcontactkey)
				where globalcontactkey = @i_newglobalcontactkey
				set @v_errind = 1
				 
			end

		end else begin
			update globalcontact
			set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact Relationship value could not be found for external code ' + @v_relatedcontact_relationcode1_externalid + ' or for ' + @v_relatedcontact_relationcode2_externalid + ' related contact name is ' + isnull(@v_firstname, '') + ' ' + isnull(@v_lastname, '') + ' ' + isnull(@v_groupname, '') + '.' +  @v_cariadgereturn
									   from globalcontact
									   where globalcontactkey = @i_newglobalcontactkey) 
			where globalcontactkey = @i_newglobalcontactkey
			set @v_errind = 1
		end
	end



--################################# GLOBALCONTACTORGENTRY INSERT ##############################################
	if @v_orgentry1 is not null begin
		Insert into globalcontactorgentry (globalcontactkey, orglevelkey, orgentrykey, lastuserid, lastmaintdate)
		values(@i_newglobalcontactkey, 1, @v_orgentry1, 'contact_import', getdate())
	end
	if @v_orgentry2 is not null begin
		Insert into globalcontactorgentry (globalcontactkey, orglevelkey, orgentrykey, lastuserid, lastmaintdate)
		values(@i_newglobalcontactkey, 2, @v_orgentry2, 'contact_import', getdate())
	end
	if @v_orgentry3 is not null begin
		Insert into globalcontactorgentry (globalcontactkey, orglevelkey, orgentrykey, lastuserid, lastmaintdate)
		values(@i_newglobalcontactkey, 3, @v_orgentry3, 'contact_import', getdate())
	end
		
--################################# GLOBALCONTACTHISTORY ##############################################
--select * from globalcontacthistory
	if @v_suffix_import is not null begin
		exec get_next_key 'qsidba', @v_globalcontacthistorykey output
		insert into globalcontacthistory
		values(@v_globalcontacthistorykey, @i_newglobalcontactkey, 1, getdate(), '(Not Present)', 'contact_import', @v_suffix_import, 'Suffix', null)
	end 

	if @v_individual = 1 begin
		set @v_corporate_contributor = 'N'
	end else begin
		set @v_corporate_contributor = 'Y'
	end 

    if ( len(isnull(@v_corporate_contributor,'')) > 0 )
    begin 
	    exec get_next_key 'qsidba', @v_globalcontacthistorykey output
	    insert into globalcontacthistory
	    values(@v_globalcontacthistorykey, @i_newglobalcontactkey, 3, getdate(), '(Not Present)', 'contact_import', @v_corporate_contributor, 'Corporate Contributor', null)
	end 
	
    if ( len(isnull(@v_displayname,'')) > 0 )
    begin 
	    exec get_next_key 'qsidba', @v_globalcontacthistorykey output
	    insert into globalcontacthistory
	    values(@v_globalcontacthistorykey, @i_newglobalcontactkey, 4, getdate(), '(Not Present)', 'contact_import', @v_displayname, 'Display Name', null)
    end
    
    if ( len(isnull(@v_firstname,'')) > 0 )
    begin 
	    exec get_next_key 'qsidba', @v_globalcontacthistorykey output
	    insert into globalcontacthistory
	    values(@v_globalcontacthistorykey, @i_newglobalcontactkey, 5, getdate(), '(Not Present)', 'contact_import', @v_firstname, 'First Name', null)
    end
    
    if ( len(isnull(@v_lastname,'')) > 0 )
    begin 
	    exec get_next_key 'qsidba', @v_globalcontacthistorykey output
	    insert into globalcontacthistory
	    values(@v_globalcontacthistorykey, @i_newglobalcontactkey, 6, getdate(), '(Not Present)', 'contact_import', @v_lastname, 'Last Name', null)
    end
    
	if @v_middlename_import is not null begin
		exec get_next_key 'qsidba', @v_globalcontacthistorykey output
		insert into globalcontacthistory
		values(@v_globalcontacthistorykey, @i_newglobalcontactkey, 7, getdate(), '(Not Present)', 'contact_import', @v_middlename_import, 'Middle Name', null)
	end  

	set @v_accreditation_desc = null
	select @v_accreditation_desc = datadesc
	from gentables 
	where tableid = 210
	and datacode = @v_accreditationcode_import

	if @v_accreditation_desc is not null begin
		exec get_next_key 'qsidba', @v_globalcontacthistorykey output
		insert into globalcontacthistory
		values(@v_globalcontacthistorykey, @i_newglobalcontactkey, 8, getdate(), '(Not Present)', 'contact_import', @v_accreditation_desc, 'Accreditation', null)
	end 

	if @v_errind = 0 begin
		update globalcontact
		set globalcontactnotes  = (select  'Import Successful. ' + @v_cariadgereturn + isNull(globalcontactnotes, '') + @v_cariadgereturn
								   from globalcontact
								   where globalcontactkey = @i_newglobalcontactkey) 
		where globalcontactkey = @i_newglobalcontactkey
	end

	update globalcontact
	set globalcontactnotes  = (select  'Contact Imported on ' + @v_date + @v_cariadgereturn + IsNull(globalcontactnotes, '')
							   from globalcontact
							   where globalcontactkey = @i_newglobalcontactkey) 
	where globalcontactkey = @i_newglobalcontactkey



    SELECT @v_global_contactkey_match = @i_newglobalcontactkey
    
	set @v_retcode = 0
	END


/******************************************************************************************************************
 ******************************************************************************************************************
 **
 **     07/31/09 Lisa moved common record inserts down here 
 **
 ******************************************************************************************************************
 ******************************************************************************************************************/

    if ( @v_global_contactkey_match > 0 )
    BEGIN -- COMMON RECORD INSERTS
    
--########################## GLOBALCONTACTROLE - ROLE 1 UPDATES ################################
			if @v_role1_externalid is not null begin
			exec dbo.get_gentables_externalcode_datacode 285, @v_role1_externalid, @v_datacode OUTPUT 
				if @v_datacode > 0 begin
					select @v_cnt = count(*)
					from globalcontactrole
					where globalcontactkey = @v_global_contactkey_match
					and rolecode = @v_datacode

					if @v_cnt  = 0 begin
						insert into globalcontactrole (Globalcontactkey, Rolecode, Keyind, Sortorder)
						values(@v_global_contactkey_match, @v_datacode, 1, 1)
						
					end
				end else begin
					update globalcontact
					set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Role could not be found for external code ' + @v_role1_externalid + '.' + @v_cariadgereturn
											   from globalcontact
											   where globalcontactkey = @v_global_contactkey_match) 
					where globalcontactkey = @v_global_contactkey_match
					set @v_errind = 1
					
				end
			end

--########################## GLOBALCONTACTROLE - ROLE 2 UPDATES ################################
			if @v_role2_externalid is not null begin
			
			exec dbo.get_gentables_externalcode_datacode 285, @v_role2_externalid, @v_datacode OUTPUT 
			--print 'Role 2 ' + @v_role2_externalid + ' ' + convert(varchar, (isNull(@v_datacode,99)))
				if @v_datacode > 0 begin
					select @v_cnt = count(*)
					from globalcontactrole
					where globalcontactkey = @v_global_contactkey_match
					and rolecode = @v_datacode

					if @v_cnt  = 0 begin
						insert into globalcontactrole (Globalcontactkey, Rolecode, Keyind, Sortorder)
						values(@v_global_contactkey_match, @v_datacode, 1, 2)
						
					end
				end else begin
					update globalcontact
					set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Role could not be found for external code ' + @v_role2_externalid + '.' + @v_cariadgereturn
											   from globalcontact
											   where globalcontactkey = @v_global_contactkey_match) 
					where globalcontactkey = @v_global_contactkey_match
					set @v_errind = 1
					
				end
			end

--########################## GLOBALCONTACTROLE - ROLE 3 UPDATES ################################
			if @v_role3_externalid is not null begin
			exec dbo.get_gentables_externalcode_datacode 285, @v_role3_externalid, @v_datacode OUTPUT 
			--print 'Role 3 ' + @v_role3_externalid + ' ' + convert(varchar, (isNull(@v_datacode,99)))
				if @v_datacode > 0 begin
					select @v_cnt = count(*)
					from globalcontactrole
					where globalcontactkey = @v_global_contactkey_match
					and rolecode = @v_datacode

					if @v_cnt  = 0 begin
						insert into globalcontactrole (Globalcontactkey, Rolecode, Keyind, Sortorder)
						values(@v_global_contactkey_match, @v_datacode, 0, 3)
						
					end
				end else begin
					update globalcontact
					set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Role could not be found for external code ' + @v_role3_externalid + '.' + @v_cariadgereturn
											   from globalcontact
											   where globalcontactkey = @v_global_contactkey_match) 
					where globalcontactkey = @v_global_contactkey_match
					set @v_errind = 1
					
				end
			end
			
--########################## GLOBALCONTACTROLE - ROLE 4 UPDATES ################################
			if @v_role4_externalid is not null begin
			exec dbo.get_gentables_externalcode_datacode 285, @v_role4_externalid, @v_datacode OUTPUT 
			--print 'Role 4 ' + @v_role4_externalid + ' ' + convert(varchar, (isNull(@v_datacode,99)))
				if @v_datacode > 0 begin
					select @v_cnt = count(*)
					from globalcontactrole
					where globalcontactkey = @v_global_contactkey_match
					and rolecode = @v_datacode

					if @v_cnt  = 0 begin
						insert into globalcontactrole (Globalcontactkey, Rolecode, Keyind, Sortorder)
						values(@v_global_contactkey_match, @v_datacode, 0, 4)
						
					end
				end else begin
					update globalcontact
					set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Role could not be found for external code ' + @v_role4_externalid + '.' + @v_cariadgereturn
											   from globalcontact
											   where globalcontactkey = @v_global_contactkey_match) 
					where globalcontactkey = @v_global_contactkey_match
					set @v_errind = 1
					
				end
			end
	
--########################## GLOBALCONTACTROLE - ROLE 5 UPDATES ################################
			if @v_role5_externalid is not null begin
			exec dbo.get_gentables_externalcode_datacode 285, @v_role5_externalid, @v_datacode OUTPUT 
			--print 'Role 5 ' + @v_role5_externalid + ' ' + convert(varchar, (isNull(@v_datacode,99)))
				if @v_datacode > 0 begin
					select @v_cnt = count(*)
					from globalcontactrole
					where globalcontactkey = @v_global_contactkey_match
					and rolecode = @v_datacode

					if @v_cnt  = 0 begin
						insert into globalcontactrole (Globalcontactkey, Rolecode, Keyind, Sortorder)
						values(@v_global_contactkey_match, @v_datacode, 0, 5)
						
					end
				end else begin
					update globalcontact
					set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Role could not be found for external code ' + @v_role5_externalid + '.' + @v_cariadgereturn
											   from globalcontact
											   where globalcontactkey = @v_global_contactkey_match) 
					where globalcontactkey = @v_global_contactkey_match
					set @v_errind = 1
					
				end
			end		
		
		
--########################## GLOBALCONTACTCATEGORY - CATEGORY 1 UPDATES ################################
		if @v_category1_externalid is not null 
		begin
            exec dbo.get_gentables_category_code 518, @v_category1_externalid, @v_datacode OUTPUT, @v_datasubcode OUTPUT, @v_datasub2code OUTPUT
 
		    if ( @v_datacode is null or @v_datasubcode is null or @v_datasub2code is null ) 
		    begin
			    update globalcontact
			    set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Category not found for table id ' + cast(@v_category1_tableid as varchar) + ' external1 code ' + @v_category1_externalid + ' external2 code = ' + @v_category1_externalid + '.' + @v_cariadgereturn
									       from globalcontact
									       where globalcontactkey = @v_global_contactkey_match) 
			    where globalcontactkey = @v_global_contactkey_match
			    set @v_errind = 1
            end 
            else 
            begin
			    select @v_cnt = count(*)
			    from globalcontactcategory
			    where contactcategorycode = @v_datacode
			    and	  contactcategorysubcode = @v_datasubcode
			    and	  contactcategorysub2code  = @v_datasub2code
			    and   Globalcontactkey = @v_global_contactkey_match 

			    if @v_cnt = 0 
			    begin
					insert into globalcontactcategory (Globalcontactkey,
														Tableid,	
														Contactcategorycode,
														Contactcategorysubcode,
														Contactcategorysub2code,
														Keyind,
														Sortorder,
														lastuserid,
														lastmaintdate)
					values(@v_global_contactkey_match, 
					@v_category1_tableid, 
					@v_datacode, 
					@v_datasubcode, 
					COALESCE(@v_datasub2code,0), 
					1, 
					1, 
					'contact_import',
					getdate())
					
			    end
            end
		end 


--########################## GLOBALCONTACTCATEGORY - CATEGORY 2 UPDATES ################################
		if @v_category2_externalid is not null 
		begin
            exec dbo.get_gentables_category_code 518, @v_category2_externalid, @v_datacode OUTPUT, @v_datasubcode OUTPUT, @v_datasub2code OUTPUT
 
		    if ( @v_datacode is null or @v_datasubcode is null or @v_datasub2code is null ) 
		    begin
				update globalcontact
				set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Category could not be found for table id ' + cast(@v_category2_tableid as varchar) + ' with external code ' + @v_category2_externalid + @v_cariadgereturn
										   from globalcontact
										   where globalcontactkey = @v_global_contactkey_match) 
				where globalcontactkey = @v_global_contactkey_match
				set @v_errind = 1
				
			end 
			else 
			begin
				select @v_cnt = count(*)
				from globalcontactcategory
				where contactcategorycode = @v_datacode
				and	  contactcategorysubcode = @v_datasubcode
				and	  contactcategorysub2code  = @v_datasub2code
				and   Globalcontactkey = @v_global_contactkey_match 

				if @v_cnt = 0 
				begin
						insert into globalcontactcategory (Globalcontactkey,
															Tableid,	
															Contactcategorycode,
															Contactcategorysubcode,
															Contactcategorysub2code,
															Keyind,
															Sortorder,
															lastuserid,
															lastmaintdate)
						values(@v_global_contactkey_match, 
						@v_category2_tableid, 
						@v_datacode, 
						@v_datasubcode, 
						COALESCE(@v_datasub2code,0), 
						1, 
						2, 
						'contact_import',
						getdate())
				
				end
			end 
		end

--########################## GLOBALCONTACTCATEGORY - CATEGORY 3 UPDATES ################################
		if @v_category3_externalid is not null 
		begin
            exec dbo.get_gentables_category_code 518, @v_category3_externalid, @v_datacode OUTPUT, @v_datasubcode OUTPUT, @v_datasub2code OUTPUT
 
		    if ( @v_datacode is null or @v_datasubcode is null or @v_datasub2code is null ) 
            begin
				update globalcontact
				set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Category could not be found for table id ' + cast(@v_category3_tableid as varchar) + ' with external code ' + @v_category3_externalid + @v_cariadgereturn
										   from globalcontact
										   where globalcontactkey = @v_global_contactkey_match) 
				where globalcontactkey = @v_global_contactkey_match
				set @v_errind = 1
				
			end 
			else 
			begin
				select @v_cnt = count(*)
				from globalcontactcategory
				where contactcategorycode = @v_datacode
				and	  contactcategorysubcode = @v_datasubcode
				and	  contactcategorysub2code  = @v_datasub2code
				and   Globalcontactkey = @v_global_contactkey_match 

				if @v_cnt = 0 
				begin
						insert into globalcontactcategory (Globalcontactkey,
															Tableid,	
															Contactcategorycode,
															Contactcategorysubcode,
															Contactcategorysub2code,
															Keyind,
															Sortorder,
															lastuserid,
															lastmaintdate)
						values(@v_global_contactkey_match, 
						@v_category3_tableid, 
						@v_datacode, 
						@v_datasubcode, 
						COALESCE(@v_datasub2code,0), 
						0, 
						3, 
						'contact_import',
						getdate())
				
				end
			end 
		end

--########################## GLOBALCONTACTCATEGORY - CATEGORY 4 UPDATES ################################
		if @v_category4_externalid is not null 
		begin
            exec dbo.get_gentables_category_code 518, @v_category4_externalid, @v_datacode OUTPUT, @v_datasubcode OUTPUT, @v_datasub2code OUTPUT
 
		    if ( @v_datacode is null or @v_datasubcode is null or @v_datasub2code is null ) 
            begin
				update globalcontact
				set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Category could not be found for table id ' + cast(@v_category4_tableid as varchar) + ' with external code ' + @v_category4_externalid + @v_cariadgereturn
										   from globalcontact
										   where globalcontactkey = @v_global_contactkey_match) 
				where globalcontactkey = @v_global_contactkey_match
				set @v_errind = 1
				
			end 
			else 
			begin
				select @v_cnt = count(*)
				from globalcontactcategory
				where contactcategorycode = @v_datacode
				and	  contactcategorysubcode = @v_datasubcode
				and	  contactcategorysub2code  = @v_datasub2code
				and   Globalcontactkey = @v_global_contactkey_match 

				if @v_cnt = 0 
				begin
						insert into globalcontactcategory (Globalcontactkey,
															Tableid,	
															Contactcategorycode,
															Contactcategorysubcode,
															Contactcategorysub2code,
															Keyind,
															Sortorder,
															lastuserid,
															lastmaintdate)
						values(@v_global_contactkey_match, 
						@v_category4_tableid, 
						@v_datacode, 
						@v_datasubcode, 
						COALESCE(@v_datasub2code,0), 
						0, 
						4, 
						'contact_import',
						getdate())
				
				end
			end 
		end
		
--########################## GLOBALCONTACTCATEGORY - CATEGORY 5 UPDATES ################################
		if @v_category5_externalid is not null 
		begin
            exec dbo.get_gentables_category_code 518, @v_category5_externalid, @v_datacode OUTPUT, @v_datasubcode OUTPUT, @v_datasub2code OUTPUT
 
		    if ( @v_datacode is null or @v_datasubcode is null or @v_datasub2code is null ) 
            begin
				update globalcontact
				set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Category could not be found for table id ' + cast(@v_category5_tableid as varchar) + ' with external code ' + @v_category5_externalid + @v_cariadgereturn
										   from globalcontact
										   where globalcontactkey = @v_global_contactkey_match) 
				where globalcontactkey = @v_global_contactkey_match
				set @v_errind = 1
				
			end 
			else 
			begin
				select @v_cnt = count(*)
				from globalcontactcategory
				where contactcategorycode = @v_datacode
				and	  contactcategorysubcode = @v_datasubcode
				and	  contactcategorysub2code  = @v_datasub2code
				and   Globalcontactkey = @v_global_contactkey_match 

				if @v_cnt = 0 
				begin
						insert into globalcontactcategory (Globalcontactkey,
															Tableid,	
															Contactcategorycode,
															Contactcategorysubcode,
															Contactcategorysub2code,
															Keyind,
															Sortorder,
															lastuserid,
															lastmaintdate)
						values(@v_global_contactkey_match, 
						@v_category5_tableid, 
						@v_datacode, 
						@v_datasubcode, 
						COALESCE(@v_datasub2code,0), 
						0, 
						5, 
						'contact_import',
						getdate())
				
				end
			end 
		end


--########################## GLOBALCONTACTMETHOD - ADDITIONAL TYPE1 UPDATES ################################
/*******************************************************************************************************
 *  Adding additional communication types as globalcontactmethod records
 *  These records are matched to subgentables on externalcode only.  It is assumed that the codes
 *  are unique.
 *******************************************************************************************************/
 
	set @v_sortorder = 0
	
    -- External additional contact method #1 of 5

    if @v_contact_method_externalid1 is not null and len(@v_contact_method_externalid1) > 0 
    begin
        select @v_globalcontactmethodkey = 0
		select @v_datacode = 1	
		exec dbo.get_subgentables_external_datacodes 517, @v_contact_method_externalid1, @v_datacode OUTPUT, @v_datasubcode OUTPUT 

		if @v_datasubcode > 0 and len(isnull(@v_contact_method_value1,'')) > 0
		begin
            --Check to see if a record exists for this contactmethod, contactmethodsub code and contactmethodvalue
            select @v_cnt = count(*) 
            from globalcontactmethod
            where globalcontactkey = @v_global_contactkey_match 
            and contactmethodcode = @v_datacode
            and contactmethodsubcode = @v_datasubcode
            and REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(contactmethodvalue, '-', ''), '(',''), ')', ''), '.', ''), '/', '') = 
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@v_contact_method_value1, '-', ''), '(',''), ')', ''), '.', ''), '/', '')

            if @v_cnt = 0 
            begin            
                -- Find the globalcontactmethod record for for the additional contact method if it exists
                -- for this contact
                
	            select @v_globalcontactmethodkey = globalcontactmethodkey
	            from globalcontactmethod
	            where globalcontactkey = @v_global_contactkey_match 
	            and contactmethodcode = @v_datacode
                --and contactmethodsubcode = @v_datasubcode
	            and primaryind = 1

                if isnull(@v_globalcontactmethodkey,0) > 0 
                begin
                    set @v_primaryind = 0
                    set @v_sortorder = ( select max(COALESCE(sortorder,0)) + 1 from globalcontactmethod
                                                     where globalcontactkey = @v_global_contactkey_match
                                                     and contactmethodcode = @v_datacode
                                                     and contactmethodsubcode = @v_datasubcode )
                end
                else
                begin
                    set @v_primaryind = 1
                    set @v_sortorder = 1
                end
                							
			    --Append to the Contact Note and Create a new globalcontactmethod record 
			    select @v_contactmethodvalue = contactmethodvalue
			    from globalcontactmethod
			    where globalcontactmethodkey = @v_globalcontactmethodkey

			    update globalcontact
			    set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import added contact method 1 ' +  @v_contact_method_value1 
									       from globalcontact
									       where globalcontactkey = @v_global_contactkey_match) 
			    where globalcontactkey = @v_global_contactkey_match
			    set @v_errind = 1
							
				exec get_next_key 'qsidba', @i_globalcontactmethodkey_addtl1 output
				
				insert into globalcontactmethod (globalcontactmethodkey,
												 globalcontactkey,
												 contactmethodcode,
												 contactmethodsubcode,
												 contactmethodvalue,
												 primaryind,
												 sortorder,
												 lastuserid,
												 lastmaintdate)
                                         values( @i_globalcontactmethodkey_addtl1,
												 @v_global_contactkey_match,
												 @v_datacode,
												 @v_datasubcode,
												 @v_contact_method_value1,
												 @v_primaryind,
												 @v_sortorder,
												 'contact_import',
												 getdate() )								 
						
            end 
		end 
		else 
		begin
			update globalcontact
			set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact Communication Method 1 not found for external code = ' + IsNull(@v_contact_method_externalid1, 'null.') + ', value is ' + isNull(@v_contact_method_value1, 'Null')+ @v_cariadgereturn
									   from globalcontact
									   where globalcontactkey = @v_global_contactkey_match) 
			where globalcontactkey = @v_global_contactkey_match
			set @v_errind = 1
			
		end
    end 

    -- External additional contact method #2 of 5
    
    if @v_contact_method_externalid2 is not null and len(@v_contact_method_externalid2) > 0 
    begin
        select @v_globalcontactmethodkey = 0
		select @v_datacode = 1		
		exec dbo.get_subgentables_external_datacodes 517, @v_contact_method_externalid2, @v_datacode OUTPUT, @v_datasubcode OUTPUT 

		if @v_datasubcode > 0 and len(isnull(@v_contact_method_value2,'')) > 0 		
		begin
            --Check to see if a record exists for this contactmethod, contactmethodsub code and contactmethodvalue
            select @v_cnt = count(*) 
            from globalcontactmethod
            where globalcontactkey = @v_global_contactkey_match 
            and contactmethodcode = @v_datacode
            and contactmethodsubcode = @v_datasubcode
            and REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(contactmethodvalue, '-', ''), '(',''), ')', ''), '.', ''), '/', '') = 
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@v_contact_method_value2, '-', ''), '(',''), ')', ''), '.', ''), '/', '')

            if @v_cnt = 0 
            begin           
                -- Find the globalcontactmethod record for for the additional contact method if it exists
                -- for this contact
                
	            select @v_globalcontactmethodkey = globalcontactmethodkey
	            from globalcontactmethod
	            where globalcontactkey = @v_global_contactkey_match 
	            and contactmethodcode = @v_datacode
                --and contactmethodsubcode = @v_datasubcode
	            and primaryind = 1

                if isnull(@v_globalcontactmethodkey,0) > 0 
                begin
                    set @v_primaryind = 0
                    set @v_sortorder = ( select max(COALESCE(sortorder,0)) + 1 from globalcontactmethod
                                                     where globalcontactkey = @v_global_contactkey_match
                                                     and contactmethodcode = @v_datacode
                                                     and contactmethodsubcode = @v_datasubcode )
                end
                else
                begin
                    set @v_primaryind = 1
                    set @v_sortorder = 1
                end
                							
			    --Append to the Contact Note and Create a new globalcontactmethod record 
			    select @v_contactmethodvalue = contactmethodvalue
			    from globalcontactmethod
			    where globalcontactmethodkey = @v_globalcontactmethodkey

			    update globalcontact
			    set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import added contact method 2 ' +  @v_contact_method_value2 
									       from globalcontact
									       where globalcontactkey = @v_global_contactkey_match) 
			    where globalcontactkey = @v_global_contactkey_match
			    set @v_errind = 1
							
				exec get_next_key 'qsidba', @i_globalcontactmethodkey_addtl2 output
				
				insert into globalcontactmethod (globalcontactmethodkey,
												 globalcontactkey,
												 contactmethodcode,
												 contactmethodsubcode,
												 contactmethodvalue,
												 primaryind,
												 sortorder,
												 lastuserid,
												 lastmaintdate)
                                         values( @i_globalcontactmethodkey_addtl2,
												 @v_global_contactkey_match,
												 @v_datacode,
												 @v_datasubcode,
												 @v_contact_method_value2,
												 @v_primaryind,
												 @v_sortorder,
												 'contact_import',
												 getdate() )								 
						
            end 
		end 
		else 
		begin
			update globalcontact
			set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact Communication Method 2 not found for external code = ' + IsNull(@v_contact_method_externalid2, 'null.') + ', value is ' + isNull(@v_contact_method_value2, 'Null')+ @v_cariadgereturn
									   from globalcontact
									   where globalcontactkey = @v_global_contactkey_match) 
			where globalcontactkey = @v_global_contactkey_match
			set @v_errind = 1
			
		end
    end 

    -- External additional contact method #3 of 5
    
    if @v_contact_method_externalid3 is not null and len(@v_contact_method_externalid3) > 0 
    begin
        select @v_globalcontactmethodkey = 0
		select @v_datacode = 1		
		exec dbo.get_subgentables_external_datacodes 517, @v_contact_method_externalid3, @v_datacode OUTPUT, @v_datasubcode OUTPUT 

		if @v_datasubcode > 0 and len(isnull(@v_contact_method_value3,'')) > 0		
		begin
            --Check to see if a record exists for this contactmethod, contactmethodsub code and contactmethodvalue
            select @v_cnt = count(*) 
            from globalcontactmethod
            where globalcontactkey = @v_global_contactkey_match 
            and contactmethodcode = @v_datacode
            --and contactmethodsubcode = @v_datasubcode
            and REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(contactmethodvalue, '-', ''), '(',''), ')', ''), '.', ''), '/', '') = 
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@v_contact_method_value3, '-', ''), '(',''), ')', ''), '.', ''), '/', '')

            if @v_cnt = 0 
            begin           
                -- Find the globalcontactmethod record for for the additional contact method if it exists
                -- for this contact
                
	            select @v_globalcontactmethodkey = globalcontactmethodkey
	            from globalcontactmethod
	            where globalcontactkey = @v_global_contactkey_match 
	            and contactmethodcode = @v_datacode
                and contactmethodsubcode = @v_datasubcode
	            and primaryind = 1

                if isnull(@v_globalcontactmethodkey,0) > 0 
                begin
                    set @v_primaryind = 0
                    set @v_sortorder = ( select max(COALESCE(sortorder,0)) + 1 from globalcontactmethod
                                                     where globalcontactkey = @v_global_contactkey_match
                                                     and contactmethodcode = @v_datacode
                                                     and contactmethodsubcode = @v_datasubcode )
                end
                else
                begin
                    set @v_primaryind = 1
                    set @v_sortorder = 1
                end
                							
			    --Append to the Contact Note and Create a new globalcontactmethod record 
			    select @v_contactmethodvalue = contactmethodvalue
			    from globalcontactmethod
			    where globalcontactmethodkey = @v_globalcontactmethodkey

			    update globalcontact
			    set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import added contact method 3 ' +  @v_contact_method_value3 
									       from globalcontact
									       where globalcontactkey = @v_global_contactkey_match) 
			    where globalcontactkey = @v_global_contactkey_match
			    set @v_errind = 1
							
				exec get_next_key 'qsidba', @i_globalcontactmethodkey_addtl3 output
				
				insert into globalcontactmethod (globalcontactmethodkey,
												 globalcontactkey,
												 contactmethodcode,
												 contactmethodsubcode,
												 contactmethodvalue,
												 primaryind,
												 sortorder,
												 lastuserid,
												 lastmaintdate)
                                         values( @i_globalcontactmethodkey_addtl3,
												 @v_global_contactkey_match,
												 @v_datacode,
												 @v_datasubcode,
												 @v_contact_method_value3,
												 @v_primaryind,
												 @v_sortorder,
												 'contact_import',
												 getdate() )								 
						
            end 
		end 
		else 
		begin
			update globalcontact
			set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact Communication Method 3 not found for external code = ' + IsNull(@v_contact_method_externalid3, 'null.') + ', value is ' + isNull(@v_contact_method_value3, 'Null')+ @v_cariadgereturn
									   from globalcontact
									   where globalcontactkey = @v_global_contactkey_match) 
			where globalcontactkey = @v_global_contactkey_match
			set @v_errind = 1
			
		end
    end 

    -- External additional contact method #4 of 5
    
    if @v_contact_method_externalid4 is not null and len(@v_contact_method_externalid4) > 0 
    begin
        select @v_globalcontactmethodkey = 0
		select @v_datacode = 1		
		exec dbo.get_subgentables_external_datacodes 517, @v_contact_method_externalid4, @v_datacode OUTPUT, @v_datasubcode OUTPUT 
		
		if @v_datasubcode > 0 and len(isnull(@v_contact_method_value4,'')) > 0		
		begin
            --Check to see if a record exists for this contactmethod, contactmethodsub code and contactmethodvalue
            select @v_cnt = count(*) 
            from globalcontactmethod
            where globalcontactkey = @v_global_contactkey_match 
            and contactmethodcode = @v_datacode
            and contactmethodsubcode = @v_datasubcode
            and REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(contactmethodvalue, '-', ''), '(',''), ')', ''), '.', ''), '/', '') = 
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@v_contact_method_value4, '-', ''), '(',''), ')', ''), '.', ''), '/', '')

            if @v_cnt = 0 
            begin           
                -- Find the globalcontactmethod record for for the additional contact method if it exists
                -- for this contact
                
	            select @v_globalcontactmethodkey = globalcontactmethodkey
	            from globalcontactmethod
	            where globalcontactkey = @v_global_contactkey_match 
	            and contactmethodcode = @v_datacode
                --and contactmethodsubcode = @v_datasubcode
	            and primaryind = 1

                if isnull(@v_globalcontactmethodkey,0) > 0 
                begin
                    set @v_primaryind = 0
                    set @v_sortorder = ( select max(COALESCE(sortorder,0)) + 1 from globalcontactmethod
                                                     where globalcontactkey = @v_global_contactkey_match
                                                     and contactmethodcode = @v_datacode
                                                     and contactmethodsubcode = @v_datasubcode )
                end
                else
                begin
                    set @v_primaryind = 1
                    set @v_sortorder = 1
                end
                							
			    --Append to the Contact Note and Create a new globalcontactmethod record 
			    select @v_contactmethodvalue = contactmethodvalue
			    from globalcontactmethod
			    where globalcontactmethodkey = @v_globalcontactmethodkey

			    update globalcontact
			    set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import added contact method 4 ' +  @v_contact_method_value4 
									       from globalcontact
									       where globalcontactkey = @v_global_contactkey_match) 
			    where globalcontactkey = @v_global_contactkey_match
			    set @v_errind = 1
							
				exec get_next_key 'qsidba', @i_globalcontactmethodkey_addtl4 output
				
				insert into globalcontactmethod (globalcontactmethodkey,
												 globalcontactkey,
												 contactmethodcode,
												 contactmethodsubcode,
												 contactmethodvalue,
												 primaryind,
												 sortorder,
												 lastuserid,
												 lastmaintdate)
                                         values( @i_globalcontactmethodkey_addtl4,
												 @v_global_contactkey_match,
												 @v_datacode,
												 @v_datasubcode,
												 @v_contact_method_value4,
												 @v_primaryind,
												 @v_sortorder,
												 'contact_import',
												 getdate() )								 
						
            end 
		end 
		else 
		begin
			update globalcontact
			set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact Communication Method 4 not found for external code = ' + IsNull(@v_contact_method_externalid4, 'null.') + ', value is ' + isNull(@v_contact_method_value4, 'Null')+ @v_cariadgereturn
									   from globalcontact
									   where globalcontactkey = @v_global_contactkey_match) 
			where globalcontactkey = @v_global_contactkey_match
			set @v_errind = 1
			
		end
    end 

    -- External additional contact method #5 of 5
    
    if @v_contact_method_externalid5 is not null and len(@v_contact_method_externalid5) > 0 
    begin
        select @v_globalcontactmethodkey = 0
		select @v_datacode = 1		
		exec dbo.get_subgentables_external_datacodes 517, @v_contact_method_externalid5, @v_datacode OUTPUT, @v_datasubcode OUTPUT 

		if @v_datasubcode > 0 and len(isnull(@v_contact_method_value5,'')) > 0		
		begin
            --Check to see if a record exists for this contactmethod, contactmethodsub code and contactmethodvalue
            select @v_cnt = count(*) 
            from globalcontactmethod
            where globalcontactkey = @v_global_contactkey_match 
            and contactmethodcode = @v_datacode
            --and contactmethodsubcode = @v_datasubcode
            and REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(contactmethodvalue, '-', ''), '(',''), ')', ''), '.', ''), '/', '') = 
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@v_contact_method_value5, '-', ''), '(',''), ')', ''), '.', ''), '/', '')

            if @v_cnt = 0 
            begin           
                -- Find the globalcontactmethod record for for the additional contact method if it exists
                -- for this contact
                
	            select @v_globalcontactmethodkey = globalcontactmethodkey
	            from globalcontactmethod
	            where globalcontactkey = @v_global_contactkey_match 
	            and contactmethodcode = @v_datacode
                --and contactmethodsubcode = @v_datasubcode
	            and primaryind = 1

                if (isnull(@v_globalcontactmethodkey,0) > 0 )
                begin
                    set @v_primaryind = 0
                    set @v_sortorder = ( select max(COALESCE(sortorder,0)) + 1 from globalcontactmethod
                                                     where globalcontactkey = @v_global_contactkey_match
                                                     and contactmethodcode = @v_datacode
                                                     and contactmethodsubcode = @v_datasubcode )
                end
                else
                begin
                    set @v_primaryind = 1
                    set @v_sortorder = 1
                end
                							
			    --Append to the Contact Note and Create a new globalcontactmethod record 
			    select @v_contactmethodvalue = contactmethodvalue
			    from globalcontactmethod
			    where globalcontactmethodkey = @v_globalcontactmethodkey

			    update globalcontact
			    set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Import added contact method 5 ' +  @v_contact_method_value5 
									       from globalcontact
									       where globalcontactkey = @v_global_contactkey_match) 
			    where globalcontactkey = @v_global_contactkey_match
			    set @v_errind = 1
							
				exec get_next_key 'qsidba', @i_globalcontactmethodkey_addtl5 output
				
				insert into globalcontactmethod (globalcontactmethodkey,
												 globalcontactkey,
												 contactmethodcode,
												 contactmethodsubcode,
												 contactmethodvalue,
												 primaryind,
												 sortorder,
												 lastuserid,
												 lastmaintdate)
                                         values( @i_globalcontactmethodkey_addtl5,
												 @v_global_contactkey_match,
												 @v_datacode,
												 @v_datasubcode,
												 @v_contact_method_value5,
												 @v_primaryind,
												 @v_sortorder,
												 'contact_import',
												 getdate() )								 
						
            end 
		end 
		else 
		begin
			update globalcontact
			set globalcontactnotes  = (select isNull(globalcontactnotes, '') + ' Contact Communication Method 5 not found for external code = ' + IsNull(@v_contact_method_externalid5, 'null.') + ', value is ' + isNull(@v_contact_method_value5, 'Null')+ @v_cariadgereturn
									   from globalcontact
									   where globalcontactkey = @v_global_contactkey_match) 
			where globalcontactkey = @v_global_contactkey_match
			set @v_errind = 1
			
		end
    end 

    END -- COMMON RECORD INSERTS
    
--############################################# END  ###############################################
	
	update globalcontact_import 
	set processedind = 1, processdate = getdate(), globalcontactkey = isNull(@i_newglobalcontactkey, @v_global_contactkey_match)
	where globalcontactrequestkey = @i_globalcontactrequestkey
	
END
GO

GRANT EXEC ON globalcontact_import_sp TO PUBLIC
GO
