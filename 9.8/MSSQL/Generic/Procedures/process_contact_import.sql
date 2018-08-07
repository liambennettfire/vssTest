
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.process_contact_import') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP proc dbo.process_contact_import
  END

GO

CREATE PROCEDURE dbo.process_contact_import
  (@batchkey INT, @importsrckey INT, @startkey INT,
   @endkey INT, @userid VARCHAR(30), @importstatus INT OUTPUT)
AS

   DECLARE @importentrykey  INT,   
           @firstname       VARCHAR(75),   
           @middleinit      VARCHAR(2),   
           @lastname        VARCHAR(75),   
           @title           VARCHAR(80),   
           @phone1          VARCHAR(30),   
           @phone2          VARCHAR(30),   
           @phone3          VARCHAR(30),      
           @phone4          VARCHAR(30),   
           @phonecode1desc  VARCHAR(50),   
           @phonecode2desc  VARCHAR(50),   
           @phonecode3desc  VARCHAR(50),   
           @phonecode4desc  VARCHAR(50),   
           @companyname     VARCHAR(50),   
           @deptname        VARCHAR(50),   
           @activeind       TINYINT,   
           @privatind       CHAR(1),   
           @mediadesc       VARCHAR(50),   
           @marketdesc      VARCHAR(50),   
           @emailaddress    VARCHAR(50),   
           @phone1code      INT,
           @phone2code      INT,
           @phone3code      INT,
           @phone4code      INT,
           @impmsg          VARCHAR(255),
           @companycode     INT,
           @deptkey         INT,
           @bucode          INT,
           @mediacode       INT,
           @marketcode      INT,
           @dupcount        INT,
           @contactkey      INT,
           @salutationcode  INT,
           @addresscode     INT,
           @salutation      VARCHAR(40),
           @host            VARCHAR(40),
           @affiliation     VARCHAR(40),
           @rep             VARCHAR(50),
           @url             VARCHAR(80),
           @notes           VARCHAR(2000),
           @addressstatus   INT,
           @categorystatus  INT

   DECLARE importcontact_cur CURSOR FOR
        SELECT importentrykey, firstname = ISNULL(firstname, '<NULL>'), middleinit, lastname = ISNULL(lastname, '<NULL>'), 
               title, phone1, phone2, phone3, phone4, phonecode1desc, phonecode2desc, phonecode3desc, phonecode4desc, companyname, 
               deptname, activeind = ISNULL(activeind, 1), privatind, mediadesc, marketdesc, emailaddress, 
               salutation, host, affiliate, rep, url, notes  
          FROM importcontacts   
         WHERE importsrckey = @importsrckey AND
               importbatchkey = @batchkey AND
               importentrykey >=  @startkey AND
               importentrykey <= @endkey
      ORDER BY importentrykey

  

   SELECT @importstatus = 0

   OPEN importcontact_cur

   FETCH NEXT FROM importcontact_cur INTO @importentrykey, @firstname, @middleinit, @lastname, @title, @phone1, @phone2,
                                          @phone3, @phone4, @phonecode1desc, @phonecode2desc, @phonecode3desc, @phonecode4desc,
                                          @companyname, @deptname, @activeind, @privatind, @mediadesc, @marketdesc, @emailaddress,
                                          @salutation, @host, @affiliation, @rep, @url, @notes

   WHILE (@@FETCH_STATUS <> -1) AND (@importstatus = 0)
      BEGIN
      
         -- Assume all will be ok
         SELECT @importstatus = 0

         -- Record which record we are processing
         SELECT @impmsg = 'Processing row ' +  cast(@importentrykey as varchar(10)) + ', Contact: ' + @lastname + ', ' + @firstname
         EXEC importmsg @importsrckey, @batchkey, 2, 0, @impmsg, @userid
           
         IF @firstname = '<NULL>' 
           BEGIN
             SELECT @impmsg = 'No first name provided.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 101
           END

         IF @lastname = '<NULL>'
           BEGIN
             SELECT @impmsg = 'No last name provided.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 102
           END

         /* Check data - get data codes, etc */
         EXEC import_contact_phone @batchkey, @importsrckey, @phone1, @phonecode1desc, @userid, '1', @importstatus OUTPUT, @phone1code OUTPUT
         EXEC import_contact_phone @batchkey, @importsrckey, @phone2, @phonecode2desc, @userid, '2', @importstatus OUTPUT, @phone2code OUTPUT
         EXEC import_contact_phone @batchkey, @importsrckey, @phone3, @phonecode3desc, @userid, '3', @importstatus OUTPUT, @phone3code OUTPUT
         EXEC import_contact_phone @batchkey, @importsrckey, @phone4, @phonecode4desc, @userid, '4', @importstatus OUTPUT, @phone4code OUTPUT

         EXEC get_publicity_bu @userid, @bucode OUTPUT
         IF @bucode IS NULL
           BEGIN
             SELECT @impmsg = 'User business unit not found for user ' + @userid + '.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 103
           END

         EXEC get_publicity_md @mediadesc, @bucode, @importsrckey, @mediacode OUTPUT
         If (@mediadesc IS NOT NULL) AND (@mediadesc <> '') AND (@mediacode IS NULL)
           BEGIN
             SELECT @impmsg = 'Media "' + @mediadesc + '" could not be mapped.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 104
           END

         EXEC get_publicity_mk @marketdesc, @bucode, @importsrckey, @marketcode OUTPUT
         If (@marketdesc IS NOT NULL) AND (@marketdesc <> '') AND (@marketcode IS NULL)
           BEGIN
             SELECT @impmsg = 'Market "' + @marketdesc + '" could not be mapped.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 105
           END

         EXEC get_publicity_co @companyname, @bucode, @companycode OUTPUT
         IF (@companycode IS NULL) AND (@companyname IS NOT NULL) AND (@companyname <> '')
           BEGIN
             SELECT @impmsg = 'Company key not found for "' + @companyname + '" for Business Unit.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 106
           END

         EXEC get_publicity_dp @deptname, @companycode, @bucode, @deptkey OUTPUT
         IF (@deptkey IS NULL) AND ((@deptname IS NOT NULL) AND (@deptname <> ''))
           BEGIN
             SELECT @impmsg = 'Department key not found for "' + @deptname + '" at company "' + @companyname + '" for Business Unit.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 107
           END
           
         EXEC gentable_by_desc_import @importsrckey, 210, @salutation, 'N', @salutationcode OUTPUT
         If (@salutation IS NOT NULL) AND (@salutation <> '') AND (@salutationcode IS NULL)
           BEGIN
             SELECT @impmsg = 'Salutation could not be mapped.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 108
           END

         IF (@host IS NULL) OR (@host = '')
           BEGIN
             SELECT @host = hostdesc
               FROM dept
               WHERE deptkey = @deptkey AND
                     companykey = @companycode
           END

         IF (@affiliation IS NULL) OR (@affiliation = '')
           BEGIN
             SELECT @affiliation = affiliate
               FROM dept
              WHERE deptkey = @deptkey AND
                    companykey = @companycode
           END


         IF @deptkey IS NULL
           BEGIN
             SELECT @deptkey = 0
           END

         IF @companycode IS NULL
           BEGIN
             SELECT @companycode = 0
           END

         SELECT @dupcount = count(*) 
           FROM contact  
          WHERE UPPER(firstnameserch) = UPPER(@firstname) AND 
                UPPER(lastnameserch) = UPPER(@lastname) AND 
                bucode = @bucode AND 
                companykey = @companycode AND 
                deptkey = @deptkey AND 
                activeind = 1

         IF @dupcount > 0
           BEGIN
             SELECT @impmsg = 'Contact is a duplicate.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 109
           END

         EXEC get_next_key @userid, @contactkey OUTPUT
         IF @contactkey IS NULL
           BEGIN
             SELECT @impmsg = 'Failed to imported row ' +  cast(@importentrykey as varchar(10)) + ' - No contact key available , Contact: ' + @lastname + ', ' + @firstname
             EXEC importmsg @importsrckey, @batchkey, 2, 0, @impmsg, 0, @userid
             SELECT @importstatus = 110
           END
         ELSE
           BEGIN
             EXEC process_contact_address @batchkey, @importsrckey, @importentrykey, @contactkey, @bucode, @userid, @addresscode OUTPUT, @addressstatus OUTPUT

             EXEC process_contact_category @batchkey, @importsrckey, @importentrykey, @contactkey, @bucode, @userid, @categorystatus OUTPUT

             IF (@categorystatus <> 0) 
               BEGIN
                 SELECT @importstatus = 111
               END

             IF (@addressstatus <> 0)
               BEGIN
                 SELECT @importstatus = 112
               END
           END

         IF @importstatus = 0 
           BEGIN
             INSERT INTO contact (contactkey, bucode, addresscode, firstname, middleinit, lastname, title, 
                                  phone1, phone2, phone3, phone4, phone1code, phone2code, phone3code, phone4code,
                                  activeind, privateind, companykey, deptkey, mediacode, marketcode, emailaddress,
                                  lastuserid, lastmaintdate, lastnameserch, firstnameserch, nameabbrcode, host,
                                  affiliate, rep, url, notes)
                          VALUES (@contactkey, @bucode, @addresscode, @firstname, @middleinit, @lastname, @title, 
                                  @phone1, @phone2, @phone3, @phone4, @phone1code, @phone2code, @phone3code, @phone4code,
                                  1, 'N', @companycode, @deptkey, @mediacode, @marketcode, @emailaddress,
                                  @userid, getdate(), UPPER(@lastname), UPPER(@firstname), @salutationcode, @host,
                                  @affiliation, @rep, @url, @notes)
                                   
             SELECT @impmsg = 'Import row ' +  cast(@importentrykey as varchar(10)) + ' completed for contact: ' + @lastname + ', ' + @firstname 
             EXEC importmsg @importsrckey, @batchkey, 2, 0, @impmsg, @userid
           END
         ELSE
           BEGIN
             DELETE FROM contactaddress WHERE contactkey = @contactkey
             DELETE FROM contactsection WHERE contactkey = @contactkey
             SELECT @impmsg = 'Failed to import row ' +  cast(@importentrykey as varchar(10)) + ' for contact: ' + @lastname + ', ' + @firstname
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
           END

         /* Get next record */
         FETCH NEXT FROM importcontact_cur INTO @importentrykey, @firstname, @middleinit, @lastname, @title, @phone1, @phone2,
                                                @phone3, @phone4, @phonecode1desc, @phonecode2desc, @phonecode3desc, @phonecode4desc,
                                                @companyname, @deptname, @activeind, @privatind, @mediadesc, @marketdesc, @emailaddress,
                                                @salutation, @host, @affiliation, @rep, @url, @notes
      END -- WHILE

   CLOSE importcontact_cur
   DEALLOCATE importcontact_cur

RETURN 

GO


GRANT EXECUTE ON dbo.process_contact_import TO PUBLIC 

GO
