IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.set_globalcontactaddress_tr') AND type = 'TR')
	DROP TRIGGER dbo.set_globalcontactaddress_tr 
GO


CREATE TRIGGER set_globalcontactaddress_tr ON author
FOR INSERT, UPDATE AS
IF UPDATE (address1) OR
   UPDATE (city) OR
   UPDATE (statecode) OR
   UPDATE (zip) OR
   UPDATE (countrycode) OR
   UPDATE (address1line2) OR
   UPDATE (address1line3) OR
   UPDATE (addresstypecode1) OR
   UPDATE (address2line1) OR
   UPDATE (address2line2) OR
   UPDATE (address2line3) OR
   UPDATE (addresstypecode2) OR
   UPDATE (city2) OR
   UPDATE (statecode2) OR
   UPDATE (zip2) OR
   UPDATE (countrycode2) OR
   UPDATE (address3line1) OR
   UPDATE (address3line2) OR
   UPDATE (address3line3) OR
   UPDATE (addresstypecode3) OR
   UPDATE (city3) OR
   UPDATE (statecode3) OR
   UPDATE (zip3) OR
   UPDATE (countrycode3)OR
   UPDATE (defaultaddressnumber)

BEGIN
  DECLARE
    @v_scopetag varchar(30),
    @v_authorkey int,
    @v_lastuserid varchar(30),
    @v_address1 varchar(80),
    @v_city varchar(25),
    @v_statecode int,
    @v_zip varchar(50),
    @v_countrycode int,
    @v_address1line2 varchar(80),
    @v_address1line3 varchar(80),
    @v_addresstypecode1 int,
    @v_address2line1 varchar(80),
    @v_address2line2 varchar(80),
    @v_address2line3 varchar(80),
    @v_addresstypecode2 int,
    @v_city2 varchar(25),
    @v_statecode2 int,
    @v_zip2 varchar(50),
    @v_countrycode2 int,
    @v_address3line1 varchar(80),
    @v_address3line2 varchar(80),
    @v_address3line3 varchar(80),
    @v_addresstypecode3 int,
    @v_city3 varchar(25),
    @v_statecode3 int,
    @v_zip3 varchar(50),
    @v_countrycode3 int,
    @v_defaultaddressnumber int,
    @v_defaultaddress1 int,
    @v_defaultaddress2 int,
    @v_defaultaddress3 int

  select 
    @v_authorkey=authorkey,
    @v_lastuserid=lastuserid,
    @v_address1=address1,
    @v_city=city,
    @v_statecode=statecode,
    @v_zip=zip,
    @v_countrycode=countrycode,
    @v_address1line2=address1line2,
    @v_address1line3=address1line3,
    @v_addresstypecode1=addresstypecode1,
    @v_address2line1=address2line1,
    @v_address2line2=address2line2,
    @v_address2line3=address2line3,
    @v_addresstypecode2=addresstypecode2,
    @v_city2=city2,
    @v_statecode2=statecode2,
    @v_zip2=zip2,
    @v_countrycode2=countrycode2,
    @v_addresstypecode2=addresstypecode2,
    @v_address3line1=address3line1,
    @v_address3line2=address3line2,
    @v_address3line3=address3line3,
    @v_addresstypecode3=addresstypecode3,
    @v_city3=city3,
    @v_statecode3=statecode3,
    @v_zip3=zip3,
    @v_countrycode3=countrycode3,
    @v_addresstypecode3=addresstypecode3,
    @v_defaultaddressnumber=defaultaddressnumber  
  from inserted i
  set @v_defaultaddress1 = 0
  set @v_defaultaddress2 = 0
  set @v_defaultaddress3 = 0
  IF @v_defaultaddressnumber = 1
    set @v_defaultaddress1 = 1
  ELSE
    IF @v_defaultaddressnumber = 2
      set @v_defaultaddress2 = 1
    ELSE
      IF @v_defaultaddressnumber = 3
        set @v_defaultaddress3 = 1

  IF UPDATE (address1)
     OR UPDATE (city)
     OR UPDATE (statecode)
     OR UPDATE (zip)
     OR UPDATE (countrycode)
     OR UPDATE (address1line2)
     OR UPDATE (address1line3)
     OR UPDATE (addresstypecode1)
    BEGIN
      set @v_scopetag = 'addr1'
      exec set_globalcontactaddress_sp
        @v_authorkey,@v_scopetag,@v_defaultaddress1 ,
        @v_address1,@v_address1line2,@v_address1line3,
        @v_city,@v_statecode,@v_zip,@v_countrycode,
        @v_addresstypecode1,@v_lastuserid
    END

  IF UPDATE (address2line1)
     OR UPDATE (address2line2)
     OR UPDATE (address2line3)
     OR UPDATE (addresstypecode2)
     OR UPDATE (city2)
     OR UPDATE (statecode2)
     OR UPDATE (zip2)
     OR UPDATE (countrycode2)
     OR UPDATE (addresstypecode2)
    BEGIN
      set @v_scopetag = 'addr2'
      exec set_globalcontactaddress_sp
        @v_authorkey,@v_scopetag,@v_defaultaddress2,
        @v_address2line1,@v_address2line2,@v_address2line3,
        @v_city2,@v_statecode2,@v_zip2,@v_countrycode2,
        @v_addresstypecode2,@v_lastuserid
    END

  IF UPDATE (address3line1)
     OR UPDATE (address3line2)
     OR UPDATE (address3line3)
     OR UPDATE (addresstypecode3)
     OR UPDATE (city3)
     OR UPDATE (statecode3)
     OR UPDATE (zip3)
     OR UPDATE (countrycode3)
     OR UPDATE (addresstypecode3)
    BEGIN
      set @v_scopetag = 'addr3'
      exec set_globalcontactaddress_sp
        @v_authorkey,@v_scopetag,@v_defaultaddress3,
        @v_address3line1,@v_address3line2,@v_address3line3,
        @v_city3,@v_statecode3,@v_zip3,@v_countrycode3,
        @v_addresstypecode3,@v_lastuserid
    END

END
go



