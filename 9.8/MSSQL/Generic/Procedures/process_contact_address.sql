IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = Object_id('dbo.process_contact_address') AND (type = 'P' OR type = 'RF'))
  BEGIN
    DROP proc dbo.process_contact_address
  END

GO


CREATE PROCEDURE dbo.process_contact_address
  (@batchkey INT, @importsrckey INT, @importentrykey INT, @contactkey INT, @bucode INT,
   @userid VARCHAR(30), @primaryaddesscode INT OUTPUT, @importstatus INT OUTPUT)

AS
   DECLARE @addresstype     VARCHAR(50),   
           @address1        VARCHAR(50),   
           @address2        VARCHAR(50),   
           @address3        VARCHAR(50),   
           @city            VARCHAR(25),   
           @state           VARCHAR(25),   
           @zip             VARCHAR(10),   
           @country         VARCHAR(50),   
           @suite           VARCHAR(50),
           @impmsg          VARCHAR(255),
           @statecode       INT,
           @countrycode     INT,
           @addresstypecode INT,
           @zipcode         INT,
           @subgroup        INT,
           @noaddress       INT,
           @addresscount    INT

   DECLARE importcontactaddr_cur CURSOR FOR
        SELECT subgroup, addresstype, address1, address2, address3, city, state, zip, country, suite
          FROM importcontactaddress
         WHERE importbatchkey = @batchkey AND
               importentrykey =  @importentrykey AND
               importsrckey = @importsrckey
      ORDER BY subgroup

BEGIN
   SELECT @primaryaddesscode = 0
   SELECT @importstatus = 0

   OPEN importcontactaddr_cur

   FETCH NEXT FROM importcontactaddr_cur 
              INTO @subgroup, @addresstype, @address1, @address2, 
                   @address3, @city, @state, @zip, @country, @suite

   WHILE (@@FETCH_STATUS <> -1)
      BEGIN
         SELECT @noaddress = 1
         
         EXEC gentable_by_desc_import @importsrckey, 207, @addresstype, 'N', @addresstypecode OUTPUT
         If (@subgroup = 1)
           BEGIN
             -- Group 1 is considered the default address - IT MUST EXIST
             If (@addresstypecode IS NULL)
               BEGIN
                 If @addresstype Is Null 
                   BEGIN
                     SELECT @impmsg = 'Default Address Type could not be mapped. Address type for group 1 was null.'
                   END
                 ELSE
                   BEGIN
                     SELECT @impmsg = 'Default Address Type could not be mapped. Address type for group 1 was "' + @addresstype + '"'
                   END
                 EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
                 SELECT @importstatus = 120
               END
             ELSE
               BEGIN
                 SELECT @primaryaddesscode = @addresstypecode
               END
           END

         -- Get state code
         EXEC gentable_by_desc_import @importsrckey, 160, @state, 'N', @statecode OUTPUT
         If (@state IS NOT NULL) AND (@state <> '') AND (@statecode IS NULL)
           BEGIN
             SELECT @impmsg = 'State "' + @state + '" could not be mapped.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 121
           END

         -- Get country code
         EXEC gentable_by_desc_import @importsrckey, 114, @country, 'N', @countrycode OUTPUT
         If (@country IS NOT NULL) AND (@country <> '') AND (@countrycode IS NULL)
           BEGIN
             SELECT @impmsg = 'Country "' + @country + '" could not be mapped.'
             EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
             SELECT @importstatus = 122
           END

          IF ((@address1 IS NULL) OR (@address1 = '')) AND ((@address2 IS NULL) OR (@address2 = '')) AND 
            ((@address3 IS NULL) OR (@address3 = '')) AND (@countrycode IS NULL) AND (@statecode IS NULL) AND 
            ((@city IS NULL) OR (@city = '')) AND ((@suite IS NULL) OR (@suite = ''))
           BEGIN
             If (@subgroup = 1)
               BEGIN
                 SELECT @impmsg = 'No address information provided for default address.'
                 EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
                 SELECT @importstatus = 123
               END
           END
         ELSE
           BEGIN
             If (@addresstypecode IS NULL)
               BEGIN
                 -- We have an address without an address type
                 If ((@addresstype IS NULL) OR (@addresstype = ''))
                   BEGIN
                     SELECT @impmsg = 'Address information provided with no address type mapped or available. Address type was blank.'
                   END
                 ELSE
                   BEGIN
                     SELECT @impmsg = 'Address information provided with no address type mapped or available. Address type was ' + @addresstype + '.'
                   END

                 EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
                 SELECT @importstatus = 124
               END
             ELSE
               BEGIN
                 -- We have an address with a valid address type, but does this type exist already?
                 SELECT @addresscount = COUNT(*)
                   FROM contactaddress
                  WHERE contactkey = @contactkey AND
                        bucode = @bucode AND
                        addresscode = @addresstypecode

                 If (@addresscount IS NULL) OR (@addresscount = 0)
                   BEGIN
                     SELECT @noaddress = 0
                   END
                 ELSE
                   BEGIN
                     SELECT @impmsg = 'Duplicate address type.'
                     EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
                     SELECT @importstatus = 125
                   END
               END 
           END             

         IF ISNUMERIC(Left(@zip, 5)) = 1
           BEGIN
             SELECT @zipcode = cast(Left(@zip, 5) as INT)
           END
         ELSE
           BEGIN
             SELECT @zipcode = 0
           END          

         If (@importstatus = 0) AND (@noaddress = 0)
            BEGIN
               INSERT INTO contactaddress (contactkey, bucode, addresscode, address1, address2, address3, city, statecode,
                                           zip, countrycode, suite, zipcode, lastuserid, lastmaintdate)
                                   VALUES (@contactkey, @bucode, @addresstypecode, @address1, @address2, @address3, @city, @statecode,
                                           @zip, @countrycode, @suite, @zipcode, @userid, getdate())
            END

         FETCH NEXT FROM importcontactaddr_cur 
                    INTO @subgroup, @addresstype, @address1, @address2, 
                         @address3, @city, @state, @zip, @country, @suite

      END -- WHILE

   CLOSE importcontactaddr_cur 
   DEALLOCATE importcontactaddr_cur 

   IF (@primaryaddesscode IS NULL) OR (@primaryaddesscode = 0)
     BEGIN
       SELECT @impmsg = 'No default address type could be determined.'
       EXEC importmsg @importsrckey, @batchkey, 2, 2, @impmsg, @userid
       SELECT @importstatus = 126
     END

   IF (@importstatus <> 0)
     BEGIN
       DELETE FROM contactaddress WHERE contactkey = @contactkey
     END

END

GO

GRANT EXECUTE ON dbo.process_contact_address TO PUBLIC

GO