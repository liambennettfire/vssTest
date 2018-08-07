PRINT 'STORED PROCEDURE : dbo.customer_insert'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'customer_insert')
	BEGIN
		PRINT 'Dropping Procedure dbo.customer_insert'
		DROP  Procedure  dbo.customer_insert
	END

GO

PRINT 'Creating Procedure dbo.customer_insert'
GO
CREATE Procedure dbo.customer_insert
  @i_customerparentkey int,
  @i_customerlongname varchar(100),
  @i_customershortname varchar(30) = null,
  @i_address1 varchar(50)      = null,
  @i_address2 varchar(50)      = null,
  @i_address3 varchar(50)      = null,
  @i_city varchar(25)          = null,
  @i_state char(2)             = null,
  @i_zipcode varchar(10)       = null,
  @i_wwwaddress varchar(100)   = null,
  @i_user varchar(100),
  @o_customerkey int out,
  @o_error_code int out,
  @o_error_desc varchar(200) out 
AS

/******************************************************************************
**		File: customer_insert.sql
**		Name: customer_insert
**		Desc: Given a new set of customer information insert a new
**            customer and associated orgentry information.
**
**      If the long name matches an existing entry, the key for
**      that entry is returned and the rest of the information
**      is not used.  It is assumed that once the key is used to
**      to update the database the rest of the information will
**      be made up-to-date.
**
**              
**
**		Auth: James P. Weber
**		Date: 13 Aug 2003
**    
*******************************************************************************/

-- If we have a particular key, then just
-- get it by the key.  Otherwise use the
-- parent key to get the requested records.
BEGIN
    BEGIN TRANSACTION
    
    DECLARE @l_ErrorCount int
    SET @l_ErrorCount = 0

    DECLARE @l_error_summary varchar(200)
    SET @l_error_summary = ''

    
    SET @o_error_code = 0 ;
    SET @o_error_desc = 'Did Not Complete!';

    SET @o_customerkey = null;
    SELECT @o_customerkey=customerkey from customer where customerlongname = @i_customerlongname;

    if (@o_customerkey is null)
    BEGIN

      -- For now onlyl make this work at 2nd level, first level is done
      -- by hand.  Default the parent to the eloquence customer.  If we
      -- use this somewhere else, allow the computation of the first
      -- level customer from existing customers.
      if (@i_customerparentkey is null)
      BEGIN
              SELECT @o_customerkey = 14;
      END

      -- Compute the default customer key for the customer parent.
      SET @o_customerkey = @i_customerparentkey * 1000 + 1;
      
      -- Calculate it if others all ready exist.
      SELECT @o_customerkey = max(customerkey) + 1 from customer  where customerparentkey = @i_customerparentkey;

      -- Verify that we have one.
      if ( @o_customerkey is null)
      BEGIN
        SET @o_customerkey = @i_customerparentkey * 1000 + 1;
      END
      
      -- Compute the eloquence id for the key.
      DECLARE @KeyAsString varchar(6);
      DECLARE @eloqcustomerid varchar(6); 
      SET @KeyAsString = CONVERT(varchar, @o_customerkey);
      SET @eloqcustomerid = STUFF('000000', 7-LEN(@KeyAsString), LEN(@KeyAsString), @KeyAsString)

     -- DEBUG
     -- PRINT @eloqcustomerid;

      INSERT customer (customerkey, eloqcustomerid , customerparentkey, 
         customerlongname,
         customershortname,
         address1,
         address2,
         address3,
         city,
         state,
         zipcode,
         wwwaddress,
         lastuserid, 
         lastmaintdate ) VALUES 
        (@o_customerkey, 
         @eloqcustomerid, 
         @i_customerparentkey, 
         @i_customerlongname, 
         CONVERT(varchar(30), @i_customershortname),
         @i_address1,
         @i_address2,
         @i_address3,
         @i_city,
         @i_state,
         @i_zipcode,
         @i_wwwaddress,
         @i_user, 
         GETDATE());
         
         if @@Error <> 0
         BEGIN
           SET @l_ErrorCount = @l_ErrorCount + 1
           SET @l_error_summary = @l_error_summary + ' Error inserting into customer table:'
         END
         
         -- Insert the associated organization.
         INSERT orgentry (orgentrykey, orglevelkey, orgentrydesc, orgentryparentkey, orgentryshortdesc, deletestatus, createtitlesinpomsind, lastuserid, lastmaintdate)
           VALUES (@o_customerkey, 2, @i_customerlongname, @i_customerparentkey, CONVERT(varchar(20), @i_customershortname), 'N', 0, @i_user, GETDATE())
         
         if @@Error <> 0
         BEGIN
           SET @l_error_summary = @l_error_summary + ' Error inserting into orgentry table:'
           SET @l_ErrorCount = @l_ErrorCount + 1
         END
   
    END

    -- Commit if need be.
    if @l_ErrorCount = 0
    BEGIN
      -- Send back for additional information even if there was no error.
      SET @o_error_desc = @l_error_summary
      COMMIT TRANSACTION
    END
    ELSE
    BEGIN
      SET @o_error_desc = 'Rolling Back : ' + @l_error_summary
      SET @o_error_code = @l_ErrorCount
      ROLLBACK TRANSACTION
    END
   


END

GO

GRANT EXEC ON dbo.customer_insert TO PUBLIC
GO

PRINT 'STORED PROCEDURE : dbo.customer_insert complete'
GO

