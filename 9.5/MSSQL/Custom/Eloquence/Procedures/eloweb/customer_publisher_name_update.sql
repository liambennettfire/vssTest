 PRINT 'STORED PROCEDURE : customer_publisher_name_update'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'customer_publisher_name_update')
	BEGIN
		PRINT 'Dropping Procedure customer_publisher_name_update'
		DROP  Procedure  customer_publisher_name_update
	END

GO

PRINT 'Creating Procedure customer_publisher_name_update';
GO

CREATE Procedure customer_publisher_name_update
(
  @i_customer_orgentry_key              int,
  @i_new_name                           varchar(40),
  @o_error_code int out,
  @o_error_desc char out 
)

AS

/******************************************************************************
** File: customer_publisher_name_update.sql
** Name: customer_publisher_name_update
** Desc: This stored procedure updates the specified customer/organization to
**       have a new name.  This is needed by the eloquence web site to make sure
**       that imports work as expected and only happen for those companies that
**       have been using the site.
**
** Auth: James P. Weber
** Date: 09 DEC 2003
*******************************************************************************/

BEGIN
  BEGIN TRANSACTION

    DECLARE @l_tempError int;
    DECLARE @l_errorCount int;
    SET @l_errorCount = 0;
    SET @o_error_code = 0;
    SET @o_error_desc = '';
    
    update orgentry set orgentrydesc=@i_new_name  where orgentrykey = @i_customer_orgentry_key;
    
    SET @l_tempError = @@ERROR
    IF @l_tempError <> 0 BEGIN
 --       print 'Error updating the orgentry table.';
        SET @o_error_code = @o_error_code + 1;
        SET @l_errorCount = @l_errorCount + 1;
        SET @o_error_desc = @o_error_desc + 'Error update the publisher name in the orgentry table. ';
    END

    update customer set customerlongname=@i_new_name, customershortname=@i_new_name  where customerkey = @i_customer_orgentry_key;
    SET @l_tempError = @@ERROR
    IF @l_tempError <> 0 BEGIN
 --       print 'Error updating the customer table.';
        SET @o_error_code = @o_error_code + 2;
        SET @l_errorCount = @l_errorCount + 1;
        SET @o_error_desc = @o_error_desc + 'Error update the customer name in the customer table. ';
    END
    
    IF @l_errorCount > 0 BEGIN
        ROLLBACK TRANSACTION
    END
    ELSE BEGIN
        COMMIT TRANSACTION
    END
END

GO

GRANT EXEC ON customer_publisher_name_update TO PUBLIC
GO

PRINT 'STORED PROCEDURE : customer_publisher_name_update complete'
GO
