if exists (select * from dbo.sysobjects where id = object_id(N'dbo.dwo_send_to_whse_dwocontact') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure dbo.dwo_send_to_whse_dwocontact
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dwo_send_to_whse_dwocontact
 (@i_taqprojectkey			 integer,
  @i_dwokey                 integer,
  @i_userid                 varchar(30),
  @o_error_code             integer output,
  @o_error_desc             varchar(2000) output)
AS


/******************************************************************************
**  File: 
**  Name: dwo_send_to_whse_dwocontact
**  Desc: This stored procedure will write a row to the dwocontact table 
**        for each contact that has a rolecode where the gentables_ext.gen1ind = 1
**        (Use in DWO) 
**        
**             
**
**    Auth: Kusum Basra
**    Date: 2 February 2009
*******************************************************************************
**    Change History
*******************************************************************************
**    Date:    Author:        Description:
**    --------    --------        -------------------------------------------
**    
*******************************************************************************/

  SET @o_error_code = 0
  SET @o_error_desc = ''
  DECLARE @error_var    INT
  DECLARE @rowcount_var INT

  IF @i_dwokey IS NULL OR @i_dwokey = 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to send to warehouse : dwokey is empty.'
    RETURN
  END 

/**** dwocontact table ********/

DECLARE 
	@v_contact_key			INT,
   @v_taqprojectcontactkey	INT,
   @v_contact_last		VARCHAR(75),
   @v_contact_first		VARCHAR(75),
	@v_title					VARCHAR(255),
	@v_address1				VARCHAR(255),
	@v_address2				VARCHAR(255),
   @v_address3				VARCHAR(255),
	@v_suite					VARCHAR(20),
	@v_city					VARCHAR(25),
	@v_statecode			INT,
	@v_zip					VARCHAR(15),
	@v_countrycode			INT,
	@v_nameabbrcode		INT,
   @v_companydesc  		VARCHAR(100),
   @v_phone					VARCHAR(50),
   @v_phonecode			INT,
 	@v_phone1				VARCHAR(30),
	@v_phone1code			INT,
   @v_phone2				VARCHAR(30),
	@v_phone2code			INT,
	@v_phone3				VARCHAR(30),
	@v_phone3code			INT,
	@v_phone4				VARCHAR(30),
	@v_phone4code			INT,
   @v_emailaddress		VARCHAR(100),
	@v_canadiancode		VARCHAR(2),
   @v_addresskey			INT,
   @v_count					INT,
   @v_count2            INT,
   @v_relationshipcode  INT,
   @v_maxlastmaintdate  DATETIME,
   @v_error INT,
   @v_rowcount INT  


 /** Declare a cursor for all contacts associated with the role type (tableid 285) **/
  /** where the gentables_ext.gen3ind = 1 (which is Use in DWO) **/
  DECLARE taqprojectcontactrole_cur CURSOR FOR
    SELECT t.taqprojectcontactkey
	  FROM taqprojectcontactrole t, gentables_ext g
	 WHERE t.rolecode = g.datacode
		AND g.tableid = 285
		AND g.gen3ind = 1
      AND t.taqprojectkey = @i_taqprojectkey
	 ORDER BY t.taqprojectcontactrolekey
        
  OPEN taqprojectcontactrole_cur

  FETCH NEXT FROM taqprojectcontactrole_cur INTO @v_taqprojectcontactkey	
  
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN
		SET @v_contact_last = ''
		SET @v_contact_first	= ''	
		SET @v_title = ''					
		SET @v_address1 = ''				
		SET @v_address2 = ''					
		SET @v_address3 = ''					
		SET @v_suite = ''						
		SET @v_city = ''						
		SET @v_statecode = 0			
		SET @v_zip = ''						
		SET @v_countrycode =0			
		SET @v_nameabbrcode = 0		
		SET @v_companydesc = ''	  		
		SET @v_phone = ''						
		SET @v_phonecode = 0			
		SET @v_phone1 = ''					
		SET @v_phone1code = 0			
		SET @v_phone2 = ''					
		SET @v_phone2code = 0			
		SET @v_phone3 = ''					
		SET @v_phone3code = 0			
		SET @v_phone4 = ''					
		SET @v_phone4code = 0			
		SET @v_emailaddress = ''			
		SET @v_canadiancode = ''			
		SET @v_addresskey	= 0		
		SET @v_count = 0
      SET @v_count2 = 0					


		SELECT @v_contact_key = globalcontactkey
        FROM globalcontact 
       WHERE globalcontactkey IN (SELECT globalcontactkey FROM taqprojectcontact WHERE taqprojectkey = @i_taqprojectkey 
                                                                                   AND taqprojectcontactkey = @v_taqprojectcontactkey)


		SELECT @v_contact_last = lastname, @v_contact_first =firstname, @v_title = jobtitle, @v_nameabbrcode = accreditationcode
		  FROM globalcontact
		 WHERE globalcontactkey = @v_contact_key

      ---- companydesc
  		 SELECT @v_count = count(*)
         FROM globalcontactrelationshipview
        WHERE globalcontactkey = @v_contact_key
          AND companyind = 1

       IF @v_count = 1
       BEGIN     
			SELECT @v_companydesc = relatedcontactname
           FROM globalcontactrelationshipview
          WHERE globalcontactkey = @v_contact_key
            AND companyind = 1
 		 END
       IF @v_count > 1
       BEGIN
			 SELECT @v_count2 = count(*)
				FROM globalcontactrelationshipview
			  WHERE globalcontactkey = @v_contact_key
				 AND companyind = 1
             AND keyind = 1

          IF @v_count2 = 1
			 BEGIN     
				SELECT @v_companydesc = relatedcontactname
				  FROM globalcontactrelationshipview
				 WHERE globalcontactkey = @v_contact_key
				   AND companyind = 1
               AND keyind = 1   
			 END
          IF @v_count2 > 1
          BEGIN
            SELECT @v_maxlastmaintdate = max(lastmaintdate)
              FROM globalcontactrelationshipview
				 WHERE globalcontactkey = @v_contact_key
				   AND companyind = 1
               AND keyind = 1
    
				SELECT @v_companydesc = relatedcontactname
				  FROM globalcontactrelationshipview
				 WHERE globalcontactkey = @v_contact_key
				   AND companyind = 1
               AND keyind = 1 
               AND lastmaintdate = @v_maxlastmaintdate
           END
        END
        IF @v_count = 0
        BEGIN
          SET @v_companydesc = ''
        END

      --- address fields
		SELECT @v_addresskey = addresskey
        FROM taqprojectcontact
       WHERE taqprojectkey = @i_taqprojectkey 
         AND globalcontactkey = @v_contact_key

		IF @v_addresskey IS NULL
      BEGIN
			SELECT @v_address1 = address1, @v_address2 = address2, @v_address3 = address3, @v_city = city, @v_statecode = statecode, @v_zip = zipcode,
                @v_countrycode = countrycode
           FROM globalcontactaddress
          WHERE globalcontactkey = @v_contact_key 
            AND primaryind = 1 
      END
      IF @v_addresskey > 0
      BEGIN
			SELECT @v_address1 = address1, @v_address2 = address2, @v_address3 = address3, @v_city = city, @v_statecode = statecode, @v_zip = zipcode,
                @v_countrycode = countrycode
           FROM globalcontactaddress
          WHERE globalcontactkey = @v_contact_key 
            AND globalcontactaddresskey = @v_addresskey 
      END

     -- phone
		SET @v_count = 0

		DECLARE globalcontactmethod_cur CURSOR FOR
		 SELECT contactmethodvalue, contactmethodsubcode
		   FROM globalcontactmethod
		  WHERE globalcontactkey = @v_contact_key
		 	 AND contactmethodcode = 1
	
		 OPEN globalcontactmethod_cur

		 FETCH NEXT FROM globalcontactmethod_cur INTO @v_phone, @v_phonecode
		 
		 WHILE (@@FETCH_STATUS = 0) 
		 BEGIN		
			SET @v_count = @v_count + 1
         
         IF @v_count = 1
         BEGIN
				SET @v_phone1 = @v_phone
				SET @v_phone1code = @v_phonecode
         END
         ELSE
         IF @v_count = 2
			BEGIN
				SET @v_phone2 = @v_phone
				SET @v_phone2code = @v_phonecode
         END
			ELSE IF @v_count = 3
			BEGIN
				SET @v_phone3 = @v_phone
				SET @v_phone3code = @v_phonecode
         END
			ELSE IF @v_count = 4
			BEGIN
				SET @v_phone4 = @v_phone
				SET @v_phone4code = @v_phonecode
         END

			FETCH NEXT FROM globalcontactmethod_cur INTO @v_phone, @v_phonecode
		 END /* @@FETCH_STATUS=0 - globalcontactmethod_cur cursor */
    
		 CLOSE globalcontactmethod_cur 
		 DEALLOCATE globalcontactmethod_cur

		SELECT @v_emailaddress = contactmethodvalue
		  FROM globalcontactmethod
		 WHERE globalcontactkey = @v_contact_key
		   AND contactmethodcode = 3
         AND primaryind = 1

		
		INSERT INTO dwocontact (dwokey,contactkey,contact_last,contact_first,title,address1,address2,address3,suite,
			city,statecode,zip,countrycode,nameabbrcode,companydesc,phone1,phone1code,phone2,phone2code,phone3,phone3code,
         phone4,phone4code,emailaddress,lastmaintdate,lastuserid,canadiancode)
      VALUES(@i_dwokey,@v_contact_key,@v_contact_last,@v_contact_first,@v_title,@v_address1,@v_address2,@v_address3,NULL,
         @v_city,@v_statecode,@v_zip,@v_countrycode,@v_nameabbrcode,@v_companydesc,@v_phone1,@v_phone1code,@v_phone2,@v_phone2code,@v_phone3,@v_phone3code,
         @v_phone4,@v_phone4code,@v_emailaddress,getdate(),@i_userid,NULL)
       
       
        SELECT @v_error = @@ERROR, @v_rowcount = @@ROWCOUNT
		IF @v_error <> 0 OR @v_rowcount = 0 BEGIN
		  SET @o_error_code = -1
		  SET @o_error_desc = 'Error inserting to dwcontact table (contactkey=' + CAST(@v_contact_key AS VARCHAR)  + ' )'
		  CLOSE taqprojectcontactrole_cur 
		  DEALLOCATE taqprojectcontactrole_cur
		  RETURN 
		END  

		FETCH NEXT FROM taqprojectcontactrole_cur INTO @v_taqprojectcontactkey
  END /* @@FETCH_STATUS=0 - taqprojectcontactrole_cur cursor */
    
  CLOSE taqprojectcontactrole_cur 
  DEALLOCATE taqprojectcontactrole_cur

GO
GRANT EXEC ON dwo_send_to_whse_dwocontact TO PUBLIC
GO



