SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
if exists (select * from dbo.sysobjects where id = Object_id('dbo.create_project_from_project_import') and (type = 'P' or type = 'TR'))
begin
 drop proc dbo.create_project_from_project_import
end
go


create PROCEDURE dbo.create_project_from_project_import
AS

declare
@v_xxx varchar(100),
@v_taqprojectcontact_addresskey int,
@v_retcode int,
@v_qsidatacode int,
@v_qsidatasubcode int,
@v_ind tinyint,
@v_new_commentkey int,
@v_globalcontactrequestkey int,
@v_sucess_ind tinyint,
@v_title	varchar(100),
@v_Relatedbook_title	varchar(100),
@v_lastname varchar(50),
@v_first_name varchar(50),
@v_Relatedbook_authorfirstname	varchar(30),
@v_Relatedbook_authorlastname	varchar(30),
@v_commentkey int,
@v_datasubcode int,
@v_datasub2code int,
@v_Projectrolecode_datacode int,
@v_titlerolecode_datacode int,
@v_Taqprojectformatkey int,
@v_bookkey int,
@v_usedefaultemplateind tinyint,
@v_miscitemexternalid varchar(20),
@v_errorcode int,
@v_Comment1	varchar(8000),
@v_Comment2	varchar(8000),
@v_Comment3	varchar(8000),
@v_Comment4	varchar(8000),
@v_Comment5	varchar(8000),
@v_longvalue int,
@v_floatvalue float,
@v_textvalue varchar(500),
@v_misctype int,
@v_misckey int,
@v_miscvalue varchar(100),
@v_alternatemiscitem_externalid varchar(20),
@v_Taqtaskkey int,
@v_Subjectkey int,
@v_taqkeyind tinyint, 
@v_task1_actualind tinyint, 
@v_task2_actualind tinyint, 
@v_task3_actualind tinyint, 
@v_task4_actualind tinyint, 
@v_task5_actualind tinyint,
@v_Task1_date datetime, 
@v_Task2_date datetime,  
@v_Task3_date datetime,  
@v_Task4_date datetime,  
@v_Task5_date datetime, 
@v_datetype int,
@v_Task1_externalid varchar(30), 
@v_Task2_externalid varchar(30), 
@v_Task3_externalid varchar(30), 
@v_Task4_externalid varchar(30), 
@v_Task5_externalid varchar(30), 
@v_Taqprojectcontactrolekey int,
@v_role1_externalid varchar(30),
@v_role2_externalid varchar(30),
@o_error_code int,
@o_error_desc varchar(2000),
@v_sort_order int,
@v_Globalcontactkey int,
@v_Taqprojectcontactkey int,
@v_Projectowner varchar(50),
@v_usageclass int,
@v_template_projectkey int,
@v_datacode int,
@v_Projecttype_externalid varchar(30),
@v_Projectstatus_externalid varchar(30),
@v_project_type_datacode int,
@v_cnt int,
@v_error_ind int,
@v_new_projectkey int,
@v_Projectname varchar(100),
@v_Itemtypecode int,
@v_Usageclass_qsicode  int,
@v_projectimportkey int,
@v_Orgentry1  int, 
@v_Orgentry2  int, 
@v_Orgentry3  int,
@v_processerrormessage varchar(8000),
@v_msg  varchar(8000),
@v_Titlerole_externalid varchar(30),
@v_Projectrole_externalid varchar(30),
@v_Comment_externalid1 varchar(30),
@v_Comment_externalid2 varchar(30),
@v_Comment_externalid3 varchar(30),
@v_Comment_externalid4 varchar(30),
@v_Comment_externalid5 varchar(30),
@v_category1_externalid varchar(30),
@v_category2_externalid varchar(30),
@v_category1_tableid int, 
@v_category2_tableid int,
@v_relatedbook_productid	varchar(30)

declare c_project cursor for
select usedefaultemplateind, projectimportkey, Projectname, Itemtypecode, Usageclass_qsicode, Orgentry1, Orgentry2, Orgentry3, Projecttype_externalid, Projectowner,
	   Task1_externalid, Task2_externalid, Task3_externalid, Task4_externalid, Task5_externalid, Task1_date, Task2_date, Task3_date, Task4_date, Task5_date,
	   task1_actualind, task2_actualind, task3_actualind, task4_actualind, task5_actualind, Titlerole_externalid, Projectrole_externalid,
	   substring(comment1, 1, 8000), substring(comment2, 1, 8000), substring(comment3, 1, 8000), substring(comment4, 1, 8000), substring(comment5, 1, 8000),
	   Comment_externalid1, Comment_externalid2, Comment_externalid3, Comment_externalid4, Comment_externalid5,
	   category1_externalid, category2_externalid, category1_tablelid, category2_tablelid, relatedbook_productid,
	   Relatedbook_authorfirstname, Relatedbook_authorlastname, Relatedbook_title, Projectstatus_externalid
from project_import
where Processedind = 0


  OPEN c_project
  FETCH c_project INTO	@v_usedefaultemplateind, @v_projectimportkey, @v_Projectname, @v_Itemtypecode, @v_Usageclass_qsicode, @v_Orgentry1, @v_Orgentry2, @v_Orgentry3,@v_Projecttype_externalid, @v_Projectowner,
						@v_Task1_externalid, @v_Task2_externalid, @v_Task3_externalid, @v_Task4_externalid, @v_Task5_externalid,
					    @v_Task1_date, @v_Task2_date, @v_Task3_date, @v_Task4_date, @v_Task5_date,
						@v_task1_actualind, @v_task2_actualind, @v_task3_actualind, @v_task4_actualind, @v_task5_actualind, 
						@v_Titlerole_externalid, @v_Projectrole_externalid,
						@v_comment1, @v_comment2, @v_comment3, @v_comment4, @v_comment5,
						@v_Comment_externalid1, @v_Comment_externalid2, @v_Comment_externalid3, @v_Comment_externalid4, @v_Comment_externalid5,
						@v_category1_externalid, @v_category2_externalid, @v_category1_tableid, @v_category2_tableid, @v_relatedbook_productid,
						@v_Relatedbook_authorfirstname, @v_Relatedbook_authorlastname, @v_Relatedbook_title, @v_Projectstatus_externalid

  while (@@FETCH_STATUS = 0) 
    begin 


	update project_import
	set processerrormessage = null
	where projectimportkey = @v_projectimportkey 

	-- VERIFY THE IMPORT RECORD
	--project name, item type and usage class must be there Check to make sure that all org entries 
	--that are required exist on the import record and are valid.  
	set @v_error_ind = 0
	set @v_processerrormessage = 'Project cannot be added due missing '
	if @v_Projectname is null begin
		set @v_processerrormessage = @v_processerrormessage + 'Project Name, '
		update project_import
		set processerrormessage = @v_processerrormessage
		where projectimportkey = @v_projectimportkey 
		set @v_error_ind = 1
	end
	if  @v_Itemtypecode is null begin
		set @v_processerrormessage = @v_processerrormessage + 'Item Type, '
		update project_import
		set processerrormessage = @v_processerrormessage, Processedind = 2, Processdate	= getdate()
		where projectimportkey = @v_projectimportkey 
		set @v_error_ind = 1
	end	
	if @v_Usageclass_qsicode is null begin
		set @v_processerrormessage = @v_processerrormessage + 'Usage Class, '
		update project_import
		set processerrormessage = @v_processerrormessage, Processedind = 2, Processdate	= getdate()
		where projectimportkey = @v_projectimportkey 
		set @v_error_ind = 1
	end	
	if @v_Orgentry1 is  null or @v_Orgentry2 is null or @v_Orgentry3 is null begin
		set @v_processerrormessage = @v_processerrormessage + 'One of org entries, '
		update project_import
		set processerrormessage = @v_processerrormessage, Processedind = 2, Processdate	= getdate()
		where projectimportkey = @v_projectimportkey 
		set @v_error_ind = 1
	end	

	if @v_error_ind = 1 begin	
		--remove last coma
		update project_import 
		set processerrormessage = (select substring(processerrormessage, 1, len(processerrormessage)-1 ) + '. ' from project_import
						   where projectimportkey = @v_projectimportkey)
		where projectimportkey = @v_projectimportkey
		goto getnext
	end
	set @v_processerrormessage = ''
	
	exec get_next_key 'qsidba', @v_new_projectkey output

		--APPLY TEMPLATE
	if @v_usedefaultemplateind = 1 begin 
		--Find the usage class by matching the usageclass_id to the externalcode on subgentables for item type (tableid 550), datacode=itemtypecode. 
		set @v_usageclass = 0
		select @v_usageclass = datasubcode
		from subgentables 
		where qsicode = @v_Usageclass_qsicode
		and datacode = @v_Itemtypecode
		and tableid = 550
		
		--Find the project type data code by matching projecttype_externalid to the externalcode on gentables for tableid 521.  
		--If not found, set project type to null

		if @v_usageclass > 0 begin
			set @v_project_type_datacode = null
			select @v_project_type_datacode = datacode
			from gentables
			where tableid = 521
			and externalcode = @v_Projecttype_externalid

			
			--Find default template
			set @v_template_projectkey = 0
				SELECT @v_template_projectkey = projectkey
				from coreprojectinfo
				WHERE searchitemcode = @v_Itemtypecode 
				AND projecttype = @v_project_type_datacode
				AND usageclasscode = @v_usageclass
				AND defaulttemplateind = 1
				AND templateind = 1		


			if @v_template_projectkey = 0 begin
				SELECT @v_template_projectkey = projectkey
				from coreprojectinfo
				WHERE searchitemcode = @v_Itemtypecode 
				AND projecttype is null
				AND usageclasscode = @v_usageclass
				AND defaulttemplateind = 1
				AND templateind = 1		
			end

			if @v_template_projectkey = 0 begin
				update project_import
				set processerrormessage = (select IsNull(processerrormessage, '') + ' Warning:  No default template found but project created anyway.'
										   where projectimportkey = @v_projectimportkey )
				where projectimportkey = @v_projectimportkey 
				set @v_ind = 0
			end else begin
				set @v_new_projectkey = null
				exec qproject_copy_project @v_template_projectkey,
											null,
											null,
											null,
											0,
											0,
											0,
											'qsidba',
											@v_Projectname,
											@v_new_projectkey output,
											@o_error_code output,
											@o_error_desc output

	

				if @o_error_code <> 0 begin
					update project_import
					set processerrormessage = (select IsNull(processerrormessage, '') + ' ' + substring(@o_error_desc, 255, 1) + '.'
											   where projectimportkey = @v_projectimportkey )
					where projectimportkey = @v_projectimportkey 
					goto getnext
				end
				set @v_ind = 1
			end
		end else begin
				update project_import
				set processerrormessage = (select IsNull(processerrormessage, '') + ' Warning:  No usage class found with item type ' + cast(@v_itemtypecode as varchar) + ' and external code ' + @v_Usageclass_qsicode + '.'
										   where projectimportkey = @v_projectimportkey )
				where projectimportkey = @v_projectimportkey 
				set @v_ind = 0
		end
   end --copy templated

	--no template copyed then insert row into taqproject
	if @v_ind = 0 begin

		if @v_Projectowner is null or rtrim(ltrim(@v_Projectowner)) = '' begin
			select @v_Projectowner = clientdefaultvalue
			from clientdefaults
			where clientdefaultid = 48
		end 

		insert into taqproject(taqprojectkey, taqprojectownerkey,taqprojecttitle, usageclasscode, lastuserid, lastmaintdate, searchitemcode)
		values(@v_new_projectkey, @v_Projectowner, @v_Projectname, @v_usageclass, 'project import', getdate(), 3)
	end



	--UPDATE TAQPROJECT RECORD
	if @v_Projectowner is not null begin
		if @v_ind = 1 begin
		  update taqproject
		  set Taqprojectownerkey = @v_Projectowner
		  where taqprojectkey = @v_new_projectkey
		end
	end
	if @v_Projectname  is not null begin
	  if @v_ind = 1 begin
		  update taqproject
		  set Taqprojecttitle = @v_Projectname
		  where taqprojectkey = @v_new_projectkey
	  end
	end

	
		set @v_datacode = null
		select @v_datacode = datacode
		from gentables
		where tableid = 521
		and externalcode = @v_Projecttype_externalid
		
		if @v_datacode is null begin
			update project_import
			set processerrormessage = (select IsNull(processerrormessage, '') + ' Error: Project type null or not found for ' +  IsNull(@v_Projecttype_externalid, 'null') + '.'
									   where projectimportkey = @v_projectimportkey )
			where projectimportkey = @v_projectimportkey 
			goto getnext
		end else begin
				update taqproject
				set Taqprojecttype = @v_datacode
				where taqprojectkey = @v_new_projectkey
		end
	
		set @v_datacode = null
		select @v_datacode = datacode
		from gentables
		where tableid = 522
		and externalcode = @v_Projectstatus_externalid
		
		if @v_datacode is null begin
			update project_import
			set processerrormessage = (select IsNull(processerrormessage, '') + ' Error: Project status null or not found for ' + IsNull(@v_Projectstatus_externalid, 'null') + '.'
									   where projectimportkey = @v_projectimportkey )
			where projectimportkey = @v_projectimportkey 
			goto getnext
		end else begin
				update taqproject
				set Taqprojectstatuscode = @v_datacode
				where taqprojectkey = @v_new_projectkey
		end
	


	  -- CREATE PROJECT CONTACTS
	--Get all contacts that are related to this project by retrieving all records from globalcontact_import 
	--that have a relatedprojectimportkey that matches this projectimportkey.  For each record found, call the Import Global Contact Procedure.  
	declare c_globalcontact cursor for
	select  role1_externalid, role2_externalid, globalcontactrequestkey
	from globalcontact_import
	where relatedprojectimportkey = @v_projectimportkey

	  set @v_sort_order = 0
	  OPEN c_globalcontact
	  FETCH c_globalcontact INTO  @v_role1_externalid, @v_role2_externalid, @v_globalcontactrequestkey
	  while (@@FETCH_STATUS = 0) 
	  begin 
	
		exec globalcontact_import_sp @v_globalcontactrequestkey, @v_globalcontactkey output, @v_retcode output, @v_processerrormessage output, @v_taqprojectcontact_addresskey output

		if @v_globalcontactkey > 0 begin
			set @v_sort_order = @v_sort_order + 1
			exec get_next_key 'qsidba', @v_Taqprojectcontactkey output

			insert into taqprojectcontact(Taqprojectcontactkey, Taqprojectkey, Globalcontactkey, Keyind, Sortorder, Lastmaintdate, lastuserid, addresskey)
			values(@v_Taqprojectcontactkey, @v_new_projectkey, @v_globalcontactkey, 1, @v_sort_order, getdate(), 'import', @v_taqprojectcontact_addresskey)

		if @v_role1_externalid is not null begin
			exec get_next_key 'qsidba', @v_Taqprojectcontactrolekey output
			set @v_datacode = null
			select  @v_datacode = datacode
			from gentables
			where tableid = 285
			and externalcode = @v_role1_externalid

			if @v_datacode is not null begin

				insert into taqprojectcontactrole(Taqprojectcontactrolekey, Taqprojectcontactkey, Taqprojectkey, Rolecode, Activeind, Lastmaintdate, lastuserid)
				values(@v_Taqprojectcontactrolekey, @v_Taqprojectcontactkey, @v_new_projectkey, @v_datacode, 1, getdate(), 'import')
			end  else begin
				update project_import
				set processerrormessage = (select IsNull(processerrormessage, '') + ' cannot find role code for role1_externalid of '  + @v_role1_externalid + '.'
										   where projectimportkey = @v_projectimportkey )
				where projectimportkey = @v_projectimportkey 
			end
		end 

		if @v_role2_externalid is not null begin
			exec get_next_key 'qsidba', @v_Taqprojectcontactrolekey output
			set @v_datacode = null
			select  @v_datacode = datacode
			from gentables
			where tableid = 285
			and externalcode = @v_role2_externalid
			
			if @v_datacode is not null begin
				insert into taqprojectcontactrole(Taqprojectcontactrolekey, Taqprojectcontactkey, Taqprojectkey, Rolecode, Activeind, Lastmaintdate, lastuserid)
				values(@v_Taqprojectcontactrolekey, @v_Taqprojectcontactkey, @v_new_projectkey, @v_datacode, 1, getdate(), 'import')
			end  else begin
				update project_import
				set processerrormessage = (select IsNull(processerrormessage, '') + ' cannot find role code for role2_externalid of '  + @v_role2_externalid + '.'
										   where projectimportkey = @v_projectimportkey )
				where projectimportkey = @v_projectimportkey 
			end
		end 
		end
		FETCH c_globalcontact INTO  @v_role1_externalid, @v_role2_externalid, @v_globalcontactrequestkey
	  end
	  close c_globalcontact
	  deallocate c_globalcontact

		-- CREATE PROJECT ORG ENTRY RECORDS
		If @v_Orgentry1 is not null begin
			select @v_cnt = count(*)
			from taqprojectorgentry
			where taqprojectkey = @v_new_projectkey
			and Orglevelkey = 1
			and Orgentrykey = @v_Orgentry1
			if @v_cnt = 0 begin
			insert into taqprojectorgentry(taqprojectkey, Orglevelkey, Orgentrykey, Lastmaintdate, lastuserid)
			values(@v_new_projectkey, 1, @v_Orgentry1, getdate(), 'import')
			end
		end

		If @v_Orgentry2 is not null begin
			select @v_cnt = count(*)
			from taqprojectorgentry
			where taqprojectkey = @v_new_projectkey
			and Orglevelkey = 2
			and Orgentrykey = @v_Orgentry2
			if @v_cnt = 0 begin
			insert into taqprojectorgentry(taqprojectkey, Orglevelkey, Orgentrykey, Lastmaintdate, lastuserid)
			values(@v_new_projectkey, 2, @v_Orgentry2, getdate(), 'import')
			end
		end

		If @v_Orgentry3 is not null begin
			select @v_cnt = count(*)
			from taqprojectorgentry
			where taqprojectkey = @v_new_projectkey
			and Orglevelkey = 3
			and Orgentrykey = @v_Orgentry3
			if @v_cnt = 0 begin
			insert into taqprojectorgentry(taqprojectkey, Orglevelkey, Orgentrykey, Lastmaintdate, lastuserid)
			values(@v_new_projectkey, 3, @v_Orgentry3, getdate(), 'import')
			end 
		end


	 --CREATE RELATED TITLES  (not done for second book yet)
	set @v_sucess_ind = 0
	IF @v_Projectrole_externalid is not null and @v_Titlerole_externalid is not null BEGIN
		--If relatedbook_productid <> null, search using this first, using the primary id type on the productnumlocations 
		--table first and if not found, use the secondary id type on the productnumlocations table. 
		if @v_relatedbook_productid is not null begin
			set @v_Bookkey = null
			select @v_Bookkey = bookkey
			from isbn 
			where ean = @v_relatedbook_productid
	
			if len(@v_Bookkey) = 0 begin
				select @v_Bookkey = bookkey
				from isbn 
				where isbn = @v_relatedbook_productid
			end

			--If found, check to see if the author last name is the same by comparing the import record relatedbook_authorlastname to 
			--the bookauthor global contact records to see if any match.  If a match is found, verify the firstname on this globbalcontact record.  
			if @v_Bookkey is not null begin
				set @v_title = null
				select @v_title = title
				from book
				where bookkey = @v_Bookkey
				and title  like '%' + @v_Relatedbook_title + '%'

				set @v_lastname = null
				select @v_lastname = lastname
				from bookauthor, globalcontact
				where bookkey = @v_Bookkey
				and authorkey = globalcontactkey
				and lastname = @v_relatedbook_authorlastname
				
				set @v_first_name = null
				select @v_first_name = firstname
				from bookauthor, globalcontact
				where bookkey = @v_Bookkey
				and authorkey = globalcontactkey
				and firstname = @v_Relatedbook_authorfirstname

				--If both names match, check to see if the book’s title and/or subtitle contain the text in the import record 
				--relatedbook_title (doesn’t have to be an exact match). 
				if @v_lastname is not null and @v_first_name is not null begin
					if len(@v_title) = 0 begin 
						update project_import
						set processerrormessage = (select IsNull(processerrormessage, '') + ' Warning:  Could not find a related book with Product ID ' +  @v_relatedbook_productid + ', 
													Title '+  @v_Relatedbook_title + '. Author ' + @v_relatedbook_authorlastname + ' ' +  @v_Relatedbook_authorfirstname + '.'
												   where projectimportkey = @v_projectimportkey )
						where projectimportkey = @v_projectimportkey 
					end else begin	
						set @v_sucess_ind = 1
					end
				end

				--If last name matches but first doesn’t, check to see if the book’s title and/or subtitle contain the text in 
				--the import record relatedbook_title (doesn’t have to be an exact match). 
				if @v_lastname is not null and @v_first_name is null begin
					if len(@v_title) > 0 begin 
						update project_import
						set processerrormessage = (select IsNull(processerrormessage, '') + ' Warning: Related book matches on Product ID,  Title and Author last name but not first name.  Verify that the related title is correct'  + '.'
												   where projectimportkey = @v_projectimportkey )
						where projectimportkey = @v_projectimportkey 
						set @v_sucess_ind = 1
					end else begin
						update project_import
						set processerrormessage = (select IsNull(processerrormessage, '') + ' Warning:  Could not find a related book with Product ID ' +  @v_relatedbook_productid + ', 
													Title '+  @v_Relatedbook_title + '. Author ' + @v_relatedbook_authorlastname + ' ' +  @v_Relatedbook_authorfirstname + '.'
												   where projectimportkey = @v_projectimportkey )
						where projectimportkey = @v_projectimportkey 
					end
				end

				--If last name does not match check to see if the book’s title and/or subtitle contain the text in the import record 
				--relatedbook_title (doesn’t have to be an exact match). 
				if @v_lastname is null begin	
					if len(@v_title) > 0 begin 
						update project_import
						set processerrormessage = (select IsNull(processerrormessage, '') + ' Warning: Related book matches on  Product ID,  Title but not Author.  Verify that the related title is correct'  + '.'
												   where projectimportkey = @v_projectimportkey )
						where projectimportkey = @v_projectimportkey 
						set @v_sucess_ind = 1	
					end else begin
						update project_import
						set processerrormessage = (select IsNull(processerrormessage, '') + ' Warning:  Could not find a related book with Product ID ' +  @v_relatedbook_productid + ', 
												Title '+  @v_Relatedbook_title + '. Author ' + @v_relatedbook_authorlastname + ' ' +  @v_Relatedbook_authorfirstname + '.'
												   where projectimportkey = @v_projectimportkey )
						where projectimportkey = @v_projectimportkey 
					end
				end
			END ELSE BEGIN
				update project_import
				set processerrormessage = (select IsNull(processerrormessage, '') + ' Warning:  Could not find a related book with Product ID ' + @v_relatedbook_productid + ', Title ' + @v_Relatedbook_title + '. Author ' + @v_relatedbook_authorlastname + ' ' +  @v_Relatedbook_authorfirstname + '.'
										   where projectimportkey = @v_projectimportkey )
				where projectimportkey = @v_projectimportkey 
			END
		
			 if @v_sucess_ind = 1 begin
				 set @v_Projectrolecode_datacode = null
				 select @v_Projectrolecode_datacode = datacode
				 from gentables
				 where tableid = 604
				 and externalcode = @v_Projectrole_externalid

				 set @v_titlerolecode_datacode = null
				 select @v_titlerolecode_datacode = datacode
				 from gentables
				 where tableid = 605
				 and externalcode = @v_Titlerole_externalid

				 exec get_next_key 'qsidba', @v_Taqprojectformatkey output
				 insert into taqprojecttitle (Taqprojectformatkey, Taqprojectkey, Bookkey, Projectrolecode, titlerolecode, Keyind, Sortorder, Lastmaintdate, lastuserid, primaryformatind)
				 values(@v_Taqprojectformatkey, @v_new_projectkey, @v_Bookkey, @v_Projectrolecode_datacode, @v_titlerolecode_datacode, 1, 1, getdate(), 'import', 1)
			end
		end
	end


	-- CREATE OR UPDATE PROJECT COMMENT RECORDS
	exec create_project_comment_record @v_Comment_externalid1, @v_comment1, @v_projectimportkey, @v_new_projectkey, 1, @v_processerrormessage output 
	exec create_project_comment_record @v_Comment_externalid2, @v_comment2, @v_projectimportkey, @v_new_projectkey, 2, @v_processerrormessage output  
	exec create_project_comment_record @v_Comment_externalid3, @v_comment3, @v_projectimportkey, @v_new_projectkey, 3, @v_processerrormessage output  
	exec create_project_comment_record @v_Comment_externalid4, @v_comment4, @v_projectimportkey, @v_new_projectkey, 4, @v_processerrormessage output  
	exec create_project_comment_record @v_Comment_externalid5, @v_comment5, @v_projectimportkey, @v_new_projectkey, 5, @v_processerrormessage output  


	-- CREATE PROJECT CATEGORY RECORDS
	if @v_category1_externalid is not null begin
			select @v_cnt = count(*)
			from gentables, subgentables, sub2gentables	
			where gentables.tableid = subgentables.tableid
			and subgentables.tableid = sub2gentables.tableid
			and gentables.externalcode = @v_category1_externalid
			and gentables.tableid = @v_category1_tableid

		if @v_cnt = 0 begin
			update project_import
			set processerrormessage = (select IsNull(processerrormessage, '') + ' Category could not be found for table id ' + cast(@v_category1_tableid as varchar) + ' with external code ' + @v_category1_externalid + '.'
									   where projectimportkey = @v_projectimportkey )
			where projectimportkey = @v_projectimportkey 
		end else begin
			set @v_datacode = null
			set @v_datasubcode = null
			set @v_datasub2code = null
			select distinct @v_datacode = gentables.datacode, @v_datasubcode = subgentables.datasubcode, @v_datasub2code =  sub2gentables.datasub2code
			from gentables, subgentables, sub2gentables	
			where gentables.tableid = subgentables.tableid
			and subgentables.tableid = sub2gentables.tableid
			and gentables.externalcode = @v_category1_externalid
			and gentables.tableid = @v_category1_tableid
			exec get_next_key 'qsidba', @v_Subjectkey output		
			insert into taqprojectsubjectcategory(taqprojectkey, Subjectkey, categorytableid, categorycode, categorysubcode, categorysub2code, Sortorder, Lastmaintdate	, Lastuserid)
			values(@v_new_projectkey, @v_Subjectkey, @v_category1_tableid, @v_datacode, @v_datasubcode, @v_datasub2code, 1, getdate(), 'import')
		end
	end


	-- CREATE UPDATE TASK RECORDS
	if @v_Task1_date is null begin set @v_Task1_date = getdate() end
	exec create_project_task_record @v_Task1_externalid, @v_projectimportkey, @v_taqkeyind, @v_new_projectkey, @v_Task1_date,
									@v_task1_actualind, @v_Taqtaskkey, @v_sort_order  output, @v_processerrormessage output, @v_cnt  output 

	if @v_Task2_date is null begin set @v_Task2_date = getdate() end
	exec create_project_task_record @v_Task2_externalid, @v_projectimportkey, @v_taqkeyind, @v_new_projectkey, @v_Task2_date,
									@v_task2_actualind, @v_Taqtaskkey, @v_sort_order  output, @v_processerrormessage output, @v_cnt  output 

	if @v_Task3_date is null begin set @v_Task3_date = getdate() end
	exec create_project_task_record @v_Task3_externalid, @v_projectimportkey, @v_taqkeyind, @v_new_projectkey, @v_Task3_date,
									@v_task3_actualind, @v_Taqtaskkey, @v_sort_order  output, @v_processerrormessage output, @v_cnt  output 

	if @v_Task4_date is null begin set @v_Task4_date = getdate() end
	exec create_project_task_record @v_Task4_externalid, @v_projectimportkey, @v_taqkeyind, @v_new_projectkey, @v_Task4_date,
									@v_task4_actualind, @v_Taqtaskkey, @v_sort_order  output, @v_processerrormessage output, @v_cnt  output 

	if @v_Task5_date is null begin set @v_Task5_date = getdate() end
	exec create_project_task_record @v_Task5_externalid, @v_projectimportkey, @v_taqkeyind, @v_new_projectkey, @v_Task5_date,
									@v_task5_actualind, @v_Taqtaskkey, @v_sort_order  output, @v_processerrormessage output, @v_cnt  output 



 --CREATE UPDATE MISC ITEMS		
	declare c_project_import_miscitem cursor for
	select alternatemiscitem_externalid, miscvalue, miscitemexternalid
	from project_import_miscitem
	where projectimportkey = @v_projectimportkey
 OPEN c_project_import_miscitem
  FETCH c_project_import_miscitem INTO	@v_alternatemiscitem_externalid, @v_miscvalue, @v_miscitemexternalid
  while (@@FETCH_STATUS = 0)  begin 

	--search the bookmiscitem using the externalid.
	set @v_misckey = null
	set @v_misctype = null
	set @v_datacode = null
	select @v_misckey = misckey, @v_misctype = misctype, @v_datacode = datacode
	from bookmiscitems
	where externalid = @v_miscitemexternalid 

	--Call Determine Misc Value sending the misckey, misctype and datacode from bookmiscitem and the miscmiscvalue from the import record.  

	exec find_misc_value @v_misckey,
						 @v_misctype, 
						 @v_datacode, 
						 @v_miscvalue,
						 @v_longvalue output,
						 @v_floatvalue output,
						 @v_textvalue output,
						 @v_errorcode output


	if @v_errorcode = -1 and @v_alternatemiscitem_externalid is null begin	
		update project_import
		set processerrormessage = (select IsNull(processerrormessage, '') + ' Invalid misc value ' +  IsNull(@v_miscvalue, '') + ' Could not load misc item from bookmiscitemtable.'
								   where projectimportkey = @v_projectimportkey ),
		Processedind = 2, Processdate	= getdate()
		where projectimportkey = @v_projectimportkey 
	end

	if @v_errorcode = -1 and @v_alternatemiscitem_externalid is not null begin	
		set @v_misckey = null
		set @v_misctype = null
		set @v_datacode = null
		select @v_misckey = misckey, @v_misctype = misctype, @v_datacode = datacode
		from bookmiscitems
		where externalid = @v_alternatemiscitem_externalid  

		exec find_misc_value @v_misckey,
						 @v_misctype, 
						 @v_datacode, 
						 @v_miscvalue,
						 @v_longvalue output,
						 @v_floatvalue output,
						 @v_textvalue output,
						 @v_errorcode output


		if @v_errorcode = -1 begin
			update project_import
			set processerrormessage = (select IsNull(processerrormessage, '') + ' Invalid misc value ' +  @v_miscvalue + ' Could not load misc item from bookmiscitemtable.'
									   where projectimportkey = @v_projectimportkey ),
			Processedind = 2, Processdate	= getdate()
			where projectimportkey = @v_projectimportkey 
		end 
	end

	if @v_errorcode = 0 begin
		select @v_cnt = count(*)
		from taqprojectmisc
		where misckey = @v_misckey
		and taqprojectkey = @v_new_projectkey
	
		if @v_cnt > 0 begin	
			update taqprojectmisc
			set longvalue = @v_longvalue, floatvalue = @v_floatvalue, textvalue = @v_textvalue
			where misckey = @v_misckey
			and taqprojectkey = @v_new_projectkey
		end else begin
		set @v_misckey = null
		select @v_misckey = misckey
		from bookmiscitems
		where externalid = @v_miscitemexternalid 

		if @v_misckey is null begin
			update project_import
			set processerrormessage = (select IsNull(processerrormessage, '') + ' Cannot find misckey in bookmiscitem for externalid ' +  @v_miscitemexternalid
									   where projectimportkey = @v_projectimportkey ),
			Processedind = 2, Processdate	= getdate()
			where projectimportkey = @v_projectimportkey 
		end else begin
			insert into taqprojectmisc
			values(@v_new_projectkey, @v_misckey, @v_longvalue, @v_floatvalue, @v_textvalue, 'import', getdate())
		end

		end
	end

	FETCH c_project_import_miscitem INTO @v_alternatemiscitem_externalid, @v_miscvalue, @v_miscitemexternalid	
  end
  close c_project_import_miscitem
  deallocate c_project_import_miscitem


	--COMPLET PROJECT IMPORT
	update project_import
	set processerrormessage = (select IsNull(processerrormessage, '') + ' Import process successful.'
							   where projectimportkey = @v_projectimportkey ),
	Processedind = 1, Processdate	= getdate()
	where projectimportkey = @v_projectimportkey 

	select @v_qsidatacode = datacode, @v_qsidatasubcode = datasubcode 
	from subgentables 
	where tableid = 284 and datadesc = 'Import Message'

	select @v_msg = processerrormessage
	from project_import
	where projectimportkey = @v_projectimportkey

	exec get_next_key 'qsidba', @v_new_commentkey output
	insert into qsicomments
	values(@v_new_commentkey, @v_qsidatacode, @v_qsidatasubcode, null,  @v_msg, '<DIV>' + @v_msg + '</DIV>','<DIV>' + @v_msg + '</DIV>', 'import', getdate(), null, null) 

	insert into taqprojectcomments
	values(@v_new_projectkey, @v_qsidatacode, @v_qsidatasubcode, @v_new_commentkey, null, 'import', getdate())
	--delete taqprojectcomments	 select * from taqprojectcomments

	getnext:

    FETCH c_project INTO @v_usedefaultemplateind, @v_projectimportkey, @v_Projectname, @v_Itemtypecode, @v_Usageclass_qsicode, @v_Orgentry1, @v_Orgentry2, @v_Orgentry3, @v_Projecttype_externalid, @v_Projectowner,
						 @v_Task1_externalid, @v_Task2_externalid, @v_Task3_externalid, @v_Task4_externalid, @v_Task5_externalid, 
						 @v_Task1_date, @v_Task2_date, @v_Task3_date, @v_Task4_date, @v_Task5_date,
					     @v_task1_actualind, @v_task2_actualind, @v_task3_actualind, @v_task4_actualind, @v_task5_actualind,
						 @v_Titlerole_externalid, @v_Projectrole_externalid,
						 @v_comment1, @v_comment2, @v_comment3, @v_comment4, @v_comment5,
						 @v_Comment_externalid1, @v_Comment_externalid2, @v_Comment_externalid3, @v_Comment_externalid4, @v_Comment_externalid5,
						 @v_category1_externalid, @v_category2_externalid, @v_category1_tableid, @v_category2_tableid, @v_relatedbook_productid,
						 @v_Relatedbook_authorfirstname, @v_Relatedbook_authorlastname, @v_Relatedbook_title, @v_Projectstatus_externalid
end
temp:
  CLOSE c_project
  DEALLOCATE c_project

