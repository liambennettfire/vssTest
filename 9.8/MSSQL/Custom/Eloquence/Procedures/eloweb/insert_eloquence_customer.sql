PRINT 'STORED PROCEDURE : qsidba.insert_eloquence_customer'
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

 
 IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'insert_eloquence_customer')
	BEGIN
		PRINT 'Dropping Procedure insert_eloquence_customer'
		DROP  Procedure  qsidba.insert_eloquence_customer
	END

GO

PRINT 'Creating Procedure insert_eloquence_customer'
GO
CREATE Procedure qsidba.insert_eloquence_customer
  @i_customerlongname varchar(40),
  @i_customershortname varchar(20),
  @i_eloqcustomerid varchar(6), 
  @i_address1 varchar(50), 
  @i_city varchar(25), 
  @i_state varchar(2), 
  @i_zipcode varchar(10), 
  @i_country varchar(30), 
  @i_lastuserid varchar(30), 
  @i_wwwaddress varchar(100),
  @o_customerkey int out,
  @o_error_code int out,
  @o_error_desc char out 
AS

/******************************************************************************
**		File: insert_eloquence_customer.sql
**		Name: insert_eloquence_customer
**		Desc: This stored procedure inserts a record into
**            the customer table based on the needs of 
**            eloquence web site.
**
**		Return values:
** 
**		Called by:   
**              
**		Parameters:
**		Input							Output
**     ----------						-----------
**
**		Auth: James P. Weber
**		Date: 03 Jun 2003
*******************************************************************************
**		Change History
*******************************************************************************
**		Date:		Author:				Description:
**		--------		--------				-------------------------------------------
**    
*******************************************************************************/

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION CreateCustomer


select o_customerkey=max(customerkey) + 1 from customer where customerparentkey=14;
	
INSERT customer (customerkey, customerlongname, customershortname, eloqcustomerid, address1, city, state, zipcode, country, lastuserid, lastmaintdate, wwwaddress, customerparentkey ) 
VALUES (@o_customerkey, @i_customerlongname, @i_customershortname, @i_eloqcustomerid, @i_address1, @i_city, @i_state, @i_zipcode, @i_country, @i_lastuserid, GETDATE(), @i_wwwaddress, 14 )

INSERT orgentry (orgentrykey, orglevelkey, orgentrydesc, orgentryparentkey, orgentryshortdesc, deletestatus, lastuserid, lastmaintdate)
    VALUES (@o_customerkey, 2, @i_customerlongname, 14, @i_customershortname, 'N', @i_lastuserid, GETDATE())

COMMIT TRANSACTION CreateCustomer
GO

GRANT EXEC ON qsidba.insert_eloquence_customer TO PUBLIC

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

PRINT 'STORED PROCEDURE : qsidba.insert_eloquence_customer complete'
GO


