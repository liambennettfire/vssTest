PRINT 'STORED PROCEDURE : dbo.customer_select'
GO

IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'customer_select')
	BEGIN
		PRINT 'Dropping Procedure customer_select'
		DROP  Procedure  dbo.customer_select
	END

GO

PRINT 'Creating Procedure dbo.customer_select'
GO
CREATE Procedure dbo.customer_select
  @i_customerkey int,
  @i_customerparentkey int,
  @o_error_code int out,
  @o_error_desc char out 
AS

/******************************************************************************
**		File: customer_select.sql
**		Name: customer_select
**		Desc: Select a single customer or all customers of a single
**            parent.  
**
**		This template can be customized:
**              
**		Return values:
** 
**
**		Auth: James P. Weber
**		Date: 05 JUN 2003
**    
*******************************************************************************/

Select @o_error_code = 0
Select @o_error_desc = ''

-- If we have a particular key, then just
-- get it by the key.  Otherwise use the
-- parent key to get the requested records.
IF @i_customerkey is NOT NULL
BEGIN
    select * from customer where customerkey = @i_customerkey
END
ELSE
BEGIN
    IF @i_customerparentkey is NOT NULL
    BEGIN
        select * from customer where customerparentkey = @i_customerparentkey
    END  
END


GO

GRANT EXEC ON dbo.customer_select TO PUBLIC
GO

PRINT 'STORED PROCEDURE : dbo.customer_select complete'
GO

