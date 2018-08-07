IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.authortopublicity_load') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP proc dbo.authortopublicity_load
  END

GO


CREATE PROCEDURE dbo.authortopublicity_load 
AS 

   DECLARE @v_authorkey            int,
           @v_nameabbrcode         int,
           @v_firstname            varchar(75),
           @v_lastname             varchar(75),
           @v_middlename           varchar(75),
           @v_title                varchar(80),
           @v_phone1               varchar(50),
           @v_phone2               varchar(50),
           @v_phone3               varchar(50),
           @v_notes                varchar(255),
           @v_defaultaddressnumber int,
           @v_addresstypecode1     int,
           @v_addresstypecode2     int,
           @v_addresstypecode3     int,
           @v_emailaddress1        varchar(50),
           @v_emailaddress2        varchar(50),
           @v_emailaddress3        varchar(50),
           @v_address1             varchar(50),
           @v_address2line1        varchar(50),
           @v_address3line1        varchar(50),
           @v_address1line2        varchar(50),
           @v_address2line2        varchar(50),
           @v_address3line2        varchar(50),
           @v_address1line3        varchar(50),
           @v_address2line3        varchar(50), 
           @v_address3line3        varchar(50),
           @v_city                 varchar(25),
           @v_city2                varchar(25),
           @v_city3                varchar(25),
           @v_statecode            int,
           @v_statecode2           int,
           @v_statecode3           int,
           @v_zip                  varchar(50),
           @v_zip2                 varchar(50),
           @v_zip3                 varchar(50),
           @v_countrycode          int,
           @v_countrycode2         int,
           @v_countrycode3         int,
           @err_msg                varchar(100),
           @i_phone1code	   int,
           @i_phone2code	   int,
           @i_phone3code	   int, 
           @i_addresscode	   int,  
           @v_count	           int,
           @i_statecode	           int,
           @i_countrycode	   int,
           @i_zipcode	           int,
           @c_city	           varchar(25),
           @c_zip	           varchar(50),
           @c_address1	           varchar(50),
           @c_address2 	           varchar(50), 
           @c_address3 	           varchar(50), 
           @c_emailaddress         varchar(50), 
           @c_middleinit           varchar(2) 

   DECLARE author_cur CURSOR FOR
      SELECT authorkey, nameabbrcode, firstname, lastname, middlename, title, phone1, phone2, phone3,
             notes, defaultaddressnumber, addresstypecode1, addresstypecode2, addresstypecode3, emailaddress1,
             emailaddress2, emailaddress3, address1, address2line1, address3line1, address1line2, address2line2,
             address3line2, address1line3, address2line3, address3line3, city, city2, city3, statecode, 
            statecode2, statecode3, zip, zip2, zip3, countrycode, countrycode2, countrycode3
      FROM author

BEGIN
   OPEN author_cur

   FETCH NEXT FROM author_cur 
      INTO @v_authorkey, @v_nameabbrcode, @v_firstname, @v_lastname, @v_middlename, @v_title, @v_phone1, @v_phone2, @v_phone3,
           @v_notes, @v_defaultaddressnumber, @v_addresstypecode1, @v_addresstypecode2, @v_addresstypecode3, @v_emailaddress1, 
           @v_emailaddress2, @v_emailaddress3, @v_address1, @v_address2line1, @v_address3line1, @v_address1line2, @v_address2line2,
           @v_address3line2, @v_address1line3, @v_address2line3, @v_address3line3, @v_city, @v_city2, @v_city3, @v_statecode,
           @v_statecode2, @v_statecode3, @v_zip, @v_zip2, @v_zip3, @v_countrycode, @v_countrycode2, @v_countrycode3 

   WHILE (@@FETCH_STATUS <> -1)
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
	
         select @v_count = count(*)
            FROM contact
            WHERE contactkey = @v_authorkey

         IF @v_count = 0   /* insert */
            BEGIN
               insert into contact (contactkey, bucode, nameabbrcode, addresscode, firstname, lastname,
                                    middleinit, title, phone1, phone1code, phone2, phone2code, phone3, phone3code,
                                    notes, activeind, emailaddress, lastuserid, lastmaintdate, lastnameserch, firstnameserch)
                            values (@v_authorkey, 35, @v_nameabbrcode, @i_addresscode, @v_firstname, @v_lastname,
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

               /* REMOVE ALL ADDRESS, THIS PREVENTS POSIBILITY OF PRIMARY KEY ISSUES */

               DELETE FROM contactaddress WHERE addresscode = @v_addresstypecode1 AND contactkey = @v_authorkey
               DELETE FROM contactaddress WHERE addresscode = @v_addresstypecode2 AND contactkey = @v_authorkey
               DELETE FROM contactaddress WHERE addresscode = @v_addresstypecode3 AND contactkey = @v_authorkey
            END

         IF @v_addresstypecode1 IS NOT NULL AND (@v_addresstypecode1 <> 0)
            BEGIN /* Insert address 1 */
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
                                   values (@v_authorkey, 35, @v_addresstypecode1, @v_address1, @v_address1line2, @v_address1line3,
                                           @v_city, @v_statecode, @v_countrycode, substring(@v_zip,1,10), @i_zipcode, 'QSITRIG', getdate())         
            END /* Insert address 1 */

         IF @v_addresstypecode2 IS NOT NULL AND (@v_addresstypecode2 <> 0)
            BEGIN /* Insert address 2 */
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
                                   values (@v_authorkey, 35, @v_addresstypecode2, @v_address2line1, @v_address2line2, @v_address2line3,
                                           @v_city2, @v_statecode2, @v_countrycode2, substring(@v_zip2, 1, 10), @i_zipcode, 'QSITRIG', getdate())         
            END /* Insert address 2 */

         IF @v_addresstypecode3 IS NOT NULL AND (@v_addresstypecode3 <> 0)
            BEGIN /* Insert address 3 */
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
                                   values (@v_authorkey, 35, @v_addresstypecode3, @v_address3line1, @v_address3line2, @v_address3line3,
                                           @v_city3, @v_statecode3, @v_countrycode3, substring(@v_zip3, 1, 10), @i_zipcode, 'QSITRIG', getdate())         
            END /* Insert address 3 */

  
         FETCH NEXT FROM author_cur INTO
            @v_authorkey, @v_nameabbrcode, @v_firstname, @v_lastname, @v_middlename, @v_title, @v_phone1, @v_phone2, @v_phone3,
            @v_notes, @v_defaultaddressnumber, @v_addresstypecode1, @v_addresstypecode2, @v_addresstypecode3, @v_emailaddress1, 
            @v_emailaddress2, @v_emailaddress3, @v_address1, @v_address2line1, @v_address3line1, @v_address1line2, @v_address2line2,
            @v_address3line2, @v_address1line3, @v_address2line3, @v_address3line3, @v_city, @v_city2, @v_city3, @v_statecode,
            @v_statecode2, @v_statecode3, @v_zip, @v_zip2, @v_zip3, @v_countrycode, @v_countrycode2, @v_countrycode3 

      END -- WHILE

   CLOSE author_cur
   DEALLOCATE author_cur
END	
	
GO

GRANT EXECUTE ON dbo.authortopublicity_load TO PUBLIC

GO


