/*****************************************************************/   
/*              Created by Althea A. 7-2-03  SIR 2071            */
/*  Any author inserted or updated on the author table           */
/*  are inserted/updated on                                      */
/*  the publicity contact and contactaddress table               */
/*  some columns had to be defaulted since they are              */
/*  necessary on the publicit table                              */
/*  defaults; bucode= 35 ; phone1code= 1 (general);              */
/*  addresscode 3 home mailing if no address; activeind = 1      */
/*                                                               */
/*              Modified by RPH 12-3-03 SIR 2493                 */
/*  Address codes between contact and contactaddress were wrong. */
/*  Bring in all three address.                                  */
/*  The duplicate address type is resolved within the determina- */
/*  tion of the default address as to ensure that the address is */
/*  imported.                                                    */
/*****************************************************************/   

if exists (select * from dbo.sysobjects where id = Object_id('dbo.authortopublicity_ins_trig') and (type = 'P' or type = 'TR'))
begin
 drop trigger dbo.authortopublicity_ins_trig
end

GO

CREATE TRIGGER authortopublicity_ins_trig ON author
FOR INSERT, UPDATE AS 

BEGIN

--Modified 2003.12.24 cgates
--  Added @author_bucode var to replace magic value "35"
--  Added bucode to select/delete statements below to prevent
--  PK collision when two contacts from different bucodes have same
--  contactkey.  (Suprising that this should happen at all, and yet
--  it did happen.  Proabbly anomaly from initial load, but more robust
--  to include the bucode since it is part of the PK.)

DECLARE @author_bucode int
DECLARE @v_authorkey int
DECLARE @v_nameabbrcode int
DECLARE @v_firstname varchar(75)
DECLARE @v_lastname varchar(75)
DECLARE @v_middlename varchar(75)
DECLARE @v_title varchar(80)
DECLARE @v_phone1 varchar(50)
DECLARE @v_phone2 varchar(50)
DECLARE @v_phone3 varchar(50)
DECLARE @v_notes varchar(255)
DECLARE @v_defaultaddressnumber int
DECLARE @v_addresstypecode1 int
DECLARE @v_addresstypecode2 int
DECLARE @v_addresstypecode3 int
DECLARE @v_emailaddress1 varchar(50)
DECLARE @v_emailaddress2 varchar(50)
DECLARE @v_emailaddress3 varchar(50)
DECLARE @v_address1  varchar(50)
DECLARE @v_address2line1 varchar(50)
DECLARE @v_address3line1 varchar(50)
DECLARE @v_address1line2 varchar(50)
DECLARE @v_address2line2 varchar(50)
DECLARE @v_address3line2 varchar(50)
DECLARE @v_address1line3 varchar(50) 
DECLARE @v_address2line3 varchar(50) 
DECLARE @v_address3line3 varchar(50)
DECLARE @v_city varchar(25)
DECLARE @v_city2 varchar(25)
DECLARE @v_city3 varchar(25)
DECLARE @v_statecode int
DECLARE @v_statecode2 int 
DECLARE @v_statecode3 int
DECLARE @v_zip varchar(50)
DECLARE @v_zip2 varchar(50)
DECLARE @v_zip3 varchar(50)
DECLARE @v_countrycode int
DECLARE @v_countrycode2 int
DECLARE @v_countrycode3 int
DECLARE @v_addresstypecode1old int
DECLARE @v_addresstypecode2old int
DECLARE @v_addresstypecode3old int
DECLARE @v_activeind int 
DECLARE @err_msg varchar(100)

SELECT @author_bucode = 35

IF UPDATE (nameabbrcode) OR
   UPDATE (firstname) OR
   UPDATE (middlename) OR
   UPDATE (lastname) OR
   UPDATE (title) OR
   UPDATE (phone1) OR 
   UPDATE (phone2) OR
   UPDATE (phone3) OR
   UPDATE (notes) OR
   UPDATE (addresstypecode1) OR
   UPDATE (addresstypecode2) OR
   UPDATE (addresstypecode3) OR
   UPDATE (emailaddress1) OR
   UPDATE (emailaddress2) OR
   UPDATE (emailaddress3) OR
   UPDATE (address1) OR
   UPDATE (address2line1) OR
   UPDATE (address3line1) OR
   UPDATE (address1line2) OR
   UPDATE (address2line2) OR
   UPDATE (address3line2) OR
   UPDATE (address1line3) OR
   UPDATE (address2line3) OR
   UPDATE (address3line3) OR
   UPDATE (defaultaddressnumber) OR
   UPDATE (city) OR 
   UPDATE (city2) OR 
   UPDATE (city3) OR
   UPDATE (statecode) OR 
   UPDATE (statecode2) OR 
   UPDATE (statecode3) OR
   UPDATE (zip) OR 
   UPDATE(zip2) OR 
   UPDATE(zip3) OR
   UPDATE (countrycode) OR 
   UPDATE(countrycode) OR 
   UPDATE (countrycode3) 
  
  
                
	SELECT @v_authorkey =new.authorkey, @v_nameabbrcode = new.nameabbrcode,
		@v_firstname = new.firstname,@v_lastname = new.lastname,
		@v_middlename = new.middlename, @v_title = new.title,
		@v_phone1 = new.phone1,@v_phone2 = new.phone2,
		@v_phone3 = new.phone3,@v_notes = new.notes,
		@v_defaultaddressnumber = new.defaultaddressnumber,
		@v_addresstypecode1 = new.addresstypecode1,
		@v_addresstypecode2 = new.addresstypecode2,
		@v_addresstypecode3 = new.addresstypecode3,
		@v_emailaddress1 = new.emailaddress1,
		@v_emailaddress2 = new.emailaddress2,
		@v_emailaddress3 = new.emailaddress3,
		@v_address1 = new.address1,
		@v_address2line1 = new.address2line1,
		@v_address3line1 = new.address3line1,
		@v_address1line2 = new.address1line2,
		@v_address2line2 = new.address2line2,
		@v_address3line2 = new.address3line2,
		@v_address1line3 = new.address1line3,
		@v_address2line3 = new.address2line3,
		@v_address3line3 = new.address3line3,
		@v_city = new.city, @v_city2 = new.city2,
		@v_city3 = new.city3, @v_statecode = new.statecode, 
		@v_statecode2 = new.statecode2, @v_statecode3 = new.statecode3,
		@v_zip = new.zip, @v_zip2 = new.zip2, @v_zip3 = new.zip3,
		@v_countrycode = new.countrycode, @v_countrycode2 = new.countrycode2,
		@v_countrycode3 = new.countrycode3,
		@v_addresstypecode1old = old.addresstypecode1,
		@v_addresstypecode2old = old.addresstypecode2,
		@v_addresstypecode3old = old.addresstypecode3
	FROM inserted new full outer join deleted old on new.authorkey=old.authorkey

ELSE

	SELECT @v_authorkey =new.authorkey, @v_nameabbrcode = new.nameabbrcode,
		@v_firstname = new.firstname,@v_lastname = new.lastname,
		@v_middlename = new.middlename, @v_title = new.title,
		@v_phone1 = new.phone1,@v_phone2 = new.phone2,
		@v_phone3 = new.phone3,@v_notes = new.notes,
		@v_defaultaddressnumber = new.defaultaddressnumber,
		@v_addresstypecode1 = new.addresstypecode1,
		@v_addresstypecode2 = new.addresstypecode2,
		@v_addresstypecode3 = new.addresstypecode3,
		@v_emailaddress1 = new.emailaddress1,
		@v_emailaddress2 = new.emailaddress2,
		@v_emailaddress3 = new.emailaddress3,
		@v_address1 = new.address1,
		@v_address2line1 = new.address2line1,
		@v_address3line1 = new.address3line1,
		@v_address1line2 = new.address1line2,
		@v_address2line2 = new.address2line2,
		@v_address3line2 = new.address3line2,
		@v_address1line3 = new.address1line3,
		@v_address2line3 = new.address2line3,
		@v_address3line3 = new.address3line3,
		@v_city = new.city, @v_city2 = new.city2,
		@v_city3 = new.city3, @v_statecode = new.statecode, 
		@v_statecode2 = new.statecode2, @v_statecode3 = new.statecode3,
		@v_zip = new.zip, @v_zip2 = new.zip2, @v_zip3 = new.zip3,
		@v_countrycode = new.countrycode, @v_countrycode2 = new.countrycode2,
		@v_countrycode3 = new.countrycode3,
		@v_addresstypecode1old = NULL,
		@v_addresstypecode2old = NULL,
		@v_addresstypecode3old = NULL
	FROM inserted new 
END

DECLARE @i_phone1code	int
DECLARE @i_phone2code	int 
DECLARE @i_phone3code	int 
DECLARE @i_addresscode	int  
DECLARE @v_count	int
DECLARE @i_statecode	int
DECLARE @i_countrycode	int
--Added to trap non-numeric zipcodes
--2003.11.15 cgates
DECLARE @c_zipcode VARCHAR(10)
DECLARE @i_zipcode	int
DECLARE @c_city	varchar(25)
DECLARE @c_zip	varchar(50)
DECLARE @c_address1	varchar(50)
DECLARE @c_address2 	varchar(50) 
DECLARE @c_address3 	varchar(50) 
DECLARE @c_emailaddress varchar(50) 
DECLARE @c_middleinit varchar(2) 

IF @@error != 0
   BEGIN
      ROLLBACK TRANSACTION
      select @err_msg = 'Could not select from author table (trigger level 1).'
      print @err_msg
   END
ELSE
   BEGIN  	
      /* Determine default address and set default info for contact */

      select @i_addresscode = NULL

      if @v_defaultaddressnumber = 1 OR (@v_defaultaddressnumber is null) OR (@v_defaultaddressnumber = 0)
         begin
            if @v_addresstypecode1 is null  /*default to home mailing if null*/
               begin
                  select @i_addresscode = 3
                  select @v_addresstypecode1 = 3
               end
            else
               begin	
                  select @i_addresscode = @v_addresstypecode1
               end

            /* Do not allow addresses with the same type */
            if @v_addresstypecode1 = @v_addresstypecode2
               begin
                  select @v_addresstypecode2 = NULL
               end

            if @v_addresstypecode1 = @v_addresstypecode3
               begin
                  select @v_addresstypecode3 = NULL
               end

            if @v_addresstypecode2 = @v_addresstypecode3
               begin
                  select @v_addresstypecode3 = NULL
               end

         end /* if @v_defaultaddressnumber = 1 */

      if @v_defaultaddressnumber = 2
         begin
            if @v_addresstypecode2 is null  /*default to home mailing if null*/
               begin
                  select @i_addresscode = 3
                  select @v_addresstypecode2 = 3
               end
            else
               begin	
                  select @i_addresscode = @v_addresstypecode2
               end

            /* Do not allow addresses with the same type */
            if @v_addresstypecode2 = @v_addresstypecode1
               begin
                  select @v_addresstypecode1 = NULL
               end

            if @v_addresstypecode2 = @v_addresstypecode3
               begin
                  select @v_addresstypecode3 = NULL
               end

            if @v_addresstypecode1 = @v_addresstypecode3
               begin
                  select @v_addresstypecode3 = NULL
               end

         end /* if @v_defaultaddressnumber = 2 */

      if @v_defaultaddressnumber = 3
         begin
            if @v_addresstypecode3 is null  /*default to home mailing if null*/
               begin
                  select @i_addresscode = 3
                  select @v_addresstypecode3 = 3
               end
         else
            begin	
               select @i_addresscode = @v_addresstypecode3
            end

            /* Do not allow addresses with the same type */
            if @v_addresstypecode3 = @v_addresstypecode1
               begin
                  select @v_addresstypecode1 = NULL
               end

            if @v_addresstypecode3 = @v_addresstypecode2
               begin
                  select @v_addresstypecode2 = NULL
               end

            if @v_addresstypecode1 = @v_addresstypecode2
               begin
                  select @v_addresstypecode2 = NULL
               end

      end /* if @v_defaultaddressnumber = 3 */

      if @v_phone1 is not null 
         begin
            select @i_phone1code = 1
         end

      if @v_phone2 is not null 
         begin
            select @i_phone2code = 1
         end

      if @v_phone3 is not null 
         begin
            select @i_phone3code = 1
         end

      if @v_middlename is not null 
         begin
            select @c_middleinit = substring(@v_middlename,1,1) + '.'
         end
		
	
--cgates 2003.12.24 cgates: added bucode
      select @v_count = count(*)
         FROM contact
         WHERE contactkey = @v_authorkey

      IF @v_count = 0   /* insert */
         BEGIN
            insert into contact (contactkey, bucode, nameabbrcode, addresscode, firstname, lastname,
                                 middleinit, title, phone1, phone1code, phone2, phone2code, phone3, phone3code,
                                 notes, activeind, emailaddress, lastuserid, lastmaintdate, lastnameserch, firstnameserch)
                         values (@v_authorkey, @author_bucode, @v_nameabbrcode, @i_addresscode, @v_firstname, @v_lastname,
                                 @c_middleinit, @v_title, substring(@v_phone1,1,10), @i_phone1code,
                                 substring(@v_phone2,1,10), @i_phone2code, substring(@v_phone3,1,10), @i_phone3code,
                                 @v_notes, 1, @c_emailaddress, 'QSITRIG', getdate(), upper(@v_lastname), upper(@v_firstname))
            IF @@error != 0
               BEGIN
                  ROLLBACK TRANSACTION
                  select @err_msg = 'Could not update contact table (trigger level 2).'
                  print @err_msg
                END

   END /* INSERT */

   IF @v_count = 1
      BEGIN /*UPDATE*/
         update contact
            set nameabbrcode = @v_nameabbrcode,
                firstname  = @v_firstname,
                middleinit   = @c_middleinit,
                lastname   = @v_lastname ,
                title  = @v_title,
                addresscode = @i_addresscode,
                phone1  = substring(@v_phone1,1,30),
                phone1code = @i_phone1code,
                phone2  = substring(@v_phone2,1,30),
                phone2code = @i_phone2code,
                phone3  = substring(@v_phone3,1,30),
                phone3code = @i_phone3code,
                emailaddress = @c_emailaddress,
                notes  = @v_notes,
                firstnameserch  = upper(@v_firstname),
                lastnameserch = upper(@v_lastname),
                lastuserid = 'QSITRIG', 
                lastmaintdate = getdate()
            where contactkey= @v_authorkey

            IF @@error != 0
               BEGIN
                  ROLLBACK TRANSACTION
                  select @err_msg = 'Could not update contact table (trigger level 3).'
                  print @err_msg
                END

	--cgates 2003.12.24 cgates: simplified and added bucode
         /* REMOVE ALL ADDRESS, THIS PREVENTS POSIBILITY OF PRIMARY KEY ISSUES */

         DELETE FROM contactaddress WHERE addresscode = @v_addresstypecode1old AND contactkey = @v_authorkey
         DELETE FROM contactaddress WHERE addresscode = @v_addresstypecode2old AND contactkey = @v_authorkey
         DELETE FROM contactaddress WHERE addresscode = @v_addresstypecode3old AND contactkey = @v_authorkey
         DELETE FROM contactaddress WHERE addresscode = @v_addresstypecode1 AND contactkey = @v_authorkey
         DELETE FROM contactaddress WHERE addresscode = @v_addresstypecode2 AND contactkey = @v_authorkey
         DELETE FROM contactaddress WHERE addresscode = @v_addresstypecode3 AND contactkey = @v_authorkey
      END

   IF @v_addresstypecode1 IS NOT NULL AND (@v_addresstypecode1 <> 0)
      BEGIN
         IF ISNUMERIC(substring(@v_zip,1,5)) = 1
            BEGIN
               select @i_zipcode = convert(int, substring(@v_zip,1,5))
            END
         ELSE
            BEGIN
               select @i_zipcode = NULL
            END

         IF (@v_address1 IS NULL OR RTRIM(LTRIM(@v_address1)) = '') AND 
            (@v_address1line2 IS NULL OR RTRIM(LTRIM(@v_address1line2)) = '') AND
            (@v_address1line3 IS NULL OR RTRIM(LTRIM(@v_address1line3)) = '') AND
            (@v_city IS NULL OR RTRIM(LTRIM(@v_city)) = '') AND
            (@v_statecode IS NULL OR @v_statecode = 0) AND
            (@v_countrycode IS NULL OR @v_countrycode = 0) AND
            (@v_zip IS NULL OR RTRIM(LTRIM(substring(@v_zip,1,10))) = '')
            BEGIN
               SELECT @v_address1 = '<No Information>'
            END

         insert into contactaddress (contactkey, bucode, addresscode, address1, address2, address3,
                                     city, statecode, countrycode, zip, zipcode, lastuserid, lastmaintdate)
                             values (@v_authorkey, @author_bucode, @v_addresstypecode1, @v_address1, @v_address1line2, @v_address1line3,
                                     @v_city, @v_statecode, @v_countrycode, substring(@v_zip,1,10), @i_zipcode, 'QSITRIG', getdate())         
      END

   IF @v_addresstypecode2 IS NOT NULL AND (@v_addresstypecode2 <> 0)
      BEGIN
         IF ISNUMERIC(substring(@v_zip2, 1, 5)) = 1
            BEGIN
               select @i_zipcode = convert(int, substring(@v_zip2, 1, 5))
            END
         ELSE
            BEGIN
               select @i_zipcode = NULL
            END

         IF (@v_address2line1 IS NULL OR RTRIM(LTRIM(@v_address2line1)) = '') AND 
            (@v_address2line2 IS NULL OR RTRIM(LTRIM(@v_address2line2)) = '') AND
            (@v_address2line3 IS NULL OR RTRIM(LTRIM(@v_address2line3)) = '') AND
            (@v_city2 IS NULL OR RTRIM(LTRIM(@v_city2)) = '') AND
            (@v_statecode2 IS NULL OR @v_statecode2 = 0) AND
            (@v_countrycode2 IS NULL OR @v_countrycode2 = 0) AND
            (@v_zip2 IS NULL OR RTRIM(LTRIM(substring(@v_zip2,1,10))) = '')
            BEGIN
               SELECT @v_address2line1 = '<No Information>'
            END

         insert into contactaddress (contactkey, bucode, addresscode, address1, address2, address3,
                                     city, statecode, countrycode, zip, zipcode, lastuserid, lastmaintdate)
		             values (@v_authorkey, @author_bucode, @v_addresstypecode2, @v_address2line1, @v_address2line2, @v_address2line3,
                                     @v_city2, @v_statecode2, @v_countrycode2, substring(@v_zip2, 1, 10), @i_zipcode, 'QSITRIG', getdate())         
      END

   IF @v_addresstypecode3 IS NOT NULL AND (@v_addresstypecode3 <> 0)
      BEGIN
         IF ISNUMERIC(substring(@v_zip3, 1, 5)) = 1
            BEGIN
               select @i_zipcode = convert(int, substring(@v_zip3, 1, 5))
            END
         ELSE
            BEGIN
               select @i_zipcode = NULL
            END

         IF (@v_address3line1 IS NULL OR RTRIM(LTRIM(@v_address3line1)) = '') AND 
            (@v_address3line2 IS NULL OR RTRIM(LTRIM(@v_address3line2)) = '') AND
            (@v_address3line3 IS NULL OR RTRIM(LTRIM(@v_address3line3)) = '') AND
            (@v_city3 IS NULL OR RTRIM(LTRIM(@v_city3)) = '') AND
            (@v_statecode3 IS NULL OR @v_statecode3 = 0) AND
            (@v_countrycode3 IS NULL OR @v_countrycode3 = 0) AND
            (@v_zip3 IS NULL OR RTRIM(LTRIM(substring(@v_zip3,1,10))) = '')
            BEGIN
               SELECT @v_address3line1 = '<No Information>'
            END

         insert into contactaddress (contactkey, bucode, addresscode, address1, address2, address3,
                                     city, statecode, countrycode, zip, zipcode, lastuserid, lastmaintdate)
		             values (@v_authorkey, @author_bucode, @v_addresstypecode3, @v_address3line1, @v_address3line2, @v_address3line3,
                                     @v_city3, @v_statecode3, @v_countrycode3, substring(@v_zip3, 1, 10), @i_zipcode, 'QSITRIG', getdate())         
      END

  

   IF @@error != 0
      BEGIN
         ROLLBACK TRANSACTION
         select @err_msg = 'Could not update contactaddress table (trigger).'
         print @err_msg
     END
END	
	
GO

