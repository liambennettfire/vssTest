IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.set_globalcontmethod_tr') AND type = 'TR')
	DROP TRIGGER dbo.set_globalcontmethod_tr 
GO

CREATE TRIGGER set_globalcontmethod_tr ON author
FOR INSERT, UPDATE AS
IF UPDATE (phone1) OR 
   UPDATE (phone2) OR 
   UPDATE (phone3) OR 
   UPDATE (emailaddress1) OR 
   UPDATE (emailaddress2) OR 
   UPDATE (emailaddress3) OR 
   UPDATE (fax1) OR 
   UPDATE (fax2) OR 
   UPDATE (fax3) OR
   UPDATE (authorurl)

BEGIN
  DECLARE
    @v_authorkey int,
    @v_method varchar(80),
    @v_scopetag varchar(30),
    @v_lastuserid varchar(30),
    @v_phone1 varchar(50),
    @v_fax1 varchar(50),
    @v_emailaddress1 varchar(50),
    @v_phone2 varchar(50),
    @v_fax2 varchar(50),
    @v_emailaddress2 varchar(50),
    @v_phone3 varchar(50),
    @v_fax3 varchar(50),
    @v_emailaddress3 varchar(50),
    @v_authorurl varchar(80)

  select 
    @v_authorkey = authorkey,
    @v_phone1 = phone1,
    @v_fax1 = fax1,
    @v_emailaddress1 = emailaddress1,
    @v_phone2 = phone2,
    @v_fax2 = fax2,
    @v_emailaddress2 = emailaddress2,
    @v_phone3 = phone3,
    @v_fax3 = fax3,
    @v_emailaddress3 = emailaddress3,
    @v_authorurl = authorurl,
    @v_lastuserid = lastuserid
  from inserted i

  IF UPDATE (phone1)
    BEGIN
      set @v_method = @v_phone1 
      set @v_scopetag = 'phone1'
      exec set_globalcontactmethod_sp @v_authorkey,@v_scopetag,@v_method,@v_lastuserid
    END
  IF UPDATE (phone2)
    BEGIN
      set @v_method = @v_phone2 
      set @v_scopetag = 'phone2'
      exec set_globalcontactmethod_sp @v_authorkey,@v_scopetag,@v_method,@v_lastuserid
    END
  IF UPDATE (phone3)
    BEGIN
      set @v_method = @v_phone3 
      set @v_scopetag = 'phone3'
      exec set_globalcontactmethod_sp @v_authorkey,@v_scopetag,@v_method,@v_lastuserid
    END
  IF UPDATE (fax1)
    BEGIN
      set @v_method = @v_fax1
      set @v_scopetag = 'fax1'
      exec set_globalcontactmethod_sp @v_authorkey,@v_scopetag,@v_method,@v_lastuserid
    END
  IF UPDATE (fax2)
    BEGIN
      set @v_method = @v_fax2
      set @v_scopetag = 'fax2'
      exec set_globalcontactmethod_sp @v_authorkey,@v_scopetag,@v_method,@v_lastuserid
    END
  IF UPDATE (fax3)
    BEGIN
      set @v_method = @v_fax3
      set @v_scopetag = 'fax3'
      exec set_globalcontactmethod_sp @v_authorkey,@v_scopetag,@v_method,@v_lastuserid
    END
  IF UPDATE (emailaddress1)
    BEGIN
      set @v_method = @v_emailaddress1 
      set @v_scopetag = 'email1'
      exec set_globalcontactmethod_sp @v_authorkey,@v_scopetag,@v_method,@v_lastuserid
    END
  IF UPDATE (emailaddress2)
    BEGIN
      set @v_method = @v_emailaddress2
      set @v_scopetag = 'email2'
      exec set_globalcontactmethod_sp @v_authorkey,@v_scopetag,@v_method,@v_lastuserid
    END
  IF UPDATE (emailaddress3)
    BEGIN
      set @v_method = @v_emailaddress3 
      set @v_scopetag = 'email3'
      exec set_globalcontactmethod_sp @v_authorkey,@v_scopetag,@v_method,@v_lastuserid
    END
  IF UPDATE (authorurl)
    BEGIN
      set @v_method = @v_authorurl 
      set @v_scopetag = 'url'
      exec set_globalcontactmethod_sp @v_authorkey,@v_scopetag,@v_method,@v_lastuserid
    END

END
go



