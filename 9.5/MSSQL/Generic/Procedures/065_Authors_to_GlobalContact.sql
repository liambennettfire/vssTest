if exists (select * from dbo.sysobjects where id = Object_id('dbo.Authors_to_GlobalContact') and (type = 'P' or type = 'RF'))
begin
 drop proc Authors_to_GlobalContact 
end
go

CREATE PROCEDURE Authors_to_GlobalContact (
  @i_overwrite_ind int 
  ) AS

  -- this procedure keeps Author and its related Contact row in sync

begin
  declare  @v_rows int
  declare  @v_authorkey int
  declare  @v_newkey int
  declare  @v_masterkey int
  declare  @v_detailkey int
  declare  @v_scopetag varchar(30)
  declare  @v_ind int
  declare  @v_ind2 int
  declare  @v_check varchar (4000)
  declare  @v_corporatecontributorind int
  declare  @v_zipcode varchar(50)
  declare  @err_msg  varchar(100)

  declare author_cur cursor for 
    select  authorkey,corporatecontributorind
      from  author

  open author_cur
  fetch author_cur into @v_authorkey,@v_corporatecontributorind
  while @@fetch_status = 0
    begin

      begin transaction

--      select @v_rows = count(*) 
--        from globalcontactauthor
--        where masterkey = @v_authorkey
      if @i_overwrite_ind = 1
        begin
          declare contact_cur cursor for 
            select  masterkey,detailkey,scopetag
            from  globalcontactauthor
            where masterkey=@v_authorkey
          open contact_cur 
          fetch contact_cur into @v_masterkey,@v_detailkey,@v_scopetag
          while @@fetch_status = 0
            begin
              if @v_scopetag = 'contact'
                begin
                  delete globalcontact where globalcontactkey=@v_detailkey


                 select @v_ind = count(*) from globalcontactrole where globalcontactkey=@v_detailkey
                 if @v_ind > 0 begin
                   delete globalcontactrole where globalcontactkey=@v_detailkey
                 end
                end
              if left(@v_scopetag,4)='addr' 
                begin
                  delete globalcontactaddress where globalcontactaddresskey=@v_detailkey
                end
              if left(@v_scopetag,5)='phone' or
                 left(@v_scopetag,3)='fax' or
                 left(@v_scopetag,5)='email' or
                 left(@v_scopetag,3)='url'
                begin
                  delete globalcontactmethod where globalcontactmethodkey=@v_detailkey
                end
					
					if left(@v_scopetag,5)='agent' 
						begin
                    delete globalcontactrelationship where globalcontactrelationshipkey=@v_detailkey
                  end 

					if left(@v_scopetag,5)='biogr' 
						begin
                    delete qsicomments where commentkey=@v_authorkey
                  end 

					delete globalcontactauthor where masterkey=@v_authorkey and detailkey=@v_detailkey
               
               fetch contact_cur into @v_masterkey,@v_detailkey,@v_scopetag
            end
          close contact_cur
          deallocate contact_cur
        end

      --  contact info
      if @v_corporatecontributorind = 1 begin
        -- group
        insert into globalcontact
          (globalcontactkey,displayname,searchname,individualind,privateind,grouptypecode,groupname,firstname,lastname,middlename,ssn,uscitizenind,lastuserid,lastmaintdate)
          (select authorkey,displayname,upper(lastname),0,0,0,lastname,firstname,lastname,middlename,ssn,uscitizenind,'a2c qsi',getdate()
              from author
              where authorkey=@v_authorkey)
      end
      else begin
        -- individual
        insert into globalcontact
          (globalcontactkey,displayname,searchname,individualind,privateind,grouptypecode,firstname,lastname,middlename,
			  accreditationcode,suffix,degree,ssn,uscitizenind,globalcontactnotes,lastuserid,lastmaintdate,
           externalcode1,externalcode2)
          (select authorkey,displayname,upper(lastname),1,0,0,firstname,lastname,middlename,
                  nameabbrcode,authorsuffix,authordegree,ssn,uscitizenind,notes,'a2c qsi',getdate(),
                  externalauthorcode1,externalauthorcode2
              from author
              where authorkey=@v_authorkey)
      end

      insert into globalcontactauthor
        (masterkey,detailkey,scopetag)
        values
        (@v_authorkey,@v_authorkey,'contact')
        
       -- Contact Roles based on mapping table.
      select @v_ind = count(*) from gentablesrelationshipdetail gtr, bookauthor ba where gtr.gentablesrelationshipkey = 1 and gtr.code1 = ba.authortypecode and ba.authorkey = @v_authorkey
      if @v_ind > 0 begin
        insert into globalcontactrole (globalcontactkey, rolecode, keyind, lastuserid, lastmaintdate) ( select distinct @v_authorkey, gtr.code2, 0, 'a2c qsi', getdate() from gentablesrelationshipdetail gtr, bookauthor ba where gtr.gentablesrelationshipkey = 1 and gtr.code1 = ba.authortypecode and ba.authorkey = @v_authorkey)
      end
       

       -- Contact addresses 1      
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and 
             ((address1 is not null and address1 <>'') or
              (address1line2 is not null and address1line2 <>'') or
              (address1line3 is not null and address1line3 <>'') or
              (city is not null and city <>'') or
              (statecode is not null and statecode <>'') or
              (countrycode is not null and countrycode <>''))
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
				select @v_zipcode = zip from author where authorkey = @v_authorkey
            if datalength(@v_zipcode) > 10 begin
					select @err_msg = 'Error - zip code greater than 10 characters for author key = ' + convert(char(10),@v_authorkey) 
					print @err_msg
				end
				else begin
					insert into globalcontactaddress
					  (globalcontactaddresskey,globalcontactkey,addresstypecode,
						address1,address2,address3,city,statecode,zipcode,countrycode,
						primaryind,lastuserid,lastmaintdate)
					  (select
							 @v_newkey,@v_authorkey,COALESCE(addresstypecode1,1),
							 address1,address1line2,address1line3,city,statecode,zip,countrycode,
							 1,'a2c qsi',getdate()   
						  from author
						  where authorkey = @v_authorkey)
					 insert into globalcontactauthor (masterkey,detailkey,scopetag)
						values (@v_authorkey,@v_newkey,'addr1')
				  end
         end

       -- Contact addresses 2      
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and 
             ((address2line1 is not null and address2line1 <>'') or
              (address2line2 is not null and address2line2 <>'') or
              (address2line3 is not null and address2line3 <>'') or
              (city2 is not null and city2 <>'') or
              (statecode2 is not null and statecode2 <>'') or
              (countrycode2 is not null and countrycode2 <>''))
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
				select @v_zipcode = zip2 from author where authorkey = @v_authorkey
            if datalength(@v_zipcode) > 10 begin
					select @err_msg = 'Error - zip code 2 greater than 10 characters for author key = ' + convert(char(10),@v_authorkey) 
					print @err_msg
				end
				else begin
					insert into globalcontactaddress
					  (globalcontactaddresskey,globalcontactkey,addresstypecode,
						address1,address2,address3,city,statecode,zipcode,countrycode,
						primaryind,lastuserid,lastmaintdate)
					  (select
							 @v_newkey,@v_authorkey,COALESCE(addresstypecode2,2),
							 address2line1,address2line2,address2line3,city2,statecode2,zip2,countrycode2,
							 0,'a2c qsi',getdate()   
						  from author
						  where authorkey = @v_authorkey)
					 insert into globalcontactauthor (masterkey,detailkey,scopetag)
						values (@v_authorkey,@v_newkey,'addr2')
            end
        end

       -- Contact addresses 3     
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and 
             ((address3line1 is not null and address3line1 <> '') or
              (address3line2 is not null and address3line2 <> '') or
              (address3line3 is not null and address3line3 <> '') or
              (city3 is not null and city3 <> '') or
              (statecode3 is not null and statecode3 <> '') or
              (countrycode3 is not null and countrycode3 <> ''))
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
				select @v_zipcode = zip3 from author where authorkey = @v_authorkey
            if datalength(@v_zipcode) > 10 begin
					select @err_msg = 'Error - zip code 3 greater than 10 characters for author key = ' + convert(char(10),@v_authorkey) 
					print @err_msg
				end
				else begin
					insert into globalcontactaddress
					  (globalcontactaddresskey,globalcontactkey,addresstypecode,
						address1,address2,address3,city,statecode,zipcode,countrycode,
						primaryind,lastuserid,lastmaintdate)
					  (select
							 @v_newkey,@v_authorkey,COALESCE(addresstypecode3,3),
							 address3line1,address3line2,address3line3,city3,statecode3,zip3,countrycode3,
							 0,'a2c qsi',getdate()   
						  from author
						  where authorkey = @v_authorkey)
					 insert into globalcontactauthor (masterkey,detailkey,scopetag)
						values (@v_authorkey,@v_newkey,'addr3')
           end
       end

       -- Contact method phone 1     
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and phone1 is not null and phone1 <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
            insert into globalcontactmethod
              (globalcontactmethodkey,globalcontactkey,
	       contactmethodcode,contactmethodsubcode,contactmethodvalue,primaryind,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   1,2,phone1,0,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'phone1')
           end

       -- Contact method phone 2     
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and phone2 is not null and phone2 <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
            insert into globalcontactmethod
              (globalcontactmethodkey,globalcontactkey,
	       contactmethodcode,contactmethodsubcode,contactmethodvalue,primaryind,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   1,1,phone2,0,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'phone2')
           end

       -- Contact method phone 3     
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and phone3 is not null and phone3 <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
            insert into globalcontactmethod
              (globalcontactmethodkey,globalcontactkey,
	       contactmethodcode,contactmethodsubcode,contactmethodvalue,primaryind,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   1,3,phone3,0,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'phone3')
           end

       -- Contact method fax 1     
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and fax1 is not null and fax1 <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
            insert into globalcontactmethod
              (globalcontactmethodkey,globalcontactkey,
	       contactmethodcode,contactmethodsubcode,contactmethodvalue,primaryind,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   2,1,fax1,0,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'fax1')
           end


       -- Contact method fax 2     
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and fax2 is not null and fax2 <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
            insert into globalcontactmethod
              (globalcontactmethodkey,globalcontactkey,
	       contactmethodcode,contactmethodsubcode,contactmethodvalue,primaryind,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   2,2,fax2,0,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'fax2')
           end

       -- Contact method fax 3     
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and fax3 is not null and fax3 <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
            insert into globalcontactmethod
              (globalcontactmethodkey,globalcontactkey,
	       contactmethodcode,contactmethodsubcode,contactmethodvalue,primaryind,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   2,1,fax3,0,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'fax3')
           end

       -- Contact method email 1     
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and emailaddress1 is not null and emailaddress1 <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
            insert into globalcontactmethod
              (globalcontactmethodkey,globalcontactkey,
	       contactmethodcode,contactmethodsubcode,contactmethodvalue,primaryind,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   3,1,emailaddress1,0,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'email1')
           end

       -- Contact method email 2     
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and emailaddress2 is not null and emailaddress2 <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
            insert into globalcontactmethod
              (globalcontactmethodkey,globalcontactkey,
	       contactmethodcode,contactmethodsubcode,contactmethodvalue,primaryind,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   3,1,emailaddress2,0,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'email2')
           end

       -- Contact method email 3
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and emailaddress3 is not null and emailaddress3 <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
            insert into globalcontactmethod
              (globalcontactmethodkey,globalcontactkey,
	       contactmethodcode,contactmethodsubcode,contactmethodvalue,primaryind,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   3,1,emailaddress3,0,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'email3')
           end


       -- Contact method URL
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and authorurl is not null and authorurl <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
            insert into globalcontactmethod
              (globalcontactmethodkey,globalcontactkey,
	       contactmethodcode,contactmethodsubcode,contactmethodvalue,primaryind,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   4,2,authorurl,0,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'url')
           end

		-- Contact Agent
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
           and agentname is not null 
           and agentname <> ''
        if @v_ind = 1
          begin
            update keys set generickey = generickey + 1 
            select @v_newkey = generickey from keys
				insert into globalcontactrelationship
              (globalcontactrelationshipkey,globalcontactkey1,
	            globalcontactname2,contactrelationshipcode1,
               lastuserid,lastmaintdate)
              (select
                   @v_newkey,@v_authorkey,
                   agentname,3,
                   'a2c qsi',getdate()   
                 from author
                 where authorkey = @v_authorkey)
             insert into globalcontactauthor (masterkey,detailkey,scopetag)
               values (@v_authorkey,@v_newkey,'agent')
				end

		-- Contact Biography
       select @v_ind = count(*)
         from author
         where authorkey = @v_authorkey
             and biography is not null 
             and cast(biography as varchar(8000))<> '' 
        if @v_ind = 1
          begin
            select @v_ind2 = count(*)
              from qsicomments
             where commentkey = @v_authorkey AND
                   commenttypecode = 2 AND
                   commenttypesubcode = 0
				if @v_ind2 = 0 
				begin
               --update keys set generickey = generickey + 1 
          		--select @v_newkey = generickey from keys
					insert into qsicomments
					  (commentkey,commenttypecode,commenttypesubcode,
						commenthtml,
						lastuserid,lastmaintdate)
					  (select
							 @v_authorkey,2,0,
							 biography,
							 'a2c qsi',getdate()   
						  from author
						  where authorkey = @v_authorkey)
					 insert into globalcontactauthor (masterkey,detailkey,scopetag)
						values (@v_authorkey,2,'biogr')
					 exec commenthtml_fix 'qsicomments',@v_authorkey,0,2,0
            end
           end

      commit

      fetch author_cur into @v_authorkey,@v_corporatecontributorind

    end

  close author_cur
  deallocate author_cur

end
GO
