if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[qauthor_contact_to_author]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[qauthor_contact_to_author]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE qauthor_contact_to_author
(
  @i_ContactKey		INT,
  @i_UserID       VARCHAR(30),
  @o_error_code		INT OUT,
  @o_error_desc		VARCHAR(2000) OUT 
)
AS

BEGIN
  DECLARE @ErrorValue INT,
      @CheckCount     INT,
      @LoopCount      TINYINT,
      @ScopeTag       VARCHAR(15),
      @DetailKey      INT,
      @AddressKey1    INT,
      @AddressKey2    INT,
      @AddressKey3    INT,
      @AddressType1   SMALLINT,
      @AddressType2   SMALLINT,
      @AddressType3   SMALLINT,
      @Address1Line1  VARCHAR(80),  --VARCHAR(255) on globalcontactaddress
      @Address1Line2  VARCHAR(80),  --VARCHAR(255)
      @Address1Line3  VARCHAR(80),  --VARCHAR(255)
      @Address2Line1  VARCHAR(80),  --VARCHAR(255)
      @Address2Line2  VARCHAR(80),  --VARCHAR(255)
      @Address2Line3  VARCHAR(80),  --VARCHAR(255)
      @Address3Line1  VARCHAR(80),  --VARCHAR(255)
      @Address3Line2  VARCHAR(80),  --VARCHAR(255)
      @Address3Line3  VARCHAR(80),  --VARCHAR(255)
      @City1          VARCHAR(25),
      @City2          VARCHAR(25),
      @City3          VARCHAR(25),
      @StateCode1     SMALLINT,
      @StateCode2     SMALLINT,
      @StateCode3     SMALLINT,
      @Zip1           VARCHAR(10),
      @Zip2           VARCHAR(10),
      @Zip3           VARCHAR(10),
      @CountryCode1   SMALLINT,
      @CountryCode2   SMALLINT,
      @CountryCode3   SMALLINT,
      @PrimaryInd1  TINYINT,
      @PrimaryInd2  TINYINT,
      @PrimaryInd3  TINYINT,
      @MethodKey      INT,
      @MethodCode     SMALLINT,
      @MethodValue    VARCHAR(100), --VARCHAR2(100) on globalcontactmethod
      @PhoneCount     TINYINT,
      @FaxCount       TINYINT,
      @EmailCount     TINYINT,
      @Phone1         VARCHAR(50),
      @Phone2         VARCHAR(50),
      @Phone3         VARCHAR(50),
      @Fax1           VARCHAR(50),
      @Fax2           VARCHAR(50),
      @Fax3           VARCHAR(50),
      @Email1         VARCHAR(50),
      @Email2         VARCHAR(50),
      @Email3         VARCHAR(50),
      @Website        VARCHAR(80),
      @GroupName      VARCHAR(255),
      @LastName       VARCHAR(75),
      @CorpContrInd   TINYINT,
      @IndividualInd  TINYINT,
      @ErrorVar       INT,
      @RowcountVar    INT,
      @commenttypecode INT,
      @commenttypesubcode INT


  SET NOCOUNT ON
  
  SET @o_error_desc = ''
  SET @PhoneCount = 0
  SET @FaxCount = 0
  SET @EmailCount = 0

  -- Check if record exists on globalcontactauthor for this contactkey.
  -- If so, assume this contact already has been processed and author record exists.
  SELECT @CheckCount = count(*)
  FROM author 
  WHERE authorkey = @i_ContactKey

  IF @CheckCount > 0
    begin
      RETURN
   end
  /****** START TRANSACTION *******/
  --BEGIN TRANSACTION
  
  -- Insert into globalcontactauthor for contact
  INSERT INTO globalcontactauthor (masterkey, detailkey, scopetag)
  VALUES (@i_ContactKey, @i_ContactKey, 'contact')
 
  -- Loop through contact addresses (first 3)
	DECLARE contactaddress_cur CURSOR FOR
	  SELECT globalcontactaddresskey, LEFT(address1, 80), LEFT(address2, 80), LEFT(address3, 80),
	    addresstypecode, city, statecode, zipcode, countrycode, primaryind
	  FROM globalcontactaddress
	  WHERE globalcontactkey = @i_ContactKey
	  ORDER BY primaryind DESC
	
	OPEN contactaddress_cur
	
	FETCH NEXT FROM contactaddress_cur 
	INTO @AddressKey1, @Address1Line1, @Address1Line2, @Address1Line3,
	  @AddressType1, @City1, @StateCode1, @Zip1, @CountryCode1, @PrimaryInd1
	  
	SET @LoopCount = 1
	SET @DetailKey = @AddressKey1

	WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN
  
    SET @ScopeTag = 'addr' + CONVERT(VARCHAR, @LoopCount)

--PRINT '(' + CONVERT(VARCHAR, @i_ContactKey) + ',' + CONVERT(VARCHAR, @DetailKey) + ',' + @ScopeTag + ')'
  
    --Insert into globalcontactauthor for each address occurance
    INSERT INTO globalcontactauthor (masterkey, detailkey, scopetag)
    VALUES (@i_ContactKey, @DetailKey, @ScopeTag)
    
--PRINT '(' + CONVERT(VARCHAR, @i_ContactKey) + ',' + CONVERT(VARCHAR, @DetailKey) + ',' + @ScopeTag + ')'
    
    SET @LoopCount = @LoopCount + 1
    IF @LoopCount = 2
      BEGIN
	      FETCH NEXT FROM contactaddress_cur 
	      INTO @AddressKey2, @Address2Line1, @Address2Line2, @Address2Line3,
	        @AddressType2, @City2, @StateCode2, @Zip2, @CountryCode2, @PrimaryInd2
	        
        SET @DetailKey = @AddressKey2	        
	    END
	  ELSE IF @LoopCount = 3
	    BEGIN
	      FETCH NEXT FROM contactaddress_cur 
	      INTO @AddressKey3, @Address3Line1, @Address3Line2, @Address3Line3,
	        @AddressType3, @City3, @StateCode3, @Zip3, @CountryCode3, @PrimaryInd3
	        
	      SET @DetailKey = @AddressKey3
	    END
	  ELSE  /* process first 3 addresses - exit if more than 3 addresses exist */
      BREAK
  END
  

	CLOSE contactaddress_cur
	DEALLOCATE contactaddress_cur
	
	
  -- Loop through contact methods to extract phone, fax, email and website
	DECLARE contactmethod_cur CURSOR FOR
	  SELECT globalcontactmethodkey, contactmethodcode, contactmethodvalue
	  FROM globalcontactmethod
	  WHERE globalcontactkey = @i_ContactKey
	  ORDER BY primaryind DESC
	
	OPEN contactmethod_cur
	
	FETCH NEXT FROM contactmethod_cur 
	INTO @MethodKey, @MethodCode, @MethodValue
	
	WHILE (@@FETCH_STATUS = 0)  /*LOOP*/
  BEGIN

   	SET @DetailKey = @MethodKey
  	
  	IF @MethodCode = 1  --phone
  	  BEGIN
  	    SET @PhoneCount = @PhoneCount + 1  	    
  	    -- only process first 3 phone numbers
  	    IF @PhoneCount = 1
  	      SET @Phone1 = LEFT(@MethodValue, 50)
  	    ELSE IF @PhoneCount = 2
  	      SET @Phone2 = LEFT(@MethodValue, 50)
  	    ELSE IF @PhoneCount = 3
  	      SET @Phone3 = LEFT(@MethodValue, 50)
        ELSE  	    
  	      BREAK
  	      
  	    SET @ScopeTag = 'phone' + CONVERT(VARCHAR, @PhoneCount)  	    
  	  END
  	ELSE IF @MethodCode = 2 --fax
  	  BEGIN
  	    SET @FaxCount = @FaxCount + 1  	    
  	    -- only process first 3 fax numbers
  	    IF @FaxCount = 1
  	      SET @Fax1 = LEFT(@MethodValue, 50)
  	    ELSE IF @FaxCount = 2
  	      SET @Fax2 = LEFT(@MethodValue, 50)
  	    ELSE IF @FaxCount = 3
  	      SET @Fax3 = LEFT(@MethodValue, 50)
        ELSE  	    
  	      BREAK
  	        	    
  	    SET @ScopeTag = 'fax' + CONVERT(VARCHAR, @FaxCount)
  	  END
  	ELSE IF @MethodCode = 3 --Email
  	  BEGIN
  	    SET @EmailCount = @EmailCount + 1
  	    -- only process first 3 email addresses
  	    IF @EmailCount = 1
  	      SET @Email1 = LEFT(@MethodValue, 50)
  	    ELSE IF @EmailCount = 2
  	      SET @Email2 = LEFT(@MethodValue, 50)
  	    ELSE IF @EmailCount = 3
  	      SET @Email3 = LEFT(@MethodValue, 50)
        ELSE  	    
  	      BREAK
  	    
  	    SET @ScopeTag = 'email' + CONVERT(VARCHAR, @EmailCount)
  	  END
  	ELSE IF @MethodCode = 4 --Website
  	  BEGIN
  	    SET @Website = LEFT(@MethodValue, 80)
  	    BREAK
  	  END
  	ELSE  --other method types - do not process
  	  BREAK

--PRINT '(' + CONVERT(VARCHAR, @i_ContactKey) + ',' + CONVERT(VARCHAR, @DetailKey) + ',' + @ScopeTag + ')'

    --Insert into globalcontactauthor for each method occurance
    INSERT INTO globalcontactauthor (masterkey, detailkey, scopetag)
    VALUES (@i_ContactKey, @DetailKey, @ScopeTag)
    
	  FETCH NEXT FROM contactmethod_cur 
	  INTO @MethodKey, @MethodCode, @MethodValue
  END
  
  CLOSE contactmethod_cur
  DEALLOCATE contactmethod_cur
		
  /******* Now insert into author table *******/
  -- First set corporatecontributorind if individualind on globalcontact is 0
  -- Also set last name equal to group name if contact is not an individual
  SELECT @IndividualInd = individualind, @GroupName = groupname, @LastName = lastname
    FROM globalcontact
   WHERE globalcontactkey = @i_ContactKey
  
  IF @IndividualInd = 1 BEGIN
    SET @CorpContrInd = 0
  END
  ELSE BEGIN
    SET @CorpContrInd = 1
    SET @LastName = LEFT(@GroupName, 75)
  END

	INSERT INTO author
	  (authorkey,
	  displayname,
	  firstname,
	  lastname,
	  middlename,
	  nameabbrcode,
	  ssn,
	  activeind,
	  notes,
	  uscitizenind,
	  defaultaddressnumber,
	  corporatecontributorind,
	  authorsuffix,
	  authordegree,
	  authorurl,
	  address1,
	  address1line2,
	  address1line3,
	  addresstypecode1,
	  city,
	  statecode,
	  zip,
	  countrycode,
	  phone1,
	  fax1,
	  emailaddress1,
	  address2line1,
	  address2line2,
	  address2line3,
	  addresstypecode2,
	  city2,
	  statecode2,
	  zip2,
	  countrycode2,
	  phone2,
	  fax2,
	  emailaddress2,	
	  address3line1,
	  address3line2,
	  address3line3,
	  addresstypecode3,
	  city3,
	  statecode3,
	  zip3,
	  countrycode3,
	  phone3,
	  fax3,
	  emailaddress3,		
	  lastuserid,
	  lastmaintdate)
  SELECT @i_ContactKey,
	  LEFT(displayname, 80),
	  firstname,
	  @LastName,
	  middlename,
	  accreditationcode,
	  LEFT(ssn, 9),
	  1,
	  LEFT(globalcontactnotes, 255),
	  uscitizenind,
	  1,
	  @CorpContrInd,	
	  suffix,
	  degree,
	  @Website,
	  @Address1Line1,
	  @Address1Line2,
	  @Address1Line3,
	  @AddressType1,
	  @City1,
	  @StateCode1,
	  @Zip1,
	  @CountryCode1,
	  @Phone1,
	  @Fax1,
	  @Email1,
	  @Address2Line1,
	  @Address2Line2,
	  @Address2Line3,
	  @AddressType2,
	  @City2,
	  @StateCode2,
	  @Zip2,
	  @CountryCode2,
	  @Phone2,
	  @Fax2,
	  @Email2,	
	  @Address3Line1,
	  @Address3Line2,
	  @Address3Line3,
	  @AddressType3,
	  @City3,
	  @StateCode3,
	  @Zip3,
	  @CountryCode3,
	  @Phone3,
	  @Fax3,
	  @Email3,		
	  @i_UserID,
	  getdate()	  
  FROM globalcontact
  WHERE globalcontactkey = @i_ContactKey

  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0 OR @RowcountVar = 0 BEGIN
    --ROLLBACK TRANSACTION
    SET @o_error_code = 1
    SET @o_error_desc = 'no data found: globalcontactkey = ' + CAST(@i_ContactKey AS VARCHAR)
    return
  END
  
  --COMMIT TRANSACTION
  
  -- author biography
  SELECT @RowcountVar=count(*)
    FROM gentables
   WHERE tableid = 528 and
         qsicode = 2

  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
  IF @ErrorVar <> 0 BEGIN
    SET @o_error_code = -1
    SET @o_error_desc = 'Unable to update author table: Could not access gentables table.'
    RETURN
  END 

  IF @RowcountVar > 0 BEGIN
    SELECT @commenttypecode=datacode, @commenttypesubcode=0
      FROM gentables
     WHERE tableid = 528 and
           qsicode = 2

    SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
    IF @ErrorVar <> 0 BEGIN
      SET @o_error_code = -1
      SET @o_error_desc = 'Unable to update author table: Could not access gentables table.'
      RETURN
    END      
  END

  INSERT INTO globalcontactauthor (masterkey, detailkey, scopetag)
  VALUES (@i_ContactKey, @commenttypecode, 'biogr')

  	SELECT @RowcountVar=count(*)
      FROM author a, globalcontactauthor g, qsicomments c
   WHERE a.authorkey = g.masterkey and
         g.detailkey = c.commentkey and
         a.authorkey = @i_ContactKey and
         c.commentkey = @i_ContactKey and
         c.commenttypecode = @commenttypecode and
         COALESCE(c.commenttypesubcode,0) = @commenttypesubcode

	IF @RowcountVar > 0 BEGIN
	  -- update author table
		  UPDATE author
			  SET lastuserid=@i_UserID,lastmaintdate=getdate(),biography=c.commenttext
			 FROM author a, globalcontactauthor g, qsicomments c
			WHERE a.authorkey = g.masterkey and
					g.detailkey = c.commentkey and
					a.authorkey = @i_ContactKey and
					c.commentkey = @i_ContactKey and
					c.commenttypecode = @commenttypecode and
					COALESCE(c.commenttypesubcode,0) = @commenttypesubcode
		
		  SELECT @ErrorVar = @@ERROR, @RowcountVar = @@ROWCOUNT
		  IF @ErrorVar <> 0 BEGIN
			 SET @o_error_code = -1
			 SET @o_error_desc = 'Unable to update author table: Update failed (author bio).'
			 RETURN
		  END 
		
	--	PRINT '(' + CONVERT(VARCHAR, @i_ContactKey) + 'after update to author table' + ')'
	END
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXEC ON qauthor_contact_to_author TO PUBLIC
GO


 


